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

## 2026-11-13 — Presentation sources consolidated

What: the five original TeX sources in `learning/pre/` (`main-v2-speech.tex`, `main.tex`, `s_channel_note.tex`, `slides-continue.tex`, `speech.tex`), the completed `slides-continue-plan.md`, and the empty `slides-continue.typ` scaffold are preserved unchanged in `history/2026-11-13-pre-consolidation/`. Archive files retain their original workspace-relative paths; they are historical copies, not new build entries.
Why: the user requested one or two TeX files and a sanitized directory. Repeated preambles, obsolete source entry points, the completed handoff and the empty scaffold no longer belong in the active directory.
Who: the user; consolidation and housekeeping by the assistant. No new physics decision, correction or independent physics check.
Replaced by: `learning/pre/main.tex` (marked compact-sector derivation, marked continuation, detailed reference companion) and `learning/pre/speech.tex` (user transcript/private instructions, separately scoped 32-slide `main-v2` script). Markup, unanswered questions and the conditional three-body interpretation remain. The shared bibliography supplies exported references; the unexported Sekihara reference and the original implementation provenance remain explicitly in `main.tex`. Typst decks, figures and source scripts are unchanged; generated PDFs now live in `learning/pre/build/`.

## 2026-11-13 — Path quadrature (S40): on-shell kernel and pole subtraction reread

What: three paragraphs of NOTEBOOK.md, Open questions, Path quadrature (S40), written earlier the same day, and the first drawing of `notes/07-continued-lse/onshell_lhc_where.png`. That figure shaded every singular point of $V(k_F,q)$ in $R(\mathcal C)$ as "where treating the propagator pole explicitly meets the left-hand cut". The paragraphs, verbatim:
> Subtracting the pole is no remedy there for $D_{\mathcal C}$ (user, 2026-11-13). It puts one kernel momentum on shell, $V(k_F,q)$ and $V(p',k_F)$: the integral $J(p;m)$ of [@Wu:2026wxb] App. D, worked there for static Yukawa exchange only. For TOPT the question stays open (Ratio-log representation, On-shell cut pattern). Graded nodes keep both momenta on $\mathcal C$ and need no on-shell kernel.
>
> Where it bites (plot evidence, `notes/07-continued-lse/onshell_lhc.py`, `onshell_lhc_where.png`). The setup: the S40 path at $d_k=d_{k,\max}/2$, 0.05–15 MeV above each threshold, $\Gamma=1$–$40$ MeV in steps of 1.5 MeV, pion exchange, and the orderings of the blocks with an on-shell $F$ leg. On it the singular points of $V(k_F,q)$ enter $R(\mathcal C)$ from $\Gamma=13$ (VV), $14.5$ (PV) and $16$ MeV (PP) on that grid. At $\Gamma=20$ MeV they are inside up to about 4 MeV above the VV and PV thresholds and 3.4 MeV above the PP threshold. The exchanged-meson point $k_F+im_\pi$ enters once $|\operatorname{Im}k_F|>m_\pi$, i.e. for $\Gamma>2\sqrt{2\varepsilon a+a^2}$ with $a=m_\pi^2/\mu_\alpha$ and $\varepsilon=\operatorname{Re}E-\delta_\alpha$: 14.3–14.4 MeV at threshold, and at $\Gamma=20$ MeV up to $\varepsilon=3.3$–$3.4$ MeV. Three-body points ($\beta=3$ for VV, $\beta=1$ for PV) enter slightly earlier; for PP none does. For $\Gamma\le12$ MeV nothing enters.
>
> App. D's second way in these kinematics (`onshell_lhc_second_way.png`; App. D's example with $p=k_5$, $m=m_\pi$, 1 MeV above the PV threshold, 30 digits). The S40 path and the real axis with pole term plus cut term both reproduce the exact $J$ to working precision for $\Gamma=2$–$40$ MeV. Dropping the cut term, or using the principal ratio log, leaves an error from $3.5\times10^{-3}$ at $\Gamma=16.5$ MeV ($|\operatorname{Im}k_5|=m_\pi$ at $16.25$ MeV) up to $0.17$ and $0.097$ at $\Gamma=40$ MeV. The pole term, cut term and reference are those of `checks/appd_contours.py`.

Why: membership in $R(\mathcal C)$ is S32's second condition, which belongs to the on-shell-point identities; those return to the real path. On a deformed path only crossing the path counts (S32, first condition). The points counted were up points, which enter $R(\mathcal C)$ across $[0,\Lambda]$, not across $\mathcal C$. App. D's $J$ on the S40 path is exact to 30 digits with $k_5+im_\pi$ in $R(\mathcal C)$. With the path through $k_F$ and the pole subtracted, $V(k_F,q)$ is the kernel at two path points (S34, S35); that route is exact as well. The first paragraph also attributed to the user a conclusion the user had not drawn.
Who: the user, 2026-11-13 ("as long as the contour do not cross them in the homotopy we are fine"; proposed Sokhotski–Plemelj on the deformed contour); checked the same day with `notes/07-continued-lse/onshell_lhc.py`.
Replaced by: the paragraphs "Pole subtraction (Sokhotski–Plemelj) on the deformed path: route 3", "What the on-shell kernel requires", "Threshold grid" and "App. D's example on the three routes" in NOTEBOOK.md. `onshell_lhc_where.png` was redrawn with up points (crossed $[0,\Lambda]$) and down points (swept by the path) kept apart. `onshell_lhc_second_way.png` was replaced by `onshell_lhc_routes.png`.

## 2026-11-13 — S40 path rule adopted: deformed SP method, sheet as a sign

What: (1) In `notes/07-continued-lse.tex`, S40 (`st:shape`), which defined the default path as the three-segment margin path of `graph_path` with pole margin $d_k$, and the remark after the path table; the statements S9 (`st:lse`), S23 (`st:admissible`, condition (P)), S26 (`st:nystrom`), S32 (`st:external`), S38 (V3) and S41 (counts), whose wording assumed that path. The full note before the change is `history/07-continued-lse.2026-11-13.tex`. (2) NOTEBOOK.md, Open questions, "Path quadrature (S40)", 22 paragraphs of evidence and proposals written up to the decision, moved verbatim to `history/2026-11-13-s40-open-question.md`; "the default path shape (S40)" in "Method proposals of note 07". (3) NOTEBOOK.md, Decisions, Admissibility: the entry read as it does now without the sentence on channels with an on-shell node and without "amended 2026-11-13 by the S40 path rule". (4) The draft `notes/07-continued-lse/s40-proposal.tex`: its title, its status line, the "not adopted" line of Sec. "Sheet as a sign", the section "What changes if adopted" and the first of its choices, preserved in `history/2026-11-13-s40-proposal-before-adoption.md`.
Why: plain Gauss–Legendre on the margin path converged slowly where a propagator pole came within the margin of a segment about 4 GeV long, and the margin vanished just above each threshold (the moved paragraphs). With Sokhotski–Plemelj on a deformed path the sheet is one sign per channel, the poles no longer constrain the path, and a path certified over a rectangle gives one analytic $D$ there (draft, L7, L8).
Who: the user, 2026-11-13 ("agree with sheet as a form and the glossary, try to push forward to actually implement this S40"), after the plots of the draft; the glossary entry "Deformed SP method" was approved in the same message.
Replaced by: note 07, S40 as a definition, parts (a)–(f) (path per rectangle at its centre, panel quadrature with $L_p=250$ MeV and $n_p=16$ to start, on-shell nodes with weight $W_\alpha$ and the sign of the sheet, certificate (C1)–(C5), principal kernel branches), with the amended S9, S23, S26, S32, S38 and S41; NOTEBOOK.md, Decisions, "S40 path rule" and the amended Admissibility entry; the condensed open question "Path quadrature (S40)"; the draft as derivations and evidence, with L8 (node pairs on a rectangle) and the paragraph "Rectangles"; the package functions `sp_path`, `panel_rule`, `onshell_nodes`, `certify_rectangle` and `tile_rectangles` (`code/Xb2Continuation/src/sp_contours.jl`). `graph_path` stays as the margin path, the second path of the Stage 6 path-independence check.

## 2026-11-15 — S40 near nodes made optional

What: the node set of `notes/07-continued-lse.tex`, S40(c), "the vertex channels and every other channel whose pole comes within $r_{\rm near}=100$ MeV of $\mathcal C_Q$", and condition (C3) of S40(d), "every channel outside $N_Q$ stays at least $r_{\rm near}$ from $\mathcal C_Q$"; the NOTEBOOK.md paragraph "Near nodes" under Open questions, Path quadrature (S40), which proposed the change. All three verbatim in `history/2026-11-15-s40-near-nodes.md`. Also the package's node selection in `certify_rectangle`, which made every channel within $r_{\rm near}$ a node.
Why: the tiling left two thin gaps in the search domain, just below the PV threshold on $(-,+,+)$ and just below the VV threshold on $(-,-,+)$, at the real axis. There the unflipped pole of the channel below its threshold came within $r_{\rm near}$ and became a node whose entry $V(k,k)$ lies next to that channel's on-shell left-hand cut, so C5 failed. Every path with slopes at most 1 passes such a pole on the sheet's side, so its residue term is only quadrature error: $1.4\times10^{-12}$ of the loop at 65 MeV from the path, the nearest the failing nodes come (`notes/07-continued-lse/gap_failures.png`, `gap_failures.py`, `gap_failures_fix.jl`). For a channel flipped below its threshold the node carries the continuation and cannot be dropped; that case is recorded under Stage 8.
Who: the user, 2026-11-15 ("with -++ sheet we can of course drop the k node, but when in --+ we cannot do this"; "okay, I think we achieved an agreement on this problem right now").
Replaced by: S40(c) and (d) as amended (a channel without a vertex joins $N_Q$ only when its node passes (C4) and (C5); otherwise it is integrated on the path and its distance recorded; vertex nodes are never dropped); NOTEBOOK.md, Decisions, "Near nodes optional", and the addition to Open questions, Stage 8; `certify_rectangle` with the new `dropped` field of `RectangleCertificate` (`code/Xb2Continuation/docs/API.md`), its tests, and the rerun tiling.

## 2026-11-15 — Talk notation aligned with Xb.tex

What: the pre-alignment `learning/pre/slides/BOchiEFT.typ`, including its embedded notes, is preserved unchanged in `history/2026-11-15-BOchiEFT-notation/BOchiEFT.typ`. Its project-specific spin/energy labels and the two-potential shorthands `U`, `W`, `S`, `F`, unhatted matrix `J` and `tau`, and alternative angular-wave-function notation no longer define the active deck.
Why: the user requested that this talk stick to the Xb paper. The paper's raw continuum amplitude and its normalised radial wave function must also be distinguished by `phi = sqrt(4 pi) Psi_S`, rather than assigning them the same symbol and measure.
Who: the user, 2026-11-15; implementation by the assistant.
Replaced by: the same slide entry point with the paper's notation, row-oriented form-factor matrix and corresponding transposes, explicit normalisation conversion, and declared derivation-only auxiliaries. `CONVENTIONS.md` records the deck-only energy/offset exceptions; other notes and code are not migrated. The 55-slide order, interaction kernels and numerical inputs are unchanged; both the talk and presenter-note PDFs are rebuilt. The three-body spectral identification remains conditional.

## 2026-11-15 — Talk, Task 4 slide structure replaced

What: the Task 4 slides of `learning/pre/slides/BOchiEFT.typ` as built on 2026-11-09/10 from the user's cyan instructions: Step 1 (the trace Lagrangian and the field definitions) and Step 2 (Goldstone bosons with the explicit $\Phi$ matrix, the expanded Lagrangian) as separate slides, the static limit as a bullet on the energy-denominator slide, the roadmap's Task 4 line as the isospin combination $3V(m_\pi)+\frac13V(m_\eta)$, and no speaker notes after Step 1. The deck before this change, with the closing slide and the backup slide added earlier the same day, is preserved in `history/2026-11-15-BOchiEFT-task4/BOchiEFT.typ`.
Why: the user did not know what to say about OME; the slides derived the potential without saying what it does in the calculation. `learning/pre/ome-talk-plan.md` builds Task 4 around the two parts of the $X_b$ norm that only OME produces, $\mathcal P_D$ through the tensor force and $\mathcal P_{\text{3-body}}$ through the energy-dependent denominators.
Who: the user, 2026-11-15 ("add the closing slide and backup the projection"; "apply all the ome-talk-plan").
Replaced by: the Task 4 described in NOTEBOOK.md, Established, "Talk, Task 4 rebuilt from the OME plan".

## 2026-11-15 — Talk, Task 4: definition slides moved to backup

What: the nine-step Task 4 built earlier the same day from `learning/pre/ome-talk-plan.md`, whose rows kept the Lagrangian, the TOPT derivation, the four classes, the energy denominators, the four kernels, the six partial-wave entries and the isospin factors in the main flow, "shown without reading". Also the assistant's advice of that day, recorded in NOTEBOOK.md as "Not deleted: Steps 4, 7, 8 and 9 define what later slides use […]; only Step 3 could move to backup without a patch elsewhere", with speaker notes of three or four sentences saying what each of those slides is for. The deck and the plan in that state are in `history/2026-11-15-BOchiEFT-task4-steps/`.
Why: on those slides there was nothing to say but the definitions.
Who: the user, 2026-11-15 ("I don't like T4S1 because merely reading the definitions is meaningless, and so for the T4S3,S4 ,S5,S7,S8,S9").
Replaced by: NOTEBOOK.md, Established, "Talk, Task 4 in compact form": the seven slides are backup B1–B8 (with the projection slide), and one new slide, Step 2, carries what the rest of the talk needs from them ($D_\beta$, $\mu_{1,2}$, the $B\bar B^*\to B\bar B^*$ kernel) as a claim about three-body states.

## 2026-11-16 — Talk, Task 4: roadmap removed, Lagrangian shown before the vertices

What: (a) the slide “What to do next?” that stood before Task 4 in `learning/pre/slides/BOchiEFT.typ`: Task 4 as the $B\bar B^*\to B\bar B^*$ kernel with its tensor numerator and three-body denominators marked, Task 5 as the two-potential formula, Task 6 as the normalisation $1=\mathcal P_{\bar bb}+\mathcal P_S+\mathcal P_D+\mathcal P_{\text{3-body}}$, with the user's speaker note. (b) The arrangement of 2026-11-15 in which the Lagrangian appeared only on backup slide B1 and the vertices slide said “Lagrangian: backup”. The deck before this change is in `history/2026-11-16-BOchiEFT-roadmap/BOchiEFT.typ`.
Why: not stated for either.
Who: the user, 2026-11-16 ("I'd like to delete the what to do next before task 4"; "before showing the vertices, I think we'd better show the lagrangian after taking the trace").
Replaced by: (a) nothing: the power-counting block leads into Task 4, and the roadmap of Tasks 1–3 earlier in the deck stays. (b) Task 4, Step 1, “The Lagrangian; one derivative per vertex”, which shows the Lagrangian after the spin traces only; the trace form and the field definitions stay on B1 (NOTEBOOK.md, Established, “Talk, Task 4 in compact form”).

## 2026-11-16 — Talk, Task 4: Lagrangian and vertices merged

What: the separate T4S1 (“The Lagrangian; one derivative per vertex”) and T4S2 (“The vertices; P waves mix S and D”) slides. The pre-merge deck is preserved in `history/2026-11-16-BOchiEFT-merged-vertices/BOchiEFT.typ`.
Why: combine the derivation into one slide and remove repetition.
Who: the user (“T4S1 and T4S2 can be merged into one, maybe delete something”).
Replaced by: one T4S1, “Lagrangian, vertices and tensor force”, retaining the full trace-evaluated Lagrangian, both vertex rules and the central/tensor decomposition. Repeated field definitions, coupling-value bullets, the antimeson-sign discussion and the separate channel box are absent from the main slide. Field conventions and coupling values remain on backup B1. The denominators and static-limit slides are now Steps 2 and 3. No interaction or numerical input changed.

## 2026-11-27 — S40 pole vertices are not required

What: note 07, S40(a), defined $\mathcal C_Q$ as the polygon with a vertex at the centre momentum (clipped to the slope-one line) of every flipped channel and every unflipped channel with $\delta_\alpha<E_2$; S40(c) said “$N_Q$ contains the vertex channels.” `code/xb2c/SPEC.md`, story 24, said “vertices at the flipped channels' poles.”
Why: the path side does not set the sheet in a channel with on-shell subtraction; the analytic node term does. The pole-based polygon is a valid reference construction where certified, not a geometric requirement.
Who: the user, restating the earlier decision that kernel cuts determine the deformation; wording by the assistant.
Replaced by: S40 and the solver documentation distinguish the kernel certificate and mandatory node set from the current polygon builder. No construction, node selection, or certificate was changed in code.

## 2026-11-27 — Real contour first in the C solver

What: `certify_s40` always built the reference polygon with a knot at each mandatory node channel's centre momentum, clipped to slope one. The Stage 4 tiling test pinned this polygon's margins and split pattern. The Stage 6 convergence run tested five probes on it: 15/15 comparisons passed, with worst relative changes $9.02\times10^{-9}$ in $T$ and $3.14\times10^{-13}$ in $\tilde D$, on meshes of 272, 528 and 544 path nodes.
Why: a pole handled by SP subtraction does not require a vertex. With the new builder, 55 of the 58 certified cells in the two baseline strips pass on $[0,\Lambda]$; the other three certify after a bend. The old convergence numbers apply to the reference geometry only.
Who: the user, “try $[0,\Lambda]$, and deform only where the kernel needs it.”
Replaced by: real path first, with certified kernel-driven fallback trials in `code/xb2c/src/lse.c`; coverage rather than the old geometry's exact margins, and the six-probe Stage 6 check of the selected paths. The Julia reference retains the original polygon.
