"""
    Xb2Continuation

Continued TOPT one-meson-exchange kernel for the 2++ pole search, following
`notes/07-continued-lse.tex` (note 07). Units: GeV, energies measured from 2m_{B*}.
"""
module Xb2Continuation

using HadronDynamics
export Ordering, nu, ordering, block_orderings, LiftedPair, lift_default, moments
export Threshold, thresholds_2pp, flipped, sheet_momentum
export GraphPath, PathExclusion, graph_path, inside_region, path_distance, path_rule
include("paths.jl")

struct Ordering
    t::Float64
    h::Float64
    a::Float64
end
nu(o::Ordering,pout,pin,E) = o.t+o.h*pout^2+o.a*pin^2-E

function ordering(beta::Integer;params=HadronDynamics.BOchiEFT.Parameters())::Ordering
    m,v = params.mB,params.mBstar
    d = v-m
    beta == 1 && return Ordering(-2d,1/(2m),1/(2m))
    beta == 2 && return Ordering(0,1/(2v),1/(2v))
    beta == 3 && return Ordering(-d,1/(2v),1/(2m))
    beta == 4 && return Ordering(-d,1/(2m),1/(2v))
    throw(ArgumentError("ordering beta must be 1, 2, 3 or 4"))
end

function block_orderings(block::Symbol)::NTuple{2,Int}
    block === :VV_VV && return (2,2)
    block === :PV_PV && return (1,2)
    block === :VV_PV && return (2,3)
    block === :PV_VV && return (2,4)
    block === :VV_PP && return (3,3)
    block === :PP_VV && return (4,4)
    throw(ArgumentError("block has no OME orderings: $block"))
end

struct LiftedPair
    pout::ComplexF64
    pin::ComplexF64
    E::ComplexF64
    mphi::Float64
    ordering::Ordering
    s::NTuple{2,ComplexF64}
    Z::NTuple{2,ComplexF64}
    L::NTuple{2,ComplexF64}
    n::NTuple{2,Int}
    zmin::Float64
end

export Branch, BranchTrackingError, continue_branch

struct Branch
    logz::ComplexF64
    sqrtz::ComplexF64
end
Branch(z::Number) = Branch(log(ComplexF64(z)), sqrt(ComplexF64(z)))

struct BranchTrackingError <: Exception
    msg::String
end
Base.showerror(io::IO, e::BranchTrackingError) = print(io, e.msg)

# The optional certificate accumulator is internal; the public tracker only returns a Branch.
function _continue_branch(z, dzbound, lam0, lam1, b0; floor, minstep)
    t = Float64(lam0)
    finish = Float64(lam1)
    direction = sign(finish-t)
    step = abs(finish-t)
    b = b0
    zmin = abs(z(t))
    zmin > floor || throw(BranchTrackingError("branch starts below the nonzero floor"))
    while direction*(finish-t) > 0
        endpoint = direction > 0 ? min(finish,t+step) : max(finish,t-step)
        dt = abs(endpoint-t)
        dt > 0 || throw(BranchTrackingError("branch step does not advance"))
        za = ComplexF64(z(t))
        bound = dzbound(min(t,endpoint), max(t,endpoint))
        if !(isfinite(bound) && bound >= 0 && bound*dt <= abs(za)/2)
            step /= 2
            step >= minstep || throw(BranchTrackingError("cannot certify a nonzero branch step"))
            continue
        end
        lower = abs(za)-bound*dt
        lower > floor || throw(BranchTrackingError("branch approaches the nonzero floor"))
        zb = ComplexF64(z(endpoint))
        abs(zb) > floor || throw(BranchTrackingError("branch endpoint below the nonzero floor"))
        ratio = zb/za
        b = Branch(b.logz+log(ratio), b.sqrtz*sqrt(ratio))
        zmin = min(zmin,lower)
        t = endpoint
        step *= 2
    end
    b,zmin
end

function continue_branch(z, dzbound, lam0, lam1, b0::Branch; floor=1e-14, minstep=1e-12)::Branch
    first(_continue_branch(z,dzbound,lam0,lam1,b0;floor,minstep))
end

function lift_default(o::Ordering,mphi::Real,pout::Number,pin::Number,E1::Number)::LiftedPair
    p,q,E = ComplexF64(pout),ComplexF64(pin),ComplexF64(E1)
    m = Float64(mphi)
    all(isfinite,(p,q,E,m,o.t,o.h,o.a)) && m > 0 ||
        throw(ArgumentError("finite momenta, energy, ordering and positive meson mass required"))
    E0 = complex(real(E),abs(imag(E)))
    pt(l) = complex(real(p),l*imag(p))
    qt(l) = complex(real(q),l*imag(q))
    # For r=x+iλy, Im(m²+r²)=2λxy. Only x=0 can hit the cut at λ>0.
    for r in (p+q,p-q)
        iszero(real(r)) && m^2-imag(r)^2 <= 0 &&
            throw(BranchTrackingError("w touches the principal square-root cut during depth scaling"))
    end
    s = ntuple(j->sqrt(complex(m^2+(j==1 ? p+q : p-q)^2)),2)
    Z = ntuple(j->s[j]+nu(o,p,q,E),2)
    results = ntuple(2) do j
        signq = j==1 ? 1 : -1
        x,y = real(p+signq*q),imag(p+signq*q)
        w(l) = complex(m^2+(complex(x,l*y))^2)
        z(l) = sqrt(w(l))+nu(o,pt(l),qt(l),E0)
        function dzbound(a,b)
            # Convexity of |x+iλy| bounds the linear derivatives on the whole step.
            dw = 2abs(y)*max(abs(complex(x,a*y)),abs(complex(x,b*y)))
            wlower = abs(w(a))-dw*(b-a)
            wlower > 0 || return Inf
            dn = 2abs(o.h)*abs(imag(p))*max(abs(pt(a)),abs(pt(b)))+
                 2abs(o.a)*abs(imag(q))*max(abs(qt(a)),abs(qt(b)))
            dw/(2sqrt(wlower))+dn
        end
        branch,lower = _continue_branch(z,dzbound,0.0,1.0,Branch(z(0.0));
                                       floor=1e-14,minstep=1e-12)
        # Distance of E*=s+t+h*p²+a*q² to the closed vertical energy segment.
        star = s[j]+nu(o,p,q,zero(E))
        ynear = clamp(imag(star),min(imag(E0),imag(E)),max(imag(E0),imag(E)))
        distance = abs(star-complex(real(E),ynear))
        distance > 1e-14 ||
            throw(BranchTrackingError("vertical energy segment meets a three-body branch point"))
        lifted = branch.logz+log(Z[j]/z(1.0))
        n = round(Int,imag(lifted-log(Z[j]))/(2pi))
        # Endpoint principal logarithms avoid accumulated roundoff without changing the lift.
        L = log(Z[j])+2pi*im*n
        (L,n,min(lower,distance))
    end
    LiftedPair(p,q,E,m,o,s,Z,(results[1][1],results[2][1]),
               (results[1][2],results[2][2]),min(results[1][3],results[2][3]))
end

# S12 in powers of Z; update polynomial coefficients in-place, descending in degree.
function _closed(A,B,v,s,Z,L,order;estimate::Bool=false)
    T = typeof(A)
    c = zeros(T,2order+1)
    c[1] = one(A)
    answer = Vector{T}(undef,order+1)
    a = A-v^2
    dz = 2B/(s[1]+s[2])
    dL = L[1]-L[2]
    denominator = B
    conditioning = 1.0
    for m in 0:order
        value = c[1]*dL
        magnitude = estimate ? abs(value) : 0.0
        difference = zero(A)
        minuspower = one(A)
        for k in 1:2m
            difference = Z[1]*difference+dz*minuspower
            summand = c[k+1]*difference/k
            value += summand
            estimate && (magnitude += abs(summand))
            minuspower *= Z[2]
        end
        answer[m+1] = value/denominator
        if estimate
            condition = iszero(value) ? (iszero(magnitude) ? 1.0 : Inf) : magnitude/abs(value)
            conditioning = max(conditioning,condition)
        end
        denominator *= B
        m==order && break
        for k in 2(m+1):-1:0
            c[k+1] = (k<=2m ? a*c[k+1] : zero(A))+
                     (1<=k<=2m+1 ? 2v*c[k] : zero(A))-
                     (k>=2 ? c[k-1] : zero(A))
        end
    end
    answer,conditioning
end

function moments(lp::LiftedPair;order::Int=4)::Vector{ComplexF64}
    order >= 0 || throw(ArgumentError("moment order must be nonnegative"))
    p,q,m,o,E = lp.pout,lp.pin,lp.mphi,lp.ordering,lp.E
    A,B,v = m^2+p^2+q^2,2p*q,nu(o,p,q,E)
    if iszero(B)
        lp.n[1]==lp.n[2] ||
            throw(BranchTrackingError("unequal logarithm lifts at B=0 are singular"))
        base = inv(lp.s[1]*(lp.s[1]+v))
        return ComplexF64[iseven(k) ? base/(k+1) : 0 for k in 0:order]
    end
    sigma = max(abs(A),abs(v)^2)
    ratio = abs(B)/sigma
    beta = order<=3 ? 0.06 : 0.3
    cancellationbits = 0
    if ratio >= beta
        values,condition = _closed(A,B,v,lp.s,lp.Z,lp.L,order;estimate=true)
        # S22 extension: the scale ratio alone does not bound cancellation between
        # the logarithmic and polynomial summands. Reserve a 16-ulp operation budget.
        16eps(Float64)*condition <= 1e-10 && return values
        cancellationbits = isfinite(condition) ? ceil(Int,log2(condition)) : 256
    end
    # Recompute ALL endpoint data from the original inputs, never promote rounded
    # Float64 roots/logarithms. The tracked integers are the only branch data needed.
    bits = max(256,ceil(Int,(order+1)*max(0.0,-log2(ratio)))+cancellationbits+128)
    setprecision(BigFloat,bits) do
        bp,bq,bm = Complex{BigFloat}(p),Complex{BigFloat}(q),BigFloat(m)
        bv = BigFloat(o.t)+BigFloat(o.h)*bp^2+BigFloat(o.a)*bq^2-Complex{BigFloat}(E)
        bA,bB = bm^2+bp^2+bq^2,2bp*bq
        bs = (sqrt(bm^2+(bp+bq)^2),sqrt(bm^2+(bp-bq)^2))
        bZ = (bs[1]+bv,bs[2]+bv)
        bL = ntuple(j->log(bZ[j])+2BigFloat(pi)*im*lp.n[j],2)
        ComplexF64.(first(_closed(bA,bB,bv,bs,bZ,bL,order)))
    end
end

end
