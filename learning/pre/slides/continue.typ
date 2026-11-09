// BOχEFT and its application to X_b, part II: learning/pre/slides-continue.tex as slides,
// in the style of main-v2.typ (same page setup and helpers, Tasks numbered on from part I).
// Build: typst compile continue.typ   (Typst 0.15; fetches @preview/cetz:0.4.2 on first use)

#import "@preview/cetz:0.4.2"

#let gray-text = luma(105)
#let rule-gray = luma(160)
#let key-stroke = rgb(0%, 0%, 45%) // xcolor blue!45!black, the notes' keybox frame
#let key-fill = rgb(97%, 97%, 100%) // xcolor blue!3, the notes' keybox background

/// Page and text setup; apply with `#show: deck`.
#let deck(body) = {
  set page(
    paper: "presentation-16-9",
    margin: (x: 1.5cm, top: 1.0cm, bottom: 1.25cm),
    footer: context {
      let n = counter(page).get().first()
      if n > 1 { align(right, text(size: 11pt, fill: gray-text)[#n]) }
    },
  )
  set text(font: "New Computer Modern", size: 18pt, lang: "en")
  set par(leading: 0.8em, spacing: 1.0em)
  set list(spacing: 0.9em, indent: 0.3em)
  show math.equation.where(block: true): set block(above: 0.85em, below: 0.85em)
  set table(stroke: none, inset: (x: 0.45em, y: 0.3em))
  body
}

/// PDF navigation entry without visible content or added layout space.
#let slide-bookmark(title) = {
  show heading: _ => []
  heading(level: 1, numbering: none, outlined: false, bookmarked: true, title)
}

/// One slide: bold title over a thin gray rule, then the body. `refs` is set
/// in small gray type at the bottom right.
#let slide(title, refs: none, body) = {
  pagebreak(weak: true)
  slide-bookmark(title)
  block(below: 0.4em, text(size: 1.3em, weight: "bold", title))
  line(length: 100%, stroke: 0.6pt + rule-gray)
  v(0.15em)
  body
  if refs != none {
    place(bottom + right, text(size: 11pt, fill: gray-text, refs))
  }
}

#let title-slide(title, author, affiliation) = align(center + horizon, {
  slide-bookmark(title)
  text(size: 1.75em, weight: "bold", title)
  v(1.4em)
  text(size: 1.1em, author)
  v(0.5em)
  text(size: 0.8em, fill: gray-text, affiliation)
})

/// Key result, framed like the notes' keybox.
#let keybox(body) = align(center, block(
  stroke: 0.6pt + key-stroke,
  fill: key-fill,
  radius: 2pt,
  inset: (x: 0.8em, y: 0.5em),
  breakable: false,
  body,
))

// booktabs-style table rules
#let toprule = table.hline(stroke: 0.9pt)
#let midrule = table.hline(stroke: 0.5pt)
#let bottomrule = table.hline(stroke: 0.9pt)

// Dirac notation and spectroscopic labels.
#let ket(x) = $lr(|#x chevron.r)$
#let bra(x) = $lr(chevron.l #x|)$
#let braket(a, b) = $lr(chevron.l #a mid(|) #b chevron.r)$
#let mel(a, o, b) = $lr(chevron.l #a mid(|) #o mid(|) #b chevron.r)$
#let pw(s, l, j) = $attach(#l, tl: #s, br: #j)$

// One TOPT time ordering (Fig. 2 of the paper, as drawn in slides-continue.tex). Time runs to the
// right; `top`/`bottom` list the heavy-line segments (x0, x1, starred) of the meson and antimeson,
// single line B, double line B*; the dashed boson runs between the two vertices `boson`; the thin
// gray line cuts the intermediate state.
#let topt-diagram(top, bottom, boson, labels, boson-label, caption-text) = cetz.canvas(length: 1.0cm, {
  import cetz.draw: *
  let heavy(y, segments) = for (x0, x1, starred) in segments {
    if starred {
      line((x0, y + 0.055), (x1, y + 0.055), stroke: 0.8pt)
      line((x0, y - 0.055), (x1, y - 0.055), stroke: 0.8pt)
    } else {
      line((x0, y), (x1, y), stroke: 0.8pt)
    }
  }
  let label(pos, anchor, body) = content(pos, text(size: 13pt, body), anchor: anchor, padding: 0.08)
  heavy(2, top)
  heavy(0, bottom)
  line((2, -0.3), (2, 2.3), stroke: 0.5pt + luma(140))
  let (a, b) = boson
  line(a, b, stroke: (thickness: 0.8pt, dash: "dashed"))
  circle(a, radius: 0.07, fill: black, stroke: none)
  circle(b, radius: 0.07, fill: black, stroke: none)
  let (tl, tr, bl, br) = labels
  label((0.45, 2.12), "south", tl)
  label((3.55, 2.12), "south", tr)
  label((0.45, -0.14), "north", bl)
  label((3.55, -0.14), "north", br)
  let (pos, anchor, body) = boson-label
  label(pos, anchor, body)
  content((2, -1.35), text(size: 14pt, caption-text))
})

#let topt-figure = grid(
  columns: 4,
  column-gutter: 1.1em,
  topt-diagram(
    ((0, 3, false), (3, 4, true)),
    ((0, 1, true), (1, 4, false)),
    ((1, 0), (3, 2)),
    ($B(bold(p))$, $B^*(bold(p)')$, $macron(B)^*(-bold(p))$, $macron(B)(-bold(p)')$),
    ((1.85, 1.2), "east", $phi(-bold(q))$),
    [(1) #h(0.2em) $B macron(B) phi$],
  ),
  topt-diagram(
    ((0, 1, false), (1, 4, true)),
    ((0, 3, true), (3, 4, false)),
    ((1, 2), (3, 0)),
    ($B(bold(p))$, $B^*(bold(p)')$, $macron(B)^*(-bold(p))$, $macron(B)(-bold(p)')$),
    ((2.15, 1.2), "west", $phi(bold(q))$),
    [(2) #h(0.2em) $B^* macron(B)^* phi$],
  ),
  topt-diagram(
    ((0, 3, false), (3, 4, true)),
    ((0, 4, true),),
    ((1, 0), (3, 2)),
    ($B(bold(p))$, $B^*(bold(p)')$, $macron(B)^*(-bold(p))$, $macron(B)^*(-bold(p)')$),
    ((1.85, 1.2), "east", $phi(-bold(q))$),
    [(3) #h(0.2em) $B macron(B)^* phi$],
  ),
  topt-diagram(
    ((0, 1, true), (1, 4, false)),
    ((0, 4, true),),
    ((1, 2), (3, 0)),
    ($B^*(bold(p))$, $B(bold(p)')$, $macron(B)^*(-bold(p))$, $macron(B)^*(-bold(p)')$),
    ((2.15, 1.2), "west", $phi(bold(q))$),
    [(4) #h(0.2em) $macron(B)^* B phi$],
  ),
)

#set document(title: "BOχEFT and its application to Xb, part II", author: "Yu Zhang")
#show: deck

#title-slide(
  [BO$chi$EFT and its application to $X_b$ \
    #text(size: 0.6em, weight: "regular")[II. Contact term, meson exchange, scattering equation and compositeness]],
  [Yu Zhang],
  [Institute of Theoretical Physics, Chinese Academy of Sciences \
    University of Chinese Academy of Sciences],
)

// ---------------------------------------------------------------------------
#slide[What to do next?][
  Part I: $hat(V)(E)$ and $cal(P)_(macron(b) b)$ (Task 1), the matrix $U$ (Task 2), the coupling $g$ (Task 3). Still open:
  - Task 4: the short-range part, and why the LO contact is a constant in $pw(3, S, 1)$ only
    $ V^"CT"_(alpha' alpha)(p', p) = C thin delta_(alpha' 1) delta_(alpha 1) + cal(O)(Q^2) $
  - Task 5: the long-range part, OME from the LO chiral Lagrangian in TOPT
    $ V^"(OME)"_(alpha' alpha)(p', p) = 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_pi) + 1 / 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_eta) $
  - Task 6: solve the LSE with the two-potential formalism
    $ T = T_U + (1 - T_U G) thin S thin (1 - G T_U), quad S = F tau F^dagger, quad tau = (hat(v)^(-1) + J)^(-1) $
  - Task 7: the composition of a bound state, from the pole of $tau$
    $ 1 = cal(P)_(macron(b) b) + cal(P)_S + cal(P)_D + cal(P)_"3-body" $
]

// ------------------------------------------------------------- Task 4: short range
#slide[Task 4, Step 1: The static potential in partial waves][
  Static limit $m_b -> infinity$: $b$, $macron(b)$ at rest at distance $r$; no heavy kinetic energy, no $B^*$–$B$ splitting, no recoil. The light degrees of freedom have energies $V_(Sigma_g^(+'))(r)$, $V_(Pi_g)(r)$: the BO potentials ($Sigma_g^(+')$: the meson-pair level, not the string $Sigma_g^+$).
  $
    hat(V) = sum_i ket("BO"_i) V_i bra("BO"_i), quad braket(alpha, "BO"_i) = U_(i alpha) quad arrow.r.double quad V(r) = U^T "diag"(V_(Sigma_g^(+')), V_(Pi_g), V_(Pi_g)) thin U
  $
  - common part plus rank one, with $e_1 = (1, 0, 0)^T$:
    $ "diag"(V_(Sigma_g^(+')), V_(Pi_g), V_(Pi_g)) = V_(Pi_g) bold(1) + (V_(Sigma_g^(+')) - V_(Pi_g)) thin e_1 e_1^T $
  - $U^T bold(1) U = bold(1)$; #h(0.2em) $u = U^T e_1$ is the first row of $U$, the overlaps $u_alpha = braket(alpha, Sigma_g^(+'))$:
  #keybox[$
    V(r) = V_(Pi_g)(r) thin bold(1) + [V_(Sigma_g^(+'))(r) - V_(Pi_g)(r)] thin u u^T, quad u = (1 / sqrt(3), 1 / sqrt(6), -1 / sqrt(2))^T
  $]
  every channel is shifted by $V_(Pi_g)$; only the difference knows the direction $Sigma_g^(+')$
]

#slide[Task 4, Step 2: Central and tensor parts][
  Pull the trace part out of the rank-one matrix ($tr u u^T = u^T u = 1$):
  $
    u u^T = mat(1 / 3, 1 / (3 sqrt(2)), -1 / sqrt(6); 1 / (3 sqrt(2)), 1 / 6, -1 / (2 sqrt(3)); -1 / sqrt(6), -1 / (2 sqrt(3)), 1 / 2) = 1 / 3 bold(1) - 1 / 6 M_T, quad M_T = mat(0, -sqrt(2), sqrt(6); -sqrt(2), 1, sqrt(3); sqrt(6), sqrt(3), -1)
  $
  check: $-1 / 6 dot (-sqrt(2)) = 1 / (3 sqrt(2))$, #h(0.3em) $1 / 3 - 1 / 6 = 1 / 6$. Collecting the unit matrices:
  #keybox[$
    V(r) = V_C (r) thin bold(1) + V_T (r) thin M_T, quad V_C = (V_(Sigma_g^(+')) + 2 V_(Pi_g)) / 3, quad V_T = (V_(Pi_g) - V_(Sigma_g^(+'))) / 6
  $]
  - $V_C$ is the same in all channels (central); $M_T$ is traceless and couples $S$ to $D$, like the OPE tensor force
  - centrifugal barriers and the threshold $Delta m$ of channel 3 come on top: kinematics, not $V_C$, $V_T$. And $V(r)$ is static and local, not our interaction: its long range is OME, its short range our contacts
]

#slide[Task 4, Step 3: What is matched; the Bessel transform][
  - large $r$: the mesons are far apart and exchange $pi$, $eta$: our OME
  - short $r$: the mesons overlap, the light quarks rearrange; not resolved by the hadronic theory, so replaced by contact terms $delta^((3))(arrow(r))$ and derivatives. Which comes first?
  Partial-wave states, consistent with $integral_0^infinity r^2 dif r thin j_L (p' r) j_L (p r) = pi / (2 p^2) delta(p' - p)$:
  $
    braket(p'\, alpha', p\, alpha) = delta_(alpha' alpha) (2 pi^2) / p^2 delta(p' - p), quad braket(arrow(r), p\, alpha) = 4 pi thin i^(L_alpha) j_(L_alpha)(p r) thin cal(Y)_alpha (hat(bold(r))), quad integral dif Omega thin cal(Y)_(alpha')^dagger cal(Y)_alpha = delta_(alpha' alpha) / (4 pi)
  $
  Insert $integral dif^3 r ket(arrow(r)) bra(arrow(r))$ on both sides of a local $hat(V)$:
  #keybox[$
    V_(alpha' alpha)(p', p) = 4 pi thin i^(L_alpha - L_(alpha')) integral_0^infinity r^2 dif r thin j_(L_(alpha'))(p' r) thin V_(alpha' alpha)(r) thin j_(L_alpha)(p r)
  $]
  the phase $i^(L_alpha - L_(alpha'))$ is $+1$ for $S$–$S$ and $D$–$D$, $-1$ for $S$–$D$
]

#slide[Task 4, Step 4: Short range means small argument][
  A piece living at $r lt.tilde R = 1 \/ Lambda_chi$, probed at $p, p' << Lambda_chi$: expand the Bessel functions,
  $
    j_L (x) = x^L / ((2L + 1)!!) (1 - x^2 / (2(2L + 3)) + dots), quad j_0 (x) = 1 - x^2 / 6 + dots, quad j_2 (x) = x^2 / 15 - x^4 / 210 + dots
  $
  so the leading term of a short-range piece is
  $
    V^<_(alpha' alpha)(p', p) tilde.eq 4 pi thin i^(L_alpha - L_(alpha')) (p'^(L_(alpha')) p^(L_alpha)) / ((2 L_(alpha') + 1)!! thin (2 L_alpha + 1)!!) integral_0^R dif r thin r^(2 + L_(alpha') + L_alpha) V_(alpha' alpha)(r)
  $
  - $S$–$S$ starts with a constant, $S$–$D$ with $p^2$ (or $p'^2$), $D$–$D$ with $p'^2 p^2$
  - counting $p, p' tilde Q$: only $S$–$S$ is $cal(O)(Q^0)$, and the only $S$ wave in $1^(+ +)$ is channel 1
  #keybox[$ V^"CT"_(alpha' alpha)(p', p) = C thin delta_(alpha' 1) delta_(alpha 1) + cal(O)(Q^2), quad "in" r "space" quad C thin delta^((3))(arrow(r)) $]
]

#slide[Task 4, Step 5: Higher contacts and the moments $C^<_(T, n)$][
  How large are the higher $S$–$D$ and $D$–$D$ contacts? Both static levels come from one light-quark multiplet as $r -> 0$, so their difference starts at $r^2$:
  $ V_T (r) = b_T r^2 + c_T r^4 + dots, quad b_T = (b_Pi - b_Sigma) / 6, quad c_T = (c_Pi - c_Sigma) / 6 $
  Put the tensor entries $V_12 = -sqrt(2) V_T$, $V_13 = sqrt(6) V_T$, $V_23 = sqrt(3) V_T$ into Step 3 and cut the integral at $R = 1 \/ Lambda_chi$. After expanding the Bessel functions only radial moments of $V_T$ appear:
  #keybox[$
    C^<_(T, n) equiv 4 pi integral_0^(1 \/ Lambda_chi) dif r thin r^n V_T (r) = 4 pi [b_T / ((n + 3) Lambda_chi^(n + 3)) + c_T / ((n + 5) Lambda_chi^(n + 5))]
  $]
  - the second term is smaller by $(n + 3) / (n + 5) c_T / (b_T Lambda_chi^2)$: one more order of the multipole expansion
]

#slide[Task 4, Step 6: The short-range $S$–$D$ and $D$–$D$ entries][
  $V^<_12$: $S$ out, $D$ in, phase $i^2 = -1$; expand the product of Bessel functions,
  $
    j_0 (p' r) j_2 (p r) = (1 - (p'^2 r^2) / 6) ((p^2 r^2) / 15 - (p^4 r^4) / 210) + dots = p^2 / 15 r^2 - (p'^2 p^2 / 90 + p^4 / 210) r^4 + dots
  $
  $
    V^<_12 = 4 pi (-1)(-sqrt(2)) integral_0^R dif r thin r^2 j_0 (p' r) j_2 (p r) V_T (r) = sqrt(2) / 15 [p^2 C^<_(T, 4) - (p'^2 p^2 / 6 + p^4 / 14) C^<_(T, 6)] + dots
  $
  - $V^<_13$: same $L$'s and phase, $sqrt(6)$ instead of $-sqrt(2)$: #h(0.2em) $V^<_13 = -sqrt(3) thin V^<_12$, an HQSS relation through the static matrix
  - $V^<_23$: $D$–$D$, phase $+1$, $j_2 (p' r) j_2 (p r) = (p'^2 p^2 r^4) / 225 + dots$:
  #keybox[$
    V^<_23 = sqrt(3) / 225 thin p'^2 p^2 thin C^<_(T, 6) + dots, quad V^<_(j i)(p', p) = V^<_(i j)(p, p')
  $]
]

#slide[Task 4, Step 7: Two suppressions; what matching cannot give][
  - angular momentum alone gives the powers $p'^(L') p^L$ of Step 4
  - the BO multipole expansion adds a second one: $b_T tilde Lambda_"QCD"^3$, $c_T tilde Lambda_"QCD"^5$ are nonperturbative, so each further term costs $(Lambda_"QCD" \/ Lambda_chi)^2$, counted as $cal(O)(Q^2)$ (the assignment can be adjusted)
  - then higher BO terms enter channel 1 at $cal(O)(Q^2)$, the $D$-wave and off-diagonal entries at $cal(O)(Q^4)$ or later; the LO statement of Step 4 needs only the first suppression
  #v(0.5em)
  What it does _not_ do:
  - give a value of $C$: the moments depend on the arbitrary radius $1 \/ Lambda_chi$, OME has its own short-range part whose split from the contacts is scheme dependent, and $C$ is fitted at each cutoff
  - add the static $V(r)$ on top: the potential stays $V^"(OME)" + V^((macron(b) b)) + C$
]

// ------------------------------------------------------------- Task 5: OME
#slide(refs: [Wise 1992; Burdman, Donoghue 1992; Yan _et al._ 1992])[Task 5, Step 1: The LO chiral Lagrangian][
  Heavy–light mesons coupled to the pseudo-Goldstone bosons, taken as given (LO heavy-meson ChPT):
  #keybox[$
    cal(L)_Phi = -g_b / 4 op("Tr")(H_a^dagger H_b thin bold(sigma) dot bold(u)_(b a)) + g_b / 4 op("Tr")(bold(sigma) dot bold(u)_(a b) thin macron(H)_b macron(H)_a^dagger)
  $]
  - $H_a = P_a + bold(V)_a dot bold(sigma)$: #h(0.2em) $P_a = (B^-, macron(B)^0)$, $V_a^i = (B^(* -), macron(B)^(* 0))$ annihilate the $b macron(q)$ mesons
  - $macron(H)_a = macron(P)_a + macron(bold(V))_a dot bold(sigma)$: #h(0.2em) $macron(P)_a = (B^+, B^0)$, $macron(V)_a^i = (B^(* +), B^(* 0))$ annihilate the $macron(b) q$ mesons; the bar means antimeson
  - $a = 1, 2$: light flavour ($u, d$); $i$: vector index of $B^*$; $bold(sigma)$ acts on spin, $tau_a$ on flavour; Tr is over spin
  - $cal(C) P_a cal(C)^(-1) = macron(P)_a$, $cal(C) V_a^i cal(C)^(-1) = -macron(V)_a^i$ #h(0.3em) $arrow.r.double$ #h(0.3em) $ket(B macron(B)^*\; C = +) = (ket(B macron(B)^*) - ket(B^* macron(B))) \/ sqrt(2)$
]

#slide(refs: [$g_b$: Flynn _et al._, PRD 93, 014510 (2016)])[Task 5, Step 2: Goldstone bosons and the spin traces][
  $
    bold(u) = -(nabla Phi) / F_pi + cal(O)(Phi^3), quad Phi = pi_a tau_a + eta / sqrt(3) bold(1) = mat(pi^0 + eta / sqrt(3), sqrt(2) pi^+; sqrt(2) pi^-, -pi^0 + eta / sqrt(3)), quad pi^plus.minus = (pi_1 minus.plus i pi_2) / sqrt(2)
  $
  - $eta$ multiplies $bold(1)$: it sits on _both_ diagonal entries, with the same $1 \/ sqrt(3)$
  - $F_pi = 92.2$ MeV; #h(0.2em) #box($g_b = 0.56(3)_"stat" (7)_"sys"$) from lattice QCD at the physical $b$ mass (central value used)
  #v(0.3em)
  Spin traces: #h(0.3em) $op("Tr") sigma_i = 0$, #h(0.3em) $op("Tr") sigma_i sigma_j = 2 delta_(i j)$, #h(0.3em) $op("Tr") sigma_i sigma_j sigma_k = 2 i epsilon_(i j k)$. Meson term:
  $
    H_a^dagger H_b = P_a^dagger P_b + P_a^dagger V_b^j sigma_j + V_a^(i dagger) P_b sigma_i + V_a^(i dagger) V_b^j sigma_i sigma_j
  $
  #keybox[$ op("Tr")(H_a^dagger H_b thin sigma_k) = 2 (P_a^dagger V_b^k + V_a^(k dagger) P_b) + 2 i epsilon_(i j k) V_a^(i dagger) V_b^j $]
  - no $P^dagger P$ term: no $B B phi$ vertex ($0^- -> 0^- 0^-$ is forbidden by parity and angular momentum)
]

#slide[Task 5, Step 3: The one-boson Lagrangian][
  Insert $u^k_(a b) = -partial_k Phi_(a b) \/ F_pi$. Meson term:
  $
    -g_b / 4 op("Tr")(H_a^dagger H_b thin sigma_k u^k_(b a)) = g_b / (2 F_pi) [(V_a^(k dagger) P_b + P_a^dagger V_b^k) partial_k Phi_(b a) + i epsilon_(i j k) V_a^(i dagger) V_b^j thin partial_k Phi_(b a)]
  $
  Antimeson term: the order is $sigma_k macron(H)_b macron(H)_a^dagger$, the Pauli matrices come reversed, $op("Tr") sigma_k sigma_j sigma_i = -2 i epsilon_(i j k)$; after normal ordering
  $
    op("Tr")(sigma_k macron(H)_b macron(H)_a^dagger) = 2 (macron(P)_a^dagger macron(V)_b^k + macron(V)_a^(k dagger) macron(P)_b) - 2 i epsilon_(i j k) macron(V)_a^(i dagger) macron(V)_b^j
  $
  $
    g_b / 4 op("Tr")(sigma_k u^k_(a b) macron(H)_b macron(H)_a^dagger) = g_b / (2 F_pi) [-(macron(P)_a^dagger macron(V)_b^k + macron(V)_a^(k dagger) macron(P)_b) partial_k Phi_(a b) + i epsilon_(i j k) macron(V)_a^(i dagger) macron(V)_b^j thin partial_k Phi_(a b)]
  $
  - antimesons: the $P V phi$ term flips sign, the $V V phi$ term does not; flavour enters as $Phi_(b a)$ for mesons but $Phi_(a b)$ for antimesons
]

#slide[Task 5, Step 4: The vertices][
  A meson line $bold(p) -> bold(p)'$ loses $bold(q) = bold(p) - bold(p)'$. Strip the common $plus.minus i bold(q)$ of the gradient and the flavour matrix:
  #keybox[$
    v^a_(B^* B phi) = g_b / (2 F_pi) tau^a (bold(epsilon.alt) dot bold(q)), quad v^a_(B^* B^* phi) = -g_b / (sqrt(2) F_pi) tau^a (bold(A) dot bold(q)), quad bold(A) = i / sqrt(2) bold(epsilon.alt) times bold(epsilon.alt)'^*
  $]
  - $bold(epsilon.alt) = bold(epsilon.alt)_lambda (bold(p))$ incoming, $bold(epsilon.alt)'^* = bold(epsilon.alt)^*_(lambda')(bold(p)')$ outgoing polarisation; for $eta$ replace $tau^a$ by $bold(1) \/ sqrt(3)$
  - $P V phi$: the field $V^k$ (or $V^(k dagger)$) becomes the polarisation of the one vector meson
  - $V V phi$: $i epsilon_(i j k) epsilon.alt'^*_i epsilon.alt_j q_k = i (bold(epsilon.alt)'^* times bold(epsilon.alt)) dot bold(q) = -i (bold(epsilon.alt) times bold(epsilon.alt)'^*) dot bold(q) = -sqrt(2) thin bold(A) dot bold(q)$; with $g_b \/ (2 F_pi)$ this gives $-g_b \/ (sqrt(2) F_pi)$
  - antimesons go from $-bold(p)$ to $-bold(p)'$, so they lose $-bold(q)$; extra minus in $P V phi$, not in $V V phi$
]

#slide[Task 5, Step 5: Signs: Hamiltonian matrix elements][
  For whole diagrams we need the $i$'s. $H_"int" = -integral dif^3 x thin cal(L)_Phi$, $c equiv g_b \/ (2 F_pi)$; emitting $phi(bold(k))$ gives $nabla -> -i bold(k)$, absorbing it $nabla -> +i bold(k)$. Per unit flavour factor (and $1 \/ sqrt(2 E_phi)$):
  #v(0.4em)
  #align(center, table(
    columns: 3,
    align: (left, center, center),
    inset: (x: 0.8em, y: 0.35em),
    toprule,
    [], [emit $phi(bold(k))$], [absorb $phi(bold(k))$],
    midrule,
    [meson $B -> B^*$], [$+i c thin bold(epsilon.alt)'^* dot bold(k)$], [$-i c thin bold(epsilon.alt)'^* dot bold(k)$],
    [antimeson $macron(B)^* -> macron(B)$], [$-i c thin bold(epsilon.alt) dot bold(k)$], [$+i c thin bold(epsilon.alt) dot bold(k)$],
    [$B^* -> B^*$, either line], [$-i sqrt(2) c thin bold(A) dot bold(k)$], [$+i sqrt(2) c thin bold(A) dot bold(k)$],
    bottomrule,
  ))
  #v(0.4em)
  - meson $B^* -> B$ and antimeson $macron(B) -> macron(B)^*$: the same, with $bold(epsilon.alt)'^*$ and $bold(epsilon.alt)$ interchanged
  - e.g. meson $B -> B^*$, emission: $-c thin epsilon.alt'^*_k (-i k_k) = +i c thin bold(epsilon.alt)'^* dot bold(k)$
]

#slide[Task 5, Step 6: Time-ordered perturbation theory][
  OME is second order in $H_"int"$. In TOPT every particle stays on shell; energy is conserved overall but not at each vertex, and each intermediate state costs an energy denominator:
  $ V = sum_n (mel(f, H_"int", n) mel(n, H_"int", i)) / (M - E_n + i 0) $
  Between the vertices: the two heavy mesons and $phi$; which ones depends on who emits first.
  #align(center, topt-figure)
  - time runs to the right; single line $B$, double line $B^*$, dashed $phi$; thin line: intermediate state
  - classes 3 and 4 contain the same particles; the $B$ carries $bold(p)$ in class 3 and $bold(p)'$ in class 4
]

#slide[Task 5, Step 7: Energy denominators][
  $omega_h (p) = m_h + p^2 \/ (2 m_h)$, $E_phi (q) = sqrt(q^2 + m_phi^2)$; one ordering with heavy mesons $h_1, h_2$ in the intermediate state ($1 \/ (2 E_phi)$: boson normalisation):
  #keybox[$
    1 / (2 E_phi) dot 1 / (M - omega_(h_1) - omega_(h_2) - E_phi + i 0) = -1 / (2 E_phi (q) [E_phi (q) + nu_beta]) equiv -D_beta, quad nu_beta = omega_(h_1) + omega_(h_2) - M - i 0
  $]
  With $M = m_B + m_(B^*) + E$, $Delta m = m_(B^*) - m_B$ ($nu_beta$ is the paper's $mu_beta$):
  $
    nu_1 & = -Delta m + (p^2 + p'^2) \/ (2 m_B) - E - i 0, & quad nu_2 & = Delta m + (p^2 + p'^2) \/ (2 m_(B^*)) - E - i 0, \
    nu_3 & = p^2 \/ (2 m_B) + p'^2 \/ (2 m_(B^*)) - E - i 0, & quad nu_4 & = p'^2 \/ (2 m_B) + p^2 \/ (2 m_(B^*)) - E - i 0
  $
  - all four depend on $E$ and on $p$, $p'$ separately: OME is energy dependent and nonlocal, kept in full
  - only without recoil and $E$ in $nu_(1, 2)$ do (1) and (2) combine into a static Yukawa: #h(0.2em) #box($D_1 + D_2 -> (2 E_phi)^(-1) [(E_phi - Delta m)^(-1) + (E_phi + Delta m)^(-1)] = (bold(q)^2 + m_phi^2 - Delta m^2)^(-1)$)
]

#slide[Task 5, Step 8: Signs of the time orderings][
  Each ordering is (vertex) $times$ (vertex) $times (-D_beta)$, with the vertices of Step 5. For $B macron(B)^* -> B^* macron(B)$:
  - $beta = 2$, the meson emits $phi(bold(q))$, the antimeson absorbs it:
    $ (+i c thin bold(epsilon.alt)'^* dot bold(q))(+i c thin bold(epsilon.alt) dot bold(q))(-D_2) = +c^2 (bold(epsilon.alt) dot bold(q))(bold(epsilon.alt)'^* dot bold(q)) thin D_2 $
  - $beta = 1$, the antimeson emits $phi(-bold(q))$:
    $ (-i c thin bold(epsilon.alt) dot (-bold(q)))(-i c thin bold(epsilon.alt)'^* dot (-bold(q)))(-D_1) = +c^2 (bold(epsilon.alt) dot bold(q))(bold(epsilon.alt)'^* dot bold(q)) thin D_1 $
  - $C$-even state $(ket(B macron(B)^*) - ket(B^* macron(B))) \/ sqrt(2)$: no diagonal terms (no $B B phi$ vertex), the cross terms carry the relative minus, $V_(P V -> P V) = -mel(B^* macron(B), V, B macron(B)^*)$
  - $B^* macron(B)^* -> B^* macron(B)^*$: $(-i sqrt(2) c thin bold(A)_1 dot bold(q))(+i sqrt(2) c thin bold(A)_2 dot bold(q))(-D_2) = -2 c^2 (bold(A)_1 dot bold(q))(bold(A)_2 dot bold(q)) thin D_2$; both orderings are class 2
]

#slide[Task 5, Step 9: The four OME kernels][
  The mixed transitions go the same way. With $c^2 = g_b^2 \/ (4 F_pi^2)$, still without the flavour factor:
  #keybox[$
    V_(B macron(B)^* -> B macron(B)^*) & = -g_b^2 / (4 F_pi^2) (bold(epsilon.alt) dot bold(q))(bold(epsilon.alt)'^* dot bold(q)) thin [D_1 + D_2] \
    V_(B macron(B)^* -> B^* macron(B)^*) & = g_b^2 / (4 F_pi^2) [(bold(A)_1 dot bold(q))(bold(epsilon.alt)'^*_2 dot bold(q)) + (bold(A)_2 dot bold(q))(bold(epsilon.alt)'^*_1 dot bold(q))] thin [D_3 + D_2] \
    V_(B^* macron(B)^* -> B macron(B)^*) & = g_b^2 / (4 F_pi^2) [(bold(A)_1 dot bold(q))(bold(epsilon.alt)_2 dot bold(q)) + (bold(A)_2 dot bold(q))(bold(epsilon.alt)_1 dot bold(q))] thin [D_4 + D_2] \
    V_(B^* macron(B)^* -> B^* macron(B)^*) & = -g_b^2 / (2 F_pi^2) (bold(A)_1 dot bold(q))(bold(A)_2 dot bold(q)) thin [2 D_2]
  $]
  - 1 and 2 label the $B^*$ and the $macron(B)^*$ of the $B^* macron(B)^*$ pair, $bold(A)_a = i / sqrt(2) bold(epsilon.alt)_a times bold(epsilon.alt)'^*_a$
  - two $P$-wave vertices: every kernel carries two powers of $bold(q)$
]

#slide[Task 5, Step 10: Tensor force and $S$–$D$ mixing][
  Split the two powers of $bold(q)$ into scalar and tensor parts, e.g. for the $B macron(B)^*$ kernel:
  $
    (bold(epsilon.alt) dot bold(q))(bold(q) dot bold(epsilon.alt)'^*) = 1 / 3 q_i q_j (delta_(i j) thin bold(epsilon.alt) dot bold(epsilon.alt)'^* + T_(i j)), quad T_(i j) = 3 epsilon.alt_i epsilon.alt'^*_j - delta_(i j) thin bold(epsilon.alt) dot bold(epsilon.alt)'^*
  $
  (the two $delta_(i j)$ terms cancel, $1 / 3 dot 3 thin q_i q_j epsilon.alt_i epsilon.alt'^*_j$ is left)
  - scalar part $1 / 3 q^2 thin bold(epsilon.alt) dot bold(epsilon.alt)'^*$: central, does not change $L$
  - $T_(i j)$ traceless: the rest is $1 / 3 (q_i q_j - 1 / 3 delta_(i j) q^2) T_(i j)$, rank 2 in the momenta contracted with rank 2 in the spins
  - a rank-2 operator connects $L = 0$ with $L = 2$ at fixed $J$; polarisation vectors without the two powers of $bold(q)$ would give no mixing:
  #keybox[$ B macron(B)^* (pw(3, S, 1)) quad arrow.l.r quad B macron(B)^* (pw(3, D, 1)), quad B^* macron(B)^* (pw(5, D, 1)) $]
]

#slide[Task 5, Step 11: Partial-wave projection][
  $
    V^"(OME)"_(alpha' alpha)(p', p; m_phi) = 1 / (2J + 1) integral (dif Omega_(bold(n)')) / (4 pi) (dif Omega_(bold(n))) / (4 pi) op("Tr")[P^dagger (alpha'; bold(n)') thin V^"(OME)"(bold(p)', bold(p); m_phi) thin P(alpha; bold(n))]
  $
  - $bold(n) = bold(p) \/ p$, $bold(n)' = bold(p)' \/ p'$; the kernel is a matrix in the polarisations of the external mesons
  - $P(alpha; bold(n))$: spin–angular wave function of channel $alpha$; index $i$ = the total $J = 1$ polarisation. With $Q_(i j)(bold(n)) = n_i n_j - 1 / 3 delta_(i j)$:
  $
    P_i (1; bold(n)) = epsilon.alt_i, quad P_i (2; bold(n)) = -3 / sqrt(2) epsilon.alt_j Q_(i j)(bold(n)), \
    P_i (3; bold(n)) = -sqrt(3) / 2 thin i epsilon_(i j k) (epsilon.alt_(1 j) epsilon.alt_(2 m) + epsilon.alt_(1 m) epsilon.alt_(2 j) - 2 / 3 delta_(j m) thin bold(epsilon.alt)_1 dot bold(epsilon.alt)_2) thin Q_(k m)(bold(n))
  $
  - Tr over $i$ and all polarisations, $1 \/ (2J + 1)$ averages over orientations; normalised as $1 / (2J + 1) integral (dif Omega_bold(n)) / (4 pi) P P^dagger = 1$ (e.g. $alpha = 1$: $1 / 3 sum_(i, lambda) |epsilon.alt_(lambda, i)|^2 = 1$). The result is $mel(p'\, alpha', V^"(OME)", p\, alpha)$, normalised as in Task 4
]

#slide[Task 5, Step 12: Angular moments; the $pw(3, S, 1)$ entry][
  Rotational invariance: put $bold(n) = hat(bold(z))$, $x = bold(n) dot bold(n)'$. Then $q^2 = p^2 + p'^2 - 2 p p' x$, the spin numerator is a polynomial in $x$, and all reduces to the angular moments
  $ Delta^((beta_1 beta_2))_m (p', p; m_phi) = integral_(-1)^1 dif x thin x^m [D_(beta_1) + D_(beta_2)] $
  Simplest case $1 -> 1$: with $sum_lambda epsilon.alt_(lambda, i) epsilon.alt^*_(lambda, j) = delta_(i j)$ the trace is $-c^2 q^2 [D_1 + D_2]$; the factor $1 \/ (2J + 1)$ is $1 \/ 3$, the angular average $1 / 2 integral_(-1)^1 dif x$:
  #keybox[$
    V_11 (p', p; m_phi) & = -g_b^2 / (24 F_pi^2) integral_(-1)^1 dif x thin (p^2 + p'^2 - 2 p p' x) [D_1 + D_2] \
    & = g_b^2 / (24 F_pi^2) [2 p p' Delta_1^((1 2)) - (p^2 + p'^2) Delta_0^((1 2))]
  $]
  - the other entries: longer polynomials in $x$, with the pairs $(beta_1, beta_2)$ of Step 9
]

#slide[Task 5, Step 13: Flavour factors from charge states][
  The kernels carry no flavour yet. A meson vertex has $Phi_(b a)$, an antimeson vertex $Phi_(a b)$: the meson sees the _transposed_ matrix. With $Phi = pi^0 M_0 + pi^+ M_+ + pi^- M_- + eta M_eta$:
  $
    M_0 = mat(1, 0; 0, -1), quad M_+ = mat(0, sqrt(2); 0, 0), quad M_- = mat(0, 0; sqrt(2), 0), quad M_eta = 1 / sqrt(3) bold(1)
  $
  $pi^0$ is emitted and absorbed as $pi^0$; a $pi^+$ created at one vertex is absorbed through $pi^- = (pi^+)^dagger$:
  $
    K_pi = M_0^T times.o M_0 + M_+^T times.o M_- + M_-^T times.o M_+ = sum_a tau_a^T times.o tau_a, quad K_eta = M_eta^T times.o M_eta = 1 / 3 bold(1)
  $
  Neutral states $ket(n) = ket(macron(B)^0 B^(* 0))$, $ket(c) = ket(B^- B^(* +))$, meson first. $pi^0$: $(-1)(-1) = (+1)(+1) = 1$; #h(0.2em) $pi^plus.minus$: $sqrt(2) dot sqrt(2) = 2$; #h(0.2em) $eta$: $1 \/ 3$
  #keybox[$ K_pi = mat(1, 2; 2, 1), quad K_eta = 1 / 3 mat(1, 0; 0, 1); quad "eigenvectors" (ket(n) plus.minus ket(c)) / sqrt(2) "with" K_pi = 3, -1 $]
]

#slide(refs: [independent check: `checks/isospin_factors.py`, 29 exact assertions pass])[Task 5, Step 14: The same from isospin algebra][
  $H_a$ annihilates $b macron(q)$: the meson carries the _anti_-doublet, $arrow(I)_1 = -arrow(tau)^T \/ 2$; the antimeson ($macron(b) q$) has $arrow(I)_2 = arrow(tau) \/ 2$:
  $
    K_pi = sum_a tau_a^T times.o tau_a = -4 thin arrow(I)_1 dot arrow(I)_2 = -2 [I(I + 1) - 3 / 4 - 3 / 4] = cases(3 quad & I = 0, -1 quad & I = 1)
  $
  - $K_eta = 1 \/ 3$ for both: $eta$ is an isosinglet
  - the paper's $arrow(tau) dot arrow(tau)^c$ with $arrow(tau)^c = tau_2 arrow(tau)^T tau_2 = -arrow(tau)$: the antiparticle minus is already inside the 3
  - the signs of the kernels (of $V_(B macron(B)^* -> B macron(B)^*)$, of the $C$-even state, of the antimeson $P V phi$ vertex) are in the spin kernels: don't apply them again
  #keybox[$
    V^"(OME)"_(alpha' alpha)(p', p) = 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_pi) + 1 / 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_eta) quad (I = 0)
  $]
]

// ------------------------------------------------------------- Task 6: scattering equation
#slide[Task 6, Step 1: The Lippmann–Schwinger equation][
  $
    hat(T) ket(p\, alpha) = hat(V) ket(psi_(p alpha)^((+))), quad T_(alpha' alpha)(p', p) = V_(alpha' alpha)(p', p) - sum_(alpha'') integral_0^Lambda (q^2 dif q) / (2 pi^2) V_(alpha' alpha'')(p', q) G_(alpha'')(k, q) T_(alpha'' alpha)(q, p)
  $
  - $ket(psi^((+))_(p alpha))$: the outgoing scattering state; $E = k^2 \/ (2 mu)$ above the $B macron(B)^*$ threshold
  - $G_alpha (k, q) = [q^2 / (2 mu_alpha) + delta_alpha - E - i epsilon]^(-1)$, #h(0.2em) $delta_alpha = (0, 0, Delta m)$
  - as an operator $G = (H_0 - E - i epsilon)^(-1)$: _minus_ the usual $(E - H_0 + i epsilon)^(-1)$, hence the sign in $T = V - V G T$
  #v(0.3em)
  Three interactions: compact exchange and the contact can be written in separable form, OME cannot:
  #keybox[$
    V = underbrace(V^"(OME)", U", not separable") + underbrace(V^((macron(b) b)) + V^"CT", W", separable, channel 1")
  $]
  ($U$ from here on means $V^"(OME)"$, not the BO matrix)
]

#slide[Task 6, Step 2: Separable potential, separable $T$][
  Compact exchange and contact, in channel 1 ($pw(3, S, 1)$) only:
  $
    V_S^((macron(b) b) + "CT")(p', p) = f^T (p') thin hat(v)(E) thin f^*(p), quad f_n (p) = cases(psi_n (p) \/ sqrt(4 pi) quad & n = 1\, dots\, N, 1 & n = N + 1)
  $
  $ hat(v)(E) = "diag"(v_1, dots, v_N, C), quad v_n = g^2 / (E - E_n), quad E_n = E_n^((0)) + V_0 $
  The contact is one more separable term, with $f_(N + 1) = 1$. Why the solution is separable too:
  - the LSE as $T = V - V G T$ or as $T = V - T G V$: #h(0.2em) $T = (1 + V G)^(-1) V = V (1 + G V)^(-1)$
  - in the first form every term starts with $f^T (p')$, in the second it ends with $f^*(p)$
  #keybox[$ T(p', p) = sum_(i j) f_i (p') thin tau_(i j) thin f_j^*(p) = f^T (p') thin tau thin f^*(p) $]
  the potential cannot create a momentum dependence it does not have
]

#slide[Task 6, Step 3: The matrix equation, and when it holds][
  Insert $T = f^T tau f^*$ into the LSE, with $(J_0)_(i j) = integral_0^Lambda (q^2 dif q) / (2 pi^2) f_i^*(q) G_1 (k, q) f_j (q)$:
  $ f^T (p') [tau - hat(v) + hat(v) J_0 tau] f^*(p) = 0 quad "for all" p', p $
  - _sufficient_: if $tau = hat(v) - hat(v) J_0 tau$, the bracket vanishes; no condition needed
  - _necessary_ iff $f_1, dots, f_(N + 1)$ are linearly independent on $[0, Lambda]$: multiply by $f^*(p')$ and $f^T (p)$ and integrate; with the Gram matrix $cal(G) = integral (q^2 dif q) / (2 pi^2) f^*(q) f^T (q)$ this is $cal(G) [dots] cal(G) = 0$, and $cal(G)$ is invertible iff the $f_i$ are independent, as the Cornell form factors and the constant are
  - for dependent $f_i$, $tau$ is not unique, but $T$ is the same
  #keybox[$ tau = (1 + hat(v) J_0)^(-1) hat(v) = (hat(v)^(-1) + J_0)^(-1), quad det(1 + hat(v) J_0) = 0 "at the poles of" T $]
  - the $hat(v)^(-1)$ form needs every $v_n != 0$: for $C = 0$ (or $g = 0$) drop that component; at $E = E_n$, $v_n^(-1) = 0$ is harmless
]

#slide[Task 6, Step 4: Adding OME: solve OME first][
  With $U equiv V^"(OME)"$, $W equiv V^((macron(b) b)) + V^"CT"$, $T_U equiv T^"(OME)"$:
  $ ket(psi) = ket(phi) - G (U + W) ket(psi) quad arrow.r.double quad (1 + G U) ket(psi) = ket(phi) - G W ket(psi) $
  $ ket(psi) = underbrace((1 + G U)^(-1) ket(phi), ket(phi_U)", OME only") - (1 + G U)^(-1) G thin W ket(psi) $
  The dressed propagator: $(1 + G U)^(-1) G = [G^(-1) (1 + G U)]^(-1) = (G^(-1) + U)^(-1) = (H_0 + U - E)^(-1) equiv K$
  #keybox[$ ket(psi) = ket(phi_U) - K W ket(psi) $]
  - an LSE with $ket(phi) -> ket(phi_U)$ and $G -> K$: solve OME first, then use it to solve the whole problem
  - careful: $U$ depends on $E$, so $K(E)$ is the resolvent of $H_0 + U(E)$ at the same $E$, not of one fixed Hamiltonian; $partial_E K != K^2$
]

#slide[Task 6, Step 5: The auxiliary transition operator][
  "$S ket(phi_U) = W ket(psi)$" only defines $S$ on one vector. Define $S$ as an operator, by the LSE with $K$ in place of $G$:
  #keybox[$ S = W - W K S, quad "i.e." quad S = (1 + W K)^(-1) W $]
  Then $S ket(phi_U) = W ket(psi)$ follows: multiply $ket(psi) = ket(phi_U) - K W ket(psi)$ by $W$,
  $ W ket(psi) = W ket(phi_U) - W K (W ket(psi)) $
  the same equation as $S ket(phi_U) = W ket(phi_U) - W K (S ket(phi_U))$; for invertible $1 + W K$ the solution is unique:
  $ W ket(psi) = S ket(phi_U) = W ket(phi_U) - W K S ket(phi_U) $
  - $S$ is a transition operator, not the $S$ matrix
]

#slide(refs: [Gell-Mann, Goldberger, Phys. Rev. 91, 398 (1953); Nakano, PRC 26, 1123 (1982)])[Task 6, Step 6: The two-potential formula][
  $
    T ket(phi) = (U + W)(ket(phi_U) - K W ket(psi)) = U ket(phi_U) - U K W ket(psi) + W ket(psi) = T_U ket(phi) + (1 - U K) S ket(phi_U)
  $
  using $W(ket(phi_U) - K W ket(psi)) = W ket(psi) = S ket(phi_U)$. The OME-only pieces, from $T_U = U - U G T_U = U - T_U G U$:
  $
    T_U = (1 + U G)^(-1) U = U (1 + G U)^(-1), quad (1 + G U)^(-1) = 1 - G T_U, quad U K = U (1 + G U)^(-1) G = T_U G
  $
  so $ket(phi_U) = (1 - G T_U) ket(phi)$, with $T_U$, not the full $T$. For every $ket(phi)$:
  #keybox[$ T = T_U + (1 - T_U G) thin S thin (1 - G T_U) $]
  - $T_U$: pure OME scattering. Second term: distorted by OME on the way in ($1 - G T_U$) and out ($1 - T_U G$), with compact exchange and contact any number of times in between ($S$, with OME rescattering inside $K$)
]

#slide[Task 6, Step 7: $S$ is separable: the matrix $tau$][
  Vertex map: put the $N + 1$ functions into channel 1, $braket(p\, alpha, f_i) = delta_(alpha 1) f_i (p)$, and set $F = sum_i ket(f_i) bra(i)$, a map from $CC^(N + 1)$ into the meson-pair space:
  $ W = F hat(v) F^dagger $
  - $S$ is separable for the same reason as $T$: $S = W - W K S$ starts with $F$, $S = W - S K W$ ends with $F^dagger$; not an extra assumption
  $ F tau F^dagger = F hat(v) F^dagger - F hat(v) F^dagger K F tau F^dagger = F [hat(v) - hat(v) J tau] F^dagger, quad J equiv F^dagger K F $
  - independent $f_i$, as in Step 3: $tau = hat(v) - hat(v) J tau$
  #keybox[$ S = F tau F^dagger, quad tau = (1 + hat(v) J)^(-1) hat(v) = (hat(v)^(-1) + J)^(-1), quad J = F^dagger K F $]
  $J$: the $(N + 1) times (N + 1)$ matrix of loops dressed by OME; the states are the zeros of $det(hat(v)^(-1) + J)$
]

#slide[Task 6, Step 8: Dressed vertices and the amplitude][
  $ X^"out"_i (bold(p)'; E) = mel(bold(p)', 1 - T_U G, f_i), quad X^"in"_i (bold(p); E) = mel(f_i, 1 - G T_U, bold(p)) $
  Insert $bold(1) = sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) ket(q\, alpha) bra(q\, alpha)$; $G$ is diagonal and $f_(i, alpha)(q) = delta_(alpha 1) f_i (q)$ is real:
  $
    X^"out"_(i, alpha')(p') & = f_(i, alpha')(p') - sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) T^"(OME)"_(alpha' alpha)(p', q) thin G_alpha (k, q) thin f_(i, alpha)(q) \
    X^"in"_(i, alpha)(p) & = f_(i, alpha)(p) - sum_(alpha') integral_0^Lambda (q^2 dif q) / (2 pi^2) f_(i, alpha')(q) thin G_(alpha')(k, q) thin T^"(OME)"_(alpha' alpha)(q, p)
  $
  #keybox[$
    T_(alpha' alpha)(p', p) = T^"(OME)"_(alpha' alpha)(p', p) + sum_(i, j = 1)^(N + 1) X^"out"_(i, alpha')(p') thin tau_(i j) thin X^"in"_(j, alpha)(p), quad tau = (hat(v)^(-1) + J)^(-1)
  $]
]

#slide[Task 6, Step 9: The dressed loop $J$][
  $K = (1 + G U)^(-1) G = (1 - G T_U) G = G (1 - T_U G) = G - G T_U G$, so $J = F^dagger K F$ has three forms:
  $
    J_(i j) & = sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) X^"in"_(i, alpha)(q) thin G_alpha (k, q) thin f_(j, alpha)(q) = sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) f_(i, alpha)(q) thin G_alpha (k, q) thin X^"out"_(j, alpha)(q) \
    & = integral_0^Lambda (q^2 dif q) / (2 pi^2) f_i (q) thin G_1 (k, q) thin f_j (q) \
    & quad - sum_(alpha', alpha) integral_0^Lambda (q'^2 dif q') / (2 pi^2) integral_0^Lambda (q^2 dif q) / (2 pi^2) f_(i, alpha')(q') thin G_(alpha')(k, q') thin T^"(OME)"_(alpha' alpha)(q', q) thin G_alpha (k, q) thin f_(j, alpha)(q)
  $
  - the free loop between two vertices, minus the full OME amplitude (not one OME potential) between two free loops
  - time reversal: $J$, hence $tau$, is symmetric
  - $T^"(OME)"$, $X^"in, out"$ and $J$ do not depend on $C$ or $V_0$, which enter only through $hat(v)$: a fit only inverts an $(N + 1) times (N + 1)$ matrix
]

// ------------------------------------------------------------- Task 7: composition
#slide[Task 7, Step 1: A third sector for three-body states][
  Task 1 had $P_Q$ (bare $macron(b) b$) and $P_M$ (meson pairs); eliminating $P_Q$ gave $hat(V)(E)$ and $cal(P)_(macron(b) b)$. The TOPT intermediate states $B^((*)) macron(B)^((*)) phi$ are real three-body states, so add a third projector $P_phi$:
  $
    P_Q + P_M + P_phi = bold(1), quad P_Q P_M = P_Q P_phi = P_M P_phi = 0, quad cal(H) = mat(H_(Q Q), hat(g)^dagger, 0; hat(g), H_(M M), hat(g)_phi^dagger; 0, hat(g)_phi, H_(phi phi)), quad hat(g)_phi equiv P_phi cal(H) P_M
  $
  - $H_(phi phi)$ is the free three-body energy, $H_(phi phi) ket(beta\; b) = E_beta (b) ket(beta\; b)$: $beta$ the four classes, $b$ all momenta and spins
  - $hat(g)_phi$: the one-boson vertex of Task 5; compact states do not couple to three-body states directly (the zeros)
  - $H_(M M) = H_0$ now: all of OME comes from $P_phi$, the contact sits in $hat(V)$ as in Task 1; nothing in $cal(H)$ depends on $E$
]

#slide[Task 7, Step 2: Eliminating compact and three-body states][
  Multiply $cal(H) ket(Psi) = E ket(Psi)$ by each projector:
  $
    (E - H_(Q Q)) thin P_Q ket(Psi) & = hat(g)^dagger P_M ket(Psi) \
    (E - H_(M M)) thin P_M ket(Psi) & = hat(g) thin P_Q ket(Psi) + hat(g)_phi^dagger P_phi ket(Psi) \
    (E - H_(phi phi)) thin P_phi ket(Psi) & = hat(g)_phi thin P_M ket(Psi)
  $
  First and third: $P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger ket(Psi_M)$, #h(0.2em) $P_phi ket(Psi) = (E - H_(phi phi))^(-1) hat(g)_phi ket(Psi_M)$. Into the second:
  #keybox[$
    [H_(M M) + hat(V)(E) + hat(U)(E)] ket(Psi_M) = E ket(Psi_M), quad hat(U)(E) = hat(g)_phi^dagger (E - H_(phi phi))^(-1) hat(g)_phi
  $]
  $
    hat(U)_(alpha' alpha)(p', p; E) = sum_(beta, b) (mel(p'\, alpha', hat(g)_phi^dagger, beta\; b) mel(beta\; b, hat(g)_phi, p\, alpha)) / (E - E_beta (b) + i epsilon)
  $
  the TOPT form; the paper identifies it with $V^"(OME)"$
]

#slide[Task 7, Step 3: Normalisation with three sectors][
  As for $P_Q$ in Task 1: $partial_E (E - H_(phi phi))^(-1) = -(E - H_(phi phi))^(-2)$. Bound state, $E = -E_B$ real:
  $
    1 = braket(Psi, Psi) & = mel(Psi, P_Q, Psi) + mel(Psi, P_M, Psi) + mel(Psi, P_phi, Psi) \
    & = mel(Psi_M, hat(g) (E - H_(Q Q))^(-2) hat(g)^dagger, Psi_M) + braket(Psi_M, Psi_M) + mel(Psi_M, hat(g)_phi^dagger (E - H_(phi phi))^(-2) hat(g)_phi, Psi_M) \
    & = mel(Psi_M, [1 - partial_E hat(V) - partial_E hat(U)], Psi_M)
  $
  #keybox[$
    cal(P)_(macron(b) b) = -mel(Psi_M, partial_E hat(V), Psi_M), quad sum_alpha cal(P)_alpha = braket(Psi_M, Psi_M), quad cal(P)_"3-body" = -mel(Psi_M, partial_E hat(U), Psi_M)
  $]
  - each one positive, adding up to 1; the contact does not depend on $E$ and drops out
  - $cal(P)_alpha = integral_0^Lambda (q^2 dif q) / (2 pi^2) |Psi_alpha (q)|^2$: the individual two-body channels
]

#slide[Task 7, Step 4: Caveat: exchange is not all of $hat(U)$][
  $hat(g)_phi$ lets _either_ heavy meson emit the boson: $hat(g)_phi = hat(g)_1 + hat(g)_2$ (meson line, antimeson line). With $R = (E - H_(phi phi))^(-1)$:
  $
    hat(U) = underbrace(hat(g)_1^dagger R thin hat(g)_1 + hat(g)_2^dagger R thin hat(g)_2, "self-energies") + underbrace(hat(g)_1^dagger R thin hat(g)_2 + hat(g)_2^dagger R thin hat(g)_1, "exchange")
  $
  - the OME kernels of Task 5 are the exchange terms only: the boson goes from one meson to the other
  - with $ket(a) = R thin hat(g)_1 ket(Psi_M)$, $ket(b) = R thin hat(g)_2 ket(Psi_M)$:
  $
    -mel(Psi_M, partial_E V^"(OME)", Psi_M) = 2 op("Re") braket(a, b) quad "vs." quad norm(a + b)^2 = norm(a)^2 + norm(b)^2 + 2 op("Re") braket(a, b)
  $
  - the exchange part alone is an interference term; the paper does not say what happens to $norm(a)^2 + norm(b)^2$: a self-energy subtraction or renormalisation prescription would be needed
  #keybox[$cal(P)_"3-body"$ below is a probability only if $hat(U) = V^"(OME)"$; the scattering algebra holds regardless]
]

#slide[Task 7, Step 5: The normalisation from the pole of $tau$][
  Simple bound-state pole of $tau = (hat(v)^(-1) + J)^(-1)$ at $E = -E_B$, $T^"(OME)"$ regular there; $tau$ symmetric, so the residue is $bold(c) bold(c)^T$. With $epsilon equiv E + E_B$ and all orders kept:
  $
    tau^(-1) = A_0 + epsilon A_1 + epsilon^2 A_2 + dots, quad A_n = 1 / n! [partial_E^n (hat(v)^(-1) + J)]_(E = -E_B), quad tau = (bold(c) bold(c)^T) / epsilon + R_0 + epsilon R_1 + dots
  $
  $tau^(-1) tau = bold(1)$, order by order in $epsilon$:
  $
    epsilon^(-1): & quad A_0 bold(c) bold(c)^T = 0 quad arrow.r.double quad A_0 bold(c) = 0: quad det(hat(v)^(-1) + J) = 0, "null vector" bold(c) \
    epsilon^0: & quad A_0 R_0 + A_1 bold(c) bold(c)^T = bold(1) \
    epsilon^1: & quad A_0 R_1 + A_1 R_0 + A_2 bold(c) bold(c)^T = 0
  $
  - $A_(n >= 2)$ and $R_(n >= 1)$ first appear at $epsilon^1$: the higher terms cannot change the residue
  - $A_0$ symmetric, so $bold(c)^T A_0 = 0$; multiply the $epsilon^0$ equation by $bold(c)^T$ from the left: $(bold(c)^T A_1 bold(c)) thin bold(c)^T = bold(c)^T$
  #keybox[$ bold(c)^T [partial_E (hat(v)^(-1) + J)]_(E = -E_B) thin bold(c) = 1 $]
]

#slide[Task 7, Step 6: The wave function from the residue][
  Near the pole $T tilde.eq (X^"out" bold(c))(bold(c)^T X^"in") \/ (E + E_B)$. The meson-pair block of the full resolvent, with our sign of $G$,
  $ P_M (E - cal(H) + i epsilon)^(-1) P_M = -(H_0 + V(E) - E)^(-1) = -G + G T G $
  has the residue $ket(Psi_M) bra(Psi_M)$ at the bound state. Compare the residues:
  #keybox[$
    ket(Psi_M) = -G X^"out" bold(c) = -G (1 - T_U G) F bold(c) = -K F bold(c), quad Psi_alpha (p) = -G_alpha (k, p) sum_i X^"out"_(i, alpha)(p) thin c_i
  $]
  - the overall sign is a phase convention; $F$ injects into channel 1 only, $K$ spreads it into all channels: the $D$-wave content
  - check: $(G^(-1) + U) ket(Psi_M) = -F bold(c)$ and $W ket(Psi_M) = -F hat(v) J bold(c) = F bold(c)$, since $J bold(c) = -hat(v)^(-1) bold(c)$; so #box($(H_0 + U + W - E) ket(Psi_M) = 0$)
]

#slide[Task 7, Step 7: Compact amplitudes and $cal(P)_(macron(b) b)$][
  From the compact-sector equation:
  $ lambda_n = braket(n, Psi) = mel(n, hat(g)^dagger, Psi_M) / (E - E_n) = (g braket(f_n, Psi_M)) / (E - E_n) $
  The pole condition gives
  $ F^dagger ket(Psi_M) = -F^dagger K F bold(c) = -J bold(c) = hat(v)^(-1) bold(c) quad arrow.r.double quad braket(f_n, Psi_M) = (E - E_n) / g^2 thin c_n $
  With $v_n^(-1) = (E - E_n) \/ g^2$ and $partial_E C^(-1) = 0$:
  #keybox[$
    lambda_n = c_n / g, quad bold(c)^T (partial_E hat(v)^(-1)) thin bold(c) = sum_(n = 1)^N c_n^2 / g^2 = sum_n lambda_n^2 = cal(P)_(macron(b) b)
  $]
  the compact probability of Task 1, read off from the residue
]

#slide[Task 7, Step 8: The derivative of $J$ and the sum rule][
  $K^(-1) = G^(-1) + U(E) = H_0 - E + U(E)$, so
  $ partial_E K = -K (partial_E K^(-1)) K = K (1 - partial_E U) K, quad partial_E J = F^dagger K (1 - partial_E U) K F $
  (for an $E$-independent $U$ this would be $F^dagger K^2 F$). With $K F bold(c) = -ket(Psi_M)$:
  $ bold(c)^T (partial_E J) thin bold(c) = braket(Psi_M, Psi_M) - mel(Psi_M, partial_E U, Psi_M) = sum_alpha cal(P)_alpha + cal(P)_"3-body" $
  Add the two pieces of $bold(c)^T partial_E (hat(v)^(-1) + J) thin bold(c) = 1$:
  #keybox[$ 1 = cal(P)_(macron(b) b) + cal(P)_S + cal(P)_D + cal(P)_"3-body", quad cal(P)_S = cal(P)_1, quad cal(P)_D = cal(P)_2 + cal(P)_3 $]
  - the paper differentiates the LSE, $partial_E T_U = (1 - T_U G) thin partial_E U thin (1 - G T_U) - T_U G^2 T_U$; via $K^(-1)$ is shorter and needs no $U^(-1)$
]

#slide[Task 7, Step 9: The three-body probability explicitly][
  $partial_E$ acts only on the TOPT denominators: $partial_E nu_beta = -1$, so
  $ partial_E D_beta = 1 / (2 E_phi (q) [E_phi (q) + nu_beta]^2) $
  #keybox[$
    cal(P)_"3-body" = -sum_(alpha', alpha) integral_0^Lambda (p'^2 dif p') / (2 pi^2) integral_0^Lambda (p^2 dif p) / (2 pi^2) thin Psi^*_(alpha')(p') thin partial_E V^"(OME)"_(alpha' alpha)(p', p; E) thin Psi_alpha (p) |_(E = -E_B)
  $]
  - if $hat(U) = V^"(OME)"$ (Step 4), this is $norm(P_phi Psi)^2 = norm((E - H_(phi phi))^(-1) hat(g)_phi Psi_M)^2 >= 0$
  - the two-body parts: $cal(P)_alpha = integral_0^Lambda (q^2 dif q) / (2 pi^2) |Psi_alpha (q)|^2$ with $Psi_alpha (p) = -G_alpha (k, p) sum_i X^"out"_(i, alpha)(p) thin c_i$
  - everything comes from the residue vector $bold(c)$ and the OME solution: nothing beyond the scattering calculation is needed
]

#slide(refs: [reviews: Hyodo 2013; Guo _et al._, RMP 90, 015004 (2018); Kinugawa, Hyodo 2025])[Task 7, Step 10: $S$-wave compositeness and its limits][
  #keybox[$ X_S = cal(P)_S + cal(P)_("3-body", S), quad cal(P)_("3-body", S) = -mel(Psi_1, partial_E V^"(OME)"_11, Psi_1) $]
  both from the $S$-wave component $Psi_1$ of the _full_ coupled-channel solution: the $S$–$D$–$S$ iterations are inside $Psi_1$. Limits:
  - the three-body states reached from $S$ and from $D$ overlap: $cal(P)_"3-body"$ also contains #box($-2 op("Re") mel(Psi_S, partial_E U, Psi_D)$), which $X_S$ leaves out; $X_S$ is not a sum of orthogonal probabilities
  - it inherits the caveat of Step 4
  - probabilities only for normalised bound states; for a resonance $E$ and $bold(c)$ are complex
  - the components depend on basis, regulator and model, and are not observables; only for a shallow $S$-wave bound state with contact interactions is the $S$-wave compositeness model independent
]
