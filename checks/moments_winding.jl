# Route 2, note 07 S18/S30/S43: integrate dZ/Z, never a stepping tracker.
# Run: julia --project=checks checks/moments_winding.jl [--standalone]
# Also included by branch_gate.jl; importing it does not execute the check.
using QuadGK: quadgk
using Printf
include(joinpath(@__DIR__, "_stage2_probes.jl"))

# Independent transcription of note 07 S3, not package ordering/nu helpers.
function winding_ordering(beta; params=BOchiEFT.Parameters())
    dm = params.mBstar-params.mB
    b, v = 1/(2params.mB), 1/(2params.mBstar)
    ((t=-2dm, h=b, a=b), (t=0.0, h=v, a=v),
     (t=-dm, h=v, a=b), (t=-dm, h=b, a=v))[beta]
end

# On the graph homotopy the continued root is principal (note 07 S34).
function winding_z(o, m, p, q, E, sign)
    sqrt(complex(m^2 + (p + sign*q)^2)) + o.t + o.h*p^2 + o.a*q^2 - E
end

function depth_integrand(o, m, p, q, E0, sign, lam)
    pl = real(p) + im*lam*imag(p)
    ql = real(q) + im*lam*imag(q)
    dp, dq = im*imag(p), im*imag(q)
    s = sqrt(complex(m^2 + (pl + sign*ql)^2))
    dz = (pl + sign*ql)*(dp + sign*dq)/s + 2o.h*pl*dp + 2o.a*ql*dq
    z = s + o.t + o.h*pl^2 + o.a*ql^2 - E0
    dz/z
end

# Coarse/fine quadrature and a floating-point evaluation allowance. The latter
# follows a conservative 256-real-operation budget for Z, its derivative, and
# their complex quotient, amplified by cancellation in the root and in Z.
# This allowance is separate from QuadGK's truncation estimate.
function winding_log(o, m, p, q, E1, sign; coarse=1e-8, fine=1e-10)
    E0 = conj(E1)
    dE = E1-E0
    za = winding_z(o, m, p, q, E0, sign)
    z0 = winding_z(o, m, real(p), real(q), E0, sign)
    f(lam) = depth_integrand(o, m, p, q, E0, sign, lam)
    g(v) = -dE/(za-v*dE)  # explicit (dZ/dE)(dE/dv)/Z, not a ratio log
    ac, _ = quadgk(f, 0.0, 1.0; atol=coarse, rtol=coarse)
    bc, _ = quadgk(g, 0.0, 1.0; atol=coarse, rtol=coarse)
    af, ea = quadgk(f, 0.0, 1.0; atol=fine, rtol=fine)
    bf, eb = quadgk(g, 0.0, 1.0; atol=fine, rtol=fine)
    # Evaluate the forward-error conditioning integral independently of the
    # signed quadrature: errors in evaluating Z are amplified by 1/|Z|.
    function ca(lam)
        pl, ql = real(p)+im*lam*imag(p), real(q)+im*lam*imag(q)
        s = sqrt(complex(m^2 + (pl+sign*ql)^2))
        z = s+o.t+o.h*pl^2+o.a*ql^2-E0
        scale = (m^2+abs(pl+sign*ql)^2)/abs(s)+abs(o.t)+abs(o.h*pl^2)+abs(o.a*ql^2)+abs(E0)
        abs(f(lam))*(1+scale/abs(z))
    end
    function cb(v)
        z = za-v*dE
        s = sqrt(complex(m^2+(p+sign*q)^2))
        scale = (m^2+abs(p+sign*q)^2)/abs(s)+abs(o.t)+abs(o.h*p^2)+abs(o.a*q^2)+abs(E0)+abs(v*dE)
        abs(g(v))*(1+scale/abs(z))
    end
    ka, eka = quadgk(ca, 0.0, 1.0; atol=coarse, rtol=coarse)
    kb, ekb = quadgk(cb, 0.0, 1.0; atol=coarse, rtol=coarse)
    roundoff = 256eps(Float64)*(1+abs(log(z0))+ka+eka+kb+ekb)
    truncation = ea+eb
    convergence = abs(af-ac)+abs(bf-bc)
    error = truncation+convergence+roundoff
    value = log(z0)+af+bf
    # One percent of a winding quantum leaves the integer unambiguous. This
    # classification threshold is fixed geometrically, not tuned to residuals.
    decided = isfinite(error) && error < 2pi/100 && isfinite(value)
    (; value, error, truncation, convergence, roundoff, decided)
end

function winding_selfcheck()
    # Exactly soluble affine Z in both stages: p=q=0 makes depth integral zero.
    o = (t=-0.09, h=0.095, a=0.095)
    E = -0.02262-0.05im
    r = winding_log(o, 0.138, 0.0im, 0.0im, E, 1)
    exact = log(complex(0.138+o.t-E))
    ok = r.decided && abs(r.value-exact) <= r.error
    @printf("%s affine dZ/Z oracle residual=%.3e tolerance=%.3e (GK=%.3e refinement=%.3e roundoff=%.3e)\n",
        ok ? "PASS" : "FAIL", abs(r.value-exact), r.error, r.truncation, r.convergence, r.roundoff)
    # A near-zero stage-b approach checks orientation against direct fine
    # quadrature, without the package. Reversing energy must undo the integral.
    p, q = 0.00067-0.01348im, 0.00534-0.10673im
    za = winding_z(o, 0.138, p, q, conj(E), 1)
    dE = E-conj(E)
    f(v) = -dE/(za-v*dE)
    v, ev = quadgk(f, 0.0, 1.0; atol=1e-11, rtol=1e-11)
    reverse, er = quadgk(f, 1.0, 0.0; atol=1e-11, rtol=1e-11)
    tol = ev+er+64eps(Float64)*(1+abs(v)+abs(reverse))
    ok2 = abs(v+reverse) <= tol
    @printf("%s reversed energy integral residual=%.3e tolerance=%.3e\n", ok2 ? "PASS" : "FAIL", abs(v+reverse), tol)
    ok && ok2
end

function winding_main()
    started = time()
    ok = winding_selfcheck()
    println("Provisional tolerance per endpoint = fine QuadGK error sum + coarse/fine change + 256eps forward-conditioning integral; coarse=1e-8, fine=1e-10.")
    println("Not decided means estimated error >= 2pi/100 (1% of a winding quantum), or nonfinite quadrature.")
    total, notdecided = 0, 0
    for (path, vertices) in pairs(PROBE_PATHS), E in PROBE_ENERGIES,
            (meson, m) in pairs(PROBE_MESONS), beta in 1:4
        o = winding_ordering(beta)
        production_ordering = Xb2Continuation.ordering(beta)
        nodes = probe_nodes(vertices)
        nfail, nd, nchecked = 0, 0, 0
        worst, maxtol, maxgk, maxconv, maxfp = 0.0, 0.0, 0.0, 0.0, 0.0
        for (i, p) in enumerate(nodes), (j, q) in enumerate(nodes)
            lp = Xb2Continuation.lift_default(production_ordering, m, p, q, E)
            for (k, sign) in enumerate((1, -1))
                r = winding_log(o, m, p, q, E, sign)
                total += 1
                if !r.decided
                    nd += 1
                    @printf("NOT_DECIDED path=%s E=%s meson=%s beta=%d pair=(%d,%d) sign=%+d error=%.6e\n", path, E, meson, beta, i, j, sign, r.error)
                    continue
                end
                nchecked += 1
                residual = abs(r.value-lp.L[k])
                worst = max(worst, residual)
                maxtol = max(maxtol, r.error)
                maxgk = max(maxgk, r.truncation)
                maxconv = max(maxconv, r.convergence)
                maxfp = max(maxfp, r.roundoff)
                if residual > r.error
                    nfail += 1
                    @printf("FAIL winding endpoint path=%s E=%s meson=%s beta=%d pair=(%d,%d) sign=%+d residual=%.6e tolerance=%.6e\n", path, E, meson, beta, i, j, sign, residual, r.error)
                end
            end
        end
        notdecided += nd
        ok &= nfail == 0
        @printf("%s winding path=%s E=%s meson=%s beta=%d checked=%d not_decided=%d failures=%d max_residual=%.3e max_tolerance=%.3e (GK=%.3e refinement=%.3e roundoff=%.3e)\n",
            nfail == 0 ? "PASS" : "FAIL", path, E, meson, beta, nchecked, nd, nfail, worst, maxtol, maxgk, maxconv, maxfp)
    end
    @printf("%s winding summary endpoints=%d not_decided=%d runtime=%.3fs\n", ok ? "PASS" : "FAIL", total, notdecided, time()-started)
    ok
end

if abspath(PROGRAM_FILE) == @__FILE__
    if "--standalone" in ARGS
        winding_selfcheck() || exit(1)
    else
        @eval import Xb2Continuation
        winding_main() || exit(1)
    end
end
