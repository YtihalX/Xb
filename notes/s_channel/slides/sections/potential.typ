#import "../style.typ": *
#import "@preview/cetz:0.4.2"

// Overview chain of s_channel_note.tex (Fig. 1), redrawn in cetz.
// Only used by the commented-out overview slide below.
#let overview-diagram() = cetz.canvas(length: 1.18cm, {
  import cetz.draw: *
  let input = rgb(94%, 94%, 100%) // blue!6: lattice and quark input
  let vertex = rgb(100%, 95%, 90%) // orange!10: transition vertex
  let potential = rgb(100%, 92%, 92%) // red!8: s-channel potential
  let scattering = rgb(92%, 100%, 92%) // green!8: hadronic scattering problem
  let tip = (end: "stealth", fill: luma(70), scale: 0.8)
  let link = 0.9pt + luma(70)
  let node(pos, name, fill, body) = content(
    pos,
    align(center, text(size: 13.5pt, body)),
    frame: "rect",
    fill: fill,
    stroke: 0.6pt + luma(60),
    padding: (x: 0.2, y: 0.12),
    name: name,
  )
  let tag(pos, anchor, body) = content(pos, text(size: 12pt, fill: luma(40), body), anchor: anchor, padding: 0.1)

  node((0, 0), "lat", input)[
    Lattice QCD, static $b macron(b)$ + light quarks \
    Bulava _et al._ 2024: $sigma$, $gamma$, $g_l$
  ]
  node((-6.6, -1.65), "corn", input)[
    Cornell $V(r) = V_0 + sigma r + gamma \/ r$ \
    $H = 2 m_b - nabla^2 \/ m_b + V(r)$, $L = 1$
  ]
  node((6.6, -1.65), "gch", input)[
    $g = underbrace(sqrt(2), "flavour") dot underbrace(2, "spin") dot underbrace(1 \/ sqrt(3), S"-wave") dot g_l = 57$ MeV
  ]
  node((-6.6, -3.35), "tower", input)[
    bare tower ${E_n^((0)), R_(1 n)(r)}$ \
    $V_0$ shifts all $E_n$
  ]
  node((-6.6, -5.1), "ff", vertex)[
    Franck–Condon vertex \
    $mel(B macron(B)^* (p), hat(g), n) = g psi_n (p)$ \
    $psi_n (p) = 4 pi integral r^2 dif r thin j_0 (p r) R_(1 n)(r)$
  ]
  node((1.1, -5.1), "V", potential)[
    $V_S^((macron(b) b) + "CT")(p', p; E) = display(sum_(n <= N)) (g^2 f_n (p') f_n (p)) / (E - E_n^((0)) - V_0) + C$
  ]
  node((-6.6, -6.8), "fit", none)[
    fit $V_0$, $C$ to \
    9.893, 10.255, 10.513 GeV
  ]
  node((1.1, -6.8), "lse", scattering)[
    LSE, two-potential solution \
    $det(hat(v)^(-1) + hat(J)) = 0$
  ]
  node((6.6, -6.8), "ome", none)[
    $V^"(OME)"$ ($pi$, $eta$) \
    $3 times 3$ channels
  ]
  node((1.1, -8.4), "out", scattering)[
    4 bound states: $chi_(b 1)(1P)$, $chi_(b 1)(2P)$, $X_b$ (molecular, $cal(P)_(macron(b) b) = 2%$), \
    compact $chi_(b 1)(3P)$ at 10.544 GeV ($cal(P)_(macron(b) b) = 85%$)
  ]

  line("lat.west", ("lat.west", "-|", "corn.north"), "corn.north", mark: tip, stroke: link)
  tag(("lat.west", 50%, ("lat.west", "-|", "corn.north")), "south", [$sigma$, $gamma$])
  line("lat.east", ("lat.east", "-|", "gch.north"), "gch.north", mark: tip, stroke: link)
  tag(("lat.east", 50%, ("lat.east", "-|", "gch.north")), "south", [$g_l$])
  line("corn.south", "tower.north", mark: tip, stroke: link)
  tag(("corn.south", 50%, "tower.north"), "west", [$m_b$, $V_0 = 0$])
  line("tower.south", "ff.north", mark: tip, stroke: link)
  line("ff.east", "V.west", mark: tip, stroke: link)
  line("gch.south", ("gch.south", "|-", "V.east"), "V.east", mark: tip, stroke: link)
  line("V.south", "lse.north", mark: tip, stroke: link)
  line("fit.east", "lse.west", mark: tip, stroke: link)
  line("ome.west", "lse.east", mark: tip, stroke: link)
  line("lse.south", "out.north", mark: tip, stroke: link)
})

// ---------------------------------------------------------------------------
#slide[Three kinds of interactions][
  #grid(
    columns: (auto, 1fr),
    column-gutter: 2.5em,
    align: horizon,
    $ V = V^"(OME)" + sum_(n = 1)^N V_n^((macron(b) b)) + C(Lambda, N) $,
    [
      - $V^"(OME)"$: one-pion and one-$eta$ exchange
      - $V_n^((macron(b) b))$: $s$-channel exchange of compact $1^(+ +)$ bottomonia
      - $C(Lambda, N)$: contact term (cutoff $Lambda$, truncation $N$)
    ],
  )
  #v(0.3em)
  #grid(
    columns: (auto, auto),
    column-gutter: 1.2em,
    align: horizon,
    text(weight: "bold")[Why only the $S$ wave at leading order?], keybox[$S$ wave _because of_ LO],
  )
  #grid(
    columns: (1.15fr, 1fr),
    column-gutter: 2em,
    [
      BO selection rule: the compact state turns into $Sigma_g^(+')$, not a pure $S$ wave (derived at the end):
      $ ket(Sigma_g^(+')) = 1 / sqrt(3) ket(pw(3, S, 1)) + 1 / sqrt(6) ket(pw(3, D, 1)) - 1 / sqrt(2) ket(pw(5, D, 1)) $
      Symmetry alone keeps the $D$ waves.
    ],
    [
      The momentum expansion does. Franck–Condon vertex $prop integral r^2 dif r thin j_L (p r) R_(1 n)(r)$:
      $ j_0 (p r) = 1 + cal(O)((p r)^2), quad j_2 (p r) = (p r)^2 / 15 + dots $
      $D$-wave vertex $cal(O)(Q^2)$, $S$-wave $cal(O)(Q^0)$; $D$ waves return at higher orders.
    ],
  )
]

/* Overview diagram, commented out.
#slide[Where $V^((macron(b) b))$ sits][
  #align(center, overview-diagram())
  #caption[Blue: input; orange: vertex; red: $s$-channel potential + contact term; green: scattering problem.]
]
*/

#slide(
  refs: [radii, $p thin r_"rms"$ and plots: our estimate from the bare Cornell tower, $m_b = 4.534$ GeV],
)[The suppression is parametric][
  - $p tilde Q approx kappa_(X_b) = 0.695$ GeV; rms radii of the bare states $n = 1$–$4$: $0.41$, $0.66$, $0.87$, $1.05$ fm
  - $p thin r_"rms" approx 1.4, 2.3, 3.1, 3.7$: not small
  - so the $S$-wave restriction is a counting statement, not a numerical one
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    align: center,
    [#image("../figs/un_r.pdf", height: 6.2cm) #caption[$u_n (r) = r R_(1 n)(r)$; dotted: string–$B macron(B)$ crossing]],
    [#image("../figs/fn_p.pdf", height: 6.2cm) #caption[$f_n (p) = sqrt(4 pi) integral r^2 dif r thin j_0 (p r) R_(1 n)(r)$; dotted: $kappa$]],
  )
]

#slide[The coupled-channel Hamiltonian and the state vector][
  $ cal(H) = mat(
    H - M_"th", 0, dots.c, hat(g)^dagger;
    0, H - M_"th", dots.c, hat(g)^dagger;
    dots.v, dots.v, dots.down, dots.v;
    hat(g), hat(g), dots.c, H_(M M)
  ) quad "acting on" quad ket(Psi) = mat(lambda_1 ket([macron(b) b]_1 (1P)); lambda_2 ket([macron(b) b]_1 (2P)); dots.v; phi(q) ket(B macron(B)^*)) $
  #grid(
    columns: (1fr, auto),
    column-gutter: 1.5em,
    align: horizon,
    [
      $ "normalisation:" quad sum_n |lambda_n|^2 + integral (q^2 dif q) / (2 pi^2) |phi(q)|^2 = 1 $
      - $phi(q) = braket(q, Psi)$; $ket(q)$ are the meson-pair states, normalised as $braket(q', q) = (2 pi^2) / q^2 delta(q' - q)$
    ],
    [
      #image("../figs/diagram.pdf", width: 8.5cm)
      #caption[$pw(3, P, 1)$ bottomonium $arrow.r$ $S$-wave $B macron(B)^*$ via $hat(g)$; \ the heavy quarks are spectators]
    ],
  )
]

#slide[Projectors and the block form of $cal(H)$][
  Split the space into the compact sector $Q$ and the meson-pair sector $M$:
  $ P_Q = sum_n ket(n) bra(n), quad P_M = integral_0^infinity (q^2 dif q) / (2 pi^2) ket(q) bra(q), quad P_Q + P_M = bold(1), quad P_Q P_M = 0 $
  Sandwich $cal(H)$ between $bold(1) = P_Q + P_M$ on both sides:
  $ cal(H) = (P_Q + P_M) cal(H) (P_Q + P_M) = underbrace(P_Q cal(H) P_Q, H_(Q Q)) + underbrace(P_M cal(H) P_M, H_(M M)) + underbrace(P_M cal(H) P_Q, hat(g)) + underbrace(P_Q cal(H) P_M, hat(g)^dagger) $
  - $H_(Q Q) = P_Q (H - M_"th") P_Q = sum_n E_n ket(n) bra(n)$
  - $P_Q cal(H) P_M = (P_M cal(H) P_Q)^dagger = hat(g)^dagger$, because $cal(H)$ is Hermitian
  - ordered as (compact, meson pair): $cal(H) = mat(H_(Q Q), hat(g)^dagger; hat(g), H_(M M))$, i.e. the Hamiltonian matrix from before with all bottomonium rows in one block
]

#slide[Projecting the Schrödinger equation][
  Write $cal(H) ket(Psi) = E ket(Psi)$ as $cal(H) (P_Q + P_M) ket(Psi) = E ket(Psi)$ and multiply from the left by $P_Q$:
  $ P_Q cal(H) P_Q ket(Psi) + P_Q cal(H) P_M ket(Psi) = E P_Q ket(Psi) $
  Since $P^2 = P$, put one more projector next to the ket:
  $ P_Q cal(H) P_Q ket(Psi) = (P_Q cal(H) P_Q)(P_Q ket(Psi)) = H_(Q Q) P_Q ket(Psi), quad P_Q cal(H) P_M ket(Psi) = hat(g)^dagger P_M ket(Psi) $
  $ arrow.r.double quad H_(Q Q) P_Q ket(Psi) + hat(g)^dagger P_M ket(Psi) = E P_Q ket(Psi) $
  Multiplying by $P_M$ instead: #h(0.3em) $hat(g) P_Q ket(Psi) + H_(M M) P_M ket(Psi) = E P_M ket(Psi)$. Collecting terms:
  #keybox[$ (E - H_(Q Q)) P_Q ket(Psi) = hat(g)^dagger P_M ket(Psi), quad (E - H_(M M)) P_M ket(Psi) = hat(g) P_Q ket(Psi) $]
]

#slide[Eliminating the compact states][
  For $E != E_n$, with the inverse taken inside the compact space:
  $ P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  Plug this into the second equation:
  $ (E - H_(M M)) P_M ket(Psi) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  $H_(Q Q) = sum_n E_n ket(n) bra(n)$ is diagonal, so on the compact space $(E - H_(Q Q))^(-1) = sum_n (ket(n) bra(n)) / (E - E_n)$:
  #keybox[$ [H_(M M) + hat(V)(E)] P_M ket(Psi) = E P_M ket(Psi), quad hat(V)(E) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger = sum_n (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) $]
  A Schrödinger equation for the heavy mesons alone: the compact states leave behind an energy-dependent potential.
]

/* Plot of V(E), commented out.
#slide(refs: [plot: our estimate, full-fit $V_0 = 371.5$ MeV])[What $hat(V)(E)$ looks like][
  #grid(
    columns: (1.55fr, 1fr),
    column-gutter: 1em,
    align: horizon,
    image("../figs/V_of_E.pdf", width: 100%),
    [
      at zero momenta, with $N = 4$:
      $ V_S (0, 0; E) = sum_(n <= 4) (g^2 f_n (0)^2) / (E - E_n) $
      - poles at the bare energies $E_n = E_n^((0)) + V_0$ (dotted)
      - dashed: the individual terms
      - near threshold the $n = 3$ term dominates
      - attractive just below $E_3$, strongly repulsive between $E_3$ and threshold
    ],
  )
]
*/

#slide[Truncation and compact amplitudes][
  Split $P_Q = P_(<= N) + P_(> N)$:
  $ hat(V)(E) = sum_(n <= N) (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) + hat(g) P_(> N) (E - H_(Q Q))^(-1) P_(> N) hat(g)^dagger $
  - the second piece has no pole near threshold and varies slowly there
  - at LO it is replaced by a constant: the contact term $C(Lambda, N)$, which is why $C$ depends on $N$
  #v(0.6em)
  Projecting $P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi)$ on $bra(n)$ gives the compact amplitudes:
  $ lambda_n = braket(n, Psi) = mel(n, hat(g)^dagger P_M, Psi) / (E - E_n) $
]

#slide[Normalisation and the compact probability][
  Bound state ($E = -E_B$, real), $ket(Psi_M) equiv P_M ket(Psi)$; $hat(g)$ does not depend on $E$, and
  $ partial_E (E - H_(Q Q))^(-1) = -(E - H_(Q Q))^(-2) $
  so
  $
    braket(Psi, Psi) & = mel(Psi, P_M, Psi) + mel(Psi, P_Q, Psi) = braket(Psi_M, Psi_M) + mel(Psi_M, hat(g) (E - H_(Q Q))^(-2) hat(g)^dagger, Psi_M) \
                     & = mel(Psi_M, [1 - partial_E hat(V)(E)], Psi_M)
  $
  #keybox[$ cal(P)_(macron(b) b) = mel(Psi, P_Q, Psi) = sum_n |lambda_n|^2 = -mel(Psi_M, partial_E hat(V), Psi_M) $]
  The energy dependence of $hat(V)$ _is_ the compact component.
]
