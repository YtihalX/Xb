# 04: The 2++ OME potential

Claim: We show what the partial-wave-projected $2^{++}$ OME potential $V^{\rm(OME)}_{\alpha'\alpha}(p',p;E)$ is in the six-channel basis: one-$\pi$ plus one-$\eta$ exchange with mass splitting, recoil, and energy dependence. The potential includes the new $B\bar B\leftrightarrow B^*\bar B^*$ transition. Its sign follows from Eq. (68) of [@Zhang:2026iyr] v1 in this project's $C$-parity convention; followup.tex Eq. (5) has the right $2D_3$/$2D_4$ structure, but its sign is still to be fixed.
- The package's OME kernel is generalised from channel indices to meson-pair species ($B\bar B$, $B\bar B^*$, $B^*\bar B^*$), so that the same kernel serves $1^{++}$ and $2^{++}$.
- The [@Baru:2019xnh] v2 bridge records the projector signs and its $\mathcal CM=\bar M$ convention.
- The [@Bruschini:2023zkb] v3 bridge records the Table 2 signs.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "2++ channel basis and projectors", "Energy origin and on-shell momentum", "Axial coupling and OME normalisation", "Partial-wave projectors", "C-parity phase", "Angular-momentum phases", "Reduced masses and TOPT energy offsets".
- [GLOSSARY.md](../../GLOSSARY.md): "Full OME", "Strict HQSS limit".
- [decisions/0003](../../decisions/0003-section-I-scope.md), [decisions/0004](../../decisions/0004-quark-model-fixed.md).
Checks:
- Numerical route, the projected $2^{++}$ $V^{\rm(OME)}_{\alpha'\alpha}$:
  - Route: the brute-force integration of Eq. (80) from slice 03, using the bridged [@Baru:2019xnh] v2 projectors, at random $(p,p',E)$ for each of the 21 independent entries, $\pi$ and $\eta$ separately.
  - Expected: agreement to quadrature precision.
- Time reversal, same seam:
  - Route: $V_{\alpha'\alpha}(p',p;E)=V_{\alpha\alpha'}(p,p';E)$.
  - Expected: exact to rounding.
  - Red: swapping $D_3$ and $D_4$ in one $B\bar B\leftrightarrow B^*\bar B^*$ entry breaks it.
- Strict HQSS limit:
  - Route: rotate the $6\times6$ potential to a basis of heavy-quark spin 1 coupled with fixed light-cloud angular momentum $J_\ell$. The rotation is built from 9j and 6j recoupling, independently of the projectors. Its $J_\ell=1$ row is compared with [@Bruschini:2023zkb] v3, Table 2, after bridging.
  - Expected: block-diagonal to rounding, and the $J_\ell=1$ block equals the $1^{++}$ $J_\ell=1$ block at the same $(p,p',E)$.
  - Red: flipping one projector sign destroys the block structure.
- The $1^{++}$ kernel after the generalisation:
  - Route: slice 01's baseline-fit check.
  - Expected: stays green.
Output: the $2^{++}$ partial-wave OME formulas and a statement of their checks → `paper/sections/app-ome-2pp.tex`
Blocked by: 03
Status: ready
