#import "../style.typ": *

#slide[From $Sigma_g^(+')$ to the $pw(3, S, 1)$ channel][
  This is still not what we want: we need $mel(B macron(B)^* (pw(3, S, 1)), H, W)$.
  - insert the completeness relation of the BO basis, $sum ket("BO") bra("BO")$ over ${Sigma_g^(+'), Pi_g\; 1, Pi_g\; 2}$
  - the string $W$ is $Sigma_g^+$ and the mixing conserves the BO quantum numbers, so only $Sigma_g^(+')$ survives (BO selection rule):
  $ mel(B macron(B)^* (pw(3, S, 1)), H, W) = braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) mel(Sigma_g^(+'), H, W) $
  #v(0.3em)
  #keybox[to show: #h(0.4em) $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 / sqrt(3)$ #h(1em) ]
]

#slide[Quantum numbers of the $1^(+ +)$ pairs][
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
      toprule, [$J_l$], [$lambda_l$],
      [BO configuration], midrule, [1],
      [0], [$Sigma_g^(+')$], [1],
      [$plus.minus 1$], [$Pi_g\; 1$], [2],
      [$plus.minus 1$], [$Pi_g\; 2$], bottomrule,
    )),
    [
      - $J_l = 2$, $lambda_l = 0$ is absent due to the CG coefficient
      $ braket(L = 2\, M_L = 0\; j_l = 1\, M_(j_l) = 0, J_l = 2\, 0) = 0 $
      - three BO configurations, as many as partial-wave channels
    ],
  )
]

#slide(refs: [Jacob, Wick, Ann. Phys. 7, 404 (1959)])[Step 1: the formula we need (Jacob–Wick)][
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
  Same steps with $braket(L thin 0 thin 1 thin plus.minus 1, J_l thin plus.minus 1)$:
  - $J_l = 1$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = 1 / sqrt(3) ket((0 thin 1) 1) minus.plus 1 / sqrt(2) ket((1 thin 1) 1) + 1 / sqrt(6) ket((2 thin 1) 1)$ \
    the $L = 1$ piece has the wrong parity and is the one that flips sign, so the parity-even state is $(ket(+1) + ket(-1)) \/ sqrt(2)$:
    $ ket(Pi_g\; 1) = sqrt(2 / 3) ket((0 thin 1) 1) + 1 / sqrt(3) ket((2 thin 1) 1) $
  - $J_l = 2$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = sqrt(3 / 10) ket((1 thin 1) 2) minus.plus 1 / sqrt(2) ket((2 thin 1) 2) + 1 / sqrt(5) ket((3 thin 1) 2)$ \
    now the even-$L$ piece flips sign: the parity-even state is $(ket(+1) - ket(-1)) \/ sqrt(2) = -ket((2 thin 1) 2)$; dropping the overall sign (a convention), $ket(Pi_g\; 2) = ket((2 thin 1) 2)$
]

#slide[Step 2: $6j$ recoupling at fixed $L$][
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

#slide[Step 3: the transformation matrix][
  Insert Step 2 into Step 1 (the same for the other two rows), e.g.
  $
    ket(Sigma_g^(+')) = 1 / sqrt(3) ket(pw(3, S, 1)) - sqrt(2 / 3) (-1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1))) = 1 / sqrt(3) ket(pw(3, S, 1)) + 1 / sqrt(6) ket(pw(3, D, 1)) - 1 / sqrt(2) ket(pw(5, D, 1))
  $
  #keybox[$
    mat(ket(Sigma_g^(+')); ket(Pi_g\; 1); ket(Pi_g\; 2)) = underbrace(mat(1 / sqrt(3), 1 / sqrt(6), -1 / sqrt(2); sqrt(2 / 3), -1 / (2 sqrt(3)), 1 / 2; 0, sqrt(3) / 2, 1 / 2), U) mat(ket(B macron(B)^* (pw(3, S, 1))); ket(B macron(B)^* (pw(3, D, 1))); ket(B^* macron(B)^* (pw(5, D, 1)))), quad U U^T = bold(1)
  $]
  - rows normalised ($1 / 3 + 1 / 6 + 1 / 2 = 2 / 3 + 1 / 12 + 1 / 4 = 3 / 4 + 1 / 4 = 1$) and orthogonal: two bases for the same three states
]

#slide[The coupling $g$][
  The first row is what we were after: $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 \/ sqrt(3)$. Back to the projector insertion:
  $
    g equiv mel(B macron(B)^* (pw(3, S, 1)), H, W) = underbrace(braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')), 1 \/ sqrt(3)) underbrace(mel(Sigma_g^(+'), H, W), -2 sqrt(2) thin g_l)
  $
  #keybox[$
    |g| = underbrace(sqrt(2), "flavour") times underbrace(2, "spin") times underbrace(1 / sqrt(3), S "wave") times g_l = 2 / sqrt(3) sqrt(2) thin g_l = 57 "MeV" quad (g_l = 35 "MeV")
  $]
  - $mel(Sigma_g^(+'), H, W)$ is the mixing with the normalised $Sigma_g^(+')$ configuration; by HQSS it equals $mel(1_H\, 0\; 1_l\, 0, H, W) = -2 sqrt(2) thin g_l$ from the lattice
  - the sign does not matter, since $V^((macron(b) b)) prop g^2$
]
