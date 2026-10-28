"""Checks for the quantum-number section of the note.

1. Heavy/light spin decomposition of S-wave meson-antimeson spin states
   (Eq. (14) of the paper and its partners).
2. 6j / Clebsch-Gordan recouplings behind Eqs. (20)-(22).
3. Normalisation of the partial-wave projectors of App. D, Eq. (81).
4. <S.L>, <S12> and the J-weighted sum rule of App. B.

Particles are ordered (b, lbar, bbar, l): meson M = (b lbar), antimeson Mbar = (bbar l).
Only spin space is used; overall phases depend on coupling order and are irrelevant
for magnitudes and for the structure (which components vanish).
"""
import itertools
import numpy as np
from sympy import Rational, sqrt, nsimplify
from sympy.physics.quantum.cg import CG
from sympy.physics.wigner import wigner_6j

half = Rational(1, 2)
MS = [half, -half]  # m values of a spin-1/2


def cg(j1, m1, j2, m2, j, m):
    return float(CG(j1, m1, j2, m2, j, m).doit())


def couple_two(j1, j2, J, M):
    """Vector over (m1, m2) of two spin-1/2 coupled to (J, M), as dict."""
    out = {}
    for m1, m2 in itertools.product(MS, MS):
        c = cg(j1, m1, j2, m2, J, M)
        if abs(c) > 1e-14:
            out[(m1, m2)] = c
    return out


def basis_index(ms):
    # ms = (m_b, m_lbar, m_bbar, m_l); index into 16-dim space
    return sum((0 if m == half else 1) << (3 - k) for k, m in enumerate(ms))


def meson_pair_state(S1, S2, S, M):
    """|(b lbar)S1, (bbar l)S2; S M> in the 16-dim spin space."""
    v = np.zeros(16)
    for M1 in [m for m in np.arange(-S1, S1 + 1)]:
        M2 = M - M1
        if abs(M2) > S2:
            continue
        c12 = cg(S1, Rational(M1), S2, Rational(M2), S, M)
        if abs(c12) < 1e-14:
            continue
        for (mb, mlb), c1 in couple_two(half, half, S1, Rational(M1)).items():
            for (mbb, ml), c2 in couple_two(half, half, S2, Rational(M2)).items():
                v[basis_index((mb, mlb, mbb, ml))] += c12 * c1 * c2
    return v


def heavy_light_state(sH, jl, S, M):
    """|(b bbar) sH, (lbar l) jl; S M>."""
    v = np.zeros(16)
    for MH in np.arange(-sH, sH + 1):
        ML = M - MH
        if abs(ML) > jl:
            continue
        c = cg(sH, Rational(MH), jl, Rational(ML), S, M)
        if abs(c) < 1e-14:
            continue
        for (mb, mbb), cH in couple_two(half, half, sH, Rational(MH)).items():
            for (mlb, ml), cL in couple_two(half, half, jl, Rational(ML)).items():
                v[basis_index((mb, mlb, mbb, ml))] += c * cH * cL
    return v


def decompose(vec, S, M):
    out = {}
    for sH, jl in itertools.product([0, 1], [0, 1]):
        if not (abs(sH - jl) <= S <= sH + jl):
            continue
        ov = heavy_light_state(sH, jl, S, M) @ vec
        if abs(ov) > 1e-12:
            out[f"{sH}_H x {jl}_l"] = nsimplify(round(ov, 12), [sqrt(2), sqrt(3), sqrt(6)])
    return out


print("== 1. heavy/light decomposition of S-wave pair spin states (M = 0 component)")
print("B Bbar      (S=0):", decompose(meson_pair_state(0, 0, 0, 0), 0, 0))
print("B* Bbar* (S=0):  ", decompose(meson_pair_state(1, 1, 0, 0), 0, 0))
print("B* Bbar* (S=1):  ", decompose(meson_pair_state(1, 1, 1, 0), 1, 0))
print("B* Bbar* (S=2):  ", decompose(meson_pair_state(1, 1, 2, 0), 2, 0))
a = meson_pair_state(0, 1, 1, 0)   # B Bbar*
b = meson_pair_state(1, 0, 1, 0)   # B* Bbar
print("(B Bbar* + B* Bbar)/sqrt2:", decompose((a + b) / np.sqrt(2), 1, 0))
print("(B Bbar* - B* Bbar)/sqrt2:", decompose((a - b) / np.sqrt(2), 1, 0))
# Eq. (14) in the m-basis: coefficient of |1_l, lam>|1_bb, -lam>
vBB = meson_pair_state(0, 0, 0, 0)
print("Eq.(14) check, <0_H 0_l|B Bbar> =", round(heavy_light_state(0, 0, 0, 0) @ vBB, 12))
for lam in (1, 0, -1):
    w = np.zeros(16)
    for (mb, mbb), cH in couple_two(half, half, 1, Rational(-lam)).items():
        for (mlb, ml), cL in couple_two(half, half, 1, Rational(lam)).items():
            w[basis_index((mb, mlb, mbb, ml))] += cH * cL
    print(f"  <1_l,{lam:+d}; 1_bb,{-lam:+d} | B Bbar> = {round(w @ vBB, 12)}")

print("\n== 2. recouplings behind Eqs. (20)-(22)")
L, jl, s = 2, 1, 1
for Jl in (1, 2):
    for S in (1, 2):
        sixj = wigner_6j(L, jl, Jl, s, 1, S)
        coef = sqrt((2 * Jl + 1) * (2 * S + 1)) * sixj
        print(f"  J_l={Jl}, S={S}: 6j{{2 1 {Jl}; 1 1 {S}}} = {sixj},  sqrt((2J_l+1)(2S+1))*6j = {nsimplify(coef)}")
print("  CG <L 0 1 0|J_l 0>:", {f"L={Lv},Jl={J}": CG(Lv, 0, 1, 0, J, 0).doit() for Lv in (0, 2) for J in (1, 2, 3)})
print("  CG <L 0 1 +1|1 +1>:", {f"L={Lv}": CG(Lv, 0, 1, 1, 1, 1).doit() for Lv in (0, 1, 2)})
print("  CG <L 0 1 -1|1 -1>:", {f"L={Lv}": CG(Lv, 0, 1, -1, 1, -1).doit() for Lv in (0, 1, 2)})
A = np.array([1, 0, 0.0])                                   # (L=0,j_l=1)J_l=1 = 3S1
B = np.array([0, -0.5, np.sqrt(3) / 2])                     # (L=2,j_l=1)J_l=1, Eq. (20)
Cst = np.array([0, np.sqrt(3) / 2, 0.5])                    # (L=2,j_l=1)J_l=2, Eq. (20)
Sig = np.sqrt(1 / 3) * A - np.sqrt(2 / 3) * B              # lambda = 0, Eq. (21)
Pi1 = np.sqrt(2 / 3) * A + np.sqrt(1 / 3) * B              # (lambda=+1 + lambda=-1)/sqrt2
U = np.array([Sig, Pi1, Cst])
print("  BO matrix U (rows Sigma', Pi;1, Pi;2; cols 3S1, 3D1, 5D1):\n", np.round(U, 6))
print("  U U^T = 1 ?", np.allclose(U @ U.T, np.eye(3)))
Ma = np.array([[0, -np.sqrt(2), np.sqrt(6)], [-np.sqrt(2), 1, np.sqrt(3)], [np.sqrt(6), np.sqrt(3), -1]])
VS, VP = 0.37, -0.21  # arbitrary numbers
Vfull = U.T @ np.diag([VS, VP, VP]) @ U
print("  Eq. (26) check:", np.allclose(Vfull, (VS + 2 * VP) / 3 * np.eye(3) + (VP - VS) / 6 * Ma))

print("\n== 3. projector normalisation, Eq. (81): (1/3) <sum_pol sum_i |P_i|^2>_Omega")
rng = np.random.default_rng(1)
pol = np.eye(3)               # Cartesian polarisation basis (sum over it = completeness)
def nmat(n):
    return np.outer(n, n) - np.eye(3) / 3
eps3 = np.zeros((3, 3, 3))
for (i, j, k), sgn in [((0, 1, 2), 1), ((1, 2, 0), 1), ((2, 0, 1), 1), ((0, 2, 1), -1), ((2, 1, 0), -1), ((1, 0, 2), -1)]:
    eps3[i, j, k] = sgn
acc = np.zeros(3)
ndir = 4000
for _ in range(ndir):
    n = rng.normal(size=3); n /= np.linalg.norm(n)
    N = nmat(n)
    for e in pol:
        acc[0] += np.sum(np.abs(e) ** 2)                               # 3S1: P_i = eps_i
        acc[1] += np.sum(np.abs(-3 / np.sqrt(2) * N @ e) ** 2)         # 3D1
    for e1 in pol:
        for e2 in pol:
            T = np.outer(e1, e2) + np.outer(e2, e1) - 2 / 3 * np.eye(3) * (e1 @ e2)
            P = -np.sqrt(3) / 2 * 1j * np.einsum("ijk,jm,km->i", eps3, T, N)
            acc[2] += np.sum(np.abs(P) ** 2)
print("  3S1, 3D1, 5D1:", np.round(acc / ndir / 3, 4))

print("\n== 4. App. B: <S.L>, <S12> (S12 = 3(S.rhat)^2 - S^2) for 3P_J and the sum rule")
for J in (0, 1, 2):
    SL = Rational(J * (J + 1), 2) - 2
    S12 = 1 - Rational(9, 2 * J + 1) * CG(1, 0, 1, 0, J, 0).doit() ** 2
    print(f"  J={J}: <S.L> = {SL}, <S12> = {S12}")
SLs = [Rational(J * (J + 1), 2) - 2 for J in (0, 1, 2)]
S12s = [1 - Rational(9, 2 * J + 1) * CG(1, 0, 1, 0, J, 0).doit() ** 2 for J in (0, 1, 2)]
print("  sum (2J+1)<S.L> =", sum((2 * J + 1) * SLs[J] for J in (0, 1, 2)),
      ", sum (2J+1)<S12> =", sum((2 * J + 1) * S12s[J] for J in (0, 1, 2)))
