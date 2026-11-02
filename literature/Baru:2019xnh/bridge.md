# Bridge: [@Baru:2019xnh]

Paper: V. Baru, E. Epelbaum, A. A. Filin, C. Hanhart, A. V. Nefediev and Q. Wang, “Spin partners W_bJ from the line shapes of the Z_b(10610) and Z_b(10650)”, arXiv:1901.10319v2.
Read from: `literature/Baru:2019xnh/src/partners.tex`; the adjacent `.arxiv-version` pins v2.
Canonical side: `CONVENTIONS.md` and `GLOSSARY.md`.

## Conventions

| Convention | Paper (where) | Canonical | Relation |
|---|---|---|---|
| Units | Sec. II, pion decay constant following source `pieta` | CONVENTIONS “Units” | Identical natural units; 92.4 MeV = 0.0924 GeV. The canonical input is instead 0.0922 GeV. |
| Charge conjugation | Sec. II A, source `Eq:Cpar`, `Cpardef` (`src/partners.tex:292–304`) | CONVENTIONS “C-parity phase” | Paper uses C M = bar M for both P and V and a plus C-even PV combination; canonical uses C V = −bar V and a minus combination. A field dictionary with P_p=P_c, V_p=V_c, bar P_p=bar P_c, bar V_p=−bar V_c maps the definitions. This is not a PV-only sign change of a projected potential; see below. |
| Channel order | Sec. II A, source `basisvec` (`src/partners.tex:288–290`) | CONVENTIONS “2++ channel basis and projectors” | Canonical indices (1,2,3,4,5,6) correspond to paper indices (3,4,5,6,2,1), with positive unit factors in the Cartesian projector formulas. |
| Projector normalisation | App. B, final equation (`src/partners.tex:1608–1610`); source `VPWA` (`665–668`) | CONVENTIONS “Partial-wave projectors” | Identical 1/(2J+1) trace and two normalised solid angles; J=2 gives 1/5. No extra 4π belongs in the canonical projected potential. |
| Projector signs | App. B (`src/partners.tex:1573–1605`) | CONVENTIONS “2++ channel basis and projectors”; “Angular-momentum phases” | Retain every printed Cartesian coefficient and its i. In canonical order the coefficient signs are (+,−,−,+,−i,−), explicitly given below. Relative to standard CS LS spin-angular functions, the channel phases are (+,+,+,+,+,−), not a universal D-wave minus. |
| Axial vertices | Sec. II D, Eqs. (35)–(36), from Lagrangian (34); source `vBstarBpi`, `vBstarBstarpi` (`src/partners.tex:581–588`) | CONVENTIONS “Axial coupling and OME normalisation” | Identical positive g_b/(2 f_pi) PV vertex, negative g_b/(sqrt(2) f_pi) VV vertex and A=i(epsilon×epsilon′*)/sqrt(2), with f_pi replaced by canonical F_pi. No sqrt(2) coupling conversion. |
| Pion and eta fields | Source `Amu`, `pieta` (`src/partners.tex:425–437`) | CONVENTIONS “Axial coupling and OME normalisation” | Identical u=−partial Phi/f_pi and Phi=pi_a tau_a+eta I/sqrt(3). One eta vertex has positive factor 1/sqrt(3); two give +1/3. |
| Isospin | Sec. II D (`src/partners.tex:605–617`) | GLOSSARY “Isospin limit”; CONVENTIONS “Axial coupling and OME normalisation” | Paper evaluates the isotriplet factor −1; canonical isoscalar pion factor is +3. Relative factor is −3 only after putting the same field/state and potential normalisations on both sides. Canonical per-meson Cartesian kernels below have isospin removed. |
| Momentum and TOPT | Source `V13D1NR1`–`V22D2NR1` (`src/partners.tex:639–658`) | CONVENTIONS “Energy origin and on-shell momentum”; “Reduced masses and TOPT energy offsets” | Identical q=p−p′ and absolute total M. Paper D is a denominator, whereas canonical D_beta is its inverse: D_beta=1/D_paper, with no minus. In 2++ use M=2m_Bstar+E, not the 1++ origin. |

## Symbols and equations

| Paper | Canonical | Relation | Checked by |
|---|---|---|---|
| g_b≈0.57, Eq. (37), source `gb`; f_pi=92.4 MeV after Eq. (21) | CONVENTIONS “Axial coupling and OME normalisation”: g_b=0.56, F_pi=92.2 MeV | Same coupling definition and signs, different numerical inputs. Replace (g_b,f_pi) by (0.56,0.0922 GeV), rather than importing the paper's numbers. A quadratic vertex prefactor consequently changes by [(0.56/0.0922)/(0.57/0.0924)]². | Baru:2019xnh v2, Eqs. (34)–(37). Compare paper vertices (35)–(36), `src/partners.tex:583–587`, with canonical Eqs. (69)–(70), `literature/Zhang:2026iyr/src/Xb.tex:1003–1010`. |
| OPE prefactor 2g_b²/(4π f_pi)², source `V13`–`V33` | CONVENTIONS “Axial coupling and OME normalisation”: Cartesian vertex product g_b²/(4F_pi²) | At identical g_b and f_pi=F_pi, the canonical vertex product is +2π² times this displayed prefactor. This is a prefactor comparison only, not a universal conversion of all paper matrix entries: isospin, C phases, the VV vertex's additional factor 2, and explicit C-even sums remain to be accounted for. | Source `src/partners.tex:628–635` against canonical Eqs. (72)–(75), `literature/Zhang:2026iyr/src/Xb.tex:1020–1032`. The check constructs canonical vertices instead of transplanting these paper potentials. |
| v_ij and v_ijkl, App. B | CONVENTIONS “2++ channel basis and projectors” | Positive unit identity: v_ij=n_i n_j−delta_ij/3; rank-four v is the printed traceless tensor below. | Literal tensor construction in `checks/_projection_2pp.py`, independent of analytic moments. |
| A_i and S_ij, App. B | CONVENTIONS “2++ channel basis and projectors” | Positive unit identity: A_i=i epsilon_ijk epsilon_1j epsilon_2k/sqrt(2); S_ij=epsilon_1i epsilon_2j+epsilon_1j epsilon_2i−2 delta_ij(epsilon_1·epsilon_2)/3. | `src/partners.tex:1602–1605`; incoming spin kets enter projectors and outgoing ones are conjugated by Eq. (80). |
| Paper projector P(alpha;n), App. B | CONVENTIONS “Partial-wave projectors” | Contract the total-J indices ij with five real orthonormal symmetric-traceless tensors T^M_ij. Sum over M gives the spin-2 trace, with positive unit factor; do not multiply by sqrt(5). | Projector Gram assertions in `checks/projection_2pp.py`; recorded result in `notes/04-ome-2pp.md`, Sec. 8. |

### Exact 2++ projectors

Use S_ij and v_ij above and

$$
\begin{aligned}
v_{ijkl}={}&n_i n_j n_k n_l
-\frac17(n_i n_j\delta_{kl}+n_i n_k\delta_{jl}+n_i n_l\delta_{jk}
+n_j n_k\delta_{il}+n_j n_l\delta_{ik}+n_k n_l\delta_{ij})\\
&+\frac1{35}(\delta_{ij}\delta_{kl}+\delta_{ik}\delta_{jl}+\delta_{il}\delta_{jk}).
\end{aligned}
$$

In the canonical order, with no additional channel rephasing,

$$
\begin{aligned}
P^{(1)}_{ij}&=\tfrac12 S_{ij},\\
P^{(2)}_{ij}&=-\sqrt{\tfrac52}(\boldsymbol\epsilon_1\cdot\boldsymbol\epsilon_2)v_{ij},\\
P^{(3)}_{ij}&=-\sqrt{\tfrac{45}{56}}\left(S_{ik}v_{kj}+S_{jk}v_{ki}-\tfrac23\delta_{ij}S_{kl}v_{kl}\right),\\
P^{(4)}_{ij}&=+\sqrt{\tfrac{175}{32}}S_{kl}v_{ijkl},\\
P^{(5)}_{ij}&=-\tfrac{i\sqrt5}{2}\epsilon_k
\left(\varepsilon_{ikl}v_{lj}+\varepsilon_{jkl}v_{li}\right),\\
P^{(6)}_{ij}&=-\sqrt{\tfrac{15}{2}}v_{ij}.
\end{aligned}
$$

Source: `src/partners.tex:1573–1588,1592–1605`. Here epsilon_k in P^(5) is the spin polarisation of the already C-even PV channel, which is the **canonical minus** combination. The formula is not a licence to use the paper's plus combination inside the canonical vertices.

For the CS comparison only, define the standard spin-angular function by sqrt(4π) sum of <L m_L S m_S|2 M> Y_Lm_L chi_Sm_S. At n=z, using epsilon_+=−(x+i y)/sqrt(2) and T^0=diag(−1,−1,2)/sqrt(6), the first four tensors at M=0 have coefficients 1, −sqrt(5/3)delta_ab, −sqrt(10/7)T^0_ab, and +sqrt(18/7)T^0_ab. The PV tensor at M=1 is −sqrt(5/2)epsilon_+, matching sqrt(5)<2 0,1 1|2 1>. The PP tensor at M=0 is −sqrt(5), opposite the standard +sqrt(5). This establishes the geometric phases (+,+,+,+,+,−) without obtaining an HQSS rotation from projectors. The heavy/light recoupling check instead constructs its rotation independently from 9j/6j coefficients.

### C-phase dictionary, not a second projector rephasing

Under the field dictionary in the conventions table, the paper's C-even state becomes

$$
\frac{|P\bar V\rangle_p+|V\bar P\rangle_p}{\sqrt2}
=\frac{-|P\bar V\rangle_c+|V\bar P\rangle_c}{\sqrt2}
=-|PV;C=+\rangle_c.
$$

The VV ket likewise acquires −1 and the PP ket +1. Thus reordered **field kets** have signs (−,−,−,−,−,+). These are distinct from the CS orbital/projector phases above. A complete transformation of a paper amplitude transforms its external fields and vertices together. The numerical route already starts with canonical vertices and the agreed Cartesian tensors, so multiplying its fifth channel alone, or multiplying it by these six field-ket signs again, would double count a conversion.

### Cartesian OME blocks used by the independent route

Let C_phi=g_b²/(4F_pi²), R_ac=epsilon_cak q_k and D_XY=[2omega(omega+nu_XY)]^−1, where nu_XY=m_X+p′²/(2m_X)+m_Y+p²/(2m_Y)−M. These symbols instantiate CONVENTIONS “Axial coupling and OME normalisation” and “Reduced masses and TOPT energy offsets”; they do not introduce a new energy convention. The isospin-free spin numerators are

$$
\begin{aligned}
N_{PV,PV;ac}&=-q_aq_c,&\quad D\text{ sum}&=D_{PP}+D_{VV},\\
N_{VV,PV;ab,c}&=\frac{i}{\sqrt2}(R_{ac}q_b+R_{bc}q_a),&D\text{ sum}&=D_{VV}+D_{VP},\\
N_{PV,VV}&=N_{VV,PV}^{\dagger},&D\text{ sum}&=D_{VV}+D_{PV},\\
N_{VV,VV;ab,cd}&=R_{ac}R_{bd},&D\text{ sum}&=2D_{VV},\\
N_{VV,PP;ab}&=+q_aq_b,&D\text{ sum}&=2D_{VP},\\
N_{PP,VV;cd}&=+q_cq_d,&D\text{ sum}&=2D_{PV}.
\end{aligned}
$$

The full block is C_phi N times its D sum; PP–PP and PP–PV vanish because no PPphi vertex exists. The first four blocks are canonical Eqs. (72)–(75). The last two follow directly from the two spin-changing terms of canonical Eq. (68), `literature/Zhang:2026iyr/src/Xb.tex:996–1001`: the opposite anti-meson vertex sign and the opposite momentum transfer cancel, giving **+q_a q_b**, not a sign inferred from HQSS. Both time orderings of incoming PP and outgoing VV have one incoming P at p and one outgoing V at p′, hence twice D_VP; the reverse has twice D_PV. There is no average over these two different momentum assignments inside a single orientation. This agrees with the mixed intermediate energy in paper source `V13D1NR1`, `src/partners.tex:645`.

### Executable seam and frozen expectations

`checks/projection_2pp.py` compares every one of the 21 upper-triangular entries at three seeded off-shell samples for pion and eta separately. It uses `checks/_projection.py` unchanged to integrate both complete solid angles, with no axis fixing and no analytic numerator coefficients. The new `checks/_projection_2pp.py` contains only the pinned Cartesian tensors and species-changing spin blocks.

The input calls `B.channels_2pp()`, `B.OMEInteraction(cfg;channels=...)`, and the unchanged public `B.ome_potential` seam through `julia --project=checks`. To isolate one exchanged species despite the legacy S–S selector, set mpi=meta=m_phi and exchange=:both. Then the public potential is (3+1/3)V(m_phi); multiplying by w_phi/(3+1/3) gives exactly 3V(m_pi) or V(m_eta)/3. No internal package moment function is called.

Frozen before analytic derivation: RNG seed 80402; p,p′ in [0.035,0.12] GeV; M=2m_Bstar+offset with offset in [−0.09,−0.015] GeV; double-sphere orders 12 and 18; both analytic residual and independent quadrature change must be at most 5×10^−9 max(1,|V|) in GeV^−2. Gram normalisation/orthogonality tolerance is 10^−12. Samples must be below BBpi threshold. The recorded comparison has 141 passing assertions, maximum potential residual 2.9×10^−12 GeV^−2 and maximum order-12/18 change 2.7×10^−15 GeV^−2 (`notes/04-ome-2pp.md`, Sec. 8).

## Flags

- Use the complete one-particle field dictionary above when converting a paper amplitude; the independent route starts directly in the canonical fields.
- The paper's isovector OPE expressions, numerical g_b/f_pi inputs, and displayed (4π f_pi)^−2 prefactors must not be copied verbatim as canonical isoscalar kernels.
