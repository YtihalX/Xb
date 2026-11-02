# 04: The $2^{++}$ OME projection, worked through

Source: [@Zhang:2026iyr] v1, Eqs. (68)–(82), (D11)–(D15). Notation follows CONVENTIONS “OME spin numerator and its projection”, “Projected OME potential”, “Partial-wave states” and “2++ channel basis and projectors”. Rows are outgoing. The channel order is

$$
1=B^*\bar B^*({}^5S_2),\quad2=B^*\bar B^*({}^1D_2),\quad3=B^*\bar B^*({}^5D_2),\quad4=B^*\bar B^*({}^5G_2),\quad5=B\bar B^*({}^3D_2),\quad6=B\bar B({}^1D_2).
$$

Channel 5 is the $C$-even combination $(|B\bar B^*\rangle-|B^*\bar B\rangle)/\sqrt2$. The projectors retain the printed signs of [@Baru:2019xnh] v2, App. B, through `literature/Baru:2019xnh/bridge.md`; their phases relative to Condon–Shortley spin-angular functions are $(+,+,+,+,+,-)$.

## 1. Spin numerators and the transition signs

Write $\boldsymbol q=\boldsymbol p-\boldsymbol p'$, $E_\phi=\sqrt{\boldsymbol q^2+m_\phi^2}$ and

$$
V(\boldsymbol p',\boldsymbol p;m_\phi)=\frac{g_b^2}{4F_\pi^2}\mathcal N(\boldsymbol q)(D_{\beta_1}+D_{\beta_2}),\qquad D_\beta=\frac1{2E_\phi(E_\phi+\nu_\beta)}.
$$

Here $g_b$ is the axial coupling, $F_\pi$ the pion decay constant, $m_\phi$ the exchanged-meson mass and $\nu_\beta$ the intermediate heavy-pair energy minus the total energy. Only bilinears in $\boldsymbol q$ occur, so reversing its sign changes nothing. Polarisation labels are $\lambda,\lambda'$; primes and complex conjugation denote outgoing polarisations. Define $\boldsymbol A=i(\boldsymbol\epsilon\times\boldsymbol\epsilon'{}^*)/\sqrt2$, with particle labels 1 and 2 on the two lines, as in [@Zhang:2026iyr] v1, Eq. (70). The signs belong inside $\mathcal N$, not in the isospin factors.

| out $\leftarrow$ in | $\mathcal N(\boldsymbol q)$ | $(\beta_1,\beta_2)$ |
|---|---|---|
| PV $\leftarrow$ PV | $-(\boldsymbol\epsilon\cdot\boldsymbol q)(\boldsymbol\epsilon'{}^*\cdot\boldsymbol q)$ | $(1,2)$ |
| VV $\leftarrow$ PV | $(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol\epsilon'_2{}^*\cdot\boldsymbol q)+(\boldsymbol A_2\cdot\boldsymbol q)(\boldsymbol\epsilon'_1{}^*\cdot\boldsymbol q)$ | $(3,2)$ |
| PV $\leftarrow$ VV | Hermitian reverse of the previous row | $(4,2)$ |
| VV $\leftarrow$ VV | $-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$ | $(2,2)$ |
| VV $\leftarrow$ PP | $+(\boldsymbol\epsilon'_1{}^*\cdot\boldsymbol q)(\boldsymbol\epsilon'_2{}^*\cdot\boldsymbol q)$ | $(3,3)$ |
| PP $\leftarrow$ VV | $+(\boldsymbol\epsilon_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2\cdot\boldsymbol q)$ | $(4,4)$ |
| PP $\leftrightarrow$ PV; PP $\leftarrow$ PP | $0$ (no $PP\phi$ vertex) | — |

The first four rows are [@Zhang:2026iyr] v1, Eqs. (72)–(75). In Cartesian spin indices, put $R_{ac}=\varepsilon_{cak}q_k$, where $\varepsilon$ is the Levi-Civita tensor. The same spin numerators are

$$
\mathcal N_{PV,PV;ac}=-q_aq_c,\quad
\mathcal N_{VV,PV;ab,c}=\frac{i}{\sqrt2}(R_{ac}q_b+R_{bc}q_a),\quad
\mathcal N_{VV,VV;ab,cd}=R_{ac}R_{bd},\quad
\mathcal N_{VV,PP;ab}=+q_aq_b.
$$

### Why $B\bar B\to B^*\bar B^*$ has the plus sign

Eq. (68) has the meson terms $(V^\dagger P+P^\dagger V)\partial\Phi$ with one common coefficient, so the meson-line vertex for $B\to B^*$ and for $B^*\to B$ is the same, $\tfrac{g_b}{2F_\pi}\boldsymbol\epsilon\cdot\boldsymbol q$ with the outgoing polarisation conjugated, at the same pion momentum $\boldsymbol q=\boldsymbol p-\boldsymbol p'$ (Eq. (69)). Compare two amplitudes with the **same** antimeson line $\bar B(p)\to\bar B^*(p')$:

- $X$: $B^*(p)\bar B(p)\to B(p')\bar B^*(p')$, numerator $\propto(\boldsymbol\epsilon_1\cdot\boldsymbol q)(\boldsymbol\epsilon'^*_2\cdot\boldsymbol q)$;
- $Y$: $B(p)\bar B(p)\to B^*(p')\bar B^*(p')$, numerator $\propto(\boldsymbol\epsilon'^*_1\cdot\boldsymbol q)(\boldsymbol\epsilon'^*_2\cdot\boldsymbol q)$.

Every other factor (antimeson vertex and its sign, isospin $\boldsymbol\tau\cdot\boldsymbol\tau^c$, momentum signs, the TOPT sign) is common, so $Y$ is $X$ with $\boldsymbol\epsilon_1\to\boldsymbol\epsilon'^*_1$ and with its own denominators. In the canonical $C$-even state $(|B\bar B^*\rangle-|B^*\bar B\rangle)/\sqrt2$ the PV–PV potential has no direct term (no $PP\phi$ vertex) and equals $-X$; Eq. (72) states it as $-\tfrac{g_b^2}{4F_\pi^2}(\boldsymbol\epsilon\cdot\boldsymbol q)(\boldsymbol\epsilon'^*\cdot\boldsymbol q)(D_1+D_2)$. Hence $X$ carries $+g_b^2/(4F_\pi^2)$, and so does $Y$:

$$
V^{\rm(OME)}_{B\bar B\to B^*\bar B^*}(\boldsymbol p',\boldsymbol p;m_\phi)
=+\frac{g_b^2}{4F_\pi^2}(\boldsymbol\epsilon'^*_1\cdot\boldsymbol q)(\boldsymbol\epsilon'^*_2\cdot\boldsymbol q)\,2D_3,\qquad
V^{\rm(OME)}_{B^*\bar B^*\to B\bar B}=+\frac{g_b^2}{4F_\pi^2}(\boldsymbol\epsilon_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2\cdot\boldsymbol q)\,2D_4 .
$$

The PP and VV kets are plain products: the $C$ convention enters only through the PV comparison. This agrees with the independent vertex-by-vertex sign argument in the Baru bridge.

## 2. TOPT offsets $\nu_\beta$


Put $x=\boldsymbol n'\cdot\boldsymbol n$, $\boldsymbol q=p\boldsymbol n-p'\boldsymbol n'$, $E_\phi=\sqrt{p^2+p'^2+m_\phi^2-2pp'x}$ and $D_\beta=[2E_\phi(E_\phi+\nu_\beta)]^{-1}$ (CONVENTIONS "Reduced masses and TOPT energy offsets"). The only change from $1^{++}$ is the energy origin: in $2^{++}$, $M=2m_{B^*}+E$ (CONVENTIONS "Energy origin and on-shell momentum"). The four intermediate heavy pairs of [@Zhang:2026iyr] v1, Eq. (76) then give

$$
\begin{aligned}
\nu_1&=\omega_B(p')+\omega_B(p)-M=-2\Delta m+\frac{p^2+p'^2}{2m_B}-E,\\
\nu_2&=\omega_{B^*}(p)+\omega_{B^*}(p')-M=\frac{p^2+p'^2}{2m_{B^*}}-E,\\
\nu_3&=\omega_B(p)+\omega_{B^*}(p')-M=-\Delta m+\frac{p^2}{2m_B}+\frac{p'^2}{2m_{B^*}}-E,\\
\nu_4&=\omega_B(p')+\omega_{B^*}(p)-M=-\Delta m+\frac{p'^2}{2m_B}+\frac{p^2}{2m_{B^*}}-E,
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

The first four rows are [@Zhang:2026iyr] v1, Eqs. (72)–(75). In the last two rows both orderings have one $B$ at the incoming (outgoing) momentum and one $B^*$ at the other, so both share $\nu_3$ (or $\nu_4$): this gives $2D_3$ for $B\bar B\to B^*\bar B^*$ and $2D_4$ for the reverse. There is no PP–PP or PP–PV exchange, because Eq. (68) has no $PP\phi$ vertex.

## 3. Projection with the incoming direction fixed

With the agreed radial-state normalisation, $V_{\alpha'\alpha}=\langle p',\alpha'|\hat V|p,\alpha\rangle$ is exactly [@Zhang:2026iyr] v1, Eq. (80):

$$
V_{\alpha'\alpha}=\frac15\int\frac{d\Omega_{n'}}{4\pi}\frac{d\Omega_n}{4\pi}\operatorname{Tr}[P^\dagger(\alpha';\hat n')VP(\alpha;\hat n)].
$$

The trace sums all spin indices and all five total-$J=2$ states $M=1,\ldots,5$. A simultaneous rotation of both directions conjugates the operator on this five-dimensional space; its trace is unchanged. Thus the traced expression depends only on $x=\hat n'\cdot\hat n$. A single fixed-$M$ matrix element does **not** have this property. It is the trace, not a choice of polarisation, that permits $\hat n=\hat z$.

Choose $\hat n'=(\sqrt{1-x^2}\cos\varphi,\sqrt{1-x^2}\sin\varphi,x)$ and define

$$
\mathcal N_{\alpha'\alpha}(x;p',p)=\int_0^{2\pi}\frac{d\varphi}{2\pi}\operatorname{Tr}[P^\dagger(\alpha';\hat n')\mathcal N(\boldsymbol q)P(\alpha;\hat z)]
=\sum_{m=0}^4\mathcal N^{(m)}_{\alpha'\alpha}(p',p)x^m.
$$

Rotations about $\hat z$ leave the incoming direction fixed and change only $\varphi$. Trace invariance therefore makes this average trivial; set $\varphi=0$ when evaluating it. The remaining angular measure is $dx/2$. Consequently

$$
V^{\rm(OME)}_{\alpha'\alpha}(p',p;m_\phi)=\frac1{10}\frac{g_b^2}{4F_\pi^2}\sum_{m=0}^4\mathcal N^{(m)}_{\alpha'\alpha}\Delta_m^{(\beta_1\beta_2)},\qquad
\Delta_m^{(\beta_1\beta_2)}=\int_{-1}^1x^m(D_{\beta_1}+D_{\beta_2})\,dx.
$$

The $1/10$ is $1/5$ from the trace average times $1/2$ from the remaining solid-angle average. The isoscalar result is $3V(m_\pi)+\frac13V(m_\eta)$ [@Zhang:2026iyr] v1, Eq. (82). The $1^{++}$ counterpart is App. D, Eqs. (D2)–(D10), with $1/6$ instead.

## 4. All 21 projected spin numerators

The following contractions use the exact intermediate results generated by `checks/_spin_numerator.py --steps`; their normalisation is the trace itself, with **no** division by five. To avoid repeating large Cartesian matrices, first give all six projectors explicitly in tensor form. Repeated Cartesian indices are summed. Let

$$
v_{ij}(\hat n)=n_in_j-\delta_{ij}/3,\qquad
S_{ij}=\epsilon_{1i}\epsilon_{2j}+\epsilon_{1j}\epsilon_{2i}-\tfrac23\delta_{ij}\,\boldsymbol\epsilon_1\cdot\boldsymbol\epsilon_2,
$$

and let $v_{ijkl}(\hat n)=n_in_jn_kn_l-\frac17\sum_{6}\delta_{ij}n_kn_l+\frac1{35}\sum_3\delta_{ij}\delta_{kl}$, where the sums contain the six distinct choices of one delta pair and the three pairings of four indices, respectively. Here $\boldsymbol\epsilon_1,\boldsymbol\epsilon_2$ are the incoming vector-meson polarisations. Contract the total-$J$ indices of each projector with five real orthonormal symmetric traceless tensors $T^M_{ij}$, $M=1,\ldots,5$, and sum over $M$ in the trace. The explicit projectors are

$$
\begin{aligned}
P^{(1)}_{ij}&=\tfrac12S_{ij},\\
P^{(2)}_{ij}(\hat n)&=-\sqrt{5/2}\,(\boldsymbol\epsilon_1\cdot\boldsymbol\epsilon_2)v_{ij},\\
P^{(3)}_{ij}(\hat n)&=-\sqrt{45/56}\,[S_{ik}v_{kj}+S_{jk}v_{ki}-\tfrac23\delta_{ij}S_{kl}v_{kl}],\\
P^{(4)}_{ij}(\hat n)&=\sqrt{175/32}\,S_{kl}v_{ijkl},\\
P^{(5)}_{ij}(\hat n)&=-\frac{i\sqrt5}{2}\epsilon_k(\varepsilon_{ikl}v_{lj}+\varepsilon_{jkl}v_{li}),\\
P^{(6)}_{ij}(\hat n)&=-\sqrt{15/2}\,v_{ij}.
\end{aligned}
$$

In $P^{(5)}$, $\epsilon_k$ is the spin polarisation of the already $C$-even PV channel. These are [@Baru:2019xnh] v2, App. B, in the bridged convention. In every entry below the stated incoming and outgoing projectors mean these explicit tensors at $\hat z$ and $\hat n'$, respectively; the outgoing one is conjugated. In particular the imaginary channel-5 projector must not be treated as real. The three contributions follow directly from

$$
q_iq_j=p^2\hat z_i\hat z_j-pp'(\hat z_i\hat n'_j+\hat n'_i\hat z_j)+p'^2\hat n'_i\hat n'_j.
$$

The $p^2$ term, the $pp'$ term and the $p'^2$ term below are whole contributions, including their momentum factors; their sum is the displayed polynomial.

### Entry 11: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(1)}(\hat z)$; outgoing projector: $P^{(1)}(\hat n')$.

The $p^2$ term: $- \frac{5 p^{2}}{3}$.

The $pp'$ term: $\frac{10 p p' x}{3}$.

The $p'^2$ term: $- \frac{5 p'^{2}}{3}$.

$\mathcal N_{11}(x;p^\prime,p)=- \frac{5 p^{2}}{3} + \frac{10 p p' x}{3} - \frac{5 p'^{2}}{3}$.

### Entry 12: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(2)}(\hat z)$; outgoing projector: $P^{(1)}(\hat n')$.

The $p^2$ term: $\frac{\sqrt{10} p^{2}}{3}$.

The $pp'$ term: $- \frac{2 \sqrt{10} p p' x}{3}$.

The $p'^2$ term: $\frac{\sqrt{10} p'^{2} (3 x^{2} - 1)}{6}$.

$\mathcal N_{12}(x;p^\prime,p)=\frac{\sqrt{10} p^{2}}{3} - \frac{2 \sqrt{10} p p' x}{3} + \frac{\sqrt{10} p'^{2} x^{2}}{2} - \frac{\sqrt{10} p'^{2}}{6}$.

### Entry 13: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(3)}(\hat z)$; outgoing projector: $P^{(1)}(\hat n')$.

The $p^2$ term: $- \frac{\sqrt{70} p^{2}}{3}$.

The $pp'$ term: $\frac{2 \sqrt{70} p p' x}{3}$.

The $p'^2$ term: $- \frac{\sqrt{70} p'^{2} (3 x^{2} - 1)}{6}$.

$\mathcal N_{13}(x;p^\prime,p)=- \frac{\sqrt{70} p^{2}}{3} + \frac{2 \sqrt{70} p p' x}{3} - \frac{\sqrt{70} p'^{2} x^{2}}{2} + \frac{\sqrt{70} p'^{2}}{6}$.

### Entry 14: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(4)}(\hat z)$; outgoing projector: $P^{(1)}(\hat n')$.

The $p^2$ term: $0$.

The $pp'$ term: $0$.

The $p'^2$ term: $0$.

$\mathcal N_{14}(x;p^\prime,p)=0$.

### Entry 15: $(\beta_1,\beta_2)=(3,2)$

$PV\to VV:\quad\mathcal N=(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)+(\boldsymbol A_2\cdot\boldsymbol q)(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(5)}(\hat z)$; outgoing projector: $P^{(1)}(\hat n')$.

The $p^2$ term: $- \sqrt{10} p^{2}$.

The $pp'$ term: $2 \sqrt{10} p p' x$.

The $p'^2$ term: $- \frac{\sqrt{10} p'^{2} (3 x^{2} - 1)}{2}$.

$\mathcal N_{15}(x;p^\prime,p)=- \sqrt{10} p^{2} + 2 \sqrt{10} p p' x - \frac{3 \sqrt{10} p'^{2} x^{2}}{2} + \frac{\sqrt{10} p'^{2}}{2}$.

### Entry 16: $(\beta_1,\beta_2)=(3,3)$

$PP\to VV:\quad\mathcal N=(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(6)}(\hat z)$; outgoing projector: $P^{(1)}(\hat n')$.

The $p^2$ term: $- \frac{\sqrt{30} p^{2}}{3}$.

The $pp'$ term: $\frac{2 \sqrt{30} p p' x}{3}$.

The $p'^2$ term: $- \frac{\sqrt{30} p'^{2} (3 x^{2} - 1)}{6}$.

$\mathcal N_{16}(x;p^\prime,p)=- \frac{\sqrt{30} p^{2}}{3} + \frac{2 \sqrt{30} p p' x}{3} - \frac{\sqrt{30} p'^{2} x^{2}}{2} + \frac{\sqrt{30} p'^{2}}{6}$.

### Entry 22: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(2)}(\hat z)$; outgoing projector: $P^{(2)}(\hat n')$.

The $p^2$ term: $\frac{5 p^{2} (3 x^{2} - 1)}{3}$.

The $pp'$ term: $- \frac{10 p p' x (3 x^{2} - 1)}{3}$.

The $p'^2$ term: $\frac{5 p'^{2} (3 x^{2} - 1)}{3}$.

$\mathcal N_{22}(x;p^\prime,p)=5 p^{2} x^{2} - \frac{5 p^{2}}{3} - 10 p p' x^{3} + \frac{10 p p' x}{3} + 5 p'^{2} x^{2} - \frac{5 p'^{2}}{3}$.

### Entry 23: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(3)}(\hat z)$; outgoing projector: $P^{(2)}(\hat n')$.

The $p^2$ term: $- \frac{5 \sqrt{7} p^{2} (3 x^{2} - 1)}{21}$.

The $pp'$ term: $\frac{5 \sqrt{7} p p' x (3 x^{2} + 1)}{21}$.

The $p'^2$ term: $- \frac{5 \sqrt{7} p'^{2} (3 x^{2} - 1)}{21}$.

$\mathcal N_{23}(x;p^\prime,p)=- \frac{5 \sqrt{7} p^{2} x^{2}}{7} + \frac{5 \sqrt{7} p^{2}}{21} + \frac{5 \sqrt{7} p p' x^{3}}{7} + \frac{5 \sqrt{7} p p' x}{21} - \frac{5 \sqrt{7} p'^{2} x^{2}}{7} + \frac{5 \sqrt{7} p'^{2}}{21}$.

### Entry 24: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(4)}(\hat z)$; outgoing projector: $P^{(2)}(\hat n')$.

The $p^2$ term: $\frac{\sqrt{35} p^{2} (3 x^{2} - 1)}{7}$.

The $pp'$ term: $- \frac{2 \sqrt{35} p p' x (5 x^{2} - 3)}{7}$.

The $p'^2$ term: $\frac{\sqrt{35} p'^{2} (35 x^{4} - 30 x^{2} + 3)}{28}$.

$\mathcal N_{24}(x;p^\prime,p)=\frac{3 \sqrt{35} p^{2} x^{2}}{7} - \frac{\sqrt{35} p^{2}}{7} - \frac{10 \sqrt{35} p p' x^{3}}{7} + \frac{6 \sqrt{35} p p' x}{7} + \frac{5 \sqrt{35} p'^{2} x^{4}}{4} - \frac{15 \sqrt{35} p'^{2} x^{2}}{14} + \frac{3 \sqrt{35} p'^{2}}{28}$.

### Entry 25: $(\beta_1,\beta_2)=(3,2)$

$PV\to VV:\quad\mathcal N=(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)+(\boldsymbol A_2\cdot\boldsymbol q)(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(5)}(\hat z)$; outgoing projector: $P^{(2)}(\hat n')$.

The $p^2$ term: $0$.

The $pp'$ term: $0$.

The $p'^2$ term: $0$.

$\mathcal N_{25}(x;p^\prime,p)=0$.

### Entry 26: $(\beta_1,\beta_2)=(3,3)$

$PP\to VV:\quad\mathcal N=(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(6)}(\hat z)$; outgoing projector: $P^{(2)}(\hat n')$.

The $p^2$ term: $\frac{5 \sqrt{3} p^{2} (3 x^{2} - 1)}{6}$.

The $pp'$ term: $- \frac{5 \sqrt{3} p p' x (3 x^{2} - 1)}{3}$.

The $p'^2$ term: $\frac{5 \sqrt{3} p'^{2} (3 x^{2} - 1)}{6}$.

$\mathcal N_{26}(x;p^\prime,p)=\frac{5 \sqrt{3} p^{2} x^{2}}{2} - \frac{5 \sqrt{3} p^{2}}{6} - 5 \sqrt{3} p p' x^{3} + \frac{5 \sqrt{3} p p' x}{3} + \frac{5 \sqrt{3} p'^{2} x^{2}}{2} - \frac{5 \sqrt{3} p'^{2}}{6}$.

### Entry 33: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(3)}(\hat z)$; outgoing projector: $P^{(3)}(\hat n')$.

The $p^2$ term: $- \frac{25 p^{2} (3 x^{2} - 1)}{21}$.

The $pp'$ term: $\frac{5 p p' x (51 x^{2} - 11)}{42}$.

The $p'^2$ term: $- \frac{25 p'^{2} (3 x^{2} - 1)}{21}$.

$\mathcal N_{33}(x;p^\prime,p)=- \frac{25 p^{2} x^{2}}{7} + \frac{25 p^{2}}{21} + \frac{85 p p' x^{3}}{14} - \frac{55 p p' x}{42} - \frac{25 p'^{2} x^{2}}{7} + \frac{25 p'^{2}}{21}$.

### Entry 34: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(4)}(\hat z)$; outgoing projector: $P^{(3)}(\hat n')$.

The $p^2$ term: $- \frac{2 \sqrt{5} p^{2} (3 x^{2} - 1)}{7}$.

The $pp'$ term: $\frac{4 \sqrt{5} p p' x (5 x^{2} - 3)}{7}$.

The $p'^2$ term: $- \frac{\sqrt{5} p'^{2} (35 x^{4} - 30 x^{2} + 3)}{14}$.

$\mathcal N_{34}(x;p^\prime,p)=- \frac{6 \sqrt{5} p^{2} x^{2}}{7} + \frac{2 \sqrt{5} p^{2}}{7} + \frac{20 \sqrt{5} p p' x^{3}}{7} - \frac{12 \sqrt{5} p p' x}{7} - \frac{5 \sqrt{5} p'^{2} x^{4}}{2} + \frac{15 \sqrt{5} p'^{2} x^{2}}{7} - \frac{3 \sqrt{5} p'^{2}}{14}$.

### Entry 35: $(\beta_1,\beta_2)=(3,2)$

$PV\to VV:\quad\mathcal N=(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)+(\boldsymbol A_2\cdot\boldsymbol q)(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(5)}(\hat z)$; outgoing projector: $P^{(3)}(\hat n')$.

The $p^2$ term: $\frac{5 \sqrt{7} p^{2} (3 x^{2} - 1)}{14}$.

The $pp'$ term: $- \frac{5 \sqrt{7} p p' x (3 x^{2} + 1)}{14}$.

The $p'^2$ term: $\frac{5 \sqrt{7} p'^{2} (3 x^{2} - 1)}{14}$.

$\mathcal N_{35}(x;p^\prime,p)=\frac{15 \sqrt{7} p^{2} x^{2}}{14} - \frac{5 \sqrt{7} p^{2}}{14} - \frac{15 \sqrt{7} p p' x^{3}}{14} - \frac{5 \sqrt{7} p p' x}{14} + \frac{15 \sqrt{7} p'^{2} x^{2}}{14} - \frac{5 \sqrt{7} p'^{2}}{14}$.

### Entry 36: $(\beta_1,\beta_2)=(3,3)$

$PP\to VV:\quad\mathcal N=(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(6)}(\hat z)$; outgoing projector: $P^{(3)}(\hat n')$.

The $p^2$ term: $\frac{5 \sqrt{21} p^{2} (3 x^{2} - 1)}{21}$.

The $pp'$ term: $- \frac{5 \sqrt{21} p p' x (3 x^{2} + 1)}{21}$.

The $p'^2$ term: $\frac{5 \sqrt{21} p'^{2} (3 x^{2} - 1)}{21}$.

$\mathcal N_{36}(x;p^\prime,p)=\frac{5 \sqrt{21} p^{2} x^{2}}{7} - \frac{5 \sqrt{21} p^{2}}{21} - \frac{5 \sqrt{21} p p' x^{3}}{7} - \frac{5 \sqrt{21} p p' x}{21} + \frac{5 \sqrt{21} p'^{2} x^{2}}{7} - \frac{5 \sqrt{21} p'^{2}}{21}$.

### Entry 44: $(\beta_1,\beta_2)=(2,2)$

$VV\to VV:\quad\mathcal N=-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)$.

Incoming projector: $P^{(4)}(\hat z)$; outgoing projector: $P^{(4)}(\hat n')$.

The $p^2$ term: $\frac{5 p^{2} (35 x^{4} - 30 x^{2} + 3)}{56}$.

The $pp'$ term: $- \frac{5 p p' x (5 x^{2} - 3)}{7}$.

The $p'^2$ term: $\frac{5 p'^{2} (35 x^{4} - 30 x^{2} + 3)}{56}$.

$\mathcal N_{44}(x;p^\prime,p)=\frac{25 p^{2} x^{4}}{8} - \frac{75 p^{2} x^{2}}{28} + \frac{15 p^{2}}{56} - \frac{25 p p' x^{3}}{7} + \frac{15 p p' x}{7} + \frac{25 p'^{2} x^{4}}{8} - \frac{75 p'^{2} x^{2}}{28} + \frac{15 p'^{2}}{56}$.

### Entry 45: $(\beta_1,\beta_2)=(3,2)$

$PV\to VV:\quad\mathcal N=(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)+(\boldsymbol A_2\cdot\boldsymbol q)(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(5)}(\hat z)$; outgoing projector: $P^{(4)}(\hat n')$.

The $p^2$ term: $\frac{\sqrt{35} p^{2} (35 x^{4} - 30 x^{2} + 3)}{14}$.

The $pp'$ term: $- \frac{4 \sqrt{35} p p' x (5 x^{2} - 3)}{7}$.

The $p'^2$ term: $\frac{2 \sqrt{35} p'^{2} (3 x^{2} - 1)}{7}$.

$\mathcal N_{45}(x;p^\prime,p)=\frac{5 \sqrt{35} p^{2} x^{4}}{2} - \frac{15 \sqrt{35} p^{2} x^{2}}{7} + \frac{3 \sqrt{35} p^{2}}{14} - \frac{20 \sqrt{35} p p' x^{3}}{7} + \frac{12 \sqrt{35} p p' x}{7} + \frac{6 \sqrt{35} p'^{2} x^{2}}{7} - \frac{2 \sqrt{35} p'^{2}}{7}$.

### Entry 46: $(\beta_1,\beta_2)=(3,3)$

$PP\to VV:\quad\mathcal N=(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(6)}(\hat z)$; outgoing projector: $P^{(4)}(\hat n')$.

The $p^2$ term: $- \frac{\sqrt{105} p^{2} (35 x^{4} - 30 x^{2} + 3)}{28}$.

The $pp'$ term: $\frac{2 \sqrt{105} p p' x (5 x^{2} - 3)}{7}$.

The $p'^2$ term: $- \frac{\sqrt{105} p'^{2} (3 x^{2} - 1)}{7}$.

$\mathcal N_{46}(x;p^\prime,p)=- \frac{5 \sqrt{105} p^{2} x^{4}}{4} + \frac{15 \sqrt{105} p^{2} x^{2}}{14} - \frac{3 \sqrt{105} p^{2}}{28} + \frac{10 \sqrt{105} p p' x^{3}}{7} - \frac{6 \sqrt{105} p p' x}{7} - \frac{3 \sqrt{105} p'^{2} x^{2}}{7} + \frac{\sqrt{105} p'^{2}}{7}$.

### Entry 55: $(\beta_1,\beta_2)=(1,2)$

$PV\to PV:\quad\mathcal N=-(\boldsymbol\epsilon\cdot\boldsymbol q)(\boldsymbol\epsilon^{\prime *}\cdot\boldsymbol q)$.

Incoming projector: $P^{(5)}(\hat z)$; outgoing projector: $P^{(5)}(\hat n')$.

The $p^2$ term: $0$.

The $pp'$ term: $\frac{5 p p' x (x - 1) (x + 1)}{2}$.

The $p'^2$ term: $0$.

$\mathcal N_{55}(x;p^\prime,p)=\frac{5 p p' x^{3}}{2} - \frac{5 p p' x}{2}$.

### Entry 56: $(\beta_1,\beta_2)=—$

$PP\to PV:\quad\mathcal N=0$.

Incoming projector: $P^{(6)}(\hat z)$; outgoing projector: $P^{(5)}(\hat n')$.

The $p^2$ term: $0$.

The $pp'$ term: $0$.

The $p'^2$ term: $0$.

$\mathcal N_{56}(x;p^\prime,p)=0$.

### Entry 66: $(\beta_1,\beta_2)=—$

$PP\to PP:\quad\mathcal N=0$.

Incoming projector: $P^{(6)}(\hat z)$; outgoing projector: $P^{(6)}(\hat n')$.

The $p^2$ term: $0$.

The $pp'$ term: $0$.

The $p'^2$ term: $0$.

$\mathcal N_{66}(x;p^\prime,p)=0$.

### Why the zeros vanish, and the reverse entries

Entry 14 requires $\Delta L=4$, while the spin numerator contains only a rank-two momentum tensor. Entry 25 vanishes already in spin space: $\delta_{ab}\mathcal N_{VV,PV;ab,c}=i\sqrt2\varepsilon_{cak}q_aq_k=0$. Entries 56 and 66 have no diagram because the Lagrangian has no $PP\phi$ vertex [@Zhang:2026iyr] v1, Eq. (68).

Only entries 24, 34, 44, 45, 46 have a nonzero $x^4$ coefficient. Reverse entries exchange $p$ and $p'$ and Hermitian-conjugate the species block; the offset pair changes $(3,2)\to(4,2)$ and $(3,3)\to(4,4)$. In particular $\nu_4(p,p')=\nu_3(p',p)$, whereas reusing $\nu_3$ at unequal momenta breaks time reversal for unequal heavy masses.

## 5. Angular moments through order four

Following [@Zhang:2026iyr] v1, Eqs. (D13)–(D15), define

$$
\mathcal A_\phi=p^2+p'^2+m_\phi^2,\quad\mathcal B=2pp',\quad E_\phi=\sqrt{\mathcal A_\phi-\mathcal Bx},\quad E_\pm=\sqrt{\mathcal A_\phi\pm\mathcal B}.
$$

For one ordering define $M_m(\nu)=\int_{-1}^1x^m dx/[2E_\phi(E_\phi+\nu)]$. Substituting $dx=-2E_\phi dE_\phi/\mathcal B$ gives

$$
M_m(\nu)=\mathcal B^{-m-1}\int_{E_-}^{E_+}\frac{(\mathcal A_\phi-E_\phi^2)^m}{E_\phi+\nu}dE_\phi,\qquad
\Delta_m^{(\beta_1\beta_2)}=M_m(\nu_{\beta_1})+M_m(\nu_{\beta_2}).
$$

Define $L(\nu)=\log[(E_++\nu)/(E_-+\nu)]$ and the finite closed forms

$$
J_0(\nu)=L(\nu),\qquad J_j(\nu)=(-\nu)^jL(\nu)+\sum_{h=0}^{j-1}\frac{(-\nu)^h}{j-h}(E_+^{j-h}-E_-^{j-h}),\quad j=1,\ldots,8.
$$

These are the integrals of $E_\phi^j/(E_\phi+\nu)$. All five moments are explicitly

$$
\begin{aligned}
\Delta_0^{(\beta_1\beta_2)}&=\sum_{\beta\in(\beta_1,\beta_2)}J_0/\mathcal B,\\
\Delta_1^{(\beta_1\beta_2)}&=\sum_{\beta\in(\beta_1,\beta_2)}(\mathcal A_\phi J_0-J_2)/\mathcal B^2,\\
\Delta_2^{(\beta_1\beta_2)}&=\sum_{\beta\in(\beta_1,\beta_2)}(\mathcal A_\phi^2J_0-2\mathcal A_\phi J_2+J_4)/\mathcal B^3,\\
\Delta_3^{(\beta_1\beta_2)}&=\sum_{\beta\in(\beta_1,\beta_2)}(\mathcal A_\phi^3J_0-3\mathcal A_\phi^2J_2+3\mathcal A_\phi J_4-J_6)/\mathcal B^4,\\
\Delta_4^{(\beta_1\beta_2)}&=\sum_{\beta\in(\beta_1,\beta_2)}(\mathcal A_\phi^4J_0-4\mathcal A_\phi^3J_2+6\mathcal A_\phi^2J_4-4\mathcal A_\phi J_6+J_8)/\mathcal B^5.
\end{aligned}
$$

Every $J_j$ in a summand is evaluated at $\nu_\beta$. The sum counts two orderings with multiplicity, even for equal offsets. The first two expressions reproduce Eq. (D15). These formulas assume a domain free of denominator zeros and consistent square-root/logarithm branches, not continuation across a three-body cut.

### Cancellation and the actual small-product implementation

The expression of order $m$ divides a cancellation-prone difference by $\mathcal B^{m+1}$. Set $f_\nu(y)=[2\sqrt y(\sqrt y+\nu)]^{-1}$. The local Taylor series is

$$
M_m(\nu)=\sum_{\ell=0}^\infty\frac{(-\mathcal B)^\ell}{\ell!}f_\nu^{(\ell)}(\mathcal A_\phi)\frac{1+(-1)^{m+\ell}}{m+\ell+1}.
$$

Here $\ell$ labels Taylor order, not angular power. For even $m$ it starts $2f_\nu/(m+1)+\mathcal B^2f_\nu''/(m+3)$; for odd $m$ it starts $-2\mathcal B f_\nu'/(m+2)$. At exactly zero,

$$
M_m(\nu)|_{\mathcal B=0}=\frac{1+(-1)^m}{m+1}\frac1{2\sqrt{\mathcal A_\phi}(\sqrt{\mathcal A_\phi}+\nu)}.
$$

**The package does not evaluate a nonzero-product Taylor series.** `src/common/ExchangeMoments.jl:9–13` implements the exact zero-product parity formula. `src/models/BOchiEFT/exchange.jl:76–85` treats each ordering separately. Below $|\mathcal B|/\max(|\mathcal A_\phi|,|\nu|^2,10^{-30}\,\mathrm{GeV}^2)<0.3$, real momenta use 64-node Gauss–Legendre quadrature; complex momenta use a recurrence with input-dependent guard bits and at least 256-bit precision (`ExchangeMoments.jl:41–57`). Above the threshold it uses the ordinary recurrence. The $1^{++}$ threshold remains 0.06 (`exchange.jl:18–23`). The public four-moment `topt_angular_moments` wrapper has its own 0.06 switch and high-precision large-product branch; `tc_moments` does not call that wrapper. Explicit `angular_method=:quadrature` instead uses the caller-selected rule. Paths here are relative to `code/HadronDynamics.jl/`.

## 6. Limits and HQSS

The projected spin numerator has units GeV$^2$, angular moments GeV$^{-2}$ and $g_b^2/F_\pi^2$ GeV$^{-2}$, so $V$ has units GeV$^{-2}$.

1. **Zero momentum.** At $p=0$ or $p'=0$ denominators are independent of $x$. Odd powers integrate to zero and the integrals of $1,x^2,x^4$ are $2,2/3,2/5$. Every entry with a zero-momentum $D$ or $G$ leg vanishes. For example $\mathcal N_{16}|_{p'=0}=-\sqrt{30}p^2/3$ is finite (outgoing $S$ wave), whereas at $p=0$ its integral is $\sqrt{30}p'^2[2/6-(2/3)/2]=0$. Entry 44 at $p'=0$ integrates to $5p^2[35(2/5)-30(2/3)+3(2)]/56=0$.
2. **Strict HQSS.** Set every heavy mass to $\bar m=(m_B+3m_{B^*})/4$. All offsets coincide and each denominator sum is $2D$. The bridged 9j/6j rotation gives blocks of sizes $2,1,2,1$ for heavy spin and light-cloud angular momentum $(s_H,j_\ell)=(1,1),(1,2),(1,3),(0,2)$. The $(1,1)$ **potential** block equals that of $1^{++}$: compare $\mathcal N^{(2^{++})}/5$ with $\mathcal N^{(1^{++})}/3$, not bare traces. The legacy exact contraction aid `notes/04-ome-2pp-contractions.py` asserts the polynomial block statement. `checks/hqss_2pp.py` tests package potentials with a Wigner-symbol rotation independent of the projectors, using `literature/Bruschini:2023zkb/bridge.md` and [@Bruschini:2023zkb] v3, Table 2.
3. **Static new transition.** Dropping recoil and $E$ only for this limit gives $\nu_3=\nu_4=-\Delta m$, where $\Delta m=m_{B^*}-m_B$. Thus $2D_3=2D_4=[E_\phi(E_\phi-\Delta m)]^{-1}$. Reciprocity is automatic there; full recoil makes the time-reversal check sensitive to a wrong $D_3\leftrightarrow D_4$ swap.

## 7. Code map

Paths below are relative to `code/HadronDynamics.jl/`; `projection.jl` and `exchange.jl` are in `src/models/BOchiEFT/`.

| Paper symbol | Package function or variable | Relation and source |
|---|---|---|
| $\alpha=1,\ldots,6$, $J=2$ | `channels_2pp()` | Canonical order, `J=2`, `order=4`; `projection.jl:46–54` |
| $p',p$ | `pout,pin` | Outgoing first; `projection.jl:63–64,86–88` |
| $\mathcal N^{(m)}$ | `_coefficients_2pp`, `projection_coefficients` | Package stores $c_m=-\mathcal N^{(m)}/(2J+1)=-\mathcal N^{(m)}/5$; lower triangle swaps momenta; `projection.jl:63–64,86–87` |
| $(\nu_{\beta_1},\nu_{\beta_2})$ | `_ome_intermediates`, `tc_alphas` | Intermediate pairs at `(pout,pin)` give $\omega_X(p')+\omega_Y(p)-M$; VV $\leftarrow$ PV enumerates $(2,3)$, equivalent to $(3,2)$; `exchange.jl:1–13,32–57` |
| $\mathcal A_\phi,\mathcal B$ | `A,B` | `pin^2+pout^2+mphi^2`, `2pin*pout`; `exchange.jl:60–61` |
| $M_m(\nu)$ | `_sd_one_moments_recurrence`, `_sd_one_moments_quad`, `_sd_one_moments_big` | Single-ordering arrays, index `m+1`; argument `alpha` is $\nu$, not channel index; `src/common/ExchangeMoments.jl:9–72` |
| $\Delta_m^{(\beta_1\beta_2)}$ | `tc_moments`, `result[m+1]` | $M_m(\nu_{\beta_1})+M_m(\nu_{\beta_2})$, repeated offsets included; `exchange.jl:60–87` |
| $V(p',p;m_\phi)$ | `tc_vphi` | $-g_b^2\sum_m c_m\Delta_m/(8F_\pi^2)=g_b^2\sum_m\mathcal N^{(m)}\Delta_m/(40F_\pi^2)$; `exchange.jl:90–94` |
| $V^{\rm(OME)}$ | `ome_potential`, callable `OMEInteraction` | $3V(m_\pi)+V(m_\eta)/3$ at defaults; `exchange.jl:96–118` |

The map is verified by reading dispatch, intermediate species, offset arithmetic, the single-ordering integrand/recurrence, array accumulation and final prefactors at the stated lines. The executed comparison recorded in §8 independently checks the $-5$ relation. Diagnostic switches preserve inherited semantics: channel 1 always keeps both mesons, `tensor_scale` affects all other entries, and `third_scale` species-changing entries (`exchange.jl:99–112`). Defaults do not alter full OME; no package coefficient convention is changed.

## 8. Independent checks


All three checks call the public seam `OMEInteraction(cfg; channels=channels_2pp())` with expectations and tolerances frozen before this derivation (commits `c992b60`, `e49af82`).

| Check | Green result (2026-10-29) |
|---|---|
| `checks/projection_2pp.py`: brute-force Eq. (80), 21 entries, $\pi$ and $\eta$, 3 seeded samples | 141 PASS: 12 projector Gram assertions, 3 below-$B\bar B\pi$ samples, 126 entries; largest residual $2.9\times10^{-12}$ GeV$^{-2}$, largest order-12/18 change $2.7\times10^{-15}$ GeV$^{-2}$ (tolerance $5\times10^{-9}\max(1,|V|)$) |
| `checks/time_reversal_2pp.jl`: $V_{\alpha'\alpha}(p',p)=V_{\alpha\alpha'}(p,p')$, 21 entries, 3 points, $\pi$ and $\eta$ | 126 PASS, largest residual $6.7\times10^{-16}$ GeV$^{-2}$ |
| `checks/hqss_2pp.py`: 9j/6j rotation, block structure, $J_\ell=1$ block vs $1^{++}$ | 15 PASS; forbidden entries $\le1.1\times10^{-15}$, $J_\ell=1$ blocks equal to $9.7\times10^{-14}$ GeV$^{-2}$ |

The exact-arithmetic table and the three numerical routes agree. The projection route shares the [@Baru:2019xnh] v2 projectors and the Eq. (68) spin numerators of Sec. 1, including the $+q_aq_b$ of $B\bar B\leftrightarrow B^*\bar B^*$, with this derivation, so it tests the contraction and the denominators, not that sign. The HQSS route shares no projector tensor or numerator; it uses the bridged channel phases $D_2=\operatorname{diag}(1,1,1,1,1,-1)$, so it tests the sign of the $B\bar B\leftrightarrow B^*\bar B^*$ entries relative to the bridged $B\bar B({}^1D_2)$ projector phase. The absolute sign rests on the Sec. 1 argument, which agrees with the bridge's independent vertex-by-vertex argument and with followup.tex Eq. (5).

Further recorded runs (2026-10-29):

- For $2^{++}$ the real-momentum small-product branch uses 64-node quadrature below $|\mathcal B|/\max(|\mathcal A_\phi|,|\nu|^2,10^{-30}\,\mathrm{GeV}^2)=0.3$. In the recorded comparison with a 256-bit recurrence at $\mathcal A_\phi=1\,\mathrm{GeV}^2$, $\nu\in\{0.5,0.01,-0.3,-0.8\}$, the quadrature's relative error stays below $4\times10^{-15}$ up to that boundary; the ordinary recurrence's relative moment error is about $1.3\times10^{-12}$ there. The $1^{++}$ switch is 0.06.
- The committed double-solid-angle samples exercise the quadrature branch. The ordinary-recurrence branch is compared with an independent 256-node angular rule in the package test; the low-momentum comparison alone does not establish high-momentum double-solid-angle convergence.

### New projected-spin-numerator check

`checks/projected_spin_numerator_2pp.py` checks regenerated-table byte identity; all 21 entries and five powers obeying $\mathcal N^{(m)}=-5c_m$ and matching unordered offsets; reduced angular moments against independent double-solid-angle Eq. (80) quadrature for pion and eta. Seed 80429, three below-threshold samples, coefficient tolerance $2\times10^{-13}$; potential agreement/convergence tolerance $5\times10^{-9}\max(1,|V|)$ GeV$^{-2}$; double-sphere orders 12/18 and moment orders 64/96.

Offset pairs are compared unordered because $D_{\beta_1}+D_{\beta_2}$ is symmetric in the two labels.

- Recorded green: all three groups PASS; package error $2.78\times10^{-17}$, offsets match; maximum scaled potential error $8.1\times10^{-15}$, quadrature change $9.26\times10^{-14}$, all samples below threshold.

These are recorded runs, not newly rerun results. Table identity is a consistency guard; double-solid-angle quadrature independently checks angular reduction and prefactor, not the shared spin-numerator sign. Neither replaces the sign argument or Wigner-based HQSS check.
