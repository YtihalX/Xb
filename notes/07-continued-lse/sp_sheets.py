# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8", "mpmath>=1.3"]
# ///
"""Sokhotski-Plemelj with the sheet as a sign, on a precalculated contour: where it works, and steep contours.
A plot of the note's formulas with numerical evidence; not a recorded check.

Rule tested. For Im E < 0 and a sheet sigma (one sign per channel), k_n = principal sqrt(2 mu_n (E - delta_n)).
A channel's pole needs an on-shell node with Sokhotski-Plemelj (SP) when the contour does not pass it on the side
sigma asks for: flipped channels (sigma: below k_n) always get a node; unflipped channels above their threshold
("hidden") get one when the contour runs through their pole. The closed form of the subtracted term carries the
sign: I = [Log((Lambda - k)/(Lambda + k)) +- i pi] / 2k, + for below (flipped), - for above (unflipped).
A node's on-shell kernel V(k_n, q) has fixed singular points: k_n +- i m and the three-body points beside them.
Up points (near k_n + i m, and near -k_n + i m) must lie above the contour, down points below it (the window).
Moving singular points (p', q both on the contour) stay off every graph path for exchange (S34); for three-body
points S35 needs slopes at most 1, so steeper contours are checked here by sampling.
Precalculated contour: a vertex at Re k_n for every node, at the depth min(|Im k_n|, Re k_n): the pole itself, or
the slope-1 line when the pole lies below it.

Figure sp_sheets.png:
  (a) E = delta_6 - 10i = -90.46 - 10i MeV (M = 2 m_B - 10i): k_6 on the slope-1 line; the window of the PP node (PP<-VV
      orderings, beta = 4); four contours, each for both sheets (-,+,+) and (+,+,+), which differ only in the sign.
  (b)-(d) maps of the energy plane for (-,+,+), (-,-,+), (-,-,-): where the real path with SP works, where the
      precalculated slope-<=1 contour works, where an up point lies below the slope-1 line (a steeper leg is needed).
  (e) tests at eight energies: App. D's J(k_n; m_pi) against its exact value (iπ Log(1 - 2ip/m) below the pole,
      plus iπ [l_-(p) - l_+(p)] above it), and the TOPT moment J = int q^2 dq G_n(q) M_0(nu_beta)(k_n, q) against an
      unsubtracted contour passing on the sheet's side of k_n inside the window; 20 digits, adaptive quadrature.
  (f) steep contours at E = -6 - 2i on (-,-,-), where the VV window lies below the slope-1 line: the depth of the
      VV vertex against the window, the moving exchange and three-body points, and App. D's J.
Run: uv run --script notes/07-continued-lse/sp_sheets.py        Units MeV; App. D's J in GeV, as in the check.
"""
import cmath
import sys
from pathlib import Path

import matplotlib
import mpmath as mp
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.colors import ListedColormap  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402
from matplotlib.patches import Patch, Rectangle  # noqa: E402

from _s40geom import *  # noqa: E402,F403

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "checks"))
import appd_contours as appd  # noqa: E402

OUT = Path(__file__).with_suffix("")
MPI = MPHI["pi"]
NAMES = ("VV", "PV", "PP")
MU = {n: mu for n, _, mu, _ in CH}
DELTA = {n: d for n, d, _, _ in CH}
IDX = {n: i for n, _, _, i in CH}
SHEETS = {"(-,+,+)": {"PP": True, "PV": False, "VV": False},
          "(-,-,+)": {"PP": True, "PV": True, "VV": False},
          "(-,-,-)": {"PP": True, "PV": True, "VV": True},
          "(+,+,+)": {"PP": False, "PV": False, "VV": False}}
UP, DOWN = ("up", "farup"), ("down", "fardown")


def kp(E, n):
    return complex(cmath.sqrt(2 * MU[n] * (E - DELTA[n])))


def nodes(E, flipped, real_path=False, force=()):
    return [n for n in NAMES
            if flipped[n] or n in force or (not real_path and E.real > DELTA[n])]


_cache = {}


def fixed_points(E, n, mesons=("pi", "eta")):
    """(channel, meson, kind, side, z): singular points in q of V(k_n, q; E), orderings with an n leg."""
    key = (E, n, mesons)
    if key in _cache:
        return _cache[key]
    k = kp(E, n)
    out = []
    for phi in mesons:
        m = MPHI[phi]
        refs = {"up": k + 1j * m, "down": k - 1j * m, "farup": -k + 1j * m, "fardown": -k - 1j * m}
        out += [(n, phi, "ex", s, z) for s, z in refs.items()]
        for beta in ONSHELL_BETAS[n]:
            for tau in (1, -1):
                r = three_body(np.array([k]), E, m, beta, tau).ravel()
                for z in r[~np.isnan(r)]:
                    s = min(refs, key=lambda key_: abs(z - refs[key_]))
                    out.append((n, phi, f"b{beta}", s, complex(z)))
    _cache[key] = out
    return out


def contour(E, flipped, depth=None, force=()):
    verts = []
    for n in nodes(E, flipped, force=force):
        k = kp(E, n)
        verts.append(complex(k.real, -(depth or {}).get(n, min(abs(k.imag), k.real))))
    verts.sort(key=lambda z: z.real)
    return [0j] + verts + [complex(LAM, 0.0)]


def height(V, x):
    for a, b in zip(V[:-1], V[1:]):
        if a.real <= x <= b.real:
            return a.imag + (x - a.real) * (b - a).imag / (b - a).real
    return 0.0


def window_ok(V, pts):
    for _, _, _, side, z in pts:
        if abs(z) < 1e-6:
            return False
        if not 0 < z.real < V[-1].real:
            continue
        h = height(V, z.real)
        if (side in UP and not z.imag > h) or (side in DOWN and not z.imag < h):
            return False
    return True


def max_slope(V):
    return max(abs((b - a).imag) / (b - a).real for a, b in zip(V[:-1], V[1:]))


def classify(E, flipped):
    """0: the real path with SP works; 1: the precalculated slope-<=1 contour works; 2: an up point lies below
    the slope-1 line, so no slope-<=1 contour works; 3: neither, other reason."""
    pts_real = [p for n in nodes(E, flipped, real_path=True) for p in fixed_points(E, n)]
    if window_ok([0j, complex(LAM, 0.0)], pts_real):
        return 0
    pts = [p for n in nodes(E, flipped) for p in fixed_points(E, n)]
    if any(p[3] in UP and 0 < p[4].real < LAM and p[4].imag <= -p[4].real for p in pts):
        return 2
    V = contour(E, flipped)
    return 1 if max_slope(V) <= 1 + 1e-12 and window_ok(V, pts) else 3


# ================================================================ integrals
def mp_path(f, V, pts=(), dps=20):
    with mp.workdps(dps):
        tot, err = mp.mpc(0), mp.mpf(0)
        for a, b in zip(V[:-1], V[1:]):
            A, B = mp.mpc(a.real, a.imag), mp.mpc(b.real, b.imag)
            d = B - A
            ts = {mp.mpf(0), mp.mpf(1)}
            for z in pts:
                t = mp.re((mp.mpc(z.real, z.imag) - A) * mp.conj(d)) / abs(d) ** 2
                if 0 < t < 1:
                    ts.add(t)
            v, e = mp.quad(lambda t: f(A + d * t) * d, sorted(ts), error=True)
            tot += v
            err += abs(e)
        return tot, err


def J_static(E, n, sign, V, dps=20):
    """App. D's J(p; m_pi), p = k_n, SP on V (MeV) plus the ray to infinity; relative error against the exact
    value on the side `sign`."""
    k = kp(E, n)
    with mp.workdps(dps):
        p, m = mp.mpc(k.real, k.imag) / 1000, mp.mpf(MPI) / 1000
        L = appd.split_logs(p, p, m)
        fp = p * L
        def g(q):
            den = p * p - q * q
            return (q * appd.split_logs(q, p, m) - fp) / den if den != 0 else mp.mpc(0)
        verts = [mp.mpc(v.real, v.imag) / 1000 for v in V]
        quad = appd.Quadrature()
        splits = [("re", mp.re(p))]
        s = -1 if sign == "below" else 1
        val = quad.path(g, verts, splits) + quad.ray(g, verts[-1], splits) + s * 1j * mp.pi * fp / (2 * p)
        exact = 1j * mp.pi * mp.log(1 - 2j * p / m) + (1j * mp.pi * L if sign == "above" else 0)
        return float(abs(val - exact) / abs(exact))


def J_static_direct(E, n, V, dps=20):
    """App. D's J without subtraction on V: the value on V's own side of k_n."""
    k = kp(E, n)
    with mp.workdps(dps):
        p, m = mp.mpc(k.real, k.imag) / 1000, mp.mpf(MPI) / 1000
        f = lambda q: q / (p * p - q * q) * appd.split_logs(q, p, m)  # noqa: E731
        verts = [mp.mpc(v.real, v.imag) / 1000 for v in V]
        quad = appd.Quadrature()
        return complex(quad.path(f, verts, [("re", mp.re(p))]) + quad.ray(f, verts[-1], [("re", mp.re(p))]))


def U_mp(k, q, E, beta, m):
    t, h, a = ORD[beta]
    nu = t + h * k * k + a * q * q - E
    return (mp.log(mp.sqrt(m * m + (k + q) ** 2) + nu) - mp.log(mp.sqrt(m * m + (k - q) ** 2) + nu)) / (2 * k * q)


def J_topt(E, n, beta, sign, V, subtract=True, dps=20):
    k, mu = kp(E, n), MU[n]
    pts = [k] + [p[4] for p in fixed_points(E, n, mesons=("pi",)) if p[3] in ("up", "down")]
    with mp.workdps(dps):
        km, Em, m = mp.mpc(k.real, k.imag), mp.mpc(E.real, E.imag), mp.mpf(MPI)
        if subtract:
            ukk = U_mp(km, km, Em, beta, m)
            def g(q):  # q = k_n is a node only at a vertex, where the tanh-sinh weight underflows
                den = q * q - km * km
                return 2 * mu * (q * q * U_mp(km, q, Em, beta, m) - km * km * ukk) / den if den != 0 else mp.mpc(0)
            val, err = mp_path(g, V, pts, dps)
            s = 1 if sign == "below" else -1
            val += 2 * mu * km * km * ukk * (mp.log((LAM - km) / (LAM + km)) + s * 1j * mp.pi) / (2 * km)
        else:
            val, err = mp_path(lambda q: 2 * mu * q * q * U_mp(km, q, Em, beta, m) / (q * q - km * km), V, pts, dps)
    return val, err


def ref_contour(k, sign, d=50.0):
    y = k.imag - d if sign == "below" else k.imag + d
    return [0j, complex(k.real, y), complex(2 * k.real, 0.0), complex(LAM, 0.0)]


# ================================================================ (b)-(d) maps
RE = np.arange(-110.0, 45.01, 1.0)
IM = -np.arange(0.5, 30.01, 1.0)
MAPS = {}
for name in ("(-,+,+)", "(-,-,+)", "(-,-,-)"):
    fl = SHEETS[name]
    MAPS[name] = np.array([[classify(complex(x, y), fl) for x in RE] for y in IM])
    c = MAPS[name]
    print(f"{name}: real path {np.mean(c == 0):.0%}, slope<=1 contour {np.mean(c == 1):.0%}, "
          f"steep needed {np.mean(c == 2):.0%}, other {np.mean(c == 3):.0%} of the grid")
    for lab, lo, hi in (("below 2m_B", -110, DELTA["PP"]), ("2m_B..m_B+m_B*", DELTA["PP"], DELTA["PV"]),
                        ("m_B+m_B*..2m_B*", DELTA["PV"], 0.0), ("above 2m_B*", 0.0, 46.0)):
        sel = (RE > lo) & (RE < hi)
        cc = c[:, sel]
        steep = RE[sel][(cc == 2).any(axis=0)]
        print(f"    {lab:16s}: steep needed at {steep.size} of {sel.sum()} Re E values"
              + (f" (Re E {steep.min():.0f} to {steep.max():.0f})" if steep.size else "")
              + f"; other failures {int((cc == 3).sum())}")
    lowest = {"(-,+,+)": "PP", "(-,-,+)": "PV", "(-,-,-)": "VV"}[name]  # highest flipped threshold
    for y in (-0.5, -10.5, -29.5):
        row = c[int(np.argmin(np.abs(IM - y)))]
        bad = RE[(row >= 2) & (RE < DELTA[lowest])]
        print(f"    Im E = {y:5.1f}: slope <= 1 suffices down to {DELTA[lowest] - (bad.max() + 1.0):.0f} MeV below "
              f"the {lowest} threshold" if bad.size else f"    Im E = {y:5.1f}: covered everywhere")

# ================================================================ (a) seam
ES = complex(DELTA["PP"], -10.0)
k6 = kp(ES, "PP")
SEAM = {"real path": [0j, complex(LAM, 0)],
        "gentle (slope 0.5)": contour(ES, SHEETS["(-,+,+)"], depth={"PP": 0.5 * k6.real}),
        "through $k_6$ (slope 1)": contour(ES, SHEETS["(-,+,+)"]),
        "steep (slope 1.5)": contour(ES, SHEETS["(-,+,+)"], depth={"PP": 1.5 * k6.real})}
pts6 = fixed_points(ES, "PP")
seam_err = {}
print(f"\nseam E = {ES}: k_6 = {k6:.2f}; slope-1 line at Re k_6: depth {k6.real:.1f}")
for lab, V in SEAM.items():
    ok = window_ok(V, pts6)
    eb, ea = J_static(ES, "PP", "below", V), J_static(ES, "PP", "above", V)
    seam_err[lab] = (ok, eb, ea)
    print(f"  {lab:24s}: window {'ok ' if ok else 'NO '} | App. D J, (-,+,+) below: {eb:.1e}, (+,+,+) above: {ea:.1e}")

# ================================================================ one fixed contour per search rectangle
def wrong_side(V, E, flipped, tol=1e-9):
    """Nodes D needs on a fixed contour: poles passed on the side the sheet does not ask for, or lying on it."""
    return [n for n in NAMES if path_dist(V, kp(E, n)) < tol or inside(V, kp(E, n)) != flipped[n]]


RECTS = [("(-,-,+)", (-46.5, -43.5), (-12, -8), "PV seam"), ("(-,-,+)", (-30, -15), (-10, -0.5), "X_b2 region"),
         ("(-,-,+)", (-3, 3), (-10, -2), "VV seam, hidden VV"), ("(-,-,-)", (-3, 3), (-10, -2), "VV seam, VV below"),
         ("(-,+,+)", (-93, -87), (-15, -5), "PP seam"), ("(-,-,+)", (-10, 0), (-30, -20), "wide, below VV")]
print("\none contour per rectangle, built at its centre; windows of the nodes D needs, on a 9 x 9 grid:")
for sh, (x0, x1), (y0, y1), lab in RECTS:
    fl = SHEETS[sh]
    V = contour(complex((x0 + x1) / 2, (y0 + y1) / 2), fl)
    bad, used = 0, set()
    for xx in np.linspace(x0, x1, 9):
        for yy in np.linspace(y0, y1, 9):
            E = complex(xx, yy)
            nn = wrong_side(V, E, fl)
            used |= set(nn)
            bad += not window_ok(V, [p for n in nn for p in fixed_points(E, n)])
    print(f"  {sh} {lab:20s} Re E {x0}..{x1}, Im E {y0}..{y1}: slope {max_slope(V):.2f}, nodes {sorted(used)}, "
          f"window failures {bad} of 81")

# ================================================================ (e) tests
TESTS = [("$-90.46-10i$\n$(-,+,+)$\nseam", ES, "PP", "below", 4, "(-,+,+)"),
         ("$-90.46-10i$\n$(+,+,+)$\nseam", ES, "PP", "above", 4, "(+,+,+)"),
         ("$-90.46-30i$\n$(-,+,+)$\nseam", complex(DELTA["PP"], -30.0), "PP", "below", 4, "(-,+,+)"),
         ("$-40-10i$\n$(-,+,+)$\nhidden PV", complex(-40.0, -10.0), "PV", "above", 1, "(-,+,+)"),
         ("$-22.6-10i$\n$(-,-,+)$\nadjacent", complex(-22.62, -10.0), "PV", "below", 1, "(-,-,+)"),
         ("$5-10i$\n$(-,-,+)$\nhidden VV", complex(5.0, -10.0), "VV", "above", 2, "(-,-,+)"),
         ("$-3-5i$\n$(-,-,-)$\nVV below", complex(-3.0, -5.0), "VV", "below", 2, "(-,-,-)"),
         ("$-6-2i$\n$(-,-,-)$\nVV below", complex(-6.0, -2.0), "VV", "below", 2, "(-,-,-)")]
print("\ntests (relative errors; TOPT against an unsubtracted contour on the sheet's side, inside the window):")
rows = []
for lab, E, n, sign, beta, sh in TESTS:
    fl = SHEETS[sh]
    V = contour(E, fl, force=(n,))
    pts = [p for c in nodes(E, fl, force=(n,)) for p in fixed_points(E, c)]
    k = kp(E, n)
    Vref = ref_contour(k, sign)
    ref_ok = window_ok(Vref, fixed_points(E, n))
    jref, eref = J_topt(E, n, beta, sign, Vref, subtract=False)
    jsp, esp = J_topt(E, n, beta, sign, V)
    rel = lambda a, b: float(abs(a - b) / abs(b))  # noqa: E731
    row = {"lab": lab, "cls": classify(E, fl), "win": window_ok(V, pts), "slope": max_slope(V),
           "static": J_static(E, n, sign, V), "topt": rel(jsp, jref),
           "real": J_static(E, n, sign, [0j, complex(LAM, 0)]), "ref_ok": ref_ok}
    if row["cls"] == 2:
        Vs = contour(E, fl, force=(n,), depth={n: abs(k.imag) - 0.5 * MPI + 25.0})
        row["steep_V"] = Vs
        row["steep_static"] = J_static(E, n, sign, Vs)
        js, _ = J_topt(E, n, beta, sign, Vs)
        row["steep_topt"] = rel(js, jref)
        row["steep_slope"] = max_slope(Vs)
    if sign == "above" and window_ok([0j, complex(LAM, 0)], fixed_points(E, n)):
        with mp.workdps(20):
            p, m = mp.mpc(k.real, k.imag) / 1000, mp.mpf(MPI) / 1000
            ex = complex(1j * mp.pi * mp.log(1 - 2j * p / m) + 1j * mp.pi * appd.split_logs(p, p, m))
        row["direct_above"] = abs(J_static_direct(E, n, [0j, complex(LAM, 0)]) - ex) / abs(ex)
    rows.append(row)
    extra = (f"; steep contour (slope {row['steep_slope']:.2f}): static {row['steep_static']:.1e}, "
             f"TOPT {row['steep_topt']:.1e}" if "steep_V" in row else "")
    extra += (f"; real axis unsubtracted vs the 'above' formula {row['direct_above']:.1e}"
              if "direct_above" in row else "")
    print(f"  {lab.replace(chr(10), ' '):38s} class {row['cls']}, window {row['win']}, slope {row['slope']:.2f}: "
          f"static {row['static']:.1e}, TOPT {row['topt']:.1e} (ref window {ref_ok}, quad err {float(eref):.0e}), "
          f"real path static {row['real']:.1e}{extra}")

# ================================================================ (f) steep contours at -6 - 2i on (-,-,-)
EF = complex(-6.0, -2.0)
flF = SHEETS["(-,-,-)"]
k1 = kp(EF, "VV")
ptsF = [p for c in nodes(EF, flF) for p in fixed_points(EF, c)]
DEP = np.concatenate([np.linspace(5, 60, 12), np.linspace(70, 330, 27)])
steep = {"slope": [], "win": [], "ex": [], "tb": [], "J": []}
for d in DEP:
    V = contour(EF, flF, depth={"VV": d})
    pp = sample(V, 4000)
    steep["slope"].append(max_slope(V))
    steep["win"].append(window_ok(V, ptsF))
    steep["ex"].append(min(path_dist_arr(V, exchanged(pp, m)).min() for m in MPHI.values()))
    tb = three_body_all(pp, EF)
    steep["tb"].append(path_dist_arr(V, tb).min() if tb.size else np.inf)
J_DEP = DEP[::3]
steep_J = [J_static(EF, "VV", "below", contour(EF, flF, depth={"VV": d}), dps=16) for d in J_DEP]
steep = {key: np.array(v) for key, v in steep.items()}
okw = DEP[steep["win"]]
print(f"\nsteep contours at E = {EF} on (-,-,-): k_1 = {k1:.1f}; window satisfied for VV vertex depth "
      f"{okw.min():.0f} to {okw.max():.0f} MeV (slopes {okw.min() / k1.real:.2f} to {okw.max() / k1.real:.2f})")
for d, s, w, ex, tb in zip(DEP, steep["slope"], steep["win"], steep["ex"], steep["tb"]):
    if d in (10, 30, 50, 70, 100, 150, 200, 250, 300, 330) or abs(d - 60) < 1e-9:
        print(f"  depth {d:5.0f} (slope {s:5.2f}): window {w}; moving exchange {ex:6.1f} MeV, three-body {tb:6.1f} MeV")
print("  App. D's J on the steep family: " + ", ".join(f"{d:.0f}: {e:.0e}" for d, e in zip(J_DEP, steep_J)))

# ================================================================ figure
fig = plt.figure(figsize=(22, 13.5))
gs = fig.add_gridspec(2, 3, height_ratios=(1, 1))
ax = fig.add_subplot(gs[0, 0])
ax.axhline(0, color="0.6", lw=0.8)
ax.axvline(0, color="0.8", lw=0.6)
ax.plot([0, 700], [0, -700], ":", color="0.4", lw=1.0)
up = [p[4] for p in pts6 if p[1] == "pi" and p[3] == "up" and p[4].real > 0]
dn = [p[4] for p in pts6 if p[1] == "pi" and p[3] == "down" and p[4].real > 0]
lo_w, hi_w = max(z.imag for z in dn), min(z.imag for z in up)
ax.add_patch(Rectangle((k6.real - 6, lo_w), 12, hi_w - lo_w, fc="#c7e9c0", ec="none", zorder=0))
ax.plot([k6.real] * 2, [hi_w, 220], ls=(0, (4, 3)), color="saddlebrown", lw=1.2)
ax.plot([k6.real] * 2, [lo_w, -420], ls=(0, (4, 3)), color="saddlebrown", lw=1.2)
cols = {"real path": "0.5", "gentle (slope 0.5)": "tab:green", "through $k_6$ (slope 1)": "darkgreen",
        "steep (slope 1.5)": "tab:purple"}
for lab, V in SEAM.items():
    ok, eb, ea = seam_err[lab]
    ax.plot([v.real for v in V], [v.imag for v in V], color=cols[lab], lw=2.0, ls="-" if ok else "--",
            label=f"{lab}: errors {eb:.0e} / {ea:.0e}")
ax.plot(k6.real, k6.imag, "o", ms=9, color="crimson", zorder=8)
ax.annotate("$k_6$ (PP): on the slope-1 line;\nthe same point on both sheets", (k6.real, k6.imag), xytext=(300, -120),
            fontsize=8.6, color="crimson", arrowprops=dict(arrowstyle="->", color="crimson", lw=0.8))
ax.plot([z.real for z in up + dn], [z.imag for z in up + dn], "P", ms=7, mfc="gold", mec="k", zorder=8)
ax.plot([k6.real] * 2, [k6.imag + MPI, k6.imag - MPI], "*", ms=12, mfc="gold", mec="k", zorder=9)
for n in ("PV", "VV"):
    z = kp(ES, n)
    ax.plot(z.real, z.imag, "o", ms=8, mfc="white", mec="navy", mew=2, zorder=8)
    ax.annotate(f"$-k_{IDX[n]}$ ({n}, unflipped)", (z.real, z.imag), xytext=(6, -12), textcoords="offset points",
                fontsize=8.4, color="navy")
ax.text(k6.real + 10, (lo_w + hi_w) / 2 - 60, "window of the\nPP node", fontsize=8.6, color="darkgreen")
ax.set_xlim(-30, 640)
ax.set_ylim(-420, 210)
ax.set_aspect("equal")
ax.set_xlabel("Re $q$ (MeV)")
ax.set_ylabel("Im $q$ (MeV)")
ax.legend(fontsize=8, loc="upper right", title="App. D's $J$: $(-,+,+)$ / $(+,+,+)$ relative error",
          title_fontsize=8)
ax.set_title("(a) $E=\\delta_6-10i=-90.46-10i$ MeV ($M=2m_B-10i$): the same contours serve both sheets;\n"
             "only the sign of $i\\pi$ differs "
             "(dashed: outside the window)", fontsize=10.5)

cmap = ListedColormap(["#d9f0d3", "#5aae61", "#fdb863", "#9970ab"])
for col, name in enumerate(("(-,+,+)", "(-,-,+)", "(-,-,-)")):
    ax = fig.add_subplot(gs[0, 1] if col == 0 else gs[0, 2] if col == 1 else gs[1, 0])
    ax.pcolormesh(RE, IM, MAPS[name], cmap=cmap, vmin=-0.5, vmax=3.5, shading="nearest")
    for d, lab in ((DELTA["PP"], "$2m_B$"), (DELTA["PV"], "$m_B+m_{B^*}$"), (0.0, "$2m_{B^*}$")):
        ax.axvline(d, color="k", lw=0.9, ls="--")
        ax.text(d, 0.6, lab, ha="center", fontsize=8.5)
    lo = {"(-,+,+)": DELTA["PP"], "(-,-,+)": DELTA["PV"], "(-,-,-)": 0.0}[name]
    hi = {"(-,+,+)": DELTA["PV"], "(-,-,+)": 0.0, "(-,-,-)": 45.0}[name]
    ax.annotate("", xy=(lo, -30.6), xytext=(hi, -30.6), arrowprops=dict(arrowstyle="<->", color="k", lw=1.2),
                annotation_clip=False)
    ax.text((lo + hi) / 2, -32.4, "adjacent (attached at Re $E$)", ha="center", fontsize=8.2, va="top")
    if name == "(-,-,-)":
        ax.plot(-0.894, 0, marker="v", ms=9, color="darkred", clip_on=False, zorder=9)
        ax.annotate("VV pion cut of the amplitude\nfrom $E=-0.89$ MeV (real axis)", (-0.894, 0), xytext=(-104, -9),
                    fontsize=8.2, color="darkred", arrowprops=dict(arrowstyle="->", color="darkred", lw=0.8))
    ax.plot(ES.real, ES.imag, "o", ms=6, mfc="white", mec="k") if name == "(-,+,+)" else None
    ax.set_xlim(RE[0] - 0.5, RE[-1] + 0.5)
    ax.set_ylim(IM[-1] - 0.5, 1.5)
    ax.set_xlabel("Re $E$ (MeV, from $2m_{B^*}$)")
    ax.set_ylabel("Im $E$ (MeV)")
    ax.set_title(f"({'bcd'[col]}) sheet {name}: where SP with sign labels works", fontsize=10.5)
handles = [Patch(fc="#d9f0d3", label="the real path with SP works"),
           Patch(fc="#5aae61", label="the precalculated contour (slopes $\\leq1$) works"),
           Patch(fc="#fdb863", label="an up point below the slope-1 line: needs a leg steeper than 1"),
           Patch(fc="#9970ab", label="other failure")]
fig.axes[1].legend(handles=handles, fontsize=8, loc="lower left")

ax = fig.add_subplot(gs[1, 1])
x = np.arange(len(rows))
clip = lambda v: max(v, 1e-21)  # noqa: E731
ax.semilogy(x - 0.12, [clip(r["static"]) for r in rows], "o", color="tab:green", ms=8,
            label="App. D's $J$, SP on the precalculated contour")
ax.semilogy(x + 0.12, [clip(r["topt"]) for r in rows], "D", color="tab:orange", ms=7,
            label="TOPT moment, SP on the precalculated contour")
ax.semilogy(x, [clip(r["real"]) for r in rows], "x", color="0.4", ms=8, mew=2, label="App. D's $J$, SP on the real path")
for i, r in enumerate(rows):
    if "steep_V" in r:
        ax.semilogy([i - 0.12], [clip(r["steep_static"])], "*", color="tab:purple", ms=14,
                    label=f"steeper VV leg (slope {r['steep_slope']:.1f}): App. D's $J$")
        ax.semilogy([i + 0.12], [clip(r["steep_topt"])], "*", mfc="none", mec="tab:purple", ms=14,
                    label="steeper VV leg: TOPT moment")
    if "direct_above" in r:
        ax.semilogy([i + 0.3], [clip(r["direct_above"])], "s", mfc="none", mec="k", ms=7,
                    label="unsubtracted real axis vs the 'above' formula" if i == 3 else None)
ax.axhspan(1e-21, 1e-17, color="0.93", zorder=0)
ax.text(len(rows) - 0.6, 3e-21, "20-digit working precision", fontsize=8, ha="right", color="0.4")
ax.set_xticks(x, [r["lab"] for r in rows], fontsize=7.4)
ax.set_ylim(1e-21, 30)
ax.set_ylabel("relative error")
ax.grid(alpha=0.3, which="both", axis="y")
ax.legend(fontsize=7.6, loc="center left")
ax.set_title("(e) SP with the sign of the sheet, eight energies (20 digits)", fontsize=10.5)

ax = fig.add_subplot(gs[1, 2])
sl = steep["slope"]
ax.axvspan(okw.min() / k1.real, okw.max() / k1.real, color="#c7e9c0", zorder=0)
ax.axvline(1.0, color="k", ls=":", lw=1)
ax.text(1.03, 255, "slope 1 (S35)", rotation=90, fontsize=8.2, va="top")
ax.semilogx(sl, steep["ex"], "-", color="0.35", lw=1.8, label="moving exchange points (S34: never on a graph path)")
ax.semilogx(sl, steep["tb"], "-", color="tab:orange", lw=1.8, label="moving three-body points ($\\pi$, $\\eta$, all $\\beta$)")
ax.set_xlabel(f"slope of the VV leg: depth / Re $k_1$, Re $k_1$ = {k1.real:.1f} MeV")
ax.set_ylabel("smallest distance from the contour (MeV)")
ax.set_ylim(0, 260)
ax.grid(alpha=0.3)
axr = ax.twinx()
axr.semilogy(J_DEP / k1.real, [clip(e) for e in steep_J], "o", color="tab:green", ms=6,
             label="App. D's $J$ with SP (right axis; static window from slope 1.5)")
axr.set_ylabel("relative error of App. D's $J$", color="tab:green")
axr.set_ylim(1e-18, 30)
h1, l1 = ax.get_legend_handles_labels()
h2, l2 = axr.get_legend_handles_labels()
ax.legend(h1 + h2 + [Patch(fc="#c7e9c0", label="VV window satisfied")], l1 + l2 + ["VV window satisfied"],
          fontsize=8, loc="center right")
ax.set_title(f"(f) steep contours at $E=-6-2i$ MeV on $(-,-,-)$: $k_1={k1.real:.1f}{k1.imag:+.1f}i$ MeV",
             fontsize=10.5)
fig.tight_layout()
fig.savefig(f"{OUT}.png", dpi=130)
print("wrote", f"{OUT}.png")
