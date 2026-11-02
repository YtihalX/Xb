# /// script
# requires-python = ">=3.12"
# dependencies = ["mpmath>=1.3"]
# ///
"""Draft: the App. D example of Wu:2026wxb v1 on every contour, both sheets; prescriptions unfilled.

Seam: J(p;m) = int_C q dq/(p^2-q^2) [l_-(q) - l_+(q)], Wu:2026wxb v1, Eq. (D2),
with w_pm = (q pm p)^2 + m^2 and l_pm the continued logs of Eq. (D1).
Route: Cauchy's theorem. Each contour that App. D gives for a case, with the
term App. D adds to it, must return the same number; so must each mirrored
contour for p in the fourth quadrant (sheet (-) of CONVENTIONS.md "Pole position
and Riemann sheets"), with the terms pending in NOTEBOOK.md, Open questions, Kernel continuation.
The reference on each sheet is the deformed contour that crosses no cut
(C_R, or its mirror Cbar_R), on which the principal logs are the continued ones.
Expected: for each p, every contour agrees with the reference to 1e-6 relative
(NOTEBOOK.md, Open questions, Tolerances need your decision). Cases follow App. D, Fig. 11: (a) 0 < |Im p| < m;
(b) |Im p| > m; (c)/(d) |Im p| > m with Re p near 0.
Bridge: literature/Wu:2026wxb/bridge.md.
Run: uv run --script checks/appd_contours.py
"""
import mpmath as mp

mp.mp.dps = 20
M = mp.mpf("0.138039407")  # exchange mass m = m_pi in GeV (GLOSSARY.md "Isospin limit")
TOLERANCE = mp.mpf("1e-6")
POINTS = {  # case -> on-shell momenta p in GeV; sheet (+) above, (-) below
    "a": [mp.mpc("0.30", "0.08"), mp.mpc("0.12", "0.05")],
    "b": [mp.mpc("0.30", "0.20"), mp.mpc("0.55", "0.40")],
    "c": [mp.mpc("0.02", "0.20"), mp.mpc("0.01", "0.35")],
}


# --- input: contour prescriptions unfilled; NOTEBOOK.md, Open questions, Kernel continuation ---
PRESCRIPTIONS = None
# --- end input ---


def path_integral(f, nodes, splits):
    """int f dq along the polygon through `nodes`, split where Re q or Im q hits a split value."""
    total = mp.mpc(0)
    for a, b in zip(nodes[:-1], nodes[1:]):
        ts = [mp.mpf(0), mp.mpf(1)]
        d = b - a
        for kind, value in splits:
            comp = mp.re(d) if kind == "re" else mp.im(d)
            start = mp.re(a) if kind == "re" else mp.im(a)
            if comp != 0:
                t = (value - start) / comp
                if 0 < t < 1:
                    ts.append(t)
        ts.sort()
        for t0, t1 in zip(ts[:-1], ts[1:]):
            total += mp.quad(lambda t: f(a + d * t) * d, [t0, t1])
    return total


def ray_integral(f, start, splits):
    """int f dq from `start` to start + infinity along a horizontal line."""
    y = mp.im(start)
    xs = sorted({mp.re(start)} | {v for k, v in splits if k == "re" and v > mp.re(start)})
    total = mp.mpc(0)
    for x0, x1 in zip(xs[:-1], xs[1:]):
        total += mp.quad(lambda x: f(x + 1j * y), [x0, x1])
    return total + mp.quad(lambda x: f(x + 1j * y), [xs[-1], xs[-1] + 1, mp.inf])


def arc_integral(f, centre, radius, theta0, theta1):
    """int f dq along centre + radius e^{i theta}, theta from theta0 to theta1."""
    return mp.quad(lambda t: f(centre + radius * mp.expj(t)) * 1j * radius * mp.expj(t),
                   [theta0, theta1])


def propagator(p):
    return lambda q: q / (p**2 - q**2)


def contour_values(p, prescriptions):
    """Every contour of App. D (or its mirror) applicable to p, as {label: J}."""
    m = M
    a, b = mp.re(p), mp.im(p)
    log_difference = prescriptions["log_difference"]
    ell_plus_leftward = prescriptions["ell_plus_leftward"]
    terms = prescriptions["terms"]
    f = lambda q: propagator(p)(q) * log_difference(q, p, m)
    f_left = lambda q: propagator(p)(q) * (mp.log((q - p)**2 + m**2) - ell_plus_leftward(q, p, m))
    splits = [("re", a), ("re", -a)]
    values = {}
    if b > 0:
        h = (max(b - m, 0) + b) / 2  # C_R: Im p - m < h < Im p
        values["C_R"] = path_integral(f, [mp.mpc(0), 1j * h], splits) + ray_integral(f, 1j * h, splits)
        real_axis = ray_integral(f, mp.mpc(0), splits)
        if b < m:
            values["C_R0"] = real_axis + terms["C_R0"](p, m)
        else:
            values["C_R'"] = real_axis + terms["C_R'"](p, m)
            r = a + mp.mpf("0.4")
            values["C_L"] = (path_integral(f, [mp.mpc(0), -r, -r + 1j * h], splits)
                             + ray_integral(f, -r + 1j * h, splits) + terms["C_L"](p, m, r, h))
            radius = h / 2  # left semicircle from 0 to i h, then the horizontal ray
            values["C_L'"] = (arc_integral(f_left, 1j * radius, radius, -mp.pi / 2, -3 * mp.pi / 2)
                              + ray_integral(f_left, 1j * h, splits))
    else:
        h = (-b + (-b + m)) / 2  # Cbar_R: |Im p| < h < |Im p| + m
        values["Cbar_R"] = path_integral(f, [mp.mpc(0), -1j * h], splits) + ray_integral(f, -1j * h, splits)
        real_axis = ray_integral(f, mp.mpc(0), splits)
        if -b < m:
            values["Cbar_R0"] = real_axis + terms["Cbar_R0"](p, m)
        else:
            values["Cbar_R'"] = real_axis + terms["Cbar_R'"](p, m)
            r = a + mp.mpf("0.4")
            values["Cbar_L"] = (path_integral(f, [mp.mpc(0), -r, -r - 1j * h], splits)
                                + ray_integral(f, -r - 1j * h, splits) + terms["Cbar_L"](p, m, r, h))
            radius = h / 2  # left semicircle from 0 to -i h, then the horizontal ray
            values["Cbar_L'"] = (arc_integral(f_left, -1j * radius, radius, mp.pi / 2, 3 * mp.pi / 2)
                                 + ray_integral(f_left, -1j * h, splits))
    return values


def main():
    if PRESCRIPTIONS is None:
        print("FAIL App. D contours: no contour prescriptions yet (NOTEBOOK.md, Open questions, Kernel continuation)")
        raise SystemExit(1)
    failed = False
    for case, momenta in POINTS.items():
        for p0 in momenta:
            for sheet, p in (("(+)", p0), ("(-)", mp.conj(p0))):
                values = contour_values(p, PRESCRIPTIONS)
                label0 = "C_R" if sheet == "(+)" else "Cbar_R"
                reference = values[label0]
                for label, value in values.items():
                    if label == label0:
                        continue
                    deviation = abs(value - reference) / abs(reference)
                    ok = deviation <= TOLERANCE
                    failed |= not ok
                    print("PASS" if ok else "FAIL", f"case ({case}) sheet {sheet} p={mp.nstr(p, 6)}:",
                          f"{label} vs {label0} relative deviation {mp.nstr(deviation, 3)}",
                          f"[{label0} = {mp.nstr(reference, 12)}]")
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
