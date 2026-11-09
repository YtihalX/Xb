using Test
using Xb2Continuation
using HadronDynamics
const HD = HadronDynamics
const BO = HD.BOchiEFT
include("continuity_tracker.jl")
# The recorded probe helper's quadrature dependency lives in the shared checks environment.
push!(LOAD_PATH, normpath(joinpath(@__DIR__, "../../../checks")))
include("../../../checks/_stage2_probes.jl")

function default_curve(pout,pin,E)
    E0 = complex(real(E),abs(imag(E)))
    t -> t <= 0.5 ?
        (real(pout)+2t*im*imag(pout),real(pin)+2t*im*imag(pin),E0) :
        (pout,pin,E0+(2t-1)*(E-E0))
end

const started = time()
@testset "Certified branch tracker" begin
    loop(t) = cis(2pi*t)
    b = continue_branch(loop, (a,b)->2pi, 0.0, 1.0, Branch(loop(0.0)))
    tol = 128eps(Float64) * 2pi # ≤ 128 rounded product-rule operations
    println("Tracker provisional tolerance = $tol (128 ulps × 2π)")
    @test abs(b.logz - 2pi*im) <= tol
    @test abs(b.sqrtz + 1) <= tol
    @test_throws BranchTrackingError continue_branch(t->complex(1-2t), (a,b)->2.0,
                                                    0.0, 1.0, Branch(1))
end
@testset "Default lift and physical offsets" begin
    params = BO.Parameters()
    model = BO.OMEInteraction(params;channels=BO.channels_2pp())
    for po in (0.0,0.17,0.71-0.13im), qi in (0.0,0.31,0.43-0.09im),
        E in (-0.06+0.03im,-0.02-0.05im), out in 1:6, incoming in 1:6
        expected = BO.tc_alphas(model,out,incoming,po,qi,E)
        isempty(expected) && continue
        block = Symbol(model.channels[out].species,"_",model.channels[incoming].species)
        actual = [nu(ordering(beta),po,qi,E) for beta in block_orderings(block)]
        # tc_alphas subtracts ~10.6 GeV absolute masses; its rounding sets the floor.
        @test maximum(abs.(actual.-collect(expected))) <= 8eps(Float64)*2params.mBstar
    end
    println("Offsets provisional tolerance = ",8eps(Float64)*2params.mBstar,
            " GeV (8 ulps of the absolute heavy-pair energy)")
    for beta in 1:4, mass in values(PROBE_MESONS)
        lp = lift_default(ordering(beta),mass,0.2,0.4,-0.03+0.05im)
        @test lp.n == (0,0)
        @test all(abs.(collect(lp.L).-log.(collect(lp.Z))) .<= 32eps(Float64))
    end
    maxres = 0.0
    for vertices in (PROBE_PATHS.gentle_2_3,PROBE_PATHS.gentle_1_3),
        (po,qi) in ((path_point(vertices,0.4),path_point(vertices,0.8)),
                    (path_point(vertices,1.2),path_point(vertices,2.4))),
        E in PROBE_ENERGIES, mass in values(PROBE_MESONS), beta in 1:4
        o = ordering(beta)
        lp = lift_default(o,mass,po,qi,E)
        oracle = ContinuityTracker.tracked_branches(default_curve(po,qi,E),
                                                   (p,q,e)->[nu(o,p,q,e)],mass)
        # Nearest-branch oracle has only roundoff at endpoints; certify its scale independently.
        tol = 128eps(Float64)*max(1.0,abs(oracle[4][1]),abs(oracle[5][1]))
        res = max(abs(lp.L[1]-oracle[4][1]),abs(lp.L[2]-oracle[5][1]))
        maxres = max(maxres,res)
        @test res <= tol
        @test lp.n == (0,0)
        @test lp.zmin > 0
    end
    println("Lift oracle max residual = $maxres; tolerance = 128 ulps × max(1, |L±|), provisional")
end

# Independent established J_j recurrence, recomputed from inputs at two precisions.
function established(po,qi,E,mass,o,bits)
    setprecision(BigFloat,bits) do
        p,q,e,m = Complex{BigFloat}(po),Complex{BigFloat}(qi),Complex{BigFloat}(E),BigFloat(mass)
        n = BigFloat(o.t)+BigFloat(o.h)*p^2+BigFloat(o.a)*q^2-e
        HD.ExchangeMoments._sd_one_moments_recurrence(m^2+p^2+q^2,2p*q,n;order=4)
    end
end

@testset "Lifted angular moments" begin
    maxerror = 0.0
    maxtol = 0.0
    for po in (0.0,0.02,0.4,1.2), qi in (0.0,0.17,0.8), beta in 1:4,
        mass in values(PROBE_MESONS)
        E = -0.03+0.05im
        o = ordering(beta)
        lp = lift_default(o,mass,po,qi,E)
        v = moments(lp;order=4)
        ref = established(po,qi,E,mass,o,256)
        fine = established(po,qi,E,mass,o,512)
        # The package J_j oracle uses the same M_m normalization 1/(2s(s+ν)), n=0:order.
        # Oracle precision convergence (Float64→256→512), independently of production.
        # Polynomial cancellation in either algebraic representation is not bounded by
        # |B|/σ alone, so retain the measured Float64 J_j assembly error component.
        A,B,vnu = mass^2+po^2+qi^2,2po*qi,nu(o,po,qi,E)
        ratio = abs(B)/max(abs(A),abs(vnu)^2)
        coarse = ratio >= 0.3 ?
            HD.ExchangeMoments._sd_one_moments_recurrence(complex(A),complex(B),vnu;order=4) : ref
        tol = 8abs.(coarse.-ref).+8abs.(ref.-fine).+
              32eps(Float64).*max.(1.0,abs.(fine))
        err = abs.(v.-fine)
        @test all(err .<= tol)
        maxerror = max(maxerror,Float64(maximum(err)))
        maxtol = max(maxtol,Float64(maximum(tol)))
    end
    println("Established moment oracle: max error=$maxerror GeV^-2; max provisional tolerance=$maxtol; ",
            "8×(|Float64→256-bit change| above switch + |256→512-bit change|) + 32 ulps")

    o,mass = ordering(3),PROBE_MESONS.pi
    po,qi,E = 0.7-0.2im,0.9-0.2im,PROBE_ENERGIES[2]
    lp = lift_default(o,mass,po,qi,E)
    ref = ContinuityTracker.tracked_moments(default_curve(po,qi,E),(p,q,e)->[nu(o,p,q,e)],mass,4)
    fine = established(po,qi,E,mass,o,512)
    # Endpoint-double oracle loses precision; its measured deficit against the independent
    # 512-bit J_j assembly sets its error, not the production residual.
    tol = 8abs.(ref.-fine).+128eps(Float64).*max.(1.0,abs.(fine))
    @test all(abs.(moments(lp).-ref) .<= tol)
    println("ContinuityTracker moment tolerance = ",Float64.(tol),
            " GeV^-2 (8× endpoint-double deficit against 512-bit J_j + 128 ulps), provisional")

    # Locate the S22 boundary from the geometry, not from production's branch decision.
    po,E = 0.7-0.1im,-0.03-0.05im
    ratio(q) = abs(2po*q)/max(abs(mass^2+po^2+q^2),abs(nu(o,po,q,E))^2)
    lo,hi = 0.0,0.3
    for _ in 1:60
        mid = (lo+hi)/2
        ratio(mid) < 0.3 ? (lo=mid) : (hi=mid)
    end
    q0 = (lo+hi)/2
    qs = (q0*(1-1e-8),q0*(1+1e-8))
    @test ratio(qs[1]) < 0.3 < ratio(qs[2])
    vals = [moments(lift_default(o,mass,po,q,E)) for q in qs]
    refs = [established(po,q,E,mass,o,512) for q in qs]
    coarse = [established(po,q,E,mass,o,256) for q in qs]
    tol = [8abs.(refs[j].-coarse[j]).+
           32eps(Float64)*max(1.0,ratio(qs[j])^-5).*max.(1.0,abs.(refs[j])) for j in 1:2]
    for j in 1:2
        @test all(abs.(vals[j].-refs[j]) .<= tol[j])
    end
    @test all(abs.((vals[2].-vals[1]).-(refs[2].-refs[1])) .<= tol[1].+tol[2])
    println("S22 continuity tolerance = ",Float64.(tol[1].+tol[2]),
            " GeV^-2 (sum of two 256→512 convergence and cancellation estimates), provisional")
end
@testset "Conditioned closed-form moments" begin
    # Independent 192-bit paired-x quadrature from XPlaneChecks; its relative
    # integration bound is <9e-31. Literals retain Float64 rounding only.
    nodes = probe_nodes(PROBE_PATHS.steep)
    worst = 0.0
    for (beta,ip,iq,ref) in ((2,10,25,0.2179624253277616+0.07934356576120179im),
                           (3,8,5,14.949176793981149-10.085921526359698im))
        lp = lift_default(ordering(beta),PROBE_MESONS.pi,nodes[ip],nodes[iq],PROBE_ENERGIES[1])
        sigma = max(abs(lp.mphi^2+lp.pout^2+lp.pin^2),abs(nu(lp.ordering,lp.pout,lp.pin,lp.E))^2)
        @test abs(2lp.pout*lp.pin) >= 0.3sigma
        tol = (1e-10+eps(Float64)+9e-31)*abs(ref)
        err = abs(moments(lp)[5]-ref)
        @test err <= tol
        worst = max(worst,err/abs(ref))
    end
    println("Conditioned moments: user decision 2026-11-05, 1e-10 relative per moment + one output ulp + <9e-31 independent quadrature bound")
    println("Conditioned quadrature fixtures maximum relative error = $worst")

    # Select both sides of the cancellation safety net from the recorded geometry.
    # The accepted case crossed the former 1e-13 budget, but not the new target.
    accepted = nothing
    escalated = nothing
    for beta in 1:4, po in nodes, qi in nodes
        lp = lift_default(ordering(beta),PROBE_MESONS.pi,po,qi,PROBE_ENERGIES[1])
        A,B,v = lp.mphi^2+po^2+qi^2,2po*qi,nu(lp.ordering,po,qi,lp.E)
        abs(B) >= 0.3max(abs(A),abs(v)^2) || continue
        raw,kappa = Xb2Continuation._closed(A,B,v,lp.s,lp.Z,lp.L,4;estimate=true)
        budget = 16eps(Float64)*kappa
        if accepted === nothing && 1e-13 < budget <= 1e-10
            accepted = (lp,raw,kappa)
        elseif escalated === nothing && budget > 1e-10
            escalated = (lp,raw,kappa)
        end
        accepted !== nothing && escalated !== nothing && break
    end
    @test accepted !== nothing
    @test escalated !== nothing
    accepted_worst = 0.0
    for (name,fixture) in (("Float64",accepted),("BigFloat",escalated))
        lp,raw,kappa = fixture
        # Independent 1024-bit closed form, rebuilding every endpoint from the
        # original inputs and retaining only the certified branch integers.
        ref = setprecision(BigFloat,1024) do
            p,q,m,E = Complex{BigFloat}(lp.pout),Complex{BigFloat}(lp.pin),
                        BigFloat(lp.mphi),Complex{BigFloat}(lp.E)
            o = lp.ordering
            v = BigFloat(o.t)+BigFloat(o.h)*p^2+BigFloat(o.a)*q^2-E
            A,B = m^2+p^2+q^2,2p*q
            s = (sqrt(m^2+(p+q)^2),sqrt(m^2+(p-q)^2))
            Z = (s[1]+v,s[2]+v)
            L = ntuple(j->log(Z[j])+2BigFloat(pi)*im*lp.n[j],2)
            first(Xb2Continuation._closed(A,B,v,s,Z,L,4))
        end
        actual = moments(lp)
        errors = abs.(actual.-ref)./abs.(ref)
        @test all(errors .<= 1e-10)
        if name == "Float64"
            @test 1e-13 < 16eps(Float64)*kappa <= 1e-10
            @test actual == raw
            accepted_worst = Float64(maximum(errors))
        else
            @test 16eps(Float64)*kappa > 1e-10
            @test actual != raw
        end
        println("Conditioned $name fixture: kappa=$kappa; max relative error=$(Float64(maximum(errors)))")
    end
    println("Worst Float64 error now accepted above switch on fixtures = $accepted_worst")
end

function stage3_check(ok::Bool, name)
    println(ok ? "PASS " : "FAIL ", name)
    @test ok
end

@testset "Graph path builder" begin
    ths = thresholds_2pp()
    params = BO.Parameters()
    offset_tol = 8eps(Float64)*2params.mBstar
    stage3_check(isapprox([t.delta for t in ths],[0,-0.04523,-0.09046];atol=offset_tol,rtol=0),
                 "S2 thresholds (8 ulps of two-heavy-mass subtraction = $offset_tol GeV)")
    stage3_check([t.mu for t in ths] ≈
                 [params.mBstar/2, params.mB*params.mBstar/(params.mB+params.mBstar), params.mB/2],
                 "S2 reduced masses")
    margin = 0.010
    # S40 table literals are quoted to 0.01 MeV, independently of the builder.
    fixtures = ((-0.06785-0.010im, (false,false,true),
                 (0.04417-0.60269im, 0.07482-0.35430im, 0.35348-0.07468im)),
                (-0.02262-0.010im, (false,true,true),
                 (0.07498-0.35506im, 0.35423-0.07484im, 0.60008-0.04399im)))
    for (E, signs, fourth_quadrant) in fixtures
        path = graph_path(E,ths;margin)
        stage3_check(path isa GraphPath,"graph path returned at E=$(1000E) MeV")
        path isa GraphPath || continue
        stage3_check(path.vertices[1] == 0,"fixed start at E=$(1000E) MeV")
        stage3_check(path.vertices[end] == 4,"fixed cutoff at E=$(1000E) MeV")
        stage3_check(all(real.(diff(path.vertices)) .> 0),"strict graph property at E=$(1000E) MeV")
        stage3_check(all(imag.(path.vertices) .<= 0),"closed fourth quadrant at E=$(1000E) MeV")
        stage3_check(all(abs.(imag.(diff(path.vertices))) .<= real.(diff(path.vertices))),
                     "slope bound one at E=$(1000E) MeV")
        for (j,th) in enumerate(ths)
            k = sheet_momentum(E,th)
            stage3_check(flipped(E,th) == signs[j],"flipped channel $j at E=$(1000E) MeV")
            stage3_check(imag(k)*(signs[j] ? -1 : 1) > 0,"root sign $j at E=$(1000E) MeV")
            q = signs[j] ? k : -k
            stage3_check(abs(q-fourth_quadrant[j]) <= sqrt(2)*0.005e-3,
                         "S40 rounded pole $j at E=$(1000E) MeV")
            stage3_check(inside_region(path,q) == signs[j],"sheet placement $j at E=$(1000E) MeV")
            stage3_check(min(path_distance(path,k),path_distance(path,-k)) >= margin,
                         "both pole margins $j at E=$(1000E) MeV")
        end
        # Independent dense traversal of (P); production must certify between samples.
        sampled_clear = all(Iterators.product(range(-abs(imag(E)),abs(imag(E));length=129),ths)) do (eta,th)
            k = sqrt(complex(2th.mu*(real(E)+im*eta-th.delta)))
            min(path_distance(path,k),path_distance(path,-k)) > 0
        end
        stage3_check(sampled_clear,"vertical (P), 129 independent energy samples at E=$(1000E) MeV")
    end
    upper = graph_path(-0.02262+0.010im,ths;margin)
    stage3_check(upper isa GraphPath,"upper-half-plane graph path")
    stage3_check(upper.vertices == [0,4],"upper-half-plane real segment")
    below = graph_path(-0.100-0.010im,ths;margin)
    stage3_check(below isa GraphPath && below.vertices == [0,4],"no flipped channel uses real segment")
    for th in ths, offset in (0.0,0.0001)
        excluded = graph_path(th.delta+offset-0.010im,ths;margin)
        stage3_check(excluded isa PathExclusion,"threshold-strip exclusion at E=$(1000(th.delta+offset))-10i MeV")
        stage3_check(!isempty(excluded.reason),"exclusion reason: $(excluded.reason)")
    end
    println("Path table tolerance = sqrt(2)*0.005 MeV (half-unit rounding of each quoted component)")
end

@testset "Oriented graph path quadrature" begin
    # An asymmetric polygon makes the missing Jacobian/conjugated Jacobian visible.
    path = GraphPath([0,0.27-0.19im,0.83-0.19im,1.4])
    n = 16
    q,w = path_rule(path,n)
    stage3_check(length(q) == length(w) == 3n,"n complex nodes/weights per segment")
    stage3_check(q isa Vector{ComplexF64},"complex quadrature nodes")
    stage3_check(w isa Vector{ComplexF64},"complex oriented quadrature weights")
    roundoff = 0.0
    for degree in 0:2n-1
        values = q.^degree
        exact = 1.4^(degree+1)/(degree+1)
        # 2n-step recurrence/evaluation + accumulation over 3n nodes, 8 ulps/step.
        tol = 8eps(Float64)*(2n+length(q))*max(1.0,sum(abs.(w.*values)),abs(exact))
        roundoff = max(roundoff,tol)
        stage3_check(abs(sum(w.*values)-exact) <= tol,"polynomial degree $degree with tolerance $tol")
    end
    coarseq,coarsew = path_rule(path,n÷2)
    coarse = sum(coarsew.*exp.(coarseq))
    fine = sum(w.*exp.(q))
    exact = exp(1.4)-1
    # Independent analytic GL remainder: on each affine segment, |d^(2n)exp(a+vt)|
    # ≤ exp(1.4)|v/2|^(2n). For n=8 this is already below double roundoff.
    remainder = sum(abs(b-a)*exp(1.4)*factorial(big(n÷2))^4/
                    ((n+1)*factorial(big(n))^3)*abs(b-a)^n
                    for (a,b) in zip(path.vertices[1:end-1],path.vertices[2:end]))
    tol = Float64(remainder)+8eps(Float64)*(2n+length(q))*max(1.0,sum(abs.(w.*exp.(q))))
    stage3_check(abs(coarse-exact) <= tol,"exp(q), n=8, tolerance $tol")
    stage3_check(abs(fine-exact) <= tol,"exp(q), n=16, tolerance $tol")
    stage3_check(abs(fine-coarse) <= 2tol,"exp(q) node doubling, change $(abs(fine-coarse))")
    invalid_rejected = try
        path_rule(path,0)
        false
    catch err
        err isa ArgumentError
    end
    stage3_check(invalid_rejected,"reject zero-node quadrature rule")
    println("Quadrature tolerance: polynomials ≤ $roundoff (8 ulps × (2n+3n) × absolute-sum scale); ",
            "exp = $tol (analytic n=8 GL remainder $(Float64(remainder)) + same roundoff)")
end
println("Package test runtime: ", time() - started, " s")
