# 06: Continuation II, the LSE on admissible contours

Claim: We show that the Lippmann–Schwinger equation solved on an admissible contour (CONVENTIONS.md "Continuation to other sheets") gives $T^{(s)}$ on every sheet. It reduces to the real-axis solution, does not depend on the contour, and agrees with the on-shell-point route where $|\operatorname{Im}k_\alpha|<m_\pi$. Built and tested in $1^{++}$. Plan claim 2, second part.
- Contour: one contour for all channels, from $0$ to $\Lambda$ with $\operatorname{Re}q$ increasing, fixed per search box and chosen from the slice-05 singularity map.
- A virtual state near the negative imaginary axis needs a short excursion into $\operatorname{Re}q<0$. That excursion stays shallower than $m_\pi/2$, so it is allowed only for $\kappa_v<m_\pi/2$.
- Package:
  - Contour grids.
  - The sheet is passed as the sign tuple of CONVENTIONS.md "Pole position and Riemann sheets", with no global "second sheet", as CornellModel's `flipped_channels` does.
  - The on-shell-point route takes complex $k_\alpha$: the subtraction term of `real_axis_grid` (`MomentumDynamics.jl:301-316`) is continued, with the sign of $\operatorname{Im}k_\alpha$ set by $s$.
  - A request with no admissible contour fails and names the obstruction (decisions/0005).
- The worked note `notes/05-continuation.md` gains the section on the continued equation and its code.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "Continuation to other sheets", "Bare-state term off the real axis", "Continued angular moments", "Lippmann–Schwinger equation", "Loop measure and regulator", "Pole position and Riemann sheets", "Multichannel S matrix and unitarity".
- [GLOSSARY.md](../../GLOSSARY.md): "Baseline fit", "Shallow-$X_b$ fit", "Sharp cutoff".
- [decisions/0005](../../decisions/0005-continuation-method.md).
Checks (tolerances from decisions/0005: on-shell $T$ to $10^{-6}$ relative, poles to 0.1 MeV; each executable also gets a missing-result red):
- Reduction on the real axis:
  - Route: as $E$ approaches the real axis from the physical sheet, the contour $T$ reproduces the package's real-axis $1^{++}$ $T$. The comparison runs from the $B\bar B^*$ threshold to the first omitted threshold, 92.8 MeV above it.
  - Expected: agreement.
- Unitarity of the real-axis $T$:
  - Route: $\operatorname{Im}(T^{-1})_{\alpha'\alpha}=\rho_\alpha\delta_{\alpha'\alpha}$ over the open channels.
  - Expected: residual within tolerance.
- Contour against on-shell point:
  - Route: on-shell $T^{(s)}$ at complex $E$ on $(-,+)$ and $(-,-)$ with $|\operatorname{Im}k_\alpha|<m_\pi$, from both routes.
  - Expected: agreement.
  - Broken-result red: a contour that stays above the flipped $k_\alpha$ while $s$ says otherwise must fail.
- Contour independence:
  - Route: on-shell $T^{(s)}$, and the determinant on search boxes, under changes of the contour's depth, starting angle and return point within the admissible set.
  - Expected: no change beyond tolerance.
  - Broken-result reds: keeping `adjoint`/`conj` of $f_n$ on the contour must fail in the $S$-wave channel; a contour deeper than the three-body locator allows must fail.
- Table V on the contour:
  - Route: the four baseline-fit bound states found on a deformed contour, against the real-axis `bound_pole` values.
  - Expected: within 0.1 MeV.
- Separable model:
  - Route: a two-channel Yamaguchi model with closed-form $T$, solved by the same contour and sheet machinery.
  - Expected: its poles on every sheet within 0.1 MeV of the closed form.
- Figures (the user's request): the contour as it is continued, drawn on the slice-05 momentum planes. For each $2^{++}$ region between consecutive thresholds, on that region's adjacent sheet, the contour is shown at several stages as $E$ moves from the real axis down past $|\operatorname{Im}k_\alpha|=m_\pi$. The same is done for the $1^{++}$ test energies of slice 07. These are region-by-region stages, not assumed pole positions. The figures show that no singularity crosses the contour.
Output: the continuation method and its checks, and a figure of the continued and real-axis $T$ on the real axis → `paper/sections/app-continuation.tex` (method part); the contour figures → `paper/figures/`
Blocked by: 05
Status: blocked
