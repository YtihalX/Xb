#import "@preview/touying:0.8.0": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9", config-info(
  title: [Towards Born-Oppenheimer chiral effective field theory],
  author: [Yu Zhang],
  institution: [Institute of Theoretical Physics, Chinese Academy of Sciences \
    University of Chinese Academy of Sciences],
))
#set text(font: "New Computer Modern", size: 18pt, lang: "en")


#title-slide[
  = Towards Born-Oppenheimer chiral effective field theory

  #v(2em)

  Yu Zhang#super[1,2]#h(1em)
  Feng-Kun Guo#super[1,2,3]#h(1em)
  Christoph Hanhart#super[4]#h(1em)
  Alexey Nefediev#super[5]#h(1em)
  Paul Pütz#super[6]

  #v(1em)

  #text(size: 12pt)[
    #super[1]Institute of Theoretical Physics, Chinese Academy of Sciences, Beijing 100190, China \
    #super[2]School of Physical Sciences, University of Chinese Academy of Sciences, Beijing 100049, China \
    #super[3]Southern Center for Nuclear-Science Theory (SCNT), Institute of Modern Physics, Chinese Academy of Sciences, Huizhou 516000, China \
    #super[4]Institute for Advanced Simulation and Cluster of Excellence "Color meets Flavor", Forschungszentrum Jülich, D-52425 Jülich, Germany \
    #super[5]Helmholtz-Institut für Strahlen- und Kernphysik, Universität Bonn, 53115 Bonn, Germany \
    #super[6]Technical University of Munich, TUM School of Natural Sciences, Physics Department, 85748 Garching, Germany
  ]
]

== BO$chi$EFT approach to ordinary and exotic hadrons
Main sources of information on hadronic states:
- #text(fill: blue)[Lattice QCD] $->$ First principle calculations of static interquark potentials, including string breaking effects $->$ input for #text(fill: rgb("#FF6600"))[short-range physics]
- #text(fill: blue)[High-energy experiment] $->$ Line shapes and branching fractions in terms of hadronic states $->$ input for #text(fill: rgb("#FF6600"))[long-range physics]

#text(fill: red)[*Problem: How to incorporate both sources of information in a single approach?*]

#text(fill: blue)[BOEFT] (Braaten, Brambilla, et al.): Coupled Schrödinger equations in coordinate space
- #text(fill: rgb("#FF6600"))[Pro:] Direct correspondence to lattice potentials $->$ short-range physics naturally captured
- #text(fill: rgb("#FF6600"))[Con:] Missing connection to hadronic degrees of freedom $->$ long-range physics parametrised

#text(fill: blue)[BOχEFT]: Coupled Lippmann-Schwinger equations in momentum space:
- #text(fill: rgb("#FF6600"))[Pro:] Long-range physics naturally captured, including multibody effects and exchanges
- #text(fill: rgb("#FF6600"))[Con:] Connection to short-range physics is nontrivial (comes as chiral expansion in $p^2/Lambda_chi^2$)
#text(fill: red)[*Hope: Merge both approaches to unified systematically improvable method*]

== Proof-of-concept BO$chi$EFT calculation at LO
Scattering of $B macron(B)^*$system with $J^(P C) = 1^(+ +)$ via potential
$ V = V^"(OME)" + sum_(n = 1)^N V_n^((macron(b) b)) + C(Lambda, N) $
- #text(fill: blue)[_s_-channel exchange of bottomonium states] $->$ potential #text(fill: red)[$V^((macron(b) b))$]:\ Parameters of interquark interaction and strength of transition $macron(b)b ->B macron(B)^*$ can be extracted from lattice-QCD calculations
#v(0.5em)
- #text(fill: blue)[_t_-channel meson exchanges] $->$ potential #text(fill: red)[$V^"(OME)"$]:\ No free parameters
#v(0.5em)
- #text(fill: blue)[Short-range counterterm] $->$  #text(fill: red)[$C$]:\ Absorbs all neglected effects
#v(0.5em)
Remaining free parameters can be fixed to the experimental spectrum of $chi_(b 1)$ bottomonia

== Short-range physics: bottomonium states
#text(fill: blue)[Schrödinger equation] with the LO static, spin-independent, colour-singlet Cornell potential:
$
  lr([2m_b - 1/m_b nabla^2 + V(r)])Psi^((macron(b)b)) = M^((macron(b)b))Psi^((macron(b)b)),quad quad
  V(r) = V_0 + sigma r + gamma/r
$

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 1em,
  align: horizon,
  [
    - Lattice QCD (Bulava et al. 2024): \ #text(fill: red)[$sigma = 0.198 op("GeV")^2$], #text(fill: red)[$gamma = -0.434$]
    - $V_0$: global offset $->$ fitted
    - $m_b = 4.534 op("GeV")$, typical quark-model value
    - $1^(++)$ states $[macron(b)b]_1(n P)$: \ $Psi_(n, L=1)^((macron(b)b))(bold(r)) = Y_(1m)(hat(bold(r)))R_(1n)(r)$
    - At LO they couple only to $S$-wave $B macron(B)^*$
  ],
  [
    Physical state:
    $
      lr(bar.v Psi chevron.r) = mat(
        delim: "(",
        lambda_1lr(bar.v [macron(b)b]_1(1P) chevron.r);
        lambda_2lr(bar.v [macron(b)b]_1(2P) chevron.r);
        dots.c;
        phi.alt(q)lr(bar.v B macron(B)^* chevron.r)
      ) \
      lr(chevron.l Psi mid(|) Psi chevron.r) = 1, quad
      #text(fill: red)[$cal(P)_(macron(b)b) = sum_(n=1)^N |lambda_n|^2$]
    $
  ],
)

== Short-range potential and open-bottom channels
#text(fill: blue)[$S$-wave short-range potential]:
$
  V_S^(macron(b)b+op("CT"))(p',p) = g^2/(4pi)sum_(n=1)^N (psi_n (p')psi^*_n (p))/(M-M_n^(macron(b)b)) + C(N)
$

#text(fill: blue)[Coupling $g$] defined by the transition operator $hat(g)$:
$
  lr(chevron.l B macron(B)^* ( ""^3S_1) mid(|) hat(g) mid(|)[macron(b)b]_1 (n P) chevron.r) = g psi_n (p), quad quad
  psi_n (p) = 4pi integral_0^infinity r^2 d r j_0(p r)R_(1n) (r)
$
- Franck-Condon: the heavy quarks carry most of the meson momentum $->$ $p$ enters the bottomonium wave function

#text(fill: blue)[Channels]: $macron(b)b$ couples only to the $S$ wave, but OME couples $S$ and $D$ waves with $J^(P C) = 1^(++)$
$
  "two-body:" quad {B macron(B)^*(""^3S_1), B macron(B)^*(""^3D_1), B^* macron(B)^* (""^5D_1)} \
  "three-body:" quad {B macron(B) phi.alt, B^* macron(B)^* phi.alt, B macron(B)^* phi.alt, macron(B)^* B phi.alt}, quad phi.alt = pi, eta
$

== Power counting
$Q$: generic momentum scale below the EFT hard scale $Lambda$

#text(fill: blue)[_s_-channel exchange of $[macron(b)b]_1(n P)$]
- Each $S$-wave $[macron(b)b]_1 B macron(B)^*$ vertex $->$ #text(fill: red)[$cal(O)(Q^0)$]
- Near threshold, $E_n tilde Q^2 slash (2mu)$: propagator #text(fill: red)[$cal(O)(Q^(-2))$] $=>$ kept explicitly in the sum
- Far from threshold: propagator and exchange #text(fill: red)[$cal(O)(Q^0)$] $=>$ absorbed into $C(N)$

#text(fill: blue)[_t_-channel exchange of $pi$, $eta$]
- $P$-wave emission: each chiral vertex $cal(O)(Q)$, propagator $cal(O)(Q^(-2))$ $=>$ #text(fill: red)[$V^"(OME)" tilde cal(O)(Q^0)$]
- Left-hand cuts inside the energy range $->$ not expandable into local operators, kept explicitly
- Accompanied by a contact term $C(Lambda)$, which also absorbs integrated-out channels like $B_s^((*)) macron(B)_s^((*))$

#text(fill: rgb("#FF6600"))[Higher orders:] momentum-dependent counterterms and multi-meson exchanges; $macron(b)b$ states from a higher-order interquark potential

== Born-Oppenheimer symmetries
At LO the $b$ and $macron(b)$ sources are static $->$ define an axis $hat(bold(r))$ $->$ BO irreps #text(fill: red)[$Lambda_eta^sigma$]:
- #text(fill: blue)[Cylindrical symmetry]: $Lambda = |lambda_ell|$, projection of $bold(j)_ell$ on $hat(bold(r))$; $Lambda = 0, 1, dots$ $->$ $Sigma, Pi, dots$
- #text(fill: blue)[$P C$]: $eta = g, u$ for even/odd $P C$ of the light degrees of freedom
- #text(fill: blue)[Reflection] through a plane containing $hat(bold(r))$: $sigma = P(-1)^(j_ell)$, only for $Lambda = 0$

Heavy-quark limit and static BO potentials $V_(Lambda_eta^sigma)(r)$

$S$-wave meson pairs: $j_ell^(P C)$ and $s_(macron(b)b)^(P C)$ in the final state are $0^(-+)$ or $1^(--)$
$
  0_ell^(-+) times.o 0_(macron(b)b)^(-+) = 0^(++), quad
  0_ell^(-+) times.o 1_(macron(b)b)^(--) = 1^(+-), quad
  1_ell^(--) times.o 0_(macron(b)b)^(-+) = 1^(+-), \
  1_ell^(--) times.o 1_(macron(b)b)^(--) = 0^(++) plus.o #text(fill: red)[$1^(++)$] plus.o 2^(++)
$

$1_ell^(--)$ with $lambda_ell = 0$ $->$ #text(fill: red)[$Sigma_g^(+')$], $lambda_ell = plus.minus 1$ $->$ #text(fill: red)[$Pi_g$] $=>$ determine the coupling of $[macron(b)b]_1(n P)$ to $S$-wave $B macron(B)^*$

== $D$-wave channels and BO configurations
Two ways to couple $s_(macron(b)b) = 1$, $j_ell = 1$ and $L = 0, 2$:
- #text(fill: blue)[Partial waves]: $bold(S) = bold(s)_(macron(b)b) + bold(j)_ell$ first; $S = 1$ ($B macron(B)^*$), $S = 2$ ($B^* macron(B)^*$) \
  $S$ does not commute with $lambda_ell$ $->$ not a BO quantum number
- #text(fill: blue)[BO]: $bold(J)_ell = bold(L) + bold(j)_ell$ first, conserved in the heavy-quark limit
  - $L = 0$: $J_ell = 1$; #h(1em) $L = 2$: $J_ell = 1, 2, 3$
  - $J_ell = 3$ cannot form $J = 1$ with $s_(macron(b)b) = 1$; $lr(|J_ell = 2, lambda_ell = 0 chevron.r)$ vanishes since $chevron.l 2, 0, 1, 0 | 2, 0 chevron.r = 0$

Three $1^(++)$ BO configurations related to the partial-wave channels by an orthogonal transformation:
$
  mat(
    delim: "(",
    lr(bar.v Sigma_g^(+') chevron.r);
    lr(bar.v Pi_g\; 1 chevron.r);
    lr(bar.v Pi_g\; 2 chevron.r)
  )
  = mat(
    delim: "(",
    1/sqrt(3), 1/sqrt(6), -1/sqrt(2);
    sqrt(2/3), -1/(2sqrt(3)), 1/2;
    0, sqrt(3)/2, 1/2
  )
  mat(
    delim: "(",
    lr(bar.v B macron(B)^*(""^3S_1) chevron.r);
    lr(bar.v B macron(B)^*(""^3D_1) chevron.r);
    lr(bar.v B^* macron(B)^*(""^5D_1) chevron.r)
  )
$

== Static potentials in the partial-wave basis
For fixed sources, $lr(|Pi_g\; 1 chevron.r)$ and $lr(|Pi_g\; 2 chevron.r)$ share the same static potential $V_(Pi_g)(r)$:
$
  V(r) = V_C (r) bb(1) + V_T (r) mat(
    delim: "(",
    0, -sqrt(2), sqrt(6);
    -sqrt(2), 1, sqrt(3);
    sqrt(6), sqrt(3), -1
  ), quad
  V_C = 1/3 [V_(Sigma_g^(+')) + 2V_(Pi_g)], quad
  V_T = 1/6 [V_(Pi_g) - V_(Sigma_g^(+'))]
$

- Local static limit: $V_(Sigma_g^(+')) = V_(Pi_g)$ as $r -> 0$, approach the same meson-pair threshold as $r -> infinity$, may differ significantly at intermediate $r$
#v(0.5em)
- #text(fill: blue)[Long range] $->$ $V^"(OME)"$, contributes to $V_C$ and $V_T$ in the static limit
#v(0.5em)
- #text(fill: blue)[Short range] $->$ derivative expansion of local operators
  - LO: constant contact term $C$, only in the $S$ wave ($V_(11)$)
  - Higher orders: additional powers of $p$, $p'$,  transitions among $S$ and $D$ waves

== Lattice input
Unquenched lattice QCD for a static $macron(b)b$ pair with string breaking (Bulava et al., PLB 854 (2024))
$
  g_l =1/sqrt(2) lr(chevron.l op("string") mid(|) H mid(|) B macron(B) chevron.r) = 35.0(5)_"stat" (3)_"sys" "MeV"
$

Lattice two-meson operator $B macron(B)$; project onto $lr(|j_ell, lambda_ell chevron.r)$ and $lr(|s_(macron(b)b), m_(macron(b)b) chevron.r)$:
$
  lr(|B macron(B) chevron.r) = 1/2 lr(|0_ell, 0 chevron.r) lr(|0_(macron(b)b), 0 chevron.r)
  + 1/2 sum_(lambda_ell = plus.minus 1, 0) (-1)^(lambda_ell + 1) lr(|1_ell, lambda_ell chevron.r) lr(|1_(macron(b)b), -lambda_ell chevron.r)
$

- BO quantum number conservation $->$ select $lr(|1_ell, 0 chevron.r) lr(|1_(macron(b)b), 0 chevron.r)$ $->$ #text(fill: red)[factor 2]
- $Sigma_g^(+')$ couples to the $S$-wave $B macron(B)^*(""^3S_1)$ with #text(fill: red)[$1 slash sqrt(3)$]

$
  g = 2 times 1/sqrt(3) times sqrt(2) g_l = 57 "MeV"
$

== Application of BO$chi$EFT to $X_b$
LO potential in the $1^(++)$ sector, $alpha = 1, 2, 3$ for $B macron(B)^*(""^3S_1), B macron(B)^*(""^3D_1), B^* macron(B)^*(""^5D_1)$:
$
  V_(alpha' alpha)(p', p) = delta_(alpha' 1) delta_(alpha 1) V_S^(macron(b)b + op("CT"))(p', p) + V_(alpha' alpha)^"(OME)" (p', p)
$

LSE with nonrelativistic two-body Green's functions:
$
  T_(alpha' alpha)(p', p) = V_(alpha' alpha)(p', p) - sum_(alpha'') integral_0^Lambda (q^2 d q)/(2pi^2) V_(alpha' alpha'')(p', q) G_(alpha'')(k, q) T_(alpha'' alpha)(q, p) \
  G_1 = G_2 = (q^2/(2mu) - E - i epsilon)^(-1), quad
  G_3 = (q^2/m_(B^*) + m_(B^*) - m_B - E - i epsilon)^(-1)
$

- Isospin limit: $m_B = 5.279 "GeV"$, $m_(B^*) = 5.325 "GeV"$, threshold at $10.604 "GeV"$

- Free parameters $C$ and $V_0$ fitted to the three $chi_(b 1)$ states: #h(0.5em) $(Delta M)^2 = 1/3 sum_(n = 1)^3 (M_n - M_n^"exp")^2$

== Two scenarios for $X_b$
#align(center, text(size: 15pt, table(
  columns: 12,
  align: center + horizon,
  stroke: none,
  inset: (x: 0.4em, y: 0.45em),
  table.hline(),
  table.header(
    [Scenario],
    [$C$ \ (GeV$""^(-2)$)],
    [$V_0$ \ (MeV)],
    [$M$ (GeV)],
    [$cal(P)_(macron(b)b)$ (%)],
    [$M$ (GeV)],
    [$cal(P)_(macron(b)b)$ (%)],
    [$M$ (GeV)],
    [$cal(P)_(macron(b)b)$ (%)],
    [$M$ (GeV)],
    [$cal(P)_(macron(b)b)$ (%)],
    [$Delta M$ \ (MeV)],
  ),
  table.hline(stroke: 0.5pt),
  [Deeply bound], [$-16.27$], [371], [9.893], [100], [10.255], [98],
  text(fill: red)[10.513], text(fill: red)[2], [10.544], [85], [0.0],
  [Shallow], [2.66], [362], [9.884], [100], [10.246], [99],
  [10.535], [86], text(fill: red)[$10.603^*$], text(fill: red)[8], [15.0],
  table.hline(),
)))
#align(center, text(size: 14pt)[$""^*$ $C$ tuned to place the state 1 MeV below the $B macron(B)^*$ threshold])

- #text(fill: blue)[Deeply bound]: $C$ and $V_0$ fitted together $->$ $Delta M = 0$
  - The state at #text(fill: red)[$10.513 "GeV"$] is the predominantly molecular $X_b$
  - A predominantly compact state is predicted between $X_b$ and the threshold, at $10.544 "GeV"$
#v(0.5em)
- #text(fill: blue)[Shallow] (as found in BOEFT studies): $C$ tuned to place $X_b$ 1 MeV below threshold, then $V_0$ fitted $->$ the three observed $chi_(b 1)$ are predominantly compact, $Delta M approx 15 "MeV"$

== Conclusion
#grid(
  columns: (auto, 1fr),
  column-gutter: 1.2em,
  align: horizon,
  image("figs/levels_three_channel_projected.pdf", height: 12.4cm),
  text(size: 16pt)[
    #text(fill: blue)[Pole masses vs. $C$] at $V_0 = 371 "MeV"$:
    - Right edge: deeply bound; left edge: shallow scenario
    - Avoided crossing $->$ near-threshold states exchange their compact content (c)
    - Spurious deep pole from the $1 slash r^3$ OME tensor force (a), projected out (b)

    #text(fill: blue)[BO$chi$EFT]:
    - Chiral EFT + BO separation + lattice static potentials with string breaking
    - Quarkonium–open-flavour coupling *and* meson exchanges, improvable order by order

    #text(fill: red, weight: "bold")[$X_b$]: the observed $1^(++)$ state at #text(fill: red)[$10.513 "GeV"$] can be a predominantly molecular $X_b$; a compact state is then predicted at #text(fill: red)[$10.544 "GeV"$], about $60 "MeV"$ below threshold
  ],
)
