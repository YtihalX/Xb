#import "../style.typ": *
#import "@preview/cetz:0.4.2"

// The three symmetries of two static sources, redrawn from the speech's TikZ figure.
#let bo-figure() = cetz.canvas(length: 1.4cm, {
  import cetz.draw: *
  let tip = (end: "stealth", fill: black, scale: 0.9)
  let axis-stroke = (paint: gray, dash: "dashed", thickness: 0.7pt)
  let src(pos, quark) = circle(pos, radius: 0.12, fill: if quark { black } else { white }, stroke: 1.1pt)
  let lbl(pos, anchor, body) = content(pos, text(size: 17pt, body), anchor: anchor, padding: 0.08)
  let note(pos, body) = content(pos, align(center, text(size: 15pt, body)), anchor: "north")

  // (a) rotations about the axis
  circle((0, 0), radius: (1.9, 0.7), fill: luma(235), stroke: none)
  line((-2.3, 0), (2.5, 0), stroke: axis-stroke, mark: (end: "stealth", fill: gray, scale: 0.9))
  lbl((2.5, 0), "west", [$hat(bold(r)) = hat(z)$])
  src((-1.1, 0), false)
  lbl((-1.1, -0.15), "north", [$macron(b)$])
  src((1.1, 0), true)
  lbl((1.1, -0.15), "north", [$b$])
  arc((2.05, 0.55), start: 90deg, stop: -200deg, radius: (0.18, 0.55), stroke: 1.1pt, mark: tip)
  lbl((2.05, 0.6), "south", [$R_(hat(z))(phi)$])
  note((
    0,
    -1.15,
  ))[*(a)* rotations about the axis \ conserve $lambda_l = arrow(j)_l dot hat(bold(r))$ \ $Lambda = |lambda_l|$: $Sigma, Pi, Delta, dots$]

  // (b) CP: P swaps the positions, C swaps b and bbar back
  let row(y, left-quark) = {
    line((4.7, y), (6.7, y), stroke: 0.7pt + gray)
    src((4.7, y), left-quark)
    src((6.7, y), not left-quark)
    lbl((4.55, y), "east", if left-quark [$b$] else [$macron(b)$])
    lbl((6.85, y), "west", if left-quark [$macron(b)$] else [$b$])
  }
  row(0.8, false)
  row(0, true)
  row(-0.8, false)
  line((5.7, 0.65), (5.7, 0.15), stroke: 1.1pt, mark: tip)
  lbl((5.8, 0.4), "west", text(size: 14pt)[$P$: $arrow(r) arrow.r -arrow(r)$])
  line((5.7, -0.15), (5.7, -0.65), stroke: 1.1pt, mark: tip)
  lbl((5.8, -0.4), "west", text(size: 14pt)[$C$: $b arrow.l.r macron(b)$])
  note((
    5.7,
    -1.15,
  ))[*(b)* $C P$ maps the configuration \ onto itself: eigenvalue \ $eta = g space (+1)$ or $u space (-1)$]

  // (c) reflection through a plane containing the axis
  line((9.1, -0.35), (12.7, -0.35), (13.1, 0.35), (9.5, 0.35), close: true, fill: luma(245), stroke: 0.6pt + gray)
  lbl((9.48, -0.2), "center", text(size: 13pt, fill: gray)[$x z$])
  line((9.0, 0), (13.2, 0), stroke: axis-stroke)
  src((10.0, 0), false)
  src((12.2, 0), true)
  circle((11.3, 0.9), radius: 0.05, fill: black, stroke: none)
  lbl((11.4, 0.9), "west", text(size: 14pt)[$(x, y, z)$])
  circle((11.3, -0.9), radius: 0.05, fill: gray, stroke: none)
  lbl((11.4, -0.9), "west", text(size: 14pt)[$(x, -y, z)$])
  line(
    (11.3, 0.78),
    (11.3, -0.78),
    stroke: (dash: "dotted", thickness: 0.8pt),
    mark: (
      start: "stealth",
      end: "stealth",
      fill: black,
      scale: 0.7,
    ),
  )
  line((9.2, 0.75), (9.7, 0.75), stroke: 0.8pt, mark: (end: "stealth", fill: black, scale: 0.6))
  lbl((9.7, 0.75), "west", text(size: 14pt)[$z$])
  line((9.2, 0.75), (9.2, 1.2), stroke: 0.8pt, mark: (end: "stealth", fill: black, scale: 0.6))
  lbl((9.2, 1.2), "south", text(size: 14pt)[$y$])
  line((9.2, 0.75), (9.0, 0.4), stroke: 0.8pt, mark: (end: "stealth", fill: black, scale: 0.6))
  lbl((9.0, 0.4), "east", text(size: 14pt)[$x$])
  note((
    11.1,
    -1.15,
  ))[*(c)* $M_(x z) = P R_y (pi)$: $y arrow.r -y$, \ sources stay put, $lambda_l arrow.r -lambda_l$ \ $arrow.r.double$ $sigma = plus.minus$ only for $Lambda = 0$]
})

// Schematic BO static energies, after Berwein, Brambilla, Tarrús Castellà, Vairo, PRD 92, 114019 (2015).
// Only used by the commented-out slide below.
#let bo-energies-sketch() = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let at(x, y) = ((x - 130) * 0.0095, (940 - y) * 0.0095) // traced on a 1494 x 1018 grid
  let green = rgb("#5aab3a")
  let curve(..pts) = catmull(..pts.pos().map(p => at(..p)), tension: 0.5, stroke: 1.2pt)
  let level(x0, x1, y) = line(at(x0, y), at(x1, y), stroke: (dash: "dashed", thickness: 0.9pt))
  let gap(x, y0, y1, scale) = line(at(x, y0), at(x, y1), stroke: 1.4pt + green, mark: (
    start: "stealth",
    end: "stealth",
    fill: green,
    scale: scale,
  ))
  line(at(130, 940), at(130, 8), stroke: 1.1pt, mark: (end: "stealth", fill: black))
  line(at(130, 940), at(1490, 940), stroke: 1.1pt, mark: (end: "stealth", fill: black))
  curve(
    (245, 880), (262, 830), (282, 790), (305, 752), (340, 722), (400, 690), (500, 648), (600, 606),
    (700, 570), (800, 535), (900, 500), (1000, 465), (1100, 430), (1200, 395), (1300, 360), (1405, 325),
  )
  curve(
    (208, 140), (210, 300), (215, 380), (225, 425), (245, 448), (280, 457), (350, 462), (450, 462),
    (550, 455), (650, 445), (750, 432), (850, 412), (950, 385), (1050, 360), (1150, 335), (1250, 310),
    (1405, 258),
  )
  curve(
    (285, 456), (350, 452), (450, 438), (550, 416), (650, 390), (750, 362), (850, 333), (950, 300),
    (1050, 262), (1150, 230), (1250, 200), (1405, 152),
  )
  level(220, 945, 383)
  level(218, 830, 417)
  level(245, 590, 443)
  level(130, 300, 762)
  level(130, 281, 793)
  level(130, 266, 823)
  level(130, 254, 853)
  gap(380, 468, 696, 0.8)
  gap(290, 818, 872, 0.45)
  content(at(398, 575), text(size: 14pt)[$Delta tilde Lambda_"QCD"$], anchor: "west")
  content(at(315, 845), text(size: 13pt)[$E tilde m_Q v^2$], anchor: "west")
  content(at(1222, 140), text(size: 16pt)[$Sigma_u^-$])
  content(at(1222, 262), text(size: 16pt)[$Pi_u$])
  content(at(1225, 462), text(size: 16pt)[$Sigma_g^+$])
  content(at(55, 475), text(size: 15pt)[$E^((0))_(Lambda_eta^sigma)(r)$], angle: 90deg)
  content(at(1405, 985), text(size: 15pt)[$r$])
})

// ---------------------------------------------------------------------------
#slide[BO symmetry: rotations about the axis][
  - angular momentum comes from the SO(3) rotational symmetry of our theory
  - static $b$ and $macron(b)$ fix an axis: only rotations about it remain, SO(3) $arrow.r$ cylindrical symmetry
  - conserved: $lambda_l = arrow(j)_l dot hat(bold(r))$, with $arrow(j)_l$ the total angular momentum of the light d.o.f.; #h(0.2em) $Lambda = |lambda_l|$, written $Sigma, Pi, Delta, dots$ for $Lambda = 0, 1, 2, dots$
  #v(0.5em)
  #align(center, bo-figure())
  #caption[Two static sources at $plus.minus arrow(r) \/ 2$ on the $z$ axis; filled: $b$, open: $macron(b)$, shaded: light degrees of freedom]
]

#slide[BO symmetry: $C P$ and reflections][
  - $eta = C P$: $P$ swaps the positions of $b$ and $macron(b)$, $C$ exchanges quark and antiquark, so the configuration is restored (panel b); #h(0.2em) $eta = g$ $(+1)$ or $u$ $(-1)$
  - $sigma = plus.minus$: reflection through a plane containing the axis; take $arrow(r)$ along $z$ and the $x z$ plane (panel c):
  $
    M_(x z) = P R_y (pi): quad (x, y, z) stretch(arrow.r, size: #3em)^(R_y (pi)) (-x, y, -z) stretch(arrow.r, size: #3em)^P (x, -y, z)
  $
  - the sources stay put; on a light state
  $
    P R_y (pi) ket(j_l\, lambda_l) = P (-1)^(j_l - lambda_l) ket(j_l\, -lambda_l) quad arrow.r.double quad sigma ket(j_l\, 0) = P (-1)^(j_l) ket(j_l\, 0)
  $
  - for $lambda_l != 0$ the reflection maps $lambda_l arrow.r -lambda_l$: a degenerate pair, so $sigma$ is quoted only for $Lambda = 0$
]

/* BO static energies, commented out.
#slide(refs: [schematic after Berwein, Brambilla, Tarrús Castellà, Vairo, PRD 92, 114019 (2015)])[BO static energies][
  #grid(
    columns: (1.3fr, 1fr),
    column-gutter: 1.2em,
    align: horizon,
    bo-energies-sketch(),
    [
      - static energies $E^((0))_(Lambda_eta^sigma)(r)$ carry the BO labels
      - $Sigma_g^+$: the ground state of the gluon field, quarkonium
      - $Pi_u$, $Sigma_u^-$: excited gluon fields (hybrids)
      - gap $Delta tilde Lambda_"QCD"$ #h(0.2em) $>>$ #h(0.2em) level spacing $E tilde m_Q v^2$: the heavy quarks move in one static energy (Born–Oppenheimer)
    ],
  )
]
*/
