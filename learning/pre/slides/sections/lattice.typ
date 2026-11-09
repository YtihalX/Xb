#import "../style.typ": *
#import "@preview/cetz:0.4.2"

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
    size: (13.2, 8.4),
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

#slide(refs: [Bulava _et al._ 2024, Eq. (6) and Table 4])[What the lattice sees: string breaking][
  #grid(
    columns: (1fr, auto),
    column-gutter: 2em,
    align: horizon,
    [
      The system is non-perturbative: the input comes from lattice QCD. Static $b$ and $macron(b)$ at distance $r$, two kinds of levels:
      - the colour string: energy rises roughly linearly with $r$
      - a pair of static–light mesons: energy nearly flat
      Bulava _et al._ (2024) fit the three lowest levels in the basis ${macron(b) b "string", B macron(B), B_s macron(B)_s}$ with
    ],
    $
      H(r) = mat(V(r), sqrt(2) g_l, g_s; sqrt(2) g_l, hat(E)_1, 0; g_s, 0, hat(E)_2) \ V(r) = hat(V)_0 + sigma r + gamma / r
    $,
  )
  #v(0.2em)
  #align(center, text(size: 16pt, table(
    columns: 8,
    align: (left,) + (center,) * 7,
    toprule, [], [$hat(E)_1$], [$hat(E)_2$], [$g_l$], [$g_s$], [$sigma$], [$hat(V)_0$],
    [$gamma$], midrule, [units of $t_0$], [0.0034(3)], [0.1005(7)], [0.0256(3)], [0.0134(4)], [0.1061(7)],
    [$-0.835(7)$], [$-0.434(11)$], [physical], [5 MeV], [137 MeV], [*35 MeV*], [18 MeV], [*0.198 GeV#super[2]*],
    [$-1.14$ GeV], [$bold(-0.434)$], bottomrule,
  )))
  - $sqrt(t_0) = 0.1443(7)(13)$ fm;
]

#slide(
  refs: [plot: the lattice model with the parameters of the previous slide; crossing: Bulava _et al._ 2024, Eq. (11)],
)[What the lattice measures][
  #grid(
    columns: (1.45fr, 1fr),
    column-gutter: 1em,
    align: horizon,
    lattice-levels-plot(),
    [
      - measured: the energy levels, i.e. the eigenvalues (solid; drawn here from the fitted model)
      - the fit explains them with diabatic entries (dashed): two flat meson-pair levels ($B macron(B)$, $B_s macron(B)_s$) and a string energy rising with $r$
      - string–$B macron(B)$ crossing at $r_l^star = 1.21$ fm
      - for our potential we need $V(r)$ and $sqrt(2) g_l$
    ],
  )
]

#slide[The basis problem][
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
