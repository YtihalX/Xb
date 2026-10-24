#import "../style.typ": *

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
    $ H(r) = mat(V(r), sqrt(2) g_l, g_s; sqrt(2) g_l, hat(E)_1, 0; g_s, 0, hat(E)_2) \ V(r) = hat(V)_0 + sigma r + gamma / r $,
  )
  #v(0.2em)
  #align(center, text(size: 16pt, table(
    columns: 8,
    align: (left,) + (center,) * 7,
    toprule,
    [], [$hat(E)_1$], [$hat(E)_2$], [$g_l$], [$g_s$], [$sigma$], [$hat(V)_0$], [$gamma$],
    midrule,
    [units of $t_0$], [0.0034(3)], [0.1005(7)], [0.0256(3)], [0.0134(4)], [0.1061(7)], [$-0.835(7)$], [$-0.434(11)$],
    [physical], [5 MeV], [137 MeV], [*35 MeV*], [18 MeV], [*0.198 GeV#super[2]*], [$-1.14$ GeV], [$bold(-0.434)$],
    bottomrule,
  )))
  - $sqrt(t_0) = 0.1443(7)(13)$ fm; bold: used here ($sigma$, $gamma$: Cornell tower; $g_l$: coupling)
  - not used: $hat(E)_1$ (one-meson exchange + contact term instead), $hat(E)_2$ and $g_s$ (no $B_s macron(B)_s^*$), $hat(V)_0$ ($V_0$ fitted)
]

#slide(refs: [plot: the lattice model with the parameters of the previous slide; crossing: Bulava _et al._ 2024, Eq. (11)])[What the lattice measures][
  #grid(
    columns: (1.45fr, 1fr),
    column-gutter: 1em,
    align: horizon,
    image("../figs/lattice_levels.pdf", width: 100%),
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
