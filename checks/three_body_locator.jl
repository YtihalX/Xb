# The three-body singularity locator of the continued OME kernel.
# Seam: the zeros in the incoming momentum q of s_sigma + nu_beta, with
# s_sigma = sqrt(m_phi^2 + (p' + sigma q)^2) principal and nu_beta the TOPT offset of
# time ordering beta (CONVENTIONS.md "Continued angular moments", "Reduced masses and
# TOPT energy offsets"), for fixed outgoing momentum p' and energy E.
# Routes:
#  - brute force: |s_sigma + nu_beta| on a fine grid of complex q (spacing 0.0125 GeV in
#    the box |Re q| <= 4.2, |Im q| <= 1.5 GeV), local minima refined by successive grid
#    zooms and unsquared Newton steps from adjacent grid seeds, kept if the refined
#    |s_sigma + nu_beta| < 1e-10 GeV. B.tc_alphas is evaluated pointwise; no polynomial is formed.
#    The meson mass is the model's (B.Parameters()), the locator's own input, so the two
#    routes solve the same equation; with the rounded GLOSSARY pion mass (0.4 keV lower) the
#    pion roots moved by up to 9.3e-7 GeV, eta roots (same mass in both) by 5e-15 GeV.
#  - real-axis limit: the lowest real E at which a located zero reaches real momenta
#    0 <= p', q <= Lambda, found by bisection on E with the locator alone. It must equal
#    the three-body threshold of that ordering's intermediate state, m_a + m_b + m_phi - M_th,
#    with the masses of GLOSSARY.md "Isospin limit" written below, not read from the package.
# Expected: every located principal zero inside the box has a brute-force zero within
# 1e-6 GeV and vice versa; real-axis limits within 1e-6 GeV of the thresholds; the lowest
# is B Bbar pi, +92.8 MeV above m_B + m_B* in 1++ and +47.6 MeV above 2 m_B* in 2++.
# Tests note 07 st:quartic (unsquared grid residual) and st:pzero (threshold onset).
# Tolerances remain provisional: 60 grid halvings give STEP/2^60 truncation,
# with a 1e-10 GeV residual gate; 45 bisections give < 1e-14 GeV energy resolution.
# The conservative 1e-6 GeV comparisons allow floating-point root/refinement error.
# Run: julia --project=checks --startup-file=no checks/three_body_locator.jl
using HadronDynamics
import Xb2Continuation as X
const B = HadronDynamics.BOchiEFT
const mB, mBs, mpi, meta = 5.27952, 5.32475, 0.138039, 0.548  # GLOSSARY.md "Isospin limit"
const LAMBDA = 4.0
const REQ, IMQ, STEP = 4.2, 1.5, 0.0125

failed = false
function report(ok, text)
    global failed |= !ok
    println(ok ? "PASS " : "FAIL ", text)
end

# --- input: the guarded package locator ---
locate(model, out, incoming, pout, E, meson) = X.three_body_points(model, out, incoming, pout, E; meson)
# --- end input ---

const SECTORS = (
    (name="1++", channels=B.channels_1pp(), threshold=mB + mBs,
     entries=((1, 1), (1, 3), (3, 1), (3, 3))),
    (name="2++", channels=B.channels_2pp(), threshold=2mBs,
     entries=((1, 1), (1, 5), (5, 1), (5, 5), (1, 6), (6, 1))),
)
const MASSES = Dict(:P => mB, :V => mBs)
const MESONS = ((:pion, mpi), (:eta, meta))

function residual(model, out, incoming, pout, q, E, mphi, ordering, sign)
    nu = B.tc_alphas(model, out, incoming, pout, q, E)[ordering]
    sqrt(mphi^2 + (pout + sign * q)^2) + nu
end

function brute_force_zeros(model, out, incoming, pout, E, mphi, ordering, sign)
    xs = -REQ:STEP:REQ; ys = -IMQ:STEP:IMQ
    F = [abs(residual(model, out, incoming, pout, complex(x, y), E, mphi, ordering, sign)) for x in xs, y in ys]
    zeros_found = ComplexF64[]
    for i in 2:length(xs)-1, j in 2:length(ys)-1
        v = F[i, j]
        all(v <= F[i+di, j+dj] for di in -1:1, dj in -1:1) || continue
        centre = complex(xs[i], ys[j]); width = STEP
        for _ in 1:60  # zoom: 5 x 5 grid, halve the width around the best point
            best = centre; bestv = Inf
            for a in -2:2, b in -2:2
                q = centre + complex(a, b) * width / 2
                r = abs(residual(model, out, incoming, pout, q, E, mphi, ordering, sign))
                r < bestv && (best = q; bestv = r)
            end
            centre = best; width /= 2
        end
        # The square-root cut can trap a grid zoom before its nearby zero.
        # Refine independent unsquared residuals from both sides of the coarse
        # minimum; never seed from the polynomial locator being tested.
        for seed in (centre, (complex(xs[i],ys[j])+complex(a,b)*STEP/2
                              for a in -1:1 for b in -1:1)...)
            q = seed
            for _ in 1:40
                f = residual(model,out,incoming,pout,q,E,mphi,ordering,sign)
                abs(f) < 1e-12 && break
                s = sqrt(complex(mphi^2+(pout+sign*q)^2))
                iszero(s) && break
                h = 1e-5
                dv = (B.tc_alphas(model,out,incoming,pout,q+h,E)[ordering] -
                      B.tc_alphas(model,out,incoming,pout,q-h,E)[ordering])/(2h)
                derivative = sign*(pout+sign*q)/s+dv
                iszero(derivative) && break
                q -= f/derivative
                isfinite(q) && abs(real(q)) <= REQ && abs(imag(q)) <= IMQ || break
            end
            abs(real(q)) <= REQ && abs(imag(q)) <= IMQ || continue
            abs(residual(model,out,incoming,pout,q,E,mphi,ordering,sign)) < 1e-10 || continue
            any(abs(q-z) < 1e-8 for z in zeros_found) || push!(zeros_found,q)
        end
    end
    zeros_found
end

inside(q) = abs(real(q)) <= REQ - 0.05 && abs(imag(q)) <= IMQ - 0.05

function probe_pairs(sector)
    probes = [(pout, E) for pout in
        (0.12 + 0im, 0.45 + 0im, 0.30 - 0.20im, 0.37 - 0.14im),
        E in (-0.03 + 0im, -0.0226 - 0.02im, 0.06 - 0.01im, 0.11 - 0.005im, 0.62 - 0.02im)] |> vec
    if sector.name == "2++"
        ths = X.thresholds_2pp()
        for (E, label) in ((-0.06785 - 0.005im, "(-,+,+)"),
                           (-0.04660 - 0.00035im, "(-,+,+)"),
                           (-0.02262 - 0.005im, "(-,-,+)"),
                           (-0.00140 - 0.00004im, "(-,-,+)"))
            # A 1 x 1 MeV cell containing E, clipped by translation at Im E=0.
            im_hi = min(0.0, imag(E) + 0.0005)
            Q = X.EnergyRectangle((real(E)-0.0005, real(E)+0.0005),
                                  (im_hi-0.001, im_hi))
            path = X.sp_path(X.center(Q), X.vertex_channels(Q, X.Sheet(label), ths), ths)
            path isa X.GraphPath || error("S40 path excluded at E=$E: $path")
            append!(probes, [(pout, E) for pout in path.vertices])
        end
    end
    probes
end

function compare_with_brute_force()
    for sector in SECTORS, (meson, _) in MESONS, (out, incoming) in sector.entries
        model = B.OMEInteraction(B.Parameters(); channels=sector.channels)
        mphi = meson === :pion ? B.Parameters().mpi : B.Parameters().meta  # the locator's input mass
        worst = 0.0; nzeros = 0; ok = true
        for (pout, E) in probe_pairs(sector)
            located = [z for z in locate(model, out, incoming, pout, E, meson) if z.principal]
            for ordering in 1:2, sign in (1, -1)
                brute = brute_force_zeros(model, out, incoming, pout, E, mphi, ordering, sign)
                mine = [z.pin for z in located if z.ordering == ordering && z.sign == sign && inside(z.pin)]
                brute = filter(inside, brute)
                for z in mine
                    d = minimum(abs(z - b) for b in brute; init=Inf)
                    worst = max(worst, d); ok &= d <= 1e-6
                    d <= 1e-6 || println("MISMATCH E=$E pout=$pout ordering=$ordering sign=$sign " *
                        "obtained locator root=$z expected grid roots=$brute " *
                        "locator residual=$(abs(residual(model,out,incoming,pout,z,E,mphi,ordering,sign)))")
                end
                for b in brute
                    d = minimum(abs(z - b) for z in mine; init=Inf)
                    worst = max(worst, d); ok &= d <= 1e-6
                    d <= 1e-6 || println("MISMATCH E=$E pout=$pout ordering=$ordering sign=$sign " *
                        "expected grid root=$b obtained locator roots=$mine")
                end
                nzeros += length(brute)
            end
        end
        report(ok && nzeros > 0, "$(sector.name) entry $((out, incoming)) $(meson): $nzeros brute-force zeros in the box, " *
            "largest locator distance $(round(worst, sigdigits=3)) GeV (tolerance 1e-6)")
    end
end

function intermediate_thresholds(sector, out, incoming, mphi)
    species = (sector.channels[out].species, sector.channels[incoming].species)
    states = species == (:PV, :PV) ? ((:P, :P), (:V, :V)) :
             species == (:VV, :VV) ? ((:V, :V), (:V, :V)) :
             species in ((:VV, :PV), (:PV, :VV)) ? ((:V, :V), (:P, :V)) :
             ((:P, :V), (:P, :V))  # PP <-> VV: both orderings pass through B Bbar* phi
    sort([MASSES[a] + MASSES[b] + mphi - sector.threshold for (a, b) in states])
end

function reaches_real_momenta(model, out, incoming, E, meson, ordering)
    for pout in 0.0:0.05:LAMBDA
        for z in locate(model, out, incoming, complex(pout), complex(E), meson)
            z.principal && z.ordering == ordering || continue
            abs(imag(z.pin)) <= 1e-9 * max(1, abs(z.pin)) && 0 <= real(z.pin) <= LAMBDA && return true
        end
    end
    false
end

function real_axis_limits()
    lowest = Dict{String,Float64}()
    for sector in SECTORS, (meson, mphi) in MESONS, (out, incoming) in sector.entries
        model = B.OMEInteraction(B.Parameters(); channels=sector.channels)
        expected = intermediate_thresholds(sector, out, incoming, mphi)
        limits = Float64[]
        for ordering in 1:2
            lo, hi = expected[1] - 0.06, expected[end] + 0.06
            reaches_real_momenta(model, out, incoming, lo, meson, ordering) && (push!(limits, NaN); continue)
            reaches_real_momenta(model, out, incoming, hi, meson, ordering) || (push!(limits, NaN); continue)
            for _ in 1:45
                mid = (lo + hi) / 2
                reaches_real_momenta(model, out, incoming, mid, meson, ordering) ? (hi = mid) : (lo = mid)
            end
            push!(limits, hi)
        end
        sort!(limits)
        deviation = maximum(abs.(limits .- expected))
        report(deviation <= 1e-6, "$(sector.name) entry $((out, incoming)) $(meson): real-axis limits " *
            "$(round.(1e3 .* limits, digits=4)) MeV, three-body thresholds $(round.(1e3 .* expected, digits=4)) MeV")
        meson == :pion && (lowest[sector.name] = min(get(lowest, sector.name, Inf), minimum(limits)))
    end
    for (name, value) in (("1++", 0.0928), ("2++", 0.0476))
        report(round(1e3 * lowest[name], digits=1) == 1e3 * value,
            "$name lowest real-axis limit $(round(1e3 * lowest[name], digits=3)) MeV (B Bbar pi, printed $(1e3 * value) MeV)")
    end
end

try
    locate(B.OMEInteraction(), 1, 1, 0.1 + 0im, -0.01 + 0im, :pion)
catch err
    report(false, "three-body locator unavailable: $(sprint(showerror, err))")
    exit(1)
end
compare_with_brute_force()
real_axis_limits()
failed && exit(1)
