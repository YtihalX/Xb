# Conventions

Canonical notation for the BOχEFT follow-up (spin-2 partners, charm sector, CMS line shapes); unless an entry says otherwise it is the notation of [@Zhang:2026iyr] v1.

## Core

### Units
Object: units of every quantity in notes, checks, code, and paper
Symbol: —
Choice: natural units $\hbar=c=1$; checks and code work in GeV (contact term $C$ in $\text{GeV}^{-2}$), prose may quote MeV; lengths convert with $\hbar c=0.1973$ GeV fm
Status: agreed
Source: [@Zhang:2026iyr] v1, Tables I and III, App. A ($30\ \text{GeV}^{-1}\simeq5.92$ fm)

### Metric signature
Object: the Minkowski metric, used only for four-momenta of exchanged mesons
Symbol: $\eta_{\mu\nu}$
Choice: mostly minus, $q^2=q_0^2-\boldsymbol q^2$, so the exchanged-meson denominator is $q^2-m_\pi^2=-\boldsymbol q^2-(m_\pi^2-q_0^2)$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (C1)–(C2)

### Energy origin and on-shell momentum
Object: the energy variable of the scattering equation and the channel kinetic energies in the bottom sectors
Symbol: $E$, $k$, $M_{\rm th}$, $\mu_\alpha$, $\delta_\alpha$, $\Delta m$
Choice: $M=M_{\rm th}+E$, with $M_{\rm th}$ the threshold of the $S$-wave channel: $M_{\rm th}=m_B+m_{B^*}$ in $1^{++}$, $M_{\rm th}=2m_{B^*}$ in $2^{++}$; $E=k^2/(2\mu_1)$ with $\mu_1$ the reduced mass of that channel; channel $\alpha$ with reduced mass $\mu_\alpha$ has free energy $q^2/(2\mu_\alpha)+\delta_\alpha$, where $\delta_\alpha$ is its threshold minus $M_{\rm th}$ ($1^{++}$: $0,0,\Delta m$; $2^{++}$: $0$ for $B^*\bar B^*$, $-\Delta m$ for $B\bar B^*$, $-2\Delta m$ for $B\bar B$), and $\Delta m=m_{B^*}-m_B$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (3)–(5), (87); the user, grilling 2026-10-28 ($2^{++}$ origin: "B*B*")

### Partial-wave states
Object: free two-meson radial partial-wave states
Symbol: $|p,\alpha\rangle$, $\mathcal Y^{J}_{L_\alpha S_\alpha}$
Choice: $\langle p',\alpha'|p,\alpha\rangle=\delta_{\alpha'\alpha}\,\frac{2\pi^2}{p^2}\,\delta(p'-p)$ and $\langle\boldsymbol r|p,\alpha\rangle=4\pi\,i^{L_\alpha}j_{L_\alpha}(pr)\,\mathcal Y^{J}_{L_\alpha S_\alpha}(\hat{\boldsymbol r})$ with $\int d\Omega\,|\mathcal Y|^2=1/(4\pi)$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (30)–(31) and the footnote to Eq. (31)

### Loop measure and regulator
Object: every momentum integral over a two-meson loop
Symbol: $\Lambda$
Choice: $\int\frac{d^3q}{(2\pi)^3}\to\int_0^\Lambda\frac{q^2\,dq}{2\pi^2}$ after the angular integration, with a sharp upper limit $\Lambda$
Status: agreed
Source: [@Zhang:2026iyr] v1, text below Eq. (58); Eqs. (86), (88)–(92)

### Lippmann–Schwinger equation
Object: the off-shell $T$-matrix and the sign of the potential
Symbol: $T_{\alpha'\alpha}(p',p)$, $V_{\alpha'\alpha}(p',p)$, $G_\alpha(k,q)$
Choice: $T_{\alpha'\alpha}(p',p)=V_{\alpha'\alpha}(p',p)-\sum_{\alpha''}\int_0^\Lambda\frac{q^2dq}{2\pi^2}V_{\alpha'\alpha''}(p',q)\,G_{\alpha''}(k,q)\,T_{\alpha''\alpha}(q,p)$ with $G_\alpha(k,q)=\bigl[q^2/(2\mu_\alpha)+\delta_\alpha-E-i\epsilon\bigr]^{-1}$; an attractive potential is negative; bound states are the zeros of $\det(\hat v^{-1}+\hat J)$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (86)–(87), (93)

### On-shell amplitude and effective-range expansion
Object: the on-shell partial-wave amplitude, the $S$ matrix, and the sign of the scattering length
Symbol: $f_{LL'}$, $S$, $a$, $r$
Choice: $f_{LL'}(E)=-\frac{\mu}{2\pi}T_{LL'}(k,k;E)$, $S=\mathbb 1+2ikf$; $k\cot\delta_S=\frac1a+\frac12rk^2+\mathcal O(k^4)$, so $a<0$ when a bound state is present
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (108), (110)

### C-parity phase
Object: charge conjugation of heavy-meson fields and the $C$-even two-meson state
Symbol: $\mathcal C$
Choice: $\mathcal C P_a\mathcal C^{-1}=\bar P_a$, $\mathcal C V^i_a\mathcal C^{-1}=-\bar V^i_a$; $|B\bar B^*;C{=}+\rangle=\bigl(|B\bar B^*\rangle-|B^*\bar B\rangle\bigr)/\sqrt2$
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. III B and footnote 14

### Axial coupling and OME normalisation
Object: the heavy-meson–Goldstone-boson vertices and the isoscalar OME potential
Symbol: $g_b$, $F_\pi$, $\Phi$, $D_\beta$
Choice: Lagrangian of Eq. (68) with $\boldsymbol u=-\nabla\Phi/F_\pi$, $\Phi=\pi_a\tau_a+\eta\,\mathbb 1_2/\sqrt3$, $F_\pi=92.2$ MeV, $g_b=0.56$; vertices $v^a_{B^*B\phi}=\frac{g_b}{2F_\pi}\tau^a(\boldsymbol\epsilon\cdot\boldsymbol q)$, $v^a_{B^*B^*\phi}=-\frac{g_b}{\sqrt2F_\pi}\tau^a(\boldsymbol A\cdot\boldsymbol q)$ with $\boldsymbol q=\boldsymbol p-\boldsymbol p'$; TOPT potentials of Eqs. (72)–(77); isoscalar combination $V^{\rm(OME)}=3V(m_\pi)+\frac13V(m_\eta)$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (66)–(70), (72)–(77), (82)

### Partial-wave projectors
Object: projection of OME potentials onto partial-wave channels
Symbol: $P(\alpha;\boldsymbol n)$
Choice: $V_{\alpha'\alpha}(p',p)=\frac{1}{2J+1}\int\frac{d\Omega_{n'}}{4\pi}\frac{d\Omega_n}{4\pi}\operatorname{Tr}\bigl[P^\dagger(\alpha';\boldsymbol n')\,V\,P(\alpha;\boldsymbol n)\bigr]$ with $\frac{1}{2J+1}\int\frac{d\Omega_n}{4\pi}P(\alpha;\boldsymbol n)P^\dagger(\alpha;\boldsymbol n)=1$; the $1^{++}$ projectors and their signs as in Eq. (D1), whose $^5D_1$ sign is opposite to [@Bruschini:2023zkb]
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (80)–(81), (D1), footnote to Eq. (17)

### Angular-momentum phases
Object: Clebsch–Gordan coefficients and spherical harmonics
Symbol: $\langle j_1m_1j_2m_2|JM\rangle$, $Y_{lm}$
Choice: Condon–Shortley phase convention
Status: agreed
Source: [@Zhang:2026iyr] v1, text above Eq. (19)

### Bare–continuum vertex
Object: the transition between a bare state and the $S$-wave two-meson channel
Symbol: $g$, $g_l$, $\psi_n(p)$, $f_n(p)$, $R_{1n}$, $u_n$
Choice: $\langle B\bar B^*|\hat g|[\bar bb]_1(nP)\rangle=g\,\psi_n(p)$, $\psi_n(p)=4\pi\int_0^\infty r^2dr\,j_0(pr)R_{1n}(r)$, $u_n=rR_{1n}$ with $\int_0^\infty|u_n|^2dr=1$, $f_n=\psi_n/\sqrt{4\pi}$ with phase $f_n(0)>0$; $g=\frac{2}{\sqrt3}\sqrt2\,g_l=57$ MeV for $g_l=35$ MeV
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (18), (52)–(54), (61), (A3), (A10)

### Separable s-channel and contact potential
Object: the bare-state exchange plus contact term and where it acts
Symbol: $V^{(\bar bb)+\rm CT}_S$, $\hat v$, $C$, $V_0$, $E^{(0)}_n$
Choice: $V^{(\bar bb)+\rm CT}_S(p',p)=\sum_{n=1}^N f_n(p')\frac{g^2}{E-E^{(0)}_n-V_0}f_n^*(p)+C$, acting only in the $S$-wave channel: $V_{\alpha'\alpha}=\delta_{\alpha'1}\delta_{\alpha1}V^{(\bar bb)+\rm CT}_S+V^{\rm(OME)}_{\alpha'\alpha}$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (59)–(63), (83)

### Quark–antiquark Hamiltonian
Object: the Hamiltonian that defines the bare states
Symbol: $H$, $V(r)$, $V_0$, $\sigma$, $\gamma$, $m_b$
Choice: $H=2m_b-\nabla^2/m_b+V(r)$, $V(r)=V_0+\sigma r+\gamma/r$ with $\gamma\equiv-\frac43\alpha_s<0$; $\sigma=0.198\ \text{GeV}^2$ and $\gamma=-0.434$ from [@Bulava:2024jpj]
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (12), (38), Table I

### 2++ channel basis and projectors
Object: the $2^{++}$ coupled-channel basis and its partial-wave projectors
Symbol: $\alpha=1,\dots,6$
Choice: $\alpha=1,\dots,6$ are $B^*\bar B^*(^5S_2)$, $B^*\bar B^*(^1D_2)$, $B^*\bar B^*(^5D_2)$, $B^*\bar B^*(^5G_2)$, $B\bar B^*(^3D_2)$, $B\bar B(^1D_2)$; the spin-angular projectors are those of [@Baru:2019xnh] v2, App. B, normalised as in "Partial-wave projectors"; the $B\bar B^*(^3D_2)$ channel is the $C$-even combination of "C-parity phase", not that paper's; every sign relative to [@Baru:2019xnh] is recorded in its bridge, `literature/Baru:2019xnh/bridge.md`
Status: agreed
Source: followup.tex §I, Eq. (3); [@Baru:2019xnh] v2, App. B; the user, grilling 2026-10-28 ("Agree basis and projectors")

### 2++ bare–continuum vertex
Object: the transition between a bare $J=2$ state and the $2^{++}$ channels
Symbol: $g$, $\psi_n(p)$
Choice: bare $\chi_{b2}$ states couple only to $\alpha=1$, $\langle B^*\bar B^*(^5S_2)|\hat g|[\bar bb]_1(nP);J{=}2\rangle=g\,\psi_n(p)$, with the $g=57$ MeV and $\psi_n$ of "Bare–continuum vertex"; the recoupling coefficient $-1/\sqrt3$ of [@Bruschini:2023zkb] v3, Table 2 has the $1^{++}$ magnitude and its sign drops out because only $g^2$ enters; the $D$-wave entries of that row are dropped at LO
Status: agreed
Source: followup.tex §I, Eq. (1); [@Bruschini:2023zkb] v3, Table 2; the user, grilling 2026-10-28 ("S-wave only, g = 57 MeV")

### Pole position and Riemann sheets
Object: complex poles of the $T$-matrix
Symbol: $M$, $\Gamma$, $E_{\rm pole}$, $(\pm,\pm,\pm)$
Choice: a pole sits at complex total energy $M-i\Gamma/2$, i.e. $E_{\rm pole}=M-M_{\rm th}-i\Gamma/2$; sheets are labelled by the signs of $\operatorname{Im}k_t$ at each distinct two-meson threshold $t$ in increasing order ($2^{++}$: $B\bar B$, $B\bar B^*$, $B^*\bar B^*$), the physical sheet being $(+,+,+)$; a pole whose $M$ lies between two thresholds is reported on the sheet reached from the physical real axis between them, e.g. $(-,-,+)$ between $B\bar B^*$ and $B^*\bar B^*$
Status: agreed
Source: the user, grilling 2026-10-28 ("E_pole = M − iΓ/2; adjacent sheet")

### Multichannel S matrix and unitarity
Object: the on-shell $S$ matrix with several open channels, and its unitarity check
Symbol: $S$, $\rho_\alpha$, $k_\alpha$
Choice: $S=\mathbb 1-2i\sqrt\rho\,T\sqrt\rho$ with $\rho=\operatorname{diag}(\mu_\alpha k_\alpha/2\pi)$ over the open channels and $k_\alpha=\sqrt{2\mu_\alpha(E-\delta_\alpha)}$, which reduces to $f=-\mu T/2\pi$, $S=\mathbb 1+2ikf$ for one reduced mass; on the real axis unitarity $S^\dagger S=\mathbb 1$ is $\operatorname{Im}(T^{-1})_{\alpha'\alpha}=\rho_\alpha\delta_{\alpha'\alpha}$, with $T$ the on-shell matrix restricted to the open channels
Status: agreed
Source: [@Zhang:2026iyr] v1, Eq. (108); code/HadronDynamics.jl/docs/BOCHIEFT.md:242–248; the user, grilling 2026-10-28 ("Agree convention and check")

## Symbols

### Binding energy and meson energies
Object: symbols that [@Zhang:2026iyr] v1 uses for two things
Symbol: $E_B$, $\omega_{B^{(*)}}(p)$
Choice: $E_B$ is the binding energy only; the paper's on-shell meson energies $E_{B^{(*)}}(p)$ in Eq. (77) are written $\omega_{B^{(*)}}(p)$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eq. (77) against Eq. (97) and Sec. IV C; the user, grilling 2026-10-28

### Reduced masses and TOPT energy offsets
Object: symbols that [@Zhang:2026iyr] v1 uses for two things
Symbol: $\mu_\alpha$, $\nu_\beta$
Choice: $\mu_\alpha$ is the reduced mass of two-body channel $\alpha$; the TOPT energy offsets $\mu_\beta$ of Eq. (77) are written $\nu_\beta$, so $D_\beta=\bigl[2E_\phi(q)(E_\phi(q)+\nu_\beta)\bigr]^{-1}$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eq. (3) against Eqs. (76)–(77); the user, grilling 2026-10-28

## Naming

### State labels
Object: names of measured peaks and of model states
Symbol: $\chi_{bJ}(nP)$, $\chi_{bJ}(\text{mass})$
Choice: $\chi_{bJ}(nP)$ (likewise $\chi_{cJ}(nP)$) is the compact-dominated model state that continues bare state $n$; a measured peak is labelled by its mass in MeV, e.g. $\chi_{b1}(10513)$, $\chi_{b2}(10524)$, $\chi_{c1}(4010)$; molecule-dominated states are $X_b$, $X_{b2}$, $X(3872)$, $X_2$
Status: agreed
Source: the user, grilling 2026-10-28 ("χ_bJ(nP)=model; peaks by mass")
