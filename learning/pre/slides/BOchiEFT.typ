// BOχEFT and its application to X_b: the talk.
// Assembled from main-v2.typ (Tasks 1–3) and continue.typ (Tasks 4–6, there numbered 5–7; the
// contact-term task is not part of this talk), in the order of ../speech.tex, whose cleaned text
// is the speaker notes.
// Build:       typst compile BOchiEFT.typ
// With notes:  typst compile --input notes=true BOchiEFT.typ BOchiEFT-notes.pdf
//              (each page: the slide, and its speaker note in a panel on the right)
// Typst 0.15; fetches @preview/cetz:0.4.2 on first use.

#import "@preview/cetz:0.4.2"

#let gray-text = luma(105)
#let rule-gray = luma(160)
#let key-stroke = rgb(0%, 0%, 45%) // xcolor blue!45!black, the notes' keybox frame
#let key-fill = rgb(97%, 97%, 100%) // xcolor blue!3, the notes' keybox background

/// Speaker notes are shown only when compiled with `--input notes=true`.
#let notes-mode = sys.inputs.at("notes", default: "false") == "true"
#let slide-width = 297mm // paper "presentation-16-9"
#let slide-height = 167.0625mm

/// Page and text setup; apply with `#show: deck`. In notes mode a page is two slides wide and the
/// right half holds the speaker note.
#let deck(body) = {
  set page(
    width: if notes-mode { 2 * slide-width } else { slide-width },
    height: slide-height,
    margin: (
      left: 1.5cm,
      right: if notes-mode { slide-width + 1.5cm } else { 1.5cm },
      top: 1.0cm,
      bottom: 1.25cm,
    ),
    footer: context {
      let n = counter(page).get().first()
      let total = counter(page).final().first()
      if n > 1 { align(right, text(size: 11pt, fill: gray-text)[#n/#total]) }
    },
    background: if notes-mode {
      place(top + left, dx: slide-width, line(angle: 90deg, length: 100%, stroke: 0.5pt + rule-gray))
    },
  )
  set text(font: "New Computer Modern", size: 18pt, lang: "en")
  set par(leading: 0.8em, spacing: 1.0em)
  set list(spacing: 0.9em, indent: 0.3em)
  show math.equation.where(block: true): set block(above: 0.85em, below: 0.85em)
  set table(stroke: none, inset: (x: 0.45em, y: 0.3em))
  body
}

/// Speaker note of the current slide, put at the start of the slide body. Shown in the right
/// half of the page in notes mode, nowhere otherwise.
#let speaker-note(body) = if notes-mode {
  place(top + left, dx: slide-width, block(width: slide-width - 3cm, {
    set text(size: 16pt)
    set par(leading: 0.65em, spacing: 0.9em)
    body
  }))
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

/// Small gray caption under a figure.
#let caption(body) = align(center, text(size: 12pt, fill: gray-text, body))

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
#let um = math.class("unary", sym.minus)

// ------------------------------------------------------------------ plots (cetz)

/// Tick label with `digits` decimals and a real minus sign.
#let tick-label(v, digits) = {
  let parts = str(calc.round(calc.abs(v), digits: digits)).split(".")
  let frac = if parts.len() > 1 { parts.at(1) } else { "" }
  let s = if digits == 0 { parts.at(0) } else { parts.at(0) + "." + frac + "0" * (digits - frac.len()) }
  if v < 0 { $-#s$ } else { $#s$ }
}

/// Framed axes of `size` (cm) for a line plot. `body(xy)` returns cetz drawing
/// commands; `xy(x, y)` maps data coordinates to the canvas.
#let line-plot(
  size: (12, 7),
  x-range: (0, 1),
  y-range: (0, 1),
  x-ticks: (),
  y-ticks: (),
  x-digits: 0,
  y-digits: 0,
  x-label: none,
  y-label: none,
  y-label-gap: 1.3,
  tick-size: 12pt,
  label-size: 14pt,
  body,
) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let (w, h) = size
  let (x0, x1) = x-range
  let (y0, y1) = y-range
  let xy(x, y) = ((x - x0) / (x1 - x0) * w, (y - y0) / (y1 - y0) * h)
  body(xy)
  rect((0, 0), (w, h), stroke: 0.6pt)
  for t in x-ticks {
    let x = xy(t, y0).at(0)
    line((x, 0), (x, 0.12), stroke: 0.6pt)
    content((x, -0.12), text(size: tick-size, tick-label(t, x-digits)), anchor: "north")
  }
  for t in y-ticks {
    let y = xy(x0, t).at(1)
    line((0, y), (0.12, y), stroke: 0.6pt)
    content((-0.12, y), text(size: tick-size, tick-label(t, y-digits)), anchor: "east")
  }
  if x-label != none {
    content((w / 2, -0.12 - 1.5 * tick-size / 1cm), text(size: label-size, x-label), anchor: "north")
  }
  if y-label != none { content((-y-label-gap, h / 2), text(size: label-size, y-label), angle: 90deg) }
})

/// Pieces of a polyline (array of (x, y)) with y-min ≤ y ≤ y-max, cut exactly at the edges.
#let clip-y(points, y-min, y-max) = {
  let inside(p) = p.at(1) >= y-min and p.at(1) <= y-max
  let cut(a, b) = {
    let y = if calc.max(a.at(1), b.at(1)) > y-max { y-max } else { y-min }
    (a.at(0) + (y - a.at(1)) / (b.at(1) - a.at(1)) * (b.at(0) - a.at(0)), y)
  }
  let pieces = ()
  let piece = ()
  let prev = none
  for p in points {
    if prev != none and inside(p) != inside(prev) {
      piece.push(cut(prev, p))
      if not inside(p) {
        pieces.push(piece)
        piece = ()
      }
    }
    if inside(p) { piece.push(p) }
    prev = p
  }
  pieces.push(piece)
  pieces.filter(c => c.len() > 1)
}

/// A curve in data coordinates, clipped to `y-range`.
#let plot-curve(xy, points, y-range, stroke) = {
  import cetz.draw: line
  for piece in clip-y(points, ..y-range) { line(..piece.map(p => xy(..p)), stroke: stroke) }
}

/// Legend: one row per (stroke, label), going down from `origin` (canvas cm).
#let plot-legend(origin, rows, step: 0.5, sample: 0.8, size: 11pt) = {
  import cetz.draw: content, line
  let (x, y) = origin
  for (i, (stroke, label)) in rows.enumerate() {
    line((x, y - i * step), (x + sample, y - i * step), stroke: stroke)
    content((x + sample + 0.15, y - i * step), text(size: size, label), anchor: "west")
  }
}

// The paper's Fig. 1: the 3P1 bottomonium turns into an S-wave B Bbar* pair through g-hat;
// the heavy quarks are spectators.
#let transition-diagram() = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let head(pos, angle) = {
    let (x, y) = pos
    let (c, s) = (calc.cos(angle), calc.sin(angle))
    line(
      (x + 0.12 * c, y + 0.12 * s),
      (x - 0.12 * c - 0.09 * s, y - 0.12 * s + 0.09 * c),
      (x - 0.12 * c + 0.09 * s, y - 0.12 * s - 0.09 * c),
      close: true,
      fill: black,
      stroke: none,
    )
  }
  let label(pos, anchor, body) = content(pos, text(size: 12pt, body), anchor: anchor, padding: 0.08)
  // heavy quarks go straight through
  line((0.9, 4.26), (7.9, 4.26), stroke: 0.8pt)
  line((0.9, 1.6), (7.9, 1.6), stroke: 0.8pt)
  head((2.6, 4.26), 180deg)
  head((6.2, 4.26), 180deg)
  head((2.66, 1.6), 0deg)
  head((6.24, 1.6), 0deg)
  // light quark pair created inside the box
  line((5.3, 3.8), (7.9, 3.8), stroke: 0.8pt)
  line((5.3, 2.06), (7.9, 2.06), stroke: 0.8pt)
  arc((5.3, 3.8), start: 90deg, stop: 270deg, radius: (0.86, 0.87), stroke: 0.8pt)
  head((6.6, 3.8), 0deg)
  head((6.6, 2.06), 180deg)
  head((4.44, 2.93), 90deg)
  rect((3.0, 1.04), (5.84, 4.8), stroke: 0.6pt + red)
  label((4.42, 1.0), "north", text(fill: red)[$hat(g)$])
  label((0.85, 4.26), "east", [$macron(b)$])
  label((0.85, 1.6), "east", [$b$])
  label((7.95, 4.3), "west", [$macron(b)$])
  label((7.95, 3.78), "west", [$q$])
  label((7.95, 2.1), "west", [$macron(q)$])
  label((7.95, 1.56), "west", [$b$])
  label((2.05, 2.93), "center", [$pw(3, P, 1) thin [b macron(b)]$])
  label((6.95, 2.93), "center", [$pw(3, S, 1) thin [B macron(B)^*]$])
})

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

// Eigenvalues (solid) and diagonal "diabatic" entries (dashed) of the lattice model H(r),
// Bulava et al. 2024 Eq. (6), computed from the parameters in the table (as code/figs.py).
#let lattice-levels-plot() = {
  let hbarc = 0.1973269804 // GeV fm
  let sqrt-t0 = 0.1443 // fm
  let gev(a) = a / sqrt-t0 * hbarc // lattice units -> GeV
  let (v0, e1, e2, gl, gs) = (-0.835, 0.0034, 0.1005, 0.0256, 0.0134).map(gev)
  let sigma = 0.1061 / (sqrt-t0 * sqrt-t0) * hbarc * hbarc // GeV^2
  let gamma = -0.434
  let v-string(r) = v0 + sigma * r / hbarc + gamma * hbarc / r // V(r) [GeV], r [fm]
  // eigenvalues of a real symmetric 3 x 3 matrix, ascending (trigonometric closed form)
  let eigenvalues(a11, a22, a33, a12, a13, a23) = {
    let q = (a11 + a22 + a33) / 3
    let off = a12 * a12 + a13 * a13 + a23 * a23
    let p = calc.sqrt((calc.pow(a11 - q, 2) + calc.pow(a22 - q, 2) + calc.pow(a33 - q, 2) + 2 * off) / 6)
    let (b11, b22, b33, b12, b13, b23) = (a11 - q, a22 - q, a33 - q, a12, a13, a23).map(v => v / p)
    let det = b11 * (b22 * b33 - b23 * b23) - b12 * (b12 * b33 - b23 * b13) + b13 * (b12 * b23 - b22 * b13)
    let phi = calc.acos(calc.max(-1, calc.min(1, det / 2))) / 3
    let hi = q + 2 * p * calc.cos(phi)
    let lo = q + 2 * p * calc.cos(phi + 120deg)
    (lo, 3 * q - hi - lo, hi)
  }
  let rs = range(351).map(i => 0.25 + i * 0.005)
  let levels = rs.map(r => eigenvalues(v-string(r), e1, e2, calc.sqrt(2) * gl, gs, 0))
  let (blue, green, red) = (rgb("#1f77b4"), rgb("#2ca02c"), rgb("#d62728")) // matplotlib tab: colours
  let y-range = (-500, 400)
  line-plot(
    size: (14.2, 7.4),
    x-range: (0.25, 2.0),
    y-range: y-range,
    x-ticks: (0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0),
    x-digits: 1,
    y-ticks: (-400, -200, 0, 200, 400),
    x-label: [$r$ [fm]],
    y-label: [$E - 2 E_(macron(Q) l)$ [MeV]],
    y-label-gap: 1.5,
    xy => {
      import cetz.draw: *
      let dashed(paint) = (paint: paint, dash: "dashed", thickness: 0.9pt)
      plot-curve(xy, rs.map(r => (r, 1000 * v-string(r))), y-range, dashed(gray))
      line(xy(0.25, 1000 * e1), xy(2.0, 1000 * e1), stroke: dashed(blue))
      line(xy(0.25, 1000 * e2), xy(2.0, 1000 * e2), stroke: dashed(green))
      for k in range(3) {
        plot-curve(xy, rs.zip(levels).map(((r, l)) => (r, 1000 * l.at(k))), y-range, 1.5pt)
      }
      line(xy(1.211, -500), xy(1.211, 400), stroke: (paint: red, dash: "dotted", thickness: 0.8pt))
      content(xy(1.17, 330), text(size: 11pt, fill: red)[$r_l^star = 1.21$ fm], anchor: "east")
      plot-legend(xy(1.08, -250), (
        (dashed(gray), [$hat(V)(r)$ (string, diabatic)]),
        (dashed(blue), [$hat(E)_1$ ($B macron(B)$, diabatic)]),
        (dashed(green), [$hat(E)_2$ ($B_s macron(B)_s$, diabatic)]),
        (1.5pt, [eigenvalues (adiabatic levels)]),
      ))
    },
  )
}

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
    ((1.85, 1.2), "east", $phi.alt(-bold(q))$),
    [(1) #h(0.2em) $B macron(B) phi.alt$],
  ),
  topt-diagram(
    ((0, 1, false), (1, 4, true)),
    ((0, 3, true), (3, 4, false)),
    ((1, 2), (3, 0)),
    ($B(bold(p))$, $B^*(bold(p)')$, $macron(B)^*(-bold(p))$, $macron(B)(-bold(p)')$),
    ((2.15, 1.2), "west", $phi.alt(bold(q))$),
    [(2) #h(0.2em) $B^* macron(B)^* phi.alt$],
  ),
  topt-diagram(
    ((0, 3, false), (3, 4, true)),
    ((0, 4, true),),
    ((1, 0), (3, 2)),
    ($B(bold(p))$, $B^*(bold(p)')$, $macron(B)^*(-bold(p))$, $macron(B)^*(-bold(p)')$),
    ((1.85, 1.2), "east", $phi.alt(-bold(q))$),
    [(3) #h(0.2em) $B macron(B)^* phi.alt$],
  ),
  topt-diagram(
    ((0, 1, true), (1, 4, false)),
    ((0, 4, true),),
    ((1, 2), (3, 0)),
    ($B^*(bold(p))$, $B(bold(p)')$, $macron(B)^*(-bold(p))$, $macron(B)^*(-bold(p)')$),
    ((2.15, 1.2), "west", $phi.alt(bold(q))$),
    [(4) #h(0.2em) $macron(B)^* B phi.alt$],
  ),
)

#set document(title: "BOχEFT and its application to Xb", author: "Yu Zhang")
#show: deck

#title-slide(
  [BO$chi$EFT and its application to $X_b$],
  [Yu Zhang],
  [Institute of Theoretical Physics, Chinese Academy of Sciences \
    University of Chinese Academy of Sciences],
)
#speaker-note[I'm going to talk about BO$chi$EFT and its application to the $X_b$.]

// --------------------------------------------------------------- introduction

#slide[BOχEFT approach to ordinary and exotic hadrons][
  #speaker-note[So why a BO$chi$EFT? Well, we have two sources of information in hadronic physics. One is lattice QCD, which we believe to be a first-principles calculation; here we use its results for the static interquark potential as an input for the short-range physics. The other is high-energy experiments, whose line shapes and branching fractions give us information about the long-range physics. But how do we incorporate both sources of information in a single approach?

  In BOEFT, one solves coupled Schrödinger equations in coordinate space. In this formalism there is a direct correspondence to the lattice potentials, so the short-range physics is naturally captured. But the hadronic degrees of freedom are missing, and the long-range forces can only be parametrised. Here, in BO$chi$EFT, we solve coupled Lippmann–Schwinger equations in momentum space, where we can include the long-range physics systematically, including multibody effects and exchanges. The tricky part is that the connection to the short-range physics is nontrivial. We hope to merge both approaches into a unified, systematically improvable method.]
  Main sources of information on hadronic states:
  - #text(fill: blue)[Lattice QCD] $->$ First principle calculations of static interquark potentials, including string breaking effects $->$ input for #text(fill: rgb("#FF6600"))[short-range physics]
  - #text(fill: blue)[High-energy experiment] $->$ Line shapes and branching fractions in terms of hadronic states $->$ input for #text(fill: rgb("#FF6600"))[long-range physics]

  #text(fill: red)[*Problem: How to incorporate both sources of information in a single approach?*]

  #text(fill: blue)[BOEFT] (Braaten, Brambilla, et al.): Coupled Schrödinger equations in coordinate space
  - #text(fill: rgb("#FF6600"))[Pro:] Direct correspondence to lattice potentials $->$ short-range physics naturally captured
  - #text(fill: rgb("#FF6600"))[Con:] Missing connection to hadronic degrees of freedom $->$ long-range physics parametrised

  #text(fill: blue)[BOχEFT]: Coupled Lippmann-Schwinger equations in momentum space:
  - #text(fill: rgb("#FF6600"))[Pro:] Long-range physics naturally captured, including multibody effects and exchanges
  - #text(fill: rgb("#FF6600"))[Con:] Connection to short-range physics is nontrivial (comes as chiral expansion in $p^2/Lambda^2$)
  #text(fill: red)[*Hope: Merge both approaches to unified systematically improvable method*]

]

#slide[Proof-of-concept BO$chi$EFT calculation at LO][
  Consider scattering problem for $B macron(B)^*$ system with $J^(italic(P) italic(C)) =1^(++)$ via potential
  $ V = V^"(OME)" + sum_(n = 1)^N V_n^((macron(b) b)) + C(Lambda, N) $
  - #text(fill: blue)[_t_-channel meson exchanges] $->$ potential #text(fill: red)[$V^"(OME)"$]:\ No free parameters
  #v(1em)
  - #text(fill: blue)[_s_-channel exchange of bottomonium states] $->$ potential #text(fill: red)[$V^((macron(b) b))$]:\ Parameters of interquark interaction and strength of transition $macron(b)b ->B macron(B)^*$ can be extracted from lattice-QCD calculations
  #v(1em)
  - #text(fill: blue)[Short-range counterterm] $->$  #text(fill: red)[$C$]:\ Absorbs all neglected effects
  #v(1em)
  Remaining free parameters can be fixed to the experimental spectrum of $chi_(b 1)$ bottomonia

]

// --------------------------------------------------------------- BO symmetry, lattice input, channels

#slide[BO symmetry: rotations around the axis between two sources][
  #speaker-note[Before diving into the formalism, let's first look at the BO symmetry. We consider a doubly heavy system with two heavy sources, and BO symmetry here means the cylindrical symmetry. As you know, angular momentum comes from the SO(3) rotational symmetry of the theory. But in the Born–Oppenheimer separation the light degrees of freedom see only two static heavy colour sources, so only rotations about the axis remain, and SO(3) reduces to a cylindrical symmetry. Thus only the projection $lambda_l$ of the angular momentum of the light degrees of freedom on the axis is conserved; its absolute value $Lambda$ labels the levels $Sigma, Pi, Delta, dots$]
  - angular momentum comes from the SO(3) rotational symmetry of our theory
  - static $b$ and $macron(b)$ fix an axis: only rotations about it remain, SO(3) $arrow.r$ cylindrical symmetry
  - conserved: $lambda_l = arrow(j)_l dot hat(bold(r))$, with $arrow(j)_l$ the total angular momentum of the light d.o.f.; #h(0.2em) $Lambda = |lambda_l|$, written $Sigma, Pi, Delta, dots$ for $Lambda = 0, 1, 2, dots$
  #v(0.5em)
  #align(center, bo-figure())
  #caption[Two static sources at $plus.minus arrow(r) \/ 2$ on the $z$ axis; filled: $b$, open: $macron(b)$, shaded: light degrees of freedom]
]

#slide[BO symmetry: $C P$ and reflections][
  #speaker-note[There are two discrete symmetries: the combined $C P$ parity $eta$, and a reflection $sigma$ through a plane containing the axis. Since a reflection flips the sign of the angular-momentum projection, only states with $Lambda = 0$ are $sigma$ eigenstates. These quantities are conserved as long as the BO separation holds, so we can use them to label the static energy levels, and to see which levels can mix.]
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

#slide[BO levels and string breaking][
  #speaker-note[The string and $Sigma_g^(+')$ have the same labels, so their levels can't cross; they repel. That avoided crossing is string breaking, and it is what lattice measures.]
  Light states of $ket(B macron(B))$ and of the string, labelled with the BO rules: #h(0.3em) $eta = C P$ of the light degrees of freedom; $sigma = P (-1)^(j_l)$ for $lambda_l = 0$.
  #v(0.3em)
  #align(center, text(size: 16pt, table(
    columns: 7,
    align: (left, center, center, center, center, center, left),
    toprule, [light configuration], [$j_l^(P C)$], [$lambda_l$], [$eta$], [$sigma$], [label],
    [role], midrule, [vacuum (string)], [$0^(+ +)$], [0], [$g$], [$+$],
    [$Sigma_g^+$],
    [compact $macron(b) b$, Cornell potential],
    [$S$-wave pair, light triplet],
    [$1^(- -)$],
    [0],
    [$g$],
    [$+$],

    [$Sigma_g^(+')$],
    [mixes with the string],
    [$S$-wave pair, light triplet],
    [$1^(- -)$],
    [$plus.minus 1$],
    [$g$],
    [–],

    [$Pi_g$], [no direct mixing], [$S$-wave pair, light singlet], [$0^(- +)$], [0], [$u$], [$-$],
    [$Sigma_u^-$], [no direct mixing; cannot give $1^(+ +)$], bottomrule,
  )))
  #v(0.3em)
  - in $ket(B macron(B))$: $ket(1_l\, 0) in Sigma_g^(+')$, #h(0.2em) $ket(1_l\, plus.minus 1) in Pi_g$, #h(0.2em) $ket(0_l\, 0) in Sigma_u^-$; the labels are conserved for static quarks, so only the $ket(1_l\, 0)$ piece mixes with the string
  - $Sigma_g^+$ and $Sigma_g^(+')$ share all labels, so their levels cannot cross $arrow.r$ avoided crossing = string breaking
]

#slide(
  refs: [Bulava _et al._ 2024, Eqs. (6) & (11) and Table 4],
)[What lattice measures: static potential with string breaking][
  #speaker-note[Now, what lattice sees is string breaking. Here, as you can see, the levels of the string and of the $B macron(B)$ pair give an avoided level crossing; these levels are calculated on the lattice. Fitting the spectrum of such a Hamiltonian to the data, we obtain the parameters needed to construct our theory: in particular the transition strength $g_l$ between the string and the $B macron(B)$ pair, which gives the coupling between bottomonium and the heavy mesons, as well as the potential of the string.

Lattice gives us the static energies and the mixing $g_l$ at fixed $r$. To use them, we let the heavy quarks move, and ask which $B^((*)) macron(B)^((*))$ channels carry $1^(+ +)$.]
  #grid(
    columns: (1.45fr, 1fr),
    column-gutter: 1em,
    align: horizon,
    lattice-levels-plot(),
    [
      $
        H(r) = mat(V(r), sqrt(2) g_l, g_s; sqrt(2) g_l, hat(E)_1, 0; g_s, 0, hat(E)_2) \ V(r) = hat(V)_0 + sigma r + gamma / r
      $
    ],
  )
  #align(center, text(size: 16pt, table(
    columns: 8,
    align: (left,) + (center,) * 7,
    toprule, [], [$hat(E)_1$], [$hat(E)_2$], [$g_l$], [$g_s$], [$sigma$], [$hat(V)_0$],
    [$gamma$], midrule, [units of $t_0$], [0.0034(3)], [0.1005(7)], [0.0256(3)], [0.0134(4)], [0.1061(7)],
    [$-0.835(7)$], [$-0.434(11)$], [physical], [5 MeV], [137 MeV], [*35 MeV*], [18 MeV], [*0.198 GeV#super[2]*],
    [$-1.14$ GeV], [$bold(-0.434)$], bottomrule,
  )))
  - $sqrt(t_0) = 0.1443(7)(13)$ fm
]

#slide[Quantum numbers of $1^(+ +)$ pair][
  #speaker-note[This will be central in the later analysis of the BO symmetry. Since we are studying the $1^(+ +)$ state, parity makes $L$ even, and $C$ then makes $s_H + j_l$ even. $(s_H, j_l) = (0, 0)$ would give $J = L$, which is even, so both are 1. They couple to total spin 0, 1, 2, and combined with even $L$ to $J = 1$, three channels are available.]
  $
    arrow(J) = arrow(s)_H + arrow(j)_l + arrow(L), quad J^(P C) = 1^(+ +), quad P = (-1)^L, quad C = (-1)^(s_H + j_l + L)
  $
  - $P = +$ makes $L$ even
  - then $C = +$ makes $s_H + j_l$ even: $(s_H, j_l) = (0, 0)$ or $(1, 1)$
  - with $(0, 0)$ we would get $J = L$, which is even and never 1 #h(0.3em) $arrow.r.double$ #h(0.3em) $s_H = j_l = 1$
  $ s_H times.o j_l = 1 times.o 1 = 0 plus.o 1 plus.o 2 $
  combined with $L = 0, 2$ to $J = 1$, this gives the $1^(+ +)$ meson pairs
  $ B macron(B)^* (pw(3, S, 1)), quad B macron(B)^* (pw(3, D, 1)), quad B^* macron(B)^* (pw(5, D, 1)) $
]

#slide[Why exactly three channels][
  #speaker-note[And this is the detailed table with the reasons; I'm not going to explain it carefully here.]
  $P = P_1 P_2 (-1)^L = (-1)^L$; #h(0.3em) $C = (-1)^(L + S)$ for $B macron(B)$ and $B^* macron(B)^*$; #h(0.3em) $B macron(B)^*$: $C = plus.minus (-1)^L$ for $(ket(B macron(B)^*) minus.plus ket(B^* macron(B))) \/ sqrt(2)$
  #v(0.2em)
  #align(center, text(size: 15.5pt, table(
    columns: 5,
    align: (left, center, center, left, left),
    inset: (x: 0.5em, y: 0.22em),
    toprule, [pair], [$S$], [$L$], [allowed $J^(P C)$],
    [$1^(+ +)$?], midrule, [$B macron(B)$], [0], [$L$],
    [$J = L$: $0^(+ +), 1^(- -), 2^(+ +), dots$], [no], [$B macron(B)^*$, $C$-even], [1], [0],
    [$1^(+ +)$], [*yes:* $pw(3, S, 1)$], [$B macron(B)^*$, $C$-even], [1], [2],
    [$1^(+ +), 2^(+ +), 3^(+ +)$], [*yes:* $pw(3, D, 1)$], [$B macron(B)^*$, $C$-odd], [1], [0, 2],
    [$1^(+ -), dots$], [no], [$B^* macron(B)^*$], [0], [0],
    [$0^(+ +)$], [no], [$B^* macron(B)^*$], [1], [0],
    [$1^(+ -)$], [no], [$B^* macron(B)^*$], [2], [0],
    [$2^(+ +)$], [no], [$B^* macron(B)^*$], [0], [2],
    [$2^(+ +)$], [no], [$B^* macron(B)^*$], [1], [2],
    [$1^(+ -), 2^(+ -), 3^(+ -)$], [no], [$B^* macron(B)^*$], [2], [2],
    [$0^(+ +), dots, 4^(+ +)$], [*yes:* $pw(5, D, 1)$], [any], [$<= 2$], [$>= 4$],
    [$J >= L - S >= 2$], [no], bottomrule,
  )))
]

#slide[The coupled-channel Hamiltonian and the vector of state][
  #speaker-note[So the last piece of the puzzle for the $s$-channel exchange is the actual formalism. To allow transitions between the hadronic degrees of freedom and the bottomonium, we write down the coupled-channel Hamiltonian. It describes the dynamics of the entire system, consisting of the $B macron(B)^*$ meson pairs and the compact bottomonium states. Note that at LO the bottomonia couple only to the $S$-wave $B macron(B)^*$; couplings to other partial waves appear at higher orders.]
  $
    cal(H) = mat(
      H - M_"th", 0, dots.c, hat(g)^dagger;
      0, H - M_"th", dots.c, hat(g)^dagger;
      dots.v, dots.v, dots.down, dots.v;
      hat(g), hat(g), dots.c, H_(M M)
    ) quad "acting on" quad ket(Psi) = mat(lambda_1 ket([macron(b) b]_1 (1P)); lambda_2 ket([macron(b) b]_1 (2P)); dots.v; phi.alt(q) ket(B macron(B)^*))
  $
  #grid(
    columns: (1fr, auto),
    column-gutter: 1.5em,
    align: horizon,
    [
      $ "normalisation:" quad sum_n |lambda_n|^2 + integral (q^2 dif q) / (2 pi^2) |phi.alt(q)|^2 = 1 $
      - $phi.alt(q) = braket(q, Psi)$; $ket(q)$ are the meson-pair states, normalised as $braket(q', q) = (2 pi^2) / q^2 delta(q' - q)$
    ],
    [
      #transition-diagram()
      #caption[$pw(3, P, 1)$ bottomonium $arrow.r$ $S$-wave $B macron(B)^*$ via $hat(g)$; \ the heavy quarks are spectators]
    ],
  )
  Note: At LO $[macron(b) b]_1 (n P)$ bottomonia couple only to $B macron(B)^*(pw(3, S, 1))$ (here simply $B macron(B)^*$); \ coupling to $B macron(B)^*(pw(3, D, 1))$ and $B^* macron(B)^*(pw(5, D, 1))$ appears at higher orders
]

#slide[What to do next?][
  #speaker-note[Next we need to derive the interaction from the Hamiltonian, establish the relation between the BO$chi$EFT channels and the BOEFT levels, and finally obtain the coupling from the lattice, using the results of the first two tasks.]

  - Task 1: Derive $V^((macron(b) b))$ from
    $cal(H)$ and define probabilities for different components of $ket(Psi)$
    $
      hat(V)(E) = sum_(n <= N) (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) + C(N)
    $
  - Task 2: Establish relation between BO$chi$EFT channels and BOEFT levels
  $
    mat(ket(Sigma_g^(+')); ket(Pi_g\; 1); ket(Pi_g\; 2)) = underbrace(mat(1 / sqrt(3), 1 / sqrt(6), -1 / sqrt(2); sqrt(2 / 3), -1 / (2 sqrt(3)), 1 / 2; 0, sqrt(3) / 2, 1 / 2), U) mat(ket(B macron(B)^* (pw(3, S, 1))); ket(B macron(B)^* (pw(3, D, 1))); ket(B^* macron(B)^* (pw(5, D, 1)))) quad quad U U^T = bold(1)
  $
  - Task 3: Relate transition matrix element of $hat(g)$ with the lattice string breaking coupling $g_l$
  $
    |g| = 2 / sqrt(3) sqrt(2) thin g_l = 57 "MeV" quad (g_l = 35 "MeV")
  $


]

// --------------------------------------------------------------- Task 1: the s-channel potential

#slide[Task 1, Step 1: Projectors and the block form of $cal(H)$][
  #speaker-note[To write down the interaction, we first split the Hilbert space into the compact sector and the heavy-meson sector; the two projectors are orthogonal to each other. The projectors separate the Hamiltonian into four blocks; this is nothing but a rewriting of the original Hamiltonian. $H_(Q Q)$ can be diagonalised numerically with the potential obtained from the lattice, and the blocks connecting the two sectors are our transition operator.]
  Split the space into the compact sector $Q$ and the meson-pair sector $M$:
  $
    P_Q = sum_n ket(n) bra(n), quad P_M = integral_0^infinity (q^2 dif q) / (2 pi^2) ket(q) bra(q), quad P_Q + P_M = bold(1), quad P_Q P_M = 0
  $
  Sandwich $cal(H)$ between $bold(1) = P_Q + P_M$ on both sides:
  $
    cal(H) = (P_Q + P_M) cal(H) (P_Q + P_M) = underbrace(P_Q cal(H) P_Q, H_(Q Q)) + underbrace(P_M cal(H) P_M, H_(M M)) + underbrace(P_M cal(H) P_Q, hat(g)) + underbrace(P_Q cal(H) P_M, hat(g)^dagger)
  $
  - $H_(Q Q) = P_Q (H - M_"th") P_Q = sum_n E_n ket(n) bra(n)$
  - $P_Q cal(H) P_M = (P_M cal(H) P_Q)^dagger = hat(g)^dagger$, because $cal(H)$ is Hermitian
  - ordered as (compact, meson pair): $cal(H) = mat(H_(Q Q), hat(g)^dagger; hat(g), H_(M M))$, i.e. the Hamiltonian matrix from before with all bottomonium rows in one block
]

#slide[Task 1, Step 2: Projecting the Schrödinger equation][
  #speaker-note[Next we project the Schrödinger equation; of course you also need to insert an identity here. These intermediate steps are not interesting. After the projection you get two equations coupled by the operator $hat(g)$; if $hat(g)$ were zero, we would get two decoupled Schrödinger equations.]
  Write $cal(H) ket(Psi) = E ket(Psi)$ as $cal(H) (P_Q + P_M) ket(Psi) = E ket(Psi)$ and multiply from the left by $P_Q$:
  $ P_Q cal(H) P_Q ket(Psi) + P_Q cal(H) P_M ket(Psi) = E P_Q ket(Psi) $
  Since $P^2 = P$, put one more projector next to the ket:
  $
    P_Q cal(H) P_Q ket(Psi) = (P_Q cal(H) P_Q)(P_Q ket(Psi)) = H_(Q Q) P_Q ket(Psi), quad P_Q cal(H) P_M ket(Psi) = hat(g)^dagger P_M ket(Psi)
  $
  $ arrow.r.double quad H_(Q Q) P_Q ket(Psi) + hat(g)^dagger P_M ket(Psi) = E P_Q ket(Psi) $
  Multiplying by $P_M$ instead: #h(0.3em) $hat(g) P_Q ket(Psi) + H_(M M) P_M ket(Psi) = E P_M ket(Psi)$. Collecting terms:
  #keybox[$
    (E - H_(Q Q)) P_Q ket(Psi) = hat(g)^dagger P_M ket(Psi), quad (E - H_(M M)) P_M ket(Psi) = hat(g) P_Q ket(Psi)
  $]
]

#slide[Task 1, Step 3: Eliminating the compact states][
  #speaker-note[Now we can invert one of the equations and plug it into the other. This gives a Schrödinger equation for the heavy-meson sector only, in which the compact states contribute through an energy-dependent potential.]
  For $E != E_n$, with the inverse taken inside the compact space:
  $ P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  Plug this into the second equation:
  $ (E - H_(M M)) P_M ket(Psi) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  $H_(Q Q) = sum_n E_n ket(n) bra(n)$ is diagonal, so on the compact space $(E - H_(Q Q))^(-1) = sum_n (ket(n) bra(n)) / (E - E_n)$:
  #keybox[$
    [H_(M M) + hat(V)(E)] P_M ket(Psi) = E P_M ket(Psi), quad hat(V)(E) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger = sum_n (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n)
  $]
  A Schrödinger equation for the heavy mesons alone: the compact states leave behind an energy-dependent potential.
]

#slide[Task 1, Step 4: Truncation and compact amplitudes][
  #speaker-note[We can split this potential into two pieces. The second piece has poles only far away from the threshold, so it is absorbed into the contact term at LO. With this formalism we can also compute the compact probability: this projection gives us the coefficients in front of the compact states.]
  Split $P_Q = P_(<= N) + P_(> N)$:
  $
    hat(V)(E) = sum_(n <= N) (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) + hat(g) P_(> N) (E - H_(Q Q))^(-1) P_(> N) hat(g)^dagger
  $
  - the second piece has no pole near threshold and varies slowly there
  - at LO it is replaced by a constant: the contact term $C(Lambda, N)$, which is why $C$ depends on $N$
  #v(0.6em)
  Projecting $P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi)$ on $bra(n)$ gives the compact amplitudes:
  $ lambda_n = braket(n, Psi) = mel(n, hat(g)^dagger P_M, Psi) / (E - E_n) $
]

#slide[Task 1, Step 5: Normalisation and the compact probability][
  #speaker-note[Since the Hamiltonian is energy independent, we have this derivative rule. Later we will see how this probability is related to the scattering amplitude.]
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

// --------------------------------------------------------------- Task 2: BO configurations and partial waves

#slide[Task 2, Step 1: The BO coupling order][
  #speaker-note[Next we work out the relation between the BO coupling and the partial-wave coupling. There are three possible BO configurations; $J_l = 2$ with $lambda_l = 0$ is absent, because, as we will see, it has odd parity.]
  Two ways to couple $j_l = s_H = 1$ and $L$ to $J = 1$:
  $
    "partial waves:" & quad arrow(S) = arrow(j)_l + arrow(s)_H, quad arrow(J) = arrow(L) + arrow(S) & quad arrow.r quad & ket(L\, (j_l thin s_H) S\; J) \
    "BO:" & quad arrow(J)_l = arrow(L) + arrow(j)_l, quad arrow(J) = arrow(J)_l + arrow(s)_H & quad arrow.r quad & ket((L thin j_l) J_l\, s_H\; J)
  $
  - $L = 0$ gives $J_l = 1$; $L = 2$ gives $J_l = 1, 2, 3$, but $J_l = 3$ cannot couple with $s_H = 1$ to $J = 1$
  #grid(
    columns: (1fr, 1.25fr),
    column-gutter: 1.5em,
    align: horizon,
    align(center, table(
      columns: 5,
      align: center,
      toprule, [$J_l^(P_l C_l)$], [$|lambda_l|$], [$eta$], [$sigma$],
      [BO configuration], midrule, [$1^(- -)$], [0], [$g$],
      [$+$], [$Sigma_g^(+')$], [$1^(- -)$], [1], [$g$],
      [–], [$Pi_g\; 1$], [$2^(- -)$], [1], [$g$],
      [–], [$Pi_g\; 2$], bottomrule,
    )),
    [
      - $J_l = 2$, $lambda_l = 0$ is absent due to the CG coefficient
      $ braket(L = 2\, M_L = 0\; j_l = 1\, M_(j_l) = 0, J_l = 2\, 0) = 0 $
      - three BO configurations, as many as partial-wave channels
    ],
  )
  #v(0.25em)
  #align(center, text(size: 16pt)[$
    eta = P_l C_l = +1 quad (g), quad sigma = P_l (-1)^(J_l) = +1 quad (lambda_l = 0, J_l = 1)
  $])
]

#slide(refs: [Jacob, Wick, Ann. Phys. 7, 404 (1959)])[Task 2, Step 2: Jacob–Wick formula][
  #speaker-note[The BO states only have a definite projection $lambda_l$; we need to connect them with states of definite orbital angular momentum, and this is the Jacob–Wick formula. You can think of it as a modified CG coupling: in the usual CG coupling both angular momenta are quantised along the same fixed axis $z$, while the BO states have a definite projection $lambda_l$ on the moving axis $hat(bold(r))$. Jacob–Wick does the coupling on that axis, where $arrow(L) = arrow(r) times arrow(p)$ has no component, so only $m_L = 0$ survives and the CG coefficient becomes $braket(L thin 0 thin j_l thin lambda_l, J_l thin lambda_l)$; a rotation then carries it to any direction $hat(bold(r))$.]
  The BO states have a definite projection $lambda_l$ of $arrow(j)_l$ on $hat(bold(r))$; the states $ket((L thin j_l) J_l thin M_l)$ have a definite $L$. Jacob–Wick connects them:
  #keybox[$
    ket(J_l thin M_l\; lambda_l) = sum_L sqrt((2L + 1) / (2 J_l + 1)) braket(L thin 0 thin j_l thin lambda_l, J_l thin lambda_l) ket((L thin j_l) J_l thin M_l)
  $]
  - the $0$: $arrow(L) dot hat(bold(r)) = 0$, so all of $lambda_l$ comes from $arrow(j)_l$; the coefficients do not depend on $M_l$
  - then a $6j$ symbol takes definite $L$ to the partial-wave channels:
  $
    underbrace(ket(J_l thin M_l\; lambda_l), "BO state") quad stretch(arrow.l.r, size: #4em)^"Step 1"_"Jacob–Wick" quad underbrace(ket((L thin j_l) J_l), "definite" L) quad stretch(arrow.l.r, size: #4em)^"Step 2"_(6j) quad underbrace(ket(L\, (j_l thin s_H) S\; J), "partial wave")
  $
  - next: derive the formula from the usual Clebsch–Gordan coupling
]

#slide[Deriving Jacob–Wick: start from Clebsch–Gordan][
  #speaker-note[First, we start from the usual CG coupling, written as a function of the direction in position space. Angular momentum is always quantised along a fixed axis, say $z$, but the BO state needs $lambda_l$. So the idea is to first put $hat(bold(r))$ on the $z$ axis, where we have the CG coupling. As said earlier, the orbital angular momentum is $arrow(r) times arrow(p)$, so by definition it has no component along the axis, which you can also see from the spherical harmonics.]
  The usual CG coupling along a fixed axis $hat(z)$, written as a function of the direction $hat(bold(r))$ of the $b macron(b)$ axis (a light-spin state at each $hat(bold(r))$):
  $
    braket(hat(bold(r)), (L thin j_l) J_l thin M_l) = sum_(m_L, m_l) braket(L thin m_L thin j_l thin m_l, J_l thin M_l) Y_(L m_L)(hat(bold(r))) ket(j_l thin m_l)
  $
  - BO needs $lambda_l$, the projection of $arrow(j)_l$ on $hat(bold(r))$, not on the fixed $hat(z)$
  - look on the axis first, $hat(bold(r)) = hat(z)$: there $Y_(L m_L)(hat(z)) = sqrt((2L + 1) \/ 4 pi) thin delta_(m_L 0)$, because $Y_(L m) prop sin^(|m|) theta$. The orbital motion has no projection on its own direction ($arrow(L) dot hat(bold(r)) = 0$), so the CG sum collapses to the $m_L = 0$ term:
  #keybox[$
    braket(hat(z), (L thin j_l) J_l thin M_l) = sqrt((2L + 1) / (4 pi)) braket(L thin 0 thin j_l thin M_l, J_l thin M_l) ket(j_l thin M_l)
  $]
  - on the axis the projection on $hat(z)$ is the projection on $hat(bold(r))$: here $M_l = lambda_l$
]

#slide[Deriving Jacob–Wick: rotate away from the axis][
  #speaker-note[Next, we use a rotation that takes $z$ to the arbitrary direction $hat(bold(r))$; that introduces a Wigner $D$-matrix. Now you see how a multiplet with definite $J$ transforms. We plug this into the CG coupling obtained before and arrive at this equation.]
  $R$: the rotation taking $hat(z)$ to $hat(bold(r))$; $U(R) = U_"orb" (R) thin U_"spin" (R)$ rotates the direction and the light spin; $D^J_(M' M)(R) = mel(J thin M', U(R), J thin M)$.
  - a multiplet of definite $J$ is fixed by its values on the axis:
    $
      braket(R hat(z), J thin M) = sum_lambda D^(J*)_(M lambda)(R) thin U_"spin" (R) braket(hat(z), J thin lambda)
    $
    because $bra(R hat(z)) = bra(hat(z)) U_"orb"^dagger = bra(hat(z)) U_"spin" U^dagger$ and $U^dagger ket(J thin M) = sum_lambda D^(J*)_(M lambda) ket(J thin lambda)$
  - insert the axis values of the previous slide (there $M_l = lambda$):
  #keybox[$
    braket(hat(bold(r)), (L thin j_l) J_l thin M_l) = sqrt((2L + 1) / (4 pi)) sum_lambda braket(L thin 0 thin j_l thin lambda, J_l thin lambda) D^(J_l*)_(M_l lambda)(R) ket(j_l thin lambda)_(hat(bold(r)))
  $]
  - $ket(j_l thin lambda)_(hat(bold(r))) equiv U_"spin" (R) ket(j_l thin lambda)$ is the light spin with projection $lambda$ on $hat(bold(r))$
]

#slide[Deriving Jacob–Wick: identify the BO states and invert][
  #speaker-note[Next, we see that each term is a BO state in position space, so we have the transformation between the BO states and the states with definite orbital angular momentum. But what we really need is the inverse, and that is easy: the transformation is orthogonal, so the inverse is just the transpose.]
  Each term is a BO state, with definite $J_l$, $M_l$ and light projection $lambda$ on $hat(bold(r))$:
  $
    braket(hat(bold(r)), J_l thin M_l\; lambda) = sqrt((2 J_l + 1) / (4 pi)) D^(J_l*)_(M_l lambda)(R) ket(j_l thin lambda)_(hat(bold(r))), quad integral dif Omega thin |D^J_(M lambda)|^2 = (4 pi) / (2 J + 1)
  $
  So the previous slide reads
  $
    ket((L thin j_l) J_l thin M_l) = sum_lambda c_(L lambda) ket(J_l thin M_l\; lambda), quad c_(L lambda) = sqrt((2L + 1) / (2 J_l + 1)) braket(L thin 0 thin j_l thin lambda, J_l thin lambda)
  $
  - $c$ is real and links two orthonormal bases, so it is orthogonal, $c^(-1) = c^T$, which gives the formula of Step 1:
  #keybox[$
    ket(J_l thin M_l\; lambda_l) = sum_L sqrt((2L + 1) / (2 J_l + 1)) braket(L thin 0 thin j_l thin lambda_l, J_l thin lambda_l) ket((L thin j_l) J_l thin M_l)
  $]
]

#slide[Applying Jacob–Wick: the $lambda_l = 0$ states][
  #speaker-note[This is just an evaluation of the formula derived above. You see there is no even-$L$ piece in the $J_l = 2$, $lambda_l = 0$ state, so it has negative parity and is excluded from our $1^(+ +)$ sector.]
  - $J_l = 1$: #h(0.3em) $braket(0 thin 0 thin 1 thin 0, 1 thin 0) = 1$, #h(0.3em) $braket(1 thin 0 thin 1 thin 0, 1 thin 0) = 0$, #h(0.3em) $braket(2 thin 0 thin 1 thin 0, 1 thin 0) = -sqrt(2 \/ 5)$:
  $
    c_(0 0) = sqrt(1 / 3) dot 1 = 1 / sqrt(3), quad c_(1 0) = 0, quad c_(2 0) = sqrt(5 / 3) dot (-sqrt(2 / 5)) = -sqrt(2 / 3)
  $
  #keybox[$ ket(Sigma_g^(+')) = 1 / sqrt(3) ket((0 thin 1) 1) - sqrt(2 / 3) ket((2 thin 1) 1) $]
  - $J_l = 2$: #h(0.3em) $braket(1 thin 0 thin 1 thin 0, 2 thin 0) = sqrt(2 \/ 3)$, #h(0.3em) $braket(2 thin 0 thin 1 thin 0, 2 thin 0) = 0$, #h(0.3em) $braket(3 thin 0 thin 1 thin 0, 2 thin 0) = -sqrt(3 \/ 7)$:
  $
    ket(J_l = 2\, lambda_l = 0) = sqrt(3 / 5) sqrt(2 / 3) ket((1 thin 1) 2) - sqrt(7 / 5) sqrt(3 / 7) ket((3 thin 1) 2) = sqrt(2 / 5) ket((1 thin 1) 2) - sqrt(3 / 5) ket((3 thin 1) 2)
  $
  - only odd $L$, i.e. negative parity: besides the vanishing $L = 2$ CG coefficient there is no even-$L$ piece at all, so this state is absent
]

#slide[Applying Jacob–Wick: the $lambda_l = plus.minus 1$ states ($Pi_g$)][
  #speaker-note[Okay, this one is not interesting, just an evaluation.]
  Same steps with $braket(L thin 0 thin 1 thin plus.minus 1, J_l thin plus.minus 1)$:
  - $J_l = 1$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = 1 / sqrt(3) ket((0 thin 1) 1) minus.plus 1 / sqrt(2) ket((1 thin 1) 1) + 1 / sqrt(6) ket((2 thin 1) 1)$ \
    the $L = 1$ piece has the wrong parity and is the one that flips sign, so the parity-even state is $(ket(+1) + ket(-1)) \/ sqrt(2)$:
    $ ket(Pi_g\; 1) = sqrt(2 / 3) ket((0 thin 1) 1) + 1 / sqrt(3) ket((2 thin 1) 1) $
  - $J_l = 2$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = sqrt(3 / 10) ket((1 thin 1) 2) minus.plus 1 / sqrt(2) ket((2 thin 1) 2) + 1 / sqrt(5) ket((3 thin 1) 2)$ \
    now the even-$L$ piece flips sign: the parity-even state is $(ket(+1) - ket(-1)) \/ sqrt(2) = -ket((2 thin 1) 2)$; dropping the overall sign (a convention), $ket(Pi_g\; 2) = ket((2 thin 1) 2)$
]

#slide[Task 2, Step 3: $6j$ recoupling at fixed $L$][
  #speaker-note[Now we have converted the BO states into states with definite orbital angular momentum. Next, we recouple them into the partial-wave scheme, where the heavy spin and the light spin couple first. This is just a Wigner $6j$ symbol.]
  To reach the partial-wave channels, move $j_l$ from $L$ over to $s_H$; the overlap is a $6j$ symbol:
  $
    braket((L thin j_l) J_l\, s_H\; J, L\, (j_l thin s_H) S\; J) = (-1)^(L + j_l + s_H + J) sqrt((2 J_l + 1)(2 S + 1)) mat(delim: "{", L, j_l, J_l; s_H, J, S)
  $
  - $L = 0$: nothing to do, $ket((0 thin 1) 1) = ket(pw(3, S, 1))$
  - $L = 2$: the phase is $(-1)^5 = -1$, and
  $
    mat(delim: "{", 2, 1, 1; 1, 1, 1) = 1 / 6, quad mat(delim: "{", 2, 1, 1; 1, 1, 2) = mat(delim: "{", 2, 1, 2; 1, 1, 1) = -sqrt(5) / 10, quad mat(delim: "{", 2, 1, 2; 1, 1, 2) = -1 / 10
  $
  e.g. $braket((2 thin 1) 1, pw(3, D, 1)) = -sqrt(3 dot 3) dot 1 \/ 6 = -1 \/ 2$. In total
  #keybox[$
    ket((2 thin 1) J_l = 1) = -1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1)), quad ket((2 thin 1) J_l = 2) = sqrt(3) / 2 ket(pw(3, D, 1)) + 1 / 2 ket(pw(5, D, 1))
  $]
]

#slide[Task 2, Step 4: The transformation matrix][
  #speaker-note[And the matrix looks like this. Okay, so this is ingredient two, Task 2.]
  Insert Step 2 into Step 1 (the same for the other two rows), e.g.
  $
    ket(Sigma_g^(+')) = 1 / sqrt(3) ket(pw(3, S, 1)) - sqrt(2 / 3) (-1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1))) = 1 / sqrt(3) ket(pw(3, S, 1)) + 1 / sqrt(6) ket(pw(3, D, 1)) - 1 / sqrt(2) ket(pw(5, D, 1))
  $
  #keybox[$
    mat(ket(Sigma_g^(+')); ket(Pi_g\; 1); ket(Pi_g\; 2)) = underbrace(mat(1 / sqrt(3), 1 / sqrt(6), -1 / sqrt(2); sqrt(2 / 3), -1 / (2 sqrt(3)), 1 / 2; 0, sqrt(3) / 2, 1 / 2), U) mat(ket(B macron(B)^* (pw(3, S, 1))); ket(B macron(B)^* (pw(3, D, 1))); ket(B^* macron(B)^* (pw(5, D, 1)))), quad U U^T = bold(1)
  $]
  - rows normalised ($1 / 3 + 1 / 6 + 1 / 2 = 2 / 3 + 1 / 12 + 1 / 4 = 3 / 4 + 1 / 4 = 1$) and orthogonal: two bases for the same three states
]

// --------------------------------------------------------------- Task 3: the coupling from the lattice

#slide[Task 3: The basis problem][
  #speaker-note[Next, we need to relate what is computed on the lattice to what we need in our calculation. The lattice works in the $B macron(B)$ basis, which is not ours, and we need the coupling of a $1^(+ +)$ bottomonium to the $S$-wave $B macron(B)^*$. We need the BO symmetry here, the cylindrical symmetry. So we start from the lattice coupling, $sqrt(2) g_l$, then use the Wigner $9j$ symbol to recouple it into the configuration of interest, and then the $6j$ symbol to recouple it into our partial-wave channels.]
  - the lattice works in the $B macron(B)$ basis (two pseudoscalar static–light mesons), which is not ours
  - we need the coupling of a $1^(+ +)$ bottomonium to an $S$-wave $B macron(B)^*$ pair
  - to relate the two we need the BO symmetry, here a cylindrical symmetry
  #v(1.4em)
  Plan of the next slides:
  #v(0.6em)
  #align(center, grid(
    columns: 5,
    column-gutter: 0.8em,
    align: center + horizon,
    [$sqrt(2) g_l$ \ #text(size: 14pt, fill: gray-text)[lattice, $B macron(B)$]],
    $stretch(arrow.r, size: #5em)^(times 2)_("spin, " 9j)$,
    [$mel(Sigma_g^(+'), H, W)$ \ #text(size: 14pt, fill: gray-text)[normalised $Sigma_g^(+')$ pair]],
    $stretch(arrow.r, size: #6em)^(times 1 \/ sqrt(3))_("partial waves, " 6j)$,
    [$g = mel(B macron(B)^* (pw(3, S, 1)), H, W)$ \ #text(size: 14pt, fill: gray-text)[$S$-wave $B macron(B)^*$]],
  ))
]

#slide(refs: [Bulava _et al._ 2019, 2024])[Task 3, Step 1: The lattice coupling and the heavy-quark spin][
  #speaker-note[So, the first step. Schematically, the coupling from the lattice can be written as such a matrix element; the $sqrt(2)$ comes from the isoscalar combination. The out-state $W$ inherits its quantum numbers from the interpolating operator used in the lattice calculation, which gives $(1, 0)$ for the heavy spin. Since the heavy-quark spin is conserved, and the BO quantum numbers are conserved too, we arrive at this equation. To show this: in $B macron(B)$ the heavy-quark spin and the light-quark spin first couple into the meson spin, and then the two mesons couple their spins to the total angular momentum. We need to recouple it such that the two heavy spins couple first, the two light spins couple with each other, and then they couple to the total angular momentum.]
  - schematically $sqrt(2) g_l = mel(W, H_"mix", B macron(B))$; the $sqrt(2)$: isoscalar $ket(B macron(B)) = (ket(B_u macron(B)_u) + ket(B_d macron(B)_d)) \/ sqrt(2)$
  - $ket(W)$ inherits its quantum numbers from the interpolating operator
  $ cal(O)_W (y, x, t) = macron(Q)(y, t) (bold(gamma) dot arrow(r)) / r W(y, x, t) Q(x, t) $
  - $bold(gamma) dot arrow(r) \/ r$ gives $ket(1\, 0)$ for the heavy spin (projection 0 on the axis); heavy-quark spin is conserved (HQSS)
  #keybox[$ sqrt(2) g_l = -1 / 2 mel(W, H, 1_H\, 0\; 1_l\, 0) $]
  - to show this: $B macron(B)$ is coupled as $ket([(s_b j_(l 1))_0 (s_macron(b) j_(l 2))_0]_0)$; recouple it into $ket([(s_b s_macron(b))_(s_H) (j_(l 1) j_(l 2))_(j_l)]_0)$
]

#slide[Recoupling $B macron(B)$: the $9j$ symbol][
  #speaker-note[This is just the Wigner $9j$ symbol,]
  For four angular momenta the recoupling coefficient is
  $
    & braket([(j_1 j_2) J_(12) thin (j_3 j_4) J_(34)] J, [(j_1 j_3) J_(13) thin (j_2 j_4) J_(24)] J) \
    & quad = sqrt((2 J_(12) + 1)(2 J_(34) + 1)(2 J_(13) + 1)(2 J_(24) + 1)) mat(delim: "{", j_1, j_2, J_(12); j_3, j_4, J_(34); J_(13), J_(24), J)
  $
  - here $j_1 = s_b$, $j_2 = j_(l 1)$, $j_3 = s_macron(b)$, $j_4 = j_(l 2)$, all equal to $1 \/ 2$
  - $J_(12) = J_(34) = 0$: both mesons are pseudoscalars; and $J = 0$
  - so $J_(13) = s_H$ and $J_(24) = j_l$ must couple to zero: #h(0.3em) $s_H = j_l equiv s in {0, 1}$
]

#slide[Evaluating the $9j$ symbol][
  #speaker-note[and after evaluation it gives this relation.]
  A $9j$ symbol with a zero reduces to a $6j$ symbol:
  $
    mat(delim: "{", a, b, e; c, d, e; f, f, 0) = (-1)^(b + c + e + f) / sqrt((2e + 1)(2f + 1)) mat(delim: "{", a, b, e; d, c, f)
  $
  For us, with the elementary $6j$ symbol with a zero:
  $
    mat(delim: "{", 1\/2, 1\/2, 0; 1\/2, 1\/2, 0; s, s, 0) = (-1)^(1 + s) / sqrt(2s + 1) mat(delim: "{", 1\/2, 1\/2, 0; 1\/2, 1\/2, s), quad mat(delim: "{", 1\/2, 1\/2, 0; 1\/2, 1\/2, s) = (-1)^(1 + s) / 2
  $
  The signs cancel: $9j = 1 \/ (2 sqrt(2s + 1))$, and the coefficient is $sqrt((2s + 1)^2) dot 1 / (2 sqrt(2s + 1)) = sqrt(2s + 1) / 2$:
  #keybox[$ ket(B macron(B)) = 1 / 2 ket((0_H 0_l)_0) + sqrt(3) / 2 ket((1_H 1_l)_0) $]
]

#slide[Task 3, Step 2: The factor of 2 from projection on the axis][
  #speaker-note[We need to break this coupling up further: the state with heavy spin one and BO quantum numbers $(1, 0)$ comes with the coefficient $-1 \/ 2$, which gives us an extra factor of two. The sign in front of this coefficient doesn't matter, because we use the square of the coupling.]
  Open $(1_H 1_l)_0$ into projections on the axis:
  $
    ket((1_H 1_l)_0) = sum_m braket(1 thin m thin 1 thin um m, 0 thin 0) ket(1_H\, m) ket(1_l\, -m), quad braket(1 thin m thin 1 thin um m, 0 thin 0) = (-1)^(1 - m) / sqrt(3)
  $
  so the coefficient of $ket(1_H\, 0) ket(1_l\, 0)$ is $sqrt(3) \/ 2 dot (-1 \/ sqrt(3)) = -1 \/ 2$. Altogether
  $
    ket(B macron(B)) = 1 / 2 ket(0_l\, 0) ket(0_H\, 0) + 1 / 2 sum_(lambda_l = plus.minus 1, 0) (-1)^(lambda_l + 1) ket(1_l\, lambda_l) ket(1_H\, -lambda_l)
  $
  - the only part with $ket(1_H\, 0)$ is $ket(1_H\, 0\; 1_l\, 0)$, with coefficient $-1 \/ 2$
  #keybox[$mel(W, H, 1_H\, 0\; 1_l\, 0) = -2 sqrt(2) thin g_l$: #h(0.3em) the extra factor of 2]
]

#slide[Task 3, Step 3: From $Sigma_g^(+')$ to the $pw(3, S, 1)$ channel][
  #speaker-note[This is not the end of the story yet: we need the transition between the $S$-wave meson pair and the string. So we insert the completeness relation of the BO basis here, and by the BO selection rule only $Sigma_g^(+')$ survives.]
  This is still not what we want: we need $mel(B macron(B)^* (pw(3, S, 1)), H, W)$.
  - insert the completeness relation of the BO basis, $sum ket("BO") bra("BO")$ over ${Sigma_g^(+'), Pi_g\; 1, Pi_g\; 2}$
  - the string $W$ is $Sigma_g^+$ and the mixing conserves the BO quantum numbers, so only $Sigma_g^(+')$ survives (BO selection rule):
  $ mel(B macron(B)^* (pw(3, S, 1)), H, W) = braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) mel(Sigma_g^(+'), H, W) $
  #v(0.3em)
  #keybox[#h(0.4em) $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 / sqrt(3)$ #h(1em) ]
]

#slide[Task 3, Step 4: The coupling $g$][
  #speaker-note[This gives the final result: the $sqrt(2)$ comes from flavour, the 2 from spin, the $1 \/ sqrt(3)$ from the $S$-wave overlap with the BO state, and finally $g_l$ comes from the lattice.]
  As derived above: $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 \/ sqrt(3)$. \ Back to the projector insertion:
  $
    g equiv mel(B macron(B)^* (pw(3, S, 1)), H, W) = underbrace(braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')), 1 \/ sqrt(3)) underbrace(mel(Sigma_g^(+'), H, W), -2 sqrt(2) thin g_l)
  $
  #keybox[$
    |g| = underbrace(sqrt(2), "flavour") times underbrace(2, "spin") times underbrace(1 / sqrt(3), S "wave") times g_l = 2 / sqrt(3) sqrt(2) thin g_l = 57 "MeV" quad (g_l = 35 "MeV")
  $]
  - $mel(Sigma_g^(+'), H, W)$ is the mixing with the normalised $Sigma_g^(+')$ configuration; by HQSS it equals $mel(1_H\, 0\; 1_l\, 0, H, W) = -2 sqrt(2) thin g_l$ from the lattice
  - the sign does not matter, since $V^((macron(b) b)) prop g^2$
]

// --------------------------------------------------------------- Task 4: one-meson exchange

#slide[What to do next?][
  #speaker-note[So by now I think I have given you a complete picture of the $s$-channel exchange. Next we tackle the $t$-channel meson exchanges.]
  Tasks 1–3 gave the $s$-channel exchange: $hat(V)(E)$ and $cal(P)_(macron(b) b)$, the matrix $U$, the coupling $g$. Next:
  - Task 4: the $t$-channel meson exchanges, OME from the LO chiral Lagrangian in TOPT
    $ V^"(OME)"_(alpha' alpha)(p', p) = 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_pi) + 1 / 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_eta) $
  - Task 5: solve the LSE with the two-potential formalism
    $ T = T_U + (1 - T_U G) thin S thin (1 - G T_U) $
    $T_U$: OME alone; #h(0.2em) $S$: compact exchange and contact term, dressed by OME
  - Task 6: the composition of a bound state, from the pole of the amplitude
    $ 1 = cal(P)_(macron(b) b) + cal(P)_S + cal(P)_D + cal(P)_"3-body" $
]

#slide(refs: [Wise 1992; Burdman, Donoghue 1992; Yan _et al._ 1992])[Task 4, Step 1: The LO chiral Lagrangian][
  #speaker-note[One-meson exchange is given by leading-order heavy-meson ChPT. Here $H$ annihilates the $b macron(q)$ mesons and $macron(H)$ the $macron(b) q$ mesons, where $P$ stands for the pseudoscalar and $V$ for the vector mesons. Charge conjugation is defined such that the $C$-even $B macron(B)^*$ state is the difference of the two states.]
  Heavy–light mesons coupled to the pseudo-Goldstone bosons, taken as given (LO heavy-meson ChPT):
  #keybox[$
    cal(L)_Phi = -g_b / 4 op("Tr")(H_a^dagger H_b thin bold(sigma) dot bold(u)_(b a)) + g_b / 4 op("Tr")(bold(sigma) dot bold(u)_(a b) thin macron(H)_b macron(H)_a^dagger)
  $]
  - $H_a = P_a + bold(V)_a dot bold(sigma)$: #h(0.2em) $P_a = (B^-, macron(B)^0)$, $V_a^i = (B^(* -), macron(B)^(* 0))$ annihilate the $b macron(q)$ mesons
  - $macron(H)_a = macron(P)_a + macron(bold(V))_a dot bold(sigma)$: #h(0.2em) $macron(P)_a = (B^+, B^0)$, $macron(V)_a^i = (B^(* +), B^(* 0))$ annihilate the $macron(b) q$ mesons; the bar means antimeson
  - $a = 1, 2$: light flavour ($u, d$); $i$: vector index of $B^*$; $bold(sigma)$ acts on spin, $tau_a$ on flavour; Tr is over spin
  - $cal(C) P_a cal(C)^(-1) = macron(P)_a$, $cal(C) V_a^i cal(C)^(-1) = -macron(V)_a^i$ #h(0.3em) $arrow.r.double$ #h(0.3em) $ket(B macron(B)^*\; C = +) = (ket(B macron(B)^*) - ket(B^* macron(B))) \/ sqrt(2)$
]

#slide(refs: [$g_b$: Flynn _et al._, PRD 93, 014510 (2016)])[Task 4, Step 2: Goldstone bosons and the one-boson Lagrangian][
  $
    bold(u) = -(nabla Phi) / F_pi + cal(O)(Phi^3), quad Phi = pi_a tau_a + eta / sqrt(3) bold(1) = mat(pi^0 + eta / sqrt(3), sqrt(2) pi^+; sqrt(2) pi^-, -pi^0 + eta / sqrt(3)), quad pi^plus.minus = (pi_1 minus.plus i pi_2) / sqrt(2)
  $
  $F_pi = 92.2$ MeV; #h(0.2em) #box($g_b = 0.56(3)_"stat" (7)_"sys"$) from lattice QCD at the physical $b$ mass (central value used). With the spin traces done:
  #keybox[$
    cal(L)_Phi = & g_b / (2 F_pi) [(V_a^(k dagger) P_b + P_a^dagger V_b^k) partial_k Phi_(b a) + i epsilon_(i j k) V_a^(i dagger) V_b^j thin partial_k Phi_(b a)] \
    & + g_b / (2 F_pi) [-(macron(P)_a^dagger macron(V)_b^k + macron(V)_a^(k dagger) macron(P)_b) partial_k Phi_(a b) + i epsilon_(i j k) macron(V)_a^(i dagger) macron(V)_b^j thin partial_k Phi_(a b)] + cal(O)(Phi^3)
  $]
  - no $P^dagger P$ term: no $B B phi.alt$ vertex ($0^- -> 0^- 0^-$ is forbidden by parity and angular momentum)
  - antimesons: the $P V phi.alt$ term flips sign, the $V V phi.alt$ term does not
]

#slide[Task 4, Step 3: The vertices; $P$ waves mix $S$ and $D$][
  A meson line $bold(p) -> bold(p)'$ loses $bold(q) = bold(p) - bold(p)'$; without the common $plus.minus i$ and the flavour matrix:
  #keybox[$
    v^a_(B^* B phi.alt) = g_b / (2 F_pi) tau^a (bold(epsilon.alt) dot bold(q)), quad v^a_(B^* B^* phi.alt) = -g_b / (sqrt(2) F_pi) tau^a (bold(A) dot bold(q)), quad bold(A) = i / sqrt(2) bold(epsilon.alt) times bold(epsilon.alt)'^*
  $]
  - $bold(epsilon.alt)$: incoming, $bold(epsilon.alt)'^*$: outgoing polarisation; for $eta$, $tau^a -> bold(1) \/ sqrt(3)$; an antimeson loses $-bold(q)$, and its $P V phi.alt$ vertex flips sign
  - each vertex is a $P$ wave, $prop bold(q)$, so OME carries $q_i q_j = (q_i q_j - 1 / 3 delta_(i j) q^2) + 1 / 3 delta_(i j) q^2$
  - the traceless part is a rank-2 tensor in the momenta: contracted with the polarisations, it connects $L = 0$ and $L = 2$ at fixed $J$ (tensor force)
  #keybox[$ B macron(B)^* (pw(3, S, 1)) quad arrow.l.r quad B macron(B)^* (pw(3, D, 1)), quad B^* macron(B)^* (pw(5, D, 1)) $]
]

#slide[Task 4, Step 4: Time-ordered perturbation theory][
  OME is second order in $H_"int"$. In TOPT every particle stays on shell; energy is conserved overall but not at each vertex, and each intermediate state costs an energy denominator:
  $ V = sum_n (mel(f, H_"int", n) mel(n, H_"int", i)) / (M - E_n + i 0) $
  Between the vertices: the two heavy mesons and $phi.alt$; which ones depends on who emits first.
  #align(center, topt-figure)
  - time runs to the right; single line $B$, double line $B^*$, dashed $phi.alt$; thin line: intermediate state
  - classes 3 and 4 contain the same particles; the $B$ carries $bold(p)$ in class 3 and $bold(p)'$ in class 4
]

#slide[Task 4, Step 5: Energy denominators][
  $omega_h (p) = m_h + p^2 \/ (2 m_h)$, $E_phi.alt (q) = sqrt(q^2 + m_phi.alt^2)$; one ordering with heavy mesons $h_1, h_2$ in the intermediate state ($1 \/ (2 E_phi.alt)$: boson normalisation):
  #keybox[$
    1 / (2 E_phi.alt) dot 1 / (M - omega_(h_1) - omega_(h_2) - E_phi.alt + i 0) = -1 / (2 E_phi.alt (q) [E_phi.alt (q) + nu_beta]) equiv -D_beta, quad nu_beta = omega_(h_1) + omega_(h_2) - M - i 0
  $]
  With $M = m_B + m_(B^*) + E$, $Delta m = m_(B^*) - m_B$ ($nu_beta$ is the paper's $mu_beta$):
  $
    nu_1 & = -Delta m + (p^2 + p'^2) \/ (2 m_B) - E - i 0, & quad nu_2 & = Delta m + (p^2 + p'^2) \/ (2 m_(B^*)) - E - i 0, \
    nu_3 & = p^2 \/ (2 m_B) + p'^2 \/ (2 m_(B^*)) - E - i 0, & quad nu_4 & = p'^2 \/ (2 m_B) + p^2 \/ (2 m_(B^*)) - E - i 0
  $
  - all four depend on $E$ and on $p$, $p'$ separately: OME is energy dependent and nonlocal, kept in full
  - only without recoil and $E$ in $nu_(1, 2)$ do (1) and (2) combine into a static Yukawa: #h(0.2em) #box($D_1 + D_2 -> (2 E_phi.alt)^(-1) [(E_phi.alt - Delta m)^(-1) + (E_phi.alt + Delta m)^(-1)] = (bold(q)^2 + m_phi.alt^2 - Delta m^2)^(-1)$)
]

#slide[Task 4, Step 6: The four OME kernels][
  Each time ordering is (vertex) $times$ (vertex) $times (-D_beta)$; summing the orderings, without the flavour factor:
  #keybox[$
    V_(B macron(B)^* -> B macron(B)^*) & = -g_b^2 / (4 F_pi^2) (bold(epsilon.alt) dot bold(q))(bold(epsilon.alt)'^* dot bold(q)) thin [D_1 + D_2] \
    V_(B macron(B)^* -> B^* macron(B)^*) & = g_b^2 / (4 F_pi^2) [(bold(A)_1 dot bold(q))(bold(epsilon.alt)'^*_2 dot bold(q)) + (bold(A)_2 dot bold(q))(bold(epsilon.alt)'^*_1 dot bold(q))] thin [D_3 + D_2] \
    V_(B^* macron(B)^* -> B macron(B)^*) & = g_b^2 / (4 F_pi^2) [(bold(A)_1 dot bold(q))(bold(epsilon.alt)_2 dot bold(q)) + (bold(A)_2 dot bold(q))(bold(epsilon.alt)_1 dot bold(q))] thin [D_4 + D_2] \
    V_(B^* macron(B)^* -> B^* macron(B)^*) & = -g_b^2 / (2 F_pi^2) (bold(A)_1 dot bold(q))(bold(A)_2 dot bold(q)) thin [2 D_2]
  $]
  - 1 and 2 label the $B^*$ and the $macron(B)^*$ of the $B^* macron(B)^*$ pair, $bold(A)_a = i / sqrt(2) bold(epsilon.alt)_a times bold(epsilon.alt)'^*_a$
]

#slide[Task 4, Step 7: Partial-wave projection][
  #speaker-note[The potential is defined on plane-wave in and out states; to get the potential in a partial-wave channel, we need to project onto the partial-wave basis.]
  The kernels are defined on momentum eigenstates, $V_(sigma' sigma)(bold(p)', bold(p)) = mel(bold(p)'\, sigma', hat(V), bold(p)\, sigma)$, with $sigma = (m_1, m_2)$ the spins of the meson pair.
  Project with $Y_(L m)(hat(bold(p))) = braket(hat(bold(p)), L m)$ and the spin–angular wave function of channel $alpha = (L, S)$:
  $
    Psi_(alpha J M)(hat(bold(p)), sigma) = sum_(m, mu) braket(L m\, S mu, J M) Y_(L m)(hat(bold(p))) braket(sigma, S mu), quad ket(p\; alpha J M) = integral dif Omega sum_sigma Psi_(alpha J M)(hat(bold(p)), sigma) ket(bold(p)\, sigma)
  $
  $
    V^J_(alpha' alpha)(p', p) = 1 / (2J + 1) sum_M mel(p'\; alpha' J M, hat(V), p\; alpha J M) = 1 / (2J + 1) sum_M integral dif Omega' dif Omega sum_(sigma' sigma) Psi^*_(alpha' J M) V_(sigma' sigma) Psi_(alpha J M)
  $
  The paper's form: $P_i (alpha; hat(bold(n))) = sqrt(4 pi) sum_M e^((M))_i Psi_(alpha 1 M)(hat(bold(n)))$, #h(0.2em) $sum_i e^((M)*)_i e^((M'))_i = delta_(M M')$, so $op("Tr")[P^dagger V P] = 4 pi sum_M Psi^* V Psi$:
  #keybox[$
    V^"(OME)"_(alpha' alpha)(p', p; m_phi.alt) = 1 / (2J + 1) integral (dif Omega_(bold(n)')) / (4 pi) (dif Omega_(bold(n))) / (4 pi) op("Tr")[P^dagger (alpha'; hat(bold(n))') thin V^"(OME)"(p' hat(bold(n))', p hat(bold(n)); m_phi.alt) thin P(alpha; hat(bold(n)))] = V^J_(alpha' alpha) / (4 pi)
  $]
  - the $1 \/ (4 pi)$: partial-wave states normalised as $braket(p'\, alpha', p\, alpha) = delta_(alpha' alpha) (2 pi^2) \/ p^2 thin delta(p' - p)$
]

#slide[Task 4, Step 8: The OME potential in partial waves][
  With $x = hat(bold(n)) dot hat(bold(n))'$ and the angular moments $Delta^((beta_1 beta_2))_m (p', p; m_phi.alt) = integral_(-1)^1 dif x thin x^m [D_(beta_1) + D_(beta_2)]$:
  #text(size: 17pt)[$
    V_11 & = g_b^2 \/ (24 F_pi^2) thin [2 p p' Delta_1^((12)) - (p^2 + p'^2) Delta_0^((12))] \
    V_12 & = g_b^2 \/ (24 sqrt(2) F_pi^2) thin [3 p'^2 Delta_2^((12)) - 4 p p' Delta_1^((12)) + (2 p^2 - p'^2) Delta_0^((12))] \
    V_13 & = -g_b^2 \/ (8 sqrt(6) F_pi^2) thin [3 p'^2 Delta_2^((24)) - 4 p p' Delta_1^((24)) + (2 p^2 - p'^2) Delta_0^((24))] \
    V_22 & = g_b^2 \/ (24 F_pi^2) thin [(9 \/ 2) p p' Delta_3^((12)) - 3 (p^2 + p'^2) Delta_2^((12)) - (1 \/ 2) p p' Delta_1^((12)) + (p^2 + p'^2) Delta_0^((12))] \
    V_23 & = g_b^2 \/ (16 sqrt(3) F_pi^2) thin [3 p p' Delta_3^((24)) - 3 (p^2 + p'^2) Delta_2^((24)) + p p' Delta_1^((24)) + (p^2 + p'^2) Delta_0^((24))] \
    V_33 & = -g_b^2 \/ (16 F_pi^2) thin p p' [Delta_1^((22)) - Delta_3^((22))]
  $]
  - $V_(alpha' alpha) equiv V^"(OME)"_(alpha' alpha)(p', p; m_phi.alt)$, with $V_(j i)(p', p) = V_(i j)(p, p')$; #h(0.2em) $(beta_1 beta_2)$: the time orderings of Step 6
]

#slide(refs: [independent check: `checks/isospin_factors.py`])[Task 4, Step 9: Isospin factors][
  The flavour factor of pion exchange is the product of the isospin generators of the two mesons: the meson ($b macron(q)$) carries the anti-doublet, $arrow(I)_1 = -arrow(tau)^T \/ 2$, the antimeson ($macron(b) q$) the doublet, $arrow(I)_2 = arrow(tau) \/ 2$:
  $
    sum_a tau_a^T times.o tau_a = -4 thin arrow(I)_1 dot arrow(I)_2 = -2 [I(I + 1) - 3 / 4 - 3 / 4] = cases(3 quad & I = 0, -1 quad & I = 1)
  $
  - $eta$ is an isosinglet: $(1 \/ sqrt(3))^2 = 1 \/ 3$ in every channel
  #v(0.4em)
  #keybox[$ V^"(OME)"_(alpha' alpha)(p', p) = 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_pi) + 1 / 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_eta) quad (I = 0) $]
]

// --------------------------------------------------------------- Task 5: the scattering equation

#slide[Task 5, Step 1: The Lippmann–Schwinger equation][
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

#slide[Task 5, Step 2: The separable part and its solution][
  Compact exchange and contact act in channel 1 ($pw(3, S, 1)$) only. Collect their form factors in the operator
  $
    F = sum_(a = 1)^(N + 1) ket(f_a) bra(a), quad braket(p\, alpha, f_a) = delta_(alpha 1) f_a (p), quad f_a (p) = cases(psi_a (p) \/ sqrt(4 pi) quad & a = 1\, dots\, N, 1 & a = N + 1)
  $
  from $CC^(N + 1)$ into the meson-pair space; $psi_n (p) = 4 pi integral r^2 dif r thin j_0 (p r) R_(1 n)(r)$ is the bare $n P$ wave function. Then
  $ W = F hat(v) F^dagger, quad hat(v)(E) = "diag"(v_1, dots, v_N, C), quad v_n = g^2 / (E - E_n), quad E_n = E_n^((0)) + V_0 $
  $W$ alone: insert $T_W = F tau_0 F^dagger$ into $T_W = W - W G T_W$,
  $ F tau_0 F^dagger = F hat(v) F^dagger - F hat(v) F^dagger G F tau_0 F^dagger quad arrow.r.double quad tau_0 = hat(v) - hat(v) J_0 tau_0, quad J_0 = F^dagger G F $
  #keybox[$ T_W = F tau_0 F^dagger, quad tau_0 = (hat(v)^(-1) + J_0)^(-1), quad "poles of" T_W "at" det(hat(v)^(-1) + J_0) = 0 $]
]

#slide[Task 5, Step 3: Adding OME: solve OME first][
  With $U equiv V^"(OME)"$, $W equiv V^((macron(b) b)) + V^"CT"$, $T_U equiv T^"(OME)"$:
  $ ket(psi) = ket(phi.alt) - G (U + W) ket(psi) quad arrow.r.double quad (1 + G U) ket(psi) = ket(phi.alt) - G W ket(psi) $
  $ ket(psi) = underbrace((1 + G U)^(-1) ket(phi.alt), ket(phi.alt_U)", OME only") - (1 + G U)^(-1) G thin W ket(psi) $
  The dressed propagator: $(1 + G U)^(-1) G = [G^(-1) (1 + G U)]^(-1) = (G^(-1) + U)^(-1) = (H_0 + U - E)^(-1) equiv K$
  #keybox[$ ket(psi) = ket(phi.alt_U) - K W ket(psi) $]
  - an LSE with $ket(phi.alt) -> ket(phi.alt_U)$ and $G -> K$: solve OME first, then use it to solve the whole problem
  - careful: $U$ depends on $E$, so $K(E)$ is the resolvent of $H_0 + U(E)$ at the same $E$, not of one fixed Hamiltonian; $partial_E K != K^2$
]

#slide[Task 5, Step 4: The auxiliary transition operator][
  $ket(psi) = ket(phi.alt_U) - K W ket(psi)$ is an LSE with $ket(phi.alt) -> ket(phi.alt_U)$ and $G -> K$. So define $S$ as $T$ was defined, on the OME-distorted incoming state:
  #keybox[$ S ket(phi.alt_U) equiv W ket(psi) $]
  Multiply the LSE above by $W$:
  $ W ket(psi) = W ket(phi.alt_U) - W K W ket(psi) quad arrow.r.double quad S ket(phi.alt_U) = W ket(phi.alt_U) - W K S ket(phi.alt_U) $
  - the auxiliary LSE, $S = W - W K S$: the LSE of $W$ alone, with $G$ replaced by the dressed propagator $K$
  - $S$ is a transition operator, not the $S$ matrix
]

#slide(refs: [Gell-Mann, Goldberger, Phys. Rev. 91, 398 (1953); Nakano, PRC 26, 1123 (1982)])[Task 5, Step 5: The two-potential formula][
  Two forms of the LSE: for any $V$, with $ket(psi) = ket(phi.alt) - G V ket(psi)$ and $T ket(phi.alt) = V ket(psi)$,
  $
    T ket(psi) & = T ket(phi.alt) - T G V ket(psi) = V ket(psi) - T G V ket(psi) \
    T ket(phi.alt) & = V ket(psi) = V ket(phi.alt) - V G T ket(phi.alt)
  $
  so $T = V - T G V = V - V G T$. For $U$ alone: $T_U = U (1 + G U)^(-1) = (1 + U G)^(-1) U$, hence $ket(phi.alt_U) = (1 + G U)^(-1) ket(phi.alt) = (1 - G T_U) ket(phi.alt)$ and $U K = U (1 + G U)^(-1) G = T_U G$. With $W ket(psi) = S ket(phi.alt_U)$:
  $ T ket(phi.alt) = (U + W)(ket(phi.alt_U) - K W ket(psi)) = U ket(phi.alt_U) - U K W ket(psi) + W ket(psi) = T_U ket(phi.alt) + (1 - U K) S ket(phi.alt_U) $
  #keybox[$ T = T_U + (1 - T_U G) thin S thin (1 - G T_U) $]
  - $T_U$: pure OME. Second term: distorted by OME on the way in and out, with compact exchange and contact any number of times in between
]

#slide[Task 5, Step 6: $S$ is separable: the matrix $tau$][
  As in Step 5, the auxiliary LSE has two forms, $S = W - W K S = W - S K W$. With $W = F hat(v) F^dagger$ the first starts with $F$, the second ends with $F^dagger$, so $S = F tau F^dagger$. Insert:
  $ F tau F^dagger = F hat(v) F^dagger - F hat(v) F^dagger K F tau F^dagger = F [hat(v) - hat(v) J tau] F^dagger, quad J equiv F^dagger K F $
  #keybox[$ S = F tau F^dagger, quad tau = (1 + hat(v) J)^(-1) hat(v) = (hat(v)^(-1) + J)^(-1), quad J = F^dagger K F $]
  - as for $W$ alone (Step 2), with $G -> K$: $J$ is the $(N + 1) times (N + 1)$ matrix of loops dressed by OME
  - the states are the zeros of $det(hat(v)^(-1) + J)$
]

#slide[Task 5, Step 7: Dressed vertices and the amplitude][
  $ X^"out"_a (bold(p)'; E) = mel(bold(p)', 1 - T_U G, f_a), quad X^"in"_a (bold(p); E) = mel(f_a, 1 - G T_U, bold(p)) $
  Insert $bold(1) = sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) ket(q\, alpha) bra(q\, alpha)$; $G$ is diagonal and $f_(a, alpha)(q) = delta_(alpha 1) f_a (q)$ is real:
  $
    X^"out"_(a, alpha')(p') & = f_(a, alpha')(p') - sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) T^"(OME)"_(alpha' alpha)(p', q) thin G_alpha (k, q) thin f_(a, alpha)(q) \
    X^"in"_(a, alpha)(p) & = f_(a, alpha)(p) - sum_(alpha') integral_0^Lambda (q^2 dif q) / (2 pi^2) f_(a, alpha')(q) thin G_(alpha')(k, q) thin T^"(OME)"_(alpha' alpha)(q, p)
  $
  #keybox[$
    T_(alpha' alpha)(p', p) = T^"(OME)"_(alpha' alpha)(p', p) + sum_(a, b = 1)^(N + 1) X^"out"_(a, alpha')(p') thin tau_(a b) thin X^"in"_(b, alpha)(p), quad tau = (hat(v)^(-1) + J)^(-1)
  $]
]

#slide[Task 5, Step 8: The dressed loop $J$][
  $K = (1 + G U)^(-1) G = (1 - G T_U) G = G (1 - T_U G) = G - G T_U G$, so $J = F^dagger K F$ has three forms:
  $
    J_(a b) & = sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) X^"in"_(a, alpha)(q) thin G_alpha (k, q) thin f_(b, alpha)(q) = sum_alpha integral_0^Lambda (q^2 dif q) / (2 pi^2) f_(a, alpha)(q) thin G_alpha (k, q) thin X^"out"_(b, alpha)(q) \
    & = integral_0^Lambda (q^2 dif q) / (2 pi^2) f_a (q) thin G_1 (k, q) thin f_b (q) \
    & quad - sum_(alpha', alpha) integral_0^Lambda (q'^2 dif q') / (2 pi^2) integral_0^Lambda (q^2 dif q) / (2 pi^2) f_(a, alpha')(q') thin G_(alpha')(k, q') thin T^"(OME)"_(alpha' alpha)(q', q) thin G_alpha (k, q) thin f_(b, alpha)(q)
  $
  - the free loop between two vertices, minus the full OME amplitude (not one OME potential) between two free loops
  - time reversal: $J$, hence $tau$, is symmetric
  - $T^"(OME)"$, $X^"in, out"$ and $J$ do not depend on $C$ or $V_0$, which enter only through $hat(v)$: a fit only inverts an $(N + 1) times (N + 1)$ matrix
]

// --------------------------------------------------------------- Task 6: composition of a bound state

#slide[Task 6, Step 1: A third sector for three-body states][
  Task 1 had $P_Q$ (bare $macron(b) b$) and $P_M$ (meson pairs); eliminating $P_Q$ gave $hat(V)(E)$ and $cal(P)_(macron(b) b)$. The TOPT intermediate states $B^((*)) macron(B)^((*)) phi.alt$ are real three-body states, so add a third projector $P_phi.alt$:
  $
    P_Q + P_M + P_phi.alt = bold(1), quad P_Q P_M = P_Q P_phi.alt = P_M P_phi.alt = 0, quad cal(H) = mat(H_(Q Q), hat(g)^dagger, 0; hat(g), H_(M M), hat(g)_phi.alt^dagger; 0, hat(g)_phi.alt, H_(phi.alt phi.alt)), quad hat(g)_phi.alt equiv P_phi.alt cal(H) P_M
  $
  - $H_(phi.alt phi.alt)$ is the free three-body energy, $H_(phi.alt phi.alt) ket(beta\; b) = E_beta (b) ket(beta\; b)$: $beta$ the four classes, $b$ all momenta and spins
  - $hat(g)_phi.alt$: the one-boson vertex of Task 4; compact states do not couple to three-body states directly (the zeros)
  - $H_(M M) = H_0$ now: all of OME comes from $P_phi.alt$, the contact sits in $hat(V)$ as in Task 1; nothing in $cal(H)$ depends on $E$
]

#slide[Task 6, Step 2: Eliminating compact and three-body states][
  Multiply $cal(H) ket(Psi) = E ket(Psi)$ by each projector:
  $
    (E - H_(Q Q)) thin P_Q ket(Psi) & = hat(g)^dagger P_M ket(Psi) \
    (E - H_(M M)) thin P_M ket(Psi) & = hat(g) thin P_Q ket(Psi) + hat(g)_phi.alt^dagger P_phi.alt ket(Psi) \
    (E - H_(phi.alt phi.alt)) thin P_phi.alt ket(Psi) & = hat(g)_phi.alt thin P_M ket(Psi)
  $
  First and third: $P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger ket(Psi_M)$, #h(0.2em) $P_phi.alt ket(Psi) = (E - H_(phi.alt phi.alt))^(-1) hat(g)_phi.alt ket(Psi_M)$. Into the second:
  #keybox[$
    [H_(M M) + hat(V)(E) + hat(U)(E)] ket(Psi_M) = E ket(Psi_M), quad hat(U)(E) = hat(g)_phi.alt^dagger (E - H_(phi.alt phi.alt))^(-1) hat(g)_phi.alt
  $]
  $
    hat(U)_(alpha' alpha)(p', p; E) = sum_(beta, b) (mel(p'\, alpha', hat(g)_phi.alt^dagger, beta\; b) mel(beta\; b, hat(g)_phi.alt, p\, alpha)) / (E - E_beta (b) + i epsilon)
  $
  the TOPT form; the paper identifies it with $V^"(OME)"$
]

#slide[Task 6, Step 3: Normalisation with three sectors][
  As for $P_Q$ in Task 1: $partial_E (E - H_(phi.alt phi.alt))^(-1) = -(E - H_(phi.alt phi.alt))^(-2)$. Bound state, $E = -E_B$ real:
  $
    1 = braket(Psi, Psi) & = mel(Psi, P_Q, Psi) + mel(Psi, P_M, Psi) + mel(Psi, P_phi.alt, Psi) \
    & = mel(Psi_M, hat(g) (E - H_(Q Q))^(-2) hat(g)^dagger, Psi_M) + braket(Psi_M, Psi_M) + mel(Psi_M, hat(g)_phi.alt^dagger (E - H_(phi.alt phi.alt))^(-2) hat(g)_phi.alt, Psi_M) \
    & = mel(Psi_M, [1 - partial_E hat(V) - partial_E hat(U)], Psi_M)
  $
  #keybox[$
    cal(P)_(macron(b) b) = -mel(Psi_M, partial_E hat(V), Psi_M), quad sum_alpha cal(P)_alpha = braket(Psi_M, Psi_M), quad cal(P)_"3-body" = -mel(Psi_M, partial_E hat(U), Psi_M)
  $]
  - each one positive, adding up to 1; the contact does not depend on $E$ and drops out
  - $cal(P)_alpha = integral_0^Lambda (q^2 dif q) / (2 pi^2) |Psi_alpha (q)|^2$: the individual two-body channels
]

#slide[Task 6, Step 4: The normalisation from the pole of $tau$][
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

#slide[Task 6, Step 5: The wave function from the residue][
  Near the pole $T tilde.eq (X^"out" bold(c))(bold(c)^T X^"in") \/ (E + E_B)$. The meson-pair block of the full resolvent, with our sign of $G$,
  $ P_M (E - cal(H) + i epsilon)^(-1) P_M = -(H_0 + V(E) - E)^(-1) = -G + G T G $
  has the residue $ket(Psi_M) bra(Psi_M)$ at the bound state. Compare the residues:
  #keybox[$
    ket(Psi_M) = -G X^"out" bold(c) = -G (1 - T_U G) F bold(c) = -K F bold(c), quad Psi_alpha (p) = -G_alpha (k, p) sum_a X^"out"_(a, alpha)(p) thin c_a
  $]
  - the overall sign is a phase convention; $F$ injects into channel 1 only, $K$ spreads it into all channels: the $D$-wave content
  - check: $(G^(-1) + U) ket(Psi_M) = -F bold(c)$ and $W ket(Psi_M) = -F hat(v) J bold(c) = F bold(c)$, since $J bold(c) = -hat(v)^(-1) bold(c)$; so #box($(H_0 + U + W - E) ket(Psi_M) = 0$)
]

#slide[Task 6, Step 6: Compact amplitudes and $cal(P)_(macron(b) b)$][
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

#slide[Task 6, Step 7: The derivative of $J$ and the sum rule][
  $K^(-1) = G^(-1) + U(E) = H_0 - E + U(E)$, so
  $ partial_E K = -K (partial_E K^(-1)) K = K (1 - partial_E U) K, quad partial_E J = F^dagger K (1 - partial_E U) K F $
  (for an $E$-independent $U$ this would be $F^dagger K^2 F$). With $K F bold(c) = -ket(Psi_M)$:
  $ bold(c)^T (partial_E J) thin bold(c) = braket(Psi_M, Psi_M) - mel(Psi_M, partial_E U, Psi_M) = sum_alpha cal(P)_alpha + cal(P)_"3-body" $
  Add the two pieces of $bold(c)^T partial_E (hat(v)^(-1) + J) thin bold(c) = 1$:
  #keybox[$ 1 = cal(P)_(macron(b) b) + cal(P)_S + cal(P)_D + cal(P)_"3-body", quad cal(P)_S = cal(P)_1, quad cal(P)_D = cal(P)_2 + cal(P)_3 $]
  - the paper differentiates the LSE, $partial_E T_U = (1 - T_U G) thin partial_E U thin (1 - G T_U) - T_U G^2 T_U$; via $K^(-1)$ is shorter and needs no $U^(-1)$
]

#slide[Task 6, Step 8: The three-body probability explicitly][
  $partial_E$ acts only on the TOPT denominators: $partial_E nu_beta = -1$, so
  $ partial_E D_beta = 1 / (2 E_phi.alt (q) [E_phi.alt (q) + nu_beta]^2) $
  #keybox[$
    cal(P)_"3-body" = -sum_(alpha', alpha) integral_0^Lambda (p'^2 dif p') / (2 pi^2) integral_0^Lambda (p^2 dif p) / (2 pi^2) thin Psi^*_(alpha')(p') thin partial_E V^"(OME)"_(alpha' alpha)(p', p; E) thin Psi_alpha (p) |_(E = -E_B)
  $]
  - the two-body parts: $cal(P)_alpha = integral_0^Lambda (q^2 dif q) / (2 pi^2) |Psi_alpha (q)|^2$ with $Psi_alpha (p) = -G_alpha (k, p) sum_a X^"out"_(a, alpha)(p) thin c_a$
  - everything comes from the residue vector $bold(c)$ and the OME solution: nothing beyond the scattering calculation is needed
]

#slide(refs: [reviews: Hyodo 2013; Guo _et al._, RMP 90, 015004 (2018); Kinugawa, Hyodo 2025])[Task 6, Step 9: $S$-wave compositeness and its limits][
  #keybox[$ X_S = cal(P)_S + cal(P)_("3-body", S), quad cal(P)_("3-body", S) = -mel(Psi_1, partial_E V^"(OME)"_11, Psi_1) $]
  both from the $S$-wave component $Psi_1$ of the _full_ coupled-channel solution: the $S$–$D$–$S$ iterations are inside $Psi_1$. Limits:
  - the three-body states reached from $S$ and from $D$ overlap: $cal(P)_"3-body"$ also contains #box($-2 op("Re") mel(Psi_S, partial_E U, Psi_D)$), which $X_S$ leaves out; $X_S$ is not a sum of orthogonal probabilities
  - probabilities only for normalised bound states; for a resonance $E$ and $bold(c)$ are complex
  - the components depend on basis, regulator and model, and are not observables; only for a shallow $S$-wave bound state with contact interactions is the $S$-wave compositeness model independent
]
