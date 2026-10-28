"""Projected OME potentials: 1^{++} check against Xb.tex App. D, then 2^{++}.

Run from inside code/:
    uv run --no-project --with numpy --with sympy python pwa.py
Prints the 2^{++} elements in LaTeX (App. D style) and, for porting, in the
convention of HadronDynamics.jl projection.jl (coefficients of x^0.. multiplying
-(g_b^2/(8 F_pi^2)) and the summed TOPT moments; r = p_out, p = p_in).
"""
import sympy as sp

from ome import CHANNELS_1PP, CHANNELS_2PP, latex_element, p, pp, project, swap_combo, swap_momenta

D = sp.symbols("D0:6")  # placeholders for Delta_m


def as_expr(coeffs):
    return sp.expand(sum(c * D[m] for m, c in coeffs.items()))


# ---------------------------------------------------------------- 1. 1++ versus App. D
print("== 1. J^PC = 1^{++}: projection with Eq. (D1) versus Eqs. (D2)-(D10)")
s2, s3, s6 = sp.sqrt(2), sp.sqrt(3), sp.sqrt(6)
paper = {  # (out, in): (expression in Delta_m, combination), Xb.tex App. D, p' = pp
    ("3S1", "3S1"): (sp.Rational(1, 24) * (2 * p * pp * D[1] - (p**2 + pp**2) * D[0]), (1, 2)),
    ("3S1", "3D1"): (1 / (24 * s2) * (3 * pp**2 * D[2] - 4 * p * pp * D[1] + (2 * p**2 - pp**2) * D[0]), (1, 2)),
    ("3S1", "5D1"): (-1 / (8 * s6) * (3 * pp**2 * D[2] - 4 * p * pp * D[1] + (2 * p**2 - pp**2) * D[0]), (2, 4)),
    ("3D1", "3D1"): (sp.Rational(1, 24) * (sp.Rational(9, 2) * p * pp * D[3] - 3 * (p**2 + pp**2) * D[2]
                                           - sp.Rational(1, 2) * p * pp * D[1] + (p**2 + pp**2) * D[0]), (1, 2)),
    ("3D1", "5D1"): (1 / (16 * s3) * (3 * p * pp * D[3] - 3 * (p**2 + pp**2) * D[2] + p * pp * D[1]
                                     + (p**2 + pp**2) * D[0]), (2, 4)),
    ("5D1", "5D1"): (-sp.Rational(1, 16) * p * pp * (D[1] - D[3]), (2, 2)),
}
for (o, i), (expr, combo) in list(paper.items()):  # time-reversed elements, Eqs. (D5),(D8),(D9)
    if o != i:
        paper[(i, o)] = (swap_momenta(expr), swap_combo(combo))
ok = True
for o in CHANNELS_1PP:
    for i in CHANNELS_1PP:
        coeffs, combo = project(o, i)
        expr, combo_p = paper[(o, i)]
        same = sp.simplify(as_expr(coeffs) - sp.expand(expr)) == 0 and tuple(sorted(combo)) == tuple(sorted(combo_p))
        ok &= same
        print(f"  V[{o:>3} <- {i:>3}]  combo {combo}  matches paper: {same}")
print("  all 1++ elements reproduced:", ok)

# ---------------------------------------------------------------- 2. 2++
print("\n== 2. J^PC = 2^{++}: channels", CHANNELS_2PP)
r_sym = sp.Symbol("r", positive=True)
# time reversal: V_{a'a}(p',p) = V_{aa'}(p,p') with D3 <-> D4
tr_ok = True
for o in CHANNELS_2PP:
    for i in CHANNELS_2PP:
        c1, k1 = project(o, i)
        c2, k2 = project(i, o)
        lhs = as_expr(c1)
        rhs = swap_momenta(as_expr(c2))
        same = sp.simplify(lhs - rhs) == 0 and (k1 is None and k2 is None or tuple(sorted(k1)) == swap_combo(k2))
        tr_ok &= same
print("  time reversal V_{a'a}(p',p) = V_{aa'}(p,p') (D3<->D4):", tr_ok)
for o in CHANNELS_2PP:
    for i in CHANNELS_2PP:
        if CHANNELS_2PP.index(i) < CHANNELS_2PP.index(o):
            continue
        coeffs, combo = project(o, i)
        print(f"\n  V[{o} <- {i}] =", latex_element(coeffs, combo) if coeffs else "0")


print("\n== 3. same, as coefficient tuples (x^0, ..., x^4) of HadronDynamics.jl tc_vphi, r = p_out, p = p_in")
print("   (multiply by -(g_b^2/(8F_pi^2)) * sum over the two TOPT denominators of int x^k/(2w(w+alpha)))")
for o in CHANNELS_2PP:
    for i in CHANNELS_2PP:
        coeffs, combo = project(o, i)
        if not coeffs:
            continue
        tup = [sp.factor(sp.expand(-8 * coeffs.get(m, 0)).subs(pp, r_sym)) for m in range(5)]
        print(f"  ({o:>4} <- {i:<4}) combo {combo}: (" + ", ".join(str(t) for t in tup) + ")")
