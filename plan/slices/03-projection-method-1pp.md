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
  - Judgement protocol: the slice author expands the Cartesian contractions of (D1) in Eq. (80), lists the coefficients of each $\Delta_k^{(\beta_1\beta_2)}$ beside (D2)–(D10), and checks every sign and numerical factor; the referee independently reviews the table. This is a written algebraic criterion, not a fit to numerical samples.
- Numerical route, same seam:
  - Route: brute-force numerical integration of Eq. (80), compared with the package's analytic kernel at random $(p,p',E)$ below the three-body thresholds, for $\pi$ and $\eta$ exchange separately. The 3D potentials enter as spin matrices contracted with the (D1) projectors and integrated over both solid angles.
  - Expected: agreement to quadrature precision.
  - Red: flipping the sign of the $^5D_1$ projector (the sign that differs from [@Bruschini:2023zkb] v3) breaks agreement in the $(^3S_1,{}^5D_1)$ and $(^3D_1,{}^5D_1)$ entries.
  - Executable: `checks/projection_1pp.py`, with reusable double-solid-angle and species-aware TOPT helper `checks/_projection.py`. Fixed tolerance $5\times10^{-9}\max(1,|V|)$; orders 12 and 18 must converge to the same precision. Three seeded random momentum/energy points, every entry and meson.
  - Initial red: the D1 phase input is unfilled before the worked derivation; `uv run --script checks/projection_1pp.py` reports `FAIL no worked projection result yet: D1 phase input is missing`.
  - Literature judgement (slice author, 2026-10-29): the Cartesian contraction table in `notes/03-projection-method-1pp.md` §§2–3 matches every sign and factor of (D2)–(D10). The original package entries 13,23,31,32 had the opposite sign; the user explicitly directed alignment of the package to the agreed (D1) phase.
  - Before-fix discrepancy (2026-10-29): `uv run --script checks/projection_1pp.py` with printed D1 exited 1, with 24 mixed-entry FAIL and 30 other-entry PASS lines. First pion sample: `FAIL ... entry=(1,3) numerical=-3.22785350281 analytic=3.22785350281 error=6.46 quadrature_delta=0`; entry (2,3) was +0.343022784097 against -0.343022784097. Largest order-12/order-18 change $1.50\times10^{-13}$ GeV$^{-2}$. Missing-result red committed before derivation (`1d26d4f`).
  - Before-fix diagnostic: `uv run --script checks/projection_1pp.py --flip-5d1` gave 54 PASS lines (largest analytic residual $4.67\times10^{-13}$ GeV$^{-2}$), confirming the opposite channel-3 phase. This was diagnostic evidence, not the completion red run.
  - Package regression: the rephased public-interface assertion was red before implementation (`3.276760109674473 == -3.276760109674473` failed). After correction, all BOchiEFT package testsets pass (9870 extraction, 77 assembly/scattering, 21 moments, 17 Cornell representation, 85 adopted-configuration assertions). The full `Pkg.test()` run then fails in unrelated `test/cornellmodel/test_gaussian_solve_group.jl:326` (`1.0851267727757951e-10 > 2.000888343900442e-10` is false); the parent is dispositioning this outside slice 03, explicitly directing no edit or rerun here.
  - Deliberate red after alignment (2026-10-29): changed only `PROJECTOR_SIGN=+1` to `-1` in the input block, confirmed it with `git diff -- checks/projection_1pp.py`, then `uv run --script checks/projection_1pp.py` exited 1. First pion sample: `FAIL ... entry=(1,3) numerical=3.22785350281 analytic=-3.22785350281 error=6.46`; `(2,3)` gave -0.343022784097 against +0.343022784097. All 24 mixed entries failed and the other 30 passed. Restored the printed D1 sign; expectations and tolerance untouched.
  - Final green closure: `just check` exits 0 after the sibling restored its deliberate doubled-$C$ mutation; all four checks and the paper build pass. Slice-03 gives all 54 comparisons PASS, largest analytic residual $4.67\times10^{-13}$ GeV$^{-2}$ and largest quadrature-order change $1.50\times10^{-13}$ GeV$^{-2}$. Earlier closure attempts were red only on the sibling's announced missing-result or deliberate doubled-$C$ states; none remain.
Output: method paragraph of the OME appendix: Eq. (80) reduced to angular moments, checked against the $1^{++}$ entries → `paper/sections/app-ome-2pp.tex`
Blocked by: 01
Status: done

## User decision: align package to (D1)

On 2026-10-29 the user explicitly directed alignment of the package to the printed (D1), after the three-route evidence (`local://slice03-5D1-evidence.md`: raw Eq. (80), package, independently evaluated printed (D4)/(D7)) showed raw integration and source agree. The original package used $V_{\rm original}=U V_{\rm D1}U$, $U=\operatorname{diag}(1,1,-1)$. The two mixed-coefficient branches are corrected; frozen-reference comparisons convert their continuum, augmented and scattering matrices with $U$ while preserving the reference itself. No check expectation or canonical convention is changed.


## Referee

Fixed point: `dd33ec75ccf420aa8cc6e0f180a00040b3936c9a`, scoped to slice-03 paths and own package phase hunks relative to sibling API commit `6c4e995`. Three independent parallel axes completed on 2026-10-29:

- **Standards:** 0 findings. Dimensions, limiting arguments, canonical conventions, pinned citations, independence, convergence and committed red-before-derivation history checked. The check's only persisted input change is the filled D1 phase; expectations and tolerance are unchanged.
- **Plan:** 0 findings. All nine entries, the worked implementation walkthrough, both solid angles, reusable species/projector data, separate mesons, bridge and paper input meet the slice and PLAN learning goal.
- **Correctness:** 0 findings. Independent exact SymPy cross-product contractions reproduce all nine polynomials and unit projector norms, the four intermediate formulas, both HQSS identities and zero-momentum cancellations. Twelve independent 70-digit moment integrations agree within $5.18\times10^{-64}$ scaled residual; independent matrix algebra verifies phase covariance of continuum, augmented, scattering and reduced-loop matrices. Scratch command: `uv run --script /tmp/slice03-referee-correctness.py` (imports no repository code).

The final `just check` is completely green, including both sibling checks and the paper build. The separate full-package-suite Cornell failure is disclosed under Checks and dispositioned by the parent; all BOchiEFT package testsets pass. No referee findings were declined.

## Result

All nine $1^{++}$ entries reproduce the printed (D2)–(D10), with the package aligned to the agreed (D1) phase on the user's instruction. All 54 per-entry/per-meson comparisons pass: largest analytic residual $4.67\times10^{-13}$ GeV$^{-2}$, largest angular-order change $1.50\times10^{-13}$ GeV$^{-2}$. Flipping only the $^5D_1$ projector makes all 24 mixed comparisons fail.

- Derivation or computation: `notes/03-projection-method-1pp.md:7–135`; reusable integrator `checks/_projection.py:13–64`.
- Checks: `checks/projection_1pp.py:53–75`, green; deliberate red recorded under Checks. Final `just check` and BOchiEFT testsets pass; the separate full-suite Cornell failure is disclosed above.
- Paper: `paper/sections/app-ome-2pp.tex:1–35`, included at `paper/main.tex:180`.
- Referee: Standards 0, Plan 0, Correctness 0 findings; independent exact spin algebra, high-precision moments and phase-covariant matrix rechecks agree.
