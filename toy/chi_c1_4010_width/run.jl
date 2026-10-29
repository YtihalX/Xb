# Toy: Gamma[chi_c1(4010) -> D Dbar*] from the LO compact-continuum vertex, with the
# Cornell 2P wave function in place of the lambda^(-3/2) estimate of followup.tex.
# Run: julia --project=checks toy/chi_c1_4010_width/run.jl     (GeV natural units)
using HadronDynamics, LinearAlgebra, Printf
const B = HadronDynamics.BOchiEFT

# Inputs
const mc    = 1.328                   # followup.tex, charm repeat of Zhang:2026iyr
const sigma = 0.19840639309997352     # Zhang:2026iyr baseline static potential (flavour independent)
const gamma = -0.434
const V0    = -0.036                  # followup.tex; enters only the bare masses printed below
const g     = B.compact_coupling(B.Parameters(); convention=:corrected)  # 2*sqrt(2/3)*g_l
const M     = 4.0125                  # LHCb:2024vfz, chi_c1(4010) mass
const dM    = sqrt(3.9^2 + 4.1^2) / 1000   # larger stat (+) syst error, combined in quadrature
const mD    = (1.86484 + 1.86966) / 2 # PDG D0, D+ ; isospin average
const mDs   = (2.00685 + 2.01026) / 2 # PDG D*0, D*+
const mu    = mD * mDs / (mD + mDs)

kallen(a, b, c) = a^2 + b^2 + c^2 - 2a * b - 2b * c - 2c * a
pdecay(m) = sqrt(kallen(m^2, mD^2, mDs^2)) / (2m)

# Package route: form_factors_at returns sqrt(4pi) * int r^2 j0(pr) R_1n dr = psi_n(p)/sqrt(4pi)
ff = B.form_factors(mb=mc, sigma=sigma, gamma=gamma, backend=:coordinate, nstates=2)
psi_pkg(p) = sqrt(4pi) .* real.(B.form_factors_at(ff, p))

# Independent route: finite-difference radial solve, L = 1, reduced mass mc/2, u = r R
function fd_solve(; N=20000, rmax=30.0)
    h = rmax / (N + 1)
    r = h .* (1:N)
    d = 2 / (mc * h^2) .+ 2 ./ (mc .* r .^ 2) .+ sigma .* r .+ gamma ./ r
    vals, vecs = eigen(SymTridiagonal(d, fill(-1 / (mc * h^2), N - 1)), 1:2)
    u = vecs ./ sqrt(h)                               # int u^2 dr = 1
    psi(p) = [4pi / p * h * sum(u[:, n] .* sin.(p .* r)) for n in 1:2]  # 4pi int r^2 j0 R dr
    return vals, psi
end
fd_E, psi_fd = fd_solve()

# Width: g_rel = sqrt(2M 2mD 2mD*) g psi/sqrt(4pi);  Gamma = g_rel^2 p / (8 pi M^2)
grel(psi; m=M) = sqrt(8m * mD * mDs) * g * psi / sqrt(4pi)
width(psi, p; m=M) = grel(psi; m=m)^2 * p / (8pi * m^2)
width_nr(psi, p) = mu * p * g^2 * psi^2 / (4pi^2)    # golden rule with d^3p/(2pi)^3

p0 = pdecay(M)
@printf("Inputs: mc = %.3f GeV, sigma = %.4f GeV^2, gamma = %.3f, g = %.2f MeV, M = %.1f MeV\n",
        mc, sigma, gamma, 1e3g, 1e3M)
@printf("Decay momentum p = %.1f MeV (followup.tex: 272 MeV); sqrt(2 mu (M - mD - mD*)) = %.1f MeV\n",
        1e3p0, 1e3sqrt(2mu * (M - mD - mDs)))
println()
@printf("Cornell levels E_n (GeV): package %.6f %.6f | finite difference %.6f %.6f\n",
        ff.energies[1], ff.energies[2], fd_E[1], fd_E[2])
@printf("Bare masses 2mc + V0 + E_n (MeV): 1P %.1f, 2P %.1f\n",
        1e3(2mc + V0 + ff.energies[1]), 1e3(2mc + V0 + ff.energies[2]))
for p in (0.272, p0)
    a, b = psi_pkg(p), psi_fd(p)
    @printf("psi_n(p = %.0f MeV) [GeV^-3/2]: package %+.4f %+.4f | finite difference |%.4f| |%.4f|\n",
            1e3p, a[1], a[2], abs(b[1]), abs(b[2]))
end
grid = range(0.01, 2.0, length=400)
vals = [psi_pkg(p)[2] for p in grid]
node = [grid[i] for i in 1:length(grid)-1 if sign(vals[i]) != sign(vals[i+1])]
@printf("Nodes of psi_2(p) below 2 GeV: %s MeV\n", join([@sprintf("%.0f", 1e3x) for x in node], ", "))
println()

psi_est = 0.1^(-1.5)
psi2 = psi_pkg(p0)[2]
rows = [
    ("followup.tex chain: g_rel = 5 GeV, p = 272 MeV", 5.0^2 * 0.272 / (8pi * M^2), NaN),
    ("lambda^(-3/2) estimate, p = 272 MeV, exact prefactor", width(psi_est, 0.272), grel(psi_est)),
    ("Cornell psi_2, p = 272 MeV", width(psi_pkg(0.272)[2], 0.272), grel(psi_pkg(0.272)[2])),
    ("Cornell psi_2, physical p", width(psi2, p0), grel(psi2)),
]
for (label, G, gr) in rows
    @printf("%-55s Gamma = %6.1f MeV   g_rel = %s\n", label, 1e3G,
            isnan(gr) ? "5 GeV (as printed)" : @sprintf("%.2f GeV", abs(gr)))
end
lo, hi = M - dM, M + dM
@printf("Physical p, M = %.1f..%.1f MeV: Gamma = %.1f..%.1f MeV\n",
        1e3lo, 1e3hi, 1e3width(psi_pkg(pdecay(lo))[2], pdecay(lo); m=lo),
        1e3width(psi_pkg(pdecay(hi))[2], pdecay(hi); m=hi))
@printf("Nonrelativistic golden rule, physical p: Gamma = %.1f MeV\n", 1e3width_nr(psi2, p0))
@printf("Measured (LHCb:2024vfz): 62.7 +7.0 -6.4 (stat) +6.4 -6.6 (syst) MeV\n")
