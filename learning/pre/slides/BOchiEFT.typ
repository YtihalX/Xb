// BOχEFT and its application to X_b: the talk.
// Build:       typst compile BOchiEFT.typ
// With notes:  typst compile --input notes=true BOchiEFT.typ BOchiEFT-notes.pdf
//              (each page: the slide, and its speaker note in a panel on the right)
// Typst 0.15; fetches @preview/cetz:0.4.2 on first use.
// Notation follows Xb.tex. Projector/block labels and K are derivation-only auxiliaries.
// In particular: mu_beta, E_h (p), ell, s_(bar b b), and the paper's row-oriented f-hat.

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
/// right half holds the speaker note. Pages are numbered n/total, where the total ends before the
/// first backup slide (see `slide`); backup pages are numbered B1, B2, ….
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
      let backup = query(<backup>)
      let total = if backup.len() > 0 { backup.first().location().page() - 1 } else { counter(page).final().first() }
      let number = if n > total [B#(n - total)] else [#n/#total]
      if n > 1 { align(right, text(size: 11pt, fill: gray-text, number)) }
    },
    background: if notes-mode {
      place(top + left, dx: slide-width, line(angle: 90deg, length: 100%, stroke: 0.5pt + rule-gray))
      // the speaker notes of this page, placed in the right half
      context {
        let page-number = here().page()
        let notes = query(<speaker-note>).filter(n => n.location().page() == page-number)
        place(top + left, dx: slide-width + 1.5cm, dy: 1.0cm, block(width: slide-width - 3cm, {
          set text(size: 16pt)
          set par(leading: 0.65em, spacing: 0.9em)
          for n in notes { n.value }
        }))
      }
    },
  )
  set text(font: "New Computer Modern", size: 18pt, lang: "en")
  set par(leading: 0.8em, spacing: 1.0em)
  set list(spacing: 0.9em, indent: 0.3em)
  show math.equation.where(block: true): set block(above: 0.85em, below: 0.85em)
  set table(stroke: none, inset: (x: 0.45em, y: 0.3em))
  body
}

/// Speaker note of the current slide. Shown in the right half of the page in notes mode (drawn
/// by the page background, so it does not depend on the slide's layout), nowhere otherwise.
#let speaker-note(body) = if notes-mode [#metadata(body) <speaker-note>]

/// PDF navigation entry without visible content or added layout space.
#let slide-bookmark(title) = {
  show heading: _ => []
  heading(level: 1, numbering: none, outlined: false, bookmarked: true, title)
}

/// Vertical spacing of a slide body: `f` times the deck's normal paragraph, list and
/// display-equation spacing (block spacing follows the paragraph spacing).
#let spaced(f, body) = {
  set par(spacing: f * 1.0em)
  set list(spacing: f * 0.9em)
  show math.equation.where(block: true): set block(above: f * 0.85em, below: f * 0.85em)
  body
}

// A sparse slide gets proportionally larger spacing until its content reaches `fill-target` of
// the page height, by at most the factor `max-spread`.
#let fill-target = 0.9
#let max-spread = 2.2

/// One slide: bold title over a thin gray rule, then the body. `refs` is set in small gray type
/// at the bottom right. A sparse body is spread vertically (see `fill-target`); `spread: false`
/// keeps the normal spacing. `backup: true` marks a backup slide, placed after the end of the talk.
#let slide(title, refs: none, spread: true, backup: false, body) = {
  pagebreak(weak: true)
  slide-bookmark(title)
  if backup [#metadata(title) <backup>]
  let assemble(f) = {
    block(below: 0.4em, text(size: 1.3em, weight: "bold", title))
    line(length: 100%, stroke: 0.6pt + rule-gray)
    // the gap under the rule stays fixed; only the spacing inside the body is scaled
    block(above: 1.1em, width: 100%, spaced(f, body))
  }
  layout(size => {
    let height(f) = measure(width: size.width, assemble(f)).height
    let target = fill-target * size.height
    let f = 1
    if spread {
      let h1 = height(1)
      if h1 < target {
        // the height is convex in f (columns: maximum of linear functions), so the chord
        // between f = 1 and f = max-spread never overshoots the target
        let hm = height(max-spread)
        f = if hm <= target { max-spread } else { 1 + (max-spread - 1) * (target - h1) / (hm - h1) }
      }
    }
    assemble(f)
  })
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
  label((2.05, 2.93), "center", [$[macron(b) b]_1 (n P)$])
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
  ))[*(a)* rotations about the axis \ conserve $lambda_ell = bold(j)_ell dot hat(bold(r))$ \ $Lambda = |lambda_ell|$: $Sigma, Pi, Delta, dots$]

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
  lbl((5.8, 0.4), "west", text(size: 14pt)[$P$: $bold(r) arrow.r -bold(r)$])
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
  ))[*(c)* $M_(x z) = P R_y (pi)$: $y arrow.r -y$, \ sources stay put, $lambda_ell arrow.r -lambda_ell$ \ $arrow.r.double$ $sigma = plus.minus$ only for $Lambda = 0$]
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

// Heavy-meson line at height `y`: `segments` lists (x0, x1, starred); single line B, double
// line B*. Returns cetz draw commands.
#let heavy-line(y, segments) = {
  import cetz.draw: line
  for (x0, x1, starred) in segments {
    if starred {
      line((x0, y + 0.055), (x1, y + 0.055), stroke: 0.8pt)
      line((x0, y - 0.055), (x1, y - 0.055), stroke: 0.8pt)
    } else {
      line((x0, y), (x1, y), stroke: 0.8pt)
    }
  }
}

// One TOPT time ordering (Fig. 2 of the paper, as drawn in slides-continue.tex). Time runs to the
// right; `top`/`bottom` list the heavy-line segments (x0, x1, starred) of the meson and antimeson,
// single line B, double line B*; the dashed boson runs between the two vertices `boson`; the thin
// gray line cuts the intermediate state.
#let topt-diagram(top, bottom, boson, labels, boson-label, caption-text) = cetz.canvas(length: 1.3cm, {
  import cetz.draw: *
  let label(pos, anchor, body) = content(pos, text(size: 15pt, body), anchor: anchor, padding: 0.08)
  heavy-line(2, top)
  heavy-line(0, bottom)
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
  content((2, -1.3), text(size: 16pt, caption-text))
})

// The four classes of TOPT diagrams: (1), (2) the two orderings of B B̄* -> B* B̄; (3), (4) one
// ordering each with a B* B̄* pair in the final or the initial state.
#let topt-diagrams = (
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

// 2 x 2: top row the classes 1 and 2, bottom row the classes 3 and 4.
#let topt-figure = grid(columns: 2, column-gutter: 1.4em, row-gutter: 0.9em, ..topt-diagrams)

// The classes 1 and 2 only, stacked.
#let topt-pair = grid(row-gutter: 0.9em, ..topt-diagrams.slice(0, 2))

// One-boson exchange as a Feynman diagram (no time order): line 1 h1 -> h1', line 2 h2 -> h2',
// the boson carries (q0, q) from line 1 to line 2. Same line style as the TOPT diagrams.
#let feynman-ome = cetz.canvas(length: 1.3cm, {
  import cetz.draw: *
  let label(pos, anchor, body) = content(pos, text(size: 15pt, body), anchor: anchor, padding: 0.08)
  line((0, 2), (6, 2), stroke: 0.8pt)
  line((0, 0), (6, 0), stroke: 0.8pt)
  line((3, 2), (3, 0), stroke: (thickness: 0.8pt, dash: "dashed"))
  circle((3, 2), radius: 0.07, fill: black, stroke: none)
  circle((3, 0), radius: 0.07, fill: black, stroke: none)
  label((0.8, 2.12), "south", $h_1 (E_1, bold(p))$)
  label((5.2, 2.12), "south", $h'_1 (E'_1, bold(p)')$)
  label((0.8, -0.14), "north", $h_2 (E_2, -bold(p))$)
  label((5.2, -0.14), "north", $h'_2 (E'_2, -bold(p)')$)
  label((2.85, 1), "east", $phi.alt$)
  line((3.3, 1.45), (3.3, 0.55), stroke: 0.6pt, mark: (end: "stealth", fill: black))
  label((3.4, 1), "west", $(q_0, bold(q))$)
})

// B B̄* -> B* B̄ through one-meson exchange as a Feynman diagram, in the layout of the TOPT
// diagrams, with the chiral order of each piece: two vertices O(Q), one propagator O(Q^-2).
#let ome-counting-diagram = cetz.canvas(length: 1.3cm, {
  import cetz.draw: *
  let label(pos, anchor, body, fill: black) = content(
    pos,
    text(size: 15pt, fill: fill, body),
    anchor: anchor,
    padding: 0.08,
  )
  heavy-line(2, ((0, 2.3, false), (2.3, 4.6, true)))
  heavy-line(0, ((0, 2.3, true), (2.3, 4.6, false)))
  line((2.3, 2), (2.3, 0), stroke: (thickness: 0.8pt, dash: "dashed"))
  circle((2.3, 2), radius: 0.07, fill: black, stroke: none)
  circle((2.3, 0), radius: 0.07, fill: black, stroke: none)
  label((0.5, 2.12), "south", $B(bold(p))$)
  label((4.1, 2.12), "south", $B^*(bold(p)')$)
  label((0.5, -0.14), "north", $macron(B)^*(-bold(p))$)
  label((4.1, -0.14), "north", $macron(B)(-bold(p)')$)
  label((2.18, 1), "east", $phi.alt(bold(q))$)
  label((2.3, 2.12), "south", $cal(O)(Q)$, fill: key-stroke)
  label((2.3, -0.14), "north", $cal(O)(Q)$, fill: key-stroke)
  label((2.42, 1), "west", $cal(O)(Q^(-2))$, fill: key-stroke)
})

// The LO chiral Lagrangian for a single Φ field with the spin traces done (paper, Sect. III B):
// the form the vertices are read from. Shown on Task 4, Step 1 and, with the trace form, in the
// backup.
#let expanded-lagrangian = keybox[$
  cal(L)_Phi = & g_b / (2 F_pi) [(V_a^(k dagger) P_b + P_a^dagger V_b^k) partial_k Phi_(b a) + i epsilon_(i j k) V_a^(i dagger) V_b^j thin partial_k Phi_(b a)] \
  & + g_b / (2 F_pi) [-(macron(P)_a^dagger macron(V)_b^k + macron(V)_a^(k dagger) macron(P)_b) partial_k Phi_(a b) + i epsilon_(i j k) macron(V)_a^(i dagger) macron(V)_b^j thin partial_k Phi_(a b)] + cal(O)(Phi^3)
$]

// The X_b of the paper's Table V (m_b = 4.534 GeV, Λ = 4 GeV) as one bar of its component
// probabilities; the bracket marks the two parts that exist only through OME.
#let composition-bar = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let (w, h) = (22, 1.1)
  let ome-fill = key-stroke.lighten(85%)
  let parts = (
    (2, none, luma(120)),
    (41, $cal(P)_S = 41%$, white),
    (36, $cal(P)_D = 36%$, ome-fill),
    (21, $cal(P)_"3-body" = 21%$, ome-fill),
  )
  let x = 0
  for (percent, label, fill) in parts {
    let dx = percent / 100 * w
    rect((x, 0), (x + dx, h), fill: fill, stroke: 0.6pt)
    if label != none { content((x + dx / 2, h / 2), text(size: 15pt, label)) }
    x += dx
  }
  content((0, h + 0.1), text(size: 15pt, $cal(P)_(macron(b) b) = 2%$), anchor: "south-west")
  let (x0, x1) = (0.43 * w, w)
  line((x0, -0.12), (x0, -0.32), (x1, -0.32), (x1, -0.12), stroke: 0.8pt + key-stroke)
  content(
    ((x0 + x1) / 2, -0.42),
    text(size: 14pt, fill: key-stroke)[only through OME: tensor force, $E$-dependence of $D_beta$],
    anchor: "north",
  )
})

// Momentum scales of the B B̄* system: π or η exchange can be traded for contact terms only below
// the branch point of its left-hand cut, |p| < κ_lhc = 65 and 273 MeV (paper, Sect. II B); the X_b
// lies at κ = 695 MeV. Lower row: the energy E = −κ²/(2μ), μ = 2651 MeV, at each point.
#let lhc-axis = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let x(k) = k * 0.028 // MeV -> cm
  let label(pos, anchor, body) = content(pos, body, anchor: anchor, padding: 0.06)
  for (k, y, name) in ((65, 1.4, $pi$), (273, 0.75, $eta$)) {
    rect((0, y - 0.18), (x(k), y + 0.18), fill: luma(228), stroke: 0.6pt + luma(110))
    label((x(k) + 0.12, y), "west", text(size: 15pt)[contact terms for #name exchange])
  }
  line((0, 0), (x(780), 0), stroke: 0.8pt, mark: (end: "stealth", fill: black))
  label((-0.3, -0.12), "north-east", text(size: 14pt)[$abs(p)$ (MeV)])
  label((-0.3, -0.72), "north-east", text(size: 14pt, fill: gray-text)[$E$ (MeV)])
  for (k, e) in ((0, $0$), (65, $-0.8$), (273, $-14$), (695, $-91$)) {
    line((x(k), -0.1), (x(k), 0.1), stroke: 0.8pt)
    label((x(k), -0.12), "north", text(size: 14pt)[#k])
    label((x(k), -0.72), "north", text(size: 14pt, fill: gray-text, e))
  }
  circle((x(695), 0), radius: 0.12, fill: black, stroke: none)
  label((x(695), 0.15), "south", text(size: 16pt)[$X_b$])
})

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
  - #text(fill: rgb("#FF6600"))[Con:] Connection to short-range physics is nontrivial (comes as chiral expansion in $p^2/Lambda_chi^2$)
  #text(fill: red)[*Hope: Merge both approaches to unified systematically improvable method*]

]

#slide[Proof-of-concept BO$chi$EFT calculation at LO][
  Consider scattering problem for $B macron(B)^*$ system with $J^(P C) =1^(++)$ via potential
  $ V = V^"(OME)" + sum_(n = 1)^N V_n^((macron(b) b)) + C(Lambda, N) $
  - #text(fill: blue)[_t_-channel meson exchanges] $->$ potential #text(fill: red)[$V^"(OME)"$]:\ No free parameters
  #v(1em)
  - #text(fill: blue)[_s_-channel exchange of bottomonium states] $->$ potential #text(fill: red)[$V^((macron(b) b))$]:\ Parameters of interquark interaction and strength of transition $macron(b)b ->B macron(B)^*$ can be extracted from lattice-QCD calculations
  #v(1em)
  - #text(fill: blue)[Short-range counterterm] $->$  #text(fill: red)[$C$]:\ Absorbs all neglected effects
  #v(1em)
  Remaining free parameters can be fixed to the experimental spectrum of $chi_(b 1)$ bottomonia

]

// --------------------------------------------------------------- the 1++ channels and the s-channel Hamiltonian

#slide[Quantum numbers of $1^(+ +)$ pair][
  #speaker-note[This will be central in the later analysis of the BO symmetry. Since we are studying the $1^(+ +)$ state, parity makes $L$ even, and $C$ then makes $s_(macron(b) b) + j_ell$ even. $(s_(macron(b) b), j_ell) = (0, 0)$ would give $J = L$, which is even, so both are 1. They couple to total spin 0, 1, 2, and combined with even $L$ to $J = 1$, three channels are available.]
  $
    bold(J) = bold(s)_(macron(b) b) + bold(j)_ell + bold(L), quad J^(P C) = 1^(+ +), quad P = (-1)^L, quad C = (-1)^(s_(macron(b) b) + j_ell + L)
  $
  - $P = +$ makes $L$ even
  - then $C = +$ makes $s_(macron(b) b) + j_ell$ even: $(s_(macron(b) b), j_ell) = (0, 0)$ or $(1, 1)$
  - with $(0, 0)$ we would get $J = L$, which is even and never 1 #h(0.3em) $arrow.r.double$ #h(0.3em) $s_(macron(b) b) = j_ell = 1$
  $ s_(macron(b) b) times.o j_ell = 1 times.o 1 = 0 plus.o 1 plus.o 2 $
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
  #speaker-note[Now we need the actual formalism for the $s$-channel exchange. To allow transitions between the hadronic degrees of freedom and the bottomonium, we write down the coupled-channel Hamiltonian. It describes the dynamics of the entire system, consisting of the $B macron(B)^*$ meson pairs and the compact bottomonium states. Note that at LO the bottomonia couple only to the $S$-wave $B macron(B)^*$; couplings to other partial waves appear at higher orders.]
  $
    cal(H) = mat(
      H - M_"th", 0, dots.c, hat(g)^dagger;
      0, H - M_"th", dots.c, hat(g)^dagger;
      dots.v, dots.v, dots.down, dots.v;
      hat(g), hat(g), dots.c, H_"MM"
    ) quad "acting on" quad ket(Psi) = mat(lambda_1 ket([macron(b) b]_1 (1P)); lambda_2 ket([macron(b) b]_1 (2P)); dots.v; phi.alt(q) ket(B macron(B)^*))
  $
  #grid(
    columns: (1fr, auto),
    column-gutter: 1.5em,
    align: horizon,
    [
      $ "normalisation:" quad sum_n |lambda_n|^2 + integral (q^2 dif q) / (2 pi)^3 |phi.alt(q)|^2 = 1 $
      - $phi.alt(q) = sqrt(4 pi) Psi_S (q)$, $Psi_S (q) = braket(q\, 1, Psi)$; the paper's radial states obey $braket(q'\, 1, q\, 1) = (2 pi^2) / q^2 delta(q' - q)$
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
      hat(V)_S^((macron(b) b) + "CT")(E) = sum_(n <= N) (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) + C(Lambda, N)
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
  Split the space into the compact sector $Q$ and the meson-pair sector $M$; $P_Q$, $P_M$ and $H_(Q Q)$ are auxiliary projector/block labels for this derivation:
  $
    P_Q = sum_n ket(n) bra(n), quad P_M = integral_0^infinity (q^2 dif q) / (2 pi^2) ket(q) bra(q), quad P_Q + P_M = bold(1), quad P_Q P_M = 0
  $
  Sandwich $cal(H)$ between $bold(1) = P_Q + P_M$ on both sides:
  $
    cal(H) = (P_Q + P_M) cal(H) (P_Q + P_M) = underbrace(P_Q cal(H) P_Q, H_(Q Q)) + underbrace(P_M cal(H) P_M, H_"MM") + underbrace(P_M cal(H) P_Q, hat(g)) + underbrace(P_Q cal(H) P_M, hat(g)^dagger)
  $
  - $H_(Q Q) = P_Q (H - M_"th") P_Q = sum_n E_n ket(n) bra(n)$
  - $P_Q cal(H) P_M = (P_M cal(H) P_Q)^dagger = hat(g)^dagger$, because $cal(H)$ is Hermitian
  - ordered as (compact, meson pair): $cal(H) = mat(H_(Q Q), hat(g)^dagger; hat(g), H_"MM")$
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
  Multiplying by $P_M$ instead: #h(0.3em) $hat(g) P_Q ket(Psi) + H_"MM" P_M ket(Psi) = E P_M ket(Psi)$. Collecting terms:
  #keybox[$
    (E - H_(Q Q)) P_Q ket(Psi) = hat(g)^dagger P_M ket(Psi), quad (E - H_"MM") P_M ket(Psi) = hat(g) P_Q ket(Psi)
  $]
]

#slide[Task 1, Step 3: Eliminating the compact states][
  #speaker-note[Now we can invert one of the equations and plug it into the other. This gives a Schrödinger equation for the heavy-meson sector only, in which the compact states contribute through an energy-dependent potential.]
  For $E != E_n$, with the inverse taken inside the compact space:
  $ P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  Plug this into the second equation:
  $ (E - H_"MM") P_M ket(Psi) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  $H_(Q Q) = sum_n E_n ket(n) bra(n)$ is diagonal, so on the compact space $(E - H_(Q Q))^(-1) = sum_n (ket(n) bra(n)) / (E - E_n)$:
  #keybox[$
    [H_"MM" + hat(V)^((macron(b) b))(E)] P_M ket(Psi) = E P_M ket(Psi) \
    hat(V)^((macron(b) b))(E) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger = sum_n (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n)
  $]
  A Schrödinger equation for the heavy mesons alone: the compact states leave behind an #text(fill: blue)[energy-dependent potential].
]

#slide[Task 1, Step 4: Truncation and compact amplitudes][
  #speaker-note[We can split this potential into two pieces. The second piece has poles only far away from the threshold, so it is absorbed into the contact term at LO. With this formalism we can also compute the compact probability: this projection gives us the coefficients in front of the compact states.]
  Split $P_Q = P_(<= N) + P_(> N)$:
  $
    hat(V)^((macron(b) b))(E) = sum_(n <= N) (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) + hat(g) P_(> N) (E - H_(Q Q))^(-1) P_(> N) hat(g)^dagger
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
    & = mel(Psi_M, [1 - partial_E hat(V)^((macron(b) b))(E)], Psi_M)
  $
  #keybox[$
    cal(P)_(macron(b) b) = mel(Psi, P_Q, Psi) = sum_n |lambda_n|^2 = -mel(Psi_M, partial_E hat(V)^((macron(b) b)), Psi_M)
  $]
  The energy dependence of $hat(V)^((macron(b) b))$ _is_ the compact component.
]

// --------------------------------------------------------------- BO symmetry and the lattice input

#slide(
  refs: [Bulava _et al._ 2024, Eqs. (6) & (11) and Table 4],
)[What lattice measures: static potential with string breaking][
  #speaker-note[Now, what lattice sees is string breaking. Here, as you can see, the levels of the string and of the $B macron(B)$ pair give an avoided level crossing; these levels are calculated on the lattice. Fitting the spectrum of such a Hamiltonian to the data, we obtain the parameters needed to construct our theory: in particular the transition strength $g_l$ between the string and the $B macron(B)$ pair, which gives the coupling between bottomonium and the heavy mesons, as well as the potential of the string.

    So lattice gives us the static energies and the mixing $g_l$ at fixed $r$, labelled by the BO quantum numbers, while our channels are partial waves.]
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

#slide[BO symmetry: rotations around the axis between two sources][
  #speaker-note[To take the coupling from the lattice, we first need the BO symmetry, since the lattice levels are labelled by it. We consider a doubly heavy system with two heavy sources, and BO symmetry here means the cylindrical symmetry. As you know, angular momentum comes from the SO(3) rotational symmetry of the theory. But in the Born–Oppenheimer separation the light degrees of freedom see only two static heavy colour sources, so only rotations about the axis remain, and SO(3) reduces to a cylindrical symmetry. Thus only the projection $lambda_ell$ of the angular momentum of the light degrees of freedom on the axis is conserved; its absolute value $Lambda$ labels the levels $Sigma, Pi, Delta, dots$]
  - angular momentum comes from the SO(3) rotational symmetry of our theory
  - static $b$ and $macron(b)$ fix an axis: only rotations about it remain, SO(3) $arrow.r$ cylindrical symmetry
  - conserved: $lambda_ell = bold(j)_ell dot hat(bold(r))$, with $bold(j)_ell$ the total angular momentum of the light d.o.f.; #h(0.2em) $Lambda = |lambda_ell|$, written $Sigma, Pi, Delta, dots$ for $Lambda = 0, 1, 2, dots$
  #v(0.5em)
  #align(center, bo-figure())
  #caption[Two static sources at $plus.minus bold(r) \/ 2$ on the $z$ axis; filled: $b$, open: $macron(b)$, shaded: light degrees of freedom]
]

#slide[BO symmetry: $C P$ and reflections][
  #speaker-note[There are two discrete symmetries: the combined $C P$ parity $eta$, and a reflection $sigma$ through a plane containing the axis. Since a reflection flips the sign of the angular-momentum projection, only states with $Lambda = 0$ are $sigma$ eigenstates. These quantities are conserved as long as the BO separation holds, so we can use them to label the static energy levels, and to see which levels can mix.]
  - $eta = C P$: $P$ swaps the positions of $b$ and $macron(b)$, $C$ exchanges quark and antiquark, so the configuration is restored (panel b); #h(0.2em) $eta = g$ $(+1)$ or $u$ $(-1)$
  - $sigma = plus.minus$: reflection through a plane containing the axis; take $bold(r)$ along $z$ and the $x z$ plane (panel c):
  $
    M_(x z) = P R_y (pi): quad (x, y, z) stretch(arrow.r, size: #3em)^(R_y (pi)) (-x, y, -z) stretch(arrow.r, size: #3em)^P (x, -y, z)
  $
  - the sources stay put; on a light state
  $
    P R_y (pi) ket(j_ell\, lambda_ell) = P (-1)^(j_ell - lambda_ell) ket(j_ell\, -lambda_ell) quad arrow.r.double quad sigma ket(j_ell\, 0) = P (-1)^(j_ell) ket(j_ell\, 0)
  $
  - for $lambda_ell != 0$ the reflection maps $lambda_ell arrow.r -lambda_ell$, so $sigma$ is quoted only for $Lambda = 0$
]

// #slide[BO levels and string breaking][
//   #speaker-note[The string and $Sigma_g^(+')$ have the same labels, so their levels can't cross; they repel. That avoided crossing is string breaking, and it is what lattice measures.]
//   Light states of $ket(B macron(B))$ and of the string, labelled with the BO rules: #h(0.3em) $eta = C P$ of the light degrees of freedom; $sigma = P (-1)^(j_ell)$ for $lambda_ell = 0$.
//   #v(0.3em)
//   #align(center, text(size: 16pt, table(
//     columns: 7,
//     align: (left, center, center, center, center, center, left),
//     toprule, [light configuration], [$j_ell^(P C)$], [$lambda_ell$], [$eta$], [$sigma$], [label],
//     [role], midrule, [vacuum (string)], [$0^(+ +)$], [0], [$g$], [$+$],
//     [$Sigma_g^+$],
//     [compact $macron(b) b$, Cornell potential],
//     [$S$-wave pair, light triplet],
//     [$1^(- -)$],
//     [0],
//     [$g$],
//     [$+$],
//
//     [$Sigma_g^(+')$],
//     [mixes with the string],
//     [$S$-wave pair, light triplet],
//     [$1^(- -)$],
//     [$plus.minus 1$],
//     [$g$],
//     [–],
//
//     [$Pi_g$], [no direct mixing], [$S$-wave pair, light singlet], [$0^(- +)$], [0], [$u$], [$-$],
//     [$Sigma_u^-$], [no direct mixing; cannot give $1^(+ +)$], bottomrule,
//   )))
//   #v(0.3em)
//   - in $ket(B macron(B))$: $ket(1_ell\, 0) in Sigma_g^(+')$, #h(0.2em) $ket(1_ell\, plus.minus 1) in Pi_g$, #h(0.2em) $ket(0_ell\, 0) in Sigma_u^-$; the labels are conserved for static quarks, so only the $ket(1_ell\, 0)$ piece mixes with the string
//   - $Sigma_g^+$ and $Sigma_g^(+')$ share all labels, so their levels cannot cross $arrow.r$ avoided crossing = string breaking
// ]

// --------------------------------------------------------------- Task 2: BO configurations and partial waves

#slide[Task 2, Step 1: The BO coupling order][
  #speaker-note[Next we work out the relation between the BO coupling and the partial-wave coupling. There are three possible BO configurations; $J_ell = 2$ with $lambda_ell = 0$ is absent, because, as we will see, it has odd parity.]
  Two ways to couple $j_ell = s_(macron(b) b) = 1$ and $L$ to $J = 1$:
  $
    "partial waves:" & quad bold(S) = bold(j)_ell + bold(s)_(macron(b) b), quad bold(J) = bold(L) + bold(S) & quad arrow.r quad & ket(L\, (j_ell thin s_(macron(b) b)) S\; J) \
    "BO:" & quad bold(J)_ell = bold(L) + bold(j)_ell, quad bold(J) = bold(J)_ell + bold(s)_(macron(b) b) & quad arrow.r quad & ket((L thin j_ell) J_ell\, s_(macron(b) b)\; J)
  $
  - $L = 0$ gives $J_ell = 1$; $L = 2$ gives $J_ell = 1, 2, 3$, but $J_ell = 3$ cannot couple with $s_(macron(b) b) = 1$ to $J = 1$
  #grid(
    columns: (1fr, 1.25fr),
    column-gutter: 1.5em,
    align: horizon,
    align(center, table(
      columns: 5,
      align: center,
      toprule, [$J_ell^(P_ell C_ell)$], [$|lambda_ell|$], [$eta$], [$sigma$],
      [BO configuration], midrule, [$1^(- -)$], [0], [$g$],
      [$+$], [$Sigma_g^(+')$], [$1^(- -)$], [1], [$g$],
      [–], [$Pi_g\; 1$], [$2^(- -)$], [1], [$g$],
      [–], [$Pi_g\; 2$], bottomrule,
    )),
    [
      - $J_ell = 2$, $lambda_ell = 0$ is absent due to the CG coefficient
      $ braket(L = 2\, M_L = 0\; j_ell = 1\, M_(j_ell) = 0, J_ell = 2\, 0) = 0 $
      - three BO configurations, as many as partial-wave channels
    ],
  )
  #v(0.25em)
  #align(center, text(size: 16pt)[$
    eta = P_ell C_ell = +1 quad (g), quad sigma = P_ell (-1)^(J_ell) = +1 quad (lambda_ell = 0, J_ell = 1)
  $])
]

#slide(refs: [Jacob, Wick, Ann. Phys. 7, 404 (1959)])[Task 2, Step 2: Jacob–Wick formula][
  #speaker-note[The BO states only have a definite projection $lambda_ell$; we need to connect them with states of definite orbital angular momentum, and this is the Jacob–Wick formula. You can think of it as a modified CG coupling: in the usual CG coupling both angular momenta are quantised along the same fixed axis $z$, while the BO states have a definite projection $lambda_ell$ on the moving axis $hat(bold(r))$. Jacob–Wick does the coupling on that axis, where $bold(L) = bold(r) times bold(p)$ has no component, so only $m_L = 0$ survives and the CG coefficient becomes $braket(L thin 0 thin j_ell thin lambda_ell, J_ell thin lambda_ell)$; a rotation then carries it to any direction $hat(bold(r))$.]
  The BO states have a definite projection $lambda_ell$ of $bold(j)_ell$ on $hat(bold(r))$; the states $ket((L thin j_ell) J_ell thin M_ell)$ have a definite $L$. Jacob–Wick connects them:
  #keybox[$
    ket(J_ell thin M_ell\; lambda_ell) = sum_L sqrt((2L + 1) / (2 J_ell + 1)) braket(L thin 0 thin j_ell thin lambda_ell, J_ell thin lambda_ell) ket((L thin j_ell) J_ell thin M_ell)
  $]
  - then a $6j$ symbol takes definite $L$ to the partial-wave channels:
  $
    underbrace(ket(J_ell thin M_ell\; lambda_ell), "BO state") quad stretch(arrow.l.r, size: #4em)^"Step 1"_"Jacob–Wick" quad underbrace(ket((L thin j_ell) J_ell), "definite" L) quad stretch(arrow.l.r, size: #4em)^"Step 2"_(6j) quad underbrace(ket(L\, (j_ell thin s_(macron(b) b)) S\; J), "partial wave")
  $
  - next: derive the formula from the usual Clebsch–Gordan coupling
]

#slide[Deriving Jacob–Wick: start from Clebsch–Gordan][
  #speaker-note[First, we start from the usual CG coupling, written as a function of the direction in position space. Angular momentum is always quantised along a fixed axis, say $z$, but the BO state needs $lambda_ell$. So the idea is to first put $hat(bold(r))$ on the $z$ axis, where we have the CG coupling. As said earlier, the orbital angular momentum is $bold(r) times bold(p)$, so by definition it has no component along the axis, which you can also see from the spherical harmonics.]
  The usual CG coupling along a fixed axis $hat(z)$, written as a function of the direction $hat(bold(r))$ of the $b macron(b)$ axis (a light-spin state at each $hat(bold(r))$):
  $
    braket(hat(bold(r)), (L thin j_ell) J_ell thin M_ell) = sum_(m_L, m_l) braket(L thin m_L thin j_ell thin m_l, J_ell thin M_ell) Y_(L m_L)(hat(bold(r))) ket(j_ell thin m_l)
  $
  - BO needs $lambda_ell$, the projection of $bold(j)_ell$ on $hat(bold(r))$, not on the fixed $hat(z)$
  - look on the axis first, $hat(bold(r)) = hat(z)$: there $Y_(L m_L)(hat(z)) = sqrt((2L + 1) \/ 4 pi) thin delta_(m_L 0)$, because $Y_(L m) prop sin^(|m|) theta$. The orbital motion has no projection on its own direction ($bold(L) dot hat(bold(r)) = 0$), so the CG sum collapses to the $m_L = 0$ term:
  #keybox[$
    braket(hat(z), (L thin j_ell) J_ell thin M_ell) = sqrt((2L + 1) / (4 pi)) braket(L thin 0 thin j_ell thin M_ell, J_ell thin M_ell) ket(j_ell thin M_ell)
  $]
  - on the axis the projection on $hat(z)$ is the projection on $hat(bold(r))$, so $M_ell = lambda_ell$
]

#slide[Jacob–Wick: rotate away from the axis][
  #speaker-note[Next, we use a rotation that takes $z$ to the arbitrary direction $hat(bold(r))$; that introduces a Wigner $D$-matrix. Now you see how a multiplet with definite $J$ transforms. We plug this into the CG coupling obtained before and arrive at this equation.]
  $R$: the rotation taking $hat(z)$ to $hat(bold(r))$; $U(R) = U_"orb" (R) thin U_"spin" (R)$ rotates the direction and the light spin; $D^J_(M' M)(R) = mel(J thin M', U(R), J thin M)$.
  - a multiplet of definite $J$ is fixed by its values on the axis:
    $
      braket(R hat(z), J thin M) = sum_lambda D^(J*)_(M lambda)(R) thin U_"spin" (R) braket(hat(z), J thin lambda)
    $
    because $bra(R hat(z)) = bra(hat(z)) U_"orb"^dagger = bra(hat(z)) U_"spin" U^dagger$ and $U^dagger ket(J thin M) = sum_lambda D^(J*)_(M lambda) ket(J thin lambda)$
  - insert the axis values of the previous slide (there $M_ell = lambda$):
  #keybox[$
    braket(hat(bold(r)), (L thin j_ell) J_ell thin M_ell) = sqrt((2L + 1) / (4 pi)) sum_lambda braket(L thin 0 thin j_ell thin lambda, J_ell thin lambda) D^(J_ell*)_(M_ell lambda)(R) ket(j_ell thin lambda)_(hat(bold(r)))
  $]
  - $ket(j_ell thin lambda)_(hat(bold(r))) equiv U_"spin" (R) ket(j_ell thin lambda)$ is the light spin with projection $lambda$ on $hat(bold(r))$
]

#slide[Identify the BO states and invert][
  #speaker-note[Next, we see that each term is a BO state in position space, so we have the transformation between the BO states and the states with definite orbital angular momentum. But what we really need is the inverse, and that is easy: the transformation is orthogonal, so the inverse is just the transpose.]
  Each term is a BO state, with definite $J_ell$, $M_ell$ and light projection $lambda$ on $hat(bold(r))$:
  $
    braket(hat(bold(r)), J_ell thin M_ell\; lambda) = sqrt((2 J_ell + 1) / (4 pi)) D^(J_ell*)_(M_ell lambda)(R) ket(j_ell thin lambda)_(hat(bold(r))), quad integral dif Omega thin |D^J_(M lambda)|^2 = (4 pi) / (2 J + 1)
  $
  So the previous slide reads
  $
    ket((L thin j_ell) J_ell thin M_ell) = sum_lambda c_(L lambda) ket(J_ell thin M_ell\; lambda), quad c_(L lambda) = sqrt((2L + 1) / (2 J_ell + 1)) braket(L thin 0 thin j_ell thin lambda, J_ell thin lambda)
  $
  - $c$ is real and links two orthonormal bases, so it is orthogonal, $c^(-1) = c^T$, which gives the formula of Step 1:
  #keybox[$
    ket(J_ell thin M_ell\; lambda_ell) = sum_L sqrt((2L + 1) / (2 J_ell + 1)) braket(L thin 0 thin j_ell thin lambda_ell, J_ell thin lambda_ell) ket((L thin j_ell) J_ell thin M_ell)
  $]
]

#slide[Applying Jacob–Wick formula: the $lambda_ell = 0$ states][
  #speaker-note[This is just an evaluation of the formula derived above. You see there is no even-$L$ piece in the $J_ell = 2$, $lambda_ell = 0$ state, so it has negative parity and is excluded from our $1^(+ +)$ sector.]
  - $J_ell = 1$: #h(0.3em) $braket(0 thin 0 thin 1 thin 0, 1 thin 0) = 1$, #h(0.3em) $braket(1 thin 0 thin 1 thin 0, 1 thin 0) = 0$, #h(0.3em) $braket(2 thin 0 thin 1 thin 0, 1 thin 0) = -sqrt(2 \/ 5)$:
  $
    c_(0 0) = sqrt(1 / 3) dot 1 = 1 / sqrt(3), quad c_(1 0) = 0, quad c_(2 0) = sqrt(5 / 3) dot (-sqrt(2 / 5)) = -sqrt(2 / 3)
  $
  #keybox[$ ket(Sigma_g^(+')) = 1 / sqrt(3) ket((0 thin 1) 1) - sqrt(2 / 3) ket((2 thin 1) 1) $]
  - $J_ell = 2$: #h(0.3em) $braket(1 thin 0 thin 1 thin 0, 2 thin 0) = sqrt(2 \/ 3)$, #h(0.3em) $braket(2 thin 0 thin 1 thin 0, 2 thin 0) = 0$, #h(0.3em) $braket(3 thin 0 thin 1 thin 0, 2 thin 0) = -sqrt(3 \/ 7)$:
  $
    ket(J_ell = 2\, lambda_ell = 0) = sqrt(3 / 5) sqrt(2 / 3) ket((1 thin 1) 2) - sqrt(7 / 5) sqrt(3 / 7) ket((3 thin 1) 2) = sqrt(2 / 5) ket((1 thin 1) 2) - sqrt(3 / 5) ket((3 thin 1) 2)
  $
  - only odd $L$, i.e. negative parity: besides the vanishing $L = 2$ CG coefficient there is no even-$L$ piece at all, so this state is absent
]

// #slide[Applying Jacob–Wick: the $lambda_ell = plus.minus 1$ states ($Pi_g$)][
//   #speaker-note[Okay, this one is not interesting, just an evaluation.]
//   Same steps with $braket(L thin 0 thin 1 thin plus.minus 1, J_ell thin plus.minus 1)$:
//   - $J_ell = 1$, $lambda_ell = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = 1 / sqrt(3) ket((0 thin 1) 1) minus.plus 1 / sqrt(2) ket((1 thin 1) 1) + 1 / sqrt(6) ket((2 thin 1) 1)$ \
//     the $L = 1$ piece has the wrong parity and is the one that flips sign, so the parity-even state is $(ket(+1) + ket(-1)) \/ sqrt(2)$:
//     $ ket(Pi_g\; 1) = sqrt(2 / 3) ket((0 thin 1) 1) + 1 / sqrt(3) ket((2 thin 1) 1) $
//   - $J_ell = 2$, $lambda_ell = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = sqrt(3 / 10) ket((1 thin 1) 2) minus.plus 1 / sqrt(2) ket((2 thin 1) 2) + 1 / sqrt(5) ket((3 thin 1) 2)$ \
//     now the even-$L$ piece flips sign: the parity-even state is $(ket(+1) - ket(-1)) \/ sqrt(2) = -ket((2 thin 1) 2)$; dropping the overall sign (a convention), $ket(Pi_g\; 2) = ket((2 thin 1) 2)$
// ]

#slide[Task 2, Step 3: $6j$ recoupling at fixed $L$][
  #speaker-note[Now we have converted the BO states into states with definite orbital angular momentum. Next, we recouple them into the partial-wave scheme, where the heavy spin and the light spin couple first. This is just a Wigner $6j$ symbol.]
  To reach the partial-wave channels, move $j_ell$ from $L$ over to $s_(macron(b) b)$; the overlap is a $6j$ symbol:
  $
    braket((L thin j_ell) J_ell\, s_(macron(b) b)\; J, L\, (j_ell thin s_(macron(b) b)) S\; J) = (-1)^(L + j_ell + s_(macron(b) b) + J) sqrt((2 J_ell + 1)(2 S + 1)) mat(delim: "{", L, j_ell, J_ell; s_(macron(b) b), J, S)
  $
  - $L = 0$: nothing to do, $ket((0 thin 1) 1) = ket(pw(3, S, 1))$
  - $L = 2$: the phase is $(-1)^5 = -1$, and
  $
    mat(delim: "{", 2, 1, 1; 1, 1, 1) = 1 / 6, quad mat(delim: "{", 2, 1, 1; 1, 1, 2) = mat(delim: "{", 2, 1, 2; 1, 1, 1) = -sqrt(5) / 10, quad mat(delim: "{", 2, 1, 2; 1, 1, 2) = -1 / 10
  $
  e.g. $braket((2 thin 1) 1, pw(3, D, 1)) = -sqrt(3 dot 3) dot 1 \/ 6 = -1 \/ 2$. In total
  #keybox[$
    ket((2 thin 1) J_ell = 1) = -1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1)), quad ket((2 thin 1) J_ell = 2) = sqrt(3) / 2 ket(pw(3, D, 1)) + 1 / 2 ket(pw(5, D, 1))
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
  $ cal(O)_W (y, x, t) = macron(Q)(y, t) (bold(gamma) dot bold(r)) / r W(y, x, t) Q(x, t) $
  - $bold(gamma) dot bold(r) \/ r$ gives $ket(1\, 0)$ for the heavy spin (projection 0 on the axis); heavy-quark spin(HQSS)/BO quantum number is conserved
  #keybox[$ sqrt(2) g_l = -1 / 2 mel(W, H, 1_(macron(b) b)\, 0\; 1_ell\, 0) $]
  - to show this: $B macron(B)$ is coupled as $ket([(s_b j_(ell 1))_0 (s_macron(b) j_(ell 2))_0]_0)$; recouple it into $ket([(s_b s_macron(b))_(s_(macron(b) b)) (j_(ell 1) j_(ell 2))_(j_ell)]_0)$
]

#slide[Recoupling $B macron(B)$: the $9j$ symbol][
  #speaker-note[This is just the Wigner $9j$ symbol, and after evaluation it gives this relation.]
  #text(size: 16pt)[$
    braket([(j_1 j_2) J_(12) thin (j_3 j_4) J_(34)] J, [(j_1 j_3) J_(13) thin (j_2 j_4) J_(24)] J) = sqrt((2 J_(12) + 1)(2 J_(34) + 1)(2 J_(13) + 1)(2 J_(24) + 1)) mat(delim: "{", j_1, j_2, J_(12); j_3, j_4, J_(34); J_(13), J_(24), J)
  $]
  #grid(
    columns: (1.1fr, 0.9fr),
    column-gutter: 1.5em,
    row-gutter: 1em,
    [
      - here $j_1 = s_b$, $j_2 = j_(ell 1)$, $j_3 = s_macron(b)$, $j_4 = j_(ell 2)$, all $1 \/ 2$
      - $J_(12) = J_(34) = 0$ (pseudoscalars), and $J = 0$
      - so $s_(macron(b) b) = J_(13) = J_(24) = j_ell equiv s in {0, 1}$
    ],
    [
      A $9j$ symbol with a zero reduces to a $6j$ symbol:
      $
        mat(delim: "{", a, b, e; c, d, e; f, f, 0) = (-1)^(b + c + e + f) / sqrt((2e + 1)(2f + 1)) mat(delim: "{", a, b, e; d, c, f)
      $
    ],

    [
      Ours, with the elementary $6j$ symbol $(-1)^(1 + s) \/ 2$:
      $
        mat(delim: "{", 1\/2, 1\/2, 0; 1\/2, 1\/2, 0; s, s, 0) = (-1)^(1 + s) / sqrt(2s + 1) dot (-1)^(1 + s) / 2 = 1 / (2 sqrt(2s + 1))
      $
    ],
    [
      The signs cancel; the coefficient is $sqrt((2s + 1)^2) dot 1 / (2 sqrt(2s + 1)) = sqrt(2s + 1) / 2$:
      #keybox[$ ket(B macron(B)) = 1 / 2 ket((0_(macron(b) b) 0_ell)_0) + sqrt(3) / 2 ket((1_(macron(b) b) 1_ell)_0) $]
    ],
  )
]

#slide[Task 3, Step 2: Decouple the spin][
  #speaker-note[We need to break this coupling up further: the state with heavy spin one and BO quantum numbers $(1, 0)$ comes with the coefficient $-1 \/ 2$, which gives us an extra factor of two. The sign in front of this coefficient doesn't matter, because we use the square of the coupling.]
  Open $(1_(macron(b) b) 1_ell)_0$ into projections on the axis:
  $
    ket((1_(macron(b) b) 1_ell)_0) = sum_m braket(1 thin m thin 1 thin um m, 0 thin 0) ket(1_(macron(b) b)\, m) ket(1_ell\, -m), quad braket(1 thin m thin 1 thin um m, 0 thin 0) = (-1)^(1 - m) / sqrt(3)
  $
  so the coefficient of $ket(1_(macron(b) b)\, 0) ket(1_ell\, 0)$ is $sqrt(3) \/ 2 dot (-1 \/ sqrt(3)) = -1 \/ 2$. Altogether
  $
    ket(B macron(B)) = 1 / 2 ket(0_ell\, 0) ket(0_(macron(b) b)\, 0) + 1 / 2 sum_(lambda_ell = plus.minus 1, 0) (-1)^(lambda_ell + 1) ket(1_ell\, lambda_ell) ket(1_(macron(b) b)\, -lambda_ell)
  $
  - the only part with $ket(1_(macron(b) b)\, 0)$ is $ket(1_(macron(b) b)\, 0\; 1_ell\, 0)$, with coefficient $-1 \/ 2$
  #keybox[$mel(W, H, 1_(macron(b) b)\, 0\; 1_ell\, 0) = -2 sqrt(2) thin g_l$]
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
  - $mel(Sigma_g^(+'), H, W)$ is the mixing with the normalised $Sigma_g^(+')$ configuration; by HQSS it equals $mel(1_(macron(b) b)\, 0\; 1_ell\, 0, H, W) = -2 sqrt(2) thin g_l$ from the lattice
  - the sign does not matter, since $V^((macron(b) b)) prop g^2$
]

// --------------------------------------------------------------- recap and power counting

#slide[Proof-of-concept BO$chi$EFT calculation at LO][
  Consider scattering problem for $B macron(B)^*$ system with $J^(P C) =1^(++)$ via potential
  $ V = V^"(OME)" + sum_(n = 1)^N V_n^((macron(b) b)) + C(Lambda, N) $
  - #text(fill: blue)[_t_-channel meson exchanges] $->$ potential #text(fill: red)[$V^"(OME)"$]:\ No free parameters
  #v(1em)
  - #text(fill: blue)[_s_-channel exchange of bottomonium states] $->$ potential #text(fill: red)[$V^((macron(b) b))$]:\ Parameters of interquark interaction and strength of transition $macron(b)b ->B macron(B)^*$ can be extracted from lattice-QCD calculations
  #v(1em)
  - #text(fill: blue)[Short-range counterterm] $->$  #text(fill: red)[$C$]:\ Absorbs all neglected effects
  #v(1em)

]

#slide()[Power counting: OME is $cal(O)(Q^0)$ and explicit][
  #speaker-note[We denote by $Q$ a generic momentum scale below the chiral-symmetry-breaking scale $Lambda_chi$, which is about 1 GeV. For the light-pseudoscalar exchanges each LO chiral vertex counts as order $Q$ and the light-meson propagator counts as order $Q^(-2)$, so in total the OME potential counts as order $Q^0$. But the OME interaction is only well defined when it is supplemented by a short-range contact interaction, $C$ here, which explicitly depends on the hard scale of the EFT, $Lambda_chi$.

    For $B macron(B)^*$ scattering the OME potential possesses a left-hand cut, with the branch point at $kappa_"lhc"$: 65 MeV for the exchanged pion and 273 MeV for the eta. These are smaller than the binding momentum of the $X_b$ that we obtain, 695 MeV, so the contribution of the exchanges cannot be represented by a derivative expansion in local contact interactions over the momentum region relevant for the bound state. So both exchanges are kept explicitly; in the isoscalar channel the pion enters with weight three and the eta with one third, and there is no free parameter.]
  #grid(
    columns: (auto, 1fr),
    column-gutter: 1.2em,
    align: (center + horizon, left + horizon),
    ome-counting-diagram,
    [
      - $Q$: momentum scale below the chiral-symmetry-breaking scale $Lambda_chi approx 1$ GeV
      - two vertices and one propagator  give #box($cal(O)(Q^0)$)
    ],
  )
  - derivative expansion only works for $abs(p) < kappa_"lhc" = 1/2 sqrt(m_phi.alt^2 - Delta m^2)$
  #align(center, lhc-axis)
  - $pi$ and $eta$ exchanges are both kept, with no free parameter
]

#slide()[Power counting: bottomonium exchange][
  #speaker-note[For the $s$-channel bottomonium exchange, each $S$-wave vertex counts as order $Q^0$, while the $s$-channel propagator is state dependent, since the energy separation of the different states from the threshold varies considerably, and whether a state is enhanced is not known a priori. For a state whose energy counted from the threshold is of order $Q^2 \/ (2 mu)$, the contribution is kinematically enhanced and counts as order $Q^(-2)$. For states whose separation from the threshold is of order $Lambda_chi$ or larger, both the propagator and the exchange contribution count as order $Q^0$. We keep the first $N$ states whatever their distance from threshold. At $N = 4$ the $5P$ level is the first omitted state; in the fit shown here it lies 444 MeV above threshold. For energies small compared with this gap, its propagator can be expanded: the leading term is a constant, which goes into $C$ at order $Q^0$, and the energy-dependent terms are higher order. The number illustrates the separation of scales; the constant approximation requires $abs(E) << E_5$, not merely that the level is called $5P$.]
  $
    hat(V)_n^((macron(b) b))(E) = underbrace(hat(g) ket(n), cal(O)(Q^0)) thin underbrace(1 / (E - E_n), "state dependent") thin underbrace(bra(n) hat(g)^dagger, cal(O)(Q^0))
  $
  Bare energies measured from the $B macron(B)^*$ threshold:
  #align(center, table(
    columns: 5,
    column-gutter: 0.9em,
    row-gutter: 0.3em,
    align: (left, center, center, center, center),
    toprule, [bare state $[macron(b) b]_1 (n P)$], [$1P$], [$2P$], [$3P$],
    [$4P$], midrule, [$E_n$ (GeV)], [$-0.728$], [$-0.362$],
    [$-0.062$], [$0.203$], bottomrule,
  ))
  - $abs(E_n) tilde.op Q^2 \/ (2 mu)$, kinematically enhanced, $cal(O)(Q^(-2))$
  - $abs(E_n) gt.tilde Lambda_chi$: $cal(O)(Q^0)$ and analytic for momenta $tilde.op Q$
]

#slide()[Matching with BO][
  #speaker-note[In the heavy-quark limit the kinetic energies of the heavy quark and antiquark sources vanish, and so does the hyperfine splitting between the $B$ and $B^*$ mesons; the recoil terms from OME also vanish. At each fixed $b macron(b)$ separation $r$, the eigenenergies of the light degrees of freedom define $r$-dependent, energy-independent BO potentials, which are labelled by the BO quantum numbers. In the BO basis the potential is diagonal, and furthermore it can be separated into two parts: the first one is invariant under the orthogonal transformation, and the other one induces the partial-wave mixing after we transform to the partial-wave basis. These are the central and the tensor potential.

    In the local static limit the two configurations $Sigma_g^(+')$ and $Pi_g$ are degenerate for $r -> 0$ and approach the same meson-pair threshold at large distances, while they can differ at intermediate distances. In our formalism the long-range parts of the two levels are provided by the OME potential, evaluated in the basis of two-meson channels. In BOEFT this part is modelled, and the spin-averaged $X_b$ binding energy moved from 15 to 1.1 MeV when the pion range was changed. The short-range parts of these levels are parameterised via a derivative expansion of local operators. This is necessary because we use the two-hadron states as dynamical degrees of freedom, without resolving their internal structure at short distances. And at leading order the short-range part is parameterised by a constant contact term.]
  #set text(size: 17pt)
  Static BO potentials in heavy-quark limit
  $
    op("diag")(V_(Sigma_g^(+')), V_(Pi_g), V_(Pi_g)) = V_(Pi_g) thin bold(1) + (V_(Sigma_g^(+')) - V_(Pi_g))op("diag")(1,0,0)
  $
  Orthogonal transformation
  $
    V_(alpha' alpha)(r) = [U^T op("diag")(V_(Sigma_g^(+')), V_(Pi_g), V_(Pi_g)) thin U]_(alpha' alpha) = V_(Pi_g)(r) thin delta_(alpha' alpha) + [V_(Sigma_g^(+'))(r) - V_(Pi_g)(r)] braket(alpha', Sigma_g^(+')) braket(Sigma_g^(+'), alpha)
  $
  #keybox[$
    V(r) = V_C (r) thin bold(1) + V_T (r) mat(0, -sqrt(2), sqrt(6); -sqrt(2), 1, sqrt(3); sqrt(6), sqrt(3), -1), quad V_C = 1 / 3 [V_(Sigma_g^(+')) + 2 V_(Pi_g)], quad V_T = 1 / 6 [V_(Pi_g) - V_(Sigma_g^(+'))]
  $]
  - $Sigma_g^(+')$–$Pi_g$ splitting mixes the partial waves which vanishes for $r -> 0$ and for $r -> infinity$
]

#slide()[Matching with BO][
  #speaker-note[To see this, we perform the Fourier–Bessel transformation of the potential and look at the spherical Bessel functions: at small argument $j_L (x)$ behaves as $x^L$. So the short-range piece comes without momentum factors for $S$ to $S$, with two powers of momentum for $S$ to $D$, and with four for $D$ to $D$. So the LO contact term contributes only to $V_(11)$.]
  #set text(size: 17pt)
  With $braket(bold(r), p\, alpha) = 4 pi thin i^(L_alpha) j_(L_alpha)(p r) thin cal(Y)^(J = 1)_(L_alpha S_alpha)(hat(bold(r)))$, #h(0.2em) $(L_1, L_2, L_3) = (0, 2, 2)$:
  $
    V_(alpha' alpha)(p', p) = 4 pi thin i^(L_alpha - L_(alpha')) integral_0^infinity dif r thin r^2 thin j_(L_(alpha'))(p' r) thin V_(alpha' alpha)(r) thin j_(L_alpha)(p r)
  $
  Contact terms from the short-range piece $V^(<)$, $r lt.tilde 1 \/ Lambda_chi$
  $
    j_L (x) = x^L / ((2 L + 1)!!) [1 - x^2 / (2 (2 L + 3)) + dots.c] quad => quad V^(<)_(alpha' alpha)(p', p) prop p'^(L_(alpha')) p^(L_alpha) = cases(1 & quad #[$S$–$S$], p^2 "or" p'^2 & quad #[$S$–$D$], p'^2 p^2 & quad #[$D$–$D$])
  $
  #keybox[$
    V_(alpha' alpha)(p', p) = V^"(OME)"_(alpha' alpha)(p', p) + delta_(alpha' 1) delta_(alpha 1) [sum_(n = 1)^N V_n^((macron(b) b))(p', p) + C(Lambda, N)]
  $]
  - the contact term contributes only to $V_(11)$
  - at LO the $S$–$D$ and $D$–$D$ entries are OME alone
  - contact terms with two and four derivatives enter at higher orders
]

#slide[Matching with BO][
  #set text(size: 17pt)
  At short distance $V_Sigma_g^(+')(0) = V_Pi_g (0)$, the splitting is even in $r$
  $
    V_T (r) = b_T thin r^2 + c_T thin r^4 + dots.c, quad b_T = cal(O)(Lambda_"QCD"^3), quad c_T = cal(O)(Lambda_"QCD"^5)
  $
  Integrated over the region that the mesons do not resolve, $r < 1 \/ Lambda_chi$:
  $
    C^(<)_(T, n) equiv 4 pi integral_0^(1 \/ Lambda_chi) dif r thin r^n thin V_T (r) = (4 pi) / Lambda_chi^n [b_T / ((n + 3) Lambda_chi^3) + c_T / ((n + 5) Lambda_chi^5)]
  $
  #keybox[$
    V^(<)_(12)(p', p) & = sqrt(2) / 15 [p^2 thin C^(<)_(T, 4) - (p'^2 p^2 \/ 6 + p^4 \/ 14) thin C^(<)_(T, 6)] + dots.c \
    V^(<)_(23)(p', p) & = sqrt(3) / 225 thin p'^2 p^2 thin C^(<)_(T, 6) + dots.c, quad V^(<)_(13)(p', p) = -sqrt(3) thin V^(<)_(12)(p', p)
  $]
  - successive term of the multipole expansion costs $(Lambda_"QCD" \/ Lambda_chi)^2$ and is counted as $cal(O)(Q^2)$
  - higher-order BO potentials enter $V_(11)$ at $cal(O)(Q^2)$ and all other entries from $cal(O)(Q^4)$
]

// --------------------------------------------------------------- Task 4: one-meson exchange

#slide()[Task 4, Step 1: Lagrangian, vertices and tensor force][
  #set text(size: 17pt)
  LO chiral Lagrangian
  #expanded-lagrangian
  Read off the two vertices (common $plus.minus i$ omitted):
  $
    v^a_(B^* B phi.alt) = g_b / (2 F_pi) tau^a (bold(epsilon) dot bold(q)), quad v^a_(B^* B^* phi.alt) = -g_b / (sqrt(2) F_pi) tau^a (bold(A) dot bold(q)), quad bold(A) = i / sqrt(2) bold(epsilon) times bold(epsilon)'^*
  $
  One derivative per vertex $arrow.r.double$ $P$-wave emission

  two vertices give
  $
    q_i q_j = underbrace(q_i q_j - 1 / 3 delta_(i j) q^2, "tensor") + underbrace(1 / 3 delta_(i j) q^2, "central")
  $
  - tensor part couples $S$ and $D$ waves
]

#slide()[Task 4, Step 2: The denominators; three-body states][
  #set text(size: 17pt)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 1.5em,
    align: (center + horizon, left + horizon),
    topt-pair,
    [
      Second-order TOPT
      $
        V_(alpha' alpha)^("OME")(p',p;E) = sum_beta frac(chevron.l p' alpha' mid(|) cal(H)^dagger_"int" mid(|)beta chevron.r chevron.l beta mid(|) cal(H)_"int" mid(|) p alpha chevron.r, M - E_"3-body" + i 0)
      $
      $
        1 / (2 E_phi.alt) dot 1 / (M - E_(h_1) - E_(h_2) - E_phi.alt + i epsilon) = -1 / (2 E_phi.alt [E_phi.alt + mu_beta]) equiv -D_beta
      $
      #caption[$E_phi.alt = sqrt(bold(q)^2 + m_phi.alt^2)$, #h(0.5em) $mu_beta = E_(h_1) + E_(h_2) - M - i epsilon$, #h(0.5em) $M = m_B + m_(B^*) + E$]
      Three things enter $mu_beta$:
      $
        mu_1 = underbrace(-Delta m, "mass splitting") + underbrace((p^2 + p'^2) / (2 m_B), "recoil") - underbrace(E, "energy") - i epsilon, quad mu_2 = +Delta m + (p^2 + p'^2) / (2 m_(B^*)) - E - i epsilon
      $
      #keybox[$
        V_(B macron(B)^* -> B macron(B)^*) = -g_b^2 / (4 F_pi^2) (bold(epsilon) dot bold(q))(bold(epsilon)'^* dot bold(q)) thin [D_1 + D_2]
      $]
    ],
  )
]

#slide[Task 4, Step 3: Full OME and its static limit][
  #set text(size: 17pt)
  Dropping the recoil terms and $E$ in $mu_(1, 2)$
  $
    D_1 + D_2 -> 1 / (2 E_phi.alt) [1 / (E_phi.alt - Delta m) + 1 / (E_phi.alt + Delta m)] = 1 / (bold(q)^2 + m_phi.alt^2 - Delta m^2)
  $
  - $B$ mesons: $Delta m = 46$ MeV $< m_pi$: a tail $prop e^(-mu_pi r) \/ r$, $B macron(B) pi$ off shell
  - $D$ mesons: $m_(D^*) - m_D > m_pi$: $D macron(D) pi$ on shell, recoil terms are needed for the right analytic structure
  We keep full OME, with $Delta m$, recoil and $E$ in every $mu_beta$:
  - one formalism for the bottom and the charm sector
  - at $p = p' = kappa_(X_b) = 695$ MeV and $E = -91$ MeV: recoil $approx 91$ MeV and $-E = 91$ MeV, against $Delta m = 46$ MeV, so $mu_1 approx 137$ MeV instead of $-46$ MeV
  - the $E$-dependence carries the three-body states, $cal(P)_"3-body" = -mel(Psi_M, partial_E hat(V)^"(OME)", Psi_M)$
]

#slide[What OME does to the $X_b$][
  #speaker-note[Before we solve the scattering equation, let me jump ahead to what this potential does to the $X_b$. In the full calculation the $X_b$ is 2% compact, 41% two-body $S$ wave, 36% $D$ wave and 21% three-body; the deuteron, for comparison, has about 5% $D$ wave. The $D$ waves exist only through the tensor force, and the three-body part only through the energy dependence of the TOPT denominators; Task 6 shows how it is computed.

    If we switch off the tensor force and refit, the fitted masses come back and the predicted $chi_(b 1)(3P)$-dominated state moves by 4 MeV, but the $S$-wave compositeness of the $X_b$ goes from 42% to 90%. Switching off the mass splitting, the recoil or the energy dependence moves the predicted state by at most 3 MeV, and the $S$-wave compositeness stays between 39% and 53%; in the charm sector these effects become substantial, which is why we keep them.

    The price of the tensor force is that it is singular, like $1 \/ r^3$. Refitted at each cutoff from 3 to 5 GeV, the contact term jumps around and changes sign, while the predicted state moves by 1 MeV; without the tensor force it hardly changes. And a spurious pole appears far below the $1P$ state, with a binding momentum of 2.5 to 3 GeV, outside the range of the theory; projecting it out moves the masses by less than 1 MeV.]
  #spaced(0.8)[
    #set text(size: 17pt)
    $X_b$ at 10.513 GeV ($E_B = 91$ MeV) in LO BO$chi$EFT; the deuteron has about 5% $D$ wave:
    #align(center, composition-bar)
    #grid(
      columns: (1fr, 1.25fr),
      column-gutter: 1.6em,
      [
        Parts of OME off, parameters refitted:
        #align(center, table(
          columns: 2,
          align: (left, center),
          toprule, [OME],
          [$X_S [X_b]$], midrule,
          [full], [42%],
          [no $Delta m$, recoil and/or $E$-dep.], [39–53%],
          [no tensor force], [90%],
          bottomrule,
        ))
        the $chi_(b 1)(3P)$-dominated state moves by at most 4~MeV
      ],
      [
        The price: the tensor force is singular ($1 \/ r^3$)
        - $C = 10.55$, $-16.27$, $-0.67$~GeV#super[−2] at #box[$Lambda = 3, 4, 5$~GeV] (no tensor force: $5.89$, $6.16$, $6.22$); the $chi_(b 1)(3P)$-dominated state moves by 1~MeV
        - spurious pole at 8.96–9.40~GeV, binding momentum 2.5–3~GeV; projecting it out moves the masses by less than 1~MeV
      ],
    )
  ]
]

// --------------------------------------------------------------- Task 5: the scattering equation

#slide[Task 5, Step 1: The Lippmann–Schwinger equation][
  $
    hat(T) ket(p\, alpha) = hat(V) ket(psi_(p alpha)^((+))), quad T_(alpha' alpha)(p', p) = V_(alpha' alpha)(p', p) - sum_(alpha'') integral_0^Lambda (q^2 dif q) / (2 pi^2) V_(alpha' alpha'')(p', q) G_(alpha'')(k, q) T_(alpha'' alpha)(q, p)
  $
  - $ket(psi^((+))_(p alpha))$: the outgoing scattering state; $E = k^2 \/ (2 mu)$ above the $B macron(B)^*$ threshold
  - $G_1 (k,q) = G_2 (k,q) = (2 mu)/(q^2-k^2-i epsilon)$, #h(0.2em) $G_3 (k,q) = [q^2/m_(B^*) + Delta m - k^2/(2mu) - i epsilon]^(-1)$
  #v(0.3em)
  Three interactions: compact exchange and contact act only in channel 1 and are separable; OME is not:
  #keybox[$
    V_(alpha' alpha)(p',p) = V^"(OME)"_(alpha' alpha)(p',p) + delta_(alpha' 1) delta_(alpha 1) V_S^((macron(b) b) + "CT")(p',p)
  $]
]

#slide[Task 5, Step 2: The separable part and its solution][
  Use the paper's separable-space index $i=1,dots,N+1$ and matrix orientation (Appendix F):
  $
    hat(f) = sum_(i=1)^(N+1) ket(i) bra(f_i), quad braket(f_i, p\, alpha) = f_(i,alpha)(p) = delta_(alpha 1) f_i (p), quad f_i (p) = cases(1/sqrt(4 pi) psi_i (p) quad & i=1\,dots\,N, 1 quad & i=N+1)
  $
  $hat(f)$ maps the meson-pair space to $CC^(N+1)$; $psi_n (p)=4 pi integral r^2 dif r thin j_0 (p r)R_(1 n)(r)$. For real momentum-space vertices:
  $
    hat(V)_S^((macron(b) b)+"CT") = hat(f)^T hat(v) hat(f), quad hat(v)="diag"(v_1,dots,v_(N+1)), quad v_n=g^2/(E-E_n), quad v_(N+1)=C, quad E_n=E_n^((0))+V_0
  $
  Without OME, insert $hat(T)_0=hat(f)^T hat(tau)_0 hat(f)$ into the LSE:
  $
    hat(f)^T hat(tau)_0 hat(f) = hat(f)^T hat(v) hat(f) - hat(f)^T hat(v) hat(f) hat(G) hat(f)^T hat(tau)_0 hat(f) \
    arrow.r.double quad hat(tau)_0=hat(v)-hat(v) hat(J)_0 hat(tau)_0, quad hat(J)_0=hat(f) hat(G) hat(f)^T
  $
  #keybox[$ hat(T)_0=hat(f)^T hat(tau)_0 hat(f), quad hat(tau)_0=(hat(v)^(-1)+hat(J)_0)^(-1) $]
]

#slide[Task 5, Step 3: Adding OME][
  Suppress the fixed incoming labels in $ket(psi) equiv ket(psi^((+))_(p alpha))$; the plane-wave state is $ket(p\,alpha)$:
  $
    ket(psi)=ket(p\,alpha)-hat(G)[hat(V)^"(OME)"+hat(V)_S^((macron(b) b)+"CT")]ket(psi) \
    arrow.r.double quad (1+hat(G)hat(V)^"(OME)")ket(psi)=ket(p\,alpha)-hat(G)hat(V)_S^((macron(b) b)+"CT")ket(psi)
  $
  Define the OME-only scattering state $ket(psi^"(OME)")=(1+hat(G)hat(V)^"(OME)")^(-1)ket(p\,alpha)$ and the auxiliary dressed propagator
  $
    hat(K) equiv (1+hat(G)hat(V)^"(OME)")^(-1)hat(G) = [hat(G)^(-1)+hat(V)^"(OME)"]^(-1) = [H_0+hat(V)^"(OME)"-E]^(-1).
  $
  #keybox[$ ket(psi)=ket(psi^"(OME)")-hat(K)hat(V)_S^((macron(b) b)+"CT")ket(psi) $]
]

#slide[Task 5, Step 4: The auxiliary transition operator][
  The auxiliary transition operator is separable; write it directly with the paper's reduced matrix $hat(tau)$:
  #keybox[$ hat(f)^T hat(tau) hat(f) ket(psi^"(OME)") equiv hat(V)_S^((macron(b) b)+"CT")ket(psi) $]
  Multiply $ket(psi)=ket(psi^"(OME)")-hat(K)hat(V)_S^((macron(b) b)+"CT")ket(psi)$ by $hat(V)_S^((macron(b) b)+"CT")$:
  $
    hat(V)_S^((macron(b) b)+"CT")ket(psi) = hat(V)_S^((macron(b) b)+"CT")ket(psi^"(OME)") - hat(V)_S^((macron(b) b)+"CT")hat(K)hat(V)_S^((macron(b) b)+"CT")ket(psi)
  $
  Thus $hat(f)^T hat(tau)hat(f)=hat(V)_S^((macron(b) b)+"CT")-hat(V)_S^((macron(b) b)+"CT")hat(K)hat(f)^T hat(tau)hat(f)$.
]

#slide(
  refs: [Gell-Mann, Goldberger, Phys. Rev. 91, 398 (1953); Nakano, PRC 26, 1123 (1982)],
)[Task 5, Step 5: The two-potential formula][
  Two forms of the LSE: $ket(psi)=ket(p\,alpha)-hat(G)hat(V)ket(psi)$ and $hat(T)ket(p\,alpha)=hat(V)ket(psi)$,
  $
          hat(T)ket(psi) & = hat(T)ket(p\,alpha)-hat(T)hat(G)hat(V)ket(psi) = hat(V)ket(psi)-hat(T)hat(G)hat(V)ket(psi) \
     hat(T)ket(p\,alpha) & = hat(V)ket(psi)=hat(V)ket(p\,alpha)-hat(V)hat(G)hat(T)ket(p\,alpha) \
                  hat(T) & = hat(V)-hat(T)hat(G)hat(V)=hat(V)-hat(V)hat(G)hat(T) \
    hat(V)^"(OME)"hat(K) & = hat(V)^"(OME)"(1+hat(G)hat(V)^"(OME)")^(-1)hat(G)=hat(T)^"(OME)"hat(G) \
        ket(psi^"(OME)") & = (1-hat(G)hat(T)^"(OME)")ket(p\,alpha)
  $
  Substitute the OME-distorted state and the separable auxiliary transition operator:
  #keybox[$ hat(T)=hat(T)^"(OME)"+(1-hat(T)^"(OME)"hat(G))hat(f)^T hat(tau)hat(f)(1-hat(G)hat(T)^"(OME)") $]
]

#slide[Task 5, Step 6: The reduced matrix $hat(tau)$ and the amplitude][
  The auxiliary LSE has left and right forms. Substituting $hat(V)_S^((macron(b) b)+"CT")=hat(f)^T hat(v)hat(f)$ gives
  $
    hat(f)^T hat(tau)hat(f) = hat(f)^T [hat(v)-hat(v)hat(J)hat(tau)]hat(f), quad hat(J)equiv hat(f)hat(K)hat(f)^T \
    arrow.r.double quad hat(tau)=hat(v)-hat(v)hat(J)hat(tau)=(hat(v)^(-1)+hat(J))^(-1).
  $
  Dressed vertices: $hat(X)^"in"=hat(f)(1-hat(G)hat(T)^"(OME)")$, $(hat(X)^"out")^T=(1-hat(T)^"(OME)"hat(G))hat(f)^T$:
  $
    X^"out"_(i,alpha')(p') &= f_(i,alpha')(p')-sum_alpha integral_0^Lambda (q^2 dif q)/(2 pi^2) T^"(OME)"_(alpha' alpha)(p',q)G_alpha (k,q)f_(i,alpha)(q) \
    X^"in"_(i,alpha)(p) &= f_(i,alpha)(p)-sum_(alpha') integral_0^Lambda (q^2 dif q)/(2 pi^2) f_(i,alpha')(q)G_(alpha')(k,q)T^"(OME)"_(alpha' alpha)(q,p)
  $
  #keybox[$
    T_(alpha' alpha)(p',p)=T^"(OME)"_(alpha' alpha)(p',p)+sum_(i,j=1)^(N+1)X^"out"_(i,alpha')(p')hat(tau)_(i j)X^"in"_(j,alpha)(p)
  $]
]

#slide[Task 5, Step 7: The dressed loop $hat(J)$][
  $hat(K)=(1-hat(G)hat(T)^"(OME)")hat(G)=hat(G)(1-hat(T)^"(OME)"hat(G))=hat(G)-hat(G)hat(T)^"(OME)"hat(G)$, so $hat(J)=hat(f)hat(K)hat(f)^T$:
  $
    J_(i j) &= sum_alpha integral_0^Lambda (q^2 dif q)/(2 pi^2) X^"in"_(i,alpha)(q)G_alpha (k,q)f_(j,alpha)(q) = sum_alpha integral_0^Lambda (q^2 dif q)/(2 pi^2) f_(i,alpha)(q)G_alpha (k,q)X^"out"_(j,alpha)(q) \
    &= integral_0^Lambda (q^2 dif q)/(2 pi^2) f_i (q)G_1 (k,q)f_j (q) \
    &quad -sum_(alpha',alpha) integral_0^Lambda (q'^2 dif q')/(2 pi^2) integral_0^Lambda (q^2 dif q)/(2 pi^2) f_(i,alpha')(q')G_(alpha')(k,q')T^"(OME)"_(alpha' alpha)(q',q)G_alpha (k,q)f_(j,alpha)(q)
  $
  - $T^"(OME)"$, $X^"in,out"$ and $hat(J)$ are independent of $C$ and $V_0$, which enter only through $hat(v)$: a fit only inverts an $(N+1)times(N+1)$ matrix
]

// --------------------------------------------------------------- Task 6: composition of a bound state

#slide(
  refs: [Three-body interpretation assumes the paper's spectral identity, Eq. (F21).],
)[Task 6, Step 1: A third sector for three-body states][
  The TOPT intermediate states $B^((*)) macron(B)^((*)) phi.alt$ are real three-body states, so add a third projector $P_phi.alt$:
  $
    P_Q + P_M + P_phi.alt = bold(1), quad P_Q P_M = P_Q P_phi.alt = P_M P_phi.alt = 0, quad tilde(cal(H)) = mat(H_(Q Q), hat(g)^dagger, 0; hat(g), H_"MM", hat(W)^dagger; 0, hat(W), H_(phi.alt phi.alt)), quad hat(W) equiv P_phi.alt tilde(cal(H)) P_M
  $
  - $H_(phi.alt phi.alt)$ is the free three-body energy, $H_(phi.alt phi.alt) ket(beta\; b) = E_beta (b) ket(beta\; b)$ where $beta$ stands for different intermediate states, and $b$ other labels like momenta and spin
  - $hat(W)$ has matrix elements $W_(beta alpha)(q;b)=mel(beta\; b, tilde(cal(H))_"int", q\,alpha)$; the three-body amplitude is $phi_beta (E;b)=braket(beta\;b, Psi(E))$
  - compact states do not couple to three-body states directly (the zeros)
  - $H_"MM" = H_0$ now, all of OME comes from $P_phi.alt$, and the paper's enlarged Hamiltonian $tilde(cal(H))$ is energy independent
]

#slide[Task 6, Step 2: Eliminating compact and three-body states][
  Multiply $tilde(cal(H)) ket(Psi) = E ket(Psi)$ by each projector:
  $
                      (E - H_(Q Q)) thin P_Q ket(Psi) & = hat(g)^dagger P_M ket(Psi) \
                       (E - H_"MM") thin P_M ket(Psi) & = hat(g) thin P_Q ket(Psi) + hat(W)^dagger P_phi.alt ket(Psi) \
    (E - H_(phi.alt phi.alt)) thin P_phi.alt ket(Psi) & = hat(W) thin P_M ket(Psi)
  $
  First and third: $P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger ket(Psi_M)$, #h(0.2em) $P_phi.alt ket(Psi) = (E - H_(phi.alt phi.alt))^(-1) hat(W) ket(Psi_M)$. Into the second:
  #keybox[$
    [H_"MM" + hat(V)^((macron(b) b))(E) + hat(V)^"(OME)"(E)] ket(Psi_M) = E ket(Psi_M), quad hat(V)^"(OME)"(E) = hat(W)^dagger (E - H_(phi.alt phi.alt))^(-1) hat(W)
  $]
  $
    V^"(OME)"_(alpha' alpha)(p',p;E)=sum_(beta,b) (W^*_(beta alpha')(p';b)W_(beta alpha)(p;b))/(E-E_beta (b)+i epsilon)
  $
]

#slide[Task 6, Step 3: Normalisation with three sectors][
  As for $P_Q$ in Task 1: $partial_E (E - H_(phi.alt phi.alt))^(-1) = -(E - H_(phi.alt phi.alt))^(-2)$. Bound state, $E = -E_B$ real:
  $
    1 = braket(Psi, Psi) & = mel(Psi, P_Q, Psi) + mel(Psi, P_M, Psi) + mel(Psi, P_phi.alt, Psi) \
    & = mel(Psi_M, hat(g) (E - H_(Q Q))^(-2) hat(g)^dagger, Psi_M) + braket(Psi_M, Psi_M) + mel(Psi_M, hat(W)^dagger (E - H_(phi.alt phi.alt))^(-2) hat(W), Psi_M) \
    & = mel(Psi_M, [1 - partial_E hat(V)^((macron(b) b)) - partial_E hat(V)^"(OME)"], Psi_M)
  $
  #keybox[$
    cal(P)_(macron(b) b) = -mel(Psi_M, partial_E hat(V)^((macron(b) b)), Psi_M), quad sum_alpha cal(P)_alpha = braket(Psi_M, Psi_M), quad cal(P)_"3-body" = -mel(Psi_M, partial_E hat(V)^"(OME)", Psi_M)
  $]
  - each one positive, adding up to 1; the contact does not depend on $E$ and drops out
  - $cal(P)_alpha = integral_0^Lambda (q^2 dif q) / (2 pi^2) |Psi_alpha (q)|^2$: the individual two-body channels
]

#slide(spread: false)[Task 6, Step 4: The normalisation from the pole of $hat(tau)$][
  #spaced(0.75)[
    #set text(size: 17pt)
    Simple pole at $E=-E_B$; $T^"(OME)"$ is regular. Set $hat(cal(J))=lim_(E -> -E_B) hat(tau)^(-1)$ (paper, Eq. (F3)).
    $
      hat(tau)^(-1) &= hat(cal(J))+(E+E_B)hat(A)_1+(E+E_B)^2hat(A)_2+dots, quad hat(A)_n=1/n![partial_E^n hat(tau)^(-1)]_(E=-E_B) \
      hat(tau) &= (bold(c)bold(c)^T)/(E+E_B)+hat(tau)_R+(E+E_B)hat(tau)_(R,1)+dots
    $
    $hat(tau)^(-1)hat(tau)=bold(1)$, order by order in $E+E_B$:
    $
      (E+E_B)^(-1): & quad hat(cal(J))bold(c)bold(c)^T=0 arrow.r.double hat(cal(J))bold(c)=0: quad det(hat(v)^(-1)+hat(J))=0 \
         (E+E_B)^0: & quad hat(cal(J))hat(tau)_R+hat(A)_1 bold(c)bold(c)^T=bold(1) \
         (E+E_B)^1: & quad hat(cal(J))hat(tau)_(R,1)+hat(A)_1 hat(tau)_R+hat(A)_2 bold(c)bold(c)^T=0
    $
    - Higher coefficients start at order $E+E_B$; they cannot change the residue
    - Symmetry gives $bold(c)^T hat(cal(J))=0$; left-multiply the constant-order equation by $bold(c)^T$:
    #keybox[$ bold(c)^T [partial_E (hat(v)^(-1)+hat(J))]_(E=-E_B)bold(c)=1 $]
  ]
]

#slide[Task 6, Step 5: Wave function and $cal(P)_(macron(b) b)$ from the residue][
  Near the pole $hat(T) tilde.eq ((hat(X)^"out")^T bold(c))(bold(c)^T hat(X)^"in")/(E+E_B)$; the meson-pair resolvent $P_M (E-tilde(cal(H))+i epsilon)^(-1) P_M=-hat(G)+hat(G)hat(T)hat(G)$ has residue $ket(Psi_M)bra(Psi_M)$:
  #keybox[$
    ket(Psi_M)=-hat(G)(hat(X)^"out")^T bold(c)=-hat(K)hat(f)^T bold(c), quad Psi_alpha (p)=-G_alpha (i kappa_B,p)sum_(i=1)^(N+1)X^"out"_(i,alpha)(p)c_i
  $]
  At the pole $k=i kappa_B$, $kappa_B=sqrt(2mu E_B)$: $hat(f)ket(Psi_M)=-hat(J)bold(c)=hat(v)^(-1)bold(c)$, i.e. $braket(f_n, Psi_M)=(E-E_n)c_n/g^2$. The compact equation gives $lambda_n=g braket(f_n, Psi_M)/(E-E_n)=c_n/g$, and $partial_E C^(-1)=0$:
  #keybox[$
    lambda_n = c_n / g, quad bold(c)^T (partial_E hat(v)^(-1)) thin bold(c) = sum_(n = 1)^N c_n^2 / g^2 = sum_n lambda_n^2 = cal(P)_(macron(b) b)
  $]
  the compact probability of Task 1, read off from the residue
]

#slide[Task 6, Step 6: The derivative of $hat(J)$][
  $hat(K)^(-1)=hat(G)^(-1)+hat(V)^"(OME)"(E)=H_0-E+hat(V)^"(OME)"(E)$, so
  $
    partial_E hat(K)=hat(K)(1-partial_E hat(V)^"(OME)")hat(K), quad partial_E hat(J)=hat(f)hat(K)(1-partial_E hat(V)^"(OME)")hat(K)hat(f)^T
  $
  With $hat(K)hat(f)^T bold(c)=-ket(Psi_M)$:
  $
    bold(c)^T(partial_E hat(J))bold(c)=braket(Psi_M, Psi_M)-mel(Psi_M, partial_E hat(V)^"(OME)", Psi_M)=sum_alpha cal(P)_alpha+cal(P)_"3-body"
  $
  Add the two pieces of $bold(c)^T partial_E (hat(v)^(-1)+hat(J))bold(c)=1$:
  #keybox[$
    1 = cal(P)_(macron(b) b) + cal(P)_S + cal(P)_D + cal(P)_"3-body", quad cal(P)_S = cal(P)_1, quad cal(P)_D = cal(P)_2 + cal(P)_3
  $]
]

#slide[Task 6, Step 7: $cal(P)_"3-body"$ and $S$-wave compositeness][
  $partial_E$ acts only on the TOPT denominators: $partial_E mu_beta = -1$, so #box($partial_E D_beta = 1 \/ (2 E_phi.alt (q) [E_phi.alt (q) + mu_beta]^2)$):
  #keybox[$
    cal(P)_"3-body" = -sum_(alpha', alpha) integral_0^Lambda (p'^2 dif p') / (2 pi^2) integral_0^Lambda (p^2 dif p) / (2 pi^2) thin Psi^*_(alpha')(p') thin partial_E V^"(OME)"_(alpha' alpha)(p', p; E) thin Psi_alpha (p) |_(E = -E_B)
  $]
  - the two-body parts: $cal(P)_alpha=integral_0^Lambda (q^2 dif q)/(2 pi^2)|Psi_alpha (q)|^2$ with $Psi_alpha (p)=-G_alpha (i kappa_B,p)sum_(i=1)^(N+1)X^"out"_(i,alpha)(p)c_i$
  - everything comes from the residue vector $bold(c)$ and the OME solution: nothing beyond the scattering calculation is needed
  The $S$-wave compositeness takes both parts from the $S$-wave component $Psi_1$ of the _full_ coupled-channel solution, so the $S$–$D$–$S$ iterations are inside $Psi_1$:
  #keybox[$
    X_S = cal(P)_S + cal(P)_("3-body", S), quad cal(P)_("3-body", S) = -mel(Psi_1, partial_E V^"(OME)"_11, Psi_1)
  $]
]

// --------------------------------------------------------------- backup

#slide(
  backup: true,
  refs: [Wise 1992; Burdman, Donoghue 1992; Yan _et al._ 1992; $g_b$: Flynn _et al._, PRD 93, 014510 (2016)],
)[Backup: The LO chiral Lagrangian][
  #speaker-note[One-meson exchange is given by leading-order heavy-meson ChPT. Here $H$ annihilates the $b macron(q)$ mesons and $macron(H)$ the $macron(b) q$ mesons, where $P$ stands for the pseudoscalar and $V$ for the vector mesons. Charge conjugation is defined such that the $C$-even $B macron(B)^*$ state is the difference of the two states. We take this Lagrangian as given; two numbers enter, $g_b$ from the lattice and $F_pi$. After the spin traces there are two vertices, $B^* B phi.alt$ and $B^* B^* phi.alt$, and no $B B phi.alt$ vertex.]
  #set text(size: 17pt)
  LO heavy-meson ChPT, taken as given ($a = 1, 2$ light flavour; Tr over spin):
  $
    cal(L)_Phi = -g_b / 4 op("Tr")(H_a^dagger H_b thin bold(sigma) dot bold(u)_(b a)) + g_b / 4 op("Tr")(bold(sigma) dot bold(u)_(a b) thin macron(H)_b macron(H)_a^dagger)
  $
  - $H_a = P_a + bold(V)_a dot bold(sigma)$: $b macron(q)$ mesons $B^-, macron(B)^0$ and $B^(* -), macron(B)^(* 0)$; #h(0.2em) $macron(H)_a$: $macron(b) q$ mesons $B^+, B^0$ and $B^(* +), B^(* 0)$
  - $bold(u) = -nabla Phi \/ F_pi + cal(O)(Phi^3)$, #h(0.2em) $Phi = pi_a tau_a + eta \/ sqrt(3) thin bold(1)$; #h(0.2em) $F_pi = 92.2$ MeV, #box($g_b = 0.56(3)_"stat" (7)_"sys"$) (lattice QCD)
  - $cal(C) P_a cal(C)^(-1) = macron(P)_a$, $cal(C) V_a^i cal(C)^(-1) = -macron(V)_a^i$ #h(0.3em) $arrow.r.double$ #h(0.3em) $ket(B macron(B)^*\; C = +) = (ket(B macron(B)^*) - ket(B^* macron(B))) \/ sqrt(2)$
  With the spin traces done:
  #expanded-lagrangian
]

#slide(backup: true)[Backup: TOPT from the Feynman propagator][
  #speaker-note[To get a potential, start from the Feynman propagator of the light meson. It has two poles, and written through the energies of the heavy mesons each one is the total energy minus the energy of three particles: the two heavy mesons and the light one. That is second-order perturbation theory with a three-body intermediate state; this is what time-ordered perturbation theory means here. The two terms are the two time orderings: either the upper or the lower meson emits first.]
  #align(center, feynman-ome)
  #caption[on shell: $q_0 = E_1 - E'_1 = E'_2 - E_2$, #h(0.3em) $M = E_1 + E_2 = E'_1 + E'_2$; #h(0.6em) $E_phi.alt = sqrt(bold(q)^2 + m_phi.alt^2)$]
  #keybox[$
    1 / (q_0^2 - E_phi.alt^2 + i epsilon) & = 1 / (2 E_phi.alt) [1 / (q_0 - E_phi.alt + i epsilon) + 1 / (-q_0 - E_phi.alt + i epsilon)] \
    & = 1 / (2 E_phi.alt) [1 / (M - (E'_1 + E_2 + E_phi.alt) + i epsilon) + 1 / (M - (E_1 + E'_2 + E_phi.alt) + i epsilon)]
  $]
]

#slide(backup: true)[Backup: The four classes of intermediate states][
  #speaker-note[Here are the time orderings as diagrams; the thin vertical line cuts the intermediate state. Which heavy mesons sit there depends on who emits first: for $B macron(B)^*$ to $B^* macron(B)$ in the top row it is $B macron(B)$ or $B^* macron(B)^*$, classes 1 and 2. The bottom row, with a $B^* macron(B)^*$ pair on one side, gives classes 3 and 4. Class 1 is the lightest of these states: of the two orderings in the top row it has the smaller denominator and gives the larger contribution.]
  #grid(
    columns: (auto, 1fr),
    column-gutter: 1.5em,
    align: (center + horizon, left + horizon),
    topt-figure,
    [
      - time runs to the right; single line $B$, double line $B^*$, dashed $phi.alt$; the thin line cuts the intermediate state
      - top: the two orderings of $B macron(B)^* -> B^* macron(B)$, through $B macron(B) phi.alt$ (1) and $B^* macron(B)^* phi.alt$ (2)
      - bottom: one ordering each of $B macron(B)^* -> B^* macron(B)^*$ and $B^* macron(B)^* -> B macron(B)^*$; the other one is class (2)
      - (3) and (4) contain the same particles; the $B$ carries $bold(p)$ in (3) and $bold(p)'$ in (4)
    ],
  )
]

#slide(backup: true)[Backup: Energy denominators][
  #speaker-note[Each ordering gives the energy of that three-body state minus the total energy. Three things sit in $mu_beta$: the $B^*$–$B$ mass difference, the kinetic energies of the heavy mesons, and the energy $E$. So this potential depends on $p$ and $p'$ separately, and on the energy.]
  Each time ordering, with heavy mesons $h_1, h_2$ in the intermediate state:
  #keybox[$
    1 / (2 E_phi.alt) dot 1 / (M - E_(h_1) - E_(h_2) - E_phi.alt + i epsilon) = -1 / (2 E_phi.alt (q) [E_phi.alt (q) + mu_beta]) equiv -D_beta, quad mu_beta = E_(h_1) + E_(h_2) - M - i epsilon
  $]
  With $M = m_B + m_(B^*) + E$, $Delta m = m_(B^*) - m_B$; $E_h (p) = m_h + p^2/(2m_h)$ for $h = B, B^*$:
  $
    mu_1 & = -Delta m + (p^2 + p'^2) \/ (2 m_B) - E - i epsilon, & quad mu_2 & = Delta m + (p^2 + p'^2) \/ (2 m_(B^*)) - E - i epsilon, \
    mu_3 & = p^2 \/ (2 m_B) + p'^2 \/ (2 m_(B^*)) - E - i epsilon, & quad mu_4 & = p'^2 \/ (2 m_B) + p^2 \/ (2 m_(B^*)) - E - i epsilon
  $
  - the argument distinguishes the paper's meson energy $E_B (p)$ from the binding energy $E_B$
]

#slide(backup: true)[Backup: The four OME kernels][
  #speaker-note[Each time ordering is vertex times vertex times its denominator. In the first line the numerator is the two $P$-wave vertices, which carry the tensor force, and the bracket holds the two time orderings in the top row of the four classes. The other three lines involve the $B^* macron(B)^*$ pair and have the same structure.]
  Each time ordering is (vertex) $times$ (vertex) $times (-D_beta)$; summing the orderings, without the flavour factor:
  #keybox[$
    V_(B macron(B)^* -> B macron(B)^*) & = -g_b^2 / (4 F_pi^2) (bold(epsilon) dot bold(q))(bold(epsilon)'^* dot bold(q)) thin [D_1 + D_2] \
    V_(B macron(B)^* -> B^* macron(B)^*) & = g_b^2 / (4 F_pi^2) [(bold(A)_1 dot bold(q))(bold(epsilon)'^*_2 dot bold(q)) + (bold(A)_2 dot bold(q))(bold(epsilon)'^*_1 dot bold(q))] thin [D_3 + D_2] \
    V_(B^* macron(B)^* -> B macron(B)^*) & = g_b^2 / (4 F_pi^2) [(bold(A)_1 dot bold(q))(bold(epsilon)_2 dot bold(q)) + (bold(A)_2 dot bold(q))(bold(epsilon)_1 dot bold(q))] thin [D_4 + D_2] \
    V_(B^* macron(B)^* -> B^* macron(B)^*) & = -g_b^2 / (2 F_pi^2) (bold(A)_1 dot bold(q))(bold(A)_2 dot bold(q)) thin [2 D_2]
  $]
  - 1 and 2 label the $B^*$ and the $macron(B)^*$ of the $B^* macron(B)^*$ pair, $bold(A)_a = i / sqrt(2) bold(epsilon)_a times bold(epsilon)'^*_a$
]

#slide(spread: false, backup: true)[Backup: Partial-wave projection][
  #spaced(0.75)[
    #set text(size: 17pt)
    #speaker-note[The potential is defined on plane-wave in and out states; to get the potential in a partial-wave channel, we need to project onto the partial-wave basis.]
    The kernels are defined on momentum eigenstates, $V_(sigma' sigma)(bold(p)', bold(p)) = mel(bold(p)'\, sigma', hat(V), bold(p)\, sigma)$, with $sigma = (m_1, m_2)$ the spins of the meson pair.
    Project with $Y_(L m)(hat(bold(p))) = braket(hat(bold(p)), L m)$ and the spin–angular wave function of channel $alpha = (L, S)$:
    $
      cal(Y)^J_(L_alpha S_alpha)(hat(bold(p)), sigma) = 1 / sqrt(4 pi) sum_(m, mu) braket(L_alpha m\, S_alpha mu, J M) Y_(L_alpha m)(hat(bold(p))) braket(sigma, S_alpha mu) \
      ket(p\; alpha J M) = integral dif Omega sum_sigma cal(Y)^J_(L_alpha S_alpha)(hat(bold(p)), sigma) ket(bold(p)\, sigma)
    $
    $
      V^J_(alpha' alpha)(p', p) = 1 / (2J + 1) sum_M mel(p'\; alpha' J M, hat(V), p\; alpha J M) = 1 / (2J + 1) sum_M integral dif Omega' dif Omega sum_(sigma' sigma) cal(Y)^(J*)_(L_(alpha') S_(alpha')) V_(sigma' sigma) cal(Y)^J_(L_alpha S_alpha)
    $
    $P_i (alpha; hat(bold(n))) = 4 pi sum_M e^((M))_i cal(Y)^1_(L_alpha S_alpha)(hat(bold(n)))$, #h(0.2em) $sum_i e^((M)*)_i e^((M'))_i = delta_(M M')$, so $op("Tr")[P^dagger V P] = (4 pi)^2 sum_M cal(Y)^* V cal(Y)$:
    #keybox[$
      V^"(OME)"_(alpha' alpha)(p', p; m_phi.alt) = 1 / (2J + 1) integral (dif Omega_(bold(n)')) / (4 pi) (dif Omega_(bold(n))) / (4 pi) op("Tr")[P^dagger (alpha'; hat(bold(n))') thin V^"(OME)"(p' hat(bold(n))', p hat(bold(n)); m_phi.alt) thin P(alpha; hat(bold(n)))] = V^J_(alpha' alpha)
    $]
    - $integral dif Omega sum_sigma |cal(Y)^J_(L_alpha S_alpha)|^2 = 1/(4 pi)$ and $braket(p'\, alpha', p\, alpha) = delta_(alpha' alpha) (2 pi^2) \/ p^2 thin delta(p' - p)$: the paper's convention throughout
  ]
]

#slide(backup: true)[Backup: The OME potential in partial waves][
  #speaker-note[These are the kernels between partial waves, projected as on the previous slide. $V_(11)$ is $S$ wave to $S$ wave; $V_(12)$ and $V_(13)$ take the $S$ wave into the two $D$ waves and exist only because of the tensor force. All of them are angular moments of the same denominators, so all of them depend on the energy.]
  With $x = hat(bold(n)) dot hat(bold(n))'$ and the angular moments $Delta^((beta_1 beta_2))_m (p', p; m_phi.alt) = integral_(-1)^1 dif x thin x^m [D_(beta_1) + D_(beta_2)]$:
  #text(size: 17pt)[$
    V_11 & = g_b^2 \/ (24 F_pi^2) thin [2 p p' Delta_1^((12)) - (p^2 + p'^2) Delta_0^((12))] \
    V_12 & = g_b^2 \/ (24 sqrt(2) F_pi^2) thin [3 p'^2 Delta_2^((12)) - 4 p p' Delta_1^((12)) + (2 p^2 - p'^2) Delta_0^((12))] \
    V_13 & = -g_b^2 \/ (8 sqrt(6) F_pi^2) thin [3 p'^2 Delta_2^((24)) - 4 p p' Delta_1^((24)) + (2 p^2 - p'^2) Delta_0^((24))] \
    V_22 & = g_b^2 \/ (24 F_pi^2) thin [(9 \/ 2) p p' Delta_3^((12)) - 3 (p^2 + p'^2) Delta_2^((12)) - (1 \/ 2) p p' Delta_1^((12)) + (p^2 + p'^2) Delta_0^((12))] \
    V_23 & = g_b^2 \/ (16 sqrt(3) F_pi^2) thin [3 p p' Delta_3^((24)) - 3 (p^2 + p'^2) Delta_2^((24)) + p p' Delta_1^((24)) + (p^2 + p'^2) Delta_0^((24))] \
    V_33 & = -g_b^2 \/ (16 F_pi^2) thin p p' [Delta_1^((22)) - Delta_3^((22))]
  $]
  - $V_(alpha' alpha) equiv V^"(OME)"_(alpha' alpha)(p', p; m_phi.alt)$, with $V_(j i)(p', p) = V_(i j)(p, p')$
  - projected onto the channels with the paper's projectors $P(alpha; hat(bold(n)))$: previous slide
]

#slide(backup: true)[Backup: Isospin factors][
  #speaker-note[The exchange carries the product of the isospin generators of the two mesons. In the isoscalar channel that is 3 for the pion and one third for the eta.]
  The flavour factor of pion exchange is the product of the isospin generators of the two mesons: the meson ($b macron(q)$) carries the anti-doublet, $bold(I)_1 = -bold(tau)^T \/ 2$, the antimeson ($macron(b) q$) the doublet, $bold(I)_2 = bold(tau) \/ 2$:
  $
    sum_a tau_a^T times.o tau_a = -4 thin bold(I)_1 dot bold(I)_2 = -2 [I(I + 1) - 3 / 4 - 3 / 4] = cases(3 quad & I = 0, -1 quad & I = 1)
  $
  - $eta$ is an isosinglet: $(1 \/ sqrt(3))^2 = 1 \/ 3$ in every channel
  #v(0.4em)
  #keybox[$
    V^"(OME)"_(alpha' alpha)(p', p) = 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_pi) + 1 / 3 thin V^"(OME)"_(alpha' alpha)(p', p; m_eta) quad (I = 0)
  $]
]
