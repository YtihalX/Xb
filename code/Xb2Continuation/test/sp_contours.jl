# SP tolerances are roundoff operation-count bounds, or independent quadrature
# convergence estimates; the quoted pole fixtures have half-unit last-digit errors.
sp_round(scale=1.0,n=1000) = 16eps(Float64)*n*max(1.0,scale)
function sp_loop(path,E,sheet,ths,a;np=16,beta=0.5)
    q,w = panel_rule(path;np)
    k = principal_momentum(E,ths[a])
    node = only(onshell_nodes(q,w,E,sheet,ths,[a];Lambda=real(last(path.vertices))))
    phi(q) = beta^2/(q^2+beta^2)
    sum(w .* q.^2 .* (2ths[a].mu ./ (q.^2 .- k^2)) .* phi.(q))+node.weight*phi(k)
end
function sp_exact(E,sheet,ths,a;beta=0.5,Lambda=4.0)
    k = principal_momentum(E,ths[a])
    2ths[a].mu*beta^2/(k^2+beta^2)*(k^2*pole_integral(k,sheet.flipped[a];Lambda)+beta*atan(Lambda/beta))
end

@testset "S40 sheets and principal momenta" begin
    ths = thresholds_2pp()
    for bits in Iterators.product((false,true),(false,true),(false,true))
        s = Sheet(bits)
        @test Sheet(sheet_label(s)) == s
        @test Sheet(replace(sheet_label(s),'-'=>'−')) == s
    end
    for E in (-0.1-0.02im,-0.06785-0.01im,-0.02262-0.01im,0.001-0.01im)
        @test adjacent_sheet(E,ths).flipped == Tuple(flipped(E,t) for t in ths)
    end
    for th in ths, E in (th.delta-0.02,th.delta+0.02,th.delta,th.delta-0.01-0.02im,th.delta+0.01-0.02im)
        k = principal_momentum(E,th)
        @test abs(k^2-2th.mu*(E-th.delta)) <= sp_round(abs(k)^2,4)
        @test real(k) >= 0 && imag(k) <= 0
        if isreal(E) && real(E) < th.delta
            @test real(k) == 0 && imag(k) < 0
        elseif isreal(E) && real(E) > th.delta
            @test real(k) > 0 && imag(k) == 0
        end
    end
    @test_throws ArgumentError Sheet("(+,+)")
    @test_throws ArgumentError EnergyRectangle((0,1),(-1,1))
    @test_throws ArgumentError principal_momentum(1im,ths[1])
end

@testset "S40 pole integral and Sokhotski limit" begin
    above = GraphPath([0,4])
    below = GraphPath([0,0.1-0.8im,2-0.8im,4])
    for k in (0.35-0.075im,0.60-0.044im,0.8-0.2im), (path,side) in ((above,false),(below,true))
        coarseq,coarsew = panel_rule(path;Lp=0.04,np=16)
        q,w = panel_rule(path;Lp=0.04,np=32)
        coarse = sum(coarsew./(coarseq.^2 .- k^2))
        fine = sum(w./(q.^2 .- k^2))
        # Doubling estimates the geometric GL tail; 16 ulps per accumulated term.
        tol = 4abs(fine-coarse)+sp_round(sum(abs.(w./(q.^2 .- k^2))),length(q))
        @test abs(fine-pole_integral(k,side)) <= tol
    end
    for k in (0.2,0.6,1.0), side in (false,true)
        @test abs(imag(pole_integral(k,side))-(side ? 1 : -1)*pi/(2k)) <= sp_round(pi/k,8)
        eta = 1e-8
        # First-order continuity bound |I'| <= (|log ratio ± iπ|/k² + 2Λ/(k(Λ²-k²)))/2.
        derivative = (abs(2k*pole_integral(k,side))/k^2+8/(k*(16-k^2)))/2
        @test abs(pole_integral(k-im*eta,side)-pole_integral(k,side)) <= 2eta*derivative
    end
end

@testset "S40 SP path and panel quadrature" begin
    ths = thresholds_2pp()
    for (E,label,expected) in ((-0.02262-0.01im,"(-,-,+)",[0.35423-0.07484im,0.60008-0.04399im]),
                               (-0.06785-0.01im,"(-,+,+)",[0.35348-0.07468im]))
        s = Sheet(label); Q = EnergyRectangle((real(E)-1e-5,real(E)+1e-5),(imag(E)-1e-5,imag(E)+1e-5))
        channels = vertex_channels(Q,s,ths); path = sp_path(E,channels,ths)
        @test path isa GraphPath
        @test all(abs.(path.vertices[2:end-1].-expected) .<= sqrt(2)*0.005e-3)
        for a in 1:3
            !s.flipped[a] && @test !inside_region(path,principal_momentum(E,ths[a]))
        end
        @test maximum(abs.(imag.(diff(path.vertices)))./real.(diff(path.vertices))) <= 1+16eps(Float64)
    end
    for label in ("(+,+,+)","(-,+,+)")
        E = -0.02262-0.005im
        Q = EnergyRectangle((-0.02263,-0.02261),(-0.00501,-0.00499))
        s = Sheet(label)
        @test vertex_channels(Q,s,ths) == [2,3]
        path = sp_path(E,vertex_channels(Q,s,ths),ths)
        @test path isa GraphPath
        for a in (2,3)
            k = principal_momentum(E,ths[a])
            vertex = complex(real(k),-min(abs(imag(k)),real(k)))
            @test path.vertices[a] == vertex
            @test a in vertex_channels(Q,s,ths)
        end
        @test !s.flipped[2]
    end
    path = sp_path(-0.003-0.01im,[1],ths)
    @test imag(path.vertices[2]) == -real(path.vertices[2])
    # A short cutoff makes the final return leg steeper than one.
    @test sp_path(-0.003-0.01im,[1],ths;Lambda=real(path.vertices[2])+0.01) isa PathExclusion
    path = GraphPath([0,0.27-0.19im,0.83-0.19im,1.4])
    np,Lp = 8,0.2
    q,w = panel_rule(path;np,Lp)
    counts = ceil.(Int,abs.(diff(path.vertices))./Lp)
    @test length(q) == np*sum(counts)
    @test abs(sum(w)-1.4) <= sp_round(sum(abs,w),length(q))
    @test all(v->all(!=(v),q),path.vertices)
    start = 1
    for (j,count) in enumerate(counts)
        a,b = path.vertices[j],path.vertices[j+1]
        for panel in 0:count-1
            aa,bb = a+panel*(b-a)/count,a+(panel+1)*(b-a)/count
            @test all(z->0 < real((z-aa)/(bb-aa)) < 1,q[start:start+np-1])
            start += np
        end
    end
    for d in 0:2np-1
        exact = 1.4^(d+1)/(d+1)
        @test abs(sum(w.*q.^d)-exact) <= sp_round(sum(abs.(w.*q.^d)),length(q)+2np)
    end
end

@testset "S40 exact free loops and wrong-side nodes" begin
    ths = thresholds_2pp(); E = -0.02262-0.01im
    k = principal_momentum(E,ths[2])
    paths = (GraphPath([0,4]),GraphPath([0,real(k)-0.05-0.2im,real(k)+0.05-0.2im,4]),
             GraphPath([0,k,4]))
    for bits in Iterators.product((false,true),(false,true),(false,true)), path in paths
        s = Sheet(bits); q,w = panel_rule(path)
        for node in onshell_nodes(q,w,E,s,ths,1:3)
            a,k = node.channel,node.k
            terms = w .* q.^2 .* (2ths[a].mu ./ (q.^2 .- k^2))
            actual = sum(terms)+node.weight
            exact = 2ths[a].mu*(4+k^2*pole_integral(k,s.flipped[a]))
            @test abs(actual-exact) <= sp_round(sum(abs,terms)+abs(node.weight),length(q))
            vals = [sp_loop(path,E,s,ths,a;np=n) for n in (8,16,32)]
            ref = sp_exact(E,s,ths,a)
            @test abs(vals[2]-ref)/abs(ref) <= 1e-12
            @test abs(vals[3]-ref) <= sp_round(abs(ref),length(q))
        end
    end
    q,w = panel_rule(first(paths))
    @test abs(only(onshell_nodes(q,w,E,Sheet("(-,-,+)"),ths,[2])).weight) > 1
end

@testset "S40 zero-momentum node limit" begin
    ths = thresholds_2pp()
    q,w = panel_rule(GraphPath([0,0.2-0.1im,4]))
    for a in 1:3, flipped in (false,true)
        s = Sheet(ntuple(_->flipped,3))
        zero_node = only(onshell_nodes(q,w,ths[a].delta,s,ths,[a]))
        @test zero_node.k == 0
        @test zero_node.weight == 0
        for angle in (0.0,-pi/4,-pi/2)
            k = 1e-6*cis(angle)
            E = complex(ths[a].delta+real(k^2)/(2ths[a].mu),min(0.0,imag(k^2)/(2ths[a].mu)))
            node = only(onshell_nodes(q,w,E,s,ths,[a]))
            r = abs(node.k)
            # |log((Λ-k)/(Λ+k))| <= 2r/(Λ-r), giving an independent
            # O(r) bound for the weight and proving continuity at zero.
            bound = 2ths[a].mu*(pi*r/2+r^2/(4-r)+
                        r^2*sum(abs(w[j])/(abs2(q[j])-r^2) for j in eachindex(q)))
            @test abs(node.weight) <= bound+sp_round(bound,16)*bound
            energy_rounding = 4eps(Float64)*ths[a].mu*max(1,abs(ths[a].delta))/1e-6
            @test abs(r-1e-6) <= energy_rounding
        end
    end
end

@testset "S40 path-piece enclosure soundness" begin
    ths = thresholds_2pp()
    params = BO.Parameters()
    fixtures = ((EnergyRectangle((-0.025,-0.020),(-0.010,-0.005)),Sheet("(-,-,+)")),
                (EnergyRectangle((-0.070,-0.065),(-0.010,-0.005)),Sheet("(-,+,+)")),
                (EnergyRectangle((-0.04540,-0.04535),(-0.00005,0.0)),Sheet("(-,+,+)")))
    for (Q,s) in fixtures
        # Shorter cutoff and deliberately coarse pieces stress the enclosures;
        # every piece is tested, rather than a subset of the production path.
        cert = certify_rectangle(Q,s,ths;Lambda=1.0,qspacing=0.02)
        @test cert isa RectangleCertificate
        cert isa RectangleCertificate || continue
        path = cert.path
        scale = maximum(abs,path.vertices)
        cell = EnergyRectangle((Q.re[1],Q.re[1]+(Q.re[2]-Q.re[1])/8),
                               (Q.im[1],Q.im[1]+(Q.im[2]-Q.im[1])/8))
        energies = (complex(cell.re[1],cell.im[1]),complex(cell.re[1],cell.im[2]),
                    complex(cell.re[2],cell.im[1]),complex(cell.re[2],cell.im[2]),center(cell))
        for a in cert.nodes
            bounds = Xb2Continuation._sp_bounds(cell,ths[a],path)
            ends = [(principal_momentum(E,ths[a]),
                     complex(real(principal_momentum(E,ths[a])),
                             path_height(path,real(principal_momentum(E,ths[a]))))) for E in energies]
            for (aa,bb) in zip(path.vertices[1:end-1],path.vertices[2:end])
                points = range(aa,bb;length=ceil(Int,abs(bb-aa)/0.02)+1)
                for j in 1:length(points)-1
                    left,right = points[j],points[j+1]
                    piece = Xb2Continuation._sp_path_piece(left,right,scale)
                    for outgoing in (true,false), m in (params.mpi,params.meta),
                        beta in (outgoing ? Xb2Continuation._SP_ROWS[a] : Xb2Continuation._SP_COLS[a])
                        o = ordering(beta)
                        lower = Xb2Continuation._sp_piece_bound(bounds,left,right,piece,o,m,cell.re,scale,outgoing)
                        sampled_min = Inf
                        for (E,ps) in zip(energies,ends), p in ps, q in range(left,right;length=50), sign in (-1,1)
                            pout,pin = outgoing ? (p,q) : (q,p)
                            z = sqrt(ComplexF64(m^2+(pout+sign*pin)^2))+nu(o,pout,pin,E)
                            sampled_min = min(sampled_min,real(z))
                        end
                        # Independent evaluations incur complex-product, root and
                        # recoil rounding; allow 32 operations × 16 ulps only.
                        @test lower <= sampled_min+sp_round(abs(sampled_min),32)
                    end
                end
            end
        end
    end
    # Correlated x/y motion makes this whole-piece box inconclusive, while
    # both endpoints pass. Refinement must recover the positive true margin.
    ps = ((x=(0.2,0.2),y=(-0.2,-0.2),sq=(0.0,0.0),graph=false,mu2=0.0,delta=0.0),)
    o = Ordering(-0.12,0.0,0.0)
    aa,bb = 0im,0.2-0.2im
    piece = Xb2Continuation._sp_path_piece(aa,bb,1.0)
    @test Xb2Continuation._sp_path_pair_bound(ps,piece,o,params.mpi,(0.0,0.0),true) <= 0
    @test Xb2Continuation._sp_piece_bound(ps,aa,bb,piece,o,params.mpi,(0.0,0.0),1.0,true) > 0
end

@testset "S40 optional near nodes" begin
    ths = thresholds_2pp()
    fixtures = ((EnergyRectangle((-0.04670,-0.04660),(-0.00040,-0.00030)),Sheet("(-,+,+)"),[3],[2]),
                (EnergyRectangle((-0.00145,-0.00135),(-0.00004,0.0)),Sheet("(-,-,+)"),[2,3],[1]),
                (EnergyRectangle((-0.04540,-0.04535),(-0.00005,0.0)),Sheet("(-,+,+)"),[2,3],Int[]))
    for (index,(Q,s,nodes,dropped)) in enumerate(fixtures)
        cert = certify_rectangle(Q,s,ths)
        @test cert isa RectangleCertificate
        if cert isa RectangleCertificate
            @test cert.nodes == nodes
            @test cert.dropped == dropped
            @test all(a->a in cert.nodes,vertex_channels(Q,s,ths))
            @test cert.clearance > 0
            @test cert.window_margin > 0 && cert.z_margin > 0
            index == 1 && @test 0.060 < cert.clearance < 0.100
            println("S40 optional-node fixture ",index,": ",cert)
        end
    end
end

@testset "S40 rectangle certificates and convergent loops" begin
    ths = thresholds_2pp()
    refs = ((EnergyRectangle((-0.025,-0.020),(-0.010,-0.005)),Sheet("(-,-,+)"),[2,3]),
            (EnergyRectangle((-0.070,-0.065),(-0.010,-0.005)),Sheet("(-,+,+)"),[3]))
    certs = RectangleCertificate[]
    for (Q,s,nodes) in refs
        elapsed = @elapsed cert = certify_rectangle(Q,s,ths)
        @test cert isa RectangleCertificate
        cert isa RectangleCertificate || continue
        push!(certs,cert)
        @test cert.nodes == nodes
        @test cert.slope <= 1+16eps(Float64)
        @test all(x->isfinite(x) && x > 0,(cert.s35_margin,cert.window_margin,cert.z_margin,cert.clearance))
        println("S40 reference certificate: ",cert)
        println("S40 piecewise reference certify runtime = ",elapsed," s")
    end
    for (delta,label) in ((ths[2].delta,"(-,-,+)"),(0.0,"(-,-,+)"),(0.0,"(-,-,-)"))
        cert = certify_rectangle(EnergyRectangle((delta-0.0001,delta+0.0001),(-0.0101,-0.0099)),Sheet(label),ths)
        @test cert isa RectangleCertificate
    end
    # Below-threshold roots need Im(w) in the square-root bound and the common
    # affine energy dependence in nu. Positivity is strict (no tolerance).
    for im_bounds in ((-0.0105,-0.0095),(-0.0025,-0.0015))
        Qbelow = EnergyRectangle((-0.0035,-0.0025),im_bounds)
        cert = certify_rectangle(Qbelow,Sheet("(-,-,-)"),ths)
        @test cert isa RectangleCertificate
        if cert isa RectangleCertificate
            @test cert.z_margin > 0
            println("S40 flipped-below-threshold certificate: ",cert)
        end
    end
    excluded = certify_rectangle(EnergyRectangle((-0.030,-0.028),(-0.002,-0.001)),Sheet("(-,-,-)"),ths)
    @test excluded isa RectangleExclusion
    @test occursin("exchange-window",excluded.reason)
    Ecut = ths[3].delta+(0.04-0.12im)^2/(2ths[3].mu)
    Qcut = EnergyRectangle((real(Ecut)-1e-7,real(Ecut)+1e-7),(imag(Ecut)-1e-7,imag(Ecut)+1e-7))
    cut = certify_rectangle(Qcut,Sheet("(-,+,+)"),ths;Lambda=0.1)
    @test cut isa RectangleExclusion
    @test occursin("node momentum outside the cutoff",cut.reason)

    Qnode = EnergyRectangle((-0.0466,-0.0464),(-0.0002,-0.0001))
    snode = Sheet("(-,-,+)")
    node_exclusion = certify_rectangle(Qnode,snode,ths)
    @test node_exclusion isa RectangleExclusion
    @test startswith(node_exclusion.reason,"C5:")
    # Independently assemble the same piecewise row/column conditions, omitting
    # only node-node pairs: they must pass, so skipping node-node checks would
    # wrongly certify this negative control.
    pathnode = sp_path(center(Qnode),vertex_channels(Qnode,snode,ths),ths)
    xs = range(Qnode.re...;length=9); ys = range(Qnode.im...;length=9)
    rowcol_margin = Inf
    for i in 1:8, j in 1:8
        cell = EnergyRectangle((xs[i],xs[i+1]),(ys[j],ys[j+1]))
        bounds = ntuple(a->Xb2Continuation._sp_bounds(cell,ths[a],pathnode),3)
        for a in (2,3), (aa,bb) in zip(pathnode.vertices[1:end-1],pathnode.vertices[2:end]),
            j in 1:ceil(Int,abs(bb-aa)/0.001)
            step = (bb-aa)/ceil(Int,abs(bb-aa)/0.001)
            left,right = aa+(j-1)*step,aa+j*step
            scale = maximum(abs,pathnode.vertices)
            piece = Xb2Continuation._sp_path_piece(left,right,scale)
            for m in (BO.Parameters().mpi,BO.Parameters().meta)
                for beta in Xb2Continuation._SP_ROWS[a]
                    rowcol_margin = min(rowcol_margin,Xb2Continuation._sp_piece_bound(bounds[a],left,right,piece,ordering(beta),m,cell.re,scale,true))
                end
                for beta in Xb2Continuation._SP_COLS[a]
                    rowcol_margin = min(rowcol_margin,Xb2Continuation._sp_piece_bound(bounds[a],left,right,piece,ordering(beta),m,cell.re,scale,false))
                end
            end
        end
    end
    @test rowcol_margin > 0
    println("S40 node-node negative control: row/column-only margin = ",rowcol_margin)
    nearQ = EnergyRectangle((-0.00011,-0.00009),(-0.00011,-0.00009))
    near = certify_rectangle(nearQ,Sheet("(-,-,+)"),ths)
    @test near isa RectangleCertificate
    if near isa RectangleCertificate
        @test !(1 in vertex_channels(nearQ,near.sheet,ths)) && 1 in near.nodes
        @test near.clearance == Inf
    end
    worst = zeros(3)
    for a in 1:3, offset in (0.00005,0.001)
        E = ths[a].delta+offset-0.01im
        s = adjacent_sheet(E,ths)
        Q = EnergyRectangle((real(E)-1e-6,real(E)+1e-6),(-0.010001,-0.009999))
        cert = certify_rectangle(Q,s,ths)
        @test cert isa RectangleCertificate
        cert isa RectangleCertificate || continue
        for b in 1:3
            ref = sp_exact(E,s,ths,b)
            vals = [sp_loop(cert.path,E,s,ths,b;np=n) for n in (8,16,32)]
            errors = abs.(vals.-ref)./abs(ref)
            worst .= max.(worst,errors)
            @test errors[2] <= 1e-12
            @test errors[3] <= 1e-12
        end
    end
    for cert in certs, a in 1:3
        E = center(cert.rectangle); ref = sp_exact(E,cert.sheet,ths,a)
        @test abs(sp_loop(cert.path,E,cert.sheet,ths,a)-ref)/abs(ref) <= 1e-12
    end
    println("S40 form-factor relative errors np=(8,16,32): ",worst,"; target 1e-12 at np=16; GL tail estimated by doubling")

    Q = refs[1][1]; s = refs[1][2]
    other = certify_rectangle(EnergyRectangle((-0.024,-0.019),(-0.011,-0.006)),s,ths)
    @test other isa RectangleCertificate
    if !isempty(certs) && other isa RectangleCertificate
        E = -0.022-0.008im
        @test certs[1].path.vertices != other.path.vertices
        for a in 1:3
            v1 = sp_loop(certs[1].path,E,s,ths,a); v2 = sp_loop(other.path,E,s,ths,a)
            # Two independently doubled rules plus their roundoff allowances.
            estimate = abs(v1-sp_loop(certs[1].path,E,s,ths,a;np=32))+abs(v2-sp_loop(other.path,E,s,ths,a;np=32))
            @test abs(v1-v2) <= 4estimate+sp_round(abs(v1)+abs(v2),600)
        end
    end
    if !isempty(certs)
        cert = certs[1]; Q = cert.rectangle
        # The center pole is a path vertex, and energies to either side cross it.
        kcenter = principal_momentum(center(Q),ths[2])
        @test path_distance(cert.path,kcenter) <= sp_round(abs(kcenter),8)
        sides = [imag(principal_momentum(complex(real(center(Q)),y),ths[2]))-
                 path_height(cert.path,real(principal_momentum(complex(real(center(Q)),y),ths[2]))) for y in Q.im]
        @test prod(sides) < 0
        function cauchy(n)
            x,w = BO.ThreeBodyToolkit.gausslegendre(n)
            corners = [complex(Q.re[1],Q.im[1]),complex(Q.re[2],Q.im[1]),complex(Q.re[2],Q.im[2]),complex(Q.re[1],Q.im[2])]
            integral,scale = 0im,0.0
            for j in 1:4
                aa,bb = corners[j],corners[mod1(j+1,4)]
                for i in eachindex(x)
                    E = aa+(x[i]+1)*(bb-aa)/2
                    D = 1+0.1sum(sp_loop(cert.path,E,cert.sheet,ths,a) for a in 1:3)
                    integral += w[i]*(bb-aa)/2*D
                    scale += w[i]*abs(bb-aa)/2*abs(D)
                end
            end
            integral,scale
        end
        coarse,_ = cauchy(8); fine,scale = cauchy(16)
        @test abs(fine)/scale <= 1e-10
        @test abs(fine) <= 4abs(fine-coarse)+sp_round(scale,1024)
        println("S40 fixed-path Cauchy relative residual = ",abs(fine)/scale)
    end
end

@testset "S40 quadtree coverage" begin
    ths = thresholds_2pp(); s = Sheet("(-,-,+)")
    region = EnergyRectangle((-0.0466,-0.0456),(-0.0004,0.0))
    floor = 0.0001
    result = tile_rectangles(region,s,ths;initial=(2,1),floor)
    cells = vcat([c.rectangle for c in result.certified],[c.rectangle for c in result.excluded])
    area(Q) = (Q.re[2]-Q.re[1])*(Q.im[2]-Q.im[1])
    @test !isempty(cells)
    @test !isempty(result.certified) && !isempty(result.excluded)
    @test all(Q->region.re[1] <= Q.re[1] < Q.re[2] <= region.re[2] &&
                 region.im[1] <= Q.im[1] < Q.im[2] <= region.im[2],cells)
    @test abs(sum(area,cells)-area(region)) <= sp_round(area(region),length(cells))*area(region)
    @test all(c->max(c.rectangle.re[2]-c.rectangle.re[1],c.rectangle.im[2]-c.rectangle.im[1]) < floor,result.excluded)
    for i in eachindex(cells), j in i+1:length(cells)
        a,b = cells[i],cells[j]
        @test min(a.re[2],b.re[2]) <= max(a.re[1],b.re[1]) || min(a.im[2],b.im[2]) <= max(a.im[1],b.im[1])
    end
end
