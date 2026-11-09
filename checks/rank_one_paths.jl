# S44 rank-one model against S9 path quadrature and S27 sheet geometry.
# Independent reference: checks/_rank_one.jl (no Xb2Continuation calls).
# Run: julia --project=checks checks/rank_one_paths.jl
# Units GeV; printed energies and pole margins are MeV.
const R1_STARTED = time_ns()
include(joinpath(@__DIR__, "_rank_one.jl"))
using Xb2Continuation

function path_loops(path, E, ths, n)
    q, w = path_rule(path, n)
    values = ComplexF64[]
    rounding = Float64[]
    for th in ths
        k2 = 2th.mu * (E - th.delta)
        terms = [w[j] * q[j]^2 * (2th.mu / (q[j]^2 - k2)) / (2pi^2) for j in eachindex(q)]
        push!(values, sum(terms)) # no conjugation of nodes or weights
        # Summation plus arithmetic allowance, gamma_m = m eps/(1-m eps).
        # A near-pole subtraction's condition is included in the term allowance.
        u = eps()
        m = length(q) + 32
        arithmetic = sum(eachindex(q)) do j
            condition = (abs2(q[j]) + abs(k2)) / abs(q[j]^2 - k2)
            abs(terms[j]) * (1 + condition)
        end
        push!(rounding, m*u / (1-m*u) * arithmetic)
    end
    values, rounding
end

function closed_rounding(E, ths)
    [begin
        k = r1_root(E, th)
        L = log((R1_CUTOFF-k)/(R1_CUTOFF+k))
        128eps() * th.mu / pi^2 * (R1_CUTOFF + abs(k)/2 * (abs(L) + pi))
    end for th in ths]
end

function loop_comparison(path, E, ths, n=64)
    Jhalf, rhalf = path_loops(path, E, ths, n÷2)
    Jfine, rfine = path_loops(path, E, ths, n)
    budget = R1_SAFETY .* abs.(Jfine-Jhalf) + rhalf + rfine + closed_rounding(E, ths)
    Jhalf, Jfine, budget
end

function geometry_metrics(path, E, ths, margin)
    v = path.vertices
    geometry = v[1] == 0 && v[end] == R1_CUTOFF &&
        all(real(v[i+1]) > real(v[i]) && imag(v[i]) <= 0 &&
            abs(imag(v[i+1]-v[i])) <= real(v[i+1]-v[i]) + 16eps() for i in 1:length(v)-1)
    clearance = Inf
    for th in ths
        k = r1_root(E, th)
        flip = th.delta < real(E)
        # In the reference ordering an unflipped root is in quadrant II;
        # its negative is the quadrant-IV pole which must stay outside.
        pole = flip ? k : -k
        geometry &= r1_inside(v, pole) == flip
        clearance = min(clearance, r1_distance(v, k), r1_distance(v, -k))
    end
    geometry &= clearance >= margin - 128eps() * R1_CUTOFF
    geometry &= r1_vertical_clear(v, E, ths)
    geometry, clearance
end

function scan_paths(ref)
    ths, probes = ref.ths, ref.probes
    package_ths = thresholds_2pp()
    r1_assert(all(a.delta == b.delta && a.mu == b.mu for (a,b) in zip(ths, package_ths)),
        "independent thresholds agree once with thresholds_2pp")
    r1_assert(all(abs(r1_root(E, ths[a]) - sheet_momentum(E, package_ths[a])) <=
        16eps() * max(1, abs(r1_root(E, ths[a]))) for E in probes for a in 1:3),
        "independent roots agree once with sheet_momentum on probe set")
    println("Tolerance: |J64-f| <= 4 |J64-J32| + gamma_(N+32) sum |terms|(1+subtraction condition) at both rules + 128eps analytic-operation allowance.")
    println("The safety factor 4 is fixed before the scan; node doubling supplies an a posteriori estimate, not a rigorous quadrature bound.")
    println("T tolerance is propagated exactly: |t_path-t_exact| <= |t_path t_exact| sum loop_error_budget, plus reciprocal rounding.")
    println("Accuracy table: worst relative loop error over all admitted probes and three channels")
    println("margin_MeV  admitted excluded    n16             n32             n64             worst64/budget   worst_rel_T64")
    excluded = Tuple{Float64,ComplexF64,String}[]
    for margin in (0.005, 0.010, 0.020, 0.040)
        worst = zeros(3)
        max_loop_ratio, max_t_ratio, worst_t = 0.0, 0.0, 0.0
        admitted, geometry_ok, clearance = 0, true, Inf
        for E in probes
            path = graph_path(E, package_ths; Lambda=R1_CUTOFF, margin)
            if path isa PathExclusion
                push!(excluded, (margin, E, path.reason))
                continue
            end
            admitted += 1
            ok, distance = geometry_metrics(path, E, ths, margin)
            geometry_ok &= ok
            clearance = min(clearance, distance)
            F = r1_loops(E, ths)
            J16, _ = path_loops(path, E, ths, 16)
            J32, J64, budget = loop_comparison(path, E, ths)
            for (i,J) in enumerate((J16, J32, J64))
                worst[i] = max(worst[i], maximum(abs.(J-F) ./ abs.(F)))
                # T is evaluated at every admitted point for every rule, not just loops.
                t = r1_t(J)
                isfinite(t) || error("nonfinite weak-coupling T at $E, n=$((16,32,64)[i])")
            end
            max_loop_ratio = max(max_loop_ratio, maximum(abs.(J64-F) ./ budget))
            tpath, texact = r1_t(J64), r1_t(F)
            terror = abs(tpath-texact)
            tbudget = abs(tpath*texact) * sum(budget) + 32eps()*(abs(tpath)+abs(texact))
            max_t_ratio = max(max_t_ratio, terror/tbudget)
            worst_t = max(worst_t, terror/abs(texact))
        end
        @printf("%10.1f %9d %8d  %.8e  %.8e  %.8e  %.8e     %.8e\n",
            1000margin, admitted, length(probes)-admitted, worst..., max_loop_ratio, worst_t)
        r1_assert(admitted > 0 && geometry_ok, "independent geometry and vertical (P), margin=$(1000margin) MeV",
            "all $admitted paths; min pole clearance=$(1000clearance) MeV")
        r1_assert(max_loop_ratio <= 1, "64-node loops within convergence estimate, margin=$(1000margin) MeV", "max residual/budget=$max_loop_ratio")
        r1_assert(max_t_ratio <= 1, "weak T at every admitted point within propagated estimate, margin=$(1000margin) MeV", "max residual/budget=$max_t_ratio")
    end
    println("Excluded probe energies (each exclusion applies to n=16,32,64):")
    for (margin,E,reason) in excluded
        @printf("EXCLUDED margin=%g MeV E=%+.5f%+.5fi MeV: %s\n", 1000margin, 1000real(E), 1000imag(E), reason)
    end
    isempty(excluded) && println("none")
    # The grid includes E=0-10i; also test exact exclusion at the other thresholds.
    r1_assert(all(graph_path(complex(th.delta,-0.010), package_ths; margin=0.020) isa PathExclusion for th in ths),
        "exact real threshold energies excluded for all three thresholds")
end

function resonance_path(ref)
    ths, Ep, g2, lambda = ref.ths, ref.Ep, ref.g2, ref.lambda
    margin = 0.020
    path = graph_path(Ep, thresholds_2pp(); margin)
    r1_assert(path isa GraphPath, "resonance reference path exists with 20 MeV pole margin")
    ok, _ = geometry_metrics(path, Ep, ths, margin)
    r1_assert(ok, "resonance path has independent sheet placement and vertical (P)")
    Dprime = lambda * sum(g2[a] * first(r1_derivatives(r1_root(Ep, ths[a]), ths[a].mu)) for a in 1:3)
    minclearance = Ref(Inf)
    iterates = ComplexF64[]
    function D(E, n)
        push!(iterates, E)
        clearance = minimum(r1_distance(path.vertices, sign*r1_root(E,th)) for th in ths for sign in (-1,1))
        minclearance[] = min(minclearance[], clearance)
        r1_assert(clearance >= margin/2, "secant fixed-path pole clearance at E=$(1000E) MeV", "$(1000clearance) MeV >= 10 MeV")
        J, loop_rounding = path_loops(path, E, ths, n)
        value = 1 + lambda * sum(g2 .* J)
        roundbound = abs(lambda) * sum(g2 .* loop_rounding) + 32eps()*(1 + abs(lambda)*sum(abs.(g2 .* J)))
        @printf("SECANT evaluation=%d n=%d E=%+.12f%+.12fi MeV D=%+.9e%+.9ei clearance=%.9f MeV\n",
            length(iterates), n, 1000real(E), 1000imag(E), real(value), imag(value), 1000clearance)
        value, roundbound
    end
    # The original (2-2i) MeV seed leaves only 7.18 MeV clearance on the
    # prescribed 20 MeV S40 path. The user-approved closer seeds retain it.
    z0, z1 = Ep + (0.5-0.5im)/1000, Ep + (-0.5+0.5im)/1000
    @printf("SECANT seeds=%+.9f%+.9fi and %+.9f%+.9fi MeV; fixed reference margin=20 MeV\n",
        1000real(z0), 1000imag(z0), 1000real(z1), 1000imag(z1))
    d0, _ = D(z0, 64)
    d1, rounding = D(z1, 64)
    converged = false
    for _ in 1:30
        if abs(d1) <= rounding
            converged = true
            break
        end
        z2 = z1 - d1*(z1-z0)/(d1-d0)
        z0, d0 = z1, d1
        z1 = z2
        d1, rounding = D(z1, 64)
    end
    r1_assert(converged, "secant converges using only fixed-path D64")
    d32, round32 = D(z1, 32)
    quadrature_error = R1_SAFETY * abs(d1-d32) + rounding + round32
    # Local root error = determinant error / |D'|; the residual of the
    # terminated secant and its rounding are retained, not hidden in a floor.
    error_estimate = (quadrature_error + abs(d1)) / abs(Dprime)
    r1_assert(abs(z1-Ep) <= error_estimate, "path zero matches independently prescribed pole",
        @sprintf("|Ezero-Ep|=%.9g MeV <= %.9g MeV = (4|D64-D32|+rounding+|D64|)/|D'|; |D'|=%.9g GeV^-1", 1000abs(z1-Ep), 1000error_estimate, abs(Dprime)))
    r1_assert(all(real(z) > ths[2].delta && real(z) < 0 && imag(z) < 0 for z in iterates),
        "all secant evaluations remain on (-,-,+)")
    @printf("POLE Ezero=%+.12f%+.12fi MeV; width=%.12f MeV; target=%+.8f%+.8fi MeV; %d evaluations; minimum clearance=%.8f MeV\n",
        1000real(z1), 1000imag(z1), -2000imag(z1), 1000real(Ep), 1000imag(Ep), length(iterates), 1000minclearance[])
end

function real_axis_continuity(ref)
    println("Continuity: adjacent-sheet t(E-i eps) -> physical t(E+i0); weak g=(1,1,1).")
    println("Expected leading difference eps |t'(E+i0)|. Taylor remainder estimate = eps^2 max|t''| on 17 vertical samples (safety factor 2) / 2, plus quadrature/rounding; derivative sampling is an estimate, not a certificate.")
    println("Continuity-only node doubling starts at 64 and resolves the O(eps^2) Taylor scale: propagated quadrature estimate <= eps^2 max|t''|; no fixed absolute tolerance.")
    for x in (-67.85, -22.62, 20.0)
        E0 = complex(x/1000, 0.0)
        F0 = r1_loops(E0, ref.ths; physical=true)
        t0 = r1_t(F0)
        S1 = sum(first(r1_derivatives(r1_root(E0, th; physical=true), th.mu)) for th in ref.ths)
        tprime = -t0^2 * S1
        differences = Float64[]
        for epsilon in (0.001, 0.0001, 0.00001)
            E = E0-im*epsilon
            path = graph_path(E, thresholds_2pp(); margin=0.020)
            r1_assert(path isa GraphPath, "continuity path exists at Re E=$x, eps=$(1000epsilon) MeV")
            ok, _ = geometry_metrics(path, E, ref.ths, 0.020)
            r1_assert(ok, "independent continuity path geometry at Re E=$x, eps=$(1000epsilon) MeV")
            maxsecond = maximum(range(0, epsilon; length=17)) do y
                z = E0-im*y
                F = r1_loops(z, ref.ths; physical=y==0)
                t = r1_t(F)
                derivatives = [r1_derivatives(r1_root(z,th; physical=y==0), th.mu) for th in ref.ths]
                Sp = sum(first, derivatives)
                Spp = sum(last, derivatives)
                abs(2t^3 * Sp^2 - t^2 * Spp)
            end
            n, tpath, tquad = 64, complex(NaN), Inf
            texact = r1_t(r1_loops(E, ref.ths))
            taylor_scale = epsilon^2 * maxsecond
            while n <= 4096
                _, Jfine, budget = loop_comparison(path, E, ref.ths, n)
                tpath = r1_t(Jfine)
                tquad = abs(tpath*texact)*sum(budget) + 32eps()*(abs(tpath)+abs(texact))
                tquad <= taylor_scale && break
                n *= 2
            end
            r1_assert(tquad <= taylor_scale, "continuity quadrature resolves Taylor scale at Re E=$x, eps=$(1000epsilon) MeV",
                "n=$n per segment; quadrature estimate=$tquad <= Taylor scale=$taylor_scale")
            r1_assert(abs(tpath-texact) <= tquad, "continuity T agrees with closed form at Re E=$x, eps=$(1000epsilon) MeV")
            remainder = epsilon^2 * maxsecond + tquad + 32eps()*abs(t0)
            difference = abs(tpath-t0)
            push!(differences, difference)
            r1_assert(abs((tpath-t0) + im*epsilon*tprime) <= remainder,
                "first-order real-axis approach at Re E=$x, eps=$(1000epsilon) MeV",
                @sprintf("difference=%.9e, eps|t'|=%.9e, Taylor/quad budget=%.9e", difference, epsilon*abs(tprime), remainder))
        end
        r1_assert(all(diff(differences) .< 0), "continuity difference shrinks at Re E=$x MeV",
            @sprintf("eps=(1,.1,.01) MeV: (%.9e, %.9e, %.9e); decade ratios=(%.6f, %.6f)", differences..., differences[1]/differences[2], differences[2]/differences[3]))
    end
end

function main()
    ref = r1_closed_checks()
    scan_paths(ref)
    resonance_path(ref)
    real_axis_continuity(ref)
    @printf("PASS rank-one path check complete; runtime %.3f s (including imports/compilation)\n", (time_ns()-R1_STARTED)/1e9)
end
abspath(PROGRAM_FILE) == (@__FILE__) && main()
