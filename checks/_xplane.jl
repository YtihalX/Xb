# Independent x-plane oracle for note 07, S20--S21. Helpers are not checks.
module XPlaneChecks
using QuadGK
using HadronDynamics: BOchiEFT
using Printf

export note_ordering, note_nu, crossing_events, crosses_default, straight_integral,
       deformed_contour, contour_integral, check_orderings, run_xcheck

function note_ordering(beta; params=BOchiEFT.Parameters())
    dm = params.mBstar - params.mB
    b, v = inv(2params.mB), inv(2params.mBstar)
    ((t=-2dm,h=b,a=b), (t=0.0,h=v,a=v),
     (t=-dm,h=v,a=b), (t=-dm,h=b,a=v))[beta]
end
note_nu(o,p,q,E) = o.t + o.h*p^2 + o.a*q^2 - E

# Ascending polynomial coefficients. Recursive derivative isolation includes
# tangencies: between consecutive stationary points a real polynomial is monotone.
polyval(c,x) = foldr((a,b)->a+x*b, c; init=zero(eltype(c)))
function polymul(a,b)
    c=zeros(promote_type(eltype(a),eltype(b)),length(a)+length(b)-1)
    for i in eachindex(a), j in eachindex(b)
        c[i+j-1] += a[i]*b[j]
    end
    c
end
function polyadd(a,b)
    c=zeros(promote_type(eltype(a),eltype(b)),max(length(a),length(b)))
    c[1:length(a)] .+= a
    c[1:length(b)] .+= b
    c
end
function realroots01(coeff)
    c=copy(coeff)
    scale=maximum(abs,c)
    scale == 0 && return Float64[]
    c ./= scale
    while length(c)>1 && abs(c[end]) < 32eps(Float64)
        pop!(c)
    end
    length(c)==1 && return Float64[]
    length(c)==2 && return 0 <= -c[1]/c[2] <= 1 ? [-c[1]/c[2]] : Float64[]
    critical=realroots01([k*c[k+1] for k in 1:length(c)-1])
    grid=sort!(unique!([0.0;critical;1.0]))
    roots=Float64[]
    for x in grid
        abs(polyval(c,x)) <= 256eps(Float64)*sum(abs,c) && push!(roots,x)
    end
    for (a,b) in zip(grid[1:end-1],grid[2:end])
        fa,fb=polyval(c,a),polyval(c,b)
        signbit(fa)==signbit(fb) && continue
        for _ in 1:48
            mid=(a+b)/2
            fm=polyval(c,mid)
            if signbit(fa)==signbit(fm)
                a,fa=mid,fm
            else
                b=mid
            end
        end
        push!(roots,(a+b)/2)
    end
    sort!(roots)
    unique!(x->round(x;digits=12),roots)
end

function homotopy(o,m,p,q,E,stage,lam)
    pp=stage==1 ? complex(real(p),lam*imag(p)) : p
    qq=stage==1 ? complex(real(q),lam*imag(q)) : q
    EE=stage==1 ? conj(E) : conj(E)+lam*(E-conj(E))
    A=m^2+pp^2+qq^2
    B=2pp*qq
    n=note_nu(o,pp,qq,EE)
    (A=A,B=B,nu=n,x0=A/B,x1=(A-n^2)/B)
end

function crossing_events(o,m,p,q,E)
    events=NamedTuple{(:stage,:lam,:point,:x,:direction),Tuple{Int,Float64,Int,ComplexF64,Int}}[]
    for stage in 1:2
        pp=stage==1 ? ComplexF64[real(p),im*imag(p)] : ComplexF64[p]
        qq=stage==1 ? ComplexF64[real(q),im*imag(q)] : ComplexF64[q]
        p2,q2=polymul(pp,pp),polymul(qq,qq)
        A=polyadd(ComplexF64[m^2],polyadd(p2,q2))
        B=2polymul(pp,qq)
        en=stage==1 ? ComplexF64[conj(E)] : ComplexF64[conj(E),E-conj(E)]
        nu=polyadd(ComplexF64[o.t],polyadd(o.h*p2,o.a*q2))
        nu=polyadd(nu,-en)
        for (point,N) in ((0,A),(1,polyadd(A,-polymul(nu,nu))))
            # Im(N/B)=Im(N*conj(B))/|B|^2. Degree <=6, so
            # isolating every polynomial root cannot miss a narrow passage.
            c=imag.(polymul(N,conj.(B)))
            for lam in realroots01(c)
                st=homotopy(o,m,p,q,E,stage,lam)
                x=point==0 ? st.x0 : st.x1
                if -1 <= real(x) <= 1 && abs(imag(x)) <= 1e-8*max(1,abs(x))
                    d=1e-6
                    left=homotopy(o,m,p,q,E,stage,max(0,lam-d))
                    right=homotopy(o,m,p,q,E,stage,min(1,lam+d))
                    yl=imag(point==0 ? left.x0 : left.x1)
                    yr=imag(point==0 ? right.x0 : right.x1)
                    push!(events,(stage=stage,lam=lam,point=point,x=ComplexF64(x),direction=Int(sign(yr-yl))))
                end
            end
        end
    end
    sort!(events;by=e->(e.stage,e.lam))
end
crosses_default(args...) = !isempty(crossing_events(args...))

# Stable paired quadrature avoids subtraction for odd moments near B=0.
# The root is continued on the segment from x=-1, not selected independently.
function straight_integral(o,m,p,q,E; rtol=2e-12, big=false)
    T=big ? BigFloat : Float64
    pp,qq,EE=Complex{T}(p),Complex{T}(q),Complex{T}(E)
    A=T(m)^2+pp^2+qq^2
    B=2pp*qq
    n=T(o.t)+T(o.h)*pp^2+T(o.a)*qq^2-EE
    sp=sqrt(T(m)^2+(pp+qq)^2)
    root(x)=sp*sqrt((A-B*x)/(A+B))
    vals=Complex{T}[]; errs=T[]; rounds=T[]
    for k in 0:4
        f=function(x)
            s,r=root(x),root(-x)
            if isodd(k)
                x^k*B*x*(r+s+n)/((r+s)*s*(s+n)*r*(r+n))
            else
                x^k*(inv(2s*(s+n))+inv(2r*(r+n)))
            end
        end
        val,err=quadgk(f,zero(T),one(T);rtol=T(rtol),atol=zero(T))
        # Local arithmetic conditioning, integrated by the same independent
        # quadrature. The odd paired expression contains B multiplicatively.
        envelope=function(x)
            s,r=root(x),root(-x)
            rootcond=max((abs(A)+abs(B*x))/abs(s^2),
                         (abs(A)+abs(B*x))/abs(r^2),one(T))
            polecond=max((abs(s)+abs(n))/abs(s+n),
                         (abs(r)+abs(n))/abs(r+n),one(T))
            128eps(T)*abs(f(x))*rootcond*polecond
        end
        rnd,_=quadgk(envelope,zero(T),one(T);rtol=T(1e-6))
        push!(vals,val);push!(errs,err);push!(rounds,rnd)
    end
    vals,errs,rounds
end

# A lasso is an explicit representative of the contour obtained by pushing
# the straight path past an actual integrand pole. Each downward (upward)
# passage appends one counterclockwise (clockwise) loop; opposite passages
# cancel by contour isotopy. No residue or closed moment formula is used.
# The squared equation also gives regular x1 candidates on the other sheet:
# those are not marked singularities of this integrand and must not be pushed.
# For them the straight segment is a valid (trivially deformed) representative.
function deformed_contour(o,m,p,q,E,events)
    any(e->e.point==0,events) && error("x0 passage outside recorded probe geometry")
    poles=pole_events(o,m,p,q,E,events)
    winding=-sum(e.direction for e in poles;init=0)
    winding==0 && return ComplexF64[-1,1]
    st=homotopy(o,m,p,q,E,2,1.0)
    z=st.x1
    radius=0.2min(abs(z+1),abs(z-1),abs(z-st.x0))
    radius>0 || error("marked point meets contour endpoint or x0")
    angle=Base.angle(-1-z)
    start=z+radius*cis(angle)
    contour=ComplexF64[-1,start]
    for k in 1:16abs(winding)
        push!(contour,z+radius*cis(angle+sign(winding)*2pi*k/16))
    end
    append!(contour,ComplexF64[start,-1,1])
    contour
end

function segment_distance(z,a,b)
    a==b && return abs(z-a)
    u=clamp(real((z-a)*conj(b-a))/abs2(b-a),0,1)
    abs(z-(a+u*(b-a)))
end

function contour_integral(o,m,p,q,E,contour;rtol=2e-12,big=false)
    T=big ? BigFloat : Float64
    pp,qq,EE=Complex{T}(p),Complex{T}(q),Complex{T}(E)
    A=T(m)^2+pp^2+qq^2; B=2pp*qq
    n=T(o.t)+T(o.h)*pp^2+T(o.a)*qq^2-EE
    root=sqrt(T(m)^2+(pp+qq)^2)
    vals=zeros(Complex{T},5);errs=zeros(T,5);rounds=zeros(T,5)
    for j in 1:length(contour)-1
        xa,xb=Complex{T}(contour[j]),Complex{T}(contour[j+1])
        dx=xb-xa
        dx==0 && continue
        wa=A-B*xa; wb=A-B*xb
        segment_distance(zero(T),wa,wb)>0 || error("contour meets x0")
        sr=root
        s(t)=sr*sqrt((wa-B*dx*t)/wa)
        for k in 0:4
            f(t)=begin
                x=xa+dx*t; ss=s(t)
                dx*x^k/(2ss*(ss+n))
            end
            val,err=quadgk(f,zero(T),one(T);rtol=T(rtol))
            envelope(t)=begin
                x=xa+dx*t; ss=s(t)
                128eps(T)*abs(f(t))*max(one(T),(abs(A)+abs(B*x))/abs(ss^2))*
                    max(one(T),(abs(ss)+abs(n))/abs(ss+n))
            end
            rnd,_=quadgk(envelope,zero(T),one(T);rtol=T(1e-6))
            vals[k+1]+=val;errs[k+1]+=err;rounds[k+1]+=rnd
        end
        root=sr*sqrt(wb/wa)
    end
    vals,errs,rounds
end

function check_orderings(XBC)
    ok=true
    for beta in 1:4
        n=note_ordering(beta);p=XBC.ordering(beta)
        ok &= (p.t,p.h,p.a)==(n.t,n.h,n.a)
        for (pp,qq,E) in ((0.17-0.08im,0.31-0.12im,-0.02262-0.05im),
                           (0.9-0.2im,0.07-0.1im,-0.06785-0.1im))
            ok &= XBC.nu(p,pp,qq,E)==note_nu(n,pp,qq,E)
        end
    end
    println(ok ? "PASS" : "FAIL"," S3 independent mass-table orderings and asymmetric nu")
    ok
end

function pole_events(o,m,p,q,E,events)
    filter(events) do ev
        ev.point==0 && return true
        st=homotopy(o,m,p,q,E,ev.stage,ev.lam)
        s=sqrt(st.A+st.B)*sqrt((st.A-st.B*real(ev.x))/(st.A+st.B))
        abs(s+st.nu)<abs(s-st.nu)
    end
end

function run_xcheck(XBC,paths,energies,mesons,nodesfn;deformed=false)
    started=time()
    ok=check_orderings(XBC)
    println("Crossings: all real roots of Im(N*conj(B)) (degree <=6), derivative isolation;",
            " 48 bisections per monotonic bracket (lambda resolution <=2^-48),",
            " both S30 stages. x1 candidates are conservatively excluded even on the nonpole sheet.")
    # Production target: user decision 2026-11-05, note 07 S22.
    production_rtol=1e-10
    println("Criterion per moment: |M_package-Q_fine| <= 1e-10*|Q_fine| + B_oracle;",
            " production relative target 1e-10 (user, 2026-11-05; note 07 S22).",
            " B_oracle = 8*(e_coarse + e_fine + |Q_coarse-Q_fine|)",
            " + R_coarse + R_fine + 64eps(Float64)*|Q_fine|;",
            " R is the integrated 128eps arithmetic-conditioning envelope.",
            " QuadGK rtol=2e-10 then 2e-12; 192-bit oracle when |B|/sigma<1e-6.",
            " The oracle budget is unchanged and does not use the package discrepancy.")
    println("Inadmissible criterion: lp.zmin <= 1e-12 GeV (declared numerical margin);",
            " BranchTrackingError is only excluded if the exact vertical Z segment",
            " comes within that margin, otherwise it is a failure.")
    deformed && println("Contour: 16-edge lasso per actual-pole passage, radius=0.2*",
        "min(distance to -1, +1, x0), with an out-and-back connector;",
        " regular x1 candidates use the undeformed representative. Roots continue along every edge.")
    totals=zeros(Int,5) # compared, crossed candidates, inadmissible, actual-pole pairs, failures
    nevents=nx0=0;minedge=Inf;maxres=0.0
    for (name,vertices) in pairs(paths), E in energies, (mes,m) in pairs(mesons), beta in 1:4
        tic=time();nodes=nodesfn(vertices);o=note_ordering(beta)
        compared=crossed=inadmissible=physical=failures=bigpairs=0
        worst=0.0;worsttol=0.0;maxtol=0.0;ratio=0.0;witness=nothing
        for (ip,p) in enumerate(nodes), (iq,q) in enumerate(nodes)
            events=crossing_events(o,m,p,q,E)
            for ev in events
                nevents+=1;nx0+=ev.point==0
                minedge=min(minedge,1-abs(real(ev.x)))
                maxres=max(maxres,abs(imag(ev.x)))
            end
            iscrossed=!isempty(events)
            crossed+=iscrossed
            physical+=!isempty(pole_events(o,m,p,q,E,events))
            lp=try
                XBC.lift_default(XBC.ordering(beta),m,p,q,E)
            catch err
                st=homotopy(o,m,p,q,E,2,0.0)
                dz=E-conj(E)
                d=minimum(segment_distance(0,sqrt(st.A+sgn*st.B)+st.nu,
                                             sqrt(st.A+sgn*st.B)+st.nu-dz) for sgn in (1,-1))
                if err isa XBC.BranchTrackingError && d<=1e-12
                    inadmissible+=1
                else
                    failures+=1
                    witness=(ip=ip,iq=iq,error=sprint(showerror,err))
                end
                continue
            end
            if lp.zmin<=1e-12
                inadmissible+=1
                continue
            end
            iscrossed==deformed || continue
            compared+=1
            sigma=max(abs(m^2+p^2+q^2),abs(note_nu(o,p,q,E))^2,abs(2p*q))
            big=abs(2p*q)/sigma<1e-6
            bigpairs+=big
            oracle=function(rtol)
                if deformed
                    c=deformed_contour(o,m,p,q,E,events)
                    contour_integral(o,m,p,q,E,c;rtol=rtol,big=big)
                else
                    straight_integral(o,m,p,q,E;rtol=rtol,big=big)
                end
            end
            coarse,ec,rc=big ? setprecision(()->oracle(2e-10),192) : oracle(2e-10)
            fine,ef,rf=big ? setprecision(()->oracle(2e-12),192) : oracle(2e-12)
            got=XBC.moments(lp;order=4)
            for k in 1:5
                oracle_budget=8*(ec[k]+ef[k]+abs(coarse[k]-fine[k]))+rc[k]+rf[k]+64eps(Float64)*abs(fine[k])
                budget=production_rtol*abs(fine[k])+oracle_budget
                delta=abs(got[k]-fine[k])
                rel=Float64(delta/abs(fine[k]))
                tol=Float64(budget/abs(fine[k]))
                maxtol=max(maxtol,tol)
                if rel>worst
                    worst=rel;worsttol=tol
                end
                rr=Float64(delta/budget)
                if rr>ratio
                    ratio=rr
                    witness=(ip=ip,iq=iq,m=k-1,got=got[k],oracle=ComplexF64(fine[k]),relative=rel,tolerance=tol)
                end
                failures+=!(isfinite(rr) && rr<=1)
            end
        end
        good=failures==0
        ok &= good
        @printf("%s %s E=%s %s beta=%d compared=%d crossed=%d actual_pole_pairs=%d inadmissible=%d big192=%d worst_relative=%.6e tolerance_at_worst=%.6e max_derived_tolerance=%.6e max_error/budget=%.4g failures=%d runtime=%.3fs\n",
                good ? "PASS" : "FAIL",name,string(E),mes,beta,compared,crossed,physical,
                inadmissible,bigpairs,worst,worsttol,maxtol,ratio,failures,time()-tic)
        good || println("FAIL witness ",witness)
        totals .+= (compared,crossed,inadmissible,physical,failures)
        flush(stdout)
    end
    resolved=nevents==0 || maxres<minedge
    ok &= resolved
    @printf("%s crossing resolution events=%d x0_events=%d min_distance_to_segment_end=%.6e max_Im_x_residual=%.6e lambda_bracket<=%.6e (all polynomial roots, no fixed sampling grid)\n",
            resolved ? "PASS" : "FAIL",nevents,nx0,minedge,maxres,2.0^-48)
    @printf("%s %s total compared=%d crossed=%d inadmissible=%d actual_pole_pairs=%d failures=%d runtime=%.3fs\n",
            ok ? "PASS" : "FAIL",deformed ? "deformed-x" : "straight-x",
            totals...,time()-started)
    ok
end

end
