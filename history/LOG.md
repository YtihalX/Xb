# History

Dated, append-only, newest last: what no longer holds, why, who decided, and what replaced it. Read on the user's request.

## 2026-10-28 — Per-sector $V_0$ fit (superseded decision)

The user first chose to fit $V_0^{(2^{++})}$ to $\chi_{b2}(9912)$ and $\chi_{b2}(10269)$, absorbing fine splitting into a sector shift while importing $g,C,m_b,N,\Lambda$ from $1^{++}$; $\chi_{b2}(10524)$ was kept for discussion because CMS assigned its spin by mass ordering. The §I scope of the time excluded corrections beyond a sector-dependent $V_0$.
Why: the colleague's ruling, adopted by the user the same day: the quark model is fixed once for all quantum numbers.
Replaced by: NOTEBOOK.md, Decisions, "Quark model fixed" and "§I scope".
Records: `git show 6dea5e4:decisions/0001-2pp-parameters.md`; `6dea5e4:decisions/0003-section-I-scope.md`.

## 2026-10-29 — Package $^5D_1$ phase (wrong code, corrected)

The HadronDynamics.jl $1^{++}$ kernel carried the opposite sign on the four mixed $^5D_1$ entries relative to the printed (D1), a rephasing by $U=\operatorname{diag}(1,1,-1)$. Flipping only the VV projector sign reproduced the package, which ruled out a missing $\sqrt2$ normalisation and a quadrature explanation.
Who: the user chose to align the package to (D1).
Replaced by: Decisions, "$^5D_1$ phase"; Established, "$1^{++}$ OME projection".
Record: `6dea5e4:plan/slices/03-projection-method-1pp.md`, User decision.

## 2026-10-29 — Adiabatic overlap following (dead end)

Following the spurious pole by adiabatic overlap ended on the compact-dominated $1P$ state rather than the shallow-fit spurious pole.
Replaced by: Decisions, "Spurious-pole identification".
Record: `6dea5e4:plan/slices/02-shallow-fit-spurious-projection.md`, Continuation evidence.

## 2026-10-29 — 10 keV projection-strength tolerance (rejected)

The tolerance had no justification, and the unperturbed calculation already failed it: the baseline $2P$ spread is $0.104$ MeV.
Who: the user.
Replaced by: Decisions, "Projection precision".
Record: `6dea5e4:plan/slices/02-shallow-fit-spurious-projection.md`, Checks.

## 2026-10-29 — Decay momentum $p\approx272$ MeV for $\chi_{c1}(4010)\to D\bar D^*$ (wrong value)

The colleague's width estimate, about 20 MeV, used $p\approx272$ MeV; the physical kinematics give $p=519$ MeV. Since $p^2=0.269$ GeV$^2$, 272 is probably $p^2$ without the square root. The source of the slip is not known; the 20 MeV agrees with the toy's 13.9 MeV only by accident.
Replaced by: Established, "Charm width toy".
Records: `cleanup-2026-10-30.diff` (A1–A2: the toy's former comparison with 272 MeV); `6dea5e4:briefs/2026-10-29-chi-c1-4010-width.md`.

## 2026-10-30 — Assumed $X_{b2}$ energies in the singularity map (wrong assumption)

The agent's first draft of the slice-05 figure placed six $2^{++}$ scenarios at energies it chose itself.
Who: the user corrected it: $X_{b2}$ is not yet determined, and the map shows thresholds, lhc and rhc only.
Replaced by: Decisions, "Singularity map".
Record: session `~/.omp/agent/sessions/-xb/2026-10-29T13-55-48-789Z_01a187f2-09b5-7279-bd2a-f4d0aa652ce0.jsonl`, 2026-10-30T02:24.

## 2026-10-30 — Continuation work paused

Work on the continued kernel stopped at the user's request. Its scratch evidence (the contour-definition conflict, the complex-form-factor precision limits, the tracker/moment discrepancy) is under Open questions.
Record: `6dea5e4:plan/slices/05-continuation-kernel.md`, Paused.

## 2026-10-30 — Pipeline records retired

After reviewing the notebook draft, the user removed `plan/`, `decisions/`, `briefs/` and the empty `meetings/`; the notebook was drafted from them. Read them with `git show 6dea5e4:<path>`:

- `plan/PLAN.md`: research question, claims, method decisions, validation.
- `plan/slices/01-checks-env-baseline-fit.md`, `02-shallow-fit-spurious-projection.md`, `03-projection-method-1pp.md`, `04-ome-2pp.md`: the work behind Established, with results.
- `plan/slices/05-continuation-kernel.md`, `06-continued-lse.md`, `07-continuation-poles.md`: the continuation work, now Open questions and Next step.
- `decisions/0002-2pp-renormalisation.md`, `0003-section-I-scope.md`, `0004-quark-model-fixed.md`, `0005-continuation-method.md`: in force, summarised under Decisions.
- `decisions/0001-2pp-parameters.md`: superseded (above).
- `briefs/2026-10-29-chi-c1-4010-width.md`: the charm-toy write-up.

## 2026-10-30 — Notebook split

The user asked that superseded and wrong material stay out of the agent's context. The notebook's log moved here; NOTEBOOK.md keeps the decisions in force, phrased without what they replaced. `old/` (superseded drafts, gitignored) moved to `history/old/`, and the AGENTS.md line about it went. `CLEANUP.md` lists the passages in the working files that still record superseded or wrong material, for the user to mark.

## 2026-10-30 — Working-file cleanup applied

The user marked all 49 items of `CLEANUP.md` "correct"; each proposal was applied as written. E6, E14 and E17 proposed no change; E1, E2, E5, E9 and E10 took their optional rewrites. What left the working files:

- Wrong values: the toy's comparison with the colleague's 272 MeV chain (A1–A2); the relativistic heavy-meson energy in the paper's notation table (A3); the `B^*\bar{B}^8` label in `followup.tex` (A4).
- Superseded stage text: `followup.tex`'s OME to-do (B1); the checks' guarded-input stage (B2); the Baru bridge's planned-assertion wording (B3); the notes' PDF snapshots (B4), now `notes-pdf/`.
- Fix narratives and rejected hypotheses: notes 03 and 04, three bridges, the glossary's spurious-pole definition, the baseline-fit window justification (C1–C13).
- Deliberately broken check modes: `PROJECTOR_SIGN`/`--flip-5d1` and `--flip-pp` (D1–D2).
- Settled bridge flags (E3, E4, E7, E8, E12, E13, E15, E16) and pointers into retired records (F1–F9).

Why: only what holds stays in the working files. Who: the user.
Replaced by: the corrected working files. E15 added the Open question "Ratio-log representation". Follow-ups the user approved the same day: A1's text had dropped the toy README's LHCb pin and E15's had dropped the Wu bridge's validity condition (S-wave static Yukawa, equal masses); both were restored. The guarded-input markers in the four fit checks went, as in B2.
Exact old text: `cleanup-2026-10-30.diff` ("-" lines). Reasons per item: `CLEANUP.md`.

## 2026-11-04 — Admissibility wording (replaced convention)

`CONVENTIONS.md`, "Continuation to other sheets", called $\mathcal C$ admissible when the flipped poles lay between $[0,\Lambda]$ and $\mathcal C$ "and no other singularity of the integrand does"; "Continued angular moments" continued $s_\pm$ and $L^{(\beta)}_\pm$ "from real momenta below the lowest three-body threshold" along an unstated path. That wording rejected every path deeper than $m_\pi$: the swept curve $\mathcal C+im_\pi$ then lies between the paths, although it never crosses $\mathcal C$.
Why: every Fredholm term of $D_{\mathcal C}$ is independent of the deformation exactly when the kernel stays analytic on $\mathcal C_\lambda\times\mathcal C_\lambda$ and no propagator pole meets $\mathcal C_\lambda$; "nothing between" is needed only by relations at a fixed external momentum, such as the on-shell-point route.
Who: the user, grilling 2026-11-04 ("Adopt homotopy wording").
Replaced by: `CONVENTIONS.md`, both entries; NOTEBOOK.md, Decisions, "Admissibility"; `notes/06-xb2-pole-problem.tex`, Secs. 5.2–5.3 and 6.
Exact old text: `git show 61460dc:CONVENTIONS.md`.

## 2026-11-04 — Branch-discrepancy count (not reproducible)

The Open question "Branch discrepancy" quoted 62–134 disagreements out of 6144 pion contour pairs between the continuity tracker and the principal split-log moments, on test paths with steep first legs from $0$ to $0.01-0.2i$ GeV at depth $0.2$ GeV. The probe script went with `plan/`, and its setup (path nodes, energies, what a pair is) was never written down, so the count cannot be reproduced.
Who: the user, grilling 2026-11-04 ("New recorded probe set").
Replaced by: NOTEBOOK.md, Decisions, "Checks per stage" (the Stage 2 gate on a new recorded probe set); Open questions, "Branch discrepancy".
Record: `git show 6dea5e4:plan/slices/05-continuation-kernel.md`, lines 60–61.

## 2026-11-04 — On-shell-point domain (sharpened)

Decisions, "Continuation route", limited the on-shell-point route to $|\operatorname{Im}k_\alpha|<m_\pi$, where an exchanged-meson branch point of $V(k_F,q)$ reaches $[0,\Lambda]$. The three-body branch point of the $B\bar B\pi$ ordering of $PV\leftarrow PV$, at $q\simeq k_5\pm i\sqrt{m_\pi^2-\Delta m^2}=k_5\pm130.4i$ MeV, gets there first (derived in the grilling, not checked).
Who: the user, confirming the close of the grilling, 2026-11-04.
Replaced by: NOTEBOOK.md, Decisions, "Continuation route"; `notes/06-xb2-pole-problem.tex`, Sec. 5.3.

## 2026-11-04 — Master prompt adapted and retired

`xb2_topt_ome_agent_master_prompt.md`, the plan for the continued TOPT OME solver that the user agreed with another AI, was the starting point of the grilling of 2026-11-04 and now lies in `history/`.
Adopted: Stages 0–7 with their gates, as checks the user picked per stage; the homotopy admissibility; the module split, as `code/Xb2Continuation`; the narrow-domain start.
Not adopted: the Markdown specs in `docs/xb2-topt/` (one LaTeX note, `notes/07`, instead); `IMPLEMENTATION_PLAN.md` and `DECISIONS.md` (NOTEBOOK.md instead); autonomous chaining of stages (one task per stage); a commit per stage (commits on request); changes inside HadronDynamics.jl (a separate project); Stage 8 (outside this phase).
Who: the user.
Replaced by: NOTEBOOK.md, Decisions, "Admissibility" through "Search domain and uncertainty". The Open questions "Contour definition", "Tolerances" (except the complex $f_n$), "Continued LSE: possible direction" and "Poles and couplings: possible direction" were closed into them.

## 2026-11-04 — Singularity map retired

`notes/05-singularity-map.md` and its scripts `notes/05-singularity-map/` now lie in `history/05-singularity-map.md` and `history/05-singularity-map/`; file paths inside them still name `notes/`. The map inventoried thresholds, sheets, the on-shell OME left-hand cuts and the loop-momentum singularities. None of its numbers was a recorded check. NOTEBOOK.md, Decisions, "Singularity map" (2026-10-30) now records the retirement, and its open question "Singularity map awaits checks" is replaced by "On-shell cut pattern".
Why: `notes/07-continued-lse.tex` carries what the continuation uses, recomputed from its own formulas: the off-shell moments (Sec. 3), the exchanged-meson and three-body branch points with their filter and motion (Sec. 5), and the on-shell inelastic branch points (App. A). Its numbers agree with the map's to the printed digits, which is not a check.
Left out, being unverified and not recomputed: the sampled graph-path deformation test down to $\operatorname{Im}E=-100$ MeV (map, Sec. 5); the on-shell cut pattern, Case 1 or Case 3 (Sec. 4); the spurious ratio-log seam through $-24.31$ MeV (Sec. 4.4); the one-channel static Yukawa test of the on-shell-point identity (Sec. 6). The leads that matter stay in NOTEBOOK.md, Open questions: Ratio-log representation, On-shell cut pattern, Pole condition in full TOPT.
Who: the user, grilling 2026-11-04 ("Retire after 07"); carried out in Stage 0.
Replaced by: `notes/07-continued-lse.tex`. In `notes/06-xb2-pole-problem.tex` the pointers now go to note 07, and three passages that rested on the map alone were removed. Sec. 5.2: "and the three-body branch points did not cross the sampled graph paths, which pass such a deformation test down to $\operatorname{Im}E=-100$~MeV at the region midpoints (notes/05-singularity-map.md, Sec.~5; not a recorded check)", now "whether the three-body branch points cross it is not settled here", with the note-07 validator. Table 2 caption: "some with a doubled cut up to the lower threshold". Sec. 5.4: "The one-channel static Yukawa version was confirmed numerically in a throwaway calculation (notes/05-singularity-map.md, Sec.~6), not a recorded check."

## 2026-11-05 — Note 07, Secs. 3–4: statements corrected

Several statements of `notes/07-continued-lse.tex` as built on 2026-11-04 were wrong or overstated; the old version lies in `history/07-continued-lse.2026-11-04.tex`. Statement numbers below are the current ones.
- The remark after S28 said that deforming the path "swings [the cuts] into the lower half plane". For $\Sigma(\mathcal C)$ this is wrong: it is a two-dimensional region of the energy plane, and part of it lies in the upper half plane ($E^*\simeq4140+143i$ MeV at $p'=\Lambda$, $q=1500-200i$ MeV).
- S28 said $D_{\mathcal C}$ is analytic off $P_\alpha(\mathcal C)\cup\Sigma(\mathcal C)$; that holds for the OME-only determinant, and the full $D_{\mathcal C}$ has the bare-state poles there. Its last clause took the logarithms from one reference energy along one segment; a chain of segments inside the domain is needed.
- S27 omitted the condition $\operatorname{Re}E_1<\delta_\alpha+\Lambda^2/2\mu_\alpha$, under which a flipped pole crosses the real axis inside $(0,\Lambda)$.
- S24 and S25 were stated for any admissible homotopy; their proofs hold for graph paths along which every $w_\pm$, $Z_\pm$ stays nonzero, and S25(b) needs paths piecewise $C^2$ with fixed breakpoints, S25(a) bounded path length.
- S14 assumed, without saying so, that $s_+-s_-\to0$ as $B\to0$; S31 needed a connector between different starting energies.
Why: an independent audit of Secs. 3–4 by a subagent (2026-11-05), prompted by the user's objection that the kernel's singular points move during the homotopy; I checked each item.
Who: the user, 2026-11-05 ("Fix all + slope theorem"); the wording of (K) in S23 and `CONVENTIONS.md` stays ("Keep wording as is").
Replaced by: the corrected S14, S24, S25, S27, S28, S31 and the remark after S28; new: the commentary after S23 on what (K) constrains, and S35, the slope bound (graph paths with slopes at most 1 satisfy (K) for $\operatorname{Re}E<47.58\,{\rm MeV}-H^2/m_B$), with S38 and S40 and the remark after the path table adjusted to it.

## 2026-11-05 — Moment precision target loosened

`notes/07-continued-lse.tex`, S22, set a provisional target of $10^{-12}$ relative per angular moment. In Stage 2 the x-plane checks found the double-precision closed form above S22's switch off by up to $9.7\times10^{-12}$; to meet $10^{-12}$ the package was made to recompute in BigFloat whenever $16\epsilon\,\kappa>10^{-13}$, which sent 109,237 of the 110,592 probe records to BigFloat and made the moments $2.4\times$ slower.
Why: the targets downstream are $10^{-6}$ for on-shell $T$ and $0.1$ MeV for poles, and the error from the finite number of quadrature nodes is far larger than $10^{-11}$; at a $10^{-10}$ target only 1,579 records above the switch escalate.
Who: the user, 2026-11-05 ("let's first loosen the condition in S22").
Replaced by: S22 as a definition with target $10^{-10}$ and escalation at $16\epsilon\,\kappa>10^{-10}$; the package's precision policy (`code/Xb2Continuation/docs/API.md`); the criterion of `checks/moments_straight_x.jl` and `checks/moments_deformed_x.jl` (target plus the oracle's own error).

## 2026-11-08 — Slide continuation: probability interpretation made conditional

What: the original implementation handoff, including its instruction to interpret the three-sector formulas as bound-state probabilities, is preserved in `history/slides-continue-plan.2026-11-08-before-implementation.md`.
Why: the source's ordinary emission vertices generate same-line self-energies plus exchange under three-body elimination (`Xb.tex:996-1001`), but its displayed OME is exchange-only (`Xb.tex:1020-1032`) while its probability derivation asserts the full positive spectral product (`Xb.tex:2457-2465`). No subtraction/field-normalization prescription was found; no correction of the source was accepted or applied.
Who: the user selected “Make the formulas conditional” after seeing the algebraic gap, rather than resolving that prescription or dropping the probability section.
Replaced by: the amended `learning/pre/slides-continue-plan.md`, the explicitly conditional derivation in `learning/pre/slides-continue.tex`, and NOTEBOOK.md's decision/open question. The scattering kernel, frozen paper, glossary and binding conventions are unchanged.
