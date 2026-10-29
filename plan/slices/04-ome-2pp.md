# 04: The 2++ OME potential

Claim: We show what the partial-wave-projected $2^{++}$ OME potential $V^{\rm(OME)}_{\alpha'\alpha}(p',p;E)$ is in the six-channel basis: one-$\pi$ plus one-$\eta$ exchange with mass splitting, recoil, and energy dependence. The potential includes the new $B\bar B\leftrightarrow B^*\bar B^*$ transition. Its sign follows from Eq. (68) of [@Zhang:2026iyr] v1 in this project's $C$-parity convention; followup.tex Eq. (5) has the right $2D_3$/$2D_4$ structure, but its sign is still to be fixed.
- The package's OME kernel is generalised from channel indices to meson-pair species ($B\bar B$, $B\bar B^*$, $B^*\bar B^*$), so that the same kernel serves $1^{++}$ and $2^{++}$.
- The [@Baru:2019xnh] v2 bridge records the projector signs and its $\mathcal CM=\bar M$ convention.
- The [@Bruschini:2023zkb] v3 bridge records the Table 2 signs.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "2++ channel basis and projectors", "Energy origin and on-shell momentum", "Axial coupling and OME normalisation", "Partial-wave projectors", "C-parity phase", "Angular-momentum phases", "Reduced masses and TOPT energy offsets".
- [GLOSSARY.md](../../GLOSSARY.md): "Full OME", "Strict HQSS limit".
- Language gate checked by reading the agreed entries above, including units, projector normalisation, charge conjugation, energy origin and the strict HQSS limit; no new canonical term is required. Starting fixed point: `ec22a47187c569f24a5854b12b0279caea081a93`.
- [decisions/0003](../../decisions/0003-section-I-scope.md), [decisions/0004](../../decisions/0004-quark-model-fixed.md).
Checks:
- Numerical route, the projected $2^{++}$ $V^{\rm(OME)}_{\alpha'\alpha}$:
  - Route: the brute-force integration of Eq. (80) from slice 03, using the bridged [@Baru:2019xnh] v2 projectors, at random $(p,p',E)$ for each of the 21 independent entries, $\pi$ and $\eta$ separately.
  - Expected: agreement to quadrature precision.
  - Executable: `checks/projection_2pp.py`, Cartesian helper `checks/_projection_2pp.py`; seed 80402, three off-shell samples, orders 12 and 18, error and convergence both bounded by $5\times10^{-9}\max(1,|V|)$. The public potential seam isolates each meson by setting the two exchange masses equal and dividing by $3+1/3$ before applying its isospin weight.
  - Missing-result red (2026-10-29): `just check` prints `FAIL package 2++ OME result unavailable: channels_2pp / OMEInteraction input`, with `channels_2pp` undefined.
  - Green (2026-10-29): exit 0, 141 PASS (12 Gram, 3 below-threshold samples, 126 entries); largest residual $2.9\times10^{-12}$ GeV$^{-2}$, largest order-12/18 change $2.7\times10^{-15}$ GeV$^{-2}$.
- Time reversal, same seam:
  - Route: $V_{\alpha'\alpha}(p',p;E)=V_{\alpha\alpha'}(p,p';E)$.
  - Expected: exact to rounding.
  - Red: swapping $D_3$ and $D_4$ in one $B\bar B\leftrightarrow B^*\bar B^*$ entry breaks it.
  - Executable: `checks/time_reversal_2pp.jl`, all 21 independent entries, three off-shell momentum/energy points and each exchanged meson separately; tolerance $2\times10^{-12}\max(1,|V_{\rm forward}|,|V_{\rm reverse}|)$, fixed before derivation.
  - Missing-result red (2026-10-29): `julia --project=checks --startup-file=no checks/time_reversal_2pp.jl` exits 1 at the absent `channels_2pp` API. `just check` likewise fails only on this newly introduced guard; the pre-existing baseline, 1++ projection, shallow-fit and spurious-projection checks pass. Red guard committed as `c992b60`.
  - Broken-result red (2026-10-29): with entry 16 alone given the $D_4$ offsets (one temporary line in `tc_alphas`, `out==1 && incoming==6` → pairs `((:P,:V),(:P,:V))`), the check exits 1; the six entry-(1,6) lines FAIL (residuals $3.0\times10^{-4}$ GeV$^{-2}$ for $\pi$ at $p'=0.061$, down to $1.2\times10^{-6}$ for $\eta$), the other 120 PASS. Line removed, file byte-identical to the green version.
  - Green (2026-10-29): exit 0, 126 PASS, largest residual $6.7\times10^{-16}$ GeV$^{-2}$.
- Strict HQSS limit:
  - Route: rotate the $6\times6$ potential to a basis of heavy-quark spin 1 coupled with fixed light-cloud angular momentum $J_\ell$. The rotation is built from 9j and 6j recoupling, independently of the projectors. Its $J_\ell=1$ row is compared with [@Bruschini:2023zkb] v3, Table 2, after bridging.
  - Expected: block-diagonal to rounding, and the $J_\ell=1$ block equals the $1^{++}$ $J_\ell=1$ block at the same $(p,p',E)$.
  - Red: flipping one projector sign destroys the block structure.
  - Executable: `checks/hqss_2pp.py`; exact Wigner recoupling, orthogonality and bridged Table 2 checks, followed by numerical blocks at three fixed off-shell points, tolerance $2\times10^{-10}\max(1,\|V_1\|_{\max},\|V_2\|_{\max})$. The complete basis also retains the $(s_H,s_\ell)=(0,0)$ channel required for a square rotation.
  - Missing-result red (2026-10-29): `just check` prints `FAIL public 2++ OME input (channels_2pp must exist)`, with that API undefined. All existing checks pass; the suite is red only on the three announced slice-04 guards.
  - Broken-result red (2026-10-29): with the $B\bar B({}^1D_2)$ projector sign flipped in the package (one temporary line in `projection_coefficients` negating every 2++ entry with exactly one PP leg), the check exits 1: all three "complete 2++ fixed $(s_H,J_\ell)$ blocks" (forbidden entries 3.91, 3.78, 1.96 GeV$^{-2}$) and all three "$J_\ell=1$ S/D blocks identical" assertions FAIL; the exact Wigner, Table 2 and 1++ assertions PASS. Line removed, file byte-identical.
  - Green (2026-10-29): exit 0, 15 PASS; forbidden entries $\le1.1\times10^{-15}$ GeV$^{-2}$, $J_\ell=1$ blocks equal to $9.7\times10^{-14}$ GeV$^{-2}$.
- The $1^{++}$ kernel after the generalisation:
  - Route: slice 01's baseline-fit check.
  - Expected: stays green.
Output: the $2^{++}$ partial-wave OME formulas and a statement of their checks → `paper/sections/app-ome-2pp.tex`
Blocked by: 03
Status: claimed
