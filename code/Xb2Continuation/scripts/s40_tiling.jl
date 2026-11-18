#!/usr/bin/env julia
# Tile the six S40 regions. Run from the repository root with --project=code/Xb2Continuation.
using Xb2Continuation
using HadronDynamics
using Printf

const LABELS = ("VV", "PV", "PP")
const MEV = 1000.0
const OUTPUT = @__DIR__
area(q) = (q.re[2] - q.re[1]) * (q.im[2] - q.im[1])
number(x) = isinf(x) ? "Inf" : @sprintf("%.12g", x)
bounds(q) = "Re [$(number(MEV*q.re[1])), $(number(MEV*q.re[2]))], Im [$(number(MEV*q.im[1])), $(number(MEV*q.im[2]))] MeV"
node_set(c) = join((LABELS[a] for a in c.nodes), "+")
dropped_set(c) = join((LABELS[a] for a in c.dropped), "+")
node_key(c) = isempty(c.dropped) ? node_set(c) : node_set(c) * " (" * dropped_set(c) * " dropped)"
csv_escape(x) = "\"" * replace(string(x), "\"" => "\"\"") * "\""

function csv_row(io, region, cell)
    q = cell.rectangle
    fields = Any[region, sheet_label(cell.sheet), MEV*q.re[1], MEV*q.re[2], MEV*q.im[1], MEV*q.im[2]]
    if cell isa RectangleCertificate
        vertices = join((number(MEV*real(v)) * ":" * number(MEV*imag(v)) for v in cell.path.vertices), ";")
        append!(fields, Any["certified", "", node_set(cell), dropped_set(cell), vertices, cell.slope, cell.s35_margin*MEV,
                            cell.window_margin*MEV, cell.z_margin*MEV, cell.clearance*MEV])
    else
        append!(fields, Any["excluded", cell.reason, "", "", "", "", "", "", "", ""])
    end
    println(io, join(csv_escape.(fields), ','))
end

function main()
    started = time_ns()
    params = HadronDynamics.BOchiEFT.Parameters()
    ths = thresholds_2pp(; params)
    e31 = params.mpi + ordering(1; params).t
    specifications = (
        ("A1", "(-,+,+)", (ths[3].delta, ths[2].delta), (-0.010, 0.0), 1e-4),
        ("A2", "(-,-,+)", (ths[2].delta, ths[1].delta), (-0.010, 0.0), 1e-4),
        ("B1", "(-,+,+)", (ths[3].delta, ths[2].delta), (-0.050, -0.010), 5e-4),
        ("B2", "(-,-,+)", (ths[2].delta, ths[1].delta), (-0.050, -0.010), 5e-4),
        ("C1", "(-,-,-)", (ths[1].delta, e31), (-0.010, 0.0), 1e-3),
        ("C2", "(-,-,-)", (ths[1].delta, e31), (-0.050, -0.010), 1e-3),
    )
    # The first call includes compilation; use its non-compilation time for estimates.
    probe = EnergyRectangle((-0.025, -0.020), (-0.010, -0.005))
    timing = @timed certify_rectangle(probe, Sheet("(-,-,+)"), ths)
    execution = max(timing.time - timing.compile_time, 0.001)
    println("First certify_rectangle: ", timing.time, " s (compilation ", timing.compile_time,
            " s; estimated execution ", execution, " s), ", typeof(timing.value))
    results = []
    open(joinpath(OUTPUT, "s40_tiling.csv"), "w") do csv
        println(csv, "region,sheet,re_lo,re_hi,im_lo,im_hi,status,reason,nodes,dropped,vertices,slope,s35_margin,window_margin,z_margin,clearance")
        for (name, label, re, im, requested_floor) in specifications
            region = EnergyRectangle(re, im)
            sheet = Sheet(label)
            initial = (ceil(Int, (re[2]-re[1])/0.005), ceil(Int, (im[2]-im[1])/0.005))
            floor = requested_floor
            estimate = prod(initial)*execution
            println(name, ": initial=", initial, ", floor=", MEV*floor,
                    " MeV, initial-grid execution estimate=", estimate, " s (refinement not included)")
            elapsed = @elapsed tiles = tile_rectangles(region, sheet, ths; initial, floor)
            total_area = sum((area(c.rectangle) for c in tiles.certified); init=0.0) +
                         sum((area(c.rectangle) for c in tiles.excluded); init=0.0)
            error = abs(total_area-area(region))/area(region)
            @assert error <= 1e-9 "Tiling area mismatch for $name: $error"
            println(name, ": ", length(tiles.certified), " certified, ", length(tiles.excluded),
                    " excluded; area relative error=", error, "; runtime=", elapsed, " s")
            for cell in Iterators.flatten((tiles.certified, tiles.excluded))
                csv_row(csv, name, cell)
            end
            flush(csv)
            push!(results, (; name, label, region, initial, requested_floor, floor, estimate,
                             elapsed, error, tiles))
        end
    end
    table = IOBuffer()
    println(table, "| Region | Sheet | Certified | Excluded | Certified area | Floor (MeV) | Runtime (s) |")
    println(table, "|:--|:--|--:|--:|--:|--:|--:|")
    for r in results
        fraction = sum((area(c.rectangle) for c in r.tiles.certified); init=0.0)/area(r.region)
        @printf(table, "| %s | %s | %d | %d | %.8f%% | %.6g | %.3f |\n", r.name, r.label,
                length(r.tiles.certified), length(r.tiles.excluded), 100fraction, MEV*r.floor, r.elapsed)
    end
    summary_table = String(take!(table))
    total_runtime = (time_ns()-started)/1e9
    open(joinpath(OUTPUT, "s40_tiling_summary.md"), "w") do io
        println(io, "# S40 adaptive tiling\n")
        println(io, "Run: `julia --startup-file=no --project=code/Xb2Continuation code/Xb2Continuation/scripts/s40_tiling.jl`.\n")
        println(io, "All energy/momentum coordinates and dimensional margins below and in the CSV are in MeV; slope is dimensionless. C5 is interval-rigorous in energy but **sampled along the path**, not interval-rigorous in momentum. Defaults: Lambda = 4 GeV, r_near = 0.1 GeV, n_sub = 8, qspacing = 0.001 GeV.\n")
        println(io, "First certificate wall time: $(timing.time) s; compilation: $(timing.compile_time) s; execution estimate: $execution s. End-to-end computation time (excluding package import): $total_runtime s.\n")
        println(io, summary_table)
        println(io, "The initial-grid estimate multiplies the first certificate's non-compilation time by the initial cell count; it excludes refinement and is not a runtime bound. All requested floors are retained: A1/A2 = 0.1 MeV, B1/B2 = 0.5 MeV, C1/C2 = 1 MeV. Early S35 exclusions are inexpensive and do not justify assuming every refinement costs a full C5 evaluation.\n")
        println(io, "Thresholds: ", join(("$(LABELS[a]) = $(number(MEV*ths[a].delta))" for a in 1:3), ", "), "; E31 = $(number(MEV*e31)) MeV.\n")
        # The figure consumes this parameter provenance rather than duplicating masses.
        println(io, "<!-- s40_metadata: {\"thresholds\":[", join((string(MEV*t.delta) for t in ths), ','),
                "],\"mu\":[", join((string(MEV*t.mu) for t in ths), ','), "],\"E31\":", MEV*e31, "} -->\n")
        for r in results
            println(io, "## $(r.name): $(r.label)\n")
            println(io, bounds(r.region), "; initial = $(r.initial); requested floor = $(number(MEV*r.requested_floor)) MeV; used floor = $(number(MEV*r.floor)) MeV.\n")
            println(io, "Area check: certified + excluded = $(number(area(r.region)*MEV^2)) MeV²; relative error = $(r.error) (required ≤ 1e-9). Runtime: $(r.elapsed) s.\n")
            println(io, "### Certified extrema\n\n| Quantity | Minimum | Cell extent |\n|:--|--:|:--|")
            for field in (:slope, :s35_margin, :window_margin, :z_margin, :clearance)
                if isempty(r.tiles.certified)
                    println(io, "| $field | n/a | no certified cells |")
                else
                    values = [getproperty(c,field) for c in r.tiles.certified]
                    val, index = findmin(values)
                    val *= field == :slope ? 1 : MEV
                    println(io, "| $field | $(number(val)) | $(bounds(r.tiles.certified[index].rectangle)) |")
                end
            end
            println(io, "\n### Node sets\n\n| Nodes | Certified cells |\n|:--|--:|")
            counts = Dict{String,Int}()
            for c in r.tiles.certified
                key = node_key(c)
                counts[key] = get(counts,key,0)+1
            end
            for key in sort(collect(keys(counts)))
                println(io, "| $key | $(counts[key]) |")
            end
            isempty(counts) && println(io, "| none | 0 |")
            println(io, "\n### Exclusions\n\nExtents are bounding boxes of each reason's cells, not claims that the entire bounding box is excluded.\n")
            println(io, "| Reason | Cells | Re extent (MeV) | Im extent (MeV) |\n|:--|--:|:--|:--|")
            reasons = sort(unique(c.reason for c in r.tiles.excluded))
            for reason in reasons
                cells = [c.rectangle for c in r.tiles.excluded if c.reason == reason]
                re = (minimum(q.re[1] for q in cells), maximum(q.re[2] for q in cells))
                im = (minimum(q.im[1] for q in cells), maximum(q.im[2] for q in cells))
                println(io, "| $reason | $(length(cells)) | [$(number(MEV*re[1])), $(number(MEV*re[2]))] | [$(number(MEV*im[1])), $(number(MEV*im[2]))] |")
            end
            isempty(reasons) && println(io, "| none | 0 | — | — |")
            println(io)
        end
    end
    println("SUMMARY TABLE\n", summary_table)
    println("Total computation runtime: ", total_runtime, " s")
    println("Wrote ", joinpath(OUTPUT, "s40_tiling.csv"), " and s40_tiling_summary.md")
end

main()
