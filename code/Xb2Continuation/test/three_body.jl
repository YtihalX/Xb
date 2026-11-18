using Test, Xb2Continuation, HadronDynamics

@testset "Three-body locator S36 and S37" begin
    mass = HadronDynamics.BOchiEFT.Parameters().mpi
    # Independent printed S37 table: tolerance is its 0.01 MeV last digit.
    table = ((119.45, nothing, 135.87, 135.88),
             (103.38, 138.03, 129.85, 129.86))
    for (row,E) in enumerate((-0.02262,0.0)), beta in 1:4
        roots = three_body_roots(0.0,E,ordering(beta),mass;tau=1)
        near = [r.pin for r in roots if r.principal && abs(r.pin)<1]
        expected = table[row][beta]
        if expected === nothing
            @test isempty(near)
        else
            @test length(near) == 2
            for target in (im*expected/1000,-im*expected/1000)
                @test minimum(abs.(near .- target)) <= 0.01/1000
            end
        end
    end
    for po in (0.0,0.3-0.2im), E in (-0.02262,0.0,-0.06785-0.005im), beta in 1:4
        ord = ordering(beta)
        plus = three_body_roots(po,E,ord,mass;tau=1)
        minus = three_body_roots(po,E,ord,mass;tau=-1)
        @test length(plus) == length(minus) == 4
        for root in plus
            @test minimum(abs(root.pin+r.pin) for r in minus) <= 1e-10*max(1,abs(root.pin))
            s = sqrt(complex(mass^2+(po+root.pin)^2))
            v = nu(ord,po,root.pin,E)
            @test abs(root.principal ? s+v : s-v) <= 1e-10*max(1,abs(s),abs(v))
        end
    end
    # No-recoil quadratic and its double root at threshold.
    @test length(three_body_roots(0.0,mass,Ordering(0,0,0),mass)) == 2
    B = HadronDynamics.BOchiEFT
    for channels in (B.channels_1pp(),B.channels_2pp())
        model = B.OMEInteraction(B.Parameters();channels)
        roots = three_body_points(model,1,1,0.3-0.2im,-0.02262-0.005im)
        @test length(roots) == 16
        for r in roots
            v = B.tc_alphas(model,1,1,0.3-0.2im,r.pin,-0.02262-0.005im)[r.ordering]
            s = sqrt(complex(mass^2+(0.3-0.2im+r.sign*r.pin)^2))
            @test abs(r.principal ? s+v : s-v) <= 1e-10*max(1,abs(s),abs(v))
        end
    end
    @test_throws ArgumentError three_body_roots(0,0,ordering(1),mass;tau=0)
end
