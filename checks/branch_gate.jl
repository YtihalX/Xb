# Stage-2 gate, note 07 S45: witness zero, or independently confirm a seam.
# Run: julia --project=checks checks/branch_gate.jl [--standalone]
include(joinpath(@__DIR__, "moments_winding.jl"))

function path_tangent(vertices, u)
    k = clamp(floor(Int, u), 0, length(vertices)-2)
    vertices[k+2]-vertices[k+1]
end

# Family Q -> P is straight in the polygon's pair parameters, not in momentum.
# Return Z and its two analytic derivatives (sigma, homotopy parameter v).
function family_data(o, m, vertices, UQ, UP, E1, sign, stage, sigma, v)
    u = UQ[1]+sigma*(UP[1]-UQ[1])
    t = UQ[2]+sigma*(UP[2]-UQ[2])
    p, q = path_point(vertices, u), path_point(vertices, t)
    dp = path_tangent(vertices, u)*(UP[1]-UQ[1])
    dq = path_tangent(vertices, t)*(UP[2]-UQ[2])
    if stage == 1
        p, q = real(p)+im*v*imag(p), real(q)+im*v*imag(q)
        dp, dq = real(dp)+im*v*imag(dp), real(dq)+im*v*imag(dq)
        pv = im*imag(path_point(vertices, u))
        qv = im*imag(path_point(vertices, t))
        E, Ev = conj(E1), 0.0im
    else
        pv, qv = 0.0im, 0.0im
        Ev = E1-conj(E1)
        E = conj(E1)+v*Ev
    end
    s = sqrt(complex(m^2+(p+sign*q)^2))
    z = s+o.t+o.h*p^2+o.a*q^2-E
    dsigma = (p+sign*q)*(dp+sign*dq)/s+2o.h*p*dp+2o.a*q*dq
    dv = (p+sign*q)*(pv+sign*qv)/s+2o.h*p*pv+2o.a*q*qv-Ev
    scale = abs(s)+abs(o.t)+abs(o.h*p^2)+abs(o.a*q^2)+abs(E)
    # 256 ulps is an operation-count forward bound for the complex expression,
    # including root and reconstructed pair/energy parameters. Not a physics margin.
    tolerance = 256eps(Float64)*max(scale, m)
    (; z, dsigma, dv, tolerance, p, q, E, u, t)
end

function verify_witness(o, m, vertices, UQ, UP, E, sign, stage, sigma, v)
    (0 <= sigma <= 1 && 0 <= v <= 1) || return nothing
    r = family_data(o, m, vertices, UQ, UP, E, sign, stage, sigma, v)
    abs(r.z) <= r.tolerance || return nothing
    # Verify the defining unsquared Z, not a root of a squared polynomial.
    (; stage, sigma, v, sign, residual=abs(r.z), tolerance=r.tolerance,
       p=r.p, q=r.q, E=r.E, u=r.u, t=r.t)
end

function newton_witness(o, m, vertices, UQ, UP, E, sign, stage, sigma, v)
    for _ in 1:60
        r = family_data(o, m, vertices, UQ, UP, E, sign, stage, sigma, v)
        if abs(r.z) <= r.tolerance
            return verify_witness(o, m, vertices, UQ, UP, E, sign, stage, sigma, v)
        end
        a, b, c, d = real(r.dsigma), real(r.dv), imag(r.dsigma), imag(r.dv)
        det = a*d-b*c
        isfinite(det) && abs(det) > eps(Float64)*(abs(a*d)+abs(b*c)) || return nothing
        ds = (d*real(r.z)-b*imag(r.z))/det
        dv = (-c*real(r.z)+a*imag(r.z))/det
        accepted = false
        alpha = 1.0
        for _ in 1:32
            sn, vn = sigma-alpha*ds, v-alpha*dv
            if 0 <= sn <= 1 && 0 <= vn <= 1
                rn = family_data(o, m, vertices, UQ, UP, E, sign, stage, sn, vn)
                if abs(rn.z) < abs(r.z)
                    sigma, v = sn, vn
                    accepted = true
                    break
                end
            end
            alpha /= 2
        end
        accepted || return nothing
    end
    nothing
end

function family_breaks(vertices, UQ, UP)
    cuts = collect(range(0.0, 1.0; length=33))
    for k in 1:2
        delta = UP[k]-UQ[k]
        iszero(delta) && continue
        for boundary in 1:length(vertices)-2
            sigma = (boundary-UQ[k])/delta
            0 < sigma < 1 && push!(cuts, sigma)
        end
    end
    sort!(unique!(cuts))
end

function find_witness(o, m, vertices, UQ, UP, E, signs)
    cuts = family_breaks(vertices, UQ, UP)
    # Stage b is triangular in the two real unknowns: Re Z fixes sigma,
    # then Im Z fixes v exactly. Bisection is robust at polygon breakpoints.
    for sign in signs
        for k in 1:length(cuts)-1
            left, right = cuts[k], cuts[k+1]
            fl = real(family_data(o, m, vertices, UQ, UP, E, sign, 2, left, 0.0).z)
            fr = real(family_data(o, m, vertices, UQ, UP, E, sign, 2, right, 0.0).z)
            fl*fr > 0 && continue
            for _ in 1:60
                mid = (left+right)/2
                fm = real(family_data(o, m, vertices, UQ, UP, E, sign, 2, mid, 0.0).z)
                if signbit(fm) == signbit(fl)
                    left, fl = mid, fm
                else
                    right = mid
                end
            end
            sigma = (left+right)/2
            r = family_data(o, m, vertices, UQ, UP, E, sign, 2, sigma, 0.0)
            v = imag(r.z)/imag(E-conj(E))
            witness = verify_witness(o, m, vertices, UQ, UP, E, sign, 2, sigma, v)
            isnothing(witness) || return witness
        end
    end
    # Newton multistart also searches stage a, and stage b tangencies which
    # have no sign-changing bracket. Failure is not evidence of admissibility.
    for stage in (1, 2), sign in signs, sigma in (0.125, 0.375, 0.625, 0.875), v in (0.125, 0.375, 0.625, 0.875)
        witness = newton_witness(o, m, vertices, UQ, UP, E, sign, stage, sigma, v)
        isnothing(witness) || return witness
    end
    nothing
end

function gate_selfcheck()
    # Construct an exact stage-b zero at the midpoint of a graph-path family.
    vertices = ComplexF64[0, 0.01-0.2im, 1.5-0.2im, 4]
    o = (t=-0.09, h=0.095, a=0.095)
    m, UQ, UP = 0.138, (0.04, 0.45), (0.10, 0.65)
    sigma = 0.5
    p = path_point(vertices, (UQ[1]+UP[1])/2)
    q = path_point(vertices, (UQ[2]+UP[2])/2)
    estar = winding_z(o, m, p, q, 0.0im, 1)
    E = real(estar)-im*(abs(imag(estar))+0.05)
    w = find_witness(o, m, vertices, UQ, UP, E, (1,))
    ok = !isnothing(w)
    @printf("%s manufactured witness recovery", ok ? "PASS" : "FAIL")
    if ok
        @printf(" sigma=%.12g stage=%d v=%.12g residual=%.3e tolerance=%.3e\n", w.sigma, w.stage, w.v, w.residual, w.tolerance)
    else
        println()
    end
    ok
end

function nearest_zero(ns, i, j)
    best, distance = nothing, typemax(Int)
    # Euclidean node-index distance; iteration order resolves ties reproducibly.
    for a in axes(ns, 1), b in axes(ns, 2)
        ns[a,b] == (0,0) || continue
        d = (i-a)^2+(j-b)^2
        if d < distance
            best, distance = (a,b), d
        end
    end
    best
end

function gate_main()
    started = time()
    ok = gate_selfcheck()
    println("Gate counts are per 2304-pair configuration; n!=0 means either endpoint; moment means n_plus!=n_minus.")
    println("Ratio count uses the integer 2pi*i discrepancy; arithmetic residual tolerance = 64eps*(1+|ratio log|+|L_plus|+|L_minus|).")
    println("Witness root residual tolerance = 256eps times the sum of magnitudes in unsquared Z (forward-roundoff estimate); numerical witness, not a global admissibility certificate.")
    println("A root anywhere in a Q-to-P family proves that family inadmissible. A failed root search proves nothing; a seam then requires independent dZ/Z confirmation.")
    println("path E meson beta nonzero moment ratio witnesses seams unexplained")
    totalw, totals, totalu = 0, 0, 0
    maxres, maxtol = 0.0, 0.0
    for (path, vertices) in pairs(PROBE_PATHS), E in PROBE_ENERGIES,
            (meson, m) in pairs(PROBE_MESONS), beta in 1:4
        o = winding_ordering(beta)
        production_ordering = Xb2Continuation.ordering(beta)
        nodes, params = probe_nodes(vertices), probe_parameters(vertices)
        nnode = length(nodes)
        lifts = [Xb2Continuation.lift_default(production_ordering, m, p, q, E) for p in nodes, q in nodes]
        ns = [lp.n for lp in lifts]
        nonzero = count(n -> n != (0,0), ns)
        moment = count(n -> n[1] != n[2], ns)
        ratio, witnesses, seams, unexplained = 0, 0, 0, 0
        arithmetic_ok = true
        for lp in lifts
            rlog = log(lp.Z[1]/lp.Z[2])
            delta = rlog-(lp.L[1]-lp.L[2])
            nratio = round(Int, imag(delta)/(2pi))
            tolerance = 64eps(Float64)*(1+abs(rlog)+abs(lp.L[1])+abs(lp.L[2]))
            arithmetic_ok &= abs(delta-2pi*im*nratio) <= tolerance
            ratio += nratio != 0
        end
        for i in 1:nnode, j in 1:nnode
            ns[i,j] == (0,0) && continue
            Q = nearest_zero(ns, i, j)
            w = isnothing(Q) ? nothing : find_witness(o, m, vertices,
                (params[Q[1]], params[Q[2]]), (params[i], params[j]), E, (1,-1))
            if !isnothing(w)
                witnesses += 1
                maxres, maxtol = max(maxres,w.residual), max(maxtol,w.tolerance)
                @printf("WITNESS path=%s E=%s meson=%s beta=%d P=(%d,%d) n=%s Q=%s sign=%+d stage=%s sigma=%.12g v=%.12g u=%.12g t=%.12g pout=%s pin=%s Eroot=%s |Z|=%.3e tolerance=%.3e GeV\n",
                    path, E, meson, beta, i, j, ns[i,j], Q, w.sign, w.stage == 1 ? "a" : "b", w.sigma, w.v, w.u, w.t, w.p, w.q, w.E, w.residual, w.tolerance)
            else
                lp = lifts[i,j]
                checks = [winding_log(o, m, nodes[i], nodes[j], E, sign) for sign in (1,-1)]
                confirmed = all(r.decided && abs(r.value-lp.L[k]) <= r.error for (k,r) in enumerate(checks))
                if confirmed
                    seams += 1
                    @printf("SEAM path=%s E=%s meson=%s beta=%d P=(%d,%d) n=%s Q=%s confirmed=dZ/Z errors=(%.3e,%.3e)\n", path, E, meson, beta, i, j, ns[i,j], Q, checks[1].error, checks[2].error)
                else
                    unexplained += 1
                    @printf("UNEXPLAINED path=%s E=%s meson=%s beta=%d P=(%d,%d) n=%s\n", path, E, meson, beta, i, j, ns[i,j])
                end
            end
        end
        good = unexplained == 0 && arithmetic_ok
        ok &= good
        @printf("%s gate %s %s %s %d %d %d %d %d %d %d arithmetic=%s\n", good ? "PASS" : "FAIL", path, E, meson, beta, nonzero, moment, ratio, witnesses, seams, unexplained, arithmetic_ok)
        totalw += witnesses
        totals += seams
        totalu += unexplained
    end
    @printf("%s Stage-2 branch gate witnesses=%d confirmed_seams=%d unexplained=%d max_root_residual=%.3e max_root_tolerance=%.3e runtime=%.3fs\n", ok ? "PASS" : "FAIL", totalw, totals, totalu, maxres, maxtol, time()-started)
    ok
end

if abspath(PROGRAM_FILE) == @__FILE__
    if "--standalone" in ARGS
        gate_selfcheck() || exit(1)
    else
        @eval import Xb2Continuation
        gate_main() || exit(1)
    end
end
