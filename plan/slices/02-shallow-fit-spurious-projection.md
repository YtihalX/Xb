# 02: Shallow-X_b fit reproduced with spurious-pole projection

Claim: We show that the spurious-pole projection of [@Zhang:2026iyr] v1, Eq. (G1), added to the package, reproduces the shallow-$X_b$ fit of Table VIII:
- $C=2.66\ \text{GeV}^{-2}$, tuned so that $E_B[X_b]=1$ MeV below $m_B+m_{B^*}$;
- $V_0=362$ MeV at $m_b=4.534$ GeV, giving $\Delta M=15.0$ MeV;
- the spurious pole moved far above threshold.
Assumptions:
- [GLOSSARY.md](../../GLOSSARY.md): "Shallow-$X_b$ fit", "Spurious-pole projection", "Spurious pole", "Fit deviation", "Binding energy".
- [CONVENTIONS.md](../../CONVENTIONS.md): "Lippmann–Schwinger equation", "Separable s-channel and contact potential", "Energy origin and on-shell momentum".
- [decisions/0004](../../decisions/0004-quark-model-fixed.md).
Checks:
- Shallow-fit parameters and states:
  - Route: [@Zhang:2026iyr] v1, Table VIII and App. G.
  - Expected: $C$ and $V_0$ to the printed digits; masses within 1 MeV; probabilities within 1% absolute.
- The projection term:
  - Route: the physical poles do not depend on $\varepsilon$ over 5–50 GeV (App. G). Also, projecting out the spurious pole of the baseline fit at $\Lambda=4$ GeV should move the Table V masses by less than 1 MeV, as Sec. IV D states.
  - Expected: both hold.
  - Red: projecting with a perturbed $\Psi^{\rm(spur)}$ makes the physical poles depend on $\varepsilon$.
Output: the shallow-$X_b$ fit row of the $1^{++}$ input table → `paper/sections/framework.tex`
Blocked by: 01
Status: ready
