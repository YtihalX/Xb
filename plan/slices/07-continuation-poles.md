# 07: Continuation III, poles and resonance couplings

Claim: We show that the pole search finds independently known $1^{++}$ test poles off the physical sheet. The search counts poles by the argument principle on boxes on each sheet and refines them by Newton. The test poles are a narrow $\chi_{b1}(3P)$-dominated test resonance, the same pole followed into the broad regime, and a virtual $X_b$. The resonance couplings (CONVENTIONS.md "Resonance couplings") satisfy the partial-width sum rule. Plan claim 2, third part.
- Test-only parameters, none of which enter a physics result:
  - $V_0$ shifts that put the $\chi_{b1}(3P)$-dominated pole near $+20$ MeV (sheet $(-,+)$) and near $+70$ MeV (sheet $(-,-)$), with $g$ scaled so that $\Gamma\approx1$ MeV;
  - a $g$-scan upward from there;
  - the shallow-$X_b$ fit with $C$ changed until the $X_b$ is a virtual state with $\kappa_v\ll\kappa_{\rm lhc}=65$ MeV ([@Zhang:2026iyr] v1, Eq. (9)).
- Escalation: a target pole with no admissible contour is reported with its obstruction, and the work stops for the user's decision (decisions/0005).
- The worked note `notes/05-continuation.md` gains the section on the pole search and the test poles.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "Continuation to other sheets", "Resonance couplings", "Pole position and Riemann sheets", "Multichannel S matrix and unitarity", "On-shell amplitude and effective-range expansion".
- [GLOSSARY.md](../../GLOSSARY.md): "Baseline fit", "Shallow-$X_b$ fit", "Compact-dominated state", "Bare–continuum coupling".
- [decisions/0005](../../decisions/0005-continuation-method.md).
Checks (tolerances from decisions/0005: poles to 0.1 MeV, the expansion checks within their next-order estimates; each executable also gets a missing-result red):
- Narrow test resonance, real axis:
  - Route: $M$ and $\Gamma$ from the speed plot of the package's real-axis $S$ matrix.
  - Expected: the pole agrees within 0.1 MeV.
- Narrow test resonance, $g^2$ width:
  - Route: the $O(g^2)$ pole shift from the OME-dressed self-energy of the bare level on the real axis, $\Sigma(E_n+i0)$. Poles at two small values of $g$ estimate the $O(g^4)$ term.
  - Expected: agreement within that estimate.
- $g$-scan:
  - Route: the pole followed while $g$ rises from its test value until $|\operatorname{Im}k_\alpha|$ exceeds $m_\pi$.
  - Expected: a continuous trajectory, and contour independence at every step. The on-shell-point route agrees up to $|\operatorname{Im}k_\alpha|=m_\pi$ and is not used beyond it.
- Virtual $X_b$:
  - Route: the pole of the $S$-wave effective-range expansion, $1/a+\frac12rk^2-ik=0$, with $a$ and $r$ from the real-axis amplitude (the package's `ere` mode).
  - Expected: agreement within the shape-term estimate.
- Counting:
  - Route: the argument-principle count on each box against the poles Newton finds there.
  - Expected: equal counts.
- Couplings:
  - Route: for the narrow test resonance, $\sum_\alpha\Gamma_\alpha$ with $\Gamma_\alpha=2\rho_\alpha(M)|g_\alpha|^2$ against $\Gamma$ from the pole; $g_\alpha$ from both routes.
  - Expected: the sum rule holds within 0.1 MeV, and the routes agree to $10^{-6}$ relative.
Output: the $1^{++}$ test poles and couplings, with a figure of the test poles and their $g$-scan trajectory → `paper/sections/app-continuation.tex` (tests part)
Blocked by: 06
Status: blocked
