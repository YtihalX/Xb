"""A channel threshold and reduced mass, both in GeV (note 07 S2)."""
struct Threshold
    delta::Float64
    mu::Float64
end

function thresholds_2pp(; params=HadronDynamics.BOchiEFT.Parameters())::NTuple{3,Threshold}
    m,v = params.mB,params.mBstar
    (Threshold(0,v/2), Threshold(-(v-m),m*v/(m+v)), Threshold(-2(v-m),m/2))
end

flipped(E::Number, th::Threshold)::Bool = th.delta < real(E)

function sheet_momentum(E::Number, th::Threshold)::ComplexF64
    k = sqrt(ComplexF64(2th.mu*(E-th.delta)))
    if flipped(E,th)
        imag(k) > 0 && (k = -k)
    else
        imag(k) < 0 && (k = -k)
    end
    k
end

"""Polygonal graph path from zero to a real cutoff; momenta use GeV."""
struct GraphPath
    vertices::Vector{ComplexF64}
    function GraphPath(vertices::Vector{ComplexF64})
        length(vertices) >= 2 && first(vertices) == 0 && imag(last(vertices)) == 0 &&
            all(isfinite,vertices) && all(imag(v) <= 0 for v in vertices) &&
            all(real(vertices[j+1]) > real(vertices[j]) for j in 1:length(vertices)-1) ||
            throw(ArgumentError("graph path needs fixed real ends, increasing real parts and nonpositive depths"))
        new(vertices)
    end
end
GraphPath(vertices::AbstractVector{<:Number}) = GraphPath(ComplexF64.(vertices))

struct PathExclusion
    reason::String
end

function _segment_distance(a, b, q)
    v = b-a
    t = clamp(real((q-a)*conj(v))/abs2(v),0.0,1.0)
    abs(q-(a+t*v))
end

function path_distance(path::GraphPath, q::Number)::Float64
    minimum(_segment_distance(path.vertices[j],path.vertices[j+1],q)
            for j in 1:length(path.vertices)-1)
end

function inside_region(path::GraphPath, q::Number)::Bool
    x,y = real(q),imag(q)
    0 < x < real(last(path.vertices)) && y < 0 || return false
    for j in 1:length(path.vertices)-1
        a,b = path.vertices[j],path.vertices[j+1]
        if real(a) <= x <= real(b)
            h = imag(a)+(x-real(a))*imag(b-a)/real(b-a)
            return h < y
        end
    end
    false
end

# Certify the entire one-dimensional vertical energy segment, not only samples.
# The unordered pair ±k is Lipschitz with |dk/dη| ≤ μ/sqrt(2μ|Re E-δ|).
function _vertical_poles_clear(path, E, ths)
    radius = abs(imag(E))
    iszero(radius) && return true
    roundoff = 64eps(Float64)*max(1.0,abs(E),real(last(path.vertices)))
    for th in ths
        speed = th.mu/sqrt(2th.mu*abs(real(E)-th.delta))
        intervals = [(-radius,radius)]
        while !isempty(intervals)
            a,b = pop!(intervals)
            mid = a+(b-a)/2
            k = sqrt(complex(2th.mu*(real(E)-th.delta+im*mid)))
            distance = min(path_distance(path,k),path_distance(path,-k))
            distance > speed*(b-a)/2+roundoff && continue
            distance > roundoff && a < mid < b || return false
            push!(intervals,(a,mid),(mid,b))
        end
    end
    true
end

"""
    graph_path(E, ths; Lambda=4.0, margin)

Build the S40 three-segment graph path, or explain why it is excluded.
The pole margin is in GeV. Certifies pole placement and (P), not Stage-4 (K).
"""
function graph_path(E::Number, ths; Lambda::Real=4.0, margin::Real)::Union{GraphPath,PathExclusion}
    isfinite(E) && isfinite(Lambda) && Lambda > 0 && isfinite(margin) && margin > 0 ||
        throw(ArgumentError("finite energy, positive cutoff and positive pole margin required"))
    isempty(ths) && throw(ArgumentError("at least one channel threshold required"))
    all(th -> isfinite(th.delta) && isfinite(th.mu) && th.mu > 0,ths) ||
        throw(ArgumentError("finite thresholds and positive reduced masses required"))
    L,d = Float64(Lambda),Float64(margin)
    imag(E) <= 0 && any(th -> real(E) == th.delta,ths) &&
        return PathExclusion("threshold equality: Re E equals a channel threshold (S27)")
    ks = [sheet_momentum(E,th) for th in ths]
    fs = [flipped(E,th) for th in ths]
    if imag(E) > 0 || !any(fs)
        path = GraphPath(ComplexF64[0,L])
        all(k -> min(path_distance(path,k),path_distance(path,-k)) >= d,ks) ||
            return PathExclusion("pole margin: real segment approaches a free-resolvent pole")
        return path
    end
    imag(E) < 0 || return PathExclusion("real-axis flipped pole: no open-region sheet placement")
    any(th -> real(E) >= th.delta+L^2/(2th.mu),ths) &&
        return PathExclusion("cutoff: Re E is beyond a channel's finite-cutoff cut (S27)")
    flipped_poles = ks[fs]
    # One upward rounding ensures that subtraction cannot undershoot the margin.
    H = nextfloat(maximum(k -> -imag(k),flipped_poles)+d)
    A = minimum(real,flipped_poles)
    B = maximum(real,flipped_poles)
    # Round the return vertex inward so its floating-point slope is also ≤ 1.
    x2 = prevfloat(L-H)
    H <= A && B <= x2 && H < x2 ||
        return PathExclusion("slope/coverage: depth and flipped-pole coverage require a slope greater than one")
    cap = H-maximum(k -> -imag(k),flipped_poles)
    # The deepest flipped pole bounds the objective by cap on the flat segment.
    # Maximise x1 subject to every flipped pole clearing the incoming leg by cap.
    clears(x) = all(k -> _segment_distance(0,complex(x,-H),k) >= cap,flipped_poles)
    clears(H) || return PathExclusion("pole margin: even the slope-one incoming leg is too close to a flipped pole")
    lo,hi = H,A
    if clears(hi)
        lo = hi
    else
        while nextfloat(lo) < hi
            mid = lo+(hi-lo)/2
            (mid == lo || mid == hi) && break
            clears(mid) ? (lo=mid) : (hi=mid)
        end
    end
    x1 = lo
    x1 < x2 || return PathExclusion("coverage: the flat segment would have zero length")
    path = GraphPath(ComplexF64[0,complex(x1,-H),complex(x2,-H),L])
    for (k,f) in zip(ks,fs)
        inside_region(path,f ? k : -k) == f ||
            return PathExclusion("sheet placement: a pole lies on the wrong side of the graph path")
        min(path_distance(path,k),path_distance(path,-k)) >= d ||
            return PathExclusion("pole margin: no default graph path separates the flipped and unflipped poles")
    end
    _vertical_poles_clear(path,E,ths) ||
        return PathExclusion("vertical (P): cannot certify separation from every moving free-resolvent pole")
    path
end

"""
    path_rule(path::GraphPath, n::Integer)

Gauss–Legendre nodes and oriented complex weights, `n` per polygon segment.
Both vectors use GeV. The weights include `dq/dt`, never its conjugate.
"""
function path_rule(path::GraphPath, n::Integer)::Tuple{Vector{ComplexF64},Vector{ComplexF64}}
    n > 0 || throw(ArgumentError("Gauss–Legendre nodes per segment must be positive"))
    # Reuse the same quadrature provider as HadronDynamics' continuum equations.
    x,w = HadronDynamics.BOchiEFT.ThreeBodyToolkit.gausslegendre(Int(n))
    count = Int(n)*(length(path.vertices)-1)
    nodes = Vector{ComplexF64}(undef,count)
    weights = Vector{ComplexF64}(undef,count)
    index = 0
    for segment in 1:length(path.vertices)-1
        a,b = path.vertices[segment],path.vertices[segment+1]
        v = (b-a)/2
        for j in eachindex(x)
            index += 1
            nodes[index] = a+(x[j]+1)*v
            weights[index] = w[j]*v
        end
    end
    nodes,weights
end
