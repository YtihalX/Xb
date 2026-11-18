# Talk, Task 4 (one-meson exchange): proposal

Status: in `slides/BOchiEFT.typ` since 2026-11-15, in the compact form the user asked for the same day: slides that only state definitions are backup. Since 2026-11-16 a power-counting block stands in front of Task 4; claim 1 below is its first slide. The user removed the roadmap before Task 4, requested the trace-evaluated Lagrangian before the vertices, then merged those two slides. Task 4 now has three numbered steps and the closing slide. Earlier versions: `../../history/2026-11-15-BOchiEFT-task4-steps/` (nine steps), `../../history/2026-11-16-BOchiEFT-roadmap/` (with the roadmap), `../../history/2026-11-16-BOchiEFT-merged-vertices/` (separate Lagrangian and vertices slides).
Scope: what to say in Task 4 and which slides carry it. Numbers are from `../../Xb.tex` (line numbers given). Items marked [arithmetic] are computed here from the paper's numbers and are not in the paper.
Deck notation stays as in `NOTEBOOK.md`, Decisions, Talk notation.

## Diagnosis

Tasks 1–3 each end in a result that is used later: $\hat V^{(\bar bb)}(E)$, $U$, $|g|=57$ MeV. Task 4 was ten derivation steps whose announced result (slide "What to do next?") was $3V(m_\pi)+\frac13V(m_\eta)$, the isospin bookkeeping. An audience with hadron/EFT knowledge (the assumption of the earlier deck, `speech.tex`, Delivery brief) knows LO heavy-meson ChPT. It does not know what OME does in this calculation, and no slide said it. The user, 2026-11-15: "merely reading the definitions is meaningless". So a slide stays in the main flow only if it makes a claim.

## Message

Full OME is the long-range, parameter-free part of the interaction. At LO it is the only term with $D$-wave channels and the only term with three-body states $B^{(*)}\bar B^{(*)}\phi$. So it accounts for two of the four terms of the Task 6 normalisation $1=\mathcal P_{\bar bb}+\mathcal P_S+\mathcal P_D+\mathcal P_{\text{3-body}}$: for the $X_b$, $\mathcal P_D=36\%$ and $\mathcal P_{\text{3-body}}=21\%$ (Xb.tex:1418–1423).

## Claims and sources

### 1. OME is LO and has to be explicit (first slide of the power-counting block)

- Counting: two vertices $\mathcal O(Q)$ and a propagator $\mathcal O(Q^{-2})$ give $\mathcal O(Q^0)$, the order of $C$; OME is well defined only together with $C$ (Xb.tex:300).
- Left-hand cut: $\kappa_{\rm lhc}=\frac12\sqrt{m_\phi^2-\Delta m^2}=65$ MeV ($\pi$) and $273$ MeV ($\eta$), against $\kappa_{X_b}=695$ MeV. Neither exchange can be expanded in contact terms at the $X_b$, so both are explicit (Xb.tex:303–316, 1256).
- [arithmetic] In energy, $E=-\kappa_{\rm lhc}^2/2\mu$: the branch points lie $0.80$ MeV ($\pi$) and $14.1$ MeV ($\eta$) below the $B\bar B^*$ threshold, the $X_b$ 91 MeV below.
- No free parameter: $g_b=0.56$ from lattice QCD, $F_\pi=92.2$ MeV, the $\eta$ coupling by SU(3) (Xb.tex:979–984, 1654). The values and field conventions remain in backup B1, not as repeated bullets on the merged slide.
- Why the tail matters (third slide of the block, with the BO potentials): BOEFT models the long-range part. With the $X(3872)$ kept shallow, changing the assumed pion range from $1/(2m_\pi)$ to $1/m_\pi$ moved its $X_b$ binding energy from 15 MeV to 1.1 MeV (Xb.tex:1637–1645 and the footnote there). In BOχEFT the long-range parts of the $\Sigma_g^{+\prime}$ and $\Pi_g$ levels are OME (Xb.tex:618–620).

### 2. Two $P$-wave vertices give the tensor force, hence three channels (Step 1)

- Both vertices are $\propto\boldsymbol q$ (Xb.tex:1005–1008). Two of them give $q_iq_j$, a central part plus a tensor part; the tensor part drives the $S$–$D$ transitions and couples the three channels (Xb.tex:1054–1070).
- $V^{(\bar bb)}$ and $C$ act only in $^3S_1$ (Xb.tex:1127–1131): every entry of $V_{\alpha'\alpha}$ outside the 11 corner is OME.
- Result: $\mathcal P_D=36\%$ in the $X_b$, against about 5% in the deuteron (Xb.tex:1446).
- Wording: "the two $P$-wave vertices mix $S$ and $D$", not "the $B^*$ polarisation vector does" (`main.tex`:817).

### 3. TOPT denominators: nonlocal, energy dependent, three-body states (Steps 2 and 3)

- Four classes of three-body intermediate states; $D_\beta=1/(2E_\phi[E_\phi+\mu_\beta])$, with $\Delta m$, the recoil terms and $E$ inside $\mu_\beta$ (Xb.tex:1012–1050). The kernel depends on $p$ and $p'$ separately and on $E$.
- Two differences from the nucleon case (Xb.tex:1103–1107): $\Delta m$ lowers the effective exchanged mass in ordering (1) and raises it in (2); the recoil terms make the propagator nonlocal and are essential when the three-body state can go on shell.
- Static limit, recoil and $E$ dropped: $D_1+D_2\to[\boldsymbol q^2+\mu_\pi^2]^{-1}$ with $\mu_\pi^2=m_\pi^2-\Delta m^2$. It is positive for $B$ mesons and negative for $D$ mesons, where $D\bar D\pi$ goes on shell and the exchange acquires an imaginary part (Xb.tex:2049–2072). Full OME is kept so that one formalism covers both sectors (Xb.tex:1109–1114).
- Size in the bottom sector (Xb.tex:1663–1709): with $\Delta m$, recoil and $E$-dependence switched off in all combinations and $C$, $V_0$ refitted, the $\chi_{b1}(3P)$-dominated mass moves within 3 MeV and $X_S[X_b]$ between 39% and 53%. The $E$-dependence is the largest effect on $X_S$ (39–42% with it, 50–53% without); without recoil $C$ changes from $-16.27$ to $2.21$ GeV$^{-2}$.
- [arithmetic] At the $X_b$ pole with $p=p'=\kappa_{X_b}$: recoil $\approx91$ MeV and $-E=91$ MeV, against $\Delta m=46$ MeV and $m_\pi=138$ MeV; $\mu_1\approx+137$ MeV where the static limit has $-46$ MeV.
- The $E$-dependence is what Task 6 differentiates: $\mathcal P_{\text{3-body}}=-\langle\Psi_M|\partial_E\hat V^{\rm(OME)}|\Psi_M\rangle$ (Xb.tex:2447–2463), 21% for the $X_b$. Conditional on the paper's spectral identity, as stated on Task 6, Step 1 (`NOTEBOOK.md`, Open questions, Three-body probability prescription).

### 4. The cost: the tensor force is singular (closing slide)

- $1/r^3$ in the local static limit. No further LO counterterm is needed here, because there is no lower-lying channel, unlike the $Z_b$ study (Xb.tex:1070–1080).
- $C(\Lambda)=10.55,\ -16.27,\ -0.67$ GeV$^{-2}$ at $\Lambda=3,4,5$ GeV, with $C$, $m_b$ and $V_0$ refitted at each $\Lambda$ to the three measured masses; the predicted $\chi_{b1}(3P)$-dominated state moves by 1 MeV and every $\mathcal P_{\bar bb}$ by at most 1% (Xb.tex:1447–1448, 1477–1482). Tensor-off: $5.887,\ 6.159,\ 6.216$ GeV$^{-2}$ (Xb.tex:2241–2243).
- Spurious pole at 8.958–9.399 GeV for $\Lambda=3$–5 GeV, absent for $\Lambda\le1.25$ GeV; projecting it out changes the masses by less than 1 MeV (Xb.tex:1450–1455, 2581–2591).
- Tensor-off refit: the same three fitted masses, the $\chi_{b1}(3P)$-dominated state at 10.548 instead of 10.544 GeV, $X_S[X_b]=90\%$ instead of 42% (Xb.tex:2183–2246).

## Slides, in order

The talk runs: the recap slide (the LO potential), the power-counting block, then Task 4. Rough weights add up to about 13 minutes [estimate, not rehearsed].

Power-counting block, five slides, in the order of `main.tex`, Part "Power counting"; every statement is in `../../Xb.tex`, Sects. II A–II C, II F 2 and III B:

| Slide | Claim | Weight |
|---|---|---|
| Power counting: OME is $\mathcal O(Q^0)$ and explicit | claim 1, with a Feynman diagram of $B\bar B^*\to B^*\bar B$ that carries the order of each vertex and of the propagator; the isoscalar weights 3 ($\pi$) and $\frac13$ ($\eta$) are stated here | 90 s |
| Power counting: bottomonium exchange | vertex $\mathcal O(Q^0)$; the propagator is $\mathcal O(Q^{-2})$ for a bare state within $Q^2/(2\mu)$ of threshold and $\mathcal O(Q^0)$ for one $\gtrsim\Lambda_\chi$ away; all $n\le N$ are kept (Xb.tex:318–327). Table II gives the displayed 1P–5P bare energies for the quark–antiquark fit with $V_0=353$ MeV (Xb.tex:678–700). At $N=4$, the first omitted level is $E_{5P}=+0.444$ GeV: for $|E|\ll E_{5P}$, $1/(E-E_{5P})=-E_{5P}^{-1}[1+E/E_{5P}+\cdots]$, whose leading constant goes into $C$ at $\mathcal O(Q^0)$. The numerical gap alone does not fix the counting | 60 s |
| Matching with BO: central and tensor potentials | $V(r)=V_C\mathbb 1+V_T\times$(traceless matrix): only the $\Sigma_g^{+\prime}$–$\Pi_g$ splitting mixes partial waves; long range from OME, short range from contact terms; the BOEFT comparison (Xb.tex:541–583, 618–627) | 90 s |
| Matching with BO: one $S$-wave contact term at LO | $j_L(x)\sim x^L$: short-range pieces scale as $p'^{L_{\alpha'}}p^{L_\alpha}$, so $C$ acts only in $V_{11}$ (Xb.tex:610–636, 1127–1131) | 60–90 s |
| Matching with BO: the other contact terms are suppressed | $V_T=b_Tr^2+c_Tr^4$, moments $C^<_{T,n}$, $V^<_{13}=-\sqrt3V^<_{12}$; each multipole order costs $(\Lambda_{\rm QCD}/\Lambda_\chi)^2\sim Q^2$; the relations do not replace renormalisation (Xb.tex:638–670) | 90 s |

Task 4, four slides:

| Slide | Claim | Weight |
|---|---|---|
| Step 1: Lagrangian, vertices and tensor force | the full trace-evaluated Lagrangian, both vertex rules, then the central/tensor decomposition of $q_iq_j$ and its $S$–$D$ consequence. Repeated definitions, coupling-value bullets, sign-convention detail and the separate channel box are removed | 90 s |
| Step 2: The denominators; three-body states | between the vertices sit three particles; $\mu_\beta$ holds the mass splitting, the recoil and $E$; with Step 1 this gives the kernel | 90 s |
| Step 3: Full OME and its static limit | claim 3 | 60–90 s |
| What OME does to the $X_b$ | claims 2–4 in numbers | 90 s |

Backup, in the order of the derivation: B1 the LO chiral Lagrangian, B2 TOPT from the Feynman propagator, B3 the four classes of intermediate states, B4 energy denominators (all four $\mu_\beta$), B5 the four kernels, B6 partial-wave projection, B7 the six partial-wave entries, B8 isospin factors.

Speaker notes are in the deck. In the power-counting block they are the user's text from `main.tex`, Part "Power counting", with typos corrected; in Task 4 each note says the slide's claim, not its definitions.

## Likely questions

- One $S$-wave contact term for a singular tensor force? No lower-lying channel here, unlike the $Z_b$ case; refitted at $\Lambda=3$–5 GeV, the predicted $\chi_{b1}(3P)$-dominated state moves by 1 MeV (Xb.tex:1073–1080, 1477–1482).
- Why keep the $\eta$? Its left-hand cut, 273 MeV, is also below $\kappa_{X_b}$ (Xb.tex:315–316); weight $\frac13$ against 3 for the pion.
- How much do $\Delta m$, recoil and $E$ matter for bottom? Xb.tex:1694–1709: the $\chi_{b1}(3P)$-dominated state within 3 MeV after the refit, $X_S$ 39–53%.
- Is $\mathcal P_{\text{3-body}}$ a probability of finding a pion? It is the weight the normalisation assigns to $-\partial_E\hat V^{\rm(OME)}$ in the paper's enlarged Hilbert space; the interpretation is conditional (above).
- Why TOPT? It is the Feynman propagator split into its two poles (backup B2); it keeps the three-body states explicit, which the on-shell $D\bar D\pi$ case and the Task 6 normalisation both need.

## Choices for the user

1. Settled (user, 2026-11-15): the closing slide with numbers.
2. Settled (user, 2026-11-15): the projection in a backup section.
3. Settled (user, 2026-11-15, "apply all"): both [arithmetic] remarks are used, as the energy row of the left-hand-cut axis on the first power-counting slide and on Step 3.
4. Settled (user, 2026-11-15: "merely reading the definitions is meaningless", about the Lagrangian, TOPT, four-classes, denominator, kernel, partial-wave and isospin slides): the detailed derivation is backup; what Step 3 and Task 6 need from it ($D_\beta$, $\mu_{1,2}$, the kernel) is on Step 2. The Lagrangian is now also on the merged main-flow slide (items 6–7).
5. The slide "Why one-meson exchange, and why explicitly" is the first slide of the power-counting block (assistant, 2026-11-16). The user has since asked for a diagram on that slide.
6. Settled (user, 2026-11-16): a Feynman diagram of OME on the first power-counting slide; no roadmap before Task 4; the Lagrangian after the spin traces before the vertices.
7. Settled (user, 2026-11-16: "T4S1 and T4S2 can be merged into one, maybe delete something"): one slide, keeping the Lagrangian and both vertex rules but cutting repeated definitions and bullets; the tensor-force argument stays on that slide.

## Not in this proposal

No new physics, no notation change, no change to Tasks 1–3, 5, 6.
