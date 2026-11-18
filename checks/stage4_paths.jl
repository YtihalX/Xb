#!/usr/bin/env julia
# Stage 4 independent sampled path checks. All internal quantities use GeV.
# Run from the repository root: julia --project=checks --startup-file=no checks/stage4_paths.jl
# 4b: S33/S34, S35's stronger Re(w)>=m² prediction, S38(V4), L8(a).
# Route: direct Cartesian pair enumeration and Euclidean polygon projection,
# not the certificate's interval bounds. 256eps times the operand scale is a
# provisional complex-arithmetic forward-error allowance (also checked against
# 256-bit arithmetic at the minima). Positive distances must exceed it.
# 4c: S30/S31 and S35 (with S29 depth scaling). Independently construct A and B;
# the package product tracker receives analytic whole-step derivative bounds.
# Compare its unnormalised lifted logs, not reconstructed principal endpoints.
# A 128eps*(1+function evaluations)*(1+|Log Z|) roundoff allowance accounts for
# the accumulated product updates; repeat a spread of tracks with doubled
# derivative bounds (smaller accepted steps) as a convergence check.
# 4c': L8(b), S40(C4,C5). Continue from A at the projected path pair, then move
# the appropriate legs vertically. Sample Re Z at 17/33 points, report their
# minimum difference, and certify positivity between the fine samples using
# the independent analytic |dZ/dlambda| bound. These are sampled checks of the
# tiling's certificates, not a replacement for their whole-rectangle proof.
# All tolerances below are provisional pending user approval.
using Xb2Continuation
using HadronDynamics
using Printf

const MEV = 1000.0
const CHANNEL = ("VV", "PV", "PP")
const ROUND = 256eps(Float64)

mutable struct Minimum
    value::Float64
    where::String
end
Minimum() = Minimum(Inf, "none")
function record!(r::Minimum, v, location)
    if v < r.value
        r.value = v
        r.where = location()
    end
end
fmt(z) = @sprintf("%.9g%+.9gi", MEV*real(z), MEV*imag(z))
function location(cellid, E, p, q; extra="")
    "cell=$cellid,E=$(fmt(E)),p=$(fmt(p)),q=$(fmt(q)) MeV" * extra
end
cut_distance(w) = real(w) >= 0 ? abs(w) : abs(imag(w))
function polygon_distance(z, vertices)
    best = Inf
    for j in 1:length(vertices)-1
        a,b = vertices[j],vertices[j+1]
        t = clamp(real((z-a)*conj(b-a))/abs2(b-a), 0.0, 1.0)
        best = min(best, abs(z-(a+t*(b-a))))
    end
    best
end

# Geometric forward-error check in extended precision at every new extremum.
function oracle_w(p, q, m, sign)
    setprecision(256) do
        bp,bq,bm = Complex{BigFloat}(p),Complex{BigFloat}(q),BigFloat(m)
        ComplexF64(bm^2+(bp+sign*bq)^2)
    end
end

function selected_cells(tiles, region, witness)
    selected = Int[]
    for (i,c) in enumerate(tiles.certified)
        q = c.rectangle
        contains = q.re[1] <= real(witness) <= q.re[2] && q.im[1] <= imag(witness) <= q.im[2]
        threshold_corner = any(x -> q.re[1] <= x <= q.re[2], region.re) &&
                           any(y -> q.im[1] <= y <= q.im[2], region.im)
        (contains || threshold_corner || !isempty(c.dropped)) && push!(selected,i)
    end
    selected
end
energies(q) = ComplexF64[complex(x,y) for x in q.re for y in q.im] |> x -> vcat(x,center(q))
function spread(path, ks)
    L = real(last(path.vertices))
    xs = sort!(unique!(vcat(real.(path.vertices), real.(ks), L .* [1e-6,0.15,0.5,0.85,1-1e-6])))
    ComplexF64[complex(x,path_height(path,x)) for x in xs]
end

# All momenta and E are affine on an individual homotopy stage. Convexity of
# |p|, |q| and |p±q| gives maxima at interval endpoints. The reverse triangle
# inequality bounds |w| away from zero, hence |s'| <= |w'|/(2sqrt(wlower)).
struct Stage
    p::ComplexF64
    q::ComplexF64
    dp::ComplexF64
    dq::ComplexF64
    E::ComplexF64
    dE::ComplexF64
end
function argument(st::Stage, o, m, sign, t)
    p,q = st.p+t*st.dp,st.q+t*st.dq
    sqrt(complex(m^2+(p+sign*q)^2))+nu(o,p,q,st.E+t*st.dE)
end
function derivative_bound(st::Stage, o, m, sign, a, b)
    pa,pb = st.p+a*st.dp,st.p+b*st.dp
    qa,qb = st.q+a*st.dq,st.q+b*st.dq
    ra,rb = pa+sign*qa,pb+sign*qb
    dw = 2abs(st.dp+sign*st.dq)*max(abs(ra),abs(rb))
    wl = abs(m^2+ra^2)-dw*(b-a)
    wl > ROUND*max(1.0,abs(m^2+ra^2)) || return Inf
    (dw/(2sqrt(wl))+2abs(o.h*st.dp)*max(abs(pa),abs(pb))+
     2abs(o.a*st.dq)*max(abs(qa),abs(qb))+abs(st.dE))*(1+ROUND)
end
function stages(p, q, E)
    E0 = complex(real(E),abs(imag(E))+0.001)
    flatp,flatq = complex(real(p)),complex(real(q))
    A1 = Stage(flatp,flatq,p-flatp,q-flatq,E0,0im)
    A2 = Stage(p,q,0im,0im,E0,E-E0)
    B = Stage(flatp,flatq,p-flatp,q-flatq,E0,E-E0)
    A1,A2,B
end
mutable struct TrackStats
    calls::Int
    failures::Int
    discrepancy::Float64
    refinement::Float64
    zmin::Minimum
    nmax::Int
    first_failure::String
end
TrackStats() = TrackStats(0,0,0.0,0.0,Minimum(),0,"")
function failure!(stats, message)
    stats.failures += 1
    isempty(stats.first_failure) && (stats.first_failure=message)
end
function track(st, o, m, sign, initial, stats, loc; factor=1.0)
    evaluations = Ref(0)
    function z(t)
        evaluations[] += 1
        value = argument(st,o,m,sign,t)
        record!(stats.zmin,abs(value),()->loc*",lambda=$t")
        value
    end
    bound(a,b) = factor*derivative_bound(st,o,m,sign,a,b)
    stats.calls += 1
    branch = continue_branch(z,bound,0.0,1.0,initial)
    tol = 128eps(Float64)*(1+evaluations[])*(1+abs(log(z(1.0))))
    branch,tol
end
function checked_track(st, o, m, sign, initial, stats, loc; refine=false)
    branch,tol = track(st,o,m,sign,initial,stats,loc)
    endpoint = argument(st,o,m,sign,1.0)
    difference = abs(branch.logz-log(endpoint))
    stats.discrepancy = max(stats.discrepancy,difference)
    n = round(Int,imag(branch.logz-log(endpoint))/(2pi))
    stats.nmax = max(stats.nmax,abs(n))
    (n == 0 && difference <= tol) || failure!(stats,"nonprincipal lift: $loc, n=$n, error=$difference, tolerance=$tol")
    if refine
        fine,finetol = track(st,o,m,sign,initial,stats,loc; factor=2.0)
        delta = abs(branch.logz-fine.logz)
        stats.refinement = max(stats.refinement,delta)
        delta <= tol+finetol || failure!(stats,"step refinement: $loc, error=$delta")
    end
    branch,tol
end
function default_lift(p,q,E,o,m,sign,stats,loc; refine=false)
    A1,A2,_ = stages(p,q,E)
    b0 = Branch(argument(A1,o,m,sign,0.0))
    b,t1 = checked_track(A1,o,m,sign,b0,stats,loc*",A-depth"; refine)
    b,t2 = checked_track(A2,o,m,sign,b,stats,loc*",A-energy"; refine)
    b,t1+t2
end

# Independent between-sample positivity: min endpoint Re Z - D*half-spacing.
# Subdivide only intervals whose derivative disk cannot yet establish positivity.
function real_lower(st,o,m,sign,a,b,depth=0)
    za,zb = argument(st,o,m,sign,a),argument(st,o,m,sign,b)
    D = derivative_bound(st,o,m,sign,a,b)
    lower = min(real(za),real(zb))-D*(b-a)/2
    tol = ROUND*max(1.0,abs(za),abs(zb))
    min(real(za),real(zb)) > tol || return min(real(za),real(zb))-tol
    lower > tol && return lower
    depth >= 30 && return -Inf
    mid = (a+b)/2
    min(real_lower(st,o,m,sign,a,mid,depth+1), real_lower(st,o,m,sign,mid,b,depth+1))
end
function segment_minimum(st,o,m,sign)
    coarse = minimum(real(argument(st,o,m,sign,t)) for t in range(0,1;length=17))
    vals = [real(argument(st,o,m,sign,t)) for t in range(0,1;length=33)]
    idx = argmin(vals)
    lower = minimum(real_lower(st,o,m,sign,j/32,(j+1)/32) for j in 0:31)
    vals[idx],(idx-1)/32,lower,abs(coarse-vals[idx])
end

function graph_check!(result, pathpoints, ks, vertices, E, cellid, params)
    # result = path-cut, node-cut, branchpoint-distance, Re(w)-m², oracle error, count, pass
    pathcut,nodecut,emb,rebound,oracle,count,ok = result
    S = vcat(pathpoints,ks)
    npath = length(pathpoints)
    for i in eachindex(S), j in eachindex(S), (meson,m) in (("pi",params.mpi),("eta",params.meta)), sign in (-1,1)
        p,q = S[i],S[j]
        w = m^2+(p+sign*q)^2
        d = cut_distance(w)
        tol = ROUND*max(1.0,m^2,abs2(p)+abs2(q))
        count[] += 1
        group = i <= npath && j <= npath ? pathcut : nodecut
        if d < group.value
            err = abs(w-oracle_w(p,q,m,sign))
            oracle[] = max(oracle[],err/tol)
            err <= tol || (ok[]=false)
        end
        record!(group,d,()->location(cellid,E,p,q;extra=",meson=$meson,sign=$sign"))
        d > tol || (ok[]=false)
        if i <= npath && j <= npath
            slack = real(w)-m^2
            record!(rebound,slack,()->location(cellid,E,p,q;extra=",meson=$meson,sign=$sign"))
            slack >= -tol || (ok[]=false)
        end
    end
    for p in S, (meson,m) in (("pi",params.mpi),("eta",params.meta)), a in (-1,1), b in (-1,1)
        point = a*p+b*im*m
        d = polygon_distance(point,vertices)
        record!(emb,d,()->"cell=$cellid,E=$(fmt(E)),p=$(fmt(p)),branchpoint=$(fmt(point)) MeV,meson=$meson")
        d > ROUND*max(1.0,abs(point),maximum(abs,vertices)) || (ok[]=false)
    end
end

function region_check(name,label,re,witness,ths,params)
    region = EnergyRectangle(re,(-0.010,0.0))
    initial = (ceil(Int,(re[2]-re[1])/0.005),2)
    tiles = tile_rectangles(region,Sheet(label),ths;initial,floor=1e-4)
    ids = selected_cells(tiles,region,witness)
    graph = (Minimum(),Minimum(),Minimum(),Minimum(),Ref(0.0),Ref(0),Ref(isempty(tiles.excluded)))
    hom,node = TrackStats(),TrackStats()
    segmentmin,segmentlower = Minimum(),Minimum()
    gridchange = 0.0
    points,npairs,nnodepairs = 0,0,0
    for id in ids
        c = tiles.certified[id]
        quadrature,_ = panel_rule(c.path)
        pathpoints = unique!(vcat(quadrature,c.path.vertices))
        for E in energies(c.rectangle)
            points += 1
            ks = [principal_momentum(E,ths[a]) for a in c.nodes]
            cs = [complex(real(k),path_height(c.path,real(k))) for k in ks]
            samples = spread(c.path,ks)
            graph_check!(graph,pathpoints,ks,c.path.vertices,E,id,params)
            for (i,p) in enumerate(samples), (j,q) in enumerate(samples)
                npairs += 1
                for (meson,m) in (("pi",params.mpi),("eta",params.meta)), sign in (-1,1), beta in 1:4
                    o = ordering(beta;params)
                    loc = location(id,E,p,q;extra=",meson=$meson,sign=$sign,beta=$beta")
                    try
                        refine = i == 2 && j == length(samples)-1
                        A,ta = default_lift(p,q,E,o,m,sign,hom,loc;refine)
                        _,_,Bstage = stages(p,q,E)
                        B,tb = checked_track(Bstage,o,m,sign,Branch(argument(Bstage,o,m,sign,0.0)),hom,loc*",B";refine)
                        err = abs(A.logz-B.logz)
                        hom.discrepancy=max(hom.discrepancy,err)
                        err <= ta+tb || failure!(hom,"family mismatch: $loc, error=$err")
                    catch e
                        e isa BranchTrackingError || rethrow()
                        failure!(hom,"BranchTrackingError: $loc: $(sprint(showerror,e))")
                    end
                end
            end
            # Each tuple specifies the projected start, on-shell end, active
            # block ordering and the node channels defining that entry.
            pairs = Tuple{ComplexF64,ComplexF64,ComplexF64,ComplexF64,Int,String}[]
            for (ia,a) in enumerate(c.nodes), q in samples
                for beta in Xb2Continuation._SP_ROWS[a]
                    push!(pairs,(cs[ia],q,ks[ia],q,beta,"row=$(CHANNEL[a])"))
                end
                for beta in Xb2Continuation._SP_COLS[a]
                    push!(pairs,(q,cs[ia],q,ks[ia],beta,"column=$(CHANNEL[a])"))
                end
            end
            for (ia,a) in enumerate(c.nodes), (ib,b) in enumerate(c.nodes), beta in unique(Xb2Continuation._SP_BLOCKS[a][b])
                push!(pairs,(cs[ia],cs[ib],ks[ia],ks[ib],beta,"nodes=$(CHANNEL[a]),$(CHANNEL[b])"))
            end
            for (p0,q0,p1,q1,beta,kind) in pairs
                nnodepairs += 1
                for (meson,m) in (("pi",params.mpi),("eta",params.meta)), sign in (-1,1)
                    o=ordering(beta;params)
                    loc=location(id,E,p1,q1;extra=",$kind,meson=$meson,sign=$sign,beta=$beta")
                    try
                        start,_=default_lift(p0,q0,E,o,m,sign,node,loc)
                        st=Stage(p0,q0,p1-p0,q1-q0,E,0im)
                        checked_track(st,o,m,sign,start,node,loc*",vertical")
                        minimum,t,lower,change=segment_minimum(st,o,m,sign)
                        gridchange=max(gridchange,change)
                        record!(segmentmin,minimum,()->loc*",lambda=$t,z_margin=$(MEV*c.z_margin) MeV")
                        record!(segmentlower,lower,()->loc*",z_margin=$(MEV*c.z_margin) MeV")
                        lower > ROUND*max(1.0,abs(minimum)) || failure!(node,"nonpositive segment lower bound: $loc, lower=$lower")
                        minimum+ROUND*max(1.0,abs(minimum)) >= c.z_margin || failure!(node,"segment below certificate: $loc, minimum=$minimum, z_margin=$(c.z_margin)")
                    catch e
                        e isa BranchTrackingError || rethrow()
                        failure!(node,"BranchTrackingError: $loc: $(sprint(showerror,e))")
                    end
                end
            end
        end
    end
    pathcut,nodecut,emb,slack,oracle,countref,ok=graph
    tiling_ok=isempty(tiles.excluded) && !isempty(ids)
    @printf("%s 4b %s S33/S34/S35/S38(V4)/L8(a): cells=%d/%d dropped_cells=%d energies=%d pair_sign_mesons=%d trackings=0 path_cut_min=%.12g MeV² {%s}; node_cut_min=%.12g MeV² {%s}; Rew_minus_m2_min=%.12g MeV² {%s}; exchanged_point_distance_min=%.12g MeV {%s}; BigFloat_error/tolerance=%.6g\n", ok[] && tiling_ok ? "PASS" : "FAIL", name,length(ids),length(tiles.certified),count(c->!isempty(c.dropped),tiles.certified),points,countref[],1e6*pathcut.value,pathcut.where,1e6*nodecut.value,nodecut.where,1e6*slack.value,slack.where,MEV*emb.value,emb.where,oracle[])
    @printf("%s 4c %s S30/S31/S35: energies=%d pairs=%d trackings=%d nmax=%d sampled_absZ_min=%.12g MeV {%s}; max_log_error=%.12g step_refinement_max=%.12g failures=%d%s\n", hom.failures==0 && tiling_ok ? "PASS" : "FAIL",name,points,npairs,hom.calls,hom.nmax,MEV*hom.zmin.value,hom.zmin.where,hom.discrepancy,hom.refinement,hom.failures,isempty(hom.first_failure) ? "" : " {"*hom.first_failure*"}")
    @printf("%s 4c' %s L8(b)/S40(C5): energies=%d pairs_with_ordering=%d trackings=%d nmax=%d segment_ReZ_min=%.12g MeV {%s}; between_sample_lower_min=%.12g MeV {%s}; grid_17_33_change_max=%.12g MeV max_log_error=%.12g failures=%d%s\n", node.failures==0 && tiling_ok ? "PASS" : "FAIL",name,points,nnodepairs,node.calls,node.nmax,MEV*segmentmin.value,segmentmin.where,MEV*segmentlower.value,segmentlower.where,MEV*gridchange,node.discrepancy,node.failures,isempty(node.first_failure) ? "" : " {"*node.first_failure*"}")
    ok[] && tiling_ok && hom.failures==0 && node.failures==0
end
function main()
    started=time_ns()
    params=HadronDynamics.BOchiEFT.Parameters()
    ths=thresholds_2pp(;params)
    println("Stage 4 paths: tolerances provisional; geometry=256eps*operand_scale; log=128eps*(1+evaluations)*(1+abs(Log Z)); 256-bit extrema and doubled-bound tracker refinement; segment grids 17/33 plus derivative enclosures. Locations/energies/momenta in MeV; cut distances in MeV².")
    a=region_check("A1","(-,+,+)",(ths[3].delta,ths[2].delta),complex(-0.06785,-0.005),ths,params)
    b=region_check("A2","(-,-,+)",(ths[2].delta,ths[1].delta),complex(-0.02262,-0.005),ths,params)
    @printf("Total runtime: %.3f s\n",(time_ns()-started)/1e9)
    a && b
end
if abspath(PROGRAM_FILE)==@__FILE__
    main() || exit(1)
end
