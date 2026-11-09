# Independent S44 reference for checks/rank_one_paths.jl; all quantities in GeV.
# Channel order is (1,5,6) = (VV,PV,PP), NOT ascending threshold/sheet-label order.
using HadronDynamics: BOchiEFT
using Printf

const R1_CUTOFF = 4.0
const R1_WEAK_LAMBDA = 0.05 # GeV^-2; the scan explicitly checks |lambda sum f| < 1.
const R1_SAFETY = 4.0 # conservative allowance on the last node-doubling correction

function r1_thresholds()
    p = BOchiEFT.Parameters()
    gap = p.mBstar - p.mB
    ((delta=0.0, mu=p.mBstar / 2),
     (delta=-gap, mu=p.mB * p.mBstar / (p.mB + p.mBstar)),
     (delta=-2gap, mu=p.mB / 2))
end

function r1_root(E, th; physical=false)
    k = sqrt(complex(2th.mu * (E - th.delta)))
    lower = !physical && th.delta < real(E)
    (lower ? imag(k) > 0 : imag(k) < 0) && (k = -k)
    k
end

function r1_f(k, mu)
    mu / pi^2 * (R1_CUTOFF + k / 2 *
        (log((R1_CUTOFF - k) / (R1_CUTOFF + k)) + im * pi))
end

# Differentiate the analytic reference, not the numerical path expression.
function r1_derivatives(k, mu)
    L = R1_CUTOFF
    A = (log((L - k) / (L + k)) + im * pi) / 2 - k * L / (L^2 - k^2)
    Ap = -2L^3 / (L^2 - k^2)^2
    (mu^2 / (pi^2 * k) * A, mu^3 / pi^2 * (Ap / k^2 - A / k^3))
end

r1_loops(E, ths; physical=false) =
    [r1_f(r1_root(E, th; physical), th.mu) for th in ths]
r1_t(F, lambda=R1_WEAK_LAMBDA, g2=(1.0, 1.0, 1.0)) =
    inv(inv(lambda) + sum(g2[a] * F[a] for a in 1:3))

function r1_probes()
    # The six extra probes are distinct from the integer-MeV grid.
    [ComplexF64[(x - 10im) / 1000 for x in -88:45];
     ComplexF64[(x - y * im) / 1000 for x in (-67.85, -22.62) for y in (1, 10, 50)]]
end

function r1_assert(ok, name, details="")
    println(ok ? "PASS " : "FAIL ", name, isempty(details) ? "" : ": " * details)
    ok || error(name)
end

function r1_closed_checks()
    ths = r1_thresholds()
    probes = r1_probes()
    @printf("Independent masses: thresholds (VV,PV,PP) = (%.8f, %.8f, %.8f) MeV; mu = (%.9f, %.9f, %.9f) GeV\n",
        (1000th.delta for th in ths)..., (th.mu for th in ths)...)
    roots_ok = all(probes) do E
        all(ths) do th
            k = r1_root(E, th)
            isapprox(k^2, 2th.mu * (E - th.delta); rtol=16eps()) &&
                (th.delta < real(E) ? imag(k) < 0 : imag(k) > 0)
        end
    end
    r1_assert(roots_ok, "independent S27 roots on all 140 probe energies")
    strength = maximum(abs(R1_WEAK_LAMBDA * sum(r1_loops(E, ths))) for E in probes)
    r1_assert(strength < 1, "weak coupling has no zero at any scan point",
        @sprintf("lambda=%.6f GeV^-2; max |lambda sum f|=%.9f; |D| >= %.9f", R1_WEAK_LAMBDA, strength, 1-strength))
    Ep = (-22.62 - 5im) / 1000
    Fp = r1_loops(Ep, ths)
    g2 = -imag(Fp[1]) / imag(Fp[2] + Fp[3])
    lambda = inv(-real(Fp[1]) - g2 * real(Fp[2] + Fp[3]))
    r1_assert(g2 > 0 && isfinite(lambda), "real resonance coupling exists",
        @sprintf("g^2=%.12g, g=%.12g, lambda=%.12g GeV^-2", g2, sqrt(g2), lambda))
    Dp = 1 + lambda * sum((1.0, g2, g2) .* Fp)
    tol = 64eps() * (1 + abs(lambda) * sum(abs.((1.0, g2, g2) .* Fp)))
    r1_assert(abs(Dp) <= tol, "closed form has prescribed 10 MeV-width pole", "|D(Ep)|=$(abs(Dp)); rounding bound=$tol")
    for x in (-67.85, -22.62, 20.0)
        E = complex(x / 1000, 0.0)
        F = r1_loops(E, ths; physical=true)
        rho = sum(th.mu * real(r1_root(E, th; physical=true)) / (2pi)
            for th in ths if th.delta < real(E))
        residual = abs(imag(inv(R1_WEAK_LAMBDA) + sum(F)) - rho)
        tol = 64eps() * sum(abs, F)
        r1_assert(rho > 0 && residual <= tol, "physical +i rho at Re E=$x MeV",
            "rho=$rho GeV^2, residual=$residual, rounding bound=$tol")
        # Independent finite-difference check of the derivative used in error estimates.
        h = cbrt(eps()) * minimum(abs(real(E) - th.delta) for th in ths)
        S1 = sum(first(r1_derivatives(r1_root(E, th; physical=true), th.mu)) for th in ths)
        numerical = (sum(r1_loops(E + h, ths; physical=true)) - sum(r1_loops(E - h, ths; physical=true))) / (2h)
        # Central difference truncates O(h^2), subtraction rounds O(eps/h).
        derivative_tol = 32 * (h^2 / minimum(abs(real(E) - th.delta) for th in ths)^2 * abs(S1) +
            eps() * sum(abs, F) / h)
        r1_assert(abs(S1 - numerical) <= derivative_tol, "closed derivative at Re E=$x MeV",
            "residual=$(abs(S1-numerical)); central-difference/rounding estimate=$derivative_tol")
    end
    (ths=ths, probes=probes, Ep=Ep, g2=(1.0, g2, g2), lambda=lambda)
end

# Ray crossing on the closed polygon C followed by Lambda -> 0 on the real axis.
# This deliberately does not call the package's inside_region implementation.
function r1_inside(vertices, z)
    winding = false
    for i in eachindex(vertices)
        a, b = vertices[i], vertices[mod1(i + 1, length(vertices))]
        if (imag(a) > imag(z)) != (imag(b) > imag(z))
            xcross = real(a) + (imag(z) - imag(a)) * real(b - a) / imag(b - a)
            real(z) < xcross && (winding = !winding)
        end
    end
    winding
end

function r1_distance(vertices, z)
    best = Inf
    for i in 1:length(vertices)-1
        a, b = vertices[i], vertices[i+1]
        d, r = b - a, z - a
        t = clamp((real(r) * real(d) + imag(r) * imag(d)) / abs2(d), 0.0, 1.0)
        best = min(best, abs(z - (a + t*d)))
    end
    best
end

# Exact quadratic intersection test of Re[delta + q(t)^2/(2mu)] = Re E.
# At its real roots inspect Im E; no energy/homotopy sampling is needed.
function r1_vertical_clear(vertices, E, ths)
    for th in ths, i in 1:length(vertices)-1
        a, d = vertices[i], vertices[i+1] - vertices[i]
        A, B = real(d^2), 2real(a*d)
        C = real(a^2) - 2th.mu * (real(E) - th.delta)
        roots = if abs(A) <= 16eps() * abs2(d)
            abs(B) > 0 ? [-C/B] : Float64[]
        else
            discriminant = B^2 - 4A*C
            discriminant < 0 ? Float64[] : [(-B - sqrt(discriminant))/(2A), (-B + sqrt(discriminant))/(2A)]
        end
        for t in roots
            if 0 <= t <= 1
                y = imag((a + t*d)^2) / (2th.mu)
                abs(y) <= abs(imag(E)) && return false
            end
        end
    end
    true
end
