# Stage 3 rank-one model against the adopted S40 deformed SP rule.
# Run: julia --project=checks checks/rank_one_sp.jl
# Independent reference (including a standalone entry point): _rank_one_sp.jl.
# Units GeV; printed energies are MeV. Never conjugate nodes or weights.
const R1SP_STARTED = time_ns()
include(joinpath(@__DIR__, "_rank_one_sp.jl"))
using Xb2Continuation: Sheet, EnergyRectangle, certify_rectangle, panel_rule,
    onshell_nodes, thresholds_2pp

function r1sp_rectangle(E; rehalf=0.0005, imhalf=0.0005)
    EnergyRectangle((real(E)-rehalf, real(E)+rehalf),
                    (imag(E)-imhalf, imag(E)+imhalf))
end

function r1sp_certificate(E, flips, ths; context="probe", center=E,
                          rehalf=0.0005, imhalf=0.0005)
    result = certify_rectangle(r1sp_rectangle(center; rehalf, imhalf), Sheet(flips), ths;
                               Lambda=R1_CUTOFF)
    if hasproperty(result, :reason)
        @printf("EXCLUDED %s sheet=%s E=%+.8f%+.8fi MeV rectangle_center=%+.8f%+.8fi MeV: %s\n",
            context, r1sp_label(flips), 1000real(E), 1000imag(E),
            1000real(center), 1000imag(center), result.reason)
        return nothing
    end
    result
end

function r1sp_path_loops(certificate, E, flips, ths, np)
    q, w = panel_rule(certificate.path; Lp=0.25, np)
    nodes = onshell_nodes(q, w, E, Sheet(flips), ths, certificate.nodes; Lambda=R1_CUTOFF)
    values, rounding = ComplexF64[], Float64[]
    for a in 1:3
        th = ths[a]
        k2 = 2th.mu * (E-th.delta)
        denominators = q.^2 .- k2
        terms = [w[j]*q[j]^2*(2th.mu/denominators[j])/(2pi^2) for j in eachindex(q)]
        node_index = findfirst(node -> node.channel == a, nodes)
        correction = isnothing(node_index) ? 0.0im : nodes[node_index].weight/(2pi^2)
        push!(values, sum(terms) + correction)
        # gamma_(N+64): summation/arithmetic, including denominator conditioning.
        conditions = [(abs2(q[j])+abs(k2))/abs(denominators[j]) for j in eachindex(q)]
        arithmetic = sum(abs(terms[j])*(1+conditions[j]) for j in eachindex(q))
        if !isnothing(node_index)
            k = nodes[node_index].k
            # Bound the work BEFORE cancellation in W, not just its small result.
            Ibound = (abs(log((R1_CUTOFF-k)/(R1_CUTOFF+k))) + pi)/(2abs(k))
            subtraction = sum(abs(w[j]/denominators[j])*(1+conditions[j]) for j in eachindex(q))
            arithmetic += abs(correction) + th.mu*abs(k2)/pi^2*(Ibound+subtraction)
        end
        m = length(q)+64
        push!(rounding, m*eps()/(1-m*eps()) * arithmetic)
    end
    values, rounding
end

function r1sp_comparison(certificate, E, flips, ths, np=16)
    half, roundhalf = r1sp_path_loops(certificate, E, flips, ths, np÷2)
    fine, roundfine = r1sp_path_loops(certificate, E, flips, ths, np)
    budget = roundhalf + roundfine + r1sp_closed_rounding(E, ths, flips)
    for a in 1:3
        # With Phi=1, q^2/(q^2-k^2)=1+k^2/(q^2-k^2) makes W cancel
        # the pole sum exactly. GL integrates the remaining constant exactly:
        # node-channel error is rounding only, NOT a quadrature allowance.
        a in certificate.nodes || (budget[a] += R1_SAFETY*abs(fine[a]-half[a]))
    end
    (; half, fine, budget, roundhalf, roundfine)
end

function r1sp_tbudget(J, F, budget; lambda=R1_WEAK_LAMBDA, g2=(1.0,1.0,1.0))
    tpath, texact = r1_t(J, lambda, g2), r1_t(F, lambda, g2)
    allowance = abs(tpath*texact)*sum(abs.(g2).*budget) + 32eps()*(abs(tpath)+abs(texact))
    tpath, texact, allowance
end

function r1sp_scan(ref, ths)
    println("Tolerance: non-node |J16-f| <= 4|J16-J8| + gamma_(N+64) arithmetic allowances at both rules + 128eps analytic allowance.")
    println("The safety factor 4 is fixed; node doubling is an estimate, not a rigorous quadrature bound.")
    println("Node channels use rounding ONLY: W cancels the pole sum algebraically for Phi=1, and sum(w)=Lambda.")
    println("T error is propagated by |t_path t_exact| sum(loop budgets), plus reciprocal rounding.")
    println("Path independence: a second 0.5 MeV-half-width rectangle is centred 0.3 MeV to the right, with the same sheet.")
    admitted, excluded, second_admitted, second_excluded = 0, 0, 0, 0
    maxnode, maxother, maxt, maxpath, worstloop, worstt = 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
    finite_weak = true
    counts = Dict{String,Vector{Int}}()
    for (E, flips) in ref.sp_probes
        label = r1sp_label(flips)
        count = get!(counts, label, [0,0,0,0])
        certificate = r1sp_certificate(E, flips, ths)
        if isnothing(certificate)
            excluded += 1
            count[2] += 1
            continue
        end
        admitted += 1
        count[1] += 1
        F = r1sp_loops(E, ref.ths, flips)
        first = r1sp_comparison(certificate, E, flips, ths)
        for (J, budget, nodes) in ((first.fine, first.budget, certificate.nodes),)
            ratios = abs.(J-F)./budget
            for a in 1:3
                if a in nodes
                    maxnode = max(maxnode, ratios[a])
                else
                    maxother = max(maxother, ratios[a])
                end
            end
            tpath, texact, tbudget = r1sp_tbudget(J, F, budget)
            maxt = max(maxt, abs(tpath-texact)/tbudget)
            worstloop = max(worstloop, maximum(abs.(J-F)./abs.(F)))
            worstt = max(worstt, abs(tpath-texact)/abs(texact))
            finite_weak &= isfinite(tpath) && abs(R1_WEAK_LAMBDA*sum(J)) < 1
        end
        # T is evaluated at the coarse rule as well, at every admitted point.
        finite_weak &= isfinite(r1_t(first.half)) && abs(R1_WEAK_LAMBDA*sum(first.half)) < 1
        second_certificate = r1sp_certificate(E, flips, ths; context="second path", center=E+0.0003)
        if isnothing(second_certificate)
            second_excluded += 1
            count[4] += 1
            continue
        end
        second_admitted += 1
        count[3] += 1
        second = r1sp_comparison(second_certificate, E, flips, ths)
        maxpath = max(maxpath, maximum(abs.(first.fine-second.fine)./(first.budget+second.budget)))
        for a in 1:3
            ratio = abs(second.fine[a]-F[a])/second.budget[a]
            if a in second_certificate.nodes
                maxnode = max(maxnode, ratio)
            else
                maxother = max(maxother, ratio)
            end
        end
        tpath, texact, tbudget = r1sp_tbudget(second.fine, F, second.budget)
        maxt = max(maxt, abs(tpath-texact)/tbudget)
        finite_weak &= isfinite(tpath) && isfinite(r1_t(second.half)) &&
            abs(R1_WEAK_LAMBDA*sum(second.fine)) < 1 && abs(R1_WEAK_LAMBDA*sum(second.half)) < 1
    end
    println("sheet       first_admitted first_excluded second_admitted second_excluded")
    for label in sort(collect(keys(counts)))
        @printf("%-10s %14d %14d %15d %15d\n", label, counts[label]...)
    end
    @printf("SCAN %d requested; %d admitted, %d excluded; second paths %d admitted, %d excluded; worst relative loop=%.9e T=%.9e\n",
        length(ref.sp_probes), admitted, excluded, second_admitted, second_excluded, worstloop, worstt)
    r1_assert(admitted > 0 && maxnode <= 1, "SP node-channel loops agree at rounding level", "max residual/budget=$maxnode")
    r1_assert(maxother <= 1, "SP non-node loops agree within node-doubling estimate", "max residual/budget=$maxother")
    r1_assert(finite_weak && maxt <= 1, "weak-coupling T at every admitted point", "max residual/budget=$maxt")
    r1_assert(second_admitted > 0 && maxpath <= 1, "SP path independence on two certified rectangles", "max residual/budget=$maxpath")
end

function r1sp_resonance(ref, ths)
    Ep, flips = ref.Ep, (false,true,true)
    # One fixed rectangle includes Ep and both seeds, with room for the secant.
    halfwidth = 0.001
    certificate = r1sp_certificate(Ep, flips, ths; context="resonance", rehalf=halfwidth, imhalf=halfwidth)
    r1_assert(!isnothing(certificate), "one certified rectangle contains resonance and secant seeds")
    Dprime = ref.lambda * sum(ref.g2[a]*first(r1_derivatives(r1sp_root(Ep, ref.ths[a], flips[a]), ref.ths[a].mu)) for a in 1:3)
    evaluations = Ref(0)
    in_rectangle = Ref(true)
    function D(E, np)
        evaluations[] += 1
        inside = abs(real(E-Ep)) <= halfwidth && abs(imag(E-Ep)) <= halfwidth
        in_rectangle[] &= inside
        r1_assert(inside, "secant evaluation remains inside fixed certified rectangle", "E=$(1000E) MeV")
        # Path and node CHANNELS are fixed; the node momenta and weights move with E.
        J, loop_rounding = r1sp_path_loops(certificate, E, flips, ths, np)
        value = 1 + ref.lambda*sum(ref.g2 .* J)
        rounding = abs(ref.lambda)*sum(ref.g2 .* loop_rounding) +
            32eps()*(1+abs(ref.lambda)*sum(abs.(ref.g2 .* J)))
        @printf("SECANT evaluation=%d np=%d E=%+.12f%+.12fi MeV D=%+.9e%+.9ei\n",
            evaluations[], np, 1000real(E), 1000imag(E), real(value), imag(value))
        value, rounding
    end
    z0, z1 = Ep+(0.5-0.5im)/1000, Ep+(-0.5+0.5im)/1000
    d0, _ = D(z0, 16)
    d1, rounding = D(z1, 16)
    converged = false
    for _ in 1:30
        if abs(d1) <= rounding
            converged = true
            break
        end
        z2 = z1-d1*(z1-z0)/(d1-d0)
        z0, d0 = z1, d1
        z1 = z2
        d1, rounding = D(z1, 16)
    end
    r1_assert(converged && in_rectangle[], "secant converges with fixed SP path and moving on-shell nodes")
    atzero = r1sp_comparison(certificate, z1, flips, ths)
    # Node-channel quadrature error vanishes; retain non-node doubling, all
    # rounding, the independent closed-form allowance, and the final residual.
    determinant_budget = abs(ref.lambda)*sum(ref.g2 .* atzero.budget) +
        32eps()*(1+abs(ref.lambda)*sum(abs.(ref.g2 .* atzero.fine)))
    error_estimate = (determinant_budget+abs(d1))/abs(Dprime)
    r1_assert(abs(z1-Ep) <= error_estimate, "SP pole agrees with independent (-,-,+) closed form",
        @sprintf("|Ezero-Ep|=%.9g MeV <= %.9g MeV = (quadrature+rounding+residual)/|D'|; |D'|=%.9g GeV^-1",
            1000abs(z1-Ep), 1000error_estimate, abs(Dprime)))
    r1_assert(0 < -2imag(z1) <= 0.020, "SP resonance width <= 20 MeV")
    @printf("POLE Ezero=%+.12f%+.12fi MeV; width=%.12f MeV; target=%+.8f%+.8fi MeV; %d evaluations\n",
        1000real(z1), 1000imag(z1), -2000imag(z1), 1000real(Ep), 1000imag(Ep), evaluations[])
end

function r1sp_continuity(ref, ths)
    println("Continuity: adjacent-sheet t(E-i eps) -> physical t(E+i0), eps=(1,.1,.01) MeV.")
    println("First-order remainder estimate: eps^2 max|t''| on 17 vertical samples (safety factor 2), plus quadrature/rounding; derivative sampling is not a certificate.")
    for x in (-67.85, -22.62, 20.0)
        E0 = complex(x/1000, 0.0)
        F0 = r1_loops(E0, ref.ths; physical=true)
        t0 = r1_t(F0)
        S1 = sum(first(r1_derivatives(r1_root(E0, th; physical=true), th.mu)) for th in ref.ths)
        tprime = -t0^2*S1
        differences = Float64[]
        for epsilon in (0.001,0.0001,0.00001)
            E = E0-im*epsilon
            flips = r1sp_adjacent(E, ref.ths)
            certificate = r1sp_certificate(E, flips, ths; context="continuity", imhalf=min(0.0005,epsilon/2))
            r1_assert(!isnothing(certificate), "continuity rectangle exists at Re E=$x, eps=$(1000epsilon) MeV")
            maxsecond = maximum(range(0,epsilon; length=17)) do y
                z = E0-im*y
                F = y == 0 ? F0 : r1sp_loops(z, ref.ths, flips)
                t = r1_t(F)
                derivatives = [r1_derivatives(y == 0 ? r1_root(z,th; physical=true) : r1sp_root(z,th,flips[a]), th.mu)
                    for (a,th) in enumerate(ref.ths)]
                Sp, Spp = sum(first, derivatives), sum(last, derivatives)
                abs(2t^3*Sp^2-t^2*Spp)
            end
            taylor_scale = epsilon^2*maxsecond
            np, tpath, tquad = 16, complex(NaN), Inf
            texact = r1_t(r1sp_loops(E, ref.ths, flips))
            while np <= 4096
                comparison = r1sp_comparison(certificate, E, flips, ths, np)
                tpath, _, tquad = r1sp_tbudget(comparison.fine, r1sp_loops(E, ref.ths, flips), comparison.budget)
                tquad <= taylor_scale && break
                np *= 2
            end
            r1_assert(tquad <= taylor_scale, "continuity quadrature resolves Taylor scale at Re E=$x, eps=$(1000epsilon) MeV",
                "np=$np per panel; estimate=$tquad <= Taylor scale=$taylor_scale")
            r1_assert(abs(tpath-texact) <= tquad, "continuity T agrees with independent closed form at Re E=$x, eps=$(1000epsilon) MeV")
            remainder = taylor_scale+tquad+32eps()*abs(t0)
            difference = abs(tpath-t0)
            push!(differences,difference)
            r1_assert(abs((tpath-t0)+im*epsilon*tprime) <= remainder,
                "first-order real-axis approach at Re E=$x, eps=$(1000epsilon) MeV",
                @sprintf("difference=%.9e, eps|t'|=%.9e, Taylor/quad budget=%.9e", difference, epsilon*abs(tprime), remainder))
        end
        r1_assert(all(diff(differences) .< 0), "continuity difference shrinks at Re E=$x MeV",
            @sprintf("eps=(1,.1,.01) MeV: (%.9e, %.9e, %.9e); decade ratios=(%.6f, %.6f)",
                differences..., differences[1]/differences[2], differences[2]/differences[3]))
    end
end

function r1sp_main()
    ref = r1sp_reference_checks()
    ths = thresholds_2pp()
    r1_assert(all(a.delta == b.delta && a.mu == b.mu for (a,b) in zip(ref.ths,ths)),
        "independent thresholds agree once with thresholds_2pp")
    r1sp_scan(ref, ths)
    r1sp_resonance(ref, ths)
    r1sp_continuity(ref, ths)
    @printf("PASS rank-one SP check complete; runtime %.3f s (including imports/compilation)\n", (time_ns()-R1SP_STARTED)/1e9)
end

if abspath(PROGRAM_FILE) == (@__FILE__)
    try
        r1sp_main()
    catch err
        println(stderr, "FAIL rank-one SP check: ", sprint(showerror,err))
        rethrow()
    end
end
