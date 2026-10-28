// Look of the slides, matching the LaTeX notes: New Computer Modern, black on
// white, one accent (the notes' keybox blue), small gray source references.

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

// Dirac notation and spectroscopic labels; call them inside math.
#let ket(x) = $lr(|#x chevron.r)$
#let bra(x) = $lr(chevron.l #x|)$
#let braket(a, b) = $lr(chevron.l #a mid(|) #b chevron.r)$
#let mel(a, o, b) = $lr(chevron.l #a mid(|) #o mid(|) #b chevron.r)$
#let pw(s, l, j) = $attach(#l, tl: #s, br: #j)$
#let um = math.class("unary", sym.minus) // minus sign inside CG labels
