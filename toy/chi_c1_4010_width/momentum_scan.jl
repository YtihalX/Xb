# Toy extension: psi_2(0), and the golden-rule width when only the decay momentum varies.
# Run: julia --project=checks toy/chi_c1_4010_width/momentum_scan.jl
# M stays at the central 4012.5 MeV in the width's prefactor; GeV inside, MeV in the output.
include("run.jl")   # inputs, psi_pkg, width; prints the base toy output first

psi2_of(p) = psi_pkg(p)[2]
width_at(p) = width(psi2_of(p), p)                 # Gamma(p) at fixed M
mass_of(p) = sqrt(mD^2 + p^2) + sqrt(mDs^2 + p^2)  # mass whose decay momentum is p

function golden_min(f, lo, hi; tol=1e-10)          # minimum of a unimodal f on [lo, hi]
    r = (sqrt(5) - 1) / 2
    c, d = hi - r * (hi - lo), lo + r * (hi - lo)
    fc, fd = f(c), f(d)
    while hi - lo > tol
        if fc < fd
            hi, d, fd = d, c, fc
            c = hi - r * (hi - lo); fc = f(c)
        else
            lo, c, fc = c, d, fd
            d = lo + r * (hi - lo); fd = f(d)
        end
    end
    return (lo + hi) / 2
end
# local minima of f on a 1 MeV scan of the interpolated range 0..6 GeV, refined
function local_minima(f; scan=range(0.0, 6.0, length=6001))
    v = f.(scan)
    return [golden_min(f, scan[i-1], scan[i+1]) for i in 2:length(scan)-1 if v[i] < v[i-1] && v[i] <= v[i+1]]
end

gamma_max = local_minima(p -> -width_at(p))       # local maxima of Gamma(p) at fixed M
psi2_min = local_minima(psi2_of)                   # local minima of psi_2

println()
@printf("psi_2(0) = %+.4f GeV^-3/2, f_2(0) = psi_2(0)/sqrt(4pi) = %+.4f GeV^-3/2\n",
        psi2_of(0.0), psi2_of(0.0) / sqrt(4pi))
@printf("Only p varied, M = %.1f MeV in the prefactor; local maxima of Gamma(p) on 0..6000 MeV:\n", 1e3M)
@printf("  p (MeV)   psi_2 (GeV^-3/2)   Gamma (MeV)   mass with this decay momentum (MeV; threshold %.1f)\n",
        1e3(mD + mDs))
for p in gamma_max
    @printf("  %7.1f   %+10.3f         %7.2f       %7.1f\n", 1e3p, psi2_of(p), 1e3width_at(p), 1e3mass_of(p))
end
for p in psi2_min
    @printf("Minimum of psi_2: %+.3f GeV^-3/2 at p = %.1f MeV; Gamma there %.2f MeV; mass %.1f MeV\n",
            psi2_of(p), 1e3p, 1e3width_at(p), 1e3mass_of(p))
end
