#import "../style.typ": *

#slide(refs: [Bulava _et al._ 2019, 2024])[The lattice coupling and the heavy-quark spin][
  - schematically $sqrt(2) g_l = mel(W, H_"mix", B macron(B))$; the $sqrt(2)$: isoscalar $ket(B macron(B)) = (ket(B_u macron(B)_u) + ket(B_d macron(B)_d)) \/ sqrt(2)$
  - $ket(W)$ inherits its quantum numbers from the interpolating operator
  $ cal(O)_W (y, x, t) = macron(Q)(y, t) (bold(gamma) dot arrow(r)) / r W(y, x, t) Q(x, t) $
  - $bold(gamma) dot arrow(r) \/ r$ gives $ket(1\, 0)$ for the heavy spin (projection 0 on the axis); heavy-quark spin is conserved (HQSS)
  #keybox[$ sqrt(2) g_l = -1 / 2 mel(W, H, 1_H\, 0\; 1_l\, 0) $]
  - to show this: $B macron(B)$ is coupled as $ket([(s_b j_(l 1))_0 (s_macron(b) j_(l 2))_0]_0)$; recouple it into $ket([(s_b s_macron(b))_(s_H) (j_(l 1) j_(l 2))_(j_l)]_0)$
]

#slide[Recoupling $B macron(B)$: the $9j$ symbol][
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

#slide[Projections on the axis: the factor 2][
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

#slide[Which pair states can mix with the string?][
  Light states of $ket(B macron(B))$ and of the string, labelled with the BO rules: #h(0.3em) $eta = C P$ of the light degrees of freedom; $sigma = P (-1)^(j_l)$ for $lambda_l = 0$.
  #v(0.3em)
  #align(center, text(size: 16pt, table(
    columns: 7,
    align: (left, center, center, center, center, center, left),
    toprule,
    [light configuration], [$j_l^(P C)$], [$lambda_l$], [$eta$], [$sigma$], [label], [role],
    midrule,
    [vacuum (string)], [$0^(+ +)$], [0], [$g$], [$+$], [$Sigma_g^+$], [compact $macron(b) b$, Cornell potential],
    [$S$-wave pair, light triplet], [$1^(- -)$], [0], [$g$], [$+$], [$Sigma_g^(+')$], [mixes with the string],
    [$S$-wave pair, light triplet], [$1^(- -)$], [$plus.minus 1$], [$g$], [–], [$Pi_g$], [no direct mixing],
    [$S$-wave pair, light singlet], [$0^(- +)$], [0], [$u$], [$-$], [$Sigma_u^-$], [no direct mixing; cannot give $1^(+ +)$],
    bottomrule,
  )))
  #v(0.3em)
  - in $ket(B macron(B))$: $ket(1_l\, 0) in Sigma_g^(+')$, #h(0.2em) $ket(1_l\, plus.minus 1) in Pi_g$, #h(0.2em) $ket(0_l\, 0) in Sigma_u^-$; the labels are conserved for static quarks, so only the $ket(1_l\, 0)$ piece mixes with the string
  - $Sigma_g^+$ and $Sigma_g^(+')$ share all labels, so their levels cannot cross $arrow.r$ avoided crossing = string breaking
]
