# /// script
# requires-python = ">=3.12"
# dependencies = ["sympy>=1.13"]
# ///
"""Exact Cartesian spin trace: Baru v2 App. B, bridged canonical phases.

Self-contained derivation, not a package-source parser. p incoming, r=p'
 outgoing. Five real orthonormal spin-2 polarisations implement the trace.
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


def reduce_transverse(expr, transverse=s):
    """Impose the outgoing unit vector after the exact Cartesian trace."""
    result = 0
    for (power,), coefficient in sp.Poly(sp.expand(expr), transverse).terms():
        if power % 2:
            assert sp.simplify(coefficient) == 0, 'odd transverse power'
        else:
            result += coefficient*(1-x*x)**(power//2)
    return sp.expand(result)


def trace(outgoing, incoming, a, b):
    return sp.expand(sum(
        N(SPECIES2[a], SPECIES2[b], o, i)
        * sum(sp.conjugate(ao[k])*ai[k] for k in range(5))
        for o, ao in outgoing.items() for i, ai in incoming.items()))


def offset_pair(a, b):
    if a <= 4 and b <= 4:
        return (2, 2)
    if a <= 4 and b == 5:
        return (3, 2)
    if a <= 4 and b == 6:
        return (3, 3)
    return (1, 2) if a == b == 5 else ()


from functools import cache


@cache
def entries():
    """All 21 independent entries; coefficients ordered x^0,...,x^4.

    The empty pair means no OME diagram (56 and 66), not a new propagator.
    Exact azimuthal invariance is established by the rotation generator
    u*d/dv-v*d/du before restricting n' to (s,0,x).
    """
    global m, q, R
    incoming = {a: proj2(a, n) for a in range(1, 7)}
    outgoing = {a: proj2(a, m) for a in range(1, 7)}
    result = {}
    for a in range(1, 7):
        for b in range(a, 7):
            polynomial = reduce_transverse(trace(outgoing[a], incoming[b], a, b))
            reverse = reduce_transverse(trace(outgoing[b], incoming[a], b, a))
            assert sp.expand(polynomial-reverse.subs({p:r, r:p}, simultaneous=True)) == 0
            result[a,b] = dict(polynomial=polynomial, offsets=offset_pair(a,b),
                coefficients=tuple(sp.factor(polynomial.coeff(x,k)) for k in range(5)))
            assert sp.Poly(polynomial, x).degree() <= 4
    saved = m, q, R
    try:
        u, v = sp.symbols('u v', real=True)
        m = sp.Matrix([u,v,x]); q = p*n-r*m
        R = sp.Matrix(3,3,lambda a,c: sum(eps(c,a,k)*q[k] for k in range(3)))
        general = {a:proj2(a,m) for a in range(1,7)}
        for a,b in result:
            value = trace(general[a],incoming[b],a,b)
            assert sp.expand(u*sp.diff(value,v)-v*sp.diff(value,u)) == 0
    finally:
        m, q, R = saved
    return result


def tex(value):
    return sp.latex(value, symbol_names={r:"p'"}).replace(r'\left', '').replace(r'\right', '')


def latex_table(rows=None):
    rows = entries() if rows is None else rows
    lines = [
        '% Generated by: uv run --script checks/_spin_numerator.py --write paper/tables/projected-spin-numerator-2pp.tex',
        r'\begin{table*}[t]',
        r'\caption{Projected spin numerator for the $2^{++}$ channels in their canonical order. Rows are outgoing first; $p$ is incoming and $p^\prime$ outgoing. An empty offset pair denotes an absent OME diagram.}',
        r'\label{tab:projected-spin-numerator-2pp}',
        r'\centering',
        r'\begingroup\footnotesize',
        r'\setlength{\tabcolsep}{3pt}',
        r'\renewcommand{\arraystretch}{1.7}',
        r'\begin{tabular}{cc|ccccc}',
        r'$\alpha^\prime\alpha$ & $(\beta_1,\beta_2)$ & $\mathcal N^{(0)}$ & $\mathcal N^{(1)}$ & $\mathcal N^{(2)}$ & $\mathcal N^{(3)}$ & $\mathcal N^{(4)}$ \\ \hline']
    for (a,b), row in rows.items():
        pair = '('+','.join(map(str,row['offsets']))+')' if row['offsets'] else r'\varnothing'
        lines.append(f'${a}{b}$ & ${pair}$ & '+' & '.join('$'+tex(c)+'$' for c in row['coefficients'])+r' \\')
    return '\n'.join(lines+[r'\end{tabular}',r'\endgroup',r'\end{table*}',''])


NUMERATORS = {
    ('VV','VV'): r'-2(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol A_2\cdot\boldsymbol q)',
    ('VV','PV'): r'(\boldsymbol A_1\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)+(\boldsymbol A_2\cdot\boldsymbol q)(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)',
    ('VV','PP'): r'(\boldsymbol\epsilon_1^{\prime *}\cdot\boldsymbol q)(\boldsymbol\epsilon_2^{\prime *}\cdot\boldsymbol q)',
    ('PV','PV'): r'-(\boldsymbol\epsilon\cdot\boldsymbol q)(\boldsymbol\epsilon^{\prime *}\cdot\boldsymbol q)',
}


def steps_markdown():
    lines = ['# Exact projected spin numerator: 2++', '',
        'Pinned sources: Zhang:2026iyr v1 Eqs. (72)–(75), (80)–(81); Baru:2019xnh v2 App. B through its bridge. Canonical C-even PV phase. No isospin factors included.',
        '', r'$p^\prime=r$, $\hat n=\hat z$, $\hat n^\prime=(s,0,x)$, $s^2=1-x^2$. Columns of each projector matrix below are the five orthonormal real spin-2 polarisations; rows are Cartesian spin states (VV: 00,01,...,22; PV: 0,1,2; PP: scalar). The trace is the sum over all five columns, with no division by five.',
        '', r'Azimuthal invariance is exact: for $\hat n^\prime=(u,v,x)$, $(u\partial_v-v\partial_u)\operatorname{Tr}[P^\dagger\mathcal NP]=0$ for each entry before imposing the unit-vector constraint.',
        '', r'$\boldsymbol A=i(\boldsymbol\epsilon\times\boldsymbol\epsilon^{\prime *})/\sqrt2$. The split follows $q_iq_j=p^2\hat z_i\hat z_j-pp^\prime(\hat z_i\hat n_j^\prime+\hat n_i^\prime\hat z_j)+p^{\prime2}\hat n_i^\prime\hat n_j^\prime$.']
    for (a,b), row in entries().items():
        lines += ['', f'## Entry {a}{b}', '',
            '$'+SPECIES2[b]+r'\to '+SPECIES2[a]+r':\quad\mathcal N='+NUMERATORS.get((SPECIES2[a],SPECIES2[b]),'0')+'$.',
            '', '$P('+str(b)+r';\hat z)='+tex(sp.Matrix(list(proj2(b,n).values())))+'$.',
            '', '$P('+str(a)+r";\hat n^\prime)="+tex(sp.Matrix(list(proj2(a,m).values())))+'$.']
        polynomial = row['polynomial']
        for label, powers in [('p^2',(2,0)), ("pp^\\prime",(1,1)), ("p^{\\prime2}",(0,2))]:
            coefficient = sp.factor(polynomial.coeff(p,powers[0]).coeff(r,powers[1]))
            lines += ['', '$T_{'+label+'}='+tex(coefficient*p**powers[0]*r**powers[1])+'$.']
        lines += ['', r'$\mathcal N_{'+str(a)+str(b)+'}(x;p^\\prime,p)='+tex(polynomial)+'$.']
    return '\n'.join(lines)+'\n'


if __name__ == '__main__':
    import argparse
    from pathlib import Path
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', type=Path)
    parser.add_argument('--steps', type=Path)
    args = parser.parse_args()
    if args.write:
        args.write.write_text(latex_table())
    if args.steps:
        args.steps.write_text(steps_markdown())
