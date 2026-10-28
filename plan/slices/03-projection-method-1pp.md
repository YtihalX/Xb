# 03: Projection method on 1++, worked through

Claim: We show that the 1++ partial-wave OME of Eqs. (D2)–(D10) of [@Zhang:2026iyr] v1 follows from its time-ordered potentials, Eqs. (72)–(77), projected with the projectors of Eq. (D1) through Eq. (80). The projection reduces each entry to angular moments $\int_{-1}^{1}dx\,x^k\,[2\omega(\omega+\nu_\beta)]^{-1}$. The results match the coefficients used by the package's $1^{++}$ kernel.
- The derivation is a worked note in the paper's notation. It walks through how the package's projection coefficients and time-ordered energy offsets encode each term; this is the user's learning goal.
- The [@Zhang:2026iyr] v1 bridge records the renames $\omega_{B^{(*)}}(p)$ and $\nu_\beta$. It also records the sign of $\boldsymbol q$: $\boldsymbol p-\boldsymbol p'$ in Sec. III B, $\boldsymbol p'-\boldsymbol p$ in App. C.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "Metric signature", "Axial coupling and OME normalisation", "Partial-wave projectors", "Angular-momentum phases", "C-parity phase", "Reduced masses and TOPT energy offsets", "Binding energy and meson energies".
- [GLOSSARY.md](../../GLOSSARY.md): "Full OME".
Checks:
- Literature route, the projected $1^{++}$ $V^{\rm(OME)}_{\alpha'\alpha}(p',p;E)$:
  - Route: the worked derivation against [@Zhang:2026iyr] v1, Eqs. (D2)–(D10).
  - Written criterion: every term matches in sign and factor.
- Numerical route, same seam:
  - Route: brute-force numerical integration of Eq. (80), compared with the package's analytic kernel at random $(p,p',E)$ below the three-body thresholds, for $\pi$ and $\eta$ exchange separately. The 3D potentials enter as spin matrices contracted with the (D1) projectors and integrated over both solid angles.
  - Expected: agreement to quadrature precision.
  - Red: flipping the sign of the $^5D_1$ projector (the sign that differs from [@Bruschini:2023zkb] v3) breaks agreement in the $(^3S_1,{}^5D_1)$ and $(^3D_1,{}^5D_1)$ entries.
Output: method paragraph of the OME appendix: Eq. (80) reduced to angular moments, checked against the $1^{++}$ entries → `paper/sections/app-ome-2pp.tex`
Blocked by: 01
Status: ready
