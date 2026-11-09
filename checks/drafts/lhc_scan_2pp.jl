# Discontinuity scan of the on-shell projected 2++ OME against the drawn cuts.
# Seam: the left-hand cuts on the 2++ singularity map, drawn from the map code
# (B.on_shell_cuts) in the complex on-shell momentum plane k_t of each distinct
# threshold t = B*Bbar* (channel 1), B Bbar* (channel 5), B Bbar (channel 6).
# Route: evaluate the on-shell projected OME of each transition just above and just
# below scan lines across each k_t plane (offset 1e-9 GeV normal to the line, step
# 0.004 GeV along it), and record where it jumps. The OME is the package's public
# potential (B.ome_potential), which shares no code with the map's cut tracing.
# Transitions: VV->VV (1,1), PV->PV (5,5), PV<->VV (1,5), PP<->VV (1,6); pion and eta
# separately (equal exchange masses isolate one meson). On shell, k_alpha^2 =
# 2 mu_alpha (E - delta_alpha) with E = k_t^2/(2 mu_t) + delta_t; the OME is even in
# each k_alpha for these even-L channels, so the branch of k_alpha does not matter.
# Expected: a jump (above 1e-4 of the local |V|) within one scan step of every point
# where a drawn cut crosses a scan line, and no jump anywhere else.
# Run: julia --project=checks --startup-file=no checks/drafts/lhc_scan_2pp.jl
using HadronDynamics
const B = HadronDynamics.BOchiEFT
const P = B.Parameters()
const STEP, OFFSET, JUMP = 0.004, 1e-9, 1e-4
const PANELS = ((label="B*Bbar*", channel=1, window=1.0), (label="B Bbar*", channel=5, window=1.1),
                (label="B Bbar", channel=6, window=1.2))
const TRANSITIONS = (("VV->VV", 1, 1), ("PV->PV", 5, 5), ("PV<->VV", 1, 5), ("PP<->VV", 1, 6))

failed = false
function report(ok, text)
    global failed |= !ok
    println(ok ? "PASS " : "FAIL ", text)
end

single(mphi) = B.OMEInteraction(B.Parameters(mpi=mphi, meta=mphi); channels=B.channels_2pp())

# --- input: the guarded singularity-map code ---
kinematics = try B.channel_kinematics(single(P.mpi)) catch; nothing end
drawn_cuts(model, out, incoming, meson) = B.on_shell_cuts(model, out, incoming; meson)
# --- end input ---

function energy(panel, k)
    t = kinematics[panel.channel]
    k^2 / (2t.reduced_mass) + t.threshold
end
momentum(alpha, E) = sqrt(2kinematics[alpha].reduced_mass * (E - kinematics[alpha].threshold))

function on_shell(model, out, incoming, panel, k)
    E = energy(panel, k)
    B.ome_potential(model, out, incoming, momentum(out, E), momentum(incoming, E), E)
end

# The two images +-k_t of a cut curve E(t), each continuous along the curve.
function images(panel, curve)
    t = kinematics[panel.channel]
    ks = ComplexF64[]
    for E in curve
        k = sqrt(complex(2t.reduced_mass * (E - t.threshold)))
        !isempty(ks) && abs(k + ks[end]) < abs(k - ks[end]) && (k = -k)
        push!(ks, k)
    end
    (ks, -ks)
end

# Crossings of a polyline with the scan line through `origin` along unit `direction`.
function crossings(polyline, origin, direction, len)
    normal = im * direction
    side(k) = real(conj(normal) * (k - origin))
    along(k) = real(conj(direction) * (k - origin))
    found = Float64[]
    for (a, b) in zip(polyline[1:end-1], polyline[2:end])
        sa, sb = side(a), side(b)
        (sa == 0 || sa * sb < 0) || continue
        u = along(a + (b - a) * sa / (sa - sb))
        0 <= u <= len && push!(found, u)
    end
    found
end

function scan_lines(panel)
    w = panel.window
    lines = Tuple{ComplexF64,ComplexF64,Float64}[]
    for c in (-0.6, -0.27, -0.11, 0.11, 0.27, 0.6) .* w   # horizontal, Im k = c
        push!(lines, (complex(-w, c), 1.0 + 0im, 2w))
    end
    for c in (-0.45, -0.17, 0.17, 0.45) .* w              # vertical, Re k = c
        push!(lines, (complex(c, -w), 0.0 + 1im, 2w))
    end
    lines
end

function scan(model, out, incoming, panel, curves)
    drawn = 0; detected = 0; ok = true; misplaced = Float64[]
    for (origin, direction, len) in scan_lines(panel)
        expected = Float64[]
        for curve in curves, image in images(panel, curve)
            append!(expected, crossings(image, origin, direction, len))
        end
        us = 0:STEP:len
        jumps = Float64[]
        for u in us
            k = origin + direction * u
            plus = on_shell(model, out, incoming, panel, k + im * direction * OFFSET)
            minus = on_shell(model, out, incoming, panel, k - im * direction * OFFSET)
            abs(plus - minus) > JUMP * max(abs(plus), abs(minus), 1e-12) && push!(jumps, u)
        end
        drawn += length(expected); detected += length(jumps)
        for u in expected
            any(abs(u - v) <= STEP for v in jumps) || (ok = false; push!(misplaced, u))
        end
        for v in jumps
            any(abs(u - v) <= STEP for u in expected) || (ok = false; push!(misplaced, v))
        end
    end
    ok, drawn, detected, misplaced
end

if kinematics === nothing
    report(false, "singularity-map code unavailable: B.channel_kinematics")
    exit(1)
end
for panel in PANELS, (name, out, incoming) in TRANSITIONS, (meson, mphi) in ((:pion, P.mpi), (:eta, P.meta))
    model = single(mphi)
    curves = try
        [c.E for c in drawn_cuts(model, out, incoming, meson)]
    catch err
        report(false, "$name $meson: singularity-map code unavailable ($(sprint(showerror, err)))")
        continue
    end
    ok, drawn, detected, misplaced = scan(model, out, incoming, panel, curves)
    report(ok && drawn > 0, "k plane of $(panel.label), $name, $meson: $drawn drawn crossings, " *
        "$detected scan points with a jump" * (isempty(misplaced) ? "" : ", unmatched at $(round.(misplaced, digits=4))"))
end
failed && exit(1)
