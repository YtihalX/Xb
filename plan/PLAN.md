# Plan: the spin-2 partner $X_{b2}$ in LO BOχEFT (followup.tex §I)

## Research question

In LO BOχEFT [@Zhang:2026iyr] v1, with every parameter fixed in $1^{++}$ (baseline fit and shallow-$X_b$ fit), is there a molecule-dominated $2^{++}$ state $X_{b2}$ near the $B^*\bar B^*$ threshold? If so, where is its pole (mass $M$, width $\Gamma$, binding energy relative to $2m_{B^*}$), and where are the $\chi_{b2}(1P)$-, $\chi_{b2}(2P)$-, $\chi_{b2}(3P)$-dominated states?

It matters for two reasons. The $X_{b2}$ is the heavy-quark spin partner of the $X_b$, so its existence and position test the reading of [@Zhang:2026iyr] v1, in which the baseline fit takes the measured $\chi_{b1}(10513)$ as the $X_b$. And the predicted $2^{++}$ spectrum between 10.52 and 10.65 GeV bears on the CMS peak $\chi_{b2}(10524)$, whose $J$ was assigned by mass ordering [@CMS:2018vgf] v2.

## Approach

The framework is LO BOχEFT as in [@Zhang:2026iyr] v1: full OME, $s$-channel exchange of $N$ bare states, and one contact term $C$, unitarised by a Lippmann–Schwinger equation with a sharp cutoff $\Lambda$ (CONVENTIONS.md "Lippmann–Schwinger equation", "Loop measure and regulator"). The $2^{++}$ sector has six channels with the $S$-wave channel $B^*\bar B^*(^5S_2)$ first and the energy origin at $2m_{B^*}$ (CONVENTIONS.md "2++ channel basis and projectors", "Energy origin and on-shell momentum"). The bare $\chi_{b2}$ states couple only to $^5S_2$, with the $1^{++}$ coupling $g=57$ MeV (CONVENTIONS.md "2++ bare–continuum vertex"), and $C$ acts only in $^5S_2$ with its $1^{++}$ value. The $2^{++}$ OME follows from the potentials of [@Zhang:2026iyr] v1, Eqs. (72)–(77), projected with the projectors of [@Baru:2019xnh] v2, App. B, rewritten in this project's $C$-parity convention. That includes the $B\bar B\leftrightarrow B^*\bar B^*$ transitions absent in $1^{++}$.

The parameters follow decisions/0004-quark-model-fixed.md. The quark model ($m_b$, $\sigma$, $\gamma$, $V_0$), $g$, $C$, $N$, and $\Lambda$ all come from the $1^{++}$ fit at each cutoff, and nothing is fitted in $2^{++}$. Which bare $\chi_{b2}$ masses enter is decided after claim 1: the $1^{++}$ bare masses, or those masses shifted by the spin-dependent terms of [@Zhang:2026iyr] v1, Eq. (B4). The work for claims 3–5 waits for that decision. The cutoff runs at $\Lambda=3,5$ GeV use the $1^{++}$ refits of [@Zhang:2026iyr] v1, Table VI; the shallow-$X_b$ fit first needs $1^{++}$ refits at those cutoffs.

The scattering equation is solved on the real axis first, with the $B\bar B(^1D_2)$ and $B\bar B^*(^3D_2)$ channels open between their thresholds and $2m_{B^*}$, and its unitarity is checked there. Then it is continued to complex energies. The holomorphic equation that reduces to the real-axis one is still to be derived (claim 2). The $X_{b2}$ is reported on the adjacent sheet (CONVENTIONS.md "Pole position and Riemann sheets"). A bound state is classified by $\mathcal P_{\bar bb}$; a resonance by whether its pole ends on a bare level as $g\to0$ (GLOSSARY.md "Compact-dominated state", "Molecule-dominated state"). The spread over $\Lambda=3$–$5$ GeV is the LO uncertainty (decisions/0002-2pp-renormalisation.md).

## Claims

1. We derive the partial-wave-projected $2^{++}$ OME potential $V^{\rm(OME)}_{\alpha'\alpha}(p',p;E)$: one-$\pi$ and one-$\eta$ exchange with mass splitting, recoil, and energy dependence, in the six-channel basis, including the $B\bar B\leftrightarrow B^*\bar B^*$ entries.
   Evidence: a worked derivation. It first reproduces the $1^{++}$ expressions of [@Zhang:2026iyr] v1, Eqs. (D2)–(D10), from its Eqs. (72)–(77), (80)–(81), (D1), then derives the $2^{++}$ ones by the same steps. Four checks:
   - a brute-force numerical angular integration of Eq. (80) agrees with the analytic expressions at random $(p,p',E)$;
   - time-reversal symmetry, $V_{\alpha'\alpha}(p',p;E)=V_{\alpha\alpha'}(p,p';E)$;
   - in the strict HQSS limit, the potential rotated to fixed light-cloud angular momentum $J_\ell$ is block-diagonal;
   - its $J_\ell=1$ block equals the $1^{++}$ $J_\ell=1$ block.

2. We construct the analytic continuation of the Lippmann–Schwinger equation to complex $E$: a holomorphic equation that reduces to the real-axis equation and gives $T$ on the adjacent sheet.
   Evidence:
   - on the real axis it reproduces the real-axis solution to numerical precision;
   - that real-axis solution satisfies unitarity, $\operatorname{Im}(T^{-1})_{\alpha'\alpha}=\rho_\alpha\delta_{\alpha'\alpha}$ over the open channels (CONVENTIONS.md "Multichannel S matrix and unitarity");
   - further physics checks are to be agreed before this claim's derivation starts.

3. We show where the $\chi_{b2}(1P)$-, $\chi_{b2}(2P)$-, and $\chi_{b2}(3P)$-dominated states lie in both fits, with the quark model fixed in $1^{++}$, and how the first two compare with $\chi_{b2}(9912)$ and $\chi_{b2}(10269)$.
   Evidence:
   - the computation;
   - the $2^{++}$-capable code run in $1^{++}$ reproduces [@Zhang:2026iyr] v1, Table V: masses within 1 MeV, probabilities within 1%;
   - as $g\to0$ the compact-dominated poles move onto the bare $2^{++}$ energies;
   - in the strict HQSS limit the $2^{++}$ compact-dominated poles coincide with the $1^{++}$ ones;
   - the $\Lambda=3$–$5$ GeV spread;
   - $N=4$–$7$, $\varepsilon=5$–$50$ GeV, momentum-grid and Cornell-grid convergence.
   Falsifier: open. It is decided together with the bare $\chi_{b2}$ masses after claim 1 (decisions/0004).

4. We locate the $X_{b2}$ pole in the baseline and shallow-$X_b$ fits: $M$ and $\Gamma$ on the adjacent sheet, the binding energy relative to $2m_{B^*}$, and the composition. The composition is $\mathcal P_{\bar bb}$ if the state is bound, or the $g\to0$ trajectory if it is a resonance. The $\Lambda=3$–$5$ GeV spread is the LO uncertainty. Alternatively we show that no molecule-dominated $2^{++}$ pole exists at LO in a fit.
   Evidence:
   - the computation, built on claims 1 and 2;
   - in the strict HQSS limit the $X_{b2}$ pole coincides with the $X_b$ pole;
   - unitarity of the real-axis amplitude;
   - the cutoff spread with the escalation rule of decisions/0002-2pp-renormalisation.md;
   - the $g\to0$ trajectory;
   - $N$, $\varepsilon$, and grid convergence;
   - spurious poles handled by GLOSSARY.md "Spurious pole".
   Falsifiers: the pole changes nature under the cutoff variation (escalate); no molecule-dominated pole (the result is "no $X_{b2}$ at LO" in that fit).

5. We state which predicted $2^{++}$ state, if any, is compatible with the CMS peak $\chi_{b2}(10524)$, and compare the $X_{b2}$ with published predictions.
   Evidence:
   - the outputs of claims 3 and 4 against [@CMS:2018vgf] v2: $10524.02\pm0.57\pm0.18$ MeV plus 0.5 MeV from the $\Upsilon(3S)$ mass, $J$ assigned by mass ordering;
   - published $X_{b2}$ predictions found by a lit-check, compared at discussion level with nothing gated on them.

## Method decisions

- **LO BOχEFT unchanged from $1^{++}$**: full OME, $N=4$ bare states, one contact term, sharp cutoff, isospin limit (GLOSSARY.md "LO BOχEFT", "Full OME", "Sharp cutoff", "Tower truncation", "Isospin limit"). The $2^{++}$ result is a prediction of the same LO theory, so nothing in it is retuned.
- **Parameters and inputs**: decisions/0004-quark-model-fixed.md, which supersedes decisions/0001. It fixes the quark model, $g$, $C$, $N$, and $\Lambda$ from $1^{++}$. $\chi_{b2}(10524)$ is neither input nor check. Hadron masses are the code values; the $1^{++}$ regression keeps $\mu_{\rm PV}=2.650950$ GeV and the $2^{++}$ reduced masses are derived from the code masses.
- **Renormalisation**: decisions/0002-2pp-renormalisation.md. $C$ alone, no $S$–$D$ counterterm at LO (unlike [@Baru:2019xnh] v2, Sec. IV B). The cutoff spread is the LO uncertainty, with an escalation rule, plus the spurious-pole rule.
- **Bare–continuum coupling only in $^5S_2$**: the $D$-wave entries of [@Bruschini:2023zkb] v3, Table 2 are dropped at LO, as $1^{++}$ dropped its $(1/\sqrt6,1/\sqrt2)$ (CONVENTIONS.md "2++ bare–continuum vertex").
- **Energy origin $2m_{B^*}$ in $2^{++}$** and binding energy relative to it, with $\Gamma$ quoted alongside when lower channels are open (CONVENTIONS.md "Energy origin and on-shell momentum"; GLOSSARY.md "Binding energy").
- **Pole conventions**: $M-i\Gamma/2$ on the sheet reached from the physical axis between the bracketing thresholds (CONVENTIONS.md "Pole position and Riemann sheets").
- **Code**: the $2^{++}$ channels, projections, and later the continuation extend the BOχEFT model of the HadronDynamics.jl submodule on a branch, upstreamed by pull request.

## Validation strategy

| Claim | Seam | Independent routes: what each catches / misses |
|---|---|---|
| 1 | projected $V^{\rm(OME)}_{\alpha'\alpha}(p',p;E)$ | reproduce $1^{++}$ Eqs. (D2)–(D10): errors in the projection procedure / $2^{++}$-only pieces. Brute-force angular integration: projection algebra / errors in the 3D potentials or in projectors shared by both routes. Time-reversal symmetry: $D_3\leftrightarrow D_4$ swaps and transposition errors / symmetric errors. Strict HQSS limit: relative signs and factors between channels, including $B\bar B\leftrightarrow B^*\bar B^*$, and projector-sign mixing / anything that vanishes at $m_B=m_{B^*}$ |
| 2 | $T(E)$ off the real axis | reduction on the real axis: a continuation that changes the physical-sheet solution / off-axis errors. Unitarity of the real-axis $T$: $i\epsilon$ and open-channel errors / everything off the axis. Further routes: to be agreed |
| 3 | compact-dominated pole masses | $1^{++}$ regression: shared machinery / $2^{++}$-only pieces. $g\to0$ limit: the shift of the energy origin and of the bare energies / coupling errors. Strict HQSS limit: $2^{++}$-specific coupling errors / HQSS-breaking pieces. Convergence ($\Lambda$, $N$, $\varepsilon$, grids): numerical error |
| 4 | the $X_{b2}$ pole | strict HQSS limit ($X_{b2}=X_b$): $2^{++}$-specific errors in OME, vertex, and origin / HQSS-breaking pieces. Unitarity: open-channel treatment. Cutoff spread: renormalisation failure (decisions/0002). $g\to0$ trajectory: the classification. Convergence: numerical error |
| 5 | none of its own | built on claims 3 and 4; compared with [@CMS:2018vgf] v2 and lit-checked predictions, discussion only |

Limits used: the strict HQSS limit (GLOSSARY.md "Strict HQSS limit"), the $g\to0$ limit, and the real axis. Literature values: [@Zhang:2026iyr] v1, App. D and Table V (our own $1^{++}$ results); [@CMS:2018vgf] v2.

## Out of scope

As decisions/0003-section-I-scope.md:
- the $0^{++}$ members of the multiplet;
- the isovector $W_{bJ}$;
- production and radiative decays of the $X_{b2}$;
- isospin breaking;
- $1/m_b$ corrections, except any spin-dependent shifts the bare-$\chi_{b2}$ decision adopts (decisions/0004);
- the $S$–$D$ counterterm, unless decisions/0002 escalates;
- bare-state couplings to $D$-wave channels.

The charm sector (followup.tex §II) and the CMS line shapes (§III) are deferred to their own grillings.

## Notes

- **Open, not done**: the method of claim 2 and its further acceptance checks; the user asked that it not be labelled settled. Candidates offered in the grilling, none chosen yet:
  - agreement of sub-threshold poles with real-axis bracketing;
  - an exactly solvable separable coupled-channel model;
  - a narrow-resonance cross-check against a real-axis speed plot;
  - independence from any auxiliary contour parameter.
- **Risk**: if HQSS held, the $X_{b2}$ would sit about 91 MeV below $2m_{B^*}$ in the baseline fit, near the $B\bar B$ threshold at 10.559 GeV, and about 1 MeV below in the shallow-$X_b$ fit, above $B\bar B^*$ at 10.604 GeV [INFERENCE]. Then the headline numbers of claim 4 depend on claim 2.
- **Risk**: the lower $D$-wave channels remove the argument [@Zhang:2026iyr] v1, Sec. III B used against an $S$–$D$ counterterm; decisions/0002 states what happens if the pole is unstable.
- **Open decision, after claim 1** (decisions/0004): the bare $\chi_{b2}$ masses, the role of $\chi_{b2}(9912)$ and $\chi_{b2}(10269)$, and the scope of the spin-dependent computation. It gates claims 3–5. The options laid out on 2026-10-28:
  - the $1^{++}$ bare masses plus $\Delta M_{\rm SD}[\chi_{b2}(nP)]-\Delta M_{\rm SD}[\chi_{b1}(nP)]$, consistent with $V_0$ absorbing $\Delta M_{\rm SD}[\chi_{b1}]$;
  - the $1^{++}$ bare masses unchanged, with the spin-dependent spectrum computed alongside for discussion;
  - the $1^{++}$ bare masses plus $\Delta M_{\rm SD}[\chi_{b2}(nP)]$, which counts $\Delta M_{\rm SD}[\chi_{b1}]$ twice.
- **Slicing** (2026-10-28): slices 01–05 cover the $1^{++}$ groundwork and claims 1–2. Slices for claims 3–5 are written after the bare-$\chi_{b2}$ decision. They start from the breakdown the user approved before that decision was deferred:
  - baseline fit, $2^{++}$ spectrum below the $B\bar B$ threshold; checks: strict HQSS limit, $g\to0$;
  - baseline fit, real-axis $2^{++}$ amplitude up to the $B\bar B\pi$ threshold; checks: unitarity, $D$-wave threshold behaviour $T_{\alpha'\alpha}\propto k_{\alpha'}^{L_{\alpha'}}k_\alpha^{L_\alpha}$;
  - baseline fit, poles above the $B\bar B$ threshold; checks: slice 05's checks rerun in $2^{++}$, and the pole followed from the strict HQSS limit to physical masses;
  - shallow-$X_b$ fit, $2^{++}$ spectrum and $X_{b2}$;
  - one uncertainty band per fit: $\Lambda=3$–$5$ GeV, $N$, $\varepsilon$, grids, with the decisions/0002 escalation rule;
  - $\chi_{b2}(10524)$ and published $X_{b2}$ predictions.
- **Learning goal**: the user wants to learn how the projected coefficients follow from the paper's notation and how they are implemented in code. The derivation for claim 1 is written as a worked note, $1^{++}$ first and then $2^{++}$, with a walkthrough of the implementation.
- **followup.tex Eq. (5)**: its structure holds. Both time orderings of $B\bar B\to B^*\bar B^*$ share the intermediate energy $\omega_B(p)+\omega_{B^*}(p')$, hence $2D_3$, and the reverse gives $2D_4$. Its sign is fixed by claim 1; "B^*\bar{B}^8" is a typo.
- **Sources**: `learning/ome_2pp` holds the user's study notes on the $2^{++}$ OME. Per AGENTS.md they may guide the derivation but are never cited or counted as checks.
- **Bridges to write when first used**:
  - [@Baru:2019xnh] v2: projector signs; its $\mathcal CM=\bar M$ convention and '+' $C$-even combination; its normalisation of $g_b$ and $f_\pi$ in Eq. (59).
  - [@Bruschini:2023zkb] v3: the Table 2 signs; its $^5D_1$ sign is opposite to ours.
  - [@Zhang:2026iyr] v1: the renames $\omega_{B^{(*)}}(p)$ and $\nu_\beta$; $\boldsymbol q=\boldsymbol p-\boldsymbol p'$ in Sec. III B against $\boldsymbol q=\boldsymbol p'-\boldsymbol p$ in App. C, which is immaterial because the OME is bilinear in $\boldsymbol q$.
- **Facts already gathered for the deferred §II**:
  - [@Baru:2016iwj] v2, Sec. 3.3: OPE moves the $X_2$ tens of MeV below $D^*\bar D^*$, width $50\pm10$ MeV, strongly cutoff-dependent binding, isospin limit with $E_X=4.2$ MeV.
  - [@Ji:2025hjw] v4: $X(3872)$ 160 keV below the neutral threshold 3871.69 MeV.
  - [@LHCb:2024vfz] v3: $\chi_{c1}(4010)$ with $M=4012.5$ MeV, $\Gamma=62.7$ MeV, $1^{++}$.
  - The present code rejects $m_\pi\le m_{V}-m_{P}$, so charm needs the three-body cut.
  - followup.tex's "imaginary part around 60 MeV" for $\chi_{c1}(4010)$ is ambiguous between $\Gamma$ and $-\operatorname{Im}E$.
