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
