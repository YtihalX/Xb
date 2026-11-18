# Re-certify the search-domain cells (regions A1, A2) that the tiling excluded before near nodes were made optional
# on 2026-11-15, with the near node switched off, emulated by r_near = 60 MeV: the unflipped pole of the channel just
# below its threshold then stays without a node (its distance from the path is above 60 MeV in every gap cell).
# Evidence for the decision "Near nodes optional" (NOTEBOOK.md, Decisions); plot data for gap_failures.py; not a
# check. Reads gap_failures_tiling_before.csv, a copy of code/Xb2Continuation/scripts/s40_tiling.csv as it was
# before that decision; the current tiling has no exclusions there.
# Run from the repository root:
#   julia --startup-file=no --project=code/Xb2Continuation notes/07-continued-lse/gap_failures_fix.jl
using Xb2Continuation

const LABELS = ("VV", "PV", "PP")
const SOURCE = joinpath(@__DIR__, "gap_failures_tiling_before.csv")
const OUTPUT = joinpath(@__DIR__, "gap_failures_fix.csv")

unquote(s) = strip(s, '"')

function main()
    ths = thresholds_2pp()
    lines = readlines(SOURCE)
    header = unquote.(split(lines[1], ','))
    col = Dict(name => i for (i, name) in enumerate(header))
    open(OUTPUT, "w") do io
        println(io, "region,sheet,re_lo,re_hi,im_lo,im_hi,status_rule,reason_rule,status_fix,reason_fix,nodes_fix,clearance_fix,z_margin_fix")
        for line in lines[2:end]
            f = unquote.(split(line, r",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)"))
            f[col["region"]] in ("A1", "A2") && f[col["status"]] == "excluded" || continue
            b = parse.(Float64, f[[col["re_lo"], col["re_hi"], col["im_lo"], col["im_hi"]]]) ./ 1000
            Q = EnergyRectangle((b[1], b[2]), (b[3], b[4]))
            c = certify_rectangle(Q, Sheet(f[col["sheet"]]), ths; r_near=0.06)
            fixed = c isa RectangleCertificate
            fields = (f[col["region"]], f[col["sheet"]], f[col["re_lo"]], f[col["re_hi"]], f[col["im_lo"]], f[col["im_hi"]],
                      "excluded", f[col["reason"]], fixed ? "certified" : "excluded", fixed ? "" : c.reason,
                      fixed ? join((LABELS[a] for a in c.nodes), "+") : "",
                      fixed ? string(1000c.clearance) : "", fixed ? string(1000c.z_margin) : "")
            println(io, join(("\"" * replace(string(x), "\"" => "\"\"") * "\"" for x in fields), ','))
        end
    end
    println("wrote ", OUTPUT)
end

main()
