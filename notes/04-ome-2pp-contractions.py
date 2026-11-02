# /// script
# dependencies = ["sympy>=1.13"]
# ///
"""Derivation aid (notes/04-ome-2pp.md): Eq. (80) spin contractions.

Not a check. Contracts the literal Cartesian projectors with the isospin-free
spin numerators N of the note at n=z, n'=(s,0,x), s=sqrt(1-x^2), reduces s^2,
asserts odd s powers cancel, and prints c=-T as coefficients of x^0..x^5
(r=p' outgoing, p incoming). The 1++ (D1) table of note 03 is reproduced first.
Run: uv run --script notes/04-ome-2pp-contractions.py
"""
import itertools as it
import sympy as sp

p, r, x = sp.symbols('p r x', real=True)
s = sp.Symbol('s', positive=True)
n = sp.Matrix([0, 0, 1])
m = sp.Matrix([s, 0, x])   # outgoing direction n'
q = p*n - r*m
I = sp.I
eye = sp.eye(3)
eps = lambda a, b, c: sp.LeviCivita(a, b, c)
R = sp.Matrix(3, 3, lambda a, c: sum(eps(c, a, k)*q[k] for k in range(3)))


def Q(v):
    return sp.Matrix(3, 3, lambda a, b: v[a]*v[b] - eye[a, b]/3)


def v4(v, i, j, k, l):
    d = lambda a, b: eye[a, b]
    return (v[i]*v[j]*v[k]*v[l]
            - (v[i]*v[j]*d(k, l) + v[i]*v[k]*d(j, l) + v[i]*v[l]*d(j, k)
               + v[j]*v[k]*d(i, l) + v[j]*v[l]*d(i, k) + v[k]*v[l]*d(i, j))/7
            + (d(i, j)*d(k, l) + d(i, k)*d(j, l) + d(i, l)*d(j, k))/35)


def S(a, b, i, j):
    return eye[a, i]*eye[b, j] + eye[a, j]*eye[b, i] - 2*eye[a, b]*eye[i, j]/3


# --- spin-2 polarisations, real orthonormal (as checks/_projection_2pp.py)
pol = []
pol.append(sp.diag(1, -1, 0)/sp.sqrt(2))
pol.append(sp.diag(-1, -1, 2)/sp.sqrt(6))
for a, b in ((0, 1), (0, 2), (1, 2)):
    t = sp.zeros(3, 3); t[a, b] = t[b, a] = 1/sp.sqrt(2); pol.append(t)

VV = [(a, b) for a in range(3) for b in range(3)]


def proj2(ch, v):
    """dict spin-index -> list over M of complex amplitude."""
    Qv = Q(v)
    out = {}
    if ch == 1:
        for a, b in VV:
            out[(a, b)] = [sum(S(a, b, i, j)/2*T[i, j] for i in range(3) for j in range(3)) for T in pol]
    elif ch == 2:
        for a, b in VV:
            out[(a, b)] = [-sp.sqrt(sp.Rational(5, 2))*eye[a, b]*sum(Qv[i, j]*T[i, j] for i in range(3) for j in range(3)) for T in pol]
    elif ch == 3:
        for a, b in VV:
            def P(i, j):
                return (sum(S(a, b, i, k)*Qv[k, j] + S(a, b, j, k)*Qv[k, i] for k in range(3))
                        - sp.Rational(2, 3)*eye[i, j]*sum(S(a, b, k, l)*Qv[k, l] for k in range(3) for l in range(3)))
            out[(a, b)] = [-sp.sqrt(sp.Rational(45, 56))*sum(P(i, j)*T[i, j] for i in range(3) for j in range(3)) for T in pol]
    elif ch == 4:
        G = {}
        for idx in it.product(range(3), repeat=4):
            G[idx] = v4(v, *idx)
        for a, b in VV:
            out[(a, b)] = [sp.sqrt(sp.Rational(175, 32))*sum(S(a, b, k, l)*G[(i, j, k, l)]*T[i, j]
                           for i, j, k, l in it.product(range(3), repeat=4)) for T in pol]
    elif ch == 5:
        for k in range(3):
            out[k] = [-I*sp.sqrt(5)/2*sum((eps(i, k, l)*Qv[l, j] + eps(j, k, l)*Qv[l, i])*T[i, j]
                      for i in range(3) for j in range(3) for l in range(3)) for T in pol]
    elif ch == 6:
        out[()] = [-sp.sqrt(sp.Rational(15, 2))*sum(Qv[i, j]*T[i, j] for i in range(3) for j in range(3)) for T in pol]
    return out


SPECIES2 = {1: 'VV', 2: 'VV', 3: 'VV', 4: 'VV', 5: 'PV', 6: 'PP'}


def N(so, si, o, i):
    """isospin-free spin numerator; o,i spin indices."""
    if so == 'PV' and si == 'PV':
        return -q[o]*q[i]
    if so == 'VV' and si == 'PV':
        a, b = o; c = i
        return I/sp.sqrt(2)*(R[a, c]*q[b] + R[b, c]*q[a])
    if so == 'PV' and si == 'VV':
        return sp.conjugate(N('VV', 'PV', i, o))
    if so == 'VV' and si == 'VV':
        a, b = o; c, d = i
        return R[a, c]*R[b, d]
    if so == 'VV' and si == 'PP':
        a, b = o
        return q[a]*q[b]
    if so == 'PP' and si == 'VV':
        c, d = i
        return q[c]*q[d]
    return 0


def T(Pout, Pin, so, si, nJ):
    total = 0
    for o, ao in Pout.items():
        for i_, ai in Pin.items():
            nn = N(so, si, o, i_)
            if nn == 0:
                continue
            total += nn*sum(sp.conjugate(ao[M])*ai[M] for M in range(nJ))
    total = sp.expand(total/nJ)
    poly = sp.Poly(total, s)
    out = 0
    for (k,), coeff in poly.terms():
        if k % 2:
            assert sp.simplify(coeff) == 0, ('odd s power', k, coeff)
            continue
        out += coeff*(1 - x**2)**(k//2)
    return sp.expand(out)


def table2():
    Pn = {c: proj2(c, n) for c in range(1, 7)}
    Pm = {c: proj2(c, m) for c in range(1, 7)}
    res = {}
    for a in range(1, 7):
        for b in range(a, 7):
            t = T(Pm[a], Pn[b], SPECIES2[a], SPECIES2[b], 5)
            c = sp.expand(-t)
            res[(a, b)] = c
    return res


def proj1(ch, v):
    """Zhang:2026iyr v1 Eq. (D1) projectors, J=1 polarisations e_i."""
    Qv = Q(v)
    out = {}
    if ch == 1:
        for a in range(3):
            out[a] = [eye[a, i] for i in range(3)]
    elif ch == 2:
        for a in range(3):
            out[a] = [-3/sp.sqrt(2)*Qv[a, i] for i in range(3)]
    else:
        for a, b in VV:
            out[(a, b)] = [-sp.sqrt(3)/2*I*sum(eps(i, a, k)*Qv[k, b] + eps(i, b, k)*Qv[k, a]
                           for k in range(3)) for i in range(3)]
    return out


def coefficients(c, order):
    poly = sp.Poly(c, x)
    return [sp.factor(poly.coeff_monomial(x**k)) for k in range(order + 1)]


# Note 03, Sec. 3 table (r=p' outgoing, p incoming), upper triangle; the
# lower triangle is the transposition rule c_ba(r,p)=c_ab(p,r).
NOTE03 = {
    (1, 1): (p**2 + r**2)/3 - 2*p*r*x/3,
    (1, 2): sp.sqrt(2)*(-2*p**2 + r**2)/6 + 2*sp.sqrt(2)*p*r*x/3 - sp.sqrt(2)*r**2*x**2/2,
    (1, 3): sp.sqrt(6)*(2*p**2 - r**2)/6 - 2*sp.sqrt(6)*p*r*x/3 + sp.sqrt(6)*r**2*x**2/2,
    (2, 2): -(p**2 + r**2)/3 + p*r*x/6 + (p**2 + r**2)*x**2 - 3*p*r*x**3/2,
    (2, 3): -sp.sqrt(3)*(p**2 + r**2)/6 - sp.sqrt(3)*p*r*x/6 + sp.sqrt(3)*(p**2 + r**2)*x**2/2
            - sp.sqrt(3)*p*r*x**3/2,
    (3, 3): p*r*x/2 - p*r*x**3/2,
}
# 9j/6j rotations from literature/Bruschini:2023zkb/bridge.md (U_2, U_1), rows
# (s_H,s_l,j_l,L); V_H = U V U^T. Independent of the Cartesian projectors.
S5, S3 = sp.sqrt(5), sp.sqrt(3)
U2 = sp.Matrix([[1, 0, 0, 0, 0, 0],
                [0, -S5/10, sp.sqrt(35)/10, 0, 3*S5/10, sp.sqrt(15)/10],
                [0, S3/6, sp.sqrt(21)/6, 0, -S3/6, -sp.Rational(1, 2)],
                [0, -sp.sqrt(105)/30, sp.sqrt(15)/15, 0, -sp.sqrt(105)/15, sp.sqrt(35)/10],
                [0, 0, 0, 1, 0, 0],
                [0, S3/2, 0, 0, 0, sp.Rational(1, 2)]])
U1 = sp.Matrix([[1, 0, 0], [0, -sp.Rational(1, 2), S3/2], [0, S3/2, sp.Rational(1, 2)]])
BLOCK = (0, 0, 1, 2, 2, 3)   # (s_H,j_l) = (1,1),(1,1),(1,2),(1,3),(1,3),(0,2)


def full(table, size):
    """Upper triangle -> full matrix by the transposition rule."""
    c = sp.zeros(size, size)
    for (a, b), value in table.items():
        c[a-1, b-1] = value
        c[b-1, a-1] = value.subs({p: r, r: p}, simultaneous=True)
    return c


if __name__ == '__main__':
    species1 = {1: 'PV', 2: 'PV', 3: 'VV'}
    print('1++ (D1), rows outgoing')
    c1 = sp.zeros(3, 3)
    for a in range(1, 4):
        for b in range(1, 4):
            c = sp.expand(-T(proj1(a, m), proj1(b, n), species1[a], species1[b], 3))
            c1[a-1, b-1] = c
            print(f'{a}{b}', coefficients(c, 3), flush=True)
    assert sp.expand(c1 - full(NOTE03, 3)) == sp.zeros(3, 3), 'note 03 table not reproduced'
    print('ASSERT 1++ contraction reproduces every note-03 coefficient')
    print('2++ (Baru:2019xnh v2 App. B), upper triangle')
    table = table2()
    for (a, b), c in table.items():
        print(f'{a}{b}', coefficients(c, 5), flush=True)
    # Strict HQSS: every D sum is 2D, so V is proportional to c.
    h2 = sp.expand(U2*full(table, 6)*U2.T)
    h1 = sp.expand(U1*c1*U1.T)
    for i in range(6):
        for j in range(6):
            if BLOCK[i] != BLOCK[j]:
                assert h2[i, j] == 0, ('2++ HQSS block mixing', i, j, h2[i, j])
    assert sp.expand(h2[:2, :2] - h1[:2, :2]) == sp.zeros(2, 2), '2++/1++ j_l=1 blocks differ'
    print('ASSERT U_2 c U_2^T is block diagonal in (s_H,j_l); its (1,1) block equals 1++')
