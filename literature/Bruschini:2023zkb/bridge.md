# Bridge: [@Bruschini:2023zkb]

Paper: R. Bruschini, "Heavy-quark spin symmetry breaking in the Born-Oppenheimer approximation", arXiv:2303.17533v3.
Read from: `src/HQSS-breaking.tex`; version pinned by `src/.arxiv-version`.
Canonical side: `CONVENTIONS.md` and `GLOSSARY.md`.

## Conventions

| Convention | Paper (where) | Canonical | Relation |
|---|---|---|---|
| Angular-momentum phases | Spherical components $\gamma^\pm=\mp(\gamma^1\pm i\gamma^2)/\sqrt2$ (source line 168); App. B CG/harmonic expansion (lines 763–778) | CONVENTIONS "Angular-momentum phases" | Identical Condon–Shortley convention, positive unit factor. The paper couples orbital momentum first: $\vert(L,S)JM\rangle$. |
| Charge conjugation | $(B\bar B^*\mp B^*\bar B)/\sqrt2$ has $CP=\pm$ (Sec. II, source line 123) | CONVENTIONS "C-parity phase" | For the even-$L$ channels here, identical $C$-even minus combination; no extra $\sqrt2$ or PV rephase. This is **not** Baru's field convention. |
| $1^{++}$ partial waves | Table 2, rows $(l,l')=(1,0),(1,2)$ | CONVENTIONS "Partial-wave projectors" | Canonical D1 kets equal the paper's kets times $D_1=\operatorname{diag}(1,1,-1)$ in $(PV\,{}^3S_1,PV\,{}^3D_1,VV\,{}^5D_1)$ order. Thus the last entry, and only the last entry, changes sign. Source: canonical entry and Zhang v1 footnote to Eq. (17), not a fit to the OME matrix. |
| $2^{++}$ partial waves | Table 2 with its orbital-first CG definition; Baru v2 App. B raw tensors, labels `BsBs5S2`, `BsBs1B2`, `BsBs5B2`, `BBs3B2`, `BB1B2` | CONVENTIONS "2++ channel basis and projectors", "Partial-wave projectors" | In canonical six-channel order, $\vert\alpha\rangle_{\rm can}=d_\alpha\vert\alpha\rangle_{\rm B}$ with $D_2=\operatorname{diag}(1,1,1,1,1,-1)$. No magnitude factor. Explicit CS/tensor comparison below fixes these signs separately from the spin recoupling. |
| Spin average and HQSS | Sec. IV, source line 324: $m_{B^{(*)}}=(m_B+3m_{B^*})/4$, $\Delta=m_{B^*}-m_B$ | GLOSSARY "Strict HQSS limit" | Identical positive mass average, $\Delta\to0$. The canonical check additionally sets **all** heavy-meson masses and reduced masses to the strict-limit values, not merely selected TOPT offsets. |
| Energy zero | Sec. V, source line 417: energy relative to twice the spin-average meson mass | CONVENTIONS "Energy origin and on-shell momentum" | $M=2\bar m_B+E_{\rm B}$; hence $E_{\rm can}=E_{\rm B}+2\bar m_B-M_{\rm th}$. In strict HQSS, both sectors have $M_{\rm th}=2\bar m_B$ and the energies coincide, with positive unit factor. |

## Symbols and equations

| Paper | Canonical | Relation | Checked by |
|---|---|---|---|
| $s_i$ and $l'$ in Table 2 | CONVENTIONS "2++ channel basis and projectors": $S_\alpha,L_\alpha$ | Positive unit rename $s_i=S_\alpha$, $l'=L_\alpha$ for the di-meson channel; Table 2's first $l$ is the **bare** orbital momentum, not the di-meson momentum. | Table caption and App. B spin-orbital definition, source lines 758–766. |
| $\bm J_{\rm light}$ in Sec. II | GLOSSARY "Recoupling coefficient", CONVENTIONS "Angular-momentum phases" | The source's **static** light angular momentum is denoted $s_\ell$ below. After orbital motion is restored, the check's $j_\ell$ includes $L$: $\bm j_\ell=\bm s_\ell+\bm L$; $\bm J=\bm s_H+\bm j_\ell$. No physical identification $j_\ell=s_\ell$ is made. | Source lines 98–104: $\bm J=\bm L+\bm S_{Q\bar Q}+\bm J_{\rm light}$ and $\bm S=\bm S_{Q\bar Q}+\bm J_{\rm light}$. |
| $\mathfrak g$ in Eq. (`coefeq`), Table 2 | GLOSSARY "Recoupling coefficient" | Dimensionless signed overlap, with no coupling factor absorbed. Row vector transforms as $\mathfrak g_{\rm can}=\mathfrak g_{\rm B}D_J$. | Exact 9j/6j row comparisons in `checks/hqss_2pp.py`; Table 2 source lines 901–909. |
| $g(r)$, Eq. (`coefeq`) | GLOSSARY "Bare–continuum coupling", CONVENTIONS "2++ bare–continuum vertex" | Not the constant canonical $g$: the paper's transition is $\mathfrak g\,g(r)$. Only the dimensionless Table 2 coefficient is borrowed here. Canonical $g\psi_n$ already includes its own normalisation and is not multiplied by another $\mathfrak g$. | Source lines 565–571 versus canonical vertex definitions. |
| $2^{++}$ $S$ coefficient $-1/\sqrt3$ | CONVENTIONS "2++ bare–continuum vertex" | Identical sign and magnitude in canonical $\alpha=1$; the $1^{++}$ $S$ coefficient is $+1/\sqrt3$. Relative sector-wide bare-state phase drops out of the stipulated $S$-only $g^2$ potential. | Table 2 rows $(1,0)$, source lines 901, 908. |

### Establishing the channel phases without deriving the rotation from projectors

The phase comparison uses one nonzero direction for each irreducible spin-angular tensor, not a projected potential. With $\boldsymbol n=\hat z$, use spherical spin kets $e_+=-(\hat x+i\hat y)/\sqrt2$, $e_0=\hat z$ and $T_0=\operatorname{diag}(-1,-1,2)/\sqrt6$. The standard angular state is

$$
\sqrt{4\pi}\sum_{m_Lm_S}\langle Lm_L,Sm_S|JM\rangle Y_{Lm_L}(\boldsymbol n)\chi_{Sm_S}.
$$

Its value at $\hat z$ is $\sqrt{2L+1}\langle L0,SM|JM\rangle\chi_{SM}$. Contract the pinned Baru tensor with the outgoing total-$J$ polarisation; its incoming spin indices remain uncontracted. The results are:

| Canonical channel | Nonzero component | Raw tensor at $\hat z$ | Standard CS state at $\hat z$ | Phase |
|---|---|---|---|---|
| $VV\,{}^5S_2$ | $M=0$ | $T_0$ | $T_0$ | $+1$ |
| $VV\,{}^1D_2$ | $M=0$ | $-\sqrt{5/3}\,\delta_{ab}$ | $\sqrt5\chi_{00}=-\sqrt{5/3}\,\delta_{ab}$ | $+1$ |
| $VV\,{}^5D_2$ | $M=0$ | $-\sqrt{10/7}\,T_0$ | $\sqrt5\langle20,20|20\rangle T_0=-\sqrt{10/7}\,T_0$ | $+1$ |
| $VV\,{}^5G_2$ | $M=0$ | $+\sqrt{18/7}\,T_0$ | $3\langle40,20|20\rangle T_0=+\sqrt{18/7}\,T_0$ | $+1$ |
| $PV\,{}^3D_2$ | $M=1$ | $-\sqrt{5/2}\,e_+$ | $\sqrt5\langle20,11|21\rangle e_+=-\sqrt{5/2}\,e_+$ | $+1$ |
| $PP\,{}^1D_2$ | $M=0$ | $-\sqrt5$ | $+\sqrt5$ | $-1$ |

Here $\chi_{00}=-\delta_{ab}/\sqrt3$ follows directly by coupling two CS spin-one vectors. In particular $T_0:v(\hat z)=\sqrt{2/3}$, so the last raw projector $-\sqrt{15/2}v_{ij}$ gives $-\sqrt5$ with no unspecified sign. The tensors and $v,S$ definitions are in Baru v2 `partners.tex:1573–1605`; all six raw tensors are retained by the independent Cartesian route. This comparison establishes $D_2$, **not** a rotation matrix. It does not insert Baru's whole-paper antimeson-field dictionary as an additional channel flip.

### Independent full HQSS rotation

The rotation is constructed exclusively from Wigner symbols in `checks/hqss_2pp.py`, not from the preceding tensors or OME polynomials. Write $h_1,\ell_1,h_2,\ell_2=1/2$, $s_H=h_1+h_2$ and $s_\ell=\ell_1+\ell_2$. The elementary spin overlap is

$$
N_{j_1j_2}^{S;s_Hs_\ell}=
\sqrt{(2j_1+1)(2j_2+1)(2s_H+1)(2s_\ell+1)}
\begin{Bmatrix}
\tfrac12&\tfrac12&j_1\\
\tfrac12&\tfrac12&j_2\\
s_H&s_\ell&S
\end{Bmatrix}.
$$

The physical antimeson constituent ordering is $(\ell_2,h_2)$ rather than $(h_2,\ell_2)$, giving $(-1)^{1-j_2}$. Thus the paper-channel spin overlaps used in the check are $-N_{00}$ for $PP$, $N_{11}$ for $VV$, and $(N_{01}+N_{10})/\sqrt2$ for its physical antisymmetric $C$-even $PV$ ket. The plus in that last Wigner expression is **not** a change of the physical $C$ state. The PP constituent-order sign and the PP orbital-projector phase are different steps; neither may be discarded as double-counting. The signs are anchored by the paper's Fierz relations (`beqs`, source lines 230–235), transition coefficients (lines 250–253, 270–271), and its signed Table 2.

For each retained orbital $L$, multiply the spin overlap by

$$
(-1)^{s_H+s_\ell+L+J}\sqrt{(2S+1)(2j_\ell+1)}
\begin{Bmatrix}s_H&s_\ell&S\\L&J&j_\ell\end{Bmatrix}
(-1)^{L+S-J}.
$$

The first factor is the 6j recoupling from $((s_Hs_\ell)S,L)J$ to $(s_H,(s_\ell L)j_\ell)J$; the final sign converts the paper's orbital-first $(L,S)J$ state. Finally multiply particle-channel columns by $D_J$. All matrix entries below are real; define $U_{a\alpha}=\langle a|\alpha\rangle_{\rm can}$, so **$V_H=U V_{\rm can}U^T$**, not the transposed convention.

Columns of $U_2$ are exactly the canonical order

$$
(VV\,{}^5S_2,\ VV\,{}^1D_2,\ VV\,{}^5D_2,\ VV\,{}^5G_2,\ PV\,{}^3D_2,\ PP\,{}^1D_2).
$$

Rows are the kets $|(s_H,(s_\ell L)j_\ell)J=2\rangle$, in $(s_H,s_\ell,j_\ell,L)$ order

$$
(1,1,1,0),\ (1,1,1,2),\ (1,1,2,2),\ (1,1,3,2),\ (1,1,3,4),\ (0,0,2,2).
$$

The full result is

$$
U_2=\begin{pmatrix}
1&0&0&0&0&0\\
0&-\sqrt5/10&\sqrt{35}/10&0&3\sqrt5/10&\sqrt{15}/10\\
0&\sqrt3/6&\sqrt{21}/6&0&-\sqrt3/6&-1/2\\
0&-\sqrt{105}/30&\sqrt{15}/15&0&-\sqrt{105}/15&\sqrt{35}/10\\
0&0&0&1&0&0\\
0&\sqrt3/2&0&0&0&1/2
\end{pmatrix}.
$$

The sixth row has $s_H=s_\ell=0$ and $j_\ell=L=2$. For even $L$, the retained $(s_H,s_\ell)=(1,1)$ and $(0,0)$ sectors have $C=+$. At total $J=2$ the retained $G$ wave has $j_\ell=3$. These six states form the complete heavy basis.

For $J=1$, columns $(PV\,{}^3S_1,PV\,{}^3D_1,VV\,{}^5D_1)$ and rows $(1,1,1,0),(1,1,1,2),(1,1,2,2)$ give the D1-phase matrix

$$
U_1=\begin{pmatrix}1&0&0\\0&-1/2&\sqrt3/2\\0&\sqrt3/2&1/2\end{pmatrix}.
$$

### Table 2 longitudinal combinations

Reordered into the canonical column order, the paper's $l=1$ rows are

$$
r_{1,\rm B}=\left(\frac1{\sqrt3},\frac1{\sqrt6},\frac1{\sqrt2}\right),\qquad
r_{2,\rm B}=\left(-\frac1{\sqrt3},-\frac1{\sqrt{30}},\sqrt{\frac7{30}},0,\sqrt{\frac3{10}},-\frac1{\sqrt{10}}\right).
$$

Therefore the signed canonical benchmarks are

$$
r_{1,\rm can}=\left(\frac1{\sqrt3},\frac1{\sqrt6},-\frac1{\sqrt2}\right),\qquad
r_{2,\rm can}=\left(-\frac1{\sqrt3},-\frac1{\sqrt{30}},\sqrt{\frac7{30}},0,\sqrt{\frac3{10}},+\frac1{\sqrt{10}}\right).
$$

With $e_a$ a row selector in the displayed heavy basis, the independent comparisons are

$$
r_{1,\rm can}=\left(\frac{e_1}{\sqrt3}-\sqrt{\frac23}e_2\right)U_1,\qquad
r_{2,\rm can}=\left(-\frac{e_1}{\sqrt3}+\sqrt{\frac23}e_2\right)U_2.
$$

The sector-wide signs are the signed Table 2 coefficients. Both benchmark rows have unit norm. The complete heavy-basis rotation is constructed independently from 9j/6j symbols.

## Check contract and flags

- `checks/hqss_2pp.py` freezes exact symbolic orthogonality/Table 2 assertions and numerical tolerance $2\times10^{-10}\max(1,\|V_2\|_{\max},\|V_1\|_{\max})$ GeV$^{-2}$, at $(p',p,E)=(.043,.117,-.031),(.139,.071,-.063),(.091,.091,-.019)$ GeV.
- The check uses the public `BOchiEFT.ome_potential` with `channels_2pp()`, setting `mB=mBstar=mbar` and `muPV=mbar/2` while retaining recoil and energy dependence. Missing `channels_2pp` is a hard failure, never skipped or replaced with a local potential. The $1^{++}$ reference uses the unchanged default constructor. Only the OME seam is checked here; no full propagator or bare-spectrum claim is inferred from it.
- In the strict HQSS limit the OME matrix separates into blocks of sizes 2,1,2,1 labelled $(s_H,j_l)=(1,1),(1,2),(1,3),(0,2)$. The first block equals the canonical 1++ block in the same light S/D order; the recorded residuals are given in `notes/04-ome-2pp.md`, Sec. 8.
- The recorded HQSS comparison has 15 passing assertions, forbidden entries at most 1.1×10^−15 GeV^−2 and common-block residual at most 9.7×10^−14 GeV^−2 (`notes/04-ome-2pp.md`, Sec. 8).
- The paper explicitly neglects light-meson exchange in its simple di-meson threshold potentials (source lines 552–562). Table 2 is used for **recoupling**, not as an OME benchmark; the OME assertion is the independently conserved heavy spin and total light angular momentum.
