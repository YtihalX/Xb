# 04: The $2^{++}$ OME projection, worked through

Source throughout: [@Zhang:2026iyr] v1, Eqs. (68)–(82), from `literature/Zhang:2026iyr/src/Xb.tex`, with the $1^{++}$ method of `notes/03-projection-method-1pp.md`. Channel order (CONVENTIONS "2++ channel basis and projectors") is

$$
1=B^*\bar B^*({}^5S_2),\ 2=B^*\bar B^*({}^1D_2),\ 3=B^*\bar B^*({}^5D_2),\ 4=B^*\bar B^*({}^5G_2),\ 5=B\bar B^*({}^3D_2),\ 6=B\bar B({}^1D_2),
$$

with the $C$-even $B\bar B^*$ combination of CONVENTIONS "C-parity phase". The row is outgoing. The projectors are those of [@Baru:2019xnh] v2, App. B, with every printed sign kept, as recorded in `literature/Baru:2019xnh/bridge.md`; relative to Condon–Shortley spin-angular functions their phases are $(+,+,+,+,+,-)$. No channel is rephased in this note.

## 1. Energy denominators: which intermediate pair, which offset

As in note 03, put $r=p'$, $x=\boldsymbol n'\cdot\boldsymbol n$, $\boldsymbol q=p\boldsymbol n-r\boldsymbol n'$, $\omega=\sqrt{p^2+r^2+m_\phi^2-2prx}$ and $D_\beta=[2\omega(\omega+\nu_\beta)]^{-1}$ (CONVENTIONS "Reduced masses and TOPT energy offsets"). The only change from $1^{++}$ is the energy origin: in $2^{++}$, $M=2m_{B^*}+E$ (CONVENTIONS "Energy origin and on-shell momentum"). The four intermediate heavy pairs of [@Zhang:2026iyr] v1, Eq. (76) then give

$$
\begin{aligned}
\nu_1&=\omega_B(p')+\omega_B(p)-M=-2\Delta m+\frac{p^2+r^2}{2m_B}-E,\\
\nu_2&=\omega_{B^*}(p)+\omega_{B^*}(p')-M=\frac{p^2+r^2}{2m_{B^*}}-E,\\
\nu_3&=\omega_B(p)+\omega_{B^*}(p')-M=-\Delta m+\frac{p^2}{2m_B}+\frac{r^2}{2m_{B^*}}-E,\\
\nu_4&=\omega_B(p')+\omega_{B^*}(p)-M=-\Delta m+\frac{r^2}{2m_B}+\frac{p^2}{2m_{B^*}}-E,
\end{aligned}
$$

with $\omega_H(p)=m_H+p^2/(2m_H)$ (CONVENTIONS "Binding energy and meson energies"). Each offset is the same intermediate energy as in $1^{++}$; only $M$ moved by $\Delta m$.

Which pair appears follows from one rule for every species transition. In one time ordering the meson line changes first, so the intermediate pair is (outgoing meson at $p'$, incoming antimeson at $p$); in the other the antimeson line changes first, giving (incoming meson at $p$, outgoing antimeson at $p'$). Applied to the six species blocks:

| out ← in | ordering 1 | ordering 2 | $D$ sum |
|---|---|---|---|
| PV ← PV (cross term of the $C$-even state) | $B(p')\bar B(p)$ | $B^*(p)\bar B^*(p')$ | $D_1+D_2$ |
| VV ← PV | $B^*(p')\bar B^*(p)$ | $B(p)\bar B^*(p')$ | $D_2+D_3$ |
| PV ← VV | $B^*(p')\bar B^*(p)$ | $B^*(p)\bar B(p')$ | $D_2+D_4$ |
| VV ← VV | $B^*\bar B^*$ | $B^*\bar B^*$ | $2D_2$ |
| VV ← PP | $B^*(p')\bar B(p)$ | $B(p)\bar B^*(p')$ | $2D_3$ |
| PP ← VV | $B(p')\bar B^*(p)$ | $B^*(p)\bar B(p')$ | $2D_4$ |

The first four rows are [@Zhang:2026iyr] v1, Eqs. (72)–(75). In the last two rows both orderings have one $B$ at the incoming (outgoing) momentum and one $B^*$ at the other, so both share $\nu_3$ (or $\nu_4$): this is followup.tex Eq. (5)'s $2D_3$ for $B\bar B\to B^*\bar B^*$ and $2D_4$ for the reverse. There is no PP–PP or PP–PV exchange, because Eq. (68) has no $PP\phi$ vertex.

## 2. The $B\bar B\leftrightarrow B^*\bar B^*$ potential and its sign

Eq. (68) has the meson terms $(V^\dagger P+P^\dagger V)\partial\Phi$ with one common coefficient, so the meson-line vertex for $B\to B^*$ and for $B^*\to B$ is the same, $\tfrac{g_b}{2F_\pi}\boldsymbol\epsilon\cdot\boldsymbol q$ with the outgoing polarisation conjugated, at the same pion momentum $\boldsymbol q=\boldsymbol p-\boldsymbol p'$ (Eq. (69)). Compare two amplitudes with the **same** antimeson line $\bar B(p)\to\bar B^*(p')$:

- $X$: $B^*(p)\bar B(p)\to B(p')\bar B^*(p')$, numerator $\propto(\boldsymbol\epsilon_1\cdot\boldsymbol q)(\boldsymbol\epsilon'^*_2\cdot\boldsymbol q)$;
- $Y$: $B(p)\bar B(p)\to B^*(p')\bar B^*(p')$, numerator $\propto(\boldsymbol\epsilon'^*_1\cdot\boldsymbol q)(\boldsymbol\epsilon'^*_2\cdot\boldsymbol q)$.

Every other factor (antimeson vertex and its sign, isospin $\boldsymbol\tau\cdot\boldsymbol\tau^c$, momentum signs, the TOPT sign) is common, so $Y$ is $X$ with $\boldsymbol\epsilon_1\to\boldsymbol\epsilon'^*_1$ and with its own denominators. In the canonical $C$-even state $(|B\bar B^*\rangle-|B^*\bar B\rangle)/\sqrt2$ the PV–PV potential has no direct term (no $PP\phi$ vertex) and equals $-X$; Eq. (72) states it as $-\tfrac{g_b^2}{4F_\pi^2}(\boldsymbol\epsilon\cdot\boldsymbol q)(\boldsymbol\epsilon'^*\cdot\boldsymbol q)(D_1+D_2)$. Hence $X$ carries $+g_b^2/(4F_\pi^2)$, and so does $Y$:

$$
V^{\rm(OME)}_{B\bar B\to B^*\bar B^*}(\boldsymbol p',\boldsymbol p;m_\phi)
=+\frac{g_b^2}{4F_\pi^2}(\boldsymbol\epsilon'^*_1\cdot\boldsymbol q)(\boldsymbol\epsilon'^*_2\cdot\boldsymbol q)\,2D_3,\qquad
V^{\rm(OME)}_{B^*\bar B^*\to B\bar B}=+\frac{g_b^2}{4F_\pi^2}(\boldsymbol\epsilon_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2\cdot\boldsymbol q)\,2D_4 .
$$

The PP and VV kets are plain products, so the $C$ convention enters only through the PV row. The sign therefore agrees with followup.tex Eq. (5) in this project's $C$-parity convention, whose second label "$B^*\bar B^8$" is a typo for $B^*\bar B^*$. The same $+q_aq_b$ is derived in the bridge from the opposite antimeson vertex sign and the opposite momentum transfer; the two arguments are independent and agree. The isoscalar combination is unchanged, $3V(m_\pi)+V(m_\eta)/3$ (Eq. (82)).

With $R_{ac}=\varepsilon_{cak}q_k$ and $\boldsymbol A=i(\boldsymbol\epsilon\times\boldsymbol\epsilon'^*)/\sqrt2$, the isospin-free spin numerators $N$ (potential $=\tfrac{g_b^2}{4F_\pi^2}N$ times the $D$ sum of Sec. 1) are

$$
N_{PV,PV;ac}=-q_aq_c,\quad N_{VV,PV;ab,c}=\tfrac{i}{\sqrt2}(R_{ac}q_b+R_{bc}q_a),\quad N_{PV,VV}=N_{VV,PV}^\dagger,\quad N_{VV,VV;ab,cd}=R_{ac}R_{bd},\quad N_{VV,PP;ab}=N_{PP,VV;ab}=+q_aq_b .
$$

## 3. The contraction

Eq. (80) at $J=2$ is

$$
V_{\alpha'\alpha}=\frac15\int\frac{d\Omega'}{4\pi}\frac{d\Omega}{4\pi}\sum_{M}\sum_{\sigma'\sigma}P^{(\alpha')*}_{\sigma'M}(\boldsymbol n')\,V_{\sigma'\sigma}(\boldsymbol q)\,P^{(\alpha)}_{\sigma M}(\boldsymbol n),
$$

where $P_{\sigma M}=P_{\sigma,ij}\mathcal E^M_{ij}$ contracts the total-$J$ tensor indices with five real orthonormal symmetric traceless tensors $\mathcal E^M$, so $\sum_M\mathcal E^M_{ij}\mathcal E^M_{kl}=\Pi_{ij,kl}$, the projector onto symmetric traceless tensors. After the spin sums the integrand is a rotational scalar built from $\boldsymbol n,\boldsymbol n'$ alone, hence a function of $x$, and the double average is $\tfrac12\int_{-1}^1dx$. With $T_{\alpha'\alpha}(x)=\tfrac15\sum P^*NP$,

$$
V_{\alpha'\alpha}=-\frac{g_b^2}{8F_\pi^2}\sum_{k=0}^4c_{\alpha'\alpha,k}\,\Delta_k^{(\beta\gamma)},\qquad c_{\alpha'\alpha}(x)=-T_{\alpha'\alpha}(x),\qquad \Delta_k^{(\beta\gamma)}=\int_{-1}^1dx\,x^k(D_\beta+D_\gamma),
$$

exactly as in $1^{++}$ with $1/3\to1/5$. The repeated pairs $(22),(33),(44)$ mean two equal time orderings.

### Three worked entries

**$S$–$S$, entry 11.** $P^{(1)}=\tfrac12S$ is the identity on the spin-2 subspace of $B^*\bar B^*$, so $T_{11}=\tfrac15\operatorname{Tr}_{S=2}N_{VV,VV}$. Using spin-1 matrices $(S_k)_{ac}=-i\varepsilon_{kac}$ one has $R=-i\,\boldsymbol S\cdot\boldsymbol q$ on each line, so $N_{VV,VV}=-(\boldsymbol S_1\cdot\boldsymbol q)(\boldsymbol S_2\cdot\boldsymbol q)$. In the $S=2$ multiplet the traceless part of $S_{1i}S_{2j}$ has zero trace and $\langle\boldsymbol S_1\cdot\boldsymbol S_2\rangle=\tfrac12(6-2-2)=1$, so $\operatorname{Tr}_{S=2}S_{1i}S_{2j}=\tfrac53\delta_{ij}$. Thus $T_{11}=-q^2/3$ and

$$c_{11}=\frac{q^2}{3}=\frac{p^2+r^2}{3}-\frac{2pr}{3}x,$$

the same polynomial as the $1^{++}$ entry 11 of note 03.

**$S$–$B\bar B$, entry 16** (the new transition). $\tfrac12S_{abij}q_aq_b=q_iq_j-\delta_{ij}q^2/3$ and $P^{(6)}=-\sqrt{15/2}\,v_{ij}(\boldsymbol n)$ with $v_{ij}=n_in_j-\delta_{ij}/3$. Contracting through $\Pi$,

$$
T_{16}=-\frac15\sqrt{\frac{15}2}\Bigl[(\boldsymbol n\cdot\boldsymbol q)^2-\frac{q^2}3\Bigr]
=-\frac{\sqrt{30}}{10}\Bigl[(p-rx)^2-\frac{p^2+r^2-2prx}3\Bigr],
$$

so $c_{16}=\sqrt{30}\,[(2p^2-r^2)-4prx+3r^2x^2]/30$. Outgoing VV and incoming PP is the VV ← PP row of Sec. 1, so entry 16 carries $2D_3$; its transpose 61 carries $2D_4$.

**${}^1D_2$–$B\bar B$, entry 26.** $P^{(2)}=-\sqrt{5/2}\,\delta_{ab}v_{ij}(\boldsymbol n')$ contracts $q_aq_b$ to $q^2$, and $\sqrt{5/2}\sqrt{15/2}=5\sqrt3/2$, $v(\boldsymbol n'):\Pi:v(\boldsymbol n)=x^2-1/3$. So $T_{26}=\tfrac{\sqrt3}{2}q^2(x^2-\tfrac13)$ and

$$c_{26}=\frac{\sqrt3}{6}(p^2+r^2)-\frac{\sqrt3}{3}prx-\frac{\sqrt3}{2}(p^2+r^2)x^2+\sqrt3\,prx^3 .$$

The remaining entries use the same identities as note 03 ($\operatorname{tr}(Q'Q)=x^2-\tfrac13$, $\boldsymbol n'\cdot\boldsymbol q=px-r$, $\boldsymbol n\cdot\boldsymbol q=p-rx$, $\varepsilon\varepsilon=\delta\delta-\delta\delta$), plus the rank-four $v_{ijkl}$ for the $G$ wave; the outgoing projector is complex-conjugated before contracting (the $-i$ of $P^{(5)}$ matters for 15, 25, 35, 45, 55). They were contracted in computer algebra at $\boldsymbol n=\hat z$, $\boldsymbol n'=(\sqrt{1-x^2},0,x)$, which is legitimate because $T$ depends only on $x$; the script asserts that odd powers of $\sqrt{1-x^2}$ cancel identically. The script, `notes/04-ome-2pp-contractions.py` (a derivation aid, not a check), first asserts that the same contraction with the (D1) projectors reproduces every coefficient of the note-03 $1^{++}$ table, then prints the table below.

### Selection-rule zeros

Four upper-triangle entries vanish identically: 14 ($S\to G$ needs $\Delta L=4$, but $N$ is rank 2 in $\boldsymbol q$); 25, because the ${}^1D_2$ projector carries the spin singlet $\delta_{ab}$ and $\delta_{ab}N_{VV,PV;ab,c}=i\sqrt2\,R_{ac}q_a=i\sqrt2\,\varepsilon_{cak}q_aq_k=0$; 56 and 66 (no $PP\phi$ vertex).

## 4. Every entry as angular moments

$V_{\alpha'\alpha}=-\tfrac{g_b^2}{8F_\pi^2}\sum_{k=0}^{4}c_{\alpha'\alpha,k}\Delta_k^{(\beta\gamma)}$, outgoing momentum $r$, incoming $p$. Common structures: $s(p,r)\equiv\bigl(-\tfrac{2p^2-r^2}{6},\tfrac{2pr}3,-\tfrac{r^2}2,0,0\bigr)$ is the $S$–$D$ polynomial; $1^{++}$ has $c_{12}=\sqrt2\,s$, $c_{13}=-\sqrt6\,s$.

| Entry | $(\beta\gamma)$ | $c_0$ | $c_1$ | $c_2$ | $c_3$ | $c_4$ |
|---|---|---|---|---|---|---|
| 11 | 22 | $(p^2+r^2)/3$ | $-2pr/3$ | 0 | 0 | 0 |
| 12 | 22 | $\sqrt{2/5}\,s_0$ | $\sqrt{2/5}\,s_1$ | $\sqrt{2/5}\,s_2$ | 0 | 0 |
| 13 | 22 | $-\sqrt{14/5}\,s_0$ | $-\sqrt{14/5}\,s_1$ | $-\sqrt{14/5}\,s_2$ | 0 | 0 |
| 14 | 22 | 0 | 0 | 0 | 0 | 0 |
| 15 | 23 | $-\sqrt{18/5}\,s_0$ | $-\sqrt{18/5}\,s_1$ | $-\sqrt{18/5}\,s_2$ | 0 | 0 |
| 16 | 33 | $-\sqrt{6/5}\,s_0$ | $-\sqrt{6/5}\,s_1$ | $-\sqrt{6/5}\,s_2$ | 0 | 0 |
| 22 | 22 | $(p^2+r^2)/3$ | $-2pr/3$ | $-(p^2+r^2)$ | $2pr$ | 0 |
| 23 | 22 | $-\sqrt7(p^2+r^2)/21$ | $-\sqrt7pr/21$ | $\sqrt7(p^2+r^2)/7$ | $-\sqrt7pr/7$ | 0 |
| 24 | 22 | $\sqrt{35}(4p^2-3r^2)/140$ | $-6\sqrt{35}pr/35$ | $-3\sqrt{35}(2p^2-5r^2)/70$ | $2\sqrt{35}pr/7$ | $-\sqrt{35}r^2/4$ |
| 25 | 23 | 0 | 0 | 0 | 0 | 0 |
| 26 | 33 | $\sqrt3(p^2+r^2)/6$ | $-\sqrt3pr/3$ | $-\sqrt3(p^2+r^2)/2$ | $\sqrt3pr$ | 0 |
| 33 | 22 | $-5(p^2+r^2)/21$ | $11pr/42$ | $5(p^2+r^2)/7$ | $-17pr/14$ | 0 |
| 34 | 22 | $-\sqrt5(4p^2-3r^2)/70$ | $12\sqrt5pr/35$ | $3\sqrt5(2p^2-5r^2)/35$ | $-4\sqrt5pr/7$ | $\sqrt5r^2/2$ |
| 35 | 23 | $\sqrt7(p^2+r^2)/14$ | $\sqrt7pr/14$ | $-3\sqrt7(p^2+r^2)/14$ | $3\sqrt7pr/14$ | 0 |
| 36 | 33 | $\sqrt{21}(p^2+r^2)/21$ | $\sqrt{21}pr/21$ | $-\sqrt{21}(p^2+r^2)/7$ | $\sqrt{21}pr/7$ | 0 |
| 44 | 22 | $-3(p^2+r^2)/56$ | $-3pr/7$ | $15(p^2+r^2)/28$ | $5pr/7$ | $-5(p^2+r^2)/8$ |
| 45 | 23 | $-\sqrt{35}(3p^2-4r^2)/70$ | $-12\sqrt{35}pr/35$ | $3\sqrt{35}(5p^2-2r^2)/35$ | $4\sqrt{35}pr/7$ | $-\sqrt{35}p^2/2$ |
| 46 | 33 | $\sqrt{105}(3p^2-4r^2)/140$ | $6\sqrt{105}pr/35$ | $-3\sqrt{105}(5p^2-2r^2)/70$ | $-2\sqrt{105}pr/7$ | $\sqrt{105}p^2/4$ |
| 55 | 12 | 0 | $pr/2$ | 0 | $-pr/2$ | 0 |
| 56 | — | 0 | 0 | 0 | 0 | 0 |
| 66 | — | 0 | 0 | 0 | 0 | 0 |

The lower triangle follows from Hermitian conjugation of the 3D blocks and exchanging the two integration variables: $c_{\alpha\alpha'}(r,p)=c_{\alpha'\alpha}(p,r)$, with the $D$ sum of the reversed species row ($23\to24$, $33\to44$). This is time reversal, $V_{\alpha\alpha'}(p,p';E)=V_{\alpha'\alpha}(p',p;E)$. Write $\nu_\beta(p',p)$ for the offset at outgoing $p'$ and incoming $p$; then $\nu_4(p,p')=\nu_3(p',p)$, so the reversed entry reproduces the forward denominators only if it uses $\nu_4$. Reusing $\nu_3$ there (a $D_3\leftrightarrow D_4$ swap) breaks the symmetry, because $\nu_3(p,p')\neq\nu_3(p',p)$ for $m_B\neq m_{B^*}$ at unequal momenta.

The highest power is $x^4$, reached only by the $G$-wave entries 24, 34, 44, 45, 46, so the $2^{++}$ kernel needs one more angular moment than $1^{++}$ ($x^0$–$x^3$). The $B\bar B\leftrightarrow B^*\bar B^*$ entries are 16, 26, 36, 46 with $2D_3$, and 61, 62, 63, 64 with $2D_4$.

## 5. Limiting cases and the HQSS structure

Dimensions are those of note 03: $c_k$ in GeV$^2$, $\Delta_k$ in GeV$^{-2}$, $g_b^2/F_\pi^2$ in GeV$^{-2}$, so $V$ is in GeV$^{-2}$.

1. **Zero momentum.** At $p=0$ or $r=0$ the denominator is $x$-independent, and $\int x^{2n+1}=0$, $\int1=2$, $\int x^2=2/3$, $\int x^4=2/5$ remove every entry with a zero-momentum $D$ or $G$ leg. For example, at $r=p'=0$ (outgoing $S$ leg at rest) $c_{16}=\sqrt{30}\,p^2/15$ is finite, while at $p=0$ (incoming $D$ leg at rest) $c_{16}$ integrates to $\tfrac{\sqrt{30}}{30}(-r^2+3r^2\cdot\tfrac13)\cdot2=0$; at $r=0$, $c_{44}$ integrates to $p^2(-\tfrac3{56}\cdot2+\tfrac{15}{28}\cdot\tfrac23-\tfrac58\cdot\tfrac25)=0$.
2. **Strict HQSS.** With all heavy-meson masses set to $\bar m=(m_B+3m_{B^*})/4$ (GLOSSARY "Strict HQSS limit") all offsets coincide and every $D$ sum is $2D$, so $V\propto c$. Rotating the full $6\times6$ polynomial matrix $c$ with the 9j/6j matrix $U_2$ of `literature/Bruschini:2023zkb/bridge.md` gives blocks of sizes $2,1,2,1$ for $(s_H,j_\ell)=(1,1),(1,2),(1,3),(0,2)$, and its $(1,1)$ block equals that of $U_1c^{(1^{++})}U_1^T$: e.g. $[U_2cU_2^T]_{12}=\sqrt2\,(2p^2-r^2-4prx+3r^2x^2)/3=-\tfrac12c^{(1^{++})}_{12}+\tfrac{\sqrt3}2c^{(1^{++})}_{13}$. The contraction script asserts both statements in exact arithmetic. Thus the derivation already satisfies the claim's HQSS statement; `checks/hqss_2pp.py` tests it on the package numbers with a rotation built from Wigner symbols and the bridged channel phases, not from the projector tensors.
3. **The new transition in the static limit.** Dropping recoil and $E$ only for this argument, $\nu_3=\nu_4=-\Delta m$, so $2D_3=2D_4=[\omega(\omega-\Delta m)]^{-1}$: the $B\bar B\leftrightarrow B^*\bar B^*$ entries are reciprocal by construction there, and full recoil is what makes the time-reversal check sensitive to a $D_3\leftrightarrow D_4$ swap.

## 6. Implementation walkthrough

The package kernel lives in `code/HadronDynamics.jl/src/models/BOchiEFT/` (submodule branch `xb-followup`).

- **Channel sets** (`projection.jl`). `channels_1pp()` and `channels_2pp()` return an `OMEChannelSet`: the total $J$, the polynomial degree in $x$ (3 or 4), a tuple of `OMEChannel(label, species)` in canonical order (`:PV_3S1, :PV_3D1, :VV_5D1` and `:VV_5S2, :VV_1D2, :VV_5D2, :VV_5G2, :PV_3D2, :PP_1D2`), and the coefficient table. `projection_coefficients(set, out, in, pout, pin)` returns the $c_k$: the unchanged $1^{++}$ table of note 03, or the $2^{++}$ table of Sec. 4 (`_coefficients_2pp`). Entries below the diagonal call the upper entry with $p\leftrightarrow r$, which is the transposition rule of Sec. 4.
- **Offsets** (`exchange.jl`, `_ome_intermediates`, `tc_alphas`). `_ome_intermediates(out_species, in_species)` returns the two intermediate pairs of the table in Sec. 1 as (species at $p'$, species at $p$), and `()` for PP–PP and PP–PV. `tc_alphas` turns each pair into $\nu=\omega_X(p')+\omega_Y(p)-M$ with $M$ the threshold of channel 1 plus $E$, keeping the arithmetic of the former index-based $1^{++}$ code, so the $1^{++}$ frozen-reference tests still agree bit for bit. The approximation switches (no mass splitting, no recoil, no energy dependence) use the same pairs, with the rest-mass difference written as (number of vector mesons in the pair minus that of channel 1) times $\Delta m$.
- **Moments** (`tc_moments`). For each offset, $\int x^k\,dx/[2\omega(\omega+\nu)]$ for $k=0,\dots,$ degree, by the substitution $\omega=\sqrt{A-Bx}$ (note 03), or by 64-node quadrature when $B=2pp'$ is small against $A=p^2+p'^2+m_\phi^2$ (and $\nu^2$). The recurrence divides by $B^{k+1}$, and the $G$-wave combinations cancel to $O(p'^4)$ at small $p'$; at $p'=0.02$, $p=0.4$ GeV the $1^{++}$ switch at $|B|/{\rm scale}=0.06$ left errors up to $1.3\times10^{-9}$ GeV$^{-2}$ in the entries with an outgoing $G$ wave against a 1024-node quadrature (the package test caught it; Sec. 7). In $2^{++}$ the quadrature branch therefore extends to 0.3. Below it the 64-node rule agrees with a high-precision recurrence to $4\times10^{-15}$ (relative); just above it the Float64 recurrence's relative moment error is about $10^{-12}$, which the referee found to leave $2.8\times10^{-12}$ GeV$^{-2}$ in entries 45 and 46 at $p'=0.05$, $p=0.228$ GeV ($6\times10^{-9}$ of those small entries). $1^{++}$ keeps the original 0.06. `tc_vphi` contracts the moments with the coefficients and $-g_b^2/(8F_\pi^2)$.
- **Public seam** (`ome_potential`, `OMEInteraction(...; channels=...)`). `ome_potential` adds $3V(m_\pi)+V(m_\eta)/3$ and rejects indices outside the set with an `ArgumentError`; channel 1 (the $S$ wave in both sets) keeps both mesons whatever `exchange` says, `tensor_scale` multiplies all other entries and `third_scale` the species-changing ones. These diagnostic switches only carry the $1^{++}$ semantics over to the six channels; at their defaults (full OME, as used for every result) they do nothing. The checks isolate one meson by setting $m_\pi=m_\eta$ and dividing by $3+1/3$.

## 7. Checks against the package, and their red runs

All three slice-04 checks call the public seam `OMEInteraction(cfg; channels=channels_2pp())` with expectations and tolerances frozen before this derivation (commits `c992b60`, `e49af82`).

| Check | Green result (2026-10-29) | Deliberate red |
|---|---|---|
| `checks/projection_2pp.py`: brute-force Eq. (80), 21 entries, $\pi$ and $\eta$, 3 seeded samples | 141 PASS: 12 projector Gram assertions, 3 below-$B\bar B\pi$ samples, 126 entries; largest residual $2.9\times10^{-12}$ GeV$^{-2}$, largest order-12/18 change $2.7\times10^{-15}$ GeV$^{-2}$ (tolerance $5\times10^{-9}\max(1,|V|)$) | $B\bar B\leftrightarrow B^*\bar B^*$ sign reversed in the package: exit 1, the 24 lines of entries 16, 26, 36, 46 FAIL (below) |
| `checks/time_reversal_2pp.jl`: $V_{\alpha'\alpha}(p',p)=V_{\alpha\alpha'}(p,p')$, 21 entries, 3 points, $\pi$ and $\eta$ | 126 PASS, largest residual $6.7\times10^{-16}$ GeV$^{-2}$ | entry 16 alone given the $D_4$ offsets ($\nu_3\to\nu_4$ in `tc_alphas`): exit 1, the six entry-16 lines FAIL with residuals $3.0\times10^{-4}$ ($\pi$) to $1.2\times10^{-6}$ ($\eta$) GeV$^{-2}$, 120 PASS |
| `checks/hqss_2pp.py`: 9j/6j rotation, block structure, $J_\ell=1$ block vs $1^{++}$ | 15 PASS; forbidden entries $\le1.1\times10^{-15}$, $J_\ell=1$ blocks equal to $9.7\times10^{-14}$ GeV$^{-2}$ | PP projector sign flipped in the package (entries with one PP leg negated): exit 1, all 3 block-diagonality and all 3 $J_\ell=1$ comparisons FAIL (forbidden entries up to 3.9 GeV$^{-2}$), the 1++ and exact Wigner assertions still PASS |

All deliberate breaks were temporary one-line package edits (or, for `--flip-pp`, the check's own switch), reverted byte-for-byte before the green runs were repeated. The exact-arithmetic consistency of the table (Sec. 5) and these three numerical routes agree. The projection route shares the [@Baru:2019xnh] v2 projectors and the Eq. (68) spin numerators of Sec. 2, including the $+q_aq_b$ of $B\bar B\leftrightarrow B^*\bar B^*$, with this derivation, so it tests the contraction and the denominators, not that sign. The HQSS route shares no projector tensor or numerator; it uses the bridged channel phases $D_2=\operatorname{diag}(1,1,1,1,1,-1)$, so it tests the sign of the $B\bar B\leftrightarrow B^*\bar B^*$ entries relative to the bridged $B\bar B({}^1D_2)$ projector phase. The absolute sign rests on the Sec. 2 argument, which agrees with the bridge's independent vertex-by-vertex argument and with followup.tex Eq. (5).

Further recorded runs (2026-10-29):

- **Projection check, broken result.** With the $B\bar B\leftrightarrow B^*\bar B^*$ sign reversed in the package (the same one-line edit as the HQSS red: every $2^{++}$ entry with exactly one PP leg negated), `uv run --script checks/projection_2pp.py` exits 1: the 24 comparisons of entries 16, 26, 36, 46 FAIL (e.g. $\pi$, sample 1, entry 16: package $+3.0662$, integral $-3.0662$ GeV$^{-2}$); the other 117 assertions PASS.
- **HQSS check, `--flip-pp`.** On the green package, `uv run --script checks/hqss_2pp.py --flip-pp` exits 1 with the same six FAIL lines and numbers as the package-edit red.
- **Package tests, red then green.** The interface testset was added first and errored on `UndefVarError: channels_2pp`. After the channel sets landed, the analytic-vs-quadrature assertion (`rtol=1e-8, atol=1e-9`) failed for entries 45 and 46 at $p'=0.02$, $p=0.4$ GeV: $3.2432\times10^{-6}$ against $3.2420\times10^{-6}$ and $-2.8928\times10^{-6}$ against $-2.8914\times10^{-6}$ GeV$^{-2}$ (a 1024-node rule showed errors up to $1.3\times10^{-9}$ GeV$^{-2}$ in entries 42–46). Moving the $2^{++}$ quadrature switch to 0.3 made all 309 assertions pass. Measured at $A=1$, $\nu\in\{0.5,0.01,-0.3,-0.8\}$ against the 256-bit recurrence: the order-4 Float64 recurrence errs by up to $5\times10^{-9}$ (relative) at $|B|/A=0.06$, $10^{-10}$ at 0.1, $3\times10^{-12}$ at 0.2, $1.3\times10^{-12}$ at 0.3; the 64-node rule stays below $4\times10^{-15}$ up to 0.3. The other BOchiEFT testsets, including every frozen-reference `==` comparison, pass unchanged; no $1^{++}$ assertion needed relaxing.
- **Recurrence branch against the brute-force integral (diagnostic, not a committed check).** The committed projection samples have $|B|/{\rm scale}\le0.30$ and so exercise the kernel's quadrature branch. A copy of the check with points $(p',p,E)=(0.30,0.40,-0.05),(0.45,0.35,-0.03),(0.25,0.50,-0.07)$ GeV (recurrence branch for both mesons) and orders 18 and 26 gives $|V_{\rm package}-V_{\rm integral}|\le2.2\times10^{-10}$ GeV$^{-2}$ for all 126 entries ($|V|\le10.9$ GeV$^{-2}$); the order-18→26 change reaches $2.2\times10^{-7}$ GeV$^{-2}$, so at these momenta the agreement is limited by the brute-force integral's own convergence, and that run's convergence assertion fails on 24 lines for that reason. The package test compares the same branch with the independent 256-node angular rule.
