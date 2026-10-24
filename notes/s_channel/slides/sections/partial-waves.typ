#import "../style.typ": *

#slide[From $Sigma_g^(+')$ to the $pw(3, S, 1)$ channel][
  This is still not what we want: we need $mel(B macron(B)^* (pw(3, S, 1)), H, W)$.
  - insert the completeness relation of the BO basis, $sum ket("BO") bra("BO")$ over ${Sigma_g^(+'), Pi_g\; 1, Pi_g\; 2}$
  - the string $W$ is $Sigma_g^+$ and the mixing conserves the BO quantum numbers, so only $Sigma_g^(+')$ survives (BO selection rule):
  $ mel(B macron(B)^* (pw(3, S, 1)), H, W) = braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) mel(Sigma_g^(+'), H, W) $
  #v(0.3em)
  #keybox[to show: #h(0.4em) $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 / sqrt(3)$ #h(1em) (its square, $1 \/ 3$, is the $S$-wave probability)]
]

#slide[Quantum numbers of the $1^(+ +)$ pairs][
  $ arrow(J) = arrow(s)_H + arrow(j)_l + arrow(L), quad J^(P C) = 1^(+ +), quad P = (-1)^L, quad C = (-1)^(s_H + j_l + L) $
  - $P = +$ makes $L$ even
  - then $C = +$ makes $s_H + j_l$ even: $(s_H, j_l) = (0, 0)$ or $(1, 1)$
  - with $(0, 0)$ we would get $J = L$, which is even and never 1 #h(0.3em) $arrow.r.double$ #h(0.3em) $s_H = j_l = 1$
  $ s_H times.o j_l = 1 times.o 1 = 0 plus.o 1 plus.o 2 $
  combined with $L = 0, 2$ to $J = 1$, this gives the $1^(+ +)$ meson pairs
  $ B macron(B)^* (pw(3, S, 1)), quad B macron(B)^* (pw(3, D, 1)), quad B^* macron(B)^* (pw(5, D, 1)) $
]

#slide[Why exactly three channels][
  $P = P_1 P_2 (-1)^L = (-1)^L$; #h(0.3em) $C = (-1)^(L + S)$ for $B macron(B)$ and $B^* macron(B)^*$; #h(0.3em) $B macron(B)^*$: $C = plus.minus (-1)^L$ for $(ket(B macron(B)^*) minus.plus ket(B^* macron(B))) \/ sqrt(2)$
  #v(0.2em)
  #align(center, text(size: 15.5pt, table(
    columns: 5,
    align: (left, center, center, left, left),
    inset: (x: 0.5em, y: 0.22em),
    toprule,
    [pair], [$S$], [$L$], [allowed $J^(P C)$], [$1^(+ +)$?],
    midrule,
    [$B macron(B)$], [0], [$L$], [$J = L$: $0^(+ +), 1^(- -), 2^(+ +), dots$], [no],
    [$B macron(B)^*$, $C$-even], [1], [0], [$1^(+ +)$], [*yes:* $pw(3, S, 1)$],
    [$B macron(B)^*$, $C$-even], [1], [2], [$1^(+ +), 2^(+ +), 3^(+ +)$], [*yes:* $pw(3, D, 1)$],
    [$B macron(B)^*$, $C$-odd], [1], [0, 2], [$1^(+ -), dots$], [no],
    [$B^* macron(B)^*$], [0], [0], [$0^(+ +)$], [no],
    [$B^* macron(B)^*$], [1], [0], [$1^(+ -)$], [no],
    [$B^* macron(B)^*$], [2], [0], [$2^(+ +)$], [no],
    [$B^* macron(B)^*$], [0], [2], [$2^(+ +)$], [no],
    [$B^* macron(B)^*$], [1], [2], [$1^(+ -), 2^(+ -), 3^(+ -)$], [no],
    [$B^* macron(B)^*$], [2], [2], [$0^(+ +), dots, 4^(+ +)$], [*yes:* $pw(5, D, 1)$],
    [any], [$<= 2$], [$>= 4$], [$J >= L - S >= 2$], [no],
    bottomrule,
  )))
]

#slide[The BO coupling order][
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
      columns: 3,
      align: center,
      toprule,
      [$J_l$], [$lambda_l$], [BO configuration],
      midrule,
      [1], [0], [$Sigma_g^(+')$],
      [1], [$plus.minus 1$], [$Pi_g\; 1$],
      [2], [$plus.minus 1$], [$Pi_g\; 2$],
      bottomrule,
    )),
    [
      - $J_l = 2$, $lambda_l = 0$ is absent; the CG coefficient shows it:
      $ braket(L = 2\, M_L = 0\; j_l = 1\, M_(j_l) = 0, J_l = 2\, 0) = 0 $
      - three BO configurations, as many as partial-wave channels
    ],
  )
]

#slide[Step 1: $6j$ recoupling at fixed $L$][
  Moving $j_l$ from $s_H$ over to $L$ is a $6j$ symbol:
  $ braket((L thin j_l) J_l\, s_H\; J, L\, (j_l thin s_H) S\; J) = (-1)^(L + j_l + s_H + J) sqrt((2 J_l + 1)(2 S + 1)) mat(delim: "{", L, j_l, J_l; s_H, J, S) $
  - $L = 0$: nothing to do, $ket((0 thin 1) 1) = ket(pw(3, S, 1))$
  - $L = 2$: the phase is $(-1)^5 = -1$, and
  $ mat(delim: "{", 2, 1, 1; 1, 1, 1) = 1 / 6, quad mat(delim: "{", 2, 1, 1; 1, 1, 2) = mat(delim: "{", 2, 1, 2; 1, 1, 1) = -sqrt(5) / 10, quad mat(delim: "{", 2, 1, 2; 1, 1, 2) = -1 / 10 $
  e.g. $braket((2 thin 1) 1, pw(3, D, 1)) = -sqrt(3 dot 3) dot 1 \/ 6 = -1 \/ 2$. In total
  #keybox[$ ket((2 thin 1) J_l = 1) = -1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1)), quad ket((2 thin 1) J_l = 2) = sqrt(3) / 2 ket(pw(3, D, 1)) + 1 / 2 ket(pw(5, D, 1)) $]
]

#slide(refs: [Jacob, Wick, Ann. Phys. 7, 404 (1959)])[Step 2: fix the axis (Jacob–Wick)][
  States with a definite projection $lambda_l$ on $hat(bold(r))$:
  $ ket(J_l thin M_l\; lambda_l) = sum_L sqrt((2L + 1) / (2 J_l + 1)) braket(L thin 0 thin j_l thin lambda_l, J_l thin lambda_l) ket((L thin j_l) J_l thin M_l) $
  - the $0$ is the physics: $arrow(L) = arrow(r) times arrow(p)$ is perpendicular to $hat(bold(r))$, so $arrow(L) dot hat(bold(r)) = 0$ and the whole projection $lambda_l$ comes from $arrow(j)_l$
  - the coefficients do not depend on $M_l$
  #v(0.3em)
  $J_l = 1$, $lambda_l = 0$: #h(0.3em) $braket(0 thin 0 thin 1 thin 0, 1 thin 0) = 1$, #h(0.3em) $braket(1 thin 0 thin 1 thin 0, 1 thin 0) = 0$, #h(0.3em) $braket(2 thin 0 thin 1 thin 0, 1 thin 0) = -sqrt(2 \/ 5)$, so
  #keybox[$ ket(Sigma_g^(+')) = 1 / sqrt(3) ket((0 thin 1) 1) - sqrt(2 / 3) ket((2 thin 1) 1) $]
]

#slide[Step 2: the $Pi_g$ states and the missing state][
  - $J_l = 1$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = 1 / sqrt(3) ket((0 thin 1) 1) minus.plus 1 / sqrt(2) ket((1 thin 1) 1) + 1 / sqrt(6) ket((2 thin 1) 1)$ \
    the $L = 1$ piece has the wrong parity and is the one that flips sign, so the parity-even state is $(ket(+1) + ket(-1)) \/ sqrt(2)$:
    $ ket(Pi_g\; 1) = sqrt(2 / 3) ket((0 thin 1) 1) + 1 / sqrt(3) ket((2 thin 1) 1) $
  - $J_l = 2$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = sqrt(3 / 10) ket((1 thin 1) 2) minus.plus 1 / sqrt(2) ket((2 thin 1) 2) + 1 / sqrt(5) ket((3 thin 1) 2)$ \
    now the even-$L$ piece flips sign: the parity-even state is $(ket(+1) - ket(-1)) \/ sqrt(2) = -ket((2 thin 1) 2)$; dropping the overall sign (a convention), $ket(Pi_g\; 2) = ket((2 thin 1) 2)$
  - $J_l = 2$, $lambda_l = 0$: #h(0.3em) $ket(0) = sqrt(2 / 5) ket((1 thin 1) 2) - sqrt(3 / 5) ket((3 thin 1) 2)$ contains only odd $L$, i.e. negative parity: besides the vanishing $L = 2$ CG coefficient, there is no even-$L$ piece at all
]

#slide[Step 3: the transformation matrix][
  Insert Step 1 into Step 2 (the same for the other two rows), e.g.
  $ ket(Sigma_g^(+')) = 1 / sqrt(3) ket(pw(3, S, 1)) - sqrt(2 / 3) (-1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1))) = 1 / sqrt(3) ket(pw(3, S, 1)) + 1 / sqrt(6) ket(pw(3, D, 1)) - 1 / sqrt(2) ket(pw(5, D, 1)) $
  #keybox[$
    mat(ket(Sigma_g^(+')); ket(Pi_g\; 1); ket(Pi_g\; 2)) = underbrace(mat(1 / sqrt(3), 1 / sqrt(6), -1 / sqrt(2); sqrt(2 / 3), -1 / (2 sqrt(3)), 1 / 2; 0, sqrt(3) / 2, 1 / 2), U) mat(ket(B macron(B)^* (pw(3, S, 1))); ket(B macron(B)^* (pw(3, D, 1))); ket(B^* macron(B)^* (pw(5, D, 1)))), quad U U^T = bold(1)
  $]
  - rows normalised ($1 / 3 + 1 / 6 + 1 / 2 = 2 / 3 + 1 / 12 + 1 / 4 = 3 / 4 + 1 / 4 = 1$) and orthogonal: two bases for the same three states
]

#slide[The coupling $g$][
  The first row is what we were after: $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 \/ sqrt(3)$. Back to the projector insertion:
  $ g equiv mel(B macron(B)^* (pw(3, S, 1)), H, W) = underbrace(braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')), 1 \/ sqrt(3)) underbrace(mel(Sigma_g^(+'), H, W), -2 sqrt(2) thin g_l) $
  #keybox[$ |g| = underbrace(sqrt(2), "flavour") times underbrace(2, "spin") times underbrace(1 / sqrt(3), S "wave") times g_l = 2 / sqrt(3) sqrt(2) thin g_l = 57 "MeV" quad (g_l = 35 "MeV") $]
  - $mel(Sigma_g^(+'), H, W)$ is the mixing with the normalised $Sigma_g^(+')$ configuration; by HQSS it equals $mel(1_H\, 0\; 1_l\, 0, H, W) = -2 sqrt(2) thin g_l$ from the lattice
  - the sign does not matter, since $V^((macron(b) b)) prop g^2$
]
