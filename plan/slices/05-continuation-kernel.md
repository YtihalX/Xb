# 05: Continuation I, the continued kernel and its singularity map

Claim: We show where the thresholds, right-hand cuts (rhc) and left-hand cuts (lhc) of the $2^{++}$ amplitude lie in the complex momentum plane of each channel, and where the integrand of the Lippmann–Schwinger equation is singular in the loop-momentum plane. We then continue the kernel there. The kernel has three parts: the angular moments with split logarithms (CONVENTIONS.md "Continued angular moments"), the three-body singularities $s_\pm+\nu_\beta=0$, located for every channel pair and time ordering, and $f_n$ at complex momentum (CONVENTIONS.md "Bare-state term off the real axis"). No pole position is assumed: the $X_{b2}$ is not yet determined. Plan claim 2, first part.
- The worked note `notes/05-continuation.md` first reproduces [@Wu:2026wxb] v1, App. D: the $J(p;m)$ example of its Eq. (D2) in cases (a)–(d). It then mirrors the example to sheet II ($p$ in the fourth quadrant), then treats our TOPT kernel, with a walkthrough of the code. Slices 06 and 07 add their sections to the same note.
- The paper is in Zotero as `Wu:2026wxb`, and its source is pinned to v1 in `literature/Wu:2026wxb/src/`. Its bridge is written here (plan Notes, "Bridges to write when first used").
- Package changes:
  - `ExchangeMoments.jl` writes every moment through $L_+-L_-$; this replaces the log of the ratio at line 19.
  - An independent continuity tracker, used only in tests, follows $s_\pm$ and $L_\pm$ along a path from a real reference configuration.
  - A three-body singularity locator; §II reuses it (decisions/0005).
  - The coordinate form factors accept complex $p$ (the guard at `cornell_coordinate.jl:233-237` is lifted).
  - The `adjoint`/`conj` of $f_n$ at `MomentumDynamics.jl:124, 204, 231, 251` become transposes.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "Continuation to other sheets", "Bare-state term off the real axis", "Continued angular moments", "Projected OME potential", "Reduced masses and TOPT energy offsets", "Energy origin and on-shell momentum", "Pole position and Riemann sheets", "Bare–continuum vertex".
- [GLOSSARY.md](../../GLOSSARY.md): "Angular moment", "Full OME", "Isospin limit".
- [decisions/0005](../../decisions/0005-continuation-method.md).
Checks (tolerances from decisions/0005: $10^{-6}$ relative unless stated; each executable also gets a missing-result red, as in slice 04):
- The App. D example:
  - Route: $J(p;m)$ evaluated on every contour App. D gives for its cases: $C_{R0}$; $C_R$; $C_R'$ with the cut-edge term; $C_L$ with the $C_S$ correction; $C_L'$ with Eq. (D4). Then again on the mirrored contours for $p$ in the fourth quadrant.
  - Expected: for each $p$, all contours agree.
  - Broken-result red: the principal log of the ratio, as written in Eq. (64) of [@Wu:2026wxb] v1, disagrees in the cases where App. D says it must.
- Continued moments against the tracker:
  - Route: the split-log moments against the independent tracker at every point of test contours whose depths go past $m_\pi$. This covers every $1^{++}$ and $2^{++}$ entry, $\pi$ and $\eta$ separately, at complex $E$ on the adjacent sheet of every $2^{++}$ region between consecutive thresholds.
  - Expected: agreement.
  - Broken-result red: restore the log of the ratio (`ExchangeMoments.jl:19`); the check must fail where the phases wrap.
- Angular quadrature:
  - Route: direct Gauss–Legendre $x$-quadrature of the complex TOPT integrand at complex $(p',p,E)$, at every point where the straight $x$ path crosses no cut of the integrand. That condition is asserted per point.
  - Expected: agreement with the closed form.
- Three-body locator:
  - Route: the locator's zeros of $s_\pm+\nu_\beta$ against a brute-force zero search on a fine grid. Separately, its real-axis limit: the lowest real $E$ at which a zero reaches real momenta.
  - Expected: positions within $10^{-6}$ GeV. The real-axis limit equals the three-body threshold of each entry's intermediate state; the lowest is $B\bar B\pi$, at $+92.8$ MeV above $m_B+m_{B^*}$ in $1^{++}$ and $+47.6$ MeV above $2m_{B^*}$ in $2^{++}$, with the masses of GLOSSARY.md "Isospin limit".
- Complex form factors:
  - Route: $f_n(p)$ from [@Zhang:2026iyr] v1, Eq. (A10), at complex $p$, against the matched-tail evaluator for $N\le4$. Box-size and tail convergence for $N=4$–$7$. Schwarz reflection $f_n(p^*)^*=f_n(p)$. All on a grid of complex momenta with $|\operatorname{Im}p|\le1$ GeV and $\operatorname{Re}p\le\Lambda$.
  - Expected: agreement.
- The $2^{++}$ singularity map (the user's request):
  - Planes: the complex on-shell momentum plane $k_\alpha$ of each distinct threshold. That gives three panels: $k_{B^*\bar B^*}$ (shared by $^5S_2$, $^1D_2$, $^5D_2$, $^5G_2$), $k_{B\bar B^*}$ and $k_{B\bar B}$. In each, the upper half-plane is the physical sheet and the lower half-plane the sheet on which that channel is flipped; the slice-06 contours are drawn on the same planes.
  - Thresholds, as branch points $k_\alpha=\pm\sqrt{2\mu_\alpha(E_t-\delta_\alpha)}$ (energies relative to $2m_{B^*}$): the two-body $B\bar B$ ($-90.5$ MeV), $B\bar B^*$ ($-45.2$ MeV) and $B^*\bar B^*$ (0), and the three-body $B\bar B\pi$ ($+47.6$ MeV), $B\bar B^*\pi$ ($+92.8$ MeV) and $B^*\bar B^*\pi$ ($+138.0$ MeV).
  - rhc: the unitarity cut from each threshold, two-body and three-body.
  - lhc: the tree-level left-hand cuts of the on-shell projected OME for each $2^{++}$ transition (VV→VV, PV→PV, PV↔VV, PP↔VV), $\pi$ and $\eta$ separately, computed from the full TOPT kernel, including any part that lies above a lower threshold or off the real axis.
  - No pole positions are plotted. Claims 3–4 add the poles they find.
- Left-hand cuts, literature value:
  - Route: the same code run in $1^{++}$ gives the start of the $\pi$- and $\eta$-exchange left-hand cuts.
  - Expected: $\kappa_{\rm lhc}=65$ and $273$ MeV ([@Zhang:2026iyr] v1, Eq. (9)), to the printed digits.
- Left-hand cuts, discontinuity scan:
  - Route: the on-shell projected OME of each transition evaluated just above and just below scan lines across each $k_\alpha$ plane.
  - Expected: it jumps exactly where a cut is drawn, within the scan step, and nowhere else.
Output: the continued kernel, the App. D reproduction, and the $2^{++}$ singularity map → `paper/sections/app-continuation.tex` (kernel part); the three momentum-plane panels → `paper/figures/`
Blocked by: 04
Status: claimed
