# Cleanup inventory, 2026-10-30

Applied 2026-10-30: the user marked every item `correct`; see `LOG.md`, "Working-file cleanup applied", and `cleanup-2026-10-30.diff`. Line numbers below refer to the files before the cleanup.

Line numbers refer to the working files read for this inventory; PDF references also give pages. A proposed move means archiving the passage or code under `history/` and adding a dated `history/LOG.md` entry recording what, why, who decided, and its replacement. Related occurrences are grouped; cross-references avoid counting a passage twice.

Coverage: read all text in `notes/` (including both PDFs), `checks/` (including all five untracked continuation drafts and both TOML files), `toy/`, all `paper/` sources, all four literature bridges, `CONVENTIONS.md`, `GLOSSARY.md`, `STANDARDS.md`, and `followup.tex`. No `literature/*/notes.md` files exist. Empty `.gitkeep` files and generated Python bytecode have no independent research passage. Paper PDFs and `paper/build/` are excluded as requested. `NOTEBOOK.md` and `history/LOG.md` were read first as the settling sources; no other history record or excluded source was opened.

Not inventory candidates: the contour-admissibility conflict, tracker/moment disagreement, proposed complex-form-factor tolerances, unfinished continuation implementations, bare spin-dependent masses, physical spin-2 poles, and charm pole/width interpretation remain Open questions (`NOTEBOOK.md:33–43`). The unprojected fit in `checks/shallow_spurious.jl:38–42` and `paper/sections/framework.tex:114–116` is an independent published comparison, not a superseded parameter choice or deliberately wrong calculation. Genuine alternate field/phase conventions and controlled limits are not errors. GLOSSARY `_Avoid_` aliases are excluded.

## A. Wrong values and results

### A1. toy/chi_c1_4010_width/README.md:3,7–12
Records: the colleague's momentum and width chain, the “not” correction, the wave function and width at the rejected momentum, and “agrees ... only by accident.”
Why it no longer holds: `history/LOG.md:32–36`; `NOTEBOOK.md:17–18` establishes the physical kinematics and limited Cornell result.
Proposed: move the old comparison to history with a log entry. Replace line 3 exactly with: “Question: What bare-state golden-rule width does the LO vertex $g f_2(p)=g\psi_2(p)/\sqrt{4\pi}$ give for $\chi_{c1}(4010)\to D\bar D^*$ with the Cornell $2P$ wave function at $m_c=1.328$ GeV and the physical decay momentum?” Replace lines 7–12 exactly with: “The bare Cornell $2P$ estimate gives $\Gamma=13.9$ MeV ($11$–$17$ MeV over the mass uncertainty), compared with the measured $62.7$ MeV. The physical momentum is $p=519$ MeV; the nonrelativistic kinematic estimate is $514$ MeV. The wave function has a node at $439$ MeV and $|\psi_2(519\,\mathrm{MeV})|=18.6\,\mathrm{GeV}^{-3/2}$, making the estimate sensitive to shifts of that node. At fixed wave function, matching the measured width would require $g\approx121$ MeV. This bare-state calculation omits dressing, OME and contact interactions.” Keep the independent-route and approximation paragraphs.
Decision: [ ] move  [x] correct  [ ] keep

### A2. toy/chi_c1_4010_width/run.jl:1–2,46–47,53–57,64–75
Records: output prints the rejected momentum; the loop and `rows` evaluate three versions of the colleague's chain, including a hard-coded coupling estimate.
Why it no longer holds: `history/LOG.md:32–36`; `NOTEBOOK.md:17–18`.
Proposed: move the comparison code/output to history with a log entry. Replace lines 1–2 exactly with `# Toy: bare Cornell 2P golden-rule width for chi_c1(4010) -> D Dbar* at the physical decay momentum.` Remove the colleague parenthesis from the line-46 format string; evaluate the package/finite-difference comparison only at `p0`. Replace lines 64–75 exactly with:
```julia
psi2 = psi_pkg(p0)[2]
@printf("Cornell psi_2, physical p: Gamma = %.1f MeV, |g_rel| = %.2f GeV\n",
        1e3width(psi2, p0), abs(grel(psi2)))
```
Keep `pdecay`, `fd_solve`, both physical width formulas, the node scan, uncertainty range, and measured comparison.
Decision: [ ] move  [x] correct  [ ] keep

### A3. paper/sections/app-ome-2pp.tex:16
Records: the notation table defines the heavy-meson energy with a relativistic square root while the offsets below use its nonrelativistic form.
Why it no longer holds: `CONVENTIONS.md:141–145`, `notes/03-projection-method-1pp.md:7`, `notes/04-ome-2pp.md:64–71`, and the same appendix at lines 125–133 fix the working definition.
Proposed: correct in place, archiving the old row with a log entry. Exact replacement: `$\omega_{B^{(*)}}(p)$ & Heavy-meson energy $m_{B^{(*)}}+p^2/(2m_{B^{(*)}})$ & $E_{B^{(*)}}(p)$\\`.
Decision: [ ] move  [x] correct  [ ] keep

### A4. followup.tex:233
Records: the reverse transition is labelled `B^*\bar{B}^8`.
Why it no longer holds: its own forward/reverse pair at lines 229–234; `NOTEBOOK.md:15–16` fixes the reverse as $B^*\bar B^*\to B\bar B$. `notes/note.pdf:65` explicitly identifies the typo.
Proposed: correct in place, archiving the erroneous label with a log entry. Exact replacement line: `V_{B^*\bar{B}^*\rightarrow B\bar{B}}^{(\text{OME})}(\vep',\vep; m_\phi) = \frac{g_b^2}{4F_\pi^2}(\veep_1 \cdot \veq)(\veep_2 \cdot \veq)\left[2D_4(\vep',\vep;m_\phi)\right]`.
Decision: [ ] move  [x] correct  [ ] keep

## B. Superseded decisions and abandoned routes

### B1. followup.tex:201–204,237
Records: $2^{++}$ OME derivation/projection remains described as preliminary work “needed” and “to be added.”
Why it no longer holds: `NOTEBOOK.md:15–16` establishes all 21 entries and their independent checks.
Proposed: move the completed-task wording to history with a log entry. Replace lines 201–204 exactly with: `The six-channel OME potential and all 21 independent partial-wave entries are derived in notes/04-ome-2pp.md and presented in the appendix of paper/main.tex.` Replace line 237 exactly with: `The partial-wave projections are given in the appendix of paper/main.tex.` The spin-2 spectrum and charm tasks remain open.
Decision: [ ] move  [x] correct  [ ] keep

### B2. checks/projection_1pp.py:14,22–26; checks/projection_2pp.py:16,27; checks/time_reversal_2pp.jl:6; checks/hqss_2pp.py:83
Records: the guarded-input/missing-result stage of the now-established $1^{++}$ and six-channel $2^{++}$ projection.
Why it no longer holds: `NOTEBOOK.md:13–16`; the populated calls in `checks/projection_1pp.py:23,54`, `checks/projection_2pp.py:34–44`, `checks/time_reversal_2pp.jl:14–16`, and `checks/hqss_2pp.py:89–95`.
Proposed: move obsolete stage descriptions to history with a log entry. Use present-tense descriptions: `The Cartesian projectors use the printed D1 phase.` and `The public six-channel OME supplies the package comparison.` D1 input simplification is specified in D1. Keep genuine package-failure handling and all independent comparisons; do not treat the continuation drafts' unfilled inputs as abandoned work.
Decision: [ ] move  [x] correct  [ ] keep

### B3. literature/Baru:2019xnh/bridge.md:29,97
Records: projector assertions are “not yet executed” and the comparison is only “planned assertions.”
Why it no longer holds: `NOTEBOOK.md:15–16`; recorded successful comparisons in `notes/04-ome-2pp.md:526–528`.
Proposed: move the construction-stage qualification to history with a log entry. Replace the line-29 Checked-by cell exactly with: `Projector Gram assertions in checks/projection_2pp.py; recorded result in notes/04-ome-2pp.md, Sec. 8.` Replace the final sentence of line 97 exactly with: `The recorded comparison has 141 passing assertions, maximum potential residual 2.9×10^−12 GeV^−2 and maximum order-12/18 change 2.7×10^−15 GeV^−2 (notes/04-ome-2pp.md, Sec. 8).` Keep the unchanged domain, seed and tolerances. See E7 for the corresponding flag.
Decision: [ ] move  [x] correct  [ ] keep

### B4. notes/03.pdf:117–178 (pp. 4–6); notes/note.pdf:65,156–192 (pp. 2,6–9)
Records: exported copies preserve the package-phase fix narrative, rejected diagnostics, old implementation walkthrough and deliberate-red results; `note.pdf` is an earlier version of note 04.
Why it no longer holds: `history/LOG.md:12–17,50–63`; current derivations are the Markdown notes and `NOTEBOOK.md:13–16`.
Proposed: move both existing PDF snapshots to history with a log entry; nothing remains at those PDF paths. Keep the corrected Markdown derivations. Any future exported copy must be generated from the approved cleaned source, not retain these older snapshots.
Decision: [ ] move  [x] correct  [ ] keep

## C. Rejected hypotheses, diagnostics, and fix narratives

### C1. notes/03-projection-method-1pp.md:135
Records: “Discrepancy and authorised resolution,” the original mixed-channel signs, and how the package was fixed.
Why it no longer holds: `history/LOG.md:12–17`; `NOTEBOOK.md:13–14,25` fixes the current printed-D1 convention.
Proposed: move the fix narrative to history with a log entry. Exact remaining text: `The package and the coefficient table use the printed (D1) phase. All nine entries agree with (D2)–(D10) and independent angular integration.`
Decision: [ ] move  [x] correct  [ ] keep

### C2. notes/03-projection-method-1pp.md:147–153
Records: four ranked former explanations: channel rephasing, C-even normalisation, source inconsistency and quadrature error, followed by the old slice evidence pointer.
Why it no longer holds: its own resolution at lines 165–169 and `history/LOG.md:12–17` settle the discrepancy.
Proposed: move all four hypotheses and the evidence-pointer sentence to history with a log entry; nothing remains. Keep the preceding independent-route, sampling-domain and convention descriptions at lines 139–145.
Decision: [ ] move  [x] correct  [ ] keep

### C3. notes/03-projection-method-1pp.md:155–171
Records: before-fix wrong values, sign-flip diagnostics, the authorised edit, deliberate-red output and former work-assignment status.
Why it no longer holds: `history/LOG.md:12–17`; `NOTEBOOK.md:13–14,25`. The final Cornell-witness sentence is an old status report, not evidence that the full suite passes.
Proposed: move the historical section to history with a log entry. Exact remaining section: `## 5. Independent comparison\n\nThe printed-D1 comparison gives 54 passing entries. The largest analytic residual is $4.67\times10^{-13}$ GeV$^{-2}$ and the order-12/order-18 quadrature change is at most $1.50\times10^{-13}$ GeV$^{-2}$. These recorded results concern the projection comparison, not a full-suite test claim.`
Decision: [ ] move  [x] correct  [ ] keep

### C4. notes/04-ome-2pp.md:519–530,534–535
Records: deliberate sign reversal, reversed time-ordering assignment and PP rephase results, plus the temporary-edit/reversion narrative.
Why it no longer holds: the same passage says the breaks were reverted; `NOTEBOOK.md:15–16` establishes the corrected potential.
Proposed: move the Deliberate-red table column, lines 534–535 and temporary-break sentence to history with a log entry. Rename the heading exactly to `## 8. Independent checks`. Keep the three check names, current successful residuals and the independence/sign-argument discussion in line 530; introduce it exactly with: `The exact-arithmetic table and the three numerical routes agree.`
Decision: [ ] move  [x] correct  [ ] keep

### C5. notes/04-ome-2pp.md:536
Records: missing-API test history, wrong small-product values and the failed quadrature-switch choice before the fix.
Why it no longer holds: the same paragraph says changing the switch to 0.3 resolves the failures; the current implementation description is at line 491.
Proposed: move the red/fix chronology and wrong numbers to history with a log entry. Exact remaining text: `For $2^{++}$ the real-momentum small-product branch uses 64-node quadrature below $|\mathcal B|/\max(|\mathcal A_\phi|,|\nu|^2,10^{-30}\,\mathrm{GeV}^2)=0.3$. In the recorded comparison with a 256-bit recurrence at $\mathcal A_\phi=1\,\mathrm{GeV}^2$, $\nu\in\{0.5,0.01,-0.3,-0.8\}$, the quadrature's relative error stays below $4\times10^{-15}$ up to that boundary; the ordinary recurrence's relative moment error is about $1.3\times10^{-12}$ there. The $1^{++}$ switch is 0.06.`
Decision: [ ] move  [x] correct  [ ] keep

### C6. notes/04-ome-2pp.md:537
Records: an uncommitted higher-momentum probe whose own convergence assertions fail; it is explicitly a diagnostic, not a committed check.
Why it no longer holds: the passage itself limits the apparent agreement by its unconverged independent integral; `NOTEBOOK.md:15–16` cites the established checks instead.
Proposed: move the scratch run and its apparent-agreement numbers to history with a log entry. Exact remaining text: `The committed double-solid-angle samples exercise the quadrature branch. The ordinary-recurrence branch is compared with an independent 256-node angular rule in the package test; the low-momentum comparison alone does not establish high-momentum double-solid-angle convergence.`
Decision: [ ] move  [x] correct  [ ] keep

### C7. notes/04-ome-2pp.md:543–546
Records: missing-helper red, the former ordered-offset comparison, sign-broken helper output and deliberately stale table output.
Why it no longer holds: its own restoration and green result at line 547; the symmetric time-ordering sum settles pair ordering at lines 454,475.
Proposed: move these four construction records to history with a log entry. Exact remaining text: `Offset pairs are compared unordered because $D_{\beta_1}+D_{\beta_2}$ is symmetric in the two labels.` Keep the check contract at line 541 (with F2's pointer correction), successful result at 547 and independence qualification at 549.
Decision: [ ] move  [x] correct  [ ] keep

### C8. literature/Zhang:2026iyr/bridge.md:28
Records: the coupling row also describes the deliberately uncorrected coupling used for a red run.
Why it no longer holds: `CONVENTIONS.md:73–77`, `NOTEBOOK.md:9–10`, and the row's own correct coupling fix the working definition.
Proposed: move the red-run sentence to history with a log entry. Exact remaining Relation cell: `g = (2/√3)√2 g_l; g_l = 35 MeV gives g ≈ 57 MeV.` Keep the source equation and `compact_coupling` mapping.
Decision: [ ] move  [x] correct  [ ] keep

### C9. literature/Zhang:2026iyr/bridge.md:34
Records: the original frozen extraction's mixed signs, basis-conversion fix and dated alignment narrative.
Why it no longer holds: `history/LOG.md:12–17`; `NOTEBOOK.md:13–14,25`.
Proposed: move the old-package comparison and fix evidence to history with a log entry. Exact remaining Relation cell: `The package uses the printed (D1) phase and reproduces (D4), (D7) and their transposes.` Exact Checked-by cell: `Independent double-angle Eq. (80) integration in checks/projection_1pp.py and the coefficient derivation in notes/03-projection-method-1pp.md.` See E4 for the duplicate Flags occurrence.
Decision: [ ] move  [x] correct  [ ] keep

### C10. GLOSSARY.md:137; literature/Zhang:2026iyr/bridge.md:38
Records: the discarded adiabatic branch and its compact-dominated endpoint remain inside the spurious-pole definition and bridge mapping.
Why it no longer holds: `history/LOG.md:19–23`; `NOTEBOOK.md:26` selects the predominantly hadronic member.
Proposed: move only the rejected-branch contrast and overlap-diagnostic record to history with a log entry. Exact replacement for the glossary's avoided-crossing clause: `through an avoided crossing with a bare level the continuation follows the predominantly hadronic member of the two levels.` Exact bridge Relation cell: `At the avoided 1P crossing, follow the predominantly hadronic member with smaller compact probability. The shallow endpoint may have compact probability above 1%.` Exact Checked-by cell: `Zhang:2026iyr v1, Fig. 5(a) caption; checks/shallow_spurious.jl.` Keep the rest of the glossary's definition and projection rule.
Decision: [ ] move  [x] correct  [ ] keep

### C11. literature/Bruschini:2023zkb/bridge.md:100
Records: an incomplete five-state HQSS construction and an inadmissible $j_\ell=5$ G-wave option are explicitly ruled out.
Why it no longer holds: the passage's own angular-momentum argument and complete six-row matrix at lines 81–98; `NOTEBOOK.md:15–16` establishes the HQSS check.
Proposed: move the rejected alternatives to history with a log entry. Exact remaining text: `The sixth row has $s_H=s_\ell=0$ and $j_\ell=L=2$. For even $L$, the retained $(s_H,s_\ell)=(1,1)$ and $(0,0)$ sectors have $C=+$. At total $J=2$ the retained $G$ wave has $j_\ell=3$. These six states form the complete heavy basis.`
Decision: [ ] move  [x] correct  [ ] keep

### C12. literature/Bruschini:2023zkb/bridge.md:108,131
Records: the explicitly rejected interpretation of Table 2 as a pure-D row or a complete HQSS rotation.
Why it no longer holds: its own signed longitudinal combinations at lines 110–129 and independent full rotation at lines 49–105.
Proposed: move the rejected-interpretation wording to history with a log entry, retaining all correct signed rows and equations. Exact heading: `### Table 2 longitudinal combinations`. Exact final paragraph: `The sector-wide signs are the signed Table 2 coefficients. Both benchmark rows have unit norm. The complete heavy-basis rotation is constructed independently from 9j/6j symbols.` This is a corrected conceptual explanation, not a claim that an abandoned implementation was observed.
Decision: [ ] move  [x] correct  [ ] keep

### C13. checks/baseline_fit.jl:20–24
Records: widened search neighbourhoods are justified by allowing the “deliberately uncorrected coupling” to reach assertions.
Why it no longer holds: the coupling is fixed by `CONVENTIONS.md:73–77`; red-run pipeline records were retired in `history/LOG.md:50–63`.
Proposed: move the red-run justification to history with a log entry; remove line 21. Keep the existing 0.014 GeV local search window and the correct limitation at line 20; no evidence here establishes a different replacement window. The published-mass/probability comparison remains the independent route.
Decision: [ ] move  [x] correct  [ ] keep

## D. Deliberately broken variants in code

### D1. checks/projection_1pp.py:14,22–29,54; checks/_projection.py:73–85
Records: `PROJECTOR_SIGN`, `--flip-5d1`, and the `projectors_1pp(sign)` parameter deliberately reverse the agreed printed-D1 projector.
Why it no longer holds: `NOTEBOOK.md:13–14,25`; `history/LOG.md:12–17,50–63` retires the wrong phase and red-run record.
Proposed: move the switch and broken branch to history with a log entry. Remove the mutable sign input, missing-sign guard and CLI branch. Change the helper to `def projectors_1pp():`; replace its coefficient with `value = -np.sqrt(3) / 2 * 1j * (` and its caller with `channels = projectors_1pp()`. Keep `sys` for the final exit status. The check keeps its real independent route: literal Cartesian spin matrices, printed-D1 projectors and double-solid-angle quadrature versus the package, with both mesons, fixed seed and orders unchanged. The complete scoped caller set is this one caller.
Decision: [ ] move  [x] correct  [ ] keep

### D2. checks/hqss_2pp.py:169–173
Records: `main()` recognises `--flip-pp`, constructs `broken`, and conjugates the computed potential while leaving the expected rotation fixed.
Why it no longer holds: its own comment says “Deliberately broken result”; `NOTEBOOK.md:15–16` establishes the correctly bridged potential and `history/LOG.md:50–63` retires red-run records.
Proposed: move lines 169–173 to history with a log entry; nothing replaces that branch. Keep the independently constructed 9j/6j rotation, phase dictionary, exact Table 2/orthogonality assertions, full block-diagonality and $J_\ell=1$ comparisons. Keep `sys` for normal failure reporting. Update the corresponding bridge flag as E12.
Decision: [ ] move  [x] correct  [ ] keep

## E. Bridge Flags

Every Flags/check-contract bullet in all four bridges is accounted for below. A correct convention, rounding qualification or coverage limit is not a suspected source error and need not become a notebook question. For settled source/pointer errors the bridge keeps only the corrected relation; the printed mistake and its evidence belong in history. Only E15 requires an unresolved-question proposal.

### E1. literature/Zhang:2026iyr/bridge.md:42
Records: integer percentages allow a contribution below 0.5%; printed zero is not exact absence.
Why it no longer holds: it still holds; the bridge's cited Table V and the 0.01 probability tolerance at line 31 settle the rounding interpretation.
Proposed: keep the flag or move its current content into the probability row exactly as: `Integer percentages are rounded; a printed zero permits a contribution below 0.5%.` No wrong value or suspected error to archive and no Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E2. literature/Zhang:2026iyr/bridge.md:43
Records: the predicted compact-dominated state is distinguished from the fitted $X_b$.
Why it no longer holds: it still holds; `NOTEBOOK.md:9–10` and `paper/sections/framework.tex:49–54,64–67,72–80` settle the assignments.
Proposed: keep the corrected assignment in the masses row exactly as: `The 10.544 GeV state is the predicted chi_b1(3P)-dominated state; the fitted 10.513 GeV state is X_b.` No source mistake or Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E3. literature/Zhang:2026iyr/bridge.md:44
Records: coverage is described by retired “slice 01,” although the bridge now covers further material.
Why it no longer holds: its own rows 16–17,32–38 and `history/LOG.md:50–63`.
Proposed: move the obsolete coverage description to history with a log entry. Exact replacement: `This bridge covers the two 1++ fits, OME projection conventions and spurious-pole projection used in the working files.` No Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E4. literature/Zhang:2026iyr/bridge.md:45
Records: the resolved package-phase mismatch and before/after fix narrative.
Why it no longer holds: settled by its own independent Eq. (80) evidence and `NOTEBOOK.md:13–14,25`; `history/LOG.md:12–17` already retires it.
Proposed: move the flag, wrong signs and fix evidence to history with a log entry. Nothing remains in Flags; the bridge row carries the corrected form in C9.
Decision: [ ] move  [x] correct  [ ] keep

### E5. literature/Baru:2019xnh/bridge.md:101
Records: the two C-even signs describe different one-particle conventions; a fifth-channel flip alone is not the full conversion.
Why it no longer holds: it still holds; the explicit field/state dictionary at lines 12,62–72 settles this as a convention difference, not a source error.
Proposed: keep the dictionary and current flag. A positive compact form is: `Use the complete one-particle field dictionary above when converting a paper amplitude; the independent route starts directly in the canonical fields.` No history move or Open question is warranted for the valid printed convention.
Decision: [ ] move  [x] correct  [ ] keep

### E6. literature/Baru:2019xnh/bridge.md:102
Records: isovector expressions, numerical inputs and prefactors require conversion before canonical use.
Why it no longer holds: it still holds; the bridge's rows 11,16–19,25–26 give the conversions.
Proposed: keep the converted forms in the bridge rows and this scope warning. These are different inputs/conventions, not erroneous values; no Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E7. literature/Baru:2019xnh/bridge.md:103
Records: an intentionally red input while `channels_2pp()` is absent, and assignment-time nonexecution.
Why it no longer holds: `NOTEBOOK.md:15–16` and the recorded green result in `notes/04-ome-2pp.md:526` settle the current state.
Proposed: move the flag to history with a log entry. Nothing remains in Flags; the projector row and convergence paragraph carry B3's corrected form.
Decision: [ ] move  [x] correct  [ ] keep

### E8. literature/Baru:2019xnh/bridge.md:104
Records: the task's rejected “Eq. (59)” axial-coupling pointer and the evidence correcting it.
Why it no longer holds: the flag itself settles the pointer using the pinned v2 numbering; rows 16 and 25 already identify the axial equations.
Proposed: move the mistaken pointer and numbering-check evidence to history with a log entry. Nothing remains in Flags. Exact corrected source form retained in the axial-vertex row: `Baru:2019xnh v2, Eqs. (34)–(37).`
Decision: [ ] move  [x] correct  [ ] keep

### E9. literature/Bruschini:2023zkb/bridge.md:135
Records: seed/domain-independent exact benchmarks, sampling points and fixed numerical tolerance.
Why it no longer holds: it still holds; `checks/hqss_2pp.py:23–42,125–137,174–190` implements the contract and `NOTEBOOK.md:15–16` cites the established result.
Proposed: keep the contract; remove only chronology if desired. No wrong printed form or suspected error and no Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E10. literature/Bruschini:2023zkb/bridge.md:136
Records: the public potential seam, strict-HQSS inputs, hard failure on missing API and the OME-only scope.
Why it no longer holds: the API exists for the established comparison (`NOTEBOOK.md:15–16`); the failure contract and scope remain correct.
Proposed: keep the substantive content, optionally replacing the first two sentences exactly with: `The check uses the public BOchiEFT.ome_potential with channels_2pp(), setting mB=mBstar=mbar and muPV=mbar/2 while retaining recoil and energy dependence.` Keep the OME-only limitation. No Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E11. literature/Bruschini:2023zkb/bridge.md:137
Records: the required four HQSS blocks and common $J_\ell=1$ block.
Why it no longer holds: it is established rather than merely required: `NOTEBOOK.md:15–16`; `notes/04-ome-2pp.md:528` records the evidence.
Proposed: correct to the current result exactly: `In the strict HQSS limit the OME matrix separates into blocks of sizes 2,1,2,1 labelled (s_H,j_l)=(1,1),(1,2),(1,3),(0,2). The first block equals the canonical 1++ block in the same light S/D order; the recorded residuals are given in notes/04-ome-2pp.md, Sec. 8.` No source error or Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E12. literature/Bruschini:2023zkb/bridge.md:138
Records: `--flip-pp` and a future instruction to the parent to record the red run.
Why it no longer holds: its deliberate failure is already recorded at `notes/04-ome-2pp.md:528,535`; current results are established at `NOTEBOOK.md:15–16`.
Proposed: move the flag and deliberate-failure evidence to history with a log entry; nothing remains in Flags. Keep the correctly phased bridge rotation and D2's independent check.
Decision: [ ] move  [x] correct  [ ] keep

### E13. literature/Bruschini:2023zkb/bridge.md:139
Records: construction-time nonexecution and a promise to establish numerical results later.
Why it no longer holds: `NOTEBOOK.md:15–16`; `notes/04-ome-2pp.md:528` already records the completed HQSS comparison.
Proposed: move the assignment-time status to history with a log entry. Exact replacement: `The recorded HQSS comparison has 15 passing assertions, forbidden entries at most 1.1×10^−15 GeV^−2 and common-block residual at most 9.7×10^−14 GeV^−2 (notes/04-ome-2pp.md, Sec. 8).` These are cited recorded results, not runs performed for this inventory.
Decision: [ ] move  [x] correct  [ ] keep

### E14. literature/Bruschini:2023zkb/bridge.md:140
Records: the source omits light-meson exchange; Table 2 supplies recoupling, not a source OME potential.
Why it no longer holds: it still holds; the flag supplies its source location and the bridge independently constructs the OME symmetry test.
Proposed: keep this source-scope qualification exactly as it stands. No wrong value, settled source error or Open question.
Decision: [ ] move  [x] correct  [ ] keep

### E15. literature/Wu:2026wxb/bridge.md:32 (also row 22)
Records: the source says the ratio log “may” give an incorrect result; the flag claims the draft records which contours fail.
Why it no longer holds: specific failing-contour evidence is not established. `NOTEBOOK.md:36–40` keeps the branch/contour checks open; `checks/appd_contours.py:33–35,119–122` still has no prescriptions. This is insufficient to declare a specific source result wrong.
Proposed: keep the source issue open; proposed NOTEBOOK Open question exactly: `For which admissible App. D contours does the principal ratio log differ from continuously tracked split logs, and how does this extend from the static Yukawa example to the full TOPT kernel? Establish the contour and branch prescriptions before claiming a failing case.` Replace the flag exactly with: `The explicit failing-contour cases for the ratio-log representation remain unestablished in this project; App. D treats first-quadrant p only.` In row 22 retain only the agreed corrected project form `$c(\ell_- - \ell_+)/(4pq)$` and source Eq. (64)/App. D pointers; do not present the draft as observed red-run evidence.
Decision: [ ] move  [x] correct  [ ] keep

### E16. literature/Wu:2026wxb/bridge.md:33
Records: the source treats static Yukawa exchange; TOPT claims are this project's, with a pointer to a nonexistent note.
Why it no longer holds: the scope distinction still holds; `NOTEBOOK.md:39` explicitly keeps the full-TOPT continuation open.
Proposed: keep the source-scope distinction, replacing the flag exactly with: `The paper treats static Yukawa exchange without TOPT offsets. Extension to the full TOPT kernel remains an Open question in NOTEBOOK.md, Kernel continuation.` No source error is settled and no additional duplicate Open question is needed beyond E15 and the existing entry.
Decision: [ ] move  [x] correct  [ ] keep

### E17. literature/Wu:2026wxb/bridge.md:34
Records: coverage is limited to App. D and Eqs. (63)–(64).
Why it no longer holds: it still holds; the bridge's own source/equation inventory at line 4 and rows 11–28 support the scope.
Proposed: keep the flag exactly as it stands. No source error or Open question.
Decision: [ ] move  [x] correct  [ ] keep

## F. Stale references into retired records (optional)

These are optional pointer/name cleanups, not further physics corrections. Historical material already covered above is not counted again here. Preserve the physics citations and working check paths. In each case the settling source is `history/LOG.md:50–63` (pipeline records retired).

### F1. checks/baseline_fit.jl:2; checks/shallow_fit.jl:2; checks/spurious_projection.jl:2; checks/shallow_spurious.jl:2,11
Records: direct retired slice paths, “referee findings,” and the `referee_results()` seam name.
Proposed: remove retired header pointers; use `NOTEBOOK.md, Established, Baseline 1++ spectrum` or `Shallow-Xb fit`. Keep the existing `referee_results()` call unless the user separately elects a coordinated upstream API rename: its implementation is outside this assignment's scope, and a local rename would break the check.
Decision: [ ] move  [x] correct  [ ] keep

### F2. notes/03-projection-method-1pp.md:153,169,171; notes/04-ome-2pp.md:522,541
Records: retired slices and a `local://` evidence artifact. Most disappear through C2–C4; line 541 still points to `plan/slices/04-ome-2pp.md:40–47`.
Proposed: remove the retired/local pointers; begin line 541 exactly with: `checks/projected_spin_numerator_2pp.py checks regenerated-table byte identity;`. Keep its remaining check contract and working derivation references.
Decision: [ ] move  [x] correct  [ ] keep

### F3. paper/sections/framework.tex:129; paper/sections/app-ome-2pp.tex:244
Records: convergence evidence points into retired slice files; exact contractions also point into `/tmp/ome-route/steps-2pp.md`.
Proposed: replace the first comment exactly with `% Numerical-convergence summary: NOTEBOOK.md, Established; checks/baseline_fit.jl and checks/shallow_fit.jl identify the computations.` This summary does not itself reproduce the retired convergence runs. Replace the second exactly with `% Exact contractions: checks/_spin_numerator.py --steps; notes/04-ome-2pp.md.` Archive supporting run detail rather than claiming the replacement checks rerun it automatically.
Decision: [ ] move  [x] correct  [ ] keep

### F4. toy/chi_c1_4010_width/README.md:12
Records: retired `briefs/2026-10-29-chi-c1-4010-width.md` pointer.
Proposed: remove the pointer with A1; the working README and `run.jl` remain the model/assumption record. If a current-state pointer is wanted, exact text: `Current result: NOTEBOOK.md, Established, Charm width toy.`
Decision: [ ] move  [x] correct  [ ] keep

### F5. GLOSSARY.md:119,139,144
Records: retired `decisions/0004-quark-model-fixed.md` and slice-02 decision wording.
Proposed: use the current `NOTEBOOK.md` Decisions entries `Quark model fixed` and `Spurious-pole identification`, retaining the pinned literature citations. The physical bare-mass choice remains open; this pointer cleanup does not decide it.
Decision: [ ] move  [x] correct  [ ] keep

### F6. literature/Wu:2026wxb/bridge.md:15–16,22–24,33; checks/appd_contours.py:12,16,33,121
Records: nonexistent `notes/05-continuation.md`, nonexistent `checks/continued_moments.jl`, a retired decision pointer and a claimed ratio-log red run.
Proposed: replace research-state pointers with `NOTEBOOK.md, Open questions, Kernel continuation` (and `Branch discrepancy` where appropriate). Remove the nonexistent check/evidence references; retain the draft `checks/appd_contours.py` path explicitly labelled `draft, prescriptions unfilled`. Preserve its $10^{-6}$ target rather than approving the pending tolerance changes. E15–E16 cover the substantive flags; no draft code is retired here.
Decision: [ ] move  [x] correct  [ ] keep

### F7. literature/Zhang:2026iyr/bridge.md:44–45; literature/Bruschini:2023zkb/bridge.md:138–139; literature/Baru:2019xnh/bridge.md:103
Records: slice coverage, parent instructions and assignment-stage red/green status.
Proposed: use the corrected current forms in E3–E4,E7,E12–E13; no extra working replacement or duplicate archive entry.
Decision: [ ] move  [x] correct  [ ] keep

### F8. paper/main.tex:2; notes/04-ome-2pp-contractions.py:4; checks/_projection.py:6–7; checks/projection_1pp.py:5; checks/projection_2pp.py:5,9; checks/hqss_2pp.py:5; checks/projected_spin_numerator_2pp.py:5; checks/time_reversal_2pp.jl:1; checks/appd_contours.py:5; checks/complex_form_factors.jl:1; checks/three_body_locator.jl:1; checks/lhc_1pp.jl:1; checks/lhc_scan_2pp.jl:1
Records: remaining slice labels and the claim-slice writing workflow.
Proposed: remove slice numbers/workflow labels, retaining each existing physical description, independent route and draft status. Exact main-source replacement: `% Section sources are input below in reading order.` Exact generic-helper replacement for lines 6–7: `coefficients or package moment functions enter this route. Channel data and species-changing 3D potentials are supplied by the caller.` No physics or continuation acceptance criterion changes.
Decision: [ ] move  [x] correct  [ ] keep

### F9. STANDARDS.md:3
Records: standards are framed as an axis of the retired referee pipeline.
Proposed: replace exactly with: `Standards for the project's working notes, checks and paper. The rules below take precedence over generic review defaults.` Keep all six substantive standards unchanged.
Decision: [ ] move  [x] correct  [ ] keep
