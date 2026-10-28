# 05: Analytic continuation of the LSE, built and tested in 1++

Claim: We show that a holomorphic continuation of the Lippmann–Schwinger equation to complex $E$ gives $T$ on the adjacent sheets and reduces to the real-axis equation. The continuation covers the OME kernel with its three-body denominators, the form factors $f_n(p)$, and the loop contour. It is built and tested in the $1^{++}$ model (plan claim 2). Its method is still open: the slice starts by agreeing the remaining checks with the user, before the derivation.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "Lippmann–Schwinger equation", "Loop measure and regulator", "Pole position and Riemann sheets", "Multichannel S matrix and unitarity", "On-shell amplitude and effective-range expansion", "Bare–continuum vertex".
- [GLOSSARY.md](../../GLOSSARY.md): "Baseline fit".
Checks:
- $T(E)$ off the real axis:
  - Route: as $E$ approaches the real axis from the physical sheet, the continued $T$ reproduces the package's real-axis $1^{++}$ $T$. The comparison runs from the $B\bar B^*$ threshold to the first omitted threshold, 92.8 MeV above it.
  - Expected: agreement to numerical precision.
- The real-axis $T$:
  - Route: unitarity, $\operatorname{Im}(T^{-1})_{\alpha'\alpha}=\rho_\alpha\delta_{\alpha'\alpha}$ over the open channels.
  - Expected: residual at numerical precision.
- Further checks: agreed with the user at the start of the slice, before the derivation. The plan's candidates are:
  - sub-threshold poles matching the real-axis bracketing of the Table V states;
  - an exactly solvable separable coupled-channel model;
  - a narrow-resonance cross-check against a real-axis speed plot;
  - independence from any auxiliary contour parameter.
Output: the continuation method and its $1^{++}$ test. The figure shows the continued and real-axis $T$ on the real axis, plus the test poles → `paper/sections/app-continuation.tex`
Blocked by: 01
Status: ready
