# Bridge: [@Wu:2026wxb]

Paper: B. Wu, W.-J. Wang, M.-L. Du, F.-K. Guo and H.-J. Jing, "Coupled-channel extension of the effective-range expansion with left-hand cut", arXiv:2610.32139v1.
Read from: `literature/Wu:2026wxb/src/main.tex`; `.arxiv-version` pins v1. Equation numbers were read from a local compile of that source (`main.aux`): Eq. (63) is `equ:LSE`, Eq. (64) `equ:VinLSE`, Eqs. (D1)–(D4) are `eq:contour_logs`, `eq:contour_triangle`, `eq:triangle_principal_cuts`, `eq:leftward_logs`.
Canonical side: `CONVENTIONS.md` and `GLOSSARY.md`.

## Conventions

| Convention | Paper (where) | Canonical | Relation |
|---|---|---|---|
| LSE sign and propagator | Eq. (63) | CONVENTIONS "Lippmann–Schwinger equation" | Paper: $T=V+\int\frac{l^2dl}{2\pi^2}V\,T/(E-l^2/2\mu_\alpha-\delta_\alpha+i\epsilon)$. Since $1/(E-l^2/2\mu-\delta+i\epsilon)=-G_\alpha$, this is the canonical $T=V-\int VGT$: identical sign of $V$ and of $T$. |
| Loop measure | Eq. (63) | CONVENTIONS "Loop measure and regulator" | Identical $l^2dl/(2\pi^2)$. The paper integrates to $\infty$ (its potential falls as $l^{-2}$); the canonical loop stops at the sharp cutoff $\Lambda$. |
| Energy origin | text below Eq. (64) | CONVENTIONS "Energy origin and on-shell momentum" | Paper: $E$ from the threshold of its first channel, the lowest one in its example. Canonical: from the $S$-wave channel's threshold, which in $2^{++}$ is the highest two-body threshold. Only $\delta_\alpha$ changes; no sign changes. |
| Logarithms | App. D, text after Eq. (D1) | CONVENTIONS "Continued angular moments" | Paper's $\operatorname{Log}$ is the principal logarithm, cut on the negative real axis, as canonical. $n_\pm$ change by $+1$ ($-1$) when the argument crosses its negative real axis from above to below (below to above). |
| Sheets | App. D, case (c) ("first Riemann sheet") | CONVENTIONS "Pole position and Riemann sheets" | Paper's first sheet of one channel, $\operatorname{Im}p>0$, is canonical $(+)$; the fourth quadrant of $p$, used for the mirrored example in NOTEBOOK.md, Open questions, Kernel continuation, is canonical $(-)$. |
| Contour | App. D, Fig. 11 | CONVENTIONS "Continuation to other sheets" | Paper contours start at $q=0$ and run to $+\infty$; canonical contours end at $\Lambda$. The paper continues only into the first quadrant of $p$; the fourth-quadrant mirror images are this project's (NOTEBOOK.md, Open questions, Kernel continuation). |

## Symbols and equations

| Paper | Canonical | Relation | Checked by |
|---|---|---|---|
| $\mathbb V_{ij}(p_i,q_j)$, Eq. (64), App. D | $V_{\alpha'\alpha}(p',p)$ of CONVENTIONS "Lippmann–Schwinger equation" | Same object for an $S$-wave static Yukawa exchange with equal masses: $c(\ell_- - \ell_+)/(4pq)$. | Eq. (64), App. D; NOTEBOOK.md, Open questions, Branch discrepancy. |
| $w_\pm=(q\pm p)^2+m^2$, Eq. (D2) | $s_\pm^2$ of CONVENTIONS "Continued angular moments", with $(p',p)\to(q,p)$ and $m\to m_\phi$ | Identical: $w_\pm=s_\pm^2$. The TOPT kernel takes $\log(s_\pm+\nu_\beta)$ where the static Yukawa log takes $\frac12\log w_\pm$; they coincide at $\nu_\beta=0$. | NOTEBOOK.md, Open questions, Kernel continuation |
| $\ell_\pm=\operatorname{Log}w_\pm+2\pi i\,n_\pm$, Eq. (D1) | $L^{(\beta)}_\pm=\operatorname{Log}(s_\pm+\nu_\beta)+2\pi i\,n_\pm$ | Same continuation rule (continuous from real momenta, where $n_\pm=0$), applied to different arguments. | `checks/appd_contours.py` (draft, prescriptions unfilled); NOTEBOOK.md, Open questions, Kernel continuation |
| $J(p;m)$, Eq. (D2) | — | Used only as the worked example; $p$ is the on-shell momentum $k$, $q$ the loop momentum, $m$ the exchange mass $m_\phi$. | `checks/appd_contours.py` (draft, prescriptions unfilled) |
| Cuts of $\operatorname{Log}w_\pm$, Eq. (D3) | — | $\operatorname{Re}q=\pm\operatorname{Re}p$, $\lvert\operatorname{Im}q\mp\operatorname{Im}p\rvert\geq m$; identical for $\sqrt{w_\pm}$, so they are the cuts of $s_\pm$ too. | `checks/appd_contours.py` (draft, prescriptions unfilled) |
| $u_\pm=q+p\pm im$, Eq. (D4) | — | $\ell_+=\operatorname{Log}u_-+\operatorname{Log}u_+$ moves the $w_+$ cuts to horizontal rays. | `checks/appd_contours.py` (draft, prescriptions unfilled) |
| $C_{R0}$, $C_R$, $C_R'$, $C_L$, $C_L'$, $C_S$, Fig. 11 and text of App. D | — | $C_{R0}$: $[0,\infty)$. $C_R$: $0\to ih\to\infty+ih$, $\operatorname{Im}p-m<h<\operatorname{Im}p$. $C_R'$: $[0,\infty)$ plus $2\pi i\int_{\operatorname{Re}p}^{p-im}\frac{q\,dq}{p^2-q^2}$. $C_L$: $0\to-r\to-r+ih\to\infty+ih$ plus $-2\pi i\int_{C_S}\frac{q\,dq}{p^2-q^2}$, $C_S$: $-\operatorname{Re}p\to-r\to-r+ih\to-\operatorname{Re}p+ih$. $C_L'$: a left bulge from $0$ to $ih$, then to $\infty+ih$, with Eq. (D4). | `checks/appd_contours.py` (draft, prescriptions unfilled) |

## Flags

- The explicit failing-contour cases for the ratio-log representation remain unestablished in this project; App. D treats first-quadrant p only.
- The paper treats static Yukawa exchange without TOPT offsets. Extension to the full TOPT kernel remains an Open question in NOTEBOOK.md, Kernel continuation.
- This bridge covers App. D, Eqs. (63)–(64) only.
