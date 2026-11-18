# Talk, Task 4 (one-meson exchange): proposal

Status: applied in full on 2026-11-15 at the user's request: first the closing slide and the backup projection, then the rest ("apply all the ome-talk-plan"). `slides/BOchiEFT.typ` carries it; the step numbers below are those of the rebuilt Task 4.
Scope: what to say in Task 4 and which slides carry it. Numbers are from `../../Xb.tex` (line numbers given). Items marked [arithmetic] are computed here from the paper's numbers and are not in the paper.
Deck notation stays as in `NOTEBOOK.md`, Decisions, Talk notation.

## Diagnosis

Tasks 1–3 each end in a result that is used later: $\hat V^{(\bar bb)}(E)$, $U$, $|g|=57$ MeV. Task 4 is ten derivation steps whose announced result (slide "What to do next?") is $3V(m_\pi)+\frac13V(m_\eta)$, the isospin bookkeeping. An audience with hadron/EFT knowledge (the assumption of the earlier deck, `speech.tex`, Delivery brief) knows LO heavy-meson ChPT. It does not know what OME does in this calculation, and no slide says it.

## Message

Full OME is the long-range, parameter-free part of the interaction. At LO it is the only term with $D$-wave channels and the only term with three-body states $B^{(*)}\bar B^{(*)}\phi$. So it accounts for two of the four terms of the Task 6 normalisation $1=\mathcal P_{\bar bb}+\mathcal P_S+\mathcal P_D+\mathcal P_{\text{3-body}}$: for the $X_b$, $\mathcal P_D=36\%$ and $\mathcal P_{\text{3-body}}=21\%$ (Xb.tex:1418–1423).

## Claims and sources

### 1. OME is LO and has to be explicit (new opening slide)

- Counting: two vertices $\mathcal O(Q)$ and a propagator $\mathcal O(Q^{-2})$ give $\mathcal O(Q^0)$, the order of $C$; OME is well defined only together with $C$ (Xb.tex:300).
- Left-hand cut: $\kappa_{\rm lhc}=\frac12\sqrt{m_\phi^2-\Delta m^2}=65$ MeV ($\pi$) and $273$ MeV ($\eta$), against $\kappa_{X_b}=695$ MeV. Neither exchange can be expanded in contact terms at the $X_b$, so both are explicit (Xb.tex:303–316, 1256).
- [arithmetic] In energy, $E=-\kappa_{\rm lhc}^2/2\mu$: the branch points lie $0.80$ MeV ($\pi$) and $14.1$ MeV ($\eta$) below the $B\bar B^*$ threshold, the $X_b$ 91 MeV below.
- No free parameter: $g_b=0.56$ from lattice QCD, $F_\pi=92.2$ MeV, the $\eta$ coupling by SU(3) (Xb.tex:979–984, 1654).
- Why the tail matters: BOEFT models the long-range part. With the $X(3872)$ kept shallow, changing the assumed pion range from $1/(2m_\pi)$ to $1/m_\pi$ moved its $X_b$ binding energy from 15 MeV to 1.1 MeV (Xb.tex:1637–1645 and the footnote there). In BOχEFT the long-range parts of the $\Sigma_g^{+\prime}$ and $\Pi_g$ levels are OME (Xb.tex:618–620).

### 2. Two $P$-wave vertices give the tensor force, hence three channels (Step 2)

- Both vertices are $\propto\boldsymbol q$ (Xb.tex:1005–1008). Two of them give $q_iq_j$, a central part plus a tensor part; the tensor part drives the $S$–$D$ transitions and couples the three channels (Xb.tex:1054–1070).
- $V^{(\bar bb)}$ and $C$ act only in $^3S_1$ (Xb.tex:1127–1131): every entry of $V_{\alpha'\alpha}$ outside the 11 corner is OME.
- Result: $\mathcal P_D=36\%$ in the $X_b$, against about 5% in the deuteron (Xb.tex:1446).
- Wording: "the two $P$-wave vertices mix $S$ and $D$", not "the $B^*$ polarisation vector does" (`main.tex`:817).

### 3. TOPT denominators: nonlocal, energy dependent, three-body states (Steps 3–5 and the new Step 6)

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

Rough weights add up to about 9 minutes [estimate, not rehearsed].

| Slide | Change | Weight |
|---|---|---|
| What to do next? | Task 4 line: the $B\bar B^*\to B\bar B^*$ kernel with its tensor numerator and three-body denominators marked, instead of $3V(m_\pi)+\frac13V(m_\eta)$ (done) | – |
| Why one-meson exchange, and why explicitly | claim 1 (new, done) | 90 s |
| Step 1: the LO chiral Lagrangian | old Steps 1–2 merged; expanded Lagrangian, $g_b$, $F_\pi$ kept (done) | 30 s |
| Step 2: vertices | claim 2 (done) | 90 s |
| Steps 3–4: TOPT, four classes | kept | 60 s |
| Step 5: energy denominators | static-limit bullet moved to Step 6 (done) | 60 s |
| Step 6: Full OME and its static limit | claim 3 (new, done) | 60–90 s |
| Steps 7–9: kernels, six entries, isospin | kept, shown without reading; the projection is backup B1 (done) | 60 s in total |
| What OME does to the $X_b$ | claims 2–4 in numbers (new, done) | 90 s |

## Draft lines (adopted as speaker notes on 2026-11-15; the deck holds the current wording)

- Why OME: "The $s$-channel part was the BO half of the theory. This is the chiral half: the long-range force between the two mesons. In BOEFT this tail is modelled, and the $X_b$ binding energy moved from 15 to 1 MeV when the pion range was changed. Here it comes from the chiral Lagrangian with no free parameter. It is of the same order as the contact term, and it cannot be replaced by a contact term: its left-hand cut starts at 65 MeV for the pion and 273 MeV for the eta, and the $X_b$ has a binding momentum of 695 MeV."
- Lagrangian: "This is leading-order heavy-meson chiral perturbation theory, taken as given. Two numbers enter, $g_b$ from the lattice and $F_\pi$. After the spin trace there are two vertices, $B^*B\phi$ and $B^*B^*\phi$, and no $BB\phi$ vertex."
- Vertices: "Both vertices are proportional to $\boldsymbol q$: the Goldstone boson leaves in a $P$ wave. Two of them give $q_iq_j$, a scalar plus a rank-2 tensor. The tensor part changes $L$ by two units. This is the only place in the LO potential where the $D$-wave channels enter; the bottomonium exchange and the contact term act in the $S$ wave only."
- TOPT, four classes: "The Feynman propagator has two poles; they are the two time orderings. In each ordering a three-particle state lives between the vertices, and there are four kinds."
- Denominators: "Each ordering gives the energy of that three-body state minus the total energy. Three things sit in $\mu_\beta$: the $B^*$–$B$ mass difference, the kinetic energies of the heavy mesons, and the energy $E$. So this potential depends on $p$ and $p'$ separately, and on the energy."
- Static limit: "If I drop the recoil terms and $E$, the first two orderings combine into the static form, with $m_\pi^2-\Delta m^2$ in place of $m_\pi^2$. For $B$ mesons this stays positive. For $D$ mesons it is negative: $D\bar D\pi$ can go on shell and the exchange gets an imaginary part. We keep the full form so that the same formalism works in the charm sector. And the energy dependence is what we differentiate in Task 6 to get the three-body weight."
- Kernels to isospin: "The four kernels are vertex times vertex times denominators. Projected onto the three channels (the projection is in the backup), these are the six independent entries: $V_{11}$ is $S$ to $S$, and $V_{12}$, $V_{13}$ exist only because of the tensor force. Isospin gives 3 for the pion and one third for the eta."

## Likely questions

- One $S$-wave contact term for a singular tensor force? No lower-lying channel here, unlike the $Z_b$ case; refitted at $\Lambda=3$–5 GeV, the predicted $\chi_{b1}(3P)$-dominated state moves by 1 MeV (Xb.tex:1073–1080, 1477–1482).
- Why keep the $\eta$? Its left-hand cut, 273 MeV, is also below $\kappa_{X_b}$ (Xb.tex:315–316); weight $\frac13$ against 3 for the pion.
- How much do $\Delta m$, recoil and $E$ matter for bottom? Xb.tex:1694–1709: the $\chi_{b1}(3P)$-dominated state within 3 MeV after the refit, $X_S$ 39–53%.
- Is $\mathcal P_{\text{3-body}}$ a probability of finding a pion? It is the weight the normalisation assigns to $-\partial_E\hat V^{\rm(OME)}$ in the paper's enlarged Hilbert space; the interpretation is conditional (above).
- Why TOPT? It is the Feynman propagator split into its two poles (Step 3); it keeps the three-body states explicit, which the on-shell $D\bar D\pi$ case and the Task 6 normalisation both need.

## Choices for the user

1. Settled (user, 2026-11-15): the closing slide with numbers.
2. Settled (user, 2026-11-15): the projection in a backup section.
3. Settled (user, 2026-11-15, "apply all"): both [arithmetic] remarks are used, on the "Why" slide and on Step 6.

## Not in this proposal

No new physics, no notation change, no change to Tasks 1–3, 5, 6.
