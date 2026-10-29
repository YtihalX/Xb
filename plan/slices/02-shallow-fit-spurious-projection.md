# 02: Shallow-X_b fit reproduced with spurious-pole projection

Claim: We show that the spurious-pole projection of [@Zhang:2026iyr] v1, Eq. (G1), added to the package, reproduces the shallow-$X_b$ fit of Table VIII:
- $C=2.66\ \text{GeV}^{-2}$, tuned so that $E_B[X_b]=1$ MeV below $m_B+m_{B^*}$;
- $V_0=362$ MeV at $m_b=4.534$ GeV, giving $\Delta M=15.0$ MeV;
- the spurious pole moved far above threshold.
Assumptions:
- [GLOSSARY.md](../../GLOSSARY.md): "Shallow-$X_b$ fit", "Spurious-pole projection", "Spurious pole", "Fit deviation", "Binding energy".
- [CONVENTIONS.md](../../CONVENTIONS.md): "Lippmann–Schwinger equation", "Separable s-channel and contact potential", "Energy origin and on-shell momentum".
- [decisions/0004](../../decisions/0004-quark-model-fixed.md).
Checks:
- Shallow-fit parameters and states:
  - Route: [@Zhang:2026iyr] v1, Table VIII and App. G.
  - Expected: $C$ and $V_0$ to the printed digits; masses within 1 MeV; probabilities within 1% absolute.
  - Check: `checks/shallow_fit.jl`; expectations committed red in `dab53b0` before computation. Initial `just check` printed `FAIL shallow-Xb fit: no computed result yet`; baseline remained green.
  - Deliberate red 2026-10-29: doubled the fitted $C$ in the marked input block; `git diff -- checks/shallow_fit.jl` confirmed the mutation. `julia --project=checks checks/shallow_fit.jl` failed the assertion `FAIL C [GeV^-2]: 5.329266139698988 (published 2.66, absolute tolerance 0.005)`. Removed the mutation; the input now calls the saved constrained fit.
- The projection term:
  - Route: the physical poles do not depend on $\varepsilon$ over 5–50 GeV (App. G). Also, projecting out the spurious pole of the baseline fit at $\Lambda=4$ GeV should move the Table V masses by less than 1 MeV, as Sec. IV D states.
  - Expected: both hold.
  - Red: projecting with a perturbed $\Psi^{\rm(spur)}$ makes the physical poles depend on $\varepsilon$.
  - Check: `checks/spurious_projection.jl`; committed red in `dab53b0` before adding the package projection. Initial `just check` printed `FAIL spurious-pole projection: no computed result yet`.
  - Package TDD (projected-model seam, agreed 2026-10-29): `julia --project=code/HadronDynamics.jl code/HadronDynamics.jl/test/bochiEFT.jl` first failed on missing `projected_model`; after the zero-strength path passed, the positive-strength tracer failed on the missing addition. Implementing the normalised rank-one addition made all 10070 package assertions pass (including the two projection testsets).
  - Preregistration correction (user approved 2026-10-29): the original `dab53b0` check required an unjustified $10$ keV epsilon spread. The unperturbed baseline $2P$ spread was $0.103580499$ MeV, so that check failed. The adopted criterion is now $1$ MeV: [@Zhang:2026iyr] v1, App. G (`literature/Zhang:2026iyr/src/Xb.tex:2579`) says “within our adopted precision”, and its masses are printed to $1$ MeV. The tolerance change is committed separately with the approval named; it is not presented as the original preregistration.
  - Deliberate red 2026-10-29: added $10\,\Psi^{(1P)}$ to the baseline spurious two-meson wave function before continuum normalisation (`perturb=true` in the check's input block); `git diff -- checks/spurious_projection.jl` confirmed the change. `julia --project=checks checks/spurious_projection.jl` failed its epsilon-independence assertion: `FAIL chi_b1_1P epsilon independence [GeV]: 0.0014783492653805963`. Restored `perturb=false`. The unperturbed baseline spreads over $\varepsilon=5,10,20,50$ GeV are $(0.172726002,0.103580499,0.050198522,0.067499447)$ MeV for $(1P,2P,3P,X_b)$; the corresponding projection shifts at $10$ GeV have absolute values $(0.773077500,0.255914694,0.081965062,0.114299544)$ MeV. These pass the approved $1$ MeV criteria.
  - At the saved shallow-fit parameters, the same $\varepsilon=5,10,20,50$ GeV scan gives $(0.242229648,0.008180294,0.000071874,0.034238588)$ MeV spreads for $(1P,2P,3P,X_b)$. These are the measured results under the user-approved $1$ MeV criterion, not a replacement claim of exact epsilon independence.
  - Input-block fix 2026-10-29: the loop line `for (name, energies) in results.shallow_energies` had been edited outside the input block; it is restored to the committed text, and the input block maps the computed $\varepsilon$ scans (baseline and shallow) onto the committed field name.
- Shallow spurious pole (added from referee findings, after the computation; not a preregistration):
  - Route: GLOSSARY.md "Spurious pole" (predominantly hadronic member); [@Zhang:2026iyr] v1 Table VIII "Not projected" row; App. G text after Eq. (G2) (unprojected shallow spurious pole at $10.13$ GeV, `Xb.tex:2594`); Eq. (G2) at $\varepsilon=5$ GeV; Eq. (94) ($V_0$ minimises $\Delta M$).
  - Expected: the projected pole is the lower-$\mathcal P_{\bar bb}$ member of the two lowest poles at the fitted parameters ($|\Delta E|<10^{-8}$ GeV), $\kappa>1$ GeV, $\mathcal P_{\bar bb}<5\%$; exactly four poles below threshold after projection for $\varepsilon=5,10,20,50$ GeV; unprojected row $C$ within $0.005$ GeV$^{-2}$ of $2.52$, $\Delta M$ within $0.05$ MeV of $15.9$, spurious mass within $5$ MeV of $10.13$ GeV; $\Delta M(V_0\pm2\,\text{MeV})>\Delta M(V_0)$ with $C$ retuned; at $\varepsilon=5$ GeV, $|\delta M(1P)|$ within $0.05$ MeV of $0.9$, $|\delta M(2P,3P)|<0.33$ MeV, $|\delta\mathcal P_{\bar bb}|<0.2\%$.
  - Check: `checks/shallow_spurious.jl`; committed red in `1d94c20` (`FAIL shallow spurious pole: no computed result yet`), then filled with `ShallowFitExample.referee_results()`.
  - Deliberate red 2026-10-29: replaced `hadronic_energy` in the input block by the adiabatic partner energy $-0.7247012498$ GeV; `git diff --stat` confirmed the change; the run failed `FAIL projected pole equals hadronic member [GeV]: 0.2569281621556636`. Restored.
  - Green values: $\Delta E=-2\times10^{-13}$ GeV, $\mathcal P_{\bar bb}=0.0167$ vs partner $0.984$, $\kappa=1.575$ GeV; four poles at every $\varepsilon$; unprojected $C=2.52379$ GeV$^{-2}$, $\Delta M=15.880$ MeV, spurious $M=10.13029$ GeV; $\Delta M=15.1111,15.1106$ MeV at $V_0\mp2$ MeV vs $14.9937$; $\varepsilon=5$ shifts $(-0.878,-0.323,-0.116)$ MeV, $|\delta\mathcal P_{\bar bb}|\le0.128\%$.
  - Note: the committed header comment of this check cites the $10.13$ GeV statement as "text after Eq. (G1)"; the statement follows Eq. (G2). The comment is outside the input block and left unchanged pending the user.
Output: the shallow-$X_b$ fit row of the $1^{++}$ input table → `paper/sections/framework.tex`
Blocked by: 01
Status: done

## Continuation evidence

`julia --project=checks code/HadronDynamics.jl/examples/bochiEFT/shallow_fit.jl continuation` holds $\Lambda=4$ GeV and $V_0=0.362$ GeV fixed, uses $\Delta C=0.05$ GeV$^{-2}$, enumerates all augmented-eigenvalue crossings in each local energy window, and selects the candidate with largest adjacent overlap in the quadrature-weighted two-meson plus compact amplitudes. The minimum adjacent overlap was $0.999642484$.

| $C$ (GeV$^{-2}$) | $E$ (GeV) | $\mathcal P_{\bar bb}$ |
|---|---|---|
| $-16.2678202043$ | $-1.3747613055$ | $0.00155715046$ |
| $-2.2678202043$ | $-0.7659623849$ | $0.287940857$ |
| $-1.2678202043$ | $-0.7372842290$ | $0.756807872$ |
| $2.66$ | $-0.7243121814$ | $0.984159750$ |

Thus overlap-following continuation reaches the compact-dominated $1P$ state, not the predominantly hadronic pole at $E=-0.4679695662$ GeV ($\mathcal P_{\bar bb}=0.016755061$). The two lowest levels exchange their content at the avoided crossing. The caption of [@Zhang:2026iyr] v1, Fig. 5(a), calls the predominantly hadronic member the spurious pole (`literature/Zhang:2026iyr/src/Xb.tex:1494`), whereas a literal adiabatic pole-continuation label does not select that member on both sides.

The user resolved the label on 2026-10-29: “Follow hadronic member”, now recorded in GLOSSARY.md. The complementary command `julia --project=checks code/HadronDynamics.jl/examples/bochiEFT/shallow_fit.jl hadronic` holds the fitted $V_0=0.36160467856259715$ GeV fixed, isolates both lowest physical poles by full augmented-eigenvalue sign changes in $E\in(-1.6,-0.4)$ GeV at each $C$, orders them by energy, and follows the member with smaller compact probability. Their compact contents exchange at $C\in(-1.8459452043,-1.8420389543)$ GeV$^{-2}$. At $C=2.66$ GeV$^{-2}$ the lower (adiabatic) pole has $E=-0.7247012498$ GeV and $\mathcal P_{\bar bb}=0.984205042$, whereas the hadronic endpoint has $E=-0.4679761839$ GeV and $\mathcal P_{\bar bb}=0.016724828$. The starting pole at $C=-16.2678202043$ has $\mathcal P_{\bar bb}=0.001558893<1\%$. This records the content exchange explicitly rather than mistaking an eigenlevel switch for overlap continuation.

## Computation

The command `julia --project=checks code/HadronDynamics.jl/examples/bochiEFT/shallow_fit.jl fit code/HadronDynamics.jl/data/bochiEFT/shallow.toml` performs a bracketed contact root at $E=-0.001$ GeV inside a constrained one-dimensional minimisation in $V_0$, with the Table-II measured masses $(9.893,10.255,10.513)$ GeV compared with the three compact-dominated states. It wrote $C=2.664633069849494$ GeV$^{-2}$, $V_0=0.36160467856259715$ GeV, $\varepsilon=10$ GeV, with $\Delta M=14.9937330528$ MeV. The full-precision baseline $m_b$ and all other inputs in `central.toml` are unchanged. To reproduce the fit without overwriting the committed input, supply a fresh output path instead.

Grid refinement: `julia --project=checks code/HadronDynamics.jl/examples/bochiEFT/shallow_fit.jl refine` doubles $n_q=24\to48$, the Cornell grid $12000\to24000$, and the transform quadrature $800\to1600$ at fixed saved parameters (no refit). The shifts are:

| State | Mass shift (MeV) | Compact probability shift (percentage points) | $X_S$ shift (percentage points) |
|---|---|---|---|
| $1P$ | $0.000133959$ | $-0.000001706$ | $0.000001760$ |
| $2P$ | $0.000321419$ | $0.000008775$ | $0.000002836$ |
| $3P$ | $0.000730350$ | $0.000945262$ | $-0.000295235$ |
| $X_b$ | $0.002837220$ | $0.009345590$ | $-0.037914447$ |

The rounded-up resolution estimates are $0.003$ MeV for masses, $0.010$ percentage points for compact probabilities, and $0.038$ percentage points for $X_S$; these do not estimate the LO theory uncertainty or a refitted-parameter uncertainty.

## Result

Shallow-$X_b$ fit with the Eq. (G1) projection ($\varepsilon=10$ GeV): $C=2.6646$ GeV$^{-2}$, $V_0=361.60$ MeV, $\Delta M=14.994$ MeV, masses $(9.8835,10.2453,10.5351,10.6033)$ GeV, all matching Table VIII within $1$ MeV and $1\%$ in probabilities; grid doubling moves masses by $<0.003$ MeV, compact probabilities by $<0.010$ and $X_S$ by $<0.038$ percentage points (resolution only, not LO theory uncertainty). Physical poles vary by $\le0.243$ MeV (shallow) and $\le0.173$ MeV (baseline) over $\varepsilon=5$–$50$ GeV; the projected pole is the predominantly hadronic member ($M=10.136$ GeV, $\kappa=1.575$ GeV, $\mathcal P_{\bar bb}=1.7\%$), and after projection only the four physical poles remain below threshold, so the spurious pole is moved out of the bound spectrum. Eq. (G2) is reproduced at $\varepsilon=5$ GeV, and the Table VIII "Not projected" row and $10.13$ GeV spurious mass are reproduced without projection.

- Derivation or computation: `code/HadronDynamics.jl/src/BOchiEFT` (`projected_model`, submodule `6c4e995`), `code/HadronDynamics.jl/examples/bochiEFT/shallow_fit.jl`, `code/HadronDynamics.jl/data/bochiEFT/shallow.toml` (submodule `7cd103c` and the referee commit).
- Checks: `checks/shallow_fit.jl`, `checks/spurious_projection.jl`, `checks/shallow_spurious.jl`, all green; red runs recorded under Checks.
- Paper: `paper/sections/framework.tex`.
- Referee (fixed point `dd33ec7`): Standards 7 — Eq. (G2) comparison (fixed: $\varepsilon=5$ shifts checked and stated), excess digits (rounded to resolution), unchecked hadronic identification (new check), unpinned App. G/two-body norm (pinned Eq. (G1), (G2), (81)), echoed $V_0$ (minimum now checked), weak perturbation red (kept; the perturbation red catches only gross projector errors, as recorded), missing shallow spurious and published-value comparisons (new check); `shallow.toml` header units fixed. Plan 7 — "moved far above threshold" unchecked (pole count now checked), label not gated (fixed), submodule commit `16fcd56` belongs to slice 03 (no action), extra paragraph (kept: it is the slice's paragraph per work-slice step 5), G2 overclaim and "refit" claim (fixed as above). Correctness — all ten re-checks agree; F1, F2 fixed as above.
