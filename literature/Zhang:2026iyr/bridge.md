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

## Flags

- Table V percentages are rounded to integers; zero permits a contribution below 0.5%. The check does not interpret zero as an exactly absent channel.
- The 10.544 GeV χ_b1(3P)-dominated state is predicted, not one of the three fitted masses (Sec. IV D). The 10.513 GeV fitted state is X_b.
- This bridge covers only the quantities used by slice 01, not every convention of the paper.
