# Independent sheet-explicit reference for rank_one_sp.jl; all quantities in GeV.
# Standalone: julia --project=checks -e 'include("checks/_rank_one_sp.jl"); r1sp_reference_checks()'
# No Xb2Continuation calls belong in this file.
include(joinpath(@__DIR__, "_rank_one.jl"))

# The root is continued from Im E < 0, including signed-zero limits on the axis.
# The tuple is in threshold order (VV,PV,PP), not printed sheet-label order.
function r1sp_root(E, th, flipped)
    k = sqrt(complex(2th.mu * (E - th.delta)))
    imag(k) > 0 && (k = -k)
    flipped ? k : -k
end

r1sp_label(flips) = "(" * join((flips[a] ? "-" : "+" for a in (3,2,1)), ",") * ")"
r1sp_adjacent(E, ths) = ntuple(a -> ths[a].delta < real(E), 3)
r1sp_loops(E, ths, flips) = [r1_f(r1sp_root(E, ths[a], flips[a]), ths[a].mu) for a in 1:3]

function r1sp_closed_rounding(E, ths, flips)
    [begin
        k = r1sp_root(E, ths[a], flips[a])
        L = log((R1_CUTOFF-k)/(R1_CUTOFF+k))
        128eps() * ths[a].mu / pi^2 * (R1_CUTOFF + abs(k)/2 * (abs(L) + pi))
    end for a in 1:3]
end

function r1sp_probes(ths)
    # Add exact real parts at all thresholds, not only VV already in r1_probes.
    energies = unique([r1_probes(); [complex(th.delta, -0.010) for th in ths]])
    probes = Tuple{ComplexF64,NTuple{3,Bool}}[]
    for E in energies
        flips = r1sp_adjacent(E, ths)
        push!(probes, (E, flips))
        for a in 1:3
            if real(E) == ths[a].delta
                # Both sheets adjacent to the real threshold are meaningful off-axis.
                push!(probes, (E, ntuple(b -> b == a ? !flips[b] : flips[b], 3)))
            end
        end
    end
    for (flips, xs) in (((false,true,true), (1,3,-46,-48)),
                         ((true,true,true), (-1,-3)),
                         ((false,false,true), (-44,-42,-91,-93)))
        for x in xs, y in (10,2)
            push!(probes, (complex(x, -y)/1000, flips))
        end
    end
    unique(probes)
end

function r1sp_reference_checks()
    ref = r1_closed_checks()
    probes = r1sp_probes(ref.ths)
    sheets = [ntuple(a -> !iszero(bits & (1 << (a-1))), 3) for bits in 0:7]
    roots_ok, jump_ok = true, true
    for (E, _) in probes, flips in sheets
        F = r1sp_loops(E, ref.ths, flips)
        for a in 1:3
            th = ref.ths[a]
            k = r1sp_root(E, th, flips[a])
            roots_ok &= abs(k^2 - 2th.mu*(E-th.delta)) <= 16eps()*abs(2th.mu*(E-th.delta))
            roots_ok &= flips[a] ? imag(k) <= 0 : imag(k) >= 0
            changed = ntuple(b -> b == a ? !flips[b] : flips[b], 3)
            other = r1sp_loops(E, ref.ths, changed)
            jump = im * th.mu * k / pi
            # f(k)-f(-k)=i mu k/pi, independently of which sign k has.
            allowance = 256eps() * (abs(F[a]) + abs(other[a]) + abs(jump))
            jump_ok &= abs(F[a]-other[a]-jump) <= allowance
        end
    end
    r1_assert(roots_ok, "sheet-explicit independent roots on all eight sheets", "$(length(probes)) requested probe/sheet pairs")
    r1_assert(jump_ok, "closed-form sheet jumps on all eight sheets")
    r1_assert(all(ref.ths) do th
        E = complex(th.delta-0.001, 0.0)
        kappa = sqrt(2th.mu*0.001)
        abs(r1sp_root(E, th, true) + im*kappa) <= 16eps()*kappa &&
            abs(r1sp_root(E, th, false) - im*kappa) <= 16eps()*kappa
    end, "real-axis closed-channel roots are -i kappa flipped and +i kappa unflipped")
    r1_assert(all(ref.probes) do E
        F = r1sp_loops(E, ref.ths, r1sp_adjacent(E, ref.ths))
        maximum(abs.(F-r1_loops(E, ref.ths))) <= maximum(r1sp_closed_rounding(E, ref.ths, r1sp_adjacent(E, ref.ths)))
    end, "sheet-explicit adjacent reference agrees with Stage 3 closed form")
    for th in ref.ths
        E = complex(th.delta, -0.010)
        r1_assert(count(p -> p[1] == E, probes) == 2,
            "both adjacent sheets probed at Re E=$(1000th.delta) MeV")
    end
    strength = maximum(abs(R1_WEAK_LAMBDA*sum(r1sp_loops(E, ref.ths, flips))) for (E,flips) in probes)
    r1_assert(strength < 1, "weak coupling has no zero on extended SP probe set", "max |lambda sum f|=$strength")
    pole_flips = (false,true,true)
    Fp = r1sp_loops(ref.Ep, ref.ths, pole_flips)
    Dp = 1 + ref.lambda * sum(ref.g2 .* Fp)
    allowance = 64eps() * (1 + abs(ref.lambda)*sum(abs.(ref.g2 .* Fp)))
    r1_assert(abs(Dp) <= allowance && 0 < -2imag(ref.Ep) <= 0.020,
        "sheet-explicit (-,-,+) resonance has width <= 20 MeV", "|D(Ep)|=$(abs(Dp)); width=$(-2000imag(ref.Ep)) MeV")
    println("PASS independent SP reference complete")
    (; ref..., sp_probes=probes)
end
