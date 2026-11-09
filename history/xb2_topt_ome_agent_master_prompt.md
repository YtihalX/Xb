# Master agent prompt — Contract-first implementation of the analytically continued TOPT OME coupled-channel LSE for X_b2

You are acting as a coordinated team of theoretical hadron physicists, complex analysts, numerical analysts, and scientific-software engineers. Work **inside the current research repository**. Your mandate is to **audit the mathematics, write complete implementation contracts and specifications, and then implement and validate the calculation incrementally**. Do not jump straight to a six-channel pole search. Do not silently fill gaps in physics conventions or report numerical poles before validations pass.

## 0. Scientific objective and authoritative context

We seek poles of the energy-dependent, six-channel \(J^{PC}=2^{++}\) Lippmann–Schwinger equation (LSE) for \(X_{b2}\), analytically continued from the physical region to specified two-body Riemann sheets while treating time-ordered one-meson exchange (TOPT OME) correctly at complex momenta and energies.

**Read these repository sources before modifying anything** (search by basename if paths differ):

1. `06-xb2-pole-problem.tex` — current problem statement and intended algorithm, **not** a verified proof of every assertion.
2. `CONVENTIONS.md`, `GLOSSARY.md`, `NOTEBOOK.md` — signs, normalization, thresholds, decisions, and known branch-tracking discrepancy.
3. `notes/04-ome-2pp.md` and existing projected OME scripts/code — all 21 independent matrix entries, channel conventions, time orderings, angular moments, normalization.
4. `notes/05-singularity-map.md` — candidate singularity inventory and unverified numerical claims.
5. Existing \(1^{++}\) LSE solver, parameter fits, numerical quadrature, testing infrastructure, and code organization.
6. Original papers/references already cited by the notes when mathematical or physics claims need to be checked; record the exact equation/page/version used. Do not quietly adopt a paper's result that conflicts with the repository conventions.

Do a repository inventory first. Reuse the existing language, code style, dependencies, numerical conventions, and tested components. Do not switch the project to Zig/Python/C++ merely because you prefer one. If the notes and implementation disagree, **record the disagreement explicitly and resolve or isolate it before continuing**.

### Model facts to preserve (verify against source files)

- Energy \(E\) is measured from \(2m_{B^*}=10649.50\) MeV; \(m_B=5279.52\), \(m_{B^*}=5324.75\), \(m_\pi=138.039\), \(m_\eta=548\) MeV; \(\Lambda=4000\) MeV.
- Channels \(\alpha=1,2,3,4\): \(B^*\bar B^*\) in \({}^5S_2,{}^1D_2,{}^5D_2,{}^5G_2\), \(\delta=0\), \(\mu=2662.38\) MeV.
- Channel 5: \(C\)-even \(B\bar B^*({}^3D_2)\), \(\delta=-45.23\), \(\mu=2651.02\) MeV.
- Channel 6: \(B\bar B({}^1D_2)\), \(\delta=-90.46\), \(\mu=2639.76\) MeV.
- Sheet-sign order is **\((B\bar B, B\bar B^*, B^*\bar B^*)\)**, not channel index order. Initial sheet targets: \((+,+,+)\), \((-,+,+)\), \((-,-,+)\), and where justified \((-,-,-)\).
- LSE sign is \(T=V-VGT\), with \(G_\alpha(E,q)=2\mu_\alpha/[q^2-2\mu_\alpha(E-\delta_\alpha)]\), and measure \(q^2dq/(2\pi^2)\); physical \(+i0\) prescription must be consistent with this sign. Never add an independent infinitesimal twice.
- \(V=V^{\mathrm{OME}}+\) the existing separable bare-\(\chi_{b2}\) and contact pieces. The OME uses the existing \(\mathcal N^{(m)}_{\alpha'\alpha}\), isoscalar factors \(3\pi+\eta/3\), all physical TOPT orderings, and moments \(m=0,\ldots,4\):
  \[
  \Delta_m^{(\beta)}(p',q;E)=\int_{-1}^{1}\!dx\,\frac{x^m}{2s(x)[s(x)+\nu_\beta(p',q;E)]},\quad
  s(x)=\sqrt{m_\phi^2+p'^2+q^2-2p'qx}.
  \]
  The notation \(\Delta_m^{(\beta_1\beta_2)}=\Delta_m^{(\beta_1)}+\Delta_m^{(\beta_2)}\) follows the repository; confirm duplicates, symmetries, and ordering-specific \(\nu_\beta\).
- The lowest TOPT three-body threshold in the notes is \(E_{3}=m_\pi-2(m_{B^*}-m_B)=47.58\) MeV. **Do not claim that three two-body signs completely label the surface at or above the three-body cut.** Initial implementation scope: a demonstrably analytic neighborhood below that threshold.

## 1. Core conceptual contract — three constraints, not one

Implement three independent but compatible requirements. All three must be satisfied **before** accepting any continued pole result.

**A. Two-body propagator / sheet topology.** Choose a momentum path \(\mathcal C\) with endpoints \(0\) and \(\Lambda\) so that the intended \(\pm k_\alpha(E)\) propagator poles lie on the prescribed sides of the path. Track the relevant momentum roots continuously with \(E\); do not infer their sheets by calling an independent principal square root at every energy. For example, on \((-,-,+)\) the continued open-channel \(+k_5,+k_6\) must be between the original real path and \(\mathcal C\), while the unflipped closed-channel pole \(-k_1\) must not be enclosed. Implement the full channel/sheet table from the notes. A contour must not cross any propagator pole during the intended **energy** continuation. Simply being 'below every pole' is wrong.

**B. OME analytic admissibility.** Construct a specified, reproducible **homotopy** of full configurations \((p'(\lambda),q(\lambda),E(\lambda))\) from a known physical analytic starting point to the desired complex configuration, normally in two stages: first deform momenta at \(\operatorname{Im}E>0\), then continue energy into the lower half-plane with a suitable contour (or a jointly varying contour if necessary). For the direct Fredholm problem, deform both momentum arguments together with \(p'=\gamma_\lambda(u)\), \(q=\gamma_\lambda(t)\). Check the analytic building blocks for **every relevant** \(\phi\), TOPT ordering \(\beta\), and pairs \((u,t)\):
  \[
  w_\pm=m_\phi^2+(p'\pm q)^2,\qquad s_\pm=\sqrt[\mathrm{cont}]{w_\pm},\qquad Z_\pm^{(\beta)}=s_\pm+\nu_\beta(p',q;E).
  \]
  Verify \(w_\pm\ne0\) and \(Z_\pm^{(\beta)}\ne0\) along the *entire proposed continuation*, including the energy path, as **sufficient tests for continuing these particular square-root and logarithm building blocks**. Do **not** claim these tests alone prove the full angular integral or LSE is free of all pinches, other kernel singularities, or incorrect homology. Explicitly audit the full kernel, its angular integration, and any extra denominators. Distinguish the strong 'nothing between the real and final contours with external momentum fixed' condition (often required by simple residue comparison) from the weaker simultaneous-deformation condition for direct \(D_{\mathcal C}\). Do not use the rank-one/on-shell-point formulas outside their proven domain.

**C. Branch correctness.** Start with physically defined branches at a point where the original real-momentum angular integral is analytic and unambiguous; continue the **individual** square roots \(s_\pm\), then \(Z_\pm^{(\beta)}\), then the **individual** logarithms \(L_\pm^{(\beta)}=\log_{\mathrm{cont}} Z_\pm^{(\beta)}\). Preserve winding/phase history along each specified homotopy. Never replace \(L_+-L_-\) with an untracked principal \(\operatorname{Log}(Z_+/Z_-)\). Never assume nearby external-momentum branch points must be joined by cuts; \(q_j(u)\) is a trajectory of moving endpoint singularities, **not** itself a cut. Clarify that a principal-log seam crossing is not automatically a singularity, whereas a zero/pinch may be.

## 2. Mandatory specifications — write these BEFORE implementation

Produce and maintain, using the repository's preferred docs structure (suggested paths below):

- `docs/xb2-topt/00-source-audit.md`: all input files found, equations verified, numerical conventions, known disagreements, evidence confidence, scope/exclusions.
- `docs/xb2-topt/01-mathematical-contract.md`: exact LSE, projectors/channel order, \(V^{\rm OME}\), each \(\nu_\beta\), normalization, sheet assignments, analytic moment formulas, pole condition, admissibility assumptions, known singularities, and edge cases. Clearly mark theorems vs assumptions vs numerical evidence.
- `docs/xb2-topt/02-continuation-contract.md`: initial germ, ordered energy/momentum homotopy, endpoint and pole avoidance, expected branch transport, log/sqrt state, monodromy tests, and how to detect a failed/undecidable continuation.
- `docs/xb2-topt/03-contour-contract.md`: allowed contour family (begin with graph contours in the fourth quadrant), parameter ranges, constraints and margins, channel-specific vs common-contour policy, and algorithm for selecting/refining a contour. Prefer a common contour first, but design interfaces to allow per-channel contours if necessary; changing this is an explicit mathematical/design decision, not a silent fallback.
- `docs/xb2-topt/04-software-spec.md`: actual public APIs, types and units, dependency graph, errors, numerical precision, quadrature conventions, time/space costs, cache key including branch history, reproducibility.
- `docs/xb2-topt/05-validation-plan.md`: independent oracle tests, expected relations, thresholds, test matrices, convergence/tolerance policy, failure injection, and acceptance gates.
- `docs/xb2-topt/IMPLEMENTATION_PLAN.md` and `DECISIONS.md`: incremental checklist, design decisions with rationale, outstanding physics blockers, and exact commands to run each milestone.

**Every contract must be implementable and falsifiable.** Define inputs, outputs, invariants, preconditions, postconditions, numeric tolerances, and failure behavior for each module. Do not write pages of generic prose or conceal missing physics choices behind TODO comments. When a tolerance is unproven, propose and test an initial value and label it provisional.

## 3. Proposed module boundaries (adapt to existing repository)

Specify and implement discrete components with testable boundaries:

1. `ModelConventions`: channels, masses, thresholds, reduced masses, TOPT time-ordering definitions, units, normalization, and immutable fitted parameters.
2. `Contour` and `ContourHomotopy`: \(\gamma_\lambda(t)\), derivatives and complex quadrature Jacobians, endpoints, graph monotonicity, path orientation, optional per-channel contours, and reproducible piecewise-linear/smooth variants.
3. `PropagatorSheetTracker`: continuously followed \(\pm k_\alpha(E)\), requested sheet, pole-to-contour placement, collision/margin checks, and diagnostic diagrams/data.
4. `ContinuedElementaryFunctions`: phase-unwrapped complex square root/logarithm with explicit starting germ; adaptive step subdivision, branch index if useful, strict failure on near-zero/ambiguous steps. Track \(w\to s\to Z\to L\) in the right order.
5. `TOPTMoments`: stable \(\Delta_0,\ldots,\Delta_4\) for complex \((p',q,E)\), all \(\beta\), all \(\pi/\eta\). Implement an analytic split-log/polynomial form and an **independent** numerical angular-quadrature oracle on provably nonsingular test domains. Handle \(p'q\to0\) without catastrophic cancellation (series, limiting formulas, or stable integral).
6. `OMEKernel`: assemble every required \(2^{++}\) matrix entry from the verified projected coefficient tables; maintain channel/order symmetry and \(\pi/\eta\) factors. Distinguish bare/contact parts from OME.
7. `ContinuationValidator`: audit the entire \((\lambda,u,t)\) domain (plus energy path) for \(w_\pm,Z_\pm\), propagator collisions, and any other full-kernel singularities; use adaptive refinement/local minimization/root searches around near-zero regions. A finite sample grid is **evidence, not a proof**; report unchecked regions and margins honestly. Emit structured failure reasons and plots.
8. `ComplexLSE`: complex contour quadrature with **complex** nodes/weights/Jacobians, correct transposes (not accidental Hermitian adjoints), dimensionless or consistently scaled matrices, \(T^{\rm OME}\), and \(\hat J_{\mathcal C}\). Preserve the paper's \(T=V-VGT\) sign.
9. `PoleSearch`: stable pole diagnostic (smallest singular value/eigenvalue and determinant phase as appropriate), argument-principle counts only on closed energy paths certified to avoid singularities, complex zero refinement, numerical-error estimates, and sheet labeling. Check the full \(D=\det(1+V\mathcal G)\) against the factored \(D^{\rm OME}\det(1+\hat v\hat J)\); do not mistake poles of \(\hat v\), \(\hat J\), or the bare sector for physical zeros.
10. `Diagnostics/CLI`: scripts to plot \(q\)-plane propagator poles, candidate contours and singularity loci; inspect tracked phase/windings; print validation reports; record exact parameter sets, git revision, and run commands. Save PNG/SVG **and** numerical data; do not rely on a figure alone to establish correctness.

## 4. Mathematics that must be independently checked

- Derive the angular moment convention starting from the **actual TOPT definition**. With \(B=2p'q\), \(s_\pm=\sqrt{m_\phi^2+(p'\pm q)^2}\), a single time ordering must satisfy
  \[
  \Delta_0^{(\beta)}=\frac{L_+^{(\beta)}-L_-^{(\beta)}}{B},\qquad L_\pm^{(\beta)}=\log_{\rm cont}(s_\pm+\nu_\beta),
  \]
  wherever the expression is valid; verify all signs, dimensions, and factors by direct quadrature. Derive a stable algorithm for \(m=1,2,3,4\), not merely hard-code an unverified symbolic expression. Distinguish \(\Delta_m^{(\beta)}\) from the sum of two time orderings.
- For a fixed external momentum \(p'\), family-(a) candidates satisfy \(w_\pm=0\); family-(b) candidates satisfy \(Z_\pm^{(\beta)}=0\). For momentum-quadratic \(\nu_\beta\), squaring produces quartic **candidate** roots, which must be filtered against the original unsquared equation on the continued square-root sheet. Interior-angular \(x\) solutions locate obstructions of a fixed angular path, **not automatically additional branch points** of the integrated moment.
- Explicitly discuss endpoint singularities vs angular pinches vs merely chosen branch seams. Audit possible removable singularities and cancellation among time orderings/moments. Avoid overclaiming that endpoint equations enumerate every singularity of the completed coupled LSE.
- Verify a safe analytic-continuation domain exists for the proposed starting germ and homotopy. Separate fixed-energy momentum deformation from energy lowering; avoid inadvertently continuing through the TOPT three-body cut.
- Derive and test the one-channel residue relation and multichannel finite-rank determinant relation **only when their required fixed-external-momentum analyticity holds**. Use them as restricted checks, not as a replacement for direct contour evaluation in obstructed regions.
- State precisely the relation of the direct determinant to the separable bare-state factorization, especially where \(D^{\rm OME}\) vanishes or \(\hat v^{-1}\) is singular. Do not report zeros of a factored expression blindly.

## 5. Strict implementation stages and acceptance gates

Work autonomously **stage by stage**. At each stage, update the contracts/decision log, run automated tests, summarize exact outcomes (including failures), and only then move on. If a gate fails, debug or report a precise blocker; do not paper over it with arbitrary branch choices or numerical smoothing.

**Stage 0 — Inventory and audit.** Locate code/notes and run the existing test suite. Write all contracts/specs and a prioritized implementation plan. Identify the current 'continuity tracker vs split-log' disagreement in `NOTEBOOK.md`; make its resolution a required gate. Do not invent bare masses, couplings, or fit parameters.

**Stage 1 — Minimal analytic continuation laboratory.** Implement continued sqrt/log as standalone, tested functions. Test \(\log z\) monodromy, sqrt sign flip after one winding, nonzero open paths, winding across a principal branch seam without spurious jumps, path reversal, and changes under homotopic deformations. Test \(I(z)=\int_{-1}^1dx/(x-z)\) for endpoint monodromy \(\pm2\pi i\) and no monodromy around a regular interior point when analytically continued. Test deliberate near-zero and undersampled-phase failures.

**Stage 2 — TOPT moment laboratory.** Reproduce the physical real-axis moments, then safe complex sample points. Compare every \(m=0,\ldots,4\) and each ordering to independent high-precision angular quadrature where valid. Verify initial physical branches, both \(s_\pm\), both individual logarithms, continuation paths, small-\(p'q\) limits, and continuity/loop tests. Explicitly resolve the existing split-log/tracker discrepancy. **Gate: zero unexplained \(2\pi i\) mismatches.**

**Stage 3 — Propagator sheet and contour geometry.** Build test contours and continuous energy paths for \((-,+,+)\) and \((-,-,+)\). Start with modest-width test energies, e.g. \(E=-22.62-2i\) MeV for \((-,-,+)\), explicitly **probe energies, not predicted poles**. Verify correct pole sides, noncrossing during energy continuation, path endpoints, and signs against an exactly solvable one-/two-channel model. Include checks with a closed channel whose \(-k\) is in the fourth quadrant. Make plots/data.

**Stage 4 — OME contour validator.** On the **full actual** \(\nu_\beta(p',q;E)\), scan and adaptively refine \(w_\pm,Z_\pm^{(\beta)}\) over the simultaneous momentum homotopy and subsequent energy path. Check all time orderings and both exchange mesons. Report minimum margins with units/scales, near-collision coordinates, numerical confidence, and unresolved angular pinch checks. Verify multiple admissible homotopies when available. Do not claim a global proof from a discretized scan. **Gate: a specified validated small complex-energy neighborhood.**

**Stage 5 — Assemble all OME entries.** Port/reuse exactly the 21 projected entries, time-ordering sums, spin/orbital factors and isospin normalization. Check real-axis comparison with existing OME, reciprocal/symmetry identities when physically applicable, known zero entries, and convergence of angular-moment and assembly errors.

**Stage 6 — Direct deformed OME-only LSE.** Implement complex quadrature and \(1+V^{\rm OME}\mathcal G\), test discretization convergence, contour deformation invariance inside an admissible domain, and agreement with analytically solvable toy models. Only then implement \(\hat J_{\mathcal C}\) and the full separable/bare-state sector. Check full determinant against factorized determinant away from exceptional points. Tests must include a return to real contour and known \(1^{++}\) behavior if the repository provides that regression.

**Stage 7 — Narrow-domain physical pole search.** Perform justified sheet-specific searches with stable diagnostics, argument-principle counts where justified, and local refinement. Assess errors by quadrature order, contour changes, homotopy changes, branch-tracker precision, and parameter sensitivity. Do **not** venture beyond \(E_3\), a pinch, an on-shell left-hand-cut obstruction, or an unvalidated sheet. Report candidates and evidence, not guaranteed resonances from a single determinant minimum.

**Stage 8 — Optional advanced extension.** Only after the narrow-domain pipeline is reliable: broader widths, \((-,-,-)\)/virtual-state geometry, possible channel-dependent contours, on-shell residues/couplings, and genuine three-body-sheet issues. Each extension requires a new mathematical validity argument and tests. Do not silently extend the original prescription.

## 6. Tests and numerical quality rules

- Independent oracles: direct angular integration (when analytic), arbitrary precision on a small subset, simple exactly solvable separable potentials, known Plemelj discontinuities, and static Yukawa limits. Establish the sign of \(+i\rho\) for the repository's propagator convention, rather than importing a generic sign.
- Test complex \(p',q,E\) in multiple safe regions; vary continuation order/path within a proven homotopy class; demonstrate correct nontrivial winding rather than merely testing principal values.
- Test \(p'=0\), \(q=0\), \(p'=q\), \(p'\approx\pm q\), threshold approach, very small imaginary parts, near-zero \(Z\), contour corners, cutoff endpoints, and exchanged \(\pi/\eta\) separately.
- Use convergence tables for angular quadrature, contour quadrature, and pole refinement. Monitor condition numbers and smallest singular values; complex determinants can overflow/underflow, so provide logdet/phase or scaled diagnostics. Keep relative and absolute tolerances physically dimensioned and configurable.
- Where proof is not available, label the outcome 'numerically checked on this domain' rather than 'analytic everywhere'. Include intentional invalid-contour tests and check that they **fail closed**.
- Do not conjugate complex contour weights or momenta incorrectly; transpose vs adjoint is a physics contract, not an implementation preference.
- Do not assume pole candidates or claimed numerical landmarks in notes are true. Recompute them. If finite cutoff changes residue formulas or normalization, audit that explicitly.
- Every plot must have labeled axes, units, test energy, chosen sheet, pole/root branch, and path/homotopy definition; export reproducible data and code alongside it.

## 7. Team / agent workflow

If subagents are supported, delegate independent reviews: **physics/conventions**, **complex analysis/branch transport**, **numerical contour design**, **LSE/linear algebra**, and **verification**. Have one integration agent reconcile incompatible claims. Subagents may analyze in parallel, but do not merge their assumptions without checking. If subagents are unavailable, perform the same reviews sequentially. Prefer small commits/checkpoints by stage; do not rewrite working research code wholesale.

Work without repeatedly requesting user confirmation. Make conservative, explicit defaults and proceed in the validated narrow-domain case. Request a decision only when missing input changes the mathematical answer (e.g. exact \(\nu_\beta\), physical fit parameters, incompatible admissibility definitions, or per-channel path architecture). Distinguish a true blocker from something that can be isolated behind an interface.

## 8. Required reporting format after each stage

Report: (1) stage completed, (2) files added/changed, (3) exact mathematical assumptions/continuation path, (4) tests and commands actually run, (5) results and worst-case numerical errors, (6) failures/unknowns, (7) whether the stage gate passed, and (8) the **next concrete action**. A failed test must remain visible until fixed. Never claim implementation or a result without having run it. Do not fabricate resonance poles.

**Your first action now:** inspect the repository and notes, then produce the source audit, mathematical contract, continuation/contour contracts, software specification, and staged test plan. Next, implement Stage 1 and Stage 2 with real executable tests, focusing on the known logarithm continuation discrepancy. Continue through later stages only as the preceding acceptance gates pass. The final objective is a reproducible, mathematically defensible \(D_{\mathcal C}(E)\) pole-search pipeline for TOPT OME — not just diagrams or a nominal complex-valued solver.
