// Shared style and math helpers for documents created by `just new file.typ`.
// Build with `just typst file.typ` so imports can reach the repository root.
#let note(body, title: "", author: "", date: none) = {
  set document(title: title, author: author, date: date)
  set page(paper: "a4", margin: 25mm, numbering: "1")
  set text(font: "New Computer Modern", size: 11pt, lang: "en")
  set par(justify: true)
  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")

  if title != "" {
    align(center)[
      #text(size: 17pt, weight: "bold", title)
      #if author != "" {
        parbreak()
        author
      }
      #if date != none {
        parbreak()
        date.display("[year]-[month]-[day]")
      }
    ]
    v(1em)
  }
  body
}

// Dirac notation with automatically sized outer and middle delimiters.
// In math: bra(psi), ket(psi), braket(phi, psi), mel(phi, A, psi), avg(A).
#let bra(body) = $lr(chevron.l #body |)$
#let ket(body) = $lr(| #body chevron.r)$
#let braket(left, right) = $lr(chevron.l #left mid(|) #right chevron.r)$
#let mel(left, operator, right) = $lr(chevron.l #left mid(|) #operator mid(|) #right chevron.r)$
#let avg(body) = $lr(chevron.l #body chevron.r)$

// First derivatives; use Typst's native dif, abs, norm, bold, vec and mat otherwise.
// In math: dv(f, x), pdv(f, x).
#let dv(body, variable) = $(dif #body) / (dif #variable)$
#let pdv(body, variable) = $(partial #body) / (partial #variable)$

// Upright units, with a thin space between the value and unit.
// In math: qty(10, GeV), qty(5, MeV), qty(2, "fm").
#let qty(value, unit) = $#value thin #unit$
#let GeV = $"GeV"$
#let MeV = $"MeV"$
