"""Checks for the 2^{++} note: (1) projector normalisation, (2) Baru 2016 Table 1 weights,
(3) heavy-quark-limit block structure, U, Sigma' content, (4) vanishing elements,
(5) transcribed HadronDynamics.jl projection.jl versus Eq. (D1), (6) kinematics of Sect. 2.2.

Run from inside code/:
    uv run --no-project --with numpy --with sympy python checks.py
"""
import itertools

import numpy as np
import sympy as sp
from sympy.physics.wigner import wigner_6j

import ome
from ome import CHANNELS_1PP, CHANNELS_2PP, PROJ, project

p, pp = ome.p, ome.pp
n_sym = sp.symbols("n1:4", real=True)


def surd(v, tol=1e-10):
    """Exact sign * sqrt(rational) from a float (all recoupling numbers are of this form)."""
    if abs(v) < tol:
        return sp.Integer(0)
    r = sp.nsimplify(v * v, rational=True, tolerance=tol)
    return sp.sign(v) * sp.sqrt(r)



def sphere_average(expr):
    """<n1^a n2^b n3^c> over dOmega/4pi = (a-1)!!(b-1)!!(c-1)!!/(a+b+c+1)!! (all even), else 0."""
    poly = sp.Poly(sp.expand(expr), *n_sym)
    out = 0
    for (a, b, c), coeff in poly.terms():
        if a % 2 or b % 2 or c % 2:
            continue
        out += coeff * sp.factorial2(a - 1) * sp.factorial2(b - 1) * sp.factorial2(c - 1) / sp.factorial2(a + b + c + 1)
    return sp.nsimplify(sp.expand(out))


# ---------------------------------------------------------------- 1. projector normalisation, Eq. (81)/(B19)
print("== 1. (1/(2J+1)) <Tr P(a) P^dag(b)>_Omega for projectors of equal kind and J")
nvec = np.array(n_sym, dtype=object)
Xs = {name: np.asarray(spec[2](nvec), dtype=object) for name, spec in PROJ.items()}
groups = {}
for name, (kind, J, _, L, S) in PROJ.items():
    groups.setdefault((kind, J), []).append(name)
for (kind, J), names in groups.items():
    mat = [[sphere_average(sum(sp.conjugate(a) * b for a, b in zip(Xs[n1].ravel(), Xs[n2].ravel()))) / (2 * J + 1)
            for n2 in names] for n1 in names]
    print(f"  {kind}, J={J}: {names} ->", sp.Matrix(mat).tolist())


# ---------------------------------------------------------------- 2. leading-divergence weights, Baru 2016 Table 1
def static_hqss_value(coeffs, p_val, pp_val):
    """V at B = 2pp' = 0 (one momentum zero): Delta_m -> 2/(m+1) (even m) times 2D; drop the common 2D."""
    tot = 0
    for m, c in coeffs.items():
        if m % 2 == 0:
            tot += c.subs({p: p_val, pp: pp_val}) * sp.Rational(2, m + 1)
    return sp.nsimplify(tot)


print("\n== 2. one-loop leading-divergence weights |V_{alpha <- S}(l,0)|^2 / sum (Baru 2016, Table 1)")
for chans, S in ((CHANNELS_1PP, "3S1"), (CHANNELS_2PP, "5S2")):
    l = sp.Symbol("l", positive=True)
    vals = {a: static_hqss_value(project(a, S)[0], 0, l) for a in chans}   # outgoing a at l, incoming S at 0
    tot = sum(v**2 for v in vals.values())
    print(f"  {S}: total = {sp.simplify(tot)};", {a: sp.simplify(v**2 / tot) for a, v in vals.items()})


# ---------------------------------------------------------------- 3. HQSS limit: block structure
def cm_matrices(chans, pv, ppv):
    """C_m(p',p) as len(chans) x len(chans) float matrices, all Delta^{(b1 b2)} identified."""
    mats = np.zeros((6, len(chans), len(chans)))
    for (ia, a), (ib, b) in itertools.product(enumerate(chans), repeat=2):
        coeffs, _ = project(a, b)
        for m, c in coeffs.items():
            mats[m, ia, ib] = float(c.subs({p: pv, pp: ppv}))
    return mats


rng = np.random.default_rng(7)
samples = [tuple(rng.uniform(0.1, 1.2, 2)) for _ in range(4)]
C2 = [cm_matrices(CHANNELS_2PP, *s) for s in samples]
C1 = [cm_matrices(CHANNELS_1PP, *s) for s in samples]
gens = [M[m] for M in C2 for m in range(6)] + [M[m].T for M in C2 for m in range(6)]


def invariant_span(v0):
    basis = [v0 / np.linalg.norm(v0)]
    while True:
        cand = np.array([g @ b for g in gens for b in basis] + basis)
        u, s, _ = np.linalg.svd(cand.T)
        rank = int(np.sum(s > 1e-10 * s[0]))
        new = u[:, :rank].T
        if rank == len(basis):
            return new
        basis = list(new)


idx = {c: k for k, c in enumerate(CHANNELS_2PP)}
e = np.eye(6)
blk1 = invariant_span(e[idx["5S2"]])
blk3 = invariant_span(e[idx["5G2"]])
print("\n== 3. HQSS limit (all D_beta equal)")
print("  dim of invariant span of 5S2:", len(blk1), "; of 5G2:", len(blk3))
rest = np.linalg.svd(np.vstack([blk1, blk3]).T)[0][:, 4:].T  # orthogonal complement (2-dim)
G = sum(rng.normal() * (rest @ g @ rest.T) for g in gens)
_, ev = np.linalg.eigh(G + G.T)
rest_vecs = (ev.T @ rest)


def clean(v, ref=None):
    v = v / np.linalg.norm(v)
    if ref is not None and v @ ref < 0:
        v = -v
    return v


# 1x1 blocks: the s_H = 0 (j_l = 0) state has support only on the two 1D2 channels
s0 = [v for v in rest_vecs if abs(v[idx["5D2"]]) < 1e-9 and abs(v[idx["3D2"]]) < 1e-9]
assert len(s0) == 1
u_jl0 = clean(s0[0], e[idx["1D2"]])
u_J2 = clean([v for v in rest_vecs if abs(v @ u_jl0) < 1e-9][0], e[idx["1D2"]])
# 2x2 blocks: pick the L = 2 member orthogonal to the pure channel
w1 = blk1 - np.outer(blk1 @ e[idx["5S2"]], e[idx["5S2"]])
w1 = clean(w1[np.argmax(np.linalg.norm(w1, axis=1))])
w3 = blk3 - np.outer(blk3 @ e[idx["5G2"]], e[idx["5G2"]])
w3 = clean(w3[np.argmax(np.linalg.norm(w3, axis=1))])

# sign convention: match the 1++ basis of Xb.tex Eq. (20),
#   |(2,1)J_l=1> = -1/2 |3D1> + sqrt3/2 |5D1>,  |(2,1)J_l=2> = sqrt3/2 |3D1> + 1/2 |5D1>,
# through V_{S,(21)1} (2++) = V_{S,(21)1} (1++).
U1 = np.array([[1, 0, 0], [0, -0.5, np.sqrt(3) / 2], [0, np.sqrt(3) / 2, 0.5]])
B1 = [U1 @ M[m] @ U1.T for M in C1 for m in range(6)]
U_tmp = np.array([e[idx["5S2"]], w1])
B2 = [U_tmp @ M[m] @ U_tmp.T for M in C2 for m in range(6)]
k = max(range(len(B1)), key=lambda t: abs(B1[t][0, 1]))
if np.sign(B2[k][0, 1]) != np.sign(B1[k][0, 1]):
    w1 = -w1
U = np.array([u_jl0, e[idx["5S2"]], w1, u_J2, w3, e[idx["5G2"]]])
labels = ["j_l=0", "(0,1)1=5S2", "(2,1)1", "(2,1)2", "(2,1)3", "(4,1)3=5G2"]
print("  U U^T = 1:", np.allclose(U @ U.T, np.eye(6)))
mask = np.ones((6, 6), bool)
for blk in ([0], [1, 2], [3], [4, 5]):
    for a in blk:
        for b in blk:
            mask[a, b] = False
off = max(np.max(np.abs((U @ M[m] @ U.T)[mask])) for M in C2 for m in range(6))
scale = max(np.max(np.abs(M)) for M in C2)
print(f"  max off-block |U C_m U^T| / max |C_m| = {off / scale:.1e}")
print("  U (rows: HQSS states; columns:", CHANNELS_2PP, "):")
for lab, row in zip(labels, U):
    print(f"    {lab:>11}: ", [surd(v) for v in row])

# compare the J_l = 1 and J_l = 2 blocks with 1++ (Xb.tex Eq. (20) basis)
dev = 0.0
for M1, M2 in zip(C1, C2):
    for m in range(6):
        b1 = U1 @ M1[m] @ U1.T
        b2 = U @ M2[m] @ U.T
        dev = max(dev, np.max(np.abs(b1[:2, :2] - b2[1:3, 1:3])), abs(b1[2, 2] - b2[3, 3]))
print(f"  J_l=1 (2x2) and J_l=2 (1x1) blocks equal to the 1++ ones: max dev = {dev:.1e}")
off1 = max(abs((U1 @ M[m] @ U1.T)[0, 2]) + abs((U1 @ M[m] @ U1.T)[1, 2]) for M in C1 for m in range(6))
print(f"  (1++ itself: Eq. (20) basis block-diagonalises Eq. (D2)-(D10): max off-block = {off1:.1e})")
# J_l = 1, lambda_l = 0 (Sigma_g^+') combination, same Step-2 coefficients as Xb.tex Eq. (21):
#   |Sigma'> = 1/sqrt3 |(0,1)1> - sqrt(2/3) |(2,1)1>   (reproduces Eq. (17) for 1++)
sig1 = np.sqrt(1 / 3) * np.array([1, 0, 0]) - np.sqrt(2 / 3) * U1[1]
sig2 = np.sqrt(1 / 3) * e[idx["5S2"]] - np.sqrt(2 / 3) * w1
print("  Sigma' content, 1++ (3S1, 3D1, 5D1):", [surd(v) for v in sig1])
print("  Sigma' content, 2++", CHANNELS_2PP, ":", [surd(v) for v in sig2])

# recoupling coefficients, <(L j_l)J_l, s; J | L, (j_l s) S; J> = (-1)^{L+j+s+J} sqrt((2J_l+1)(2S+1)) {L j J_l; s J S}
print("  6j recoupling at L=2, J=2 (rows J_l=1,2,3; columns S=0,1,2):")
Rm = sp.Matrix(3, 3, lambda a, b: (-1) ** 6 * sp.sqrt((2 * (a + 1) + 1) * (2 * b + 1)) * wigner_6j(2, 1, a + 1, 1, 2, b))
print("   ", Rm.tolist())
# our L=2 rows in the basis (u_S0, 3D2, 5D2), with u_S0 = sqrt3/2 |1D2> - 1/2 |1D2*>  [the (1_H 1_l)_0 part]
u_S0 = np.zeros(6)
u_S0[idx["1D2"]], u_S0[idx["1D2*"]] = np.sqrt(3) / 2, -0.5
ours = np.array([[row @ u_S0, row[idx["3D2"]], row[idx["5D2"]]] for row in (w1, u_J2, w3)])
print("    ours (same layout):", [[surd(v) for v in r] for r in ours])
print("    |ours| = |6j|:", np.allclose(np.abs(ours), np.abs(np.array(Rm.evalf(), dtype=float))))
print("    ours / 6j (sign pattern):", np.round(ours / np.array(Rm.evalf(), dtype=float), 12).tolist())

# j_l = 0 element versus -3 x central OME in L=2.  With x-moments Delta_m of the common D:
#   V_11(1++) = (1/24) int dx (-q^2) D   (j_l = 1, central only, <sigma.sigma> = +1),
#   so the light-singlet (<sigma.sigma> = -3) L = 2 element should be (-3)(1/24) int dx P_2(x) (-q^2) D.
print("  j_l = 0 element vs (-3) x central OME in L = 2:")
x = sp.Symbol("x")
D = sp.symbols("D0:6")
coef = {}
for a, ca in zip(CHANNELS_2PP, u_jl0):
    for b, cb in zip(CHANNELS_2PP, u_jl0):
        if abs(ca * cb) < 1e-12:
            continue
        cs, _ = project(a, b)
        for m, c in cs.items():
            coef[m] = coef.get(m, 0) + surd(ca * cb) * c
jl0 = sp.expand(sum(v * D[m] for m, v in coef.items()))
P2 = (3 * x**2 - 1) / 2
cen = sp.expand(-3 * sp.Rational(1, 24) * P2 * (-(p**2 + pp**2 - 2 * p * pp * x)))
cen = sp.expand(sum(cen.coeff(x, m) * D[m] for m in range(4)))
print("    V_{j_l=0} =", jl0, "\n    equal to (-3) x central(L=2):", sp.simplify(jl0 - cen) == 0)

# ---------------------------------------------------------------- 4. identically vanishing elements
print("\n== 4. identically vanishing 2++ elements (any masses):")
for a, b in itertools.combinations_with_replacement(CHANNELS_2PP, 2):
    if not project(a, b)[0]:
        print(f"    V[{a} <- {b}] = 0")


# ---------------------------------------------------------------- 5. HadronDynamics.jl projection.jl (transcribed)
def hd_coefficients(out, incoming, pout, pin):
    """Transcription of src/models/BOchiEFT/projection.jl:11-29 (x^0..x^3, units -g_b^2/(8F_pi^2))."""
    r, q = pout, pin
    if out == 1 and incoming == 1:
        return ((q**2 + r**2) / 3, -2 * q * r / 3, 0, 0)
    if out == 1 and incoming in (2, 3):
        a = sp.sqrt(2) if incoming == 2 else sp.sqrt(6)
        return (a * (-2 * q**2 + r**2) / 6, 2 * a * q * r / 3, -a * r**2 / 2, 0)
    if incoming == 1 and out in (2, 3):
        return hd_coefficients(incoming, out, q, r)
    if out == 2 and incoming == 2:
        return (-(q**2 + r**2) / 3, q * r / 6, q**2 + r**2, -3 * q * r / 2)
    if {out, incoming} == {2, 3}:
        a = sp.sqrt(3)
        return (a * (q**2 + r**2) / 6, a * q * r / 6, -a * (q**2 + r**2) / 2, a * q * r / 2)
    return (0, q * r / 2, 0, -q * r / 2)


print("\n== 5. HadronDynamics.jl projection.jl (transcribed) versus Eq. (D1) projection, ratio code/paper:")
for o, i in itertools.product(range(1, 4), repeat=2):
    ours = project(CHANNELS_1PP[o - 1], CHANNELS_1PP[i - 1])[0]
    code = [sp.expand(-sp.S(c) / 8) for c in hd_coefficients(o, i, pp, p)]
    ratio = {sp.simplify(code[m] / ours[m]) for m in ours}
    same_support = {m for m in range(4) if code[m] != 0} == set(ours)
    print(f"    ({o},{i}): {ratio}  same x-powers: {same_support}")

# ---------------------------------------------------------------- 6. kinematics quoted in Sect. 2.2
mB, mBs = 5.279, 5.325   # Xb.tex Eq. (2)
dm = mBs - mB
mu = mB * mBs / (mB + mBs)
E = dm                   # the B* Bbar* threshold, counted from m_B + m_B*
print("\n== 6. on-shell momenta at the B*Bbar* threshold (nonrelativistic, E from m_B+m_B*):")
print(f"    B Bbar* : k = {np.sqrt(2 * mu * E):.3f} GeV;  B Bbar : k = {np.sqrt(2 * (mB / 2) * (E + dm)):.3f} GeV")
print(f"    thresholds - M_th: B*Bbar* {+dm*1e3:.0f} MeV, B Bbar {-dm*1e3:.0f} MeV; 2 m_B = {2*mB:.3f} GeV")
