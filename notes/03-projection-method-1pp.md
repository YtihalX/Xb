# 03: The $1^{++}$ OME projection, worked through

Source throughout: [@Zhang:2026iyr] v1, Eqs. (72)–(81), (D1)–(D11), from `literature/Zhang:2026iyr/src/Xb.tex`, not the finished root paper. Channel order is $1=B\bar B^*({}^3S_1)$, $2=B\bar B^*({}^3D_1)$, $3=B^*\bar B^*({}^5D_1)$; the row is outgoing. This note uses the agreed projectors without a channel rephasing.

## 1. Separate the energy denominator from the spin algebra

Put $r=p'$, $x=\boldsymbol n'\cdot\boldsymbol n$, and $\boldsymbol q=p\boldsymbol n-r\boldsymbol n'$. Then $q^2=p^2+r^2-2prx$ and $\omega=\sqrt{p^2+r^2+m_\phi^2-2prx}$. In the canonical notation the paper's $E_H(p)$ is $\omega_H(p)=m_H+p^2/(2m_H)$ and its TOPT $\mu_\beta$ is $\nu_\beta$, not a reduced mass. With $M=m_B+m_{B^*}+E$,

$$
\begin{aligned}
\nu_1&=-\Delta m+(p^2+r^2)/(2m_B)-E,\\
\nu_2&=+\Delta m+(p^2+r^2)/(2m_{B^*})-E,\\
\nu_3&=p^2/(2m_B)+r^2/(2m_{B^*})-E,\\
\nu_4&=r^2/(2m_B)+p^2/(2m_{B^*})-E.
\end{aligned}
$$

The $-i0$ is implicit; the numerical comparison is below all three-body thresholds and has no singular denominator. Define

$$
D_\beta(x)=\frac1{2\omega(\omega+\nu_\beta)},\qquad
\Delta_k^{(ab)}=\int_{-1}^1dx\,x^k(D_a+D_b).
$$

The four species blocks use $(12)$ for PV→PV, $(23)$ for PV→VV, $(24)$ for VV→PV, and $(22)$ for VV→VV [@Zhang:2026iyr] v1, Eqs. (72)–(77), (D11). The repeated $(22)$ means **two** identical time orderings, not one. `tc_alphas` returns exactly these two offsets: its PV→VV branch is `(nu2,nu3)`, its reverse swaps $p,r$ to obtain `(nu2,nu4)`, and VV→VV returns `(nu2,nu2)`. The absolute-energy implementation subtracts `mB+mBstar+E` from the intermediate two-meson energy; it does not introduce a second energy-origin convention.

## 2. Cartesian projectors and the double angular integral

Write $Q_{ab}(\boldsymbol n)=n_an_b-\delta_{ab}/3$ and retain the total-$J$ polarisation index $i$ explicitly. Eq. (D1) gives matrices with spin-state rows and total-$J$ columns:

$$
P^{(1)}_{ai}=\delta_{ai},\qquad
P^{(2)}_{ai}=-\frac3{\sqrt2}Q_{ai},\qquad
P^{(3)}_{ab,i}=-\frac{\sqrt3}{2}i
 [\varepsilon_{iak}Q_{kb}+\varepsilon_{ibk}Q_{ka}].
$$

The trace subtraction in the spin-2 pair vanishes against $\varepsilon_{ijk}Q_{kj}$, but is not a change of the projector. Eq. (80) is

$$
V_{a b}=\frac13\int\frac{d\Omega'}{4\pi}\frac{d\Omega}{4\pi}
 \sum_{\sigma',\sigma,i}P^{(a)*}_{\sigma'i}(\boldsymbol n')
 V_{\sigma'\sigma}(\boldsymbol q)P^{(b)}_{\sigma i}(\boldsymbol n).
$$

After the spin sums the integrand is a rotational scalar. Thus the angular average of any remaining function of $x$ is $\tfrac12\int_{-1}^1dx$. This factor $1/2$, together with the vertex factor $g_b^2/(4F_\pi^2)$, accounts for the convenient common prefactor $-g_b^2/(8F_\pi^2)$ below. No extra $4\pi$ belongs in the projected potential.

For example the S–S contraction is $q_aq_b\delta_{ai}\delta_{bi}/3=q^2/3$, so

$$V_{11}=-\frac{g_b^2}{24F_\pi^2}[(p^2+r^2)\Delta_0^{(12)}-2pr\Delta_1^{(12)}],$$

which is (D2). For the S–D contraction, use

$$
\boldsymbol q\cdot Q(\boldsymbol n)\cdot\boldsymbol q
=(p-rx)^2-\frac13(p^2+r^2-2prx).
$$

The spin average gives $-1/\sqrt2$ times this expression. Consequently its polynomial is $\sqrt2(-2p^2+r^2)/6+2\sqrt2prx/3-\sqrt2r^2x^2/2$, reproducing (D3). Transposition interchanges $p,r$, not the meaning of the incoming argument.

For two D projectors one repeatedly uses $\operatorname{tr}(Q'Q)=x^2-1/3$, $\boldsymbol n'\cdot\boldsymbol q=px-r$, $\boldsymbol n\cdot\boldsymbol q=p-rx$, and $\varepsilon_{ijk}\varepsilon_{ilm}=\delta_{jl}\delta_{km}-\delta_{jm}\delta_{kl}$. For a VV projector retain its factor $i$ until after complex conjugation of the outgoing projector. Dropping that conjugation or reversing only one Levi-Civita tensor changes mixed-channel signs.

### Completing the spin contractions (not just reading off App. D)

Remove the common $g_b^2/(4F_\pi^2)$ and the appropriate $D_\beta+D_\gamma$ from the 3D potential, calling the remaining spin matrix $N$. Define $R_{ac}=\varepsilon_{cak}q_k$. Eqs. (72)–(75) then read

$$
\begin{aligned}
N_{\rm PV,PV;ac}&=-q_aq_c,\\
N_{\rm VV,PV;ab,c}&=\frac{i}{\sqrt2}(R_{ac}q_b+R_{bc}q_a),\\
N_{\rm PV,VV}&=N_{\rm VV,PV}^{\dagger},\\
N_{\rm VV,VV;ab,cd}&=R_{ac}R_{bd}.
\end{aligned}
$$

The last plus sign is the product of the minus in (75) and $i^2$ from its two $\boldsymbol A$'s; the repeated denominator is still $2D_2$. Let $T_{ab}=\tfrac13\operatorname{Tr}[P_a^\dagger N P_b]$ after the spin sums. Then $c_{ab}(x)=-T_{ab}(x)$, because the remaining solid-angle average gives $1/2$. The following contractions complete the independent steps.

For D–D within PV, multiplying the two $Q$ tensors before expanding gives

$$
T_{22}=-\frac32\boldsymbol q\cdot Q(\boldsymbol n)Q(\boldsymbol n')\cdot\boldsymbol q
=-\frac32\left[
x(p-rx)(px-r)-\frac{(p-rx)^2+(px-r)^2}{3}+\frac{q^2}{9}
\right].
$$

Expansion gives $T_{22}=(p^2+r^2)/3-prx/6-(p^2+r^2)x^2+3prx^3/2$. Thus $-T_{22}$ is exactly the 22 row below and yields every term of (D6).

For S–VV, the two symmetric terms in $P_3$ and the two meson-line terms in $N$ give, after contracting $\varepsilon\varepsilon$,

$$
T_{13}=-\frac1{\sqrt6}
\left[2p^2-r^2-4prx+3r^2x^2\right].
$$

Its sign includes the conjugation in $N_{\rm PV,VV}$; changing the sign of $P_3$ reverses this entire result. Then $-T_{13}$ yields $V_{13}=-g_b^2[ (2p^2-r^2)\Delta_0^{(24)}-4pr\Delta_1^{(24)}+3r^2\Delta_2^{(24)}]/(8\sqrt6F_\pi^2)$, namely (D4).

For D–VV, the extra incoming or outgoing $Q$ can be reduced with the same identities as for $T_{22}$. A useful unexpanded form is

$$
T_{23}=\frac{\sqrt3}{6}
\left[(p^2+r^2)(1-3x^2)+prx(1+3x^2)\right].
$$

The terms proportional to $p^2$ and $r^2$ follow from the two equal-vector-spin contractions, while the cross terms retain one factor $x$ or $x^3$. Multiplying by $g_b^2/(8F_\pi^2)$ and integrating produces the four positive-prefactor bracket terms of (D7). The denominator is $(24)$ for outgoing PV, incoming VV, and becomes $(23)$ on reversing the process; the numerator is symmetric in $p,r$ but those two denominators need not be equal at fixed unequal momenta.

Finally the two VV projectors contract the two antisymmetric $R$ matrices to

$$
T_{33}=-\frac{pr}{2}x(1-x^2).
$$

The pure $p^2$ and $r^2$ pieces cancel, leaving only the odd first and third moments. Thus $V_{33}=-g_b^2pr(\Delta_1^{(22)}-\Delta_3^{(22)})/(16F_\pi^2)$ as in (D10), including its factor two from the two identical offsets. The remaining 21,31,32 entries follow by Hermitian conjugation of the 3D matrices and exchanging the two integration variables: $V_{ba}(r,p)=V_{ab}(p,r)$. This derives (D5),(D8),(D9), including the $\nu_4(r,p)=\nu_3(p,r)$ interchange rather than an assumed equality at fixed momenta.

## 3. Every entry as angular moments, and the package comparison

Write $V_{ab}=-g_b^2/(8F_\pi^2)\sum_{k=0}^3c_{ab,k}\Delta_k^{(\beta\gamma)}$. Collecting the contractions above gives the following coefficients. Independently collecting the printed (D2)–(D10) under the same common prefactor gives every identical sign and numerical factor; zero entries are explicit.

| Entry | $(\beta\gamma)$ | $c_0$ | $c_1$ | $c_2$ | $c_3$ | Source |
|---|---|---|---|---|---|---|
| 11 | 12 | $(p^2+r^2)/3$ | $-2pr/3$ | $0$ | $0$ | (D2) |
| 12 | 12 | $\sqrt2(-2p^2+r^2)/6$ | $2\sqrt2pr/3$ | $-\sqrt2r^2/2$ | $0$ | (D3) |
| 13 | 24 | $\sqrt6(2p^2-r^2)/6$ | $-2\sqrt6pr/3$ | $+\sqrt6r^2/2$ | $0$ | (D4) |
| 21 | 12 | $c_{12,0}(p,r)$ | $c_{12,1}(p,r)$ | $c_{12,2}(p,r)$ | $0$ | (D5) |
| 22 | 12 | $-(p^2+r^2)/3$ | $pr/6$ | $p^2+r^2$ | $-3pr/2$ | (D6) |
| 23 | 24 | $-\sqrt3(p^2+r^2)/6$ | $-\sqrt3pr/6$ | $+\sqrt3(p^2+r^2)/2$ | $-\sqrt3pr/2$ | (D7) |
| 31 | 23 | $c_{13,0}(p,r)$ | $c_{13,1}(p,r)$ | $c_{13,2}(p,r)$ | $0$ | (D8) |
| 32 | 23 | $c_{23,0}(p,r)$ | $c_{23,1}(p,r)$ | $c_{23,2}(p,r)$ | $c_{23,3}(p,r)$ | (D9) |
| 33 | 22 | $0$ | $pr/2$ | $0$ | $-pr/2$ | (D10) |

In the transpose rows, $c_{ab,k}(p,r)$ means evaluate the polynomial with outgoing momentum $p$ and incoming momentum $r$; all other rows use outgoing $r$ and incoming $p$.

`projection_coefficients(out,in,pout,pin)` returns four coefficients in the order $x^0,x^1,x^2,x^3$. `tc_moments` returns the four $\Delta_k$ for the offsets selected above. `tc_vphi` contracts these vectors with $-g_b^2/(8F_\pi^2)$. Its analytic moment implementation changes variables $x\to\omega=\sqrt{A-Bx}$; then $dx=-2\omega\,d\omega/B$, cancelling the $2\omega$ in $D_\beta$ and leaving integrals of $(A-\omega^2)^k/(\omega+\nu_\beta)$. This explains why polynomial recurrence and logarithms suffice. For small $B$ the implementation avoids cancellation through its small-$B$ moment route, rather than dividing ill-conditioned differences by $B^{k+1}$.

The package and the coefficient table use the printed (D1) phase. All nine entries agree with (D2)–(D10) and independent angular integration.

## 4. Independence and discrepancy protocol

`checks/_projection.py` builds the spin matrices of (72)–(75) directly from $\boldsymbol A=i(\boldsymbol\epsilon\times\boldsymbol\epsilon'^*)/\sqrt2$, contracts the Cartesian (D1) projectors, and integrates **both** solid angles numerically. Its projector arrays and species-dependent potential callback can be replaced for the six-channel $2^{++}$ basis without importing any analytic partial-wave coefficients. The energy-offset helper takes the actual two intermediate masses and absolute energy, so a future PP↔VV entry can supply its shared mixed-species intermediate energy without assuming the external channel species.

The numerical route isolates each meson by calling `tc_vphi(...,mphi)` and applying $3$ or $1/3$ itself. `OMEInteraction(exchange=:pion|:eta)` is unsuitable here: the package intentionally retains both mesons in S–S.

The seeded numerical points use independent uniform $p,r\in[0.035,0.15]$ GeV and $E\in[-0.09,-0.015]$ GeV (seed 80301), fixed in the committed check. This low-momentum range keeps the two-solid-angle quadrature well converged at the predetermined orders without angular singularities; it is not a high-momentum or threshold-singularity stress test. The analytic contraction and limiting arguments, rather than the three random samples alone, establish the polynomial identity. Shared mistakes in the input 3D potentials or projectors would not be caught by numerical agreement alone; the separate pinned-source comparison is therefore essential.

Conventions aligned before probing: natural GeV units, $g_b,F_\pi$ taken from the same package input, no Fourier transform, Eq. (80)'s spin and angular averages, incoming/outgoing ordering, $\boldsymbol q$ bilinear sign invariance, the C-even PV combination, full recoil and mass splitting, and absolute energy $M=m_B+m_{B^*}+E$. Projector signs are exactly (D1), not adjusted to fit the code.

## 5. Independent comparison

The printed-D1 comparison gives 54 passing entries. The largest analytic residual is $4.67\times10^{-13}$ GeV$^{-2}$ and the order-12/order-18 quadrature change is at most $1.50\times10^{-13}$ GeV$^{-2}$. These recorded results concern the projection comparison, not a full-suite test claim.

## 6. Dimensions and controlled limiting cases

The agreed entries used here are CONVENTIONS "Units", "Axial coupling and OME normalisation", "Partial-wave projectors", "C-parity phase", "Angular-momentum phases", "Binding energy and meson energies" and "Reduced masses and TOPT energy offsets"; GLOSSARY "Full OME" means no static or recoil approximation in the main result. $D_\beta$ and every $\Delta_k$ have dimension GeV$^{-2}$, $c_k$ has GeV$^2$, and $g_b^2/F_\pi^2$ has GeV$^{-2}$, giving $V$ dimension GeV$^{-2}$.

Two limiting arguments check the collected result independently of its numerical samples:

1. If either radial momentum vanishes, the denominator becomes independent of $x$. Integrating the D-wave polynomials uses $\int_{-1}^1x^{2n+1}dx=0$, $\int_{-1}^1dx=2$, $\int_{-1}^1x^2dx=2/3$. Every entry with the zero-momentum D-wave leg vanishes; the 22 and 23 polynomials reduce to multiples of $1-3x^2$, and 33 is proportional to $pr$. The S–S entry remains finite. At $p=r=0$ the derivative-vertex numerator vanishes in every entry. This also checks the removable $B=2pr=0$ limit without using the package recurrence.
2. In the strict HQSS limit all offsets coincide, so the denominator is common to every entry. The numerator table gives $c_{13}=-\sqrt3\,c_{12}$ and $2c_{23}=\sqrt3(c_{22}-c_{33})$ coefficient by coefficient, hence the two projected-potential identities stated in [@Zhang:2026iyr] v1, App. D after Eq. (D14). Separately, dropping recoil and $E$ only for the static-limit argument gives $\nu_1=-\Delta m$, $\nu_2=+\Delta m$, and $D_1+D_2=[q^2+m_\phi^2-(\Delta m)^2]^{-1}$ as in that reference, v1, App. C. This limit is a check, not a replacement for full OME.
