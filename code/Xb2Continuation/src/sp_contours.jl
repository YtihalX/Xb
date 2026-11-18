"""Sheet signs indexed VV, PV, PP; string labels instead use PP, PV, VV."""
struct Sheet
    flipped::NTuple{3,Bool}
end
function Sheet(label::AbstractString)
    s = replace(label, '−'=>'-', r"\s"=>"")
    occursin(r"^\([+-],[+-],[+-]\)$",s) || throw(ArgumentError("sheet label must be (±,±,±)"))
    Sheet(Tuple(reverse([c == '-' for c in s if c in ('+','-')])))
end
sheet_label(s::Sheet)::String = "(" * join((b ? "-" : "+" for b in reverse(s.flipped)),",") * ")"
adjacent_sheet(E::Number,ths)::Sheet = Sheet(ntuple(a->flipped(E,ths[a]),3))
function principal_momentum(E::Number,th::Threshold)::ComplexF64
    isfinite(E) && imag(E) <= 0 && isfinite(th.delta) && isfinite(th.mu) && th.mu > 0 ||
        throw(ArgumentError("principal momentum needs finite lower-half-plane energy and positive mass"))
    sqrt(complex(2th.mu*(real(E)-th.delta), imag(E) == 0 ? -0.0 : 2th.mu*imag(E)))
end
function pole_integral(k::Number,below::Bool;Lambda::Real=4.0)::ComplexF64
    isfinite(Lambda) && Lambda > 0 && isfinite(k) && 0 < abs(k) < Lambda && real(k) >= 0 && imag(k) <= 0 ||
        throw(ArgumentError("pole must be nonzero in the closed fourth quadrant inside the cutoff"))
    (log(ComplexF64((Lambda-k)/(Lambda+k))) + (below ? 1 : -1)*im*pi)/(2k)
end
function path_height(path::GraphPath,x::Real)::Float64
    0 <= x <= real(last(path.vertices)) || return 0.0
    j = 1
    while j < length(path.vertices)-1 && real(path.vertices[j+1]) <= x
        j += 1
    end
    a,b = path.vertices[j],path.vertices[j+1]
    imag(a)+(x-real(a))*imag(b-a)/real(b-a)
end
struct EnergyRectangle
    re::NTuple{2,Float64}
    im::NTuple{2,Float64}
    function EnergyRectangle(re::Tuple{Real,Real},im::Tuple{Real,Real})
        all(isfinite,(re...,im...)) && re[1] < re[2] && im[1] < im[2] <= 0 ||
            throw(ArgumentError("rectangle needs ordered finite bounds in the lower half-plane"))
        new(Float64.(re),Float64.(im))
    end
end
center(Q::EnergyRectangle)::ComplexF64 = complex(sum(Q.re)/2,sum(Q.im)/2)
vertex_channels(Q::EnergyRectangle,sheet::Sheet,ths)::Vector{Int} =
    [a for a in 1:3 if sheet.flipped[a] || ths[a].delta < Q.re[2]]
function sp_path(Ec::Number,channels::AbstractVector{<:Integer},ths;Lambda::Real=4.0)::Union{GraphPath,PathExclusion}
    isfinite(Lambda) && Lambda > 0 || throw(ArgumentError("cutoff must be positive and finite"))
    all(a->1 <= a <= length(ths),channels) || throw(ArgumentError("invalid channel"))
    vertices = ComplexF64[]
    for a in channels
        k = principal_momentum(Ec,ths[a])
        0 < real(k) < Lambda || return PathExclusion("vertex outside the finite cutoff")
        push!(vertices,complex(real(k),-min(abs(imag(k)),real(k))))
    end
    sort!(vertices;by=real)
    any(j->real(vertices[j]) == real(vertices[j+1]),1:length(vertices)-1) &&
        return PathExclusion("equal vertex real parts")
    path = GraphPath(vcat(0im,vertices,ComplexF64(Lambda)))
    _sp_slope(path) <= 1+16eps(Float64) || return PathExclusion("C1: segment slope exceeds one")
    path
end
_sp_slope(path) = maximum(abs(imag(b-a))/real(b-a) for (a,b) in zip(path.vertices[1:end-1],path.vertices[2:end]))
function panel_rule(path::GraphPath;Lp::Real=0.25,np::Integer=16)::Tuple{Vector{ComplexF64},Vector{ComplexF64}}
    isfinite(Lp) && Lp > 0 && np > 0 || throw(ArgumentError("panel length and node count must be positive"))
    x,w = HadronDynamics.BOchiEFT.ThreeBodyToolkit.gausslegendre(Int(np))
    counts = [max(1,ceil(Int,abs(b-a)/Lp)) for (a,b) in zip(path.vertices[1:end-1],path.vertices[2:end])]
    q = Vector{ComplexF64}(undef,np*sum(counts)); weights = similar(q)
    index = 0
    for j in eachindex(counts)
        a,b = path.vertices[j],path.vertices[j+1]
        step = (b-a)/counts[j]
        for panel in 0:counts[j]-1, i in eachindex(x)
            index += 1
            q[index] = a+panel*step+(x[i]+1)*step/2
            weights[index] = w[i]*step/2
        end
    end
    q,weights
end
struct OnShellNode
    channel::Int
    k::ComplexF64
    flipped::Bool
    weight::ComplexF64
end
function onshell_nodes(q,w,E::Number,sheet::Sheet,ths,channels;Lambda::Real=4.0)::Vector{OnShellNode}
    length(q) == length(w) || throw(ArgumentError("nodes and weights must have equal lengths"))
    [begin
        k = principal_momentum(E,ths[a]); side = sheet.flipped[a]
        weight = iszero(k) ? 0im : 2ths[a].mu*k^2*(pole_integral(k,side;Lambda)-sum(w[j]/(q[j]^2-k^2) for j in eachindex(q)))
        OnShellNode(a,k,side,weight)
    end for a in channels]
end
struct RectangleCertificate
    rectangle::EnergyRectangle
    sheet::Sheet
    path::GraphPath
    nodes::Vector{Int}
    dropped::Vector{Int}
    slope::Float64
    s35_margin::Float64
    window_margin::Float64
    z_margin::Float64
    clearance::Float64
end
struct RectangleExclusion
    rectangle::EnergyRectangle
    sheet::Sheet
    reason::String
end

# Outward-rounded interval operations. Coordinates enclose all energies in a cell;
# squares of k use the exact energy identity rather than independent x/y bounds.
_sp_out(lo,hi) = (prevfloat(Float64(lo)),nextfloat(Float64(hi)))
# Enclose evaluations assembled outside the primitive interval operations
# (complex roots, interpolation, path sampling, and geometric distances).
_sp_error(scale) = nextfloat(64eps(Float64)*max(1.0,scale))
_sp_pad(lo,hi,scale) = _sp_out(lo-_sp_error(scale),hi+_sp_error(scale))
_sp_add(a,b) = _sp_out(a[1]+b[1],a[2]+b[2])
_sp_sub(a,b) = _sp_out(a[1]-b[2],a[2]-b[1])
_sp_square(a) = _sp_out(a[1] <= 0 <= a[2] ? 0.0 : min(a[1]^2,a[2]^2),max(a[1]^2,a[2]^2))
_sp_scale(c,a) = c >= 0 ? _sp_out(c*a[1],c*a[2]) : _sp_out(c*a[2],c*a[1])
function _sp_height_bounds(path,x)
    lo,hi = minmax(path_height(path,x[1]),path_height(path,x[2]))
    for v in path.vertices
        if x[1] <= real(v) <= x[2]
            lo = min(lo,imag(v)); hi = max(hi,imag(v))
        end
    end
    _sp_pad(lo,hi,max(abs(x[1]),abs(x[2]),maximum(abs,path.vertices)))
end
function _sp_bounds(Q,th,path)
    k1 = principal_momentum(complex(Q.re[1],Q.im[2]),th)
    k2 = principal_momentum(complex(Q.re[2],Q.im[1]),th)
    k3 = principal_momentum(complex(Q.re[1],Q.im[1]),th)
    k4 = principal_momentum(complex(Q.re[2],Q.im[2]),th)
    scale = max(abs(k1),abs(k2),abs(k3),abs(k4),abs(th.delta),th.mu,
                maximum(abs,Q.re),maximum(abs,Q.im),maximum(abs,path.vertices))
    x = _sp_pad(real(k1),real(k2),scale)
    y = _sp_pad(imag(k3),imag(k4),scale)
    h = _sp_height_bounds(path,x)
    ks = _sp_scale(2th.mu,_sp_sub(Q.re,(th.delta,th.delta)))
    cs = _sp_sub(_sp_square(x),_sp_square(h))
    ((x=x,y=h,sq=cs,graph=true,mu2=0.0,delta=0.0),
     (x=x,y=y,sq=ks,graph=false,mu2=2th.mu,delta=th.delta))
end
function _sp_distance(path,p)
    mid = complex(sum(p.x)/2,sum(p.y)/2)
    scale = max(abs(mid),maximum(abs,path.vertices),maximum(abs,p.x),maximum(abs,p.y))
    lower = path_distance(path,mid)-hypot(p.x[2]-p.x[1],p.y[2]-p.y[1])/2
    max(0.0,_sp_pad(lower,lower,scale)[1])
end
# Keep the imaginary part when Re w is negative. The rationalized expression
# avoids cancellation in hypot(a,c)+a; every operation rounds outwards.
_sp_minabs(x) = x[1] <= 0 <= x[2] ? 0.0 : min(abs(x[1]),abs(x[2]))
function _sp_root_bound(a,c)
    if a < 0
        denominator = nextfloat(sqrt(nextfloat(2nextfloat(nextfloat(hypot(a,c))-a))))
        return max(0.0,prevfloat(c/denominator))
    end
    max(0.0,prevfloat(sqrt(max(0.0,prevfloat(prevfloat(hypot(a,c))+a)/2))))
end

# Preserve the common Re E dependence of all k-ends before evaluating the two
# energy edges. Graph ends retain interval square bounds, including c-ends.
function _sp_nu_bound(p,q,o,re)
    coefficient = (-1.0,-1.0)
    constant = (o.t,o.t)
    for (endpt,recoil) in ((p,o.h),(q,o.a))
        if endpt.graph
            constant = _sp_add(constant,_sp_scale(recoil,endpt.sq))
        else
            c = _sp_scale(recoil,(endpt.mu2,endpt.mu2))
            coefficient = _sp_add(coefficient,c)
            constant = _sp_sub(constant,_sp_scale(endpt.delta,c))
        end
    end
    lower = min(_sp_add(constant,_sp_scale(re[1],coefficient))[1],
                _sp_add(constant,_sp_scale(re[2],coefficient))[1])
    _sp_pad(lower,lower,max(abs(o.t),abs(o.h),abs(o.a),maximum(abs,re),
                           maximum(abs,p.sq),maximum(abs,q.sq)))[1]
end
function _sp_pair_bound(ps,qs,o,m,re)
    sn,nmin = Inf,Inf
    for p in ps, q in qs
        for sign in (-1,1)
            x = _sp_add(p.x,_sp_scale(sign,q.x)); y = _sp_add(p.y,_sp_scale(sign,q.y))
            w = _sp_add(_sp_out(m^2,m^2),_sp_sub(_sp_square(x),_sp_square(y)))
            c = max(0.0,prevfloat(2prevfloat(_sp_minabs(x)*_sp_minabs(y))))
            s = p.graph && q.graph ? m : _sp_root_bound(w[1],c)
            sn = min(sn,s)
        end
        nmin = min(nmin,_sp_nu_bound(p,q,o,re))
    end
    prevfloat(sn+nmin)
end

# A straight path piece has affine height, so endpoint coordinate intervals
# enclose every q on it. Squaring these intervals encloses Re(q^2) throughout.
function _sp_path_piece(a,b,scale)
    x = _sp_pad(min(real(a),real(b)),max(real(a),real(b)),scale)
    y = _sp_pad(min(imag(a),imag(b)),max(imag(a),imag(b)),scale)
    (x=x,y=y,sq=_sp_sub(_sp_square(x),_sp_square(y)),
     graph=true,mu2=0.0,delta=0.0)
end
_sp_path_pair_bound(ps,piece,o,m,re,outgoing) = outgoing ?
    _sp_pair_bound(ps,(piece,),o,m,re) : _sp_pair_bound((piece,),ps,o,m,re)

function _sp_piece_bound(ps,a,b,piece,o,m,re,scale,outgoing)
    lower = _sp_path_pair_bound(ps,piece,o,m,re,outgoing)
    lower > 0 && return lower
    abs(b-a) <= 1e-5 && return lower
    # Subdivide only a geometric enclosure failure, not a failed endpoint.
    first_bound = _sp_path_pair_bound(ps,_sp_path_piece(a,a,scale),o,m,re,outgoing)
    last_bound = _sp_path_pair_bound(ps,_sp_path_piece(b,b,scale),o,m,re,outgoing)
    min(first_bound,last_bound) > 0 || return lower
    midpoint = a+(b-a)/2
    left = _sp_piece_bound(ps,a,midpoint,_sp_path_piece(a,midpoint,scale),o,m,re,scale,outgoing)
    right = _sp_piece_bound(ps,midpoint,b,_sp_path_piece(midpoint,b,scale),o,m,re,scale,outgoing)
    min(left,right)
end
const _SP_ROWS = ((2,3),(1,2,4),(4,))
const _SP_COLS = ((2,4),(1,2,3),(3,))
const _SP_BLOCKS = (((2,2),(2,3),(3,3)),((2,4),(1,2),()),((4,4),(),()))
"""Certify C1–C5 over energy sub-cells and whole straight path pieces."""
function certify_rectangle(Q::EnergyRectangle,sheet::Sheet,ths;Lambda=4.0,r_near=0.1,n_sub=8,qspacing=0.001,
                           params=HadronDynamics.BOchiEFT.Parameters())::Union{RectangleCertificate,RectangleExclusion}
    isfinite(r_near) && r_near > 0 && n_sub isa Integer && n_sub > 0 && isfinite(qspacing) && qspacing > 0 ||
        throw(ArgumentError("positive near radius, integer subdivisions and path spacing required"))
    reject(reason) = RectangleExclusion(Q,sheet,reason)
    vertices = vertex_channels(Q,sheet,ths)
    path = sp_path(center(Q),vertices,ths;Lambda)
    path isa PathExclusion && return reject(path.reason)
    H = -minimum(imag,path.vertices)
    orders = ntuple(b->ordering(b;params),4)
    s35_value = minimum(m+o.t-(o.h+o.a)*H^2-Q.re[2] for m in (params.mpi,params.meta), o in orders)
    s35 = _sp_pad(s35_value,s35_value,max(params.mpi,params.meta,H^2,maximum(abs,Q.re),
                                       maximum(o->max(abs(o.t),abs(o.h),abs(o.a)),orders)))[1]
    s35 > 0 || return reject("C2: S35 margin is nonpositive")
    xs = range(Q.re...;length=n_sub+1); ys = range(Q.im...;length=n_sub+1)
    cells = [EnergyRectangle((xs[i],xs[i+1]),(ys[j],ys[j+1])) for i in 1:n_sub for j in 1:n_sub]
    bounds = [ntuple(a->_sp_bounds(cell,ths[a],path),3) for cell in cells]
    distances = [minimum(_sp_distance(path,b[a][2]) for b in bounds) for a in 1:3]
    optional = [a for a in 1:3 if !(a in vertices) && distances[a] < r_near]
    nodes = [a for a in 1:3 if a in vertices || a in optional]
    windows = fill(Inf,3)
    for b in bounds, a in nodes
        delta = _sp_sub(b[a][2].y,b[a][1].y)
        windows[a] = min(windows[a],prevfloat(params.mpi-max(abs(delta[1]),abs(delta[2]))))
    end
    path_scale = maximum(abs,path.vertices)
    pieces = Tuple{ComplexF64,ComplexF64,typeof(_sp_path_piece(0im,0im,path_scale))}[]
    for (a,b) in zip(path.vertices[1:end-1],path.vertices[2:end])
        points = range(a,b;length=max(1,ceil(Int,abs(b-a)/qspacing))+1)
        for j in 1:length(points)-1
            aa,bb = points[j],points[j+1]
            push!(pieces,(aa,bb,_sp_path_piece(aa,bb,path_scale)))
        end
    end
    rowcols = fill(Inf,3)
    pairs = fill(Inf,3,3)
    for (cell,bounds_cell) in zip(cells,bounds)
        for a in nodes, (aa,bb,piece) in pieces
            for m in (params.mpi,params.meta)
                for beta in _SP_ROWS[a]
                    rowcols[a] = min(rowcols[a],_sp_piece_bound(bounds_cell[a],aa,bb,piece,orders[beta],m,cell.re,path_scale,true))
                end
                for beta in _SP_COLS[a]
                    rowcols[a] = min(rowcols[a],_sp_piece_bound(bounds_cell[a],aa,bb,piece,orders[beta],m,cell.re,path_scale,false))
                end
            end
        end
        for a in nodes, b in nodes, beta in _SP_BLOCKS[a][b], m in (params.mpi,params.meta)
            pairs[a,b] = min(pairs[a,b],_sp_pair_bound(bounds_cell[a],bounds_cell[b],orders[beta],m,cell.re))
        end
    end
    dropped = Int[]
    while true
        failing = [a for a in nodes if a in optional &&
                   (windows[a] <= 0 || rowcols[a] <= 0 ||
                    any(b->min(pairs[a,b],pairs[b,a]) <= 0,nodes))]
        isempty(failing) && break
        append!(dropped,failing)
        filter!(a->!(a in failing),nodes)
    end
    sort!(dropped)
    for b in bounds, a in nodes
        p = b[a][2]
        maxk = nextfloat(hypot(maximum(abs,p.x),maximum(abs,p.y)))
        maxk < Lambda || return reject("C1: node momentum outside the cutoff")
    end
    any(a->distances[a] <= 0,dropped) && return reject("C3: dropped near pole touches the path")
    clearance = minimum((distances[a] for a in 1:3 if !(a in nodes));init=Inf)
    window = minimum((windows[a] for a in nodes);init=Inf)
    window > 0 || return reject("C4: exchange-window margin is nonpositive")
    zmargin = min(minimum((rowcols[a] for a in nodes);init=Inf),
                  minimum((pairs[a,b] for a in nodes for b in nodes);init=Inf))
    zmargin > 0 || return reject("C5: piecewise Re Z bound is nonpositive")
    RectangleCertificate(Q,sheet,path,nodes,dropped,_sp_slope(path),s35,window,zmargin,clearance)
end
function tile_rectangles(region::EnergyRectangle,sheet::Sheet,ths;initial=(1,1),floor=1e-4,kwargs...)
    length(initial) == 2 && all(n->n isa Integer && n > 0,initial) && isfinite(floor) && floor > 0 ||
        throw(ArgumentError("positive initial grid and floor required"))
    certified = RectangleCertificate[]; excluded = RectangleExclusion[]
    function visit(Q)
        result = certify_rectangle(Q,sheet,ths;kwargs...)
        if result isa RectangleCertificate
            push!(certified,result)
        elseif max(Q.re[2]-Q.re[1],Q.im[2]-Q.im[1]) < floor
            push!(excluded,result)
        else
            x,y = real(center(Q)),imag(center(Q))
            for re in ((Q.re[1],x),(x,Q.re[2])), im in ((Q.im[1],y),(y,Q.im[2]))
                visit(EnergyRectangle(re,im))
            end
        end
    end
    xs = range(region.re...;length=initial[1]+1); ys = range(region.im...;length=initial[2]+1)
    for i in 1:initial[1], j in 1:initial[2]
        visit(EnergyRectangle((xs[i],xs[i+1]),(ys[j],ys[j+1])))
    end
    (certified=certified,excluded=excluded)
end
