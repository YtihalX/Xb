# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8", "mpmath>=1.3"]
# ///
"""The on-shell node of the S40 proposal against the TOPT singularities of the half-off-shell kernel.
Backs notes/07-continued-lse/s40-proposal.tex, Sec. "The on-shell node". A plot of the note's formulas and
numerical evidence, not a recorded check.

Question: with the on-shell momentum k_F a vertex of C(E) (R1-R2), do the singular points of V(k_F, q; E) and of
V(p', k_F; E) (exchanged-meson, w = 0; three-body/TOPT, Z = 0) ever meet the path, at the final energy or during
the continuation; and does the on-shell integral on C(E) equal the one obtained by other admissible routes?
By time reversal (note 07, S43 check 5) the column V(p', k_F) is the row V(k_F, p') of the reversed block, so the
row form with the orderings of the blocks with an outgoing F leg covers both: F = VV: beta 2, 3; PV: 1, 2, 4;
PP: 4 (note 07, S3). Geometry uses pi and eta and every beta; the integral tests use pi.

Part 1, geometry along two homotopies, for E_1 on a grid over the search domain and the widenings:
  follow: E_lam = Re E_1 + i lam Im E_1, lam from 0 (the real axis, k_F real, E + i0) to 1, with
          C_lam = sp_polygon(E_lam): k_F(E_lam) stays a vertex (the homotopy proposed for the rule);
  fixed:  note 07's S30 with C = sp_polygon(E_1) held fixed: (a) depth scaling at E_1^*, (b) E lowered to E_1.
  Reported: the smallest distance from the path to the on-shell singular points; the smallest Re Z over q on the
  path with p' = k_F, for every beta, meson and sign; the smallest Re w / m^2 (S34: w off (-inf, 0]); the diagonal
  Z_-(k_F, k_F); and, for "fixed", whether a down point (k_F - i m and the three-body points beside it, which
  start below the path) ends up above it, i.e. was swept.
Part 2, an integral with one on-shell TOPT leg, the S-wave moment M_0 of S3 for one ordering,
  J(E) = int_C dq q^2 [2 mu_F / (q^2 - k_F^2)] U_beta(k_F, q; E),
  U_beta(p', q; E) = int_{-1}^{1} dx / (2 s (s + nu_beta)) = [Log Z_+ - Log Z_-] / (2 p' q),
  Z_pm = sqrt(m^2 + (p' pm q)^2) + t_beta + h_beta p'^2 + a_beta q^2 - E (principal branches);
  route 3: C(E), pole subtracted at its vertex (R2), composite Gauss-Legendre (250 MeV panels, 24 nodes), double;
  route 1: the S40 path at d_k = d_k,max/2 (graph_path replica), no subtraction, mpmath adaptive, 20 digits;
           comparable when no on-shell singular point lies between it and C(E) (down points below both paths,
           up points above both);
  route 2: [0, Lambda] plus the pole term 2 pi i mu_F k_F U(k_F, k_F), adaptive, 20 digits, no cut terms;
           correct only while no up point has crossed [0, Lambda] (S32, second condition).
Figure onshell_topt.png: (a) follow homotopy at E_1 = delta_PV + 1 - 10i MeV; (b) the fixed path at the same E_1;
(c) distance from the path to the on-shell singular points along both homotopies; (d) the three routes.
Run: uv run --script notes/07-continued-lse/onshell_topt.py      Units MeV.
"""
import math
from pathlib import Path

import matplotlib
import mpmath as mp
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402

from _s40geom import *  # noqa: E402,F403  shared constants, builders, singular points

OUT = Path(__file__).with_suffix("")
MU = {name: mu for name, _, mu, _ in CH}
DELTA = {name: d for name, d, _, _ in CH}
IDX = {name: i for name, _, _, i in CH}
DPP, DPV, DVV = DELTA["PP"], DELTA["PV"], DELTA["VV"]
BETAS = (1, 2, 3, 4)


# ================================================================ on-shell singular points and bounds
def kphys(E, name):
    """Continued on-shell momentum of channel `name` on the sheet attached at Re E: flipped -> principal root
    (4th quadrant for Im E < 0, 1st for Im E > 0, real on the axis); unflipped are not used here."""
    return complex(np.sqrt(complex(2 * MU[name] * (E - DELTA[name]))))


def flipped_names(E):
    return [name for name in ("VV", "PV", "PP") if DELTA[name] < E.real]


def onshell_set(E, k):
    """(meson, kind, side, z): the singular points in q of V(k, q; E), every beta and sign, pi and eta.
    side: 'up' / 'down' by the nearer of k + i m, k - i m; 'far' when -k +- i m is nearer."""
    pts = []
    for phi, m in MPHI.items():
        refs = {"up": k + 1j * m, "down": k - 1j * m, "far": -k + 1j * m, "far2": -k - 1j * m}
        pts += [(phi, "ex", "up", refs["up"]), (phi, "ex", "down", refs["down"]),
                (phi, "ex", "far", refs["far"]), (phi, "ex", "far", refs["far2"])]
        for beta in BETAS:
            for tau in (1, -1):
                r = three_body(np.array([k]), E, m, beta, tau).ravel()
                for z in r[~np.isnan(r)]:
                    side = min(refs, key=lambda s: abs(z - refs[s]))
                    pts.append((phi, f"b{beta}", side if side in ("up", "down") else "far", complex(z)))
    return pts


def height(V, x):
    for a, b in zip(V[:-1], V[1:]):
        if a.real <= x <= b.real:
            return a.imag + (x - a.real) * (b - a).imag / (b - a).real
    return 0.0


def above(V, z):
    """z lies above the path (in R(V), or above [0, Lambda], or outside 0 < Re q < Lambda)."""
    return not (0 < z.real < V[-1].real) or z.imag > height(V, z.real)


def sides_ok(V, pts):
    """Down points below V, up points above V."""
    return all((not above(V, z)) if side == "down" else above(V, z) for _, _, side, z in pts if side != "far")


def z_bounds(V, E, k, n=1500):
    """min Re Z(k, q; E) and min Re w / m^2 over q sampled on V (plus the vertices), every beta, meson, sign."""
    q = np.concatenate([sample(V, n), np.asarray(V, complex)])
    zmin, wmin = np.inf, np.inf
    for phi, m in MPHI.items():
        for beta, (t, h, a) in ORD.items():
            for sg in (1, -1):
                w = m * m + (k + sg * q) ** 2
                Z = np.sqrt(w) + t + h * k * k + a * q * q - E
                zmin = min(zmin, Z.real.min())
                wmin = min(wmin, (w.real / (m * m)).min())
    return zmin, wmin


def diag_Z(E, k):
    """min over beta, meson of Re Z_-(k, k; E) = m + t + (h + a) k^2 - E."""
    return min((m + t + (h + a) * k * k - E).real for m in MPHI.values() for (t, h, a) in ORD.values())


def follow_scan(E1, nlam=21):
    rows = []
    for lam in np.linspace(0.0, 1.0, nlam):
        E = complex(E1.real, lam * E1.imag)
        V = sp_polygon(E)
        d, zmin, wmin, dz, ok = np.inf, np.inf, np.inf, np.inf, True
        for name in flipped_names(E):
            k = kphys(E, name)
            pts = onshell_set(E, k)
            d = min(d, min(path_dist(V, z) for *_, z in pts))
            zb = z_bounds(V, E, k)
            zmin, wmin = min(zmin, zb[0]), min(wmin, zb[1])
            dz = min(dz, diag_Z(E, k))
            ok &= sides_ok(V, pts)
        rows.append((lam, d, zmin, wmin, dz, ok))
    return rows


def fixed_scan(E1, nlam=21):
    """S30 with C = sp_polygon(E1) fixed: (a) at E1^*, depth scaling: a down point of k_F(E1^*) inside R(C) is
    swept; (b) E from E1^* down to E1: the sides of every on-shell point of k_F(E)."""
    V = sp_polygon(E1)
    rows = []
    for lam in np.linspace(-1.0, 1.0, 2 * nlam - 1):  # Im E = -lam |Im E1| ... from +|Im E1| (lam=-1) to Im E1
        E = complex(E1.real, lam * E1.imag)
        d, ok = np.inf, True
        for name in flipped_names(E1):
            k = kphys(E, name)
            pts = onshell_set(E, k)
            d = min(d, min(path_dist(V, z) for *_, z in pts))
            ok &= sides_ok(V, pts)
        rows.append((lam, d, ok))
    return rows


# ================================================================ part 1: geometry over the domain
def offsets(lo, hi, near=(0.05, 1.0, 5.0)):
    xs = [lo + e for e in near] + [0.5 * (lo + hi)] + [hi - e for e in near]
    return [x for x in xs if lo < x < hi]


GRID = {
    "(-,+,+)": [complex(x, -g / 2) for x in offsets(DPP, DPV) for g in (2, 10, 20, 40, 60, 100)],
    "(-,-,+)": [complex(x, -g / 2) for x in offsets(DPV, DVV) for g in (2, 10, 20, 40, 60, 100)],
    "(-,-,-)": [complex(x, -g / 2) for x in (0.05, 1.0, 5.0, 20.0, 37.0) for g in (2, 10, 20, 40, 60, 100)],
}
print("Part 1, follow homotopy (vertex follows k_F), lam = 0 ... 1 in 20 steps:")
print("  sheet   : energies | smallest distance path-to-on-shell-point | min Re Z (p'=k_F, q on C) | "
      "min Re w/m^2 | min diag Re Z_-(k_F,k_F) | sides violated")
fol_all, fix_all = {}, {}
for sheet, Es in GRID.items():
    res = [follow_scan(E) for E in Es]
    fol_all[sheet] = (Es, res)
    d = min(r[1] for rr in res for r in rr)
    zmin = min(r[2] for rr in res for r in rr)
    wmin = min(r[3] for rr in res for r in rr)
    dz = min(r[4] for rr in res for r in rr)
    bad = sum(not r[5] for rr in res for r in rr)
    print(f"  {sheet}: {len(Es):3d}      | {d:7.1f} MeV | {zmin:7.2f} MeV | {wmin:6.3f} | {dz:7.2f} MeV | {bad}")
print("Part 1, fixed path (note 07, S30): energies where a down point is swept or an up point ends below C:")
for sheet, Es in GRID.items():
    res = [fixed_scan(E) for E in Es]
    fix_all[sheet] = (Es, res)
    bad = [(E, min(r[1] for r in rr)) for E, rr in zip(Es, res) if not all(r[2] for r in rr)]
    gammas = sorted({round(-2 * E.imag) for E, _ in bad})
    print(f"  {sheet}: {len(bad)} of {len(Es)} energies; Gamma values among them: {gammas}")
# depth of the vertex against m_pi/2: the stage-(a) criterion for the exchanged-meson down point
print("  stage (a) sweeps k_F - i m_pi when the vertex is deeper than m_pi/2 = "
      f"{MPHI['pi'] / 2:.1f} MeV: |Im k_F| at 1 MeV above the PV threshold is "
      + ", ".join(f"{abs(kphys(complex(DPV + 1, -g / 2), 'PV').imag):.0f} (Gamma={g})" for g in (2, 4, 10, 20)))


# ================================================================ part 2: the on-shell TOPT integral, three routes
def U_np(k, q, E, beta, m):
    t, h, a = ORD[beta]
    nu = t + h * k * k + a * q * q - E
    zp = np.sqrt(m * m + (k + q) ** 2) + nu
    zm = np.sqrt(m * m + (k - q) ** 2) + nu
    return (np.log(zp) - np.log(zm)) / (2 * k * q)


def U_mp(k, q, E, beta, m):
    t, h, a = ORD[beta]
    nu = t + h * k * k + a * q * q - E
    zp = mp.sqrt(m * m + (k + q) ** 2) + nu
    zm = mp.sqrt(m * m + (k - q) ** 2) + nu
    return (mp.log(zp) - mp.log(zm)) / (2 * k * q)


def panels(V, Lp=250.0):
    out = []
    for a, b in zip(V[:-1], V[1:]):
        n = max(1, math.ceil(abs(b - a) / Lp))
        out += [(a + (b - a) * j / n, a + (b - a) * (j + 1) / n) for j in range(n)]
    return out


def route3(E, name, beta, n=24):
    k, mu, m = kphys(E, name), MU[name], MPHI["pi"]
    x, w = np.polynomial.legendre.leggauss(n)
    tot = 0j
    ukk = U_np(k, k, E, beta, m)
    for a, b in panels(sp_polygon(E)):
        h = (b - a) / 2
        q = a + (x + 1) * h
        f = 2 * mu * (q * q * U_np(k, q, E, beta, m) - k * k * ukk) / (q * q - k * k)
        tot += np.sum(w * h * f)
    I = (np.log((LAM - k) / (LAM + k)) + 1j * np.pi) / (2 * k)
    return tot + 2 * mu * k * k * ukk * I


def mp_path(f, V, k, dps=20):
    """Adaptive integral of f along the polygon V, each segment split at the point nearest to k."""
    with mp.workdps(dps):
        tot, err = mp.mpc(0), mp.mpf(0)
        kk = mp.mpc(k.real, k.imag)
        for a, b in zip(V[:-1], V[1:]):
            A, B = mp.mpc(a.real, a.imag), mp.mpc(b.real, b.imag)
            d = B - A
            ts = [mp.mpf(0), mp.mpf(1)]
            tstar = mp.re((kk - A) * mp.conj(d)) / abs(d) ** 2
            if 0 < tstar < 1:
                ts.insert(1, tstar)
            v, e = mp.quad(lambda t: f(A + d * t) * d, ts, error=True)
            tot += v
            err += abs(e)
        return complex(tot), float(err)


def route1(E, name, beta):
    """S40 path at d_k,max/2, no subtraction; comparable if no on-shell point lies between it and C(E)."""
    dm = largest_dk(E)
    if not dm == dm:
        return None, False, np.nan
    V = s40_path(E, dm / 2)
    k, mu, m = kphys(E, name), MU[name], MPHI["pi"]
    pts = [p for p in onshell_set(E, k) if p[0] == "pi" and (p[1] == "ex" or int(p[1][1]) == beta)]
    ok = sides_ok(V, pts) and sides_ok(sp_polygon(E), pts)
    with mp.workdps(20):
        km, Em = mp.mpc(k.real, k.imag), mp.mpc(E.real, E.imag)
        val, _ = mp_path(lambda q: q * q * 2 * mu / (q * q - km * km) * U_mp(km, q, Em, beta, m), V, k)
    return val, ok, dm / 2


def route2(E, name, beta):
    """[0, Lambda] plus the pole term; no cut terms. Correct if no up point of this beta lies in R(C(E))."""
    k, mu, m = kphys(E, name), MU[name], MPHI["pi"]
    pts = [p for p in onshell_set(E, k) if p[0] == "pi" and (p[1] == "ex" or int(p[1][1]) == beta)]
    crossed = any(side == "up" and inside(sp_polygon(E), z) for _, _, side, z in pts)
    with mp.workdps(20):
        km, Em = mp.mpc(k.real, k.imag), mp.mpc(E.real, E.imag)
        val, _ = mp_path(lambda q: q * q * 2 * mu / (q * q - km * km) * U_mp(km, q, Em, beta, m),
                         [0j, complex(LAM, 0)], k)
        val += complex(2j * mp.pi * mu * km * U_mp(km, km, Em, beta, m))
    return val, not crossed


ONSH = {"VV": (2, 3), "PV": (1, 2, 4), "PP": (4,)}
TESTS = [complex(x, -g / 2) for x in (DPP + 0.05, DPP + 1.0, -67.85, DPV + 0.05, DPV + 1.0, -22.62, DVV - 1.0,
                                      DVV + 0.05, DVV + 1.0, 20.0)
         for g in (2.0, 20.0, 60.0)]
print("\nPart 2, J(E) with one on-shell TOPT leg (pi): relative differences |J3 - J1|/|J1| and |J3 - J2|/|J2|")
print("  E                F  beta  d_k(route1)  route1:diff [comparable]   route2:diff [no up point crossed]")
rows2 = []
for E in TESTS:
    for name in flipped_names(E):
        for beta in ONSH[name]:
            j3 = route3(E, name, beta)
            j1, ok1, dk1 = route1(E, name, beta)
            j2, ok2 = route2(E, name, beta)
            r1 = abs(j3 - j1) / abs(j1) if j1 is not None else np.nan
            r2 = abs(j3 - j2) / abs(j2)
            rows2.append((E, name, beta, r1, ok1, r2, ok2))
            print(f"  {E.real:7.2f}{E.imag:+6.1f}i  {name}  {beta}   {dk1:8.2f}     {r1:9.2e} [{'yes' if ok1 else 'no '}]"
                  f"          {r2:9.2e} [{'yes' if ok2 else 'no '}]")
ok1v = [r[3] for r in rows2 if r[4] and r[3] == r[3]]
ok2v = [r[5] for r in rows2 if r[6]]
bad2v = [r[5] for r in rows2 if not r[6]]
print(f"  route 1 comparable: {len(ok1v)} cases, largest difference {max(ok1v):.1e}")
print(f"  route 2 without crossed up points: {len(ok2v)} cases, largest difference {max(ok2v):.1e}")
if bad2v:
    print(f"  route 2 with a crossed up point: {len(bad2v)} cases, differences {min(bad2v):.1e} to {max(bad2v):.1e}")
not_cmp1 = [r for r in rows2 if not r[4]]
if not_cmp1:
    print(f"  route 1 not comparable (an on-shell point between the paths): {len(not_cmp1)} cases, differences "
          f"{min(r[3] for r in not_cmp1):.1e} to {max(r[3] for r in not_cmp1):.1e}")

# ================================================================ figure
E1 = complex(DPV + 1.0, -10.0)
fig = plt.figure(figsize=(17, 12.5))
gs = fig.add_gridspec(2, 2)


def qplane(ax, title):
    ax.axhline(0, color="0.6", lw=0.8)
    ax.axvline(0, color="0.8", lw=0.6)
    ax.plot([0, 600], [0, -600], ":", color="0.5", lw=0.9)
    ax.set_xlim(-20, 640)
    ax.set_ylim(-360, 190)
    ax.set_aspect("equal")
    ax.set_xlabel("Re $q$ (MeV)")
    ax.set_ylabel("Im $q$ (MeV)")
    ax.set_title(title, fontsize=10.5)


def trail(ax, Es, k_of_E, ls="-"):
    """Trajectories of k_F and of its pion on-shell points (up: k + i m side, down: k - i m side)."""
    ks = np.array([k_of_E(E) for E in Es])
    ax.plot(ks.real, ks.imag, ls, color="crimson", lw=1.6, zorder=6)
    for side, col in (("up", "tab:orange"), ("down", "tab:purple")):
        for kind in ("ex", "b1", "b2", "b4"):
            zs = []
            for E, k in zip(Es, ks):
                c = [z for phi, kd, sd, z in onshell_set(E, k) if phi == "pi" and kd == kind and sd == side]
                zs.append(c[0] if c else np.nan)
            zs = np.array(zs, complex)
            ax.plot(zs.real, zs.imag, ls, color=col, lw=1.4 if kind == "ex" else 0.9,
                    alpha=1.0 if kind == "ex" else 0.7, zorder=5)
            ax.plot(zs.real[-1], zs.imag[-1], "*" if kind == "ex" else "P", ms=10 if kind == "ex" else 6,
                    mfc="gold", mec="k", zorder=8)
    ax.plot(ks.real[-1], ks.imag[-1], "o", ms=8, color="crimson", zorder=9)


ax = fig.add_subplot(gs[0, 0])
qplane(ax, f"(a) proposed: the vertex follows $k_5(E)$, $E=-44.23+i\\lambda(-10)$ MeV, $\\lambda=0\\to1$\n"
           "up points (orange) cross the real axis but stay above every $\\mathcal{C}_\\lambda$; down points stay below")
lams = np.linspace(0, 1, 26)
Es_f = [complex(E1.real, lam * E1.imag) for lam in lams]
for lam, col in zip((0.0, 0.25, 0.5, 0.75, 1.0), plt.cm.Greens(np.linspace(0.35, 0.95, 5))):
    V = sp_polygon(complex(E1.real, lam * E1.imag))
    ax.plot([v.real for v in V], [v.imag for v in V], color=col, lw=2.0, zorder=4)
    ax.text(V[1].real + 6, V[1].imag - 22, f"$\\lambda={lam:g}$", color=col, fontsize=8)
trail(ax, Es_f, lambda E: kphys(E, "PV"))
ax = fig.add_subplot(gs[0, 1])
qplane(ax, f"(b) note 07's S30: path fixed at $\\mathcal{{C}}(E_1)$; (a) depth scaling at $E_1^*$, (b) $E: E_1^*\\to E_1$\n"
           "the down points start above the path (here above the real axis) and end below it: they cross it")
V = sp_polygon(E1)
ax.fill_between([v.real for v in V], [v.imag for v in V], 0, color="0.92", zorder=0)
ax.plot([v.real for v in V], [v.imag for v in V], color="tab:green", lw=2.2, zorder=4)
Es_b = [complex(E1.real, -lam * E1.imag) for lam in np.linspace(-1, 1, 41)]
trail(ax, Es_b, lambda E: kphys(E, "PV"))
k_star = kphys(E1.conjugate(), "PV")
ax.plot(k_star.real, k_star.imag, "o", ms=8, mfc="white", mec="crimson", mew=2, zorder=9)
ax.annotate("$k_5(E_1^*)$", (k_star.real, k_star.imag), xytext=(8, 4), textcoords="offset points", fontsize=9)
ax.annotate("$k_5(E_1^*)-im_\\pi$: above the path\nat the start of stage (b)", (k_star.real, k_star.imag - MPHI["pi"]),
            xytext=(40, 40), textcoords="offset points", fontsize=8.5,
            arrowprops=dict(arrowstyle="->", color="tab:purple"), color="tab:purple")
ax = fig.add_subplot(gs[1, 0])
for E, col in ((complex(DPV + 1.0, -1.0), "tab:blue"), (complex(DPV + 1.0, -10.0), "k"),
               (complex(DPV + 1.0, -30.0), "tab:red"), (complex(-22.62, -10.0), "tab:green")):
    rf = follow_scan(E, nlam=41)
    rx = fixed_scan(E, nlam=41)
    ax.plot([r[0] for r in rf], [r[1] for r in rf], "-", color=col, lw=1.8,
            label=f"proposed, $E_1={E.real:.2f}{E.imag:+g}i$")
    ax.plot([(r[0] + 1) / 2 for r in rx], [r[1] if r[2] else 0 for r in rx], "--", color=col, lw=1.2,
            label="S30, fixed path (0 where a point is on the wrong side)")
ax.set_xlabel("homotopy parameter (proposed: $\\lambda$; S30 stage (b): $E$ from $E_1^*$ to $E_1$)")
ax.set_ylabel("smallest distance from the path to an on-shell singular point (MeV)")
ax.set_ylim(0, 200)
ax.grid(alpha=0.3)
ax.legend(fontsize=7.8, ncol=1, loc="upper right")
ax.set_title("(c) on-shell singular points of $V(k_F,q)$ and $V(p',k_F)$ ($\\pi$, $\\eta$, every $\\beta$) "
             "against the path", fontsize=10.5)
ax = fig.add_subplot(gs[1, 1])
gam = np.array([-2 * r[0].imag for r in rows2])
jit = (np.arange(len(rows2)) % 7 - 3) * 0.9
r1 = np.array([r[3] for r in rows2])
r2 = np.array([r[5] for r in rows2])
c1 = np.array([r[4] for r in rows2])
c2 = np.array([r[6] for r in rows2])
ax.semilogy(gam[c1] + jit[c1], np.maximum(r1[c1], 1e-17), "o", color="k", ms=5,
            label="route 3 vs route 1 (S40 path), comparable")
ax.semilogy(gam[c2] + jit[c2], np.maximum(r2[c2], 1e-17), "s", mfc="none", mec="tab:blue", ms=6,
            label="route 3 vs route 2 (real axis + pole term), no up point crossed")
if (~c2).any():
    ax.semilogy(gam[~c2] + jit[~c2], np.maximum(r2[~c2], 1e-17), "x", color="tab:red", ms=7,
                label="route 3 vs route 2, an up point crossed $[0,\\Lambda]$ (needs cut terms)")
if (~c1).any():
    ax.semilogy(gam[~c1] + jit[~c1], np.maximum(r1[~c1], 1e-17), "^", color="0.5", ms=5,
                label="route 3 vs route 1, an on-shell point between the paths")
ax.set_xticks([2, 20, 60])
ax.set_xlabel("$\\Gamma$ (MeV) (points spread horizontally)")
ax.set_ylabel("relative difference of $J$")
ax.grid(alpha=0.3, which="both")
ax.legend(fontsize=8)
ax.set_title("(d) $J=\\int q^2dq\\,G_F\\,M_0(\\nu_\\beta)$ with one on-shell leg: route 3 (proposal) against two others",
             fontsize=10.5)
handles = [Line2D([], [], color="crimson", lw=1.6, marker="o", label="$k_5$ (a vertex in (a))"),
           Line2D([], [], color="tab:orange", lw=1.4, label="up points: $k_5+im_\\pi$ and three-body points beside it"),
           Line2D([], [], color="tab:purple", lw=1.4, label="down points: $k_5-im_\\pi$ and three-body points beside it"),
           Line2D([], [], ls="", marker="*", ms=10, mfc="gold", mec="k", label="exchanged-meson point at the end"),
           Line2D([], [], ls="", marker="P", ms=6, mfc="gold", mec="k", label="three-body points at the end"),
           Line2D([], [], ls=":", color="0.5", label="slope-1 line")]
fig.legend(handles=handles, loc="upper center", ncol=6, fontsize=8.6, frameon=False)
fig.tight_layout(rect=(0, 0, 1, 0.97))
fig.savefig(f"{OUT}.png", dpi=140)
print("\nwrote", f"{OUT}.png")
