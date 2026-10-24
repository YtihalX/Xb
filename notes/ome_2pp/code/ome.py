"""Partial-wave projection of the LO one-meson exchange (OME) in B^(*) Bbar^(*).

Conventions are those of Xb.tex, Sect. III B and App. D:
  * TOPT potentials, Eqs. (72)-(75); the B Bbar <-> B* Bbar* transitions, absent in
    1^{++}, follow from the same vertices, Eqs. (69),(70) (derivation in the note);
  * projection, Eq. (80):
        V_{a'a}(p',p) = 1/(2J+1) int dO_n'/4pi dO_n/4pi Tr[P^dag(a';n') V(p',p) P(a;n)];
  * projectors: Xb.tex Eq. (D1) for J=1, Baru et al. 2019 (arXiv:1901.10319),
    App. B, Eqs. (B4),(B7),(B10),(B11),(B13),(B14) for J=2.

The trace is a rotational scalar, so the double angular average equals the
average over n' at fixed n = e_z.  With x = n.n' it is a polynomial in x times
the TOPT denominators D_beta (which depend on x only through q), hence
    V_{a'a}(p',p) = (g_b^2/F_pi^2) sum_m C_m(p',p) Delta_m^{(b1 b2)}(p',p),
    Delta_m^{(b1 b2)} = int_{-1}^{1} dx x^m [D_b1 + D_b2]            (Eq. (D11)).
Symbols: p = |p| (incoming), pp = |p'| (outgoing), q = p - p'.
"""
import itertools

import numpy as np
import sympy as sp

p, pp = sp.symbols("p pp", positive=True)
x = sp.Symbol("x", real=True)
cf, sf = sp.symbols("cf sf", real=True)  # cos, sin of the azimuth of n'
st = sp.Symbol("st", positive=True)       # sin(theta'), = sqrt(1 - x^2)

R = range(3)
EPS = np.zeros((3, 3, 3), dtype=object)
for (i, j, k), sgn in [((0, 1, 2), 1), ((1, 2, 0), 1), ((2, 0, 1), 1),
                       ((0, 2, 1), -1), ((2, 1, 0), -1), ((1, 0, 2), -1)]:
    EPS[i, j, k] = sp.Integer(sgn)
DEL = np.array([[sp.Integer(int(i == j)) for j in R] for i in R], dtype=object)

N_IN = np.array([sp.Integer(0), sp.Integer(0), sp.Integer(1)], dtype=object)
N_OUT = np.array([st * cf, st * sf, x], dtype=object)
Q = p * N_IN - pp * N_OUT


# ---------------------------------------------------------------- building blocks
def v2(n):
    """v_ij = n_i n_j - delta_ij/3, Baru 2019 Eq. (B15)."""
    return np.array([[n[i] * n[j] - DEL[i, j] / 3 for j in R] for i in R], dtype=object)


def v4(n):
    """Rank-4 symmetric traceless tensor of n, Baru 2019 Eq. (B16)."""
    out = np.empty((3,) * 4, dtype=object)
    for i, j, k, l in itertools.product(R, repeat=4):
        nn = (n[i] * n[j] * DEL[k, l] + n[i] * n[k] * DEL[j, l] + n[i] * n[l] * DEL[j, k]
              + n[j] * n[k] * DEL[i, l] + n[j] * n[l] * DEL[i, k] + n[k] * n[l] * DEL[i, j])
        dd = DEL[i, j] * DEL[k, l] + DEL[i, k] * DEL[j, l] + DEL[i, l] * DEL[j, k]
        out[i, j, k, l] = n[i] * n[j] * n[k] * n[l] - nn / 7 + dd / 35
    return out


# S_ij = eps1_i eps2_j + eps1_j eps2_i - 2/3 delta_ij eps1.eps2 = sum_cd eps1_c eps2_d S4[c,d,i,j]
S4 = np.empty((3,) * 4, dtype=object)
for c, d, i, j in itertools.product(R, repeat=4):
    S4[c, d, i, j] = DEL[i, c] * DEL[j, d] + DEL[j, c] * DEL[i, d] - sp.Rational(2, 3) * DEL[i, j] * DEL[c, d]


# ---------------------------------------------------------------- projectors
# A projector is (kind, J, X(n)); kind in {"PP","PV","VV"} counts the vector mesons.
# X has the polarisation indices first and the J indices last:
#   P_{J-indices} = sum_pol eps_{pol} X[pol, J-indices]   (incoming state).
def X_3S1(n):
    return np.array([[DEL[a, i] for i in R] for a in R], dtype=object)


def X_3D1(n):
    v = v2(n)
    return np.array([[-3 / sp.sqrt(2) * v[i, a] for i in R] for a in R], dtype=object)


def X_5D1(n):
    v = v2(n)
    X = np.empty((3, 3, 3), dtype=object)
    for c, d, i in itertools.product(R, repeat=3):
        X[c, d, i] = -sp.sqrt(3) / 2 * sp.I * sum(EPS[i, j, k] * S4[c, d, j, m] * v[k, m]
                                                  for j in R for k in R for m in R)
    return X


def X_1D2_PP(n):
    v = v2(n)
    return np.array([[-sp.sqrt(sp.Rational(15, 2)) * v[i, j] for j in R] for i in R], dtype=object)


def X_3D2(n):
    v = v2(n)
    X = np.empty((3, 3, 3), dtype=object)
    for k, i, j in itertools.product(R, repeat=3):
        X[k, i, j] = -sp.sqrt(5) / 2 * sum(sp.I * EPS[i, k, l] * v[l, j] + sp.I * EPS[j, k, l] * v[l, i]
                                           for l in R)
    return X


def X_5S2(n):
    X = np.empty((3,) * 4, dtype=object)
    for c, d, i, j in itertools.product(R, repeat=4):
        X[c, d, i, j] = S4[c, d, i, j] / 2
    return X


def X_1D2_VV(n):
    v = v2(n)
    X = np.empty((3,) * 4, dtype=object)
    for c, d, i, j in itertools.product(R, repeat=4):
        X[c, d, i, j] = -sp.sqrt(sp.Rational(5, 2)) * DEL[c, d] * v[i, j]
    return X


def X_5D2(n):
    v = v2(n)
    X = np.empty((3,) * 4, dtype=object)
    for c, d, i, j in itertools.product(R, repeat=4):
        X[c, d, i, j] = -sp.sqrt(sp.Rational(45, 56)) * (
            sum(S4[c, d, i, k] * v[k, j] + S4[c, d, j, k] * v[k, i] for k in R)
            - sp.Rational(2, 3) * DEL[i, j] * sum(S4[c, d, k, l] * v[k, l] for k in R for l in R))
    return X


def X_5G2(n):
    w = v4(n)
    X = np.empty((3,) * 4, dtype=object)
    for c, d, i, j in itertools.product(R, repeat=4):
        X[c, d, i, j] = sp.sqrt(sp.Rational(175, 32)) * sum(S4[c, d, k, l] * w[i, j, k, l]
                                                             for k in R for l in R)
    return X


PROJ = {  # name: (kind, J, X-builder, L, S)
    "3S1": ("PV", 1, X_3S1, 0, 1),
    "3D1": ("PV", 1, X_3D1, 2, 1),
    "5D1": ("VV", 1, X_5D1, 2, 2),
    "5S2": ("VV", 2, X_5S2, 0, 2),
    "1D2*": ("VV", 2, X_1D2_VV, 2, 0),
    "5D2": ("VV", 2, X_5D2, 2, 2),
    "5G2": ("VV", 2, X_5G2, 4, 2),
    "3D2": ("PV", 2, X_3D2, 2, 1),
    "1D2": ("PP", 2, X_1D2_PP, 2, 0),
}
CHANNELS_1PP = ["3S1", "3D1", "5D1"]
CHANNELS_2PP = ["5S2", "1D2*", "5D2", "5G2", "3D2", "1D2"]  # 1D2* = B*Bbar*(1D2), 1D2 = B Bbar(1D2)


# ---------------------------------------------------------------- TOPT potentials
def _aq(a, b, q):
    """(A.q) with A = i/sqrt2 (eps x eps'^*), eps -> index a, eps'^* -> index b."""
    return sp.I / sp.sqrt(2) * sum(EPS[k, a, b] * q[k] for k in R)


def spin_tensor(kind_out, kind_in, q):
    """Spin structure V[out pol..., in pol...], prefactor (units g_b^2/F_pi^2), D-combination.

    (PV,PV): Eq. (72)   -1/4 (eps.q)(eps'^*.q)                          [D1+D2]
    (VV,PV): Eq. (73)   +1/4 [(A1.q)(eps2'^*.q) + (A2.q)(eps1'^*.q)]     [D3+D2]
    (PV,VV): Eq. (74)   +1/4 [(A1.q)(eps2.q) + (A2.q)(eps1.q)]           [D4+D2]
    (VV,VV): Eq. (75)   -1/2 (A1.q)(A2.q)                                [2 D2]
    (VV,PP): new        +1/4 (eps1'^*.q)(eps2'^*.q)                      [2 D3]
    (PP,VV): new        +1/4 (eps1.q)(eps2.q)                            [2 D4]
    B Bbar -> B Bbar and B Bbar <-> B Bbar* vanish (no B B phi vertex).
    """
    key = (kind_out, kind_in)
    if key == ("PV", "PV"):
        V = np.array([[q[a] * q[b] for a in R] for b in R], dtype=object)
        return V, sp.Rational(-1, 4), (1, 2)
    if key == ("VV", "PV"):
        V = np.empty((3, 3, 3), dtype=object)
        for b1, b2, a in itertools.product(R, repeat=3):
            V[b1, b2, a] = _aq(a, b1, q) * q[b2] + _aq(a, b2, q) * q[b1]
        return V, sp.Rational(1, 4), (2, 3)
    if key == ("PV", "VV"):
        V = np.empty((3, 3, 3), dtype=object)
        for b, a1, a2 in itertools.product(R, repeat=3):
            V[b, a1, a2] = _aq(a1, b, q) * q[a2] + _aq(a2, b, q) * q[a1]
        return V, sp.Rational(1, 4), (2, 4)
    if key == ("VV", "VV"):
        V = np.empty((3,) * 4, dtype=object)
        for b1, b2, a1, a2 in itertools.product(R, repeat=4):
            V[b1, b2, a1, a2] = _aq(a1, b1, q) * _aq(a2, b2, q)
        return V, sp.Rational(-1, 2), (2, 2)
    if key == ("VV", "PP"):
        V = np.array([[q[b1] * q[b2] for b2 in R] for b1 in R], dtype=object)
        return V, sp.Rational(1, 4), (3, 3)
    if key == ("PP", "VV"):
        V = np.array([[q[a1] * q[a2] for a2 in R] for a1 in R], dtype=object)
        return V, sp.Rational(1, 4), (4, 4)
    return None, 0, None  # PP<->PP, PP<->PV: no OME


NPOL = {"PP": 0, "PV": 1, "VV": 2}


def _as_matrix(X, npol):
    """Reshape pol indices into rows, J indices into columns."""
    rows = 3 ** npol
    return sp.Matrix(np.asarray(X, dtype=object).reshape(rows, -1).tolist())


def phi_average(expr):
    """<cf^a sf^b>_phi = (a-1)!!(b-1)!!/(a+b)!! for even a, b, zero otherwise; st^2 -> 1-x^2."""
    poly = sp.Poly(sp.expand(expr), cf, sf)
    out = 0
    for (a, b), coeff in poly.terms():
        if a % 2 or b % 2:
            continue
        out += coeff * sp.factorial2(a - 1) * sp.factorial2(b - 1) / sp.factorial2(a + b)
    out = sp.expand(out)
    # st appears only in even powers after the phi average
    out = sp.expand(out.subs(st, sp.sqrt(1 - x ** 2)))
    assert not out.has(st)
    return out


def project(name_out, name_in):
    """Return (coeffs, combo): V = (g_b^2/F_pi^2) sum_m coeffs[m] Delta_m^{combo}."""
    k_out, J, Xo_f, _, _ = PROJ[name_out]
    k_in, J2, Xi_f, _, _ = PROJ[name_in]
    assert J == J2
    V, pref, combo = spin_tensor(k_out, k_in, Q)
    if V is None:
        return {}, None
    Xo = _as_matrix(Xo_f(N_OUT), NPOL[k_out])
    Xi = _as_matrix(Xi_f(N_IN), NPOL[k_in])
    Vm = sp.Matrix(np.asarray(V, dtype=object).reshape(3 ** NPOL[k_out], 3 ** NPOL[k_in]).tolist())
    trace = (Xo.H * Vm * Xi).trace()
    avg = phi_average(trace)
    assert sp.simplify(sp.im(sp.expand_complex(avg))) == 0, (name_out, name_in)
    avg = sp.expand(sp.re(sp.expand_complex(avg)))
    poly = sp.Poly(avg, x)
    coeffs = {}
    for (m,), c in poly.terms():
        val = sp.expand(pref * c / (2 * (2 * J + 1)))
        if val != 0:
            coeffs[m] = val
    return coeffs, combo


def projected_matrix(channels):
    return {(a, b): project(a, b) for a in channels for b in channels}


def swap_momenta(expr):
    t = sp.Symbol("t", positive=True)
    return sp.expand(expr.subs(p, t).subs(pp, p).subs(t, pp))


def swap_combo(combo):
    """D_beta(p',p) <-> D_beta(p,p'): beta 3 <-> 4, others unchanged."""
    if combo is None:
        return None
    m = {1: 1, 2: 2, 3: 4, 4: 3}
    return tuple(sorted((m[combo[0]], m[combo[1]])))


# ---------------------------------------------------------------- pretty printing
def bracket(coeffs):
    """Split sum_m C_m Delta_m into kappa * [integer-coefficient bracket]."""
    terms = []
    for m, c in coeffs.items():
        for mon, cc in sp.Poly(c, p, pp).terms():
            terms.append((m, mon, sp.nsimplify(cc)))
    first = terms[0][2]
    ratios = [sp.nsimplify(sp.simplify(t[2] / first)) for t in terms]
    assert all(r.is_Rational for r in ratios), ratios
    lcm = sp.ilcm(*[r.q for r in ratios])
    gcd = sp.igcd(*[r.p for r in ratios])
    ints = [r * lcm / gcd for r in ratios]
    kappa = sp.simplify(first * gcd / lcm)
    # make the coefficient of the highest moment's leading monomial positive
    top = max(range(len(terms)), key=lambda k: (terms[k][0], terms[k][1]))
    if ints[top] < 0:
        ints = [-v for v in ints]
        kappa = -kappa
    return kappa, [(terms[k][0], terms[k][1], ints[k]) for k in range(len(terms))]


def latex_element(coeffs, combo):
    """LaTeX in the style of Xb.tex App. D: kappa g^2/F^2 [sum_m poly_m Delta_m], highest m first."""
    if not coeffs:
        return "0"
    kappa, ints = bracket(coeffs)
    by_m = {}
    for m, (a, b), n in ints:
        by_m.setdefault(m, []).append((n, a, b))
    body = ""
    for m in sorted(by_m, reverse=True):
        poly = sp.expand(sum(n * p ** a * pp ** b for n, a, b in by_m[m]))
        lead = sp.Poly(poly, p, pp).coeffs()[0]
        sign = "-" if lead < 0 else "+"
        poly = sp.factor(-poly if lead < 0 else poly)
        s = sp.latex(poly).replace("pp", "p'")
        if isinstance(poly, sp.Add):
            s = "(" + s + ")"
        body += f" {sign} {s}\\,\\Delta^{{({combo[0]}{combo[1]})}}_{m}"
    body = body.strip()
    body = body[2:] if body.startswith("+ ") else "-" + body[2:]
    return f"{sp.latex(kappa)}\\,\\frac{{g_b^2}}{{F_\\pi^2}}\\Bigl[{body}\\Bigr]"
