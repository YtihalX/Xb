# Toy extension figures. Mass band: psi_2(p) with the decay-momentum band, Gamma(M) for M = 4012.5 +- 10 MeV.
# Momentum scan: the complete psi_2(p), and Gamma(p) at fixed M.
# Run: julia --project=toy/chi_c1_4010_width toy/chi_c1_4010_width/plot.jl
# Writes psi2_band.pdf, width_vs_mass.pdf, psi2_full.pdf and width_vs_momentum.pdf next to this file;
# GeV inside, MeV on the axes.
include("momentum_scan.jl")   # run.jl (inputs, psi_pkg, pdecay, width, psi2 = psi_2(p0)) and the momentum scan
                              # (psi2_of, width_at, mass_of, local_minima, gamma_max, psi2_min); prints both first
using CairoMakie

const Mshift = 0.010                         # mass varied by +-10 MeV about M (user, 2026-10-30)
width_of(m) = width(psi2_of(pdecay(m)), pdecay(m); m=m)
width_fixed(m) = width(psi2, pdecay(m); m=m)  # psi_2 held at psi_2(p0): S-wave phase space alone

function bisect(f, a, b; iters=60)
    fa = f(a)
    for _ in 1:iters
        c = (a + b) / 2
        fc = f(c)
        sign(fc) == sign(fa) ? ((a, fa) = (c, fc)) : (b = c)
    end
    return (a + b) / 2
end

pnode = bisect(psi2_of, node[1], node[1] + step(grid))   # bracket from run.jl's grid scan
Mnode = mass_of(pnode)
Mlo, Mhi = M - Mshift, M + Mshift
plo, phi = pdecay(Mlo), pdecay(Mhi)

println()
@printf("Mass band M = %.1f..%.1f MeV gives p = %.1f..%.1f MeV\n", 1e3Mlo, 1e3Mhi, 1e3plo, 1e3phi)
println("  M (MeV)   p (MeV)   psi_2 (GeV^-3/2)   Gamma (MeV)   Gamma, psi_2 fixed at p0 (MeV)")
for m in (Mlo, M - Mshift / 2, M, M + Mshift / 2, Mhi)
    @printf("  %7.1f   %7.1f   %+10.3f         %7.2f       %7.2f\n",
            1e3m, 1e3pdecay(m), psi2_of(pdecay(m)), 1e3width_of(m), 1e3width_fixed(m))
end
@printf("Node of psi_2: p = %.1f MeV, the decay momentum at M = %.1f MeV\n", 1e3pnode, 1e3Mnode)
h = 1e-5
dlog(f) = (log(f(M + h)) - log(f(M - h))) / (2h) / 1000   # per MeV
@printf("d ln Gamma/dM at M = %.1f MeV: %.2f %%/MeV; with psi_2 fixed at p0: %.2f %%/MeV\n",
        1e3M, 100dlog(width_of), 100dlog(width_fixed))

set_theme!(theme_latexfonts())
band_color = (:darkorange, 0.25)
mev1(x) = @sprintf("%.1f", 1e3x)

# psi_2(p) with the momentum band
ps = range(0.001, 1.0, length=1000)
fig1 = Figure(size=(640, 420))
ax1 = Axis(fig1[1, 1], xlabel=L"p\;\mathrm{(MeV)}", ylabel=L"\psi_2(p)\;\mathrm{(GeV^{-3/2})}",
           title=L"\mathrm{Cornell}\;2P,\; m_c = 1.328\;\mathrm{GeV}", xticks=0:100:1000)
hlines!(ax1, 0, color=:gray60, linewidth=0.8)
vspan!(ax1, 1e3plo, 1e3phi, color=band_color,
       label=L"M = %$(mev1(M)) \pm %$(round(Int, 1e3Mshift))\;\mathrm{MeV}")
lines!(ax1, 1e3 .* ps, psi2_of.(ps), color=:black, linewidth=1.8)
vlines!(ax1, 1e3p0, color=:darkorange, linestyle=:dash, label=L"p = %$(mev1(p0))\;\mathrm{MeV}")
scatter!(ax1, [1e3pnode], [0.0], color=:white, strokecolor=:black, strokewidth=1.5, markersize=9,
         label=L"\mathrm{node},\; p = %$(mev1(pnode))\;\mathrm{MeV}")
xlims!(ax1, 0, 1000)
axislegend(ax1, position=:rt, framevisible=false)
save(joinpath(@__DIR__, "psi2_band.pdf"), fig1)

# Gamma(M) across the band, with the decay momentum on the top axis
ms = range(Mlo, Mhi, length=201)
fig2 = Figure(size=(640, 420))
ax2 = Axis(fig2[1, 1], xlabel=L"M\;\mathrm{(MeV)}", ylabel=L"\Gamma\;\mathrm{(MeV)}")
ptick = 500:10:530
axp = Axis(fig2[1, 1], xaxisposition=:top, xlabel=L"p\;\mathrm{(MeV)}", xgridvisible=false,
           backgroundcolor=:transparent, xticks=(1e3 .* mass_of.(ptick ./ 1e3), string.(ptick)))
hidespines!(axp); hideydecorations!(axp); linkxaxes!(ax2, axp)
lines!(ax2, 1e3 .* ms, 1e3 .* width_of.(ms), color=:black, linewidth=1.8,
       label=L"\psi_2\;\mathrm{at}\;p(M)")
lines!(ax2, 1e3 .* ms, 1e3 .* width_fixed.(ms), color=:gray45, linestyle=:dash,
       label=L"\psi_2\;\mathrm{fixed\;at}\;p = %$(mev1(p0))\;\mathrm{MeV}")
vlines!(ax2, 1e3M, color=:darkorange, linestyle=:dash, label=L"M = %$(mev1(M))\;\mathrm{MeV}")
for (m, halign, dx) in ((Mlo, :left, 4), (M, :right, -5), (Mhi, :right, 0))
    scatter!(ax2, [1e3m], [1e3width_of(m)], color=:black, markersize=7)
    text!(ax2, 1e3m, 1e3width_of(m), text=mev1(width_of(m)), offset=(dx, 7), align=(halign, :bottom),
          fontsize=14)
end
xlims!(ax2, 1e3Mlo - 0.4, 1e3Mhi + 0.4)
ylims!(ax2, 0, 1.15e3width_of(Mhi))
axislegend(ax2, position=:lt, framevisible=false)
save(joinpath(@__DIR__, "width_vs_mass.pdf"), fig2)

# Complete psi_2(p): zeros on a 1 MeV scan of 0..6 GeV (the package's real-axis range), refined by
# bisection, and extrema from local_minima; the figure shows 0..3 GeV
function sign_changes(f, scan)
    v = f.(scan)
    return [bisect(f, scan[i], scan[i+1]) for i in 1:length(scan)-1 if sign(v[i]) != sign(v[i+1])]
end
zeros2 = sign_changes(psi2_of, range(0.0, 6.0, length=6001))
psi2_max = local_minima(p -> -psi2_of(p))   # interior maxima: p = 0, the maximum by symmetry, is an endpoint
@printf("Zeros of psi_2 on 0..6000 MeV: %s MeV\n", join(mev1.(zeros2), ", "))
for p in psi2_max
    @printf("Maximum of psi_2 at p > 0: %+.3f GeV^-3/2 at p = %.1f MeV\n", psi2_of(p), 1e3p)
end

psi0s = @sprintf("%.2f", psi2_of(0.0))
zeros_s = join(mev1.(zeros2), ",\\;")
ext_s = [(@sprintf("%+.2f", psi2_of(p)), mev1(p)) for p in (psi2_min[1], psi2_max[1])]
zoom = (x=(1000.0, 3000.0), y=(-3.0, 2.5))
fig3 = Figure(size=(980, 420))
axa = Axis(fig3[1, 1], xlabel=L"p\;\mathrm{(MeV)}", ylabel=L"\psi_2(p)\;\mathrm{(GeV^{-3/2})}",
           title=L"\mathrm{Cornell}\;2P,\; m_c = 1.328\;\mathrm{GeV}")
axb = Axis(fig3[1, 2], xlabel=L"p\;\mathrm{(MeV)}", title=L"\mathrm{magnified}")
colsize!(fig3.layout, 1, Relative(0.58))
pfull = range(0.0, 3.0, length=3001)
for ax in (axa, axb)
    hlines!(ax, 0, color=:gray60, linewidth=0.8)
    lines!(ax, 1e3 .* pfull, psi2_of.(pfull), color=:black, linewidth=1.8)
end
poly!(axa, Rect(zoom.x[1], zoom.y[1], zoom.x[2] - zoom.x[1], zoom.y[2] - zoom.y[1]), color=(:gray, 0.25))
vlines!(axa, 1e3p0, color=:darkorange, linestyle=:dash, label=L"\mathrm{physical}\;p = %$(mev1(p0))\;\mathrm{MeV}")
scatter!(axa, [0.0], [psi2_of(0.0)], color=:black, markersize=8, label=L"\psi_2(0) = %$(psi0s)")
scatter!(axa, 1e3 .* zeros2, zeros(length(zeros2)), color=:white, strokecolor=:black, strokewidth=1.5,
         markersize=9, label=L"\mathrm{zeros}\;\mathrm{at}\; %$(zeros_s)\;\mathrm{MeV}")
scatter!(axa, [1e3psi2_min[1]], [psi2_of(psi2_min[1])], color=:steelblue, markersize=9,
         label=L"\mathrm{minimum}\; %$(ext_s[1][1])\;\mathrm{at}\; %$(ext_s[1][2])\;\mathrm{MeV}")
xlims!(axa, -40, 3000)
axislegend(axa, position=:rt, framevisible=false)
scatter!(axb, [1e3zeros2[2]], [0.0], color=:white, strokecolor=:black, strokewidth=1.5, markersize=9,
         label=L"\mathrm{zero}\;\mathrm{at}\; %$(mev1(zeros2[2]))\;\mathrm{MeV}")
scatter!(axb, [1e3psi2_max[1]], [psi2_of(psi2_max[1])], color=:steelblue, markersize=9,
         label=L"\mathrm{maximum}\; %$(ext_s[2][1])\;\mathrm{at}\; %$(ext_s[2][2])\;\mathrm{MeV}")
xlims!(axb, zoom.x...)
ylims!(axb, zoom.y...)
axislegend(axb, position=:rt, framevisible=false)
save(joinpath(@__DIR__, "psi2_full.pdf"), fig3)

# Gamma(p) at fixed M (momentum_scan.jl), with the maximum beyond the second zero magnified
const Gmeas, Gmeas_up, Gmeas_dn = 0.0627, hypot(0.0070, 0.0064), hypot(0.0064, 0.0066)  # LHCb:2024vfz, stat and syst in quadrature
gamma_mev(p) = 1e3width_at(p)
gtop = gamma_mev(gamma_max[1])
gamma3_s = @sprintf("%.2f", gamma_mev(gamma_max[3]))
fig4 = Figure(size=(980, 420))
axc = Axis(fig4[1, 1], xlabel=L"p\;\mathrm{(MeV)}", ylabel=L"\Gamma\;\mathrm{(MeV)}",
           title=L"\mathrm{Cornell}\;2P,\;\mathrm{fixed}\;M = %$(mev1(M))\;\mathrm{MeV}")
axd = Axis(fig4[1, 2], xlabel=L"p\;\mathrm{(MeV)}", title=L"\mathrm{magnified}")
colsize!(fig4.layout, 1, Relative(0.58))
hspan!(axc, 1e3(Gmeas - Gmeas_dn), 1e3(Gmeas + Gmeas_up), color=(:seagreen, 0.25),
       label=L"\mathrm{measured}\;\Gamma = %$(mev1(Gmeas))^{+%$(mev1(Gmeas_up))}_{-%$(mev1(Gmeas_dn))}\;\mathrm{MeV}")
for ax in (axc, axd)
    hlines!(ax, 0, color=:gray60, linewidth=0.8)
    lines!(ax, 1e3 .* pfull, gamma_mev.(pfull), color=:black, linewidth=1.8)
end
vlines!(axc, 1e3p0, color=:darkorange, linestyle=:dash,
        label=L"\mathrm{physical}\;p = %$(mev1(p0))\;\mathrm{MeV},\;\Gamma = %$(mev1(width_at(p0)))\;\mathrm{MeV}")
scatter!(axc, [1e3p0], [gamma_mev(p0)], color=:darkorange, markersize=7)
vlines!(axc, 1e3psi2_min[1], color=:gray30, linestyle=:dot,
        label=L"\psi_2\;\mathrm{minimum},\;p = %$(mev1(psi2_min[1]))\;\mathrm{MeV},\;\Gamma = %$(mev1(width_at(psi2_min[1])))\;\mathrm{MeV}")
for p in gamma_max[1:2]
    scatter!(axc, [1e3p], [gamma_mev(p)], color=:steelblue, markersize=9,
             label=L"\mathrm{maximum}\; %$(mev1(width_at(p)))\;\mathrm{MeV}\;\mathrm{at}\;p = %$(mev1(p))\;\mathrm{MeV}")
end
scatter!(axc, 1e3 .* zeros2, zeros(length(zeros2)), color=:white, strokecolor=:black, strokewidth=1.5,
         markersize=9, label=L"\mathrm{zeros}\;\mathrm{at}\; %$(zeros_s)\;\mathrm{MeV}")
xlims!(axc, 0, 3000)
ylims!(axc, -0.03gtop, 1.1gtop)
axislegend(axc, position=:rt, framevisible=false)
scatter!(axd, [1e3zeros2[2]], [0.0], color=:white, strokecolor=:black, strokewidth=1.5, markersize=9,
         label=L"\mathrm{zero}\;\mathrm{at}\; %$(mev1(zeros2[2]))\;\mathrm{MeV}")
scatter!(axd, [1e3gamma_max[3]], [gamma_mev(gamma_max[3])], color=:steelblue, markersize=9,
         label=L"\mathrm{maximum}\; %$(gamma3_s)\;\mathrm{MeV}\;\mathrm{at}\;p = %$(mev1(gamma_max[3]))\;\mathrm{MeV}")
xlims!(axd, 1000, 3000)
ylims!(axd, -0.012, 0.4)
axislegend(axd, position=:rt, framevisible=false)
save(joinpath(@__DIR__, "width_vs_momentum.pdf"), fig4)
println("Wrote psi2_band.pdf, width_vs_mass.pdf, psi2_full.pdf, width_vs_momentum.pdf")
