# chi_c1_4010_width

Question: followup.tex estimates $\Gamma[\chi_{c1}(4010)\to D\bar D^*]\simeq20$ MeV from the LO vertex $\frac{1}{\sqrt{4\pi}}g\psi_n(p)=g\,f_n(p)$ [@Zhang:2026iyr] v1, Eqs. (52)–(53) (CONVENTIONS.md "Bare–continuum vertex"), with $\psi_n(p)\approx\lambda^{-3/2}$, $\lambda=100$ MeV, and $p\approx272$ MeV. What width does the same vertex give with the Cornell $2P$ wave function at $m_c=1.328$ GeV and the physical decay momentum? Near the measured $62.7$ MeV, the estimate supports the follow-up's reading of $\chi_{c1}(4010)$ as $\chi_{c1}(2P)$-dominated; far from it, that reading needs the full above-threshold pole search before the charm repeat relies on it.

Run: `julia --project=checks toy/chi_c1_4010_width/run.jl`

Verdict: $\Gamma\approx14$ MeV ($11$–$17$ MeV over the $\pm5.7$ MeV mass uncertainty), a factor $\approx4.5$ below the measured $62.7^{+7.0+6.4}_{-6.4-6.6}$ MeV [@LHCb:2024vfz]. Two things change against the follow-up:

- The decay momentum is $p=519$ MeV, not $272$ MeV ($\sqrt{2\mu(M-m_D-m_{D^*})}=514$ MeV; $p^2=0.269$ GeV$^2$, so the printed value is probably $p^2$ without the square root).
- $\psi_2(p)$ has a node at $p=439$ MeV. At $p=519$ MeV, $|\psi_2|=18.6$ GeV$^{-3/2}$, against the estimate $\lambda^{-3/2}=31.6$ GeV$^{-3/2}$; at $272$ MeV it would be $61.9$ GeV$^{-3/2}$ and $\Gamma=81$ MeV.

The follow-up's $\simeq20$ MeV agrees with this result only by accident. Because the physical momentum lies just above the node, the width is sensitive to anything that moves it ($m_c$, $\sigma$, $\gamma$, $1/m_c$ corrections): the $\pm5.7$ MeV mass range alone spans $11$–$17$ MeV. Reaching $62.7$ MeV at fixed wave function would need $g\approx121$ MeV instead of $57$ MeV.

Cross-checks in the output: the package's Cornell levels and $\psi_n(p)$ agree with an independent finite-difference solve to all printed digits; the nonrelativistic golden rule with measure $d^3p/(2\pi)^3$ gives $14.4$ MeV, consistent with the relativistic conversion ($13.9$ MeV) up to $(m_D+m_{D^*})/M$; with $V_0=-36$ MeV the bare $1P$ and $2P$ masses are $3511.9$ and $4014.4$ MeV.

Approximations: golden rule for the bare $2P$ state at the physical mass, so no dressing, no compact probability below 1, no energy dependence across the width; $S$-wave $D\bar D^*$ only, with no OME, contact term, or mixing with the $1P$, $3P$ and $X(3872)$; flavour-independent $\sigma=0.1984$ GeV$^2$, $\gamma=-0.434$ and $g=2\sqrt{2/3}\,g_l=57.15$ MeV taken from the bottom sector; isospin-averaged $D$ and $D^*$ masses of [@ParticleDataGroup:2024cfk]; mass uncertainty from the larger statistical and systematic errors of [@LHCb:2024vfz] in quadrature; LO Cornell wave function.

Date: 2026-10-29
