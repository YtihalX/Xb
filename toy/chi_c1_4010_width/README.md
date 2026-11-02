# chi_c1_4010_width

Question: What bare-state golden-rule width does the LO vertex $g f_2(p)=g\psi_2(p)/\sqrt{4\pi}$ give for $\chi_{c1}(4010)\to D\bar D^*$ with the Cornell $2P$ wave function at $m_c=1.328$ GeV and the physical decay momentum?

Run: `julia --project=checks toy/chi_c1_4010_width/run.jl`

The bare Cornell $2P$ estimate gives $\Gamma=13.9$ MeV ($11$–$17$ MeV over the mass uncertainty), compared with the measured $62.7^{+7.0+6.4}_{-6.4-6.6}$ MeV [@LHCb:2024vfz]. The physical momentum is $p=519$ MeV; the nonrelativistic kinematic estimate is $514$ MeV. The wave function has a node at $439$ MeV and $|\psi_2(519\,\mathrm{MeV})|=18.6\,\mathrm{GeV}^{-3/2}$, making the estimate sensitive to shifts of that node. At fixed wave function, matching the measured width would require $g\approx121$ MeV. This bare-state calculation omits dressing, OME and contact interactions.

Current result: NOTEBOOK.md, Established, Charm width toy.

Cross-checks in the output: the package's Cornell levels and $\psi_n(p)$ agree with an independent finite-difference solve to all printed digits; the nonrelativistic golden rule with measure $d^3p/(2\pi)^3$ gives $14.4$ MeV, consistent with the relativistic conversion ($13.9$ MeV) up to $(m_D+m_{D^*})/M$; with $V_0=-36$ MeV the bare $1P$ and $2P$ masses are $3511.9$ and $4014.4$ MeV.

Approximations: golden rule for the bare $2P$ state at the physical mass, so no dressing, no compact probability below 1, no energy dependence across the width; $S$-wave $D\bar D^*$ only, with no OME, contact term, or mixing with the $1P$, $3P$ and $X(3872)$; flavour-independent $\sigma=0.1984$ GeV$^2$, $\gamma=-0.434$ and $g=2\sqrt{2/3}\,g_l=57.15$ MeV taken from the bottom sector; isospin-averaged $D$ and $D^*$ masses of [@ParticleDataGroup:2024cfk]; mass uncertainty from the larger statistical and systematic errors of [@LHCb:2024vfz] in quadrature; LO Cornell wave function.

Date: 2026-10-29

## Mass band

Question: How strongly do $\psi_2(p)$ and the golden-rule width $\Gamma(M)$ change when the $\chi_{c1}(4010)$ mass moves $\pm10$ MeV about its central value, with the $\psi_2$ node close to the decay momentum? The answer shows whether a mass shift inside this band can close the gap to the measured $62.7$ MeV, and how precisely a dressed calculation must fix the pole mass before its width can be compared with experiment.

Run: `julia --project=toy/chi_c1_4010_width toy/chi_c1_4010_width/plot.jl`; it prints the output of `momentum_scan.jl`, which begins with that of `run.jl`, and writes `psi2_band.pdf` ($\psi_2(p)$ with the momentum band) and `width_vs_mass.pdf` ($\Gamma(M)$, decay momentum on the top axis), plus the two Momentum scan figures.

Verdict: For $M=4012.5\pm10$ MeV the decay momentum spans $p=499.2$–$537.9$ MeV, $60$–$98$ MeV above the node at $439.7$ MeV, and $\psi_2$ runs from $-14.8$ to $-21.8\ \mathrm{GeV}^{-3/2}$. $\Gamma$ rises monotonically from $8.5$ to $19.7$ MeV through $13.9$ MeV at the centre, $-39\%$ and $+42\%$, or $4.1\%$ per MeV at the centre. With $\psi_2$ fixed at its central value, phase space alone gives $13.4$–$14.4$ MeV and $0.35\%$ per MeV, so the node makes $\Gamma$ about 12 times more sensitive to $M$. Across the whole band $\Gamma$ stays below a third of the measured $62.7$ MeV; the decay momentum reaches the node ($\Gamma=0$) at $M=3974.5$ MeV, $38$ MeV below the centre. Checked by the independent finite-difference radial solve of `run.jl`: $\psi_2$ and $\Gamma$ at $M=4002.5$, $4007.5$, $4012.5$, $4017.5$ and $4022.5$ MeV, the node and the slope agree to every digit `plot.jl` prints (largest differences $7\times10^{-6}\ \mathrm{GeV}^{-3/2}$ in $\psi_2$ and $10^{-4}$ MeV in the node), and the solve's own step and box errors lie below those digits (`checks/chi_c1_4010_band.jl`). The rest of the plotted $\psi_2$ curve is not compared.

Approximations: those of the base toy; $\psi_2$, $g$ and $m_c$ stay fixed as $M$ varies, so $M$ enters only through $p(M)$ and the kinematic factors of $\Gamma=m_Dm_{D^*}g^2\psi_2^2(p)\,p/(4\pi^2M)$; the central mass is the $4012.5$ MeV of [@LHCb:2024vfz] used by `run.jl`, and the $\pm10$ MeV range is the user's choice (2026-10-30), wider than the $\pm5.7$ MeV experimental uncertainty.

Date: 2026-10-30

## Momentum scan

Question: What is $\psi_2(0)$, and how large does the golden-rule width get when only the decay momentum varies, with $M$ held at $4012.5$ MeV in the prefactor? Where is the maximum, and what is $\Gamma$ at the minimum of $\psi_2$? The answer shows how large $\Gamma$ can be at this coupling and wave function by moving the decay momentum alone, against the measured $62.7$ MeV.

Run: `julia --project=checks toy/chi_c1_4010_width/momentum_scan.jl`; it prints the output of `run.jl` first. `plot.jl` (Mass band) also prints the zeros of $\psi_2$ and its maximum at $p>0$ from a scan up to $6$ GeV, and draws the complete $\psi_2(p)$ up to $3$ GeV in `psi2_full.pdf` and $\Gamma(p)$ at fixed $M$ in `width_vs_momentum.pdf`, with the measured width $62.7^{+9.5}_{-9.2}$ MeV (statistical and systematic errors of [@LHCb:2024vfz] in quadrature) as a band.

Verdict: $\psi_2(0)=+133.29\ \mathrm{GeV}^{-3/2}$ ($f_2(0)=37.60\ \mathrm{GeV}^{-3/2}$), $7.2$ times $|\psi_2|$ at the physical $p=518.9$ MeV. At fixed $M$, $\Gamma\propto p\,\psi_2^2(p)$ peaks where $d\ln|\psi_2|/d\ln p=-1/2$, not at an extremum of $\psi_2$. The global maximum lies below the node: $\Gamma=135.9$ MeV at $p=159.7$ MeV ($\psi_2=+104.9\ \mathrm{GeV}^{-3/2}$), the decay momentum of a $3889.0$ MeV state, $13$ MeV above the $D\bar D^*$ threshold at $3875.8$ MeV. In the lobe of the physical momentum, beyond the node, the maximum is $\Gamma=52.7$ MeV at $p=701.8$ MeV, the decay momentum of a $4122.4$ MeV state; that is $3.8$ times the physical $13.9$ MeV and still below the measured $62.7$ MeV. At the minimum of $\psi_2$, $-31.48\ \mathrm{GeV}^{-3/2}$ at $p=673.5$ MeV, $\Gamma=51.6$ MeV. $\psi_2(p)$ has a second zero at $1270.4$ MeV; it is a zero of the $j_0$ transition form factor, not a node of the $2P$ wave function, which has one radial node. Beyond that zero $\psi_2$ peaks at $+1.65\ \mathrm{GeV}^{-3/2}$ at $p=1518.0$ MeV and the width at $0.3$ MeV, at $p=1539.4$ MeV; neither has a further zero or a larger maximum up to $6$ GeV. Not yet checked by an independent route.

Approximations: those of the base toy; the shape of $\psi_2$ is fixed, so the scan moves the decay momentum along one wave function instead of moving its node, which a change of $m_c$, $\sigma$ or $\gamma$ would do while also rescaling $\psi_2$; $M$ stays $4012.5$ MeV in $\Gamma=m_Dm_{D^*}g^2\psi_2^2(p)\,p/(4\pi^2M)$, and setting $M$ to the mass of each momentum instead would change the widths at the two maxima by the factor $4012.5\ \mathrm{MeV}/M$, $+3.2\%$ and $-2.7\%$; the scan stops at $6$ GeV, the end of the package's real-axis interpolant.

Date: 2026-10-30
