# Xb follow-up: BOχEFT spin partners and the charm sector

This project extends the leading-order BOχEFT of [@Zhang:2026iyr] from $J^{PC}=1^{++}$ bottomonium to the $2^{++}$ sector (the $X_{b2}$), to charmonium ($X(3872)$ and its spin-2 partner $X_2$), and to the CMS $\Upsilon(nS)\gamma$ line shapes in the $\chi_{bJ}(3P)$ region, following the collaborators' list in `followup.tex`.

## Physical objects

**$X_b$**:
The isoscalar $1^{++}$ molecule-dominated state near the $B\bar B^*$ threshold, the bottom counterpart of $X(3872)$. In the baseline fit it is the pole at 10.513 GeV, identified with the measured peak $\chi_{b1}(10513)$ (the RPP's $\chi_{b1}(3P)$); in the shallow-$X_b$ fit it lies 1 MeV below the $B\bar B^*$ threshold.
_Avoid_: $\chi_{b1}(3P)$ for this state, bottom $X(3872)$
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. IV D, Tables V and VIII; followup.tex §I; the user, grilling 2026-10-28 (state labels)

**$X_{b2}$**:
The isoscalar $2^{++}$ molecule-dominated state near the $B^*\bar B^*$ threshold: the $2^{++}$ member of the heavy-quark spin multiplet $1_\ell^{--}\otimes 1_{\bar bb}^{--}=0^{++}\oplus1^{++}\oplus2^{++}$ that contains the $X_b$.
_Avoid_: molecular pole, tensor $X_b$, $W_{b2}$ (the isovector state)
Status: agreed
Source: followup.tex §I ("a molecular pole representing the $X_{b2}$"); [@Zhang:2026iyr] v1, Eq. (16)

**$X(3872)$**:
The isoscalar $1^{++}$ molecule-dominated state near the $D\bar D^*$ threshold, listed as $\chi_{c1}(3872)$ in the RPP.
_Avoid_: pure molecular state, $X_{c1}$
Status: agreed
Source: followup.tex §II, Eq. (7); [@Zhang:2026iyr] v1, footnote to Sec. IV F

**$X_2$**:
The isoscalar $2^{++}$ molecule-dominated state near the $D^*\bar D^*$ threshold, the spin-2 partner of $X(3872)$.
_Avoid_: $X_{c2}$, $X(4013)$
Status: agreed
Source: followup.tex §II ("make prediction for the $X(3872)$ spin-2 partner $X_2$")

**Binding energy**:
The distance $E_B = M_{\rm th}-M>0$ of a pole below a named two-meson threshold $M_{\rm th}$, with $M$ the real part of the pole mass $M-i\Gamma/2$; every quoted value names its threshold, and for a pole above a lower open threshold $\Gamma$ is quoted alongside. For the $X_b$ the threshold is $m_B+m_{B^*}$; for the $X_{b2}$ it is the $B^*\bar B^*$ threshold $2m_{B^*}$.
_Avoid_: binding (alone), $E_b$
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. IV C and Eq. (97); followup.tex §II, Eq. (7); the user, grilling 2026-10-28 ("we are interested in S-wave bound states, so B*B* is the threshold we needed"; "E_pole = M − iΓ/2; adjacent sheet")

## Mathematical definitions

**Bare state**:
An eigenstate $[\bar bb]_1(nP)$ of the quark–antiquark Hamiltonian with the Cornell potential including the shift $V_0$, before any coupling to two-meson channels; its bare mass is $M^{(\bar bb)}_n=M^{(0)}_n+V_0$, where the reference mass $M^{(0)}_n$ is the eigenvalue at $V_0=0$.
_Avoid_: generic state, quark-model state, reference state (for $V_0\neq0$)
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. III A 1, Eqs. (37)–(38), (63), Table II

**Compact probability**:
The weight $\mathcal P_{\bar bb}=\sum_{n=1}^N|\lambda_n|^2$ of the bare states in a normalised bound-state wave function, alongside the two-body ($\mathcal P_S$, $\mathcal P_D$) and three-body ($\mathcal P_{\text{3-body}}$) weights that complete it to 1.
_Avoid_: elementariness, $Z$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (104)–(106)

**S-wave compositeness**:
The sum $X_S=\mathcal P_S+\mathcal P_{\text{3-body},S}$ of the two- and three-body $S$-wave weights of a bound state.
_Avoid_: compositeness (alone), $X$
Status: agreed
Source: [@Zhang:2026iyr] v1, Eq. (107)

**Compact-dominated state**:
A bound state with $\mathcal P_{\bar bb}>1/2$, or a resonance whose pole moves continuously onto a bare level as the bare–continuum coupling $g\to0$; it is named after that bare state, e.g. the $\chi_{b1}(3P)$-dominated state at 10.544 GeV in the baseline fit.
_Avoid_: generic state, conventional quarkonium (for a dressed state)
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. IV D and Table V ("predominantly compact"); followup.tex §I–II ("generic bottomonium states"); the user, grilling 2026-10-28 ("P_bb̄ ≷ 1/2; resonances by trajectory")

**Molecule-dominated state**:
A bound state with $\mathcal P_{\bar bb}<1/2$, or a resonance whose pole does not end on a bare level as $g\to0$.
_Avoid_: molecular pole, pure molecule, dynamically generated state
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. IV D and Table V ("predominantly molecular"); followup.tex §I–II; the user, grilling 2026-10-28 ("P_bb̄ ≷ 1/2; resonances by trajectory")

**Bare–continuum coupling**:
The $n$-independent constant $g$ that multiplies the transition form factor between a bare state and the $S$-wave two-meson channel it couples to at LO.
_Avoid_: mixing coupling, $g_b$ (that is the axial coupling)
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (18), (52), (54); followup.tex §I, Eq. (1)

**Recoupling coefficient**:
The overlap of the static-limit light-cloud configuration $\Sigma_g^{+\prime}$ of total spin $J$ with a heavy-meson-pair partial-wave channel; its value for the $S$-wave channel ($1/\sqrt3$ for $1^{++}$) enters the bare–continuum coupling.
_Avoid_: spin factor, HQSS factor
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (17), (22); followup.tex §I

**Fit deviation**:
The root-mean-square deviation $\Delta M$ of the computed masses of the fitted states from their measured masses.
_Avoid_: $\Delta M$ as a scenario label, $\Delta m$ (that is $m_{B^*}-m_B$)
Status: agreed
Source: [@Zhang:2026iyr] v1, Eq. (94)

## Approximations and schemes

**LO BOχEFT**:
The potential $V=V^{\rm (OME)}+\sum_{n=1}^N V^{(\bar bb)}_n+C(\Lambda,N)$: full OME, $s$-channel exchange of the first $N$ bare states, and one non-derivative contact term in the $S$-wave channel, counted in powers of $Q/\Lambda_\chi$ with $\Lambda_\chi\approx1$ GeV.
_Avoid_: LO (without naming the expansion), quark model
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (7), (10), (83)

**Full OME**:
One-$\pi$ plus one-$\eta$ exchange in time-ordered perturbation theory, keeping the $B^*$–$B$ mass splitting, the recoil terms, and the energy dependence of the three-body propagators.
_Avoid_: OPE (when $\eta$ is included), static OPE, Yukawa potential
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (72)–(77), (82); Table VII, first row

**Sharp cutoff**:
The regulator: every loop momentum is integrated over $0\le q\le\Lambda$, with $\Lambda=4$ GeV in the baseline and $3$–$5$ GeV as the variation.
_Avoid_: form factor, regulator (alone)
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (86), (88)–(92); Sec. IV B; Table VI

**Tower truncation**:
Keeping the first $N$ bare states explicitly in the $s$-channel exchange and absorbing the rest into $C$; $N=4$ in the baseline, $N=4$–$7$ as the variation.
_Avoid_: cutoff (for $N$)
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. II C, Table IV

**Isospin limit**:
Charged and neutral heavy mesons share one mass, and the two-meson channels are isoscalar combinations. Computations use $m_B=5.27952$ GeV, $m_{B^*}=5.32475$ GeV, $m_\pi=138.039$ MeV, $m_\eta=548$ MeV (printed as 5.279 GeV, 5.325 GeV, 138 MeV).
_Avoid_: isospin-averaged threshold (without naming the masses)
Status: agreed
Source: [@Zhang:2026iyr] v1, Eqs. (2), (6), (13), (82); the user, grilling 2026-10-28 ("Code values everywhere"), values from code/HadronDynamics.jl/src/models/BOchiEFT/BOchiEFT.jl:43–45

**Spin-independent bare spectrum**:
At LO the quark–antiquark potential carries no spin dependence, so bare states with the same $n$ and $L=1$ share one reference mass and one wave function for every $J$. In the $1^{++}$ fit the $1/m_b^2$ spin-dependent shifts, constant within about 1 MeV over the states considered, are absorbed into $V_0$, and the quark-model parameters $m_b$, $\sigma$, $\gamma$, $V_0$ fixed there are used unchanged for every $J^{PC}$.
_Avoid_: centre-of-gravity spectrum (for the $1^{++}$ fit)
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. III A 1, App. B, Eqs. (B4), (B6); decisions/0004-quark-model-fixed.md; the user, slicing session 2026-10-28 ("Agree")

**Baseline fit**:
The LO parameter set $m_b=4.534$ GeV, $V_0=371$ MeV, $C=-16.27\ \text{GeV}^{-2}$ at $N=4$, $\Lambda=4$ GeV, obtained by minimising $\Delta M$ over the three measured $\chi_{b1}$ masses with the 10.513 GeV state taken as the $X_b$; it gives $\Delta M=0.0$ MeV. Full-precision values are in code/HadronDynamics.jl/data/bochiEFT/central.toml; the cutoff variation uses the refitted rows of Table VI.
_Avoid_: $\Delta M=0$ scenario, scenario (i)
Status: agreed
Source: [@Zhang:2026iyr] v1, Eq. (39), Tables III and VI; followup.tex §I; the user, grilling 2026-10-28

**Shallow-$X_b$ fit**:
The LO parameter set with $C$ tuned so that $E_B[X_b]=1$ MeV below the $B\bar B^*$ threshold and $V_0$ refitted to minimise $\Delta M$ at $m_b=4.534$ GeV: $C=2.66\ \text{GeV}^{-2}$, $V_0=362$ MeV, with the spurious pole projected out ($\Delta M=15.0$ MeV). It exists at $\Lambda=4$ GeV only; other cutoffs need a refit.
_Avoid_: $E_B=1$ MeV scenario, scenario (ii)
Status: agreed
Source: [@Zhang:2026iyr] v1, Table VIII and App. G; followup.tex §I; the user, grilling 2026-10-28

**Spurious-pole projection**:
Adding $\varepsilon\,\Psi^{\rm(spur)}_{\alpha'}(p')\Psi^{\rm(spur)}_\alpha(p)$ to the potential, with $\Psi^{\rm(spur)}$ the normalised two-meson wave function of the regulator-dependent deep pole and $\varepsilon=5$–$50$ GeV, to move that pole far above threshold.
_Avoid_: subtraction, removing the deep state (without the method)
Status: agreed
Source: [@Zhang:2026iyr] v1, Eq. (G1) and App. G

**Spurious pole**:
A pole whose binding momentum exceeds $\Lambda_\chi\approx1$ GeV, with $\mathcal P_{\bar bb}<1\%$ and a position that moves strongly with $\Lambda$: an artifact of the renormalised singular tensor force. A pole that continues from such a pole as $C$ varies at fixed $\Lambda$ is the same spurious pole, even where mixing with a nearby bare level raises its $\mathcal P_{\bar bb}$ above 1%, as in the shallow-$X_b$ fit; through an avoided crossing with a bare level the continuation follows the predominantly hadronic member of the two levels, not the adiabatic branch, which ends on the compact-dominated state. It is projected out when it lies above the lowest compact-dominated state of the sector ($\chi_{b1}(1P)$- or $\chi_{b2}(1P)$-dominated); otherwise it is kept and the shift its projection causes is reported.
_Avoid_: deep bound state, ghost
Status: agreed
Source: [@Zhang:2026iyr] v1, Sec. IV D, Fig. 5(a) and its caption ("the predominantly hadronic member of the two lowest levels"), App. G; the user, grilling 2026-10-28 ("Agree the rule"); the user, slice-02 session 2026-10-29 ("Add continuation in C"; "Follow hadronic member")

**Strict HQSS limit**:
All heavy-meson masses set to $\bar m_B=(m_B+3m_{B^*})/4\approx5.313$ GeV in every threshold, reduced mass, and TOPT offset, with the bare $\chi_{b2}$ masses equal to the bare $\chi_{b1}$ masses (any spin-dependent shift switched off) and $g$, $C$ unchanged.
_Avoid_: HQSS limit (for the Table VII variant, which changes only the TOPT offsets), $m_{B^*}=m_B$ (without saying where)
Status: agreed
Source: [@Zhang:2026iyr] v1, Table VII caption ($\bar m_B$), Sec. II F 1; the user, grilling 2026-10-28 (selected as a check); decisions/0004-quark-model-fixed.md; the user, slicing session 2026-10-28 ("Agree")
