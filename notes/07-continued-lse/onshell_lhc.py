# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8", "mpmath>=1.3"]
# ///
"""The singular points of the on-shell kernel V(k_F, q; E) next to the two-body thresholds, against three ways of
integrating past the propagator pole at q = k_F of a flipped channel F.

  route 1, our path: the S40 path C passes below every flipped k_F; no node at k_F.
  route 2, the real path: [0, Lambda] plus the pole term 2 pi i Res and, for every singular point of V(k_F, q) that
           crossed [0, Lambda], a cut term ([@Wu:2026wxb] v1, App. D, C_R' mirrored). The on-shell-point identities
           06:eq:onshellpoint--06:eq:Dflip go this way: S32's second condition.
  route 3, Sokhotski-Plemelj on the deformed path: C through every flipped k_F (sp_polygon), the pole subtracted at
           its vertex and the subtracted term integrated along C below k_F in closed form, -i pi / (2 k) on [0, inf).
A route is right when no singular point crosses its contour during the continuation (S32, first condition). Up
points (k_F + i m_pi and the three-body points beside it) lie above [0, Lambda] on the physical sheet and cross it
once |Im k_F| is large enough: that crosses route 2's contour, not those of routes 1 and 3. Down points (k_F - i m_pi
and its neighbours) start below the path and must stay below it: S32's depth window. On route 3, k_F lies on C, so
V(k_F, q) is the kernel at two path points and S34 (exchanged-meson) and S35 (three-body) keep both kinds off C.

Figure 1 (onshell_lhc_where.png): just above each threshold, in the plane eps = Re E - delta_alpha, Gamma = -2 Im E,
S40 path at d_k = d_k,max / 2. Shaded: an up point lies in R(C), so it crossed [0, Lambda] and route 2 needs a cut
term. Hatched: a down point lies in R(C), so the path swept it and on-shell T on route 1 breaks S32's window (D_C is
unaffected). Lines: contours of d_k,max; |Im k_F| = m_pi of the just-flipped channel, Gamma = 2 sqrt(2 eps a + a^2)
with a = m_pi^2 / mu_alpha; Gamma = 20 MeV. Route 3 is checked on the same grid (printed).
Figure 2 (onshell_lhc_routes.png): App. D's example J(p; m) = int q dq / (p^2 - q^2) [l_- - l_+], an on-shell kernel
times the propagator, with p = k_5 (PV) and m = m_pi. (a), (b): the q plane 1 MeV above the PV threshold at
Gamma = 20 and 10 MeV. (c): relative error against the exact J = i pi Log(1 - 2 i p / m), 30 digits, adaptive
quadrature and pole and cut terms of checks/appd_contours.py: routes 1, 2, 3, route 2 without its cut term, and
route 2 with the principal ratio log. (d): Gauss-Legendre nodes per segment, double precision, at Gamma = 20 MeV,
0.05 and 1 MeV above the PV threshold: route 1 at d_k = d_k,max / 2 against route 3.
Static Yukawa only: for the TOPT kernel the cut terms of the three-body points are not derived (NOTEBOOK.md, Open
questions, On-shell cut pattern); routes 1 and 3 do not need them.

Run: uv run --script notes/07-continued-lse/onshell_lhc.py
A plot of the note's formulas, not a check. Units MeV; J in GeV, as in the check.
"""
import math
import sys
from pathlib import Path

import matplotlib
import mpmath as mp
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.colors import ListedColormap  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402
from matplotlib.patches import Circle, Patch  # noqa: E402

from _s40geom import *  # noqa: E402,F403  shared constants, S40 builder replica, singular points

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "checks"))
import appd_contours as appd  # noqa: E402  App. D example: split logs, pole term, cut term, quadrature

OUT = Path(__file__).with_suffix("")
MPI = MPHI["pi"]
CHN = {name: (delta, mu) for name, delta, mu, _ in CH}


def dk_max(E, iters=24):
    """Largest margin the S40 builder admits, bisected without the vertical (P) check; NaN if none."""
    if s40_path(E, 0.01, vertical=False) is None:
        return float("nan")
    lo, hi = 0.01, 600.0
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        lo, hi = (mid, hi) if s40_path(E, mid, vertical=False) is not None else (lo, mid)
    return lo


def height(V, x):
    """Im q of the graph path V at Re q = x."""
    for a, b in zip(V[:-1], V[1:]):
        if a.real <= x <= b.real:
            return a.imag + (x - a.real) * (b - a).imag / (b - a).real
    return 0.0


def sides(V, E):
    """(an up point in R(V), channels whose down points lie in R(V), an up point below V)."""
    up_in, down_in, up_below = False, set(), False
    for name, _, side, z in onshell_points(E):
        if side == "up":
            up_in |= inside(V, z)
            up_below |= 0 < z.real < V[-1].real and z.imag < height(V, z.real)
        elif side == "down" and inside(V, z):
            down_in.add(name)
    return up_in, down_in, up_below


def max_slope(V):
    return max(abs((b - a).imag) / (b - a).real for a, b in zip(V[:-1], V[1:]))


# ================================================================ figure 1 data
EPS_GRID = np.geomspace(0.05, 15.0, 28)
GAM_GRID = np.arange(1.0, 40.01, 1.5)
maps, swept_at = {}, {}
for name in ("VV", "PV", "PP"):
    delta, mu = CHN[name]
    shape = (EPS_GRID.size, GAM_GRID.size)
    dm, up, down = np.full(shape, np.nan), np.zeros(shape, bool), np.zeros(shape, bool)
    swept, up_below, sp_bad, sp_slope, sp_dist = set(), 0, 0, 0.0, np.inf
    for i, e in enumerate(EPS_GRID):
        for j, g in enumerate(GAM_GRID):
            E = complex(delta + e, -g / 2)
            dm[i, j] = dk_max(E)
            V = s40_path(E, dm[i, j] / 2) if dm[i, j] == dm[i, j] else None
            if V is None:
                continue
            up[i, j], chans, ub = sides(V, E)
            down[i, j] = bool(chans)
            swept |= chans
            up_below += ub
            Vp = sp_polygon(E)
            _, chans3, ub3 = sides(Vp, E)
            sp_bad += bool(chans3) or ub3
            sp_slope = max(sp_slope, max_slope(Vp))
            sp_dist = min(sp_dist, min(path_dist(Vp, z) for *_, z in onshell_points(E)))
    maps[name] = (dm, up, down)
    swept_at[name] = swept
    a = MPI ** 2 / mu
    g_first = GAM_GRID[np.argmax(up.any(axis=0))] if up.any() else np.nan
    j20 = int(np.argmin(np.abs(GAM_GRID - 20.5)))
    e20 = EPS_GRID[up[:, j20]].max() if up[:, j20].any() else 0.0
    print(f"{name} threshold, S40 path at d_k,max/2 ({up.size} cells, {int(np.isnan(dm).sum())} excluded):\n"
          f"  up point in R(C) (crossed [0, Lambda]; route 2 needs a cut term) in {int(up.sum())} cells, from Gamma ="
          f" {g_first:.1f} MeV; at Gamma = {GAM_GRID[j20]:.1f} MeV up to eps = {e20:.2f} MeV;"
          f" |Im k_F| = m_pi at Gamma = {2 * a:.2f} MeV (eps -> 0), at Gamma = 20 MeV eps = {(100 - a * a) / (2 * a):.2f}\n"
          f"  down point in R(C) (swept; S32 window broken on route 1) in {int(down.sum())} cells, channels"
          f" {sorted(swept) or '-'}, first at Gamma = "
          f"{GAM_GRID[np.argmax(down.any(axis=0))] if down.any() else float('nan'):.1f} MeV; up point below C: {up_below}\n"
          f"  route 3 polygon: max slope {sp_slope:.3f}, nearest on-shell point {sp_dist:.1f} MeV, cells with a point"
          f" swept: {sp_bad}")


# ================================================================ figure 2 data: App. D's example
EPS_DEMO = 1.0
DELTA_PV, MU_PV = CHN["PV"]


def j_routes(E, dps=30):
    """App. D's J(p; m_pi) at p = k_5: relative errors of the routes against the exact value, 30 digits, GeV."""
    k = sheet_k(E, DELTA_PV, MU_PV)[0]
    V = s40_path(E, dk_max(E) / 2)
    with mp.workdps(dps):
        p = mp.mpc(k.real, k.imag) / 1000
        m = mp.mpf(MPI) / 1000
        a = mp.re(p)
        exact = 1j * mp.pi * mp.log(1 - 2j * p / m)
        splits = [("re", a), ("re", -a)]
        f = lambda q: q / (p * p - q * q) * appd.split_logs(q, p, m)  # noqa: E731
        quad = appd.Quadrature()
        verts = [mp.mpc(v.real, v.imag) / 1000 for v in V]
        route1 = quad.path(f, verts, splits) + quad.ray(f, verts[-1], splits)
        real_axis = quad.ray(f, mp.mpc(0), splits)
        pole = appd.pole_term(p, m, quad)
        bites = abs(mp.im(p)) > m
        cut = appd.right_cut(p, m, quad) if bites else mp.mpc(0)
        qstar = [("re", mp.sqrt(abs(p) ** 2 - m * m))] if bites else []
        fr = lambda q: q / (p * p - q * q) * mp.log(((q - p) ** 2 + m * m) / ((q + p) ** 2 + m * m))  # noqa: E731
        ratio = quad.ray(fr, mp.mpc(0), splits + qstar) + pole + cut
        fp = p * appd.split_logs(p, p, m)
        g = lambda q: f(q) - fp / (p * p - q * q)  # noqa: E731
        verts3 = [mp.mpc(v.real, v.imag) / 1000 for v in sp_polygon(E)]
        route3 = quad.path(g, verts3, splits) + quad.ray(g, verts3[-1], splits) - 1j * mp.pi * fp / (2 * p)
        rel = lambda x: float(abs(x - exact) / abs(exact))  # noqa: E731
        return {"k": k, "cut/J": float(abs(cut) / abs(exact)), "route 1": rel(route1),
                "route 2": rel(real_axis + pole + cut), "route 2, no cut term": rel(real_axis + pole),
                "route 2, ratio log": rel(ratio), "route 3": rel(route3), "quad error": float(quad.error)}


def j_fixed(E, n, route):
    """J(k_5; m_pi) with n Gauss-Legendre nodes per segment and the tail q = X / (1 - t); double precision."""
    k = sheet_k(E, DELTA_PV, MU_PV)[0]
    p, m = k / 1000, MPI / 1000
    V = [v / 1000 for v in (s40_path(E, dk_max(E) / 2) if route == 1 else sp_polygon(E))]
    x, w = np.polynomial.legendre.leggauss(n)
    qs, ws = [], []
    for a, b in zip(V[:-1], V[1:]):
        h = (b - a) / 2
        qs.append(a + (x + 1) * h)
        ws.append(w * h)
    t = (x + 1) / 2
    X = V[-1].real
    qs.append(X / (1 - t) + 0j)
    ws.append(w / 2 * X / (1 - t) ** 2)
    q, wq = np.concatenate(qs), np.concatenate(ws)
    f = q / (p * p - q * q) * (np.log((q - p) ** 2 + m * m) - np.log((q + p) ** 2 + m * m))
    if route == 1:
        val = np.sum(wq * f)
    else:
        fp = p * (np.log(m * m) - np.log(4 * p * p + m * m))
        val = np.sum(wq * (f - fp / (p * p - q * q))) - 1j * np.pi * fp / (2 * p)
    exact = 1j * np.pi * np.log(1 - 2j * p / m)
    return abs(val - exact) / abs(exact)


GAMMAS = np.array([2, 4, 6, 8, 10, 12, 13, 14, 15, 15.5, 16, 16.5, 17, 18, 20, 22, 25, 28, 32, 36, 40], float)
demo = [j_routes(complex(DELTA_PV + EPS_DEMO, -g / 2)) for g in GAMMAS]
GC_DEMO = 2 * math.sqrt(2 * EPS_DEMO * MPI ** 2 / MU_PV + (MPI ** 2 / MU_PV) ** 2)
print(f"\nApp. D example, p = k_5 at Re E = delta_PV + {EPS_DEMO} MeV; k_5 + i m_pi below [0, Lambda] for"
      f" Gamma > {GC_DEMO:.2f} MeV")
print(" Gamma  |Im k|   route 1    route 2   no cut     ratio log  route 3    |cut|/|J|")
for g, r in zip(GAMMAS, demo):
    print(f" {g:5.1f}  {abs(r['k'].imag):6.1f}  {r['route 1']:.1e}  {r['route 2']:.1e}  {r['route 2, no cut term']:.1e}"
          f"  {r['route 2, ratio log']:.1e}  {r['route 3']:.1e}  {r['cut/J']:.1e}")
NODES = (8, 12, 16, 24, 32, 48, 64, 96, 128, 192, 256)
EPS_CONV = (0.05, 1.0)
conv = {(route, e): [j_fixed(complex(DELTA_PV + e, -10.0), n, route) for n in NODES]
        for route in (1, 3) for e in EPS_CONV}
print("\nnodes per segment, Gamma = 20 MeV:")
for (route, e), errs in conv.items():
    print(f"  route {route}, eps = {e:4.2f} MeV: " + " ".join(f"{n}:{v:.1e}" for n, v in zip(NODES, errs)))

# ================================================================ figure 1
plt.rcParams["hatch.color"] = "k"
plt.rcParams["hatch.linewidth"] = 0.7
fig1, axes1 = plt.subplots(1, 3, figsize=(17, 6.2), sharey=True)
titles = {"VV": "(a) $B^*\\bar B^*$ threshold: VV just flipped, sheet $(-,-,-)$",
          "PV": "(b) $B\\bar B^*$ threshold: PV just flipped, sheet $(-,-,+)$",
          "PP": "(c) $B\\bar B$ threshold: PP just flipped, sheet $(-,+,+)$"}
for ax, name in zip(axes1, ("VV", "PV", "PP")):
    dm, up, down = maps[name]
    ax.pcolormesh(EPS_GRID, GAM_GRID, up.T.astype(float), cmap=ListedColormap(["white", "#fdd49e"]), vmin=0, vmax=1,
                  shading="nearest")
    if down.any():
        ax.contourf(EPS_GRID, GAM_GRID, down.T.astype(float), levels=[0.5, 1.5], colors="none", hatches=["////"])
    levels = [5, 10, 20, 40, MPI / math.sqrt(2)]
    cs = ax.contour(EPS_GRID, GAM_GRID, dm.T, levels=levels, colors="k", linewidths=0.9)
    ax.clabel(cs, fmt={lv: f"{lv:.0f}" for lv in levels}, fontsize=8)
    a = MPI ** 2 / CHN[name][1]
    ee = np.geomspace(EPS_GRID[0], EPS_GRID[-1], 300)
    ax.plot(ee, 2 * np.sqrt(2 * ee * a + a * a), "--", color="darkred", lw=1.6)
    ax.axhline(20, color="0.25", ls=":", lw=1.2)
    ax.set_xscale("log")
    ax.set_xlim(EPS_GRID[0], EPS_GRID[-1])
    ax.set_ylim(GAM_GRID[0] - 0.75, GAM_GRID[-1] + 0.75)
    ax.set_xticks([0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10], ["0.05", "0.1", "0.2", "0.5", "1", "2", "5", "10"])
    ax.set_xlabel("Re $E-\\delta_\\alpha$ (MeV above the threshold)")
    ax.set_title(titles[name], fontsize=10.5)
axes1[0].set_ylabel("$\\Gamma=-2\\,{\\rm Im}\\,E$ (MeV)")
handles = [Patch(fc="#fdd49e", label="an up point ($k_F+im_\\pi$ or a three-body point beside it) lies in "
                                     "$R(\\mathcal{C})$: it crossed $[0,\\Lambda]$; route 2 needs a cut term, routes 1, 3 not"),
           Patch(fc="white", ec="k", hatch="////", label="a down point lies in $R(\\mathcal{C})$: the S40 path swept it ("
                 + "; ".join(f"{'/'.join(sorted(c))}'s, at the {n} threshold" for n, c in swept_at.items() if c)
                 + "); on-shell $T$ on route 1 is wrong there"),
           Line2D([], [], color="k", lw=0.9, label="contours of $d_{k,\\max}$ (MeV); 98 $=m_\\pi/\\sqrt{2}$"),
           Line2D([], [], color="darkred", ls="--", lw=1.6, label="$|{\\rm Im}\\,k_F|=m_\\pi$ (just-flipped channel)"),
           Line2D([], [], color="0.25", ls=":", lw=1.2, label="$\\Gamma=20$ MeV: edge of the first search domain")]
fig1.legend(handles=handles, loc="lower center", ncol=2, fontsize=8.8, frameon=False)
fig1.suptitle("Singular points of the on-shell kernel $V(k_F,q;E)$ against the S40 path at $d_k=d_{k,\\max}/2$ "
              "(pion exchange). Route 3, the path through every flipped pole, sweeps none of them on this grid.",
              fontsize=11.5)
fig1.tight_layout(rect=(0, 0.15, 1, 0.95))
fig1.savefig(f"{OUT}_where.png", dpi=150)

# ================================================================ figure 2
YMIN, YMAX = -340.0, 170.0


def draw_routes(ax, E):
    dm = dk_max(E)
    V = s40_path(E, dm / 2)
    xs, ys = [v.real for v in V], [v.imag for v in V]
    ax.fill_between(xs, ys, 0, color="0.92", zorder=0)
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.plot([0, 1200], [0, 0], color="tab:blue", lw=3.2, alpha=0.75, zorder=2, solid_capstyle="butt")
    ax.plot(xs, ys, color="k", lw=2.2, zorder=4)
    V3 = sp_polygon(E)
    ax.plot([v.real for v in V3], [v.imag for v in V3], color="tab:green", lw=2.2, zorder=4.5)
    for p in poles(E):
        z = p["q4"]
        if not p["flipped"]:
            ax.plot(z.real, z.imag, "o", ms=8, mfc="white", mec="navy", mew=2, zorder=6)
            ax.annotate(f"$-k_{p['idx']}$ ({p['name']})", (z.real, z.imag), xytext=(8, 4),
                        textcoords="offset points", fontsize=9, color="navy")
            continue
        k = p["k"]
        ax.plot(k.real, k.imag, "o", ms=8, color="crimson", zorder=6)
        ax.add_patch(Circle((k.real, k.imag), 15, fill=False, ec="tab:blue", lw=1.8, zorder=5))
        ax.annotate(f"$+k_{p['idx']}$ ({p['name']})", (k.real, k.imag), xytext=(12, -16),
                    textcoords="offset points", fontsize=9, color="crimson")
        ax.plot([k.real, k.real], [k.imag + MPI, YMAX], ls=(0, (4, 3)), color="saddlebrown", lw=1.3, zorder=3)
        ax.plot([k.real, k.real], [k.imag - MPI, YMIN], ls=(0, (4, 3)), color="saddlebrown", lw=1.3, zorder=3)
        ax.plot([k.real] * 2, [k.imag + MPI, k.imag - MPI], "*", ms=12, mfc="gold", mec="k", zorder=7)
        tb = three_body_all(np.array([k]), E, mesons=("pi",), betas=ONSHELL_BETAS[p["name"]])
        ax.plot(tb.real, tb.imag, "P", ms=7, mfc="gold", mec="k", zorder=7)
        if abs(k.imag) > MPI:
            ax.plot([k.real, k.real], [0, k.imag + MPI], color="tab:blue", lw=4.5, zorder=6,
                    solid_capstyle="butt")
            ax.annotate("cut term:\n$-2\\pi i\\int_{{\\rm Re}\\,k}^{k+im_\\pi}\\frac{q\\,dq}{k^2-q^2}$",
                        (k.real, (k.imag + MPI) / 2), xytext=(45, 52), textcoords="offset points",
                        fontsize=9, color="tab:blue", arrowprops=dict(arrowstyle="->", color="tab:blue"))
    ax.set_xlim(-60, 760)
    ax.set_ylim(YMIN, YMAX)
    ax.set_aspect("equal")
    ax.set_xlabel("Re $q$ (MeV)")
    ax.set_ylabel("Im $q$ (MeV)")
    return dm


fig2 = plt.figure(figsize=(17, 11.5))
gs = fig2.add_gridspec(2, 2, height_ratios=(1.0, 1.0))
for col, (g, tag) in enumerate(((20.0, "a"), (10.0, "b"))):
    ax = fig2.add_subplot(gs[0, col])
    E = complex(DELTA_PV + EPS_DEMO, -g / 2)
    dm = draw_routes(ax, E)
    k5 = sheet_k(E, DELTA_PV, MU_PV)[0]
    verdict = ("$|{\\rm Im}\\,k_5|>m_\\pi$: $k_5+im_\\pi$ crossed $[0,\\Lambda]$; route 2 needs the cut term"
               if abs(k5.imag) > MPI else
               "$|{\\rm Im}\\,k_5|<m_\\pi$: $k_5+im_\\pi$ still above $[0,\\Lambda]$; no cut term")
    ax.set_title(f"({tag}) $E=\\delta_{{PV}}+{EPS_DEMO:g}-{g / 2:g}i$ MeV ($\\Gamma={g:g}$ MeV), "
                 f"$|{{\\rm Im}}\\,k_5|={abs(k5.imag):.1f}$ MeV\n{verdict}", fontsize=10)
    ax.text(0.99, 0.02, f"route 1: S40 path, $d_k={dm / 2:.1f}$ MeV, no extra term\n"
                        "route 3: through $k_5$ and $k_6$, pole subtracted", transform=ax.transAxes,
            ha="right", va="bottom", fontsize=8.6, bbox=dict(boxstyle="round", fc="white", ec="0.7"))
ax = fig2.add_subplot(gs[1, 0])
styles = {"route 1": ("k", "-", "o"), "route 3": ("tab:green", "-", "D"), "route 2": ("tab:blue", "-", "s"),
          "route 2, no cut term": ("tab:red", "--", "v"), "route 2, ratio log": ("tab:purple", ":", "^")}
labels = {"route 1": "route 1: S40 path below the pole",
          "route 3": "route 3: path through every flipped pole, pole subtracted",
          "route 2": "route 2: real axis + pole term + cut term",
          "route 2, no cut term": "route 2 without the cut term",
          "route 2, ratio log": "route 2 with the principal ratio log ${\\rm Log}(w_-/w_+)$"}
for key, (col, ls, mk) in styles.items():
    vals = np.maximum([r[key] for r in demo], 1e-33)
    ax.semilogy(GAMMAS, vals, ls=ls, marker=mk, color=col, ms=5, lw=1.5, label=labels[key])
ax.axvline(GC_DEMO, color="darkred", ls="--", lw=1.2)
ax.text(GC_DEMO + 0.3, 1e-12, f"$|{{\\rm Im}}\\,k_5|=m_\\pi$\n$\\Gamma={GC_DEMO:.1f}$ MeV", color="darkred", fontsize=9)
ax.text(2.2, 1e-27, "routes 1, 2 and 3 agree with the exact $J$ to the 30-digit working precision", fontsize=8.5)
ax.set_xlabel("$\\Gamma=-2\\,{\\rm Im}\\,E$ (MeV), at Re $E=\\delta_{PV}+1$ MeV")
ax.set_ylabel("relative error against $J=i\\pi\\,{\\rm Log}(1-2ip/m)$")
ax.set_ylim(1e-33, 10)
ax.grid(alpha=0.3, which="both")
ax.legend(fontsize=8.4, loc="center left")
ax.set_title("(c) App. D's $J(p;m)$, $p=k_5$, $m=m_\\pi$ (static Yukawa), 30 digits, adaptive quadrature",
             fontsize=10.5)
ax = fig2.add_subplot(gs[1, 1])
for (route, e), errs in conv.items():
    E = complex(DELTA_PV + e, -10.0)
    lab = (f"route 1, $d_k={dk_max(E) / 2:.2f}$ MeV" if route == 1 else "route 3") + f", {e:g} MeV above"
    ax.loglog(NODES, np.maximum(errs, 1e-17), ls="--" if e < 0.5 else "-", marker="o" if route == 1 else "D",
              color="k" if route == 1 else "tab:green", ms=5, label=lab)
ax.set_xscale("log", base=2)
ax.set_xticks(NODES, [str(n) for n in NODES], fontsize=8)
ax.set_xlabel("Gauss–Legendre nodes per segment")
ax.set_ylabel("relative error against the exact $J$")
ax.grid(alpha=0.3, which="both")
ax.legend(fontsize=8.6)
ax.set_title("(d) same $J$, fixed nodes, double precision, $\\Gamma=20$ MeV, above the PV threshold", fontsize=10.5)
handles2 = [Line2D([], [], color="k", lw=2.2, label="route 1: our S40 path"),
            Line2D([], [], color="tab:green", lw=2.2, label="route 3: through every flipped pole (S–P)"),
            Line2D([], [], color="tab:blue", lw=3.2, alpha=0.75, label="route 2: real axis"),
            Line2D([], [], ls="", marker="o", ms=11, mfc="white", mec="tab:blue", mew=1.8,
                   label="route 2: pole term $2\\pi i\\,{\\rm Res}_k$"),
            Line2D([], [], color="tab:blue", lw=4.5, label="route 2: cut term (both edges)"),
            Line2D([], [], ls=(0, (4, 3)), color="saddlebrown", label="principal cuts of ${\\rm Log}\\,w_-$ at $p=k_F$"),
            Line2D([], [], ls="", marker="*", ms=12, mfc="gold", mec="k", label="$k_F\\pm im_\\pi$"),
            Line2D([], [], ls="", marker="P", ms=7, mfc="gold", mec="k",
                   label="three-body points of $V_{\\rm TOPT}(k_F,q)$"),
            Patch(fc="0.92", label="$R(\\mathcal{C})$ of route 1")]
fig2.legend(handles=handles2, loc="upper center", ncol=5, fontsize=8.8, frameon=False, bbox_to_anchor=(0.5, 0.995))
fig2.tight_layout(rect=(0, 0, 1, 0.95))
fig2.savefig(f"{OUT}_routes.png", dpi=150)
print("\nwrote", f"{OUT}_where.png", "and", f"{OUT}_routes.png")
