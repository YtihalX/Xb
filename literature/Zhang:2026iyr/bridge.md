# Bridge: [@Zhang:2026iyr]

Paper: Y. Zhang, F.-K. Guo, C. Hanhart, A. Nefediev and P. Pütz, \"Born–Oppenheimer chiral effective field theory and its application to X_b\", arXiv:2610.19066v1.
Read from: literature/Zhang:2026iyr/src/Xb.tex (pinned v1 LaTeX source).
Canonical side: CONVENTIONS.md and GLOSSARY.md.

## Conventions

| Convention | Paper (where) | Canonical | Relation |
|---|---|---|---|
| Units | Tables I, V, VI | CONVENTIONS "Units" | Identical natural units; MeV = 0.001 GeV; printed percentages = 100 times probability. |
| Threshold and energy | Sec. IV C; Table V | CONVENTIONS "Energy origin and on-shell momentum"; GLOSSARY "Binding energy" | Identical signs: M = m_B + m_Bstar + E, E_B = -E > 0 below the B Bstar threshold. |
| Radial loop norm | Eqs. (104)–(106) | CONVENTIONS "Loop measure and regulator", "Partial-wave states" | Identical measure q² dq/(2π²) up to the sharp cutoff; no extra factor in probabilities. |
| Bare vertex | Eqs. (18), (52)–(54), (61) | CONVENTIONS "Bare–continuum vertex" | Identical positive choice g = (2/√3)√2 g_l; only g² enters the potential. Form factors f_n = ψ_n/√(4π), with no additional factor in the separable kernel. |
| Cornell potential | Eq. (12), Table I | CONVENTIONS "Quark–antiquark Hamiltonian" | Identical V(r) = V_0 + σr + γ/r, γ = -4α_s/3 < 0. |
| Momentum transfer | Sec. III B, Eqs. (69)–(77); App. C, Eq. (C1) | CONVENTIONS "Axial coupling and OME normalisation", "Metric signature" | Sec. III B uses $\boldsymbol q=\boldsymbol p-\boldsymbol p'$; App. C reverses it. Every OME numerator is bilinear in $\boldsymbol q$ and each denominator depends on $q^2$, so reversal has identical positive unit factor in the potential. |
| Projectors and trace | Eqs. (80)–(81), (D1) | CONVENTIONS "Partial-wave projectors", "Angular-momentum phases" | Identical $1/(2J+1)$ spin average and two $d\Omega/(4\pi)$ measures. The $^5D_1$ projector includes the printed negative imaginary coefficient $-\sqrt3\,i/2$; no phase is silently changed. |

## Symbols and equations

| Paper | Canonical | Relation | Checked by |
|---|---|---|---|
| $\mathcal P_{\bar bb}$, Eqs. (104)–(105) | GLOSSARY "Compact probability" | Identical; `bound_state.P_compact`; sum of bare-state squared amplitudes. | `MomentumDynamics.jl` compact norm divided by total norm; `BOchiEFT.jl` bound-state adapter. |
| $\mathcal P_S$, Eq. (106), Table V caption | GLOSSARY "Compact probability" (two-body weights) | Identical, positive unit factor: `P_PV_S`, channel 1. | Source text following Eq. (106): B Bstar(³S₁); package channel order PV_3S1, PV_3D1, VV_5D1. |
| $\mathcal P_D$, Eq. (106), Table V caption | GLOSSARY "Compact probability" (two-body weights) | Identical, positive sum `P_PV_D + P_VV_D`; not either channel alone. | Table V caption and text following Eq. (106). |
| $\mathcal P_{\text{3-body}}$, Eq. (104), App. F | GLOSSARY "Compact probability" (three-body weight) | Identical: `P_OME_derivative`; negative expectation of ∂_E V_OME, not the unweighted derivative. | Source `eq:P-3body` and `MomentumDynamics.jl`: both use -⟨Ψ∣∂_E V_OME∣Ψ⟩ with the dressed wave function. |
| $X_S$, Eq. (107) | GLOSSARY "S-wave compositeness" | Identical: `P_PV_S + derivative_blocks[1,1]`; not the two-body S-wave probability alone. | Eq. (107), `BOchiEFT.bound_state`. |
| $g$, $g_l$, Eq. (18) | GLOSSARY "Bare–continuum coupling" | g = (2/√3)√2 g_l; g_l = 35 MeV gives g ≈ 57 MeV. The red run drops 2/√3, using √2 g_l. | Eq. (18) against static matrix element and recoupling discussion; package `compact_coupling`. |
| $g_b$, Eq. (66) | CONVENTIONS "Axial coupling and OME normalisation" | Identical g_b = 0.56; distinct from g. | Source axial input, Eq. (66), and OME vertices, Eqs. (69)–(70); canonical entry. |
| $m_b, C, V_0$, Table VI, Λ = 4 GeV | GLOSSARY "Baseline fit" | Identical parameters; printed 4.534 GeV, -16.27 GeV⁻², 371 MeV are rounded. Full precision is in `code/HadronDynamics.jl/data/bochiEFT/central.toml`. | Table VI central row against baseline input block. |
| Masses and probabilities, Table V dagger rows | GLOSSARY "Baseline fit", "Compact probability"; CONVENTIONS "State labels" | Identical observable labels and positive probabilities; mass tolerance 0.001 GeV, probability tolerance 0.01 absolute. | `checks/baseline_fit.jl`, fixed published expectations. |
| $E_{B^{(*)}}(p)$, Eq. (77) | CONVENTIONS "Binding energy and meson energies": $\omega_{B^{(*)}}(p)$ | Positive unit rename only: $\omega_H(p)=m_H+p^2/(2m_H)$. Not the binding energy $E_B$. | Eq. (77) expansion of the intermediate energies. |
| $\mu_\beta$, Eqs. (76)–(77) | CONVENTIONS "Reduced masses and TOPT energy offsets": $\nu_\beta$ | Positive unit rename only: $D_\beta=[2\omega(\omega+\nu_\beta)]^{-1}$; not a reduced mass. $\nu_{1,2}=\mp\Delta m+(p^2+p'^2)/(2m_{B^{(*)}})-E$, $\nu_3=p^2/(2m_B)+p'^2/(2m_{B^*})-E$, $\nu_4=\nu_3(p,p')$. | Eq. (77) with $M=m_B+m_{B^*}+E$; `exchange.jl:1–14`. |
| $P({}^5D_1)$ and mixed $V_{13},V_{23}$, Eqs. (D1),(D4),(D7) | CONVENTIONS "Partial-wave projectors" | Package now uses the identical (D1) phase. Relative to its original frozen extraction, $V_{\rm D1}=U V_{\rm frozen}U$, $U=\operatorname{diag}(1,1,-1)$: precisely entries 13,23,31,32 change sign; diagonal blocks, poles and probabilities do not. The user directed alignment to (D1) on 2026-10-29. | Raw double-angle Eq. (80) in `checks/projection_1pp.py`; all published coefficients in `notes/03-projection-method-1pp.md`; package frozen comparisons explicitly transform both sides of each continuum matrix. |
| $\Psi^{\rm(spur)}_\alpha$, App. G, Eq. (G1) | GLOSSARY "Spurious-pole projection"; CONVENTIONS "Loop measure and regulator" | Positive separable addition $\varepsilon\Psi_{\alpha'}(p')\Psi_\alpha(p)$, no extra $2\pi$ factor. Renormalise the two-meson component alone: $\sum_\alpha\int_0^\Lambda q^2dq/(2\pi^2)\,\Psi_\alpha^2=1$, not the compact-plus-derivative norm of a physical bound state. | App. G text preceding Eq. (G1), Eq. (106); `checks/spurious_projection.jl`. |
| $C,V_0$, Table VIII projected row | GLOSSARY "Shallow-$X_b$ fit" | Identical units and signs: $C=2.66$ GeV$^{-2}$, $V_0=0.362$ GeV are rounded; $C$ imposes $E_B[X_b]=0.001$ GeV and $V_0$ minimises Eq. (94). | Table VIII caption and projected row; `checks/shallow_fit.jl`. |
| $\Delta M$, Eq. (94), Table VIII | GLOSSARY "Fit deviation"; CONVENTIONS "State labels" | Identical RMS with factor $1/3$: in the shallow fit compare the three compact-dominated states with the measured $\chi_{b1}(9893)$, $\chi_{b1}(10255)$, $\chi_{b1}(10513)$ masses. The shallow $X_b$ is constrained separately, not a fourth fitted mass; baseline instead matches $X_b$ to 10513 MeV. | Eq. (94), Sec. IV F and Table VIII caption; `checks/shallow_fit.jl`. |

## Flags

- Table V percentages are rounded to integers; zero permits a contribution below 0.5%. The check does not interpret zero as an exactly absent channel.
- The 10.544 GeV χ_b1(3P)-dominated state is predicted, not one of the three fitted masses (Sec. IV D). The 10.513 GeV fitted state is X_b.
- This bridge covers only the quantities used by slice 01, not every convention of the paper.
- Slice 03 extends the original slice-01 coverage with the OME conventions above. Resolved package phase mismatch: the original mixed PV–VV entries had the negative of (D4),(D7) and their transposes; direct Eq. (80) integration with printed (D1) agreed with the source. On the user's 2026-10-29 instruction, the package was aligned to (D1), not the check rephased. The canonical convention did not change; the frozen reference stays untouched and is converted only in comparisons.
