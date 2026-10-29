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
  - Check: `checks/shallow_fit.jl`; expectations committed red in `dab53b0` before computation. Initial `just check` printed `FAIL shallow-Xb fit: no computed result yet`; baseline remained green.
- The projection term:
  - Route: the physical poles do not depend on $\varepsilon$ over 5–50 GeV (App. G). Also, projecting out the spurious pole of the baseline fit at $\Lambda=4$ GeV should move the Table V masses by less than 1 MeV, as Sec. IV D states.
  - Expected: both hold.
  - Red: projecting with a perturbed $\Psi^{\rm(spur)}$ makes the physical poles depend on $\varepsilon$.
  - Check: `checks/spurious_projection.jl`; committed red in `dab53b0` before adding the package projection. Initial `just check` printed `FAIL spurious-pole projection: no computed result yet`.
  - Package TDD (projected-model seam, agreed 2026-10-29): `julia --project=code/HadronDynamics.jl code/HadronDynamics.jl/test/bochiEFT.jl` first failed on missing `projected_model`; after the zero-strength path passed, the positive-strength tracer failed on the missing addition. Implementing the normalised rank-one addition made all 10070 package assertions pass (including the two projection testsets).
  - Preregistration correction (user approved 2026-10-29): the original `dab53b0` check required an unjustified $10$ keV epsilon spread. The unperturbed baseline $2P$ spread was $0.103580499$ MeV, so that check failed. The adopted criterion is now $1$ MeV: [@Zhang:2026iyr] v1, App. G (`literature/Zhang:2026iyr/src/Xb.tex:2579`) says “within our adopted precision”, and its masses are printed to $1$ MeV. The tolerance change is committed separately with the approval named; it is not presented as the original preregistration.
Output: the shallow-$X_b$ fit row of the $1^{++}$ input table → `paper/sections/framework.tex`
Blocked by: 01
Status: claimed
