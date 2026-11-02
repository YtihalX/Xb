// Look of the slides, matching the LaTeX notes: New Computer Modern, black on
// white, one accent (the notes' keybox blue), small gray source references.

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

/// One slide: bold title over a thin gray rule, then the body. `refs` is set
/// in small gray type at the bottom right.
#let slide(title, refs: none, body) = {
  pagebreak(weak: true)
  block(below: 0.4em, text(size: 1.3em, weight: "bold", title))
  line(length: 100%, stroke: 0.6pt + rule-gray)
  v(0.15em)
  body
  if refs != none {
    place(bottom + right, text(size: 11pt, fill: gray-text, refs))
  }
}

#let title-slide(title, author, affiliation) = align(center + horizon, {
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
  if x-label != none { content((w / 2, -0.12 - 1.5 * tick-size / 1cm), text(size: label-size, x-label), anchor: "north") }
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
