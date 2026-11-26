# /// script
# requires-python = ">=3.12"
# dependencies = ["sympy>=1.13"]
# ///
"""Generate code/xb2c/src/tables.h, the projected spin numerators of the OME kernel.

2++: the existing generator, checks/_spin_numerator.py (Baru v2 App. B projectors in
the canonical phases), traces every directed entry itself; its channel i is channel
(3,4,5,6,2,1)_i of the current order (CONVENTIONS.md, "2++ channel basis and
projectors").
1++: the same spin numerator N with the Eq. (D1) projectors of checks/_projection.py,
asserted equal to the printed entries [@Zhang:2026iyr] v1, Eqs. (D2)-(D10) (Xb.tex,
App. D). The upstream HadronDynamics checkout (91ee258) prints V_13 and V_23 with the
opposite sign, i.e. the opposite 5D1 phase; CONVENTIONS.md keeps the printed D1 phase.

Each entry is written as c_{a'a,m} = -N^{(m)}_{a'a}/(2J+1), the coefficients of
p'^2, p'q and q^2 (p' outgoing, q incoming), so that
V_{a'a}(p',q) = -(g_b^2/(8F_pi^2)) sum_m c_{a'a,m} Delta_m, Delta_m = M_m(nu_b1)+M_m(nu_b2),
with the time orderings (b1,b2) of note 07, S2, written beside each entry.

Run from the repository root: uv run --script code/xb2c/gen/spin_tables.py
"""
import importlib.util
import itertools as it
from pathlib import Path

import sympy as sp

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('spin', ROOT / 'checks/_spin_numerator.py')
spin = importlib.util.module_from_spec(spec)
spec.loader.exec_module(spin)
p, r, x, n, m, eye, I = spin.p, spin.r, spin.x, spin.n, spin.m, spin.eye, spin.I

# Time orderings of each species block, outgoing first (note 07, S2).
ORDERINGS = {('VV', 'VV'): (2, 2), ('PV', 'PV'): (1, 2), ('VV', 'PV'): (2, 3),
             ('PV', 'VV'): (2, 4), ('VV', 'PP'): (3, 3), ('PP', 'VV'): (4, 4)}


def proj1(ch, v):
    """Eq. (D1) projectors, as checks/_projection.py, projectors_1pp."""
    t = spin.Q(v)
    if ch == 1:
        return {a: [eye[a, k] for k in range(3)] for a in range(3)}
    if ch == 2:
        return {a: [-3/sp.sqrt(2)*(v[a]*v[k] - eye[a, k]/3) for k in range(3)] for a in range(3)}
    return {(a, b): [-sp.sqrt(3)/2*I*sum(spin.eps(k, a, l)*t[l, b] + spin.eps(k, b, l)*t[l, a]
                                          for l in range(3)) for k in range(3)]
            for a, b in spin.VV}


SPECIES1 = {1: 'PV', 2: 'PV', 3: 'VV'}


def trace1(a, b):
    out, inc = proj1(a, m), proj1(b, n)
    return spin.reduce_transverse(sp.expand(sum(
        spin.N(SPECIES1[a], SPECIES1[b], o, i)*sum(sp.conjugate(ao[k])*ai[k] for k in range(3))
        for o, ao in out.items() for i, ai in inc.items())))


# Coefficients (x^0..x^3) of the printed 1++ entries, Eqs. (D2)-(D10), written as
# V = -(g_b^2/(8F_pi^2)) sum_m c_m Delta_m; p incoming, r = p' outgoing.
def printed1(a, b):
    if b < a:
        return [sp.sympify(e).subs({p: r, r: p}, simultaneous=True) for e in printed1(b, a)]
    if (a, b) == (1, 1):
        return [(p**2 + r**2)/3, -2*p*r/3, 0, 0]
    if (a, b) == (1, 2):
        return [(r**2 - 2*p**2)/(3*sp.sqrt(2)), 4*p*r/(3*sp.sqrt(2)), -r**2/sp.sqrt(2), 0]
    if (a, b) == (1, 3):
        return [(2*p**2 - r**2)/sp.sqrt(6), -4*p*r/sp.sqrt(6), 3*r**2/sp.sqrt(6), 0]
    if (a, b) == (2, 2):
        return [-(p**2 + r**2)/3, p*r/6, p**2 + r**2, -3*p*r/2]
    if (a, b) == (2, 3):
        return [-(p**2 + r**2)/(2*sp.sqrt(3)), -p*r/(2*sp.sqrt(3)),
                3*(p**2 + r**2)/(2*sp.sqrt(3)), -3*p*r/(2*sp.sqrt(3))]
    return [0, p*r/2, 0, -p*r/2]


def monomials(c):
    """Coefficients of p'^2 (r^2), p'q (r p), q^2 (p^2) of a homogeneous quadratic."""
    poly = sp.Poly(sp.expand(c), r, p)
    assert all(sum(mon) == 2 for mon in poly.monoms()) or poly.is_zero, c
    return [poly.coeff_monomial(r**2), poly.coeff_monomial(r*p), poly.coeff_monomial(p**2)]


def table(trace, species, size, J):
    rows = {}
    for a, b in it.product(range(1, size + 1), repeat=2):
        poly = sp.expand(trace(a, b))
        assert sp.Poly(poly, x).degree() <= 4
        c = [sp.expand(-poly.coeff(x, k)/(2*J + 1)) for k in range(5)]
        pair = ORDERINGS.get((species[a], species[b]), (0, 0))
        assert pair != (0, 0) or all(e == 0 for e in c), (a, b)
        rows[a, b] = ([monomials(e) for e in c], pair)
    return rows


def main():
    one = table(trace1, SPECIES1, 3, 1)
    for (a, b), (coefficients, _) in one.items():
        printed = printed1(a, b)
        for k in range(5):
            expected = printed[k] if k < 4 else 0
            got = sum(coefficients[k][j]*mono for j, mono in enumerate((r**2, r*p, p**2)))
            assert sp.simplify(got - expected) == 0, (a, b, k, got, expected)

    current = (3, 4, 5, 6, 2, 1)          # generator channel i is current channel current[i-1]
    species2 = {current[i - 1]: s for i, s in spin.SPECIES2.items()}
    old = {current[i - 1]: i for i in range(1, 7)}
    incoming = {i: spin.proj2(i, n) for i in range(1, 7)}
    outgoing = {i: spin.proj2(i, m) for i in range(1, 7)}
    two = table(lambda a, b: spin.reduce_transverse(
        spin.trace(outgoing[old[a]], incoming[old[b]], old[a], old[b])), species2, 6, 2)
    for (a, b), (_, pair) in two.items():
        oa, ob = old[a], old[b]
        if oa <= ob:
            expected = spin.offset_pair(oa, ob)
            assert (sorted(pair) == sorted(expected)) if expected else pair == (0, 0), (a, b)

    def number(v):
        return f'{float(sp.N(v, 30))!r}'

    c_lines = ['/* Generated by code/xb2c/gen/spin_tables.py; do not edit.',
               ' * Projected spin numerators c[a\'][a][m][k], k = p\'^2, p\'q, q^2 (p\' outgoing),',
               ' * and the time orderings {b1, b2} of each entry, 0 for no exchange.',
               ' * V_{a\'a}(p\',q) = -(g_b^2/(8F_pi^2)) sum_m c_{a\'a,m} [M_m(nu_b1) + M_m(nu_b2)]. */',
               '#pragma once', '']
    zig_lines = ['//! Generated by code/xb2c/gen/spin_tables.py; do not edit. The spin numerators of',
                 '//! src/tables.h for the tests: spin[a\'][a][m][k], k = p\'^2, p\'q, q^2 (p\' outgoing).', '']
    for name, rows, size in (('1pp', one, 3), ('2pp', two, 6)):
        c_lines.append(f'static constexpr double xb_spin_{name}[{size}][{size}][5][3] = {{')
        zig_lines.append(f'pub const spin_{name} = [{size}][{size}][5][3]f64{{')
        for a in range(1, size + 1):
            c_lines.append('    {')
            zig_lines.append('    .{')
            for b in range(1, size + 1):
                monos = [', '.join(number(v) for v in mono) for mono in rows[a, b][0]]
                c_lines.append('        {' + ', '.join('{' + m + '}' for m in monos) + '},')
                zig_lines.append('        .{ ' + ', '.join('.{ ' + m + ' }' for m in monos) + ' },')
            c_lines.append('    },')
            zig_lines.append('    },')
        c_lines += ['};', f'static constexpr int xb_order_{name}[{size}][{size}][2] = {{']
        for a in range(1, size + 1):
            c_lines.append('    {' + ', '.join('{%d, %d}' % rows[a, b][1] for b in range(1, size + 1)) + '},')
        c_lines += ['};', '']
        zig_lines += ['};', '']
    (ROOT / 'code/xb2c/src/tables.h').write_text('\n'.join(c_lines))
    (ROOT / 'code/xb2c/test/tables.zig').write_text('\n'.join(zig_lines))


if __name__ == '__main__':
    main()
