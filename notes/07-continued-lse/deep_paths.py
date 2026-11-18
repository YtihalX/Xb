# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""S40 path quadrature: how far can the path be pushed from the propagator poles?

Figure 1 (deep_paths_geometry.png), q plane at E1 = -22.62 - 10i MeV, sheet (-,-,+):
  (a) the default S40 path with pole margin d_k = 20 MeV (the slow case of NOTEBOOK.md, Path quadrature),
  (b) the same builder with d_k = 197 MeV, the largest it admits at E1.
  Drawn: the path and its Gauss-Legendre nodes (32 per segment); the free-resolvent poles +-k_alpha
  (filled: flipped, inside R(C); open: unflipped fourth-quadrant pole, outside); the singular points of
  q -> V(p', q; E) as p' runs over the path: exchanged-meson points q = +-p' +- i m_phi (S33) and the genuine
  three-body (TOPT) points s_tau + nu_beta = 0 (S36, principal s, which is the lifted branch on graph paths,
  S34); and the fixed singular points of V(k_F, q; E) at the flipped on-shell momenta, which matter only for
  on-shell T, couplings and the on-shell-point identities (S32).
Figure 2 (deep_paths_limits.png):
  (a) relative error of the free loops J_alpha (form factor 1, as in checks/rank_one_paths.jl) against
      Gauss-Legendre nodes per segment, at E1, for several d_k;
  (b) the largest d_k the S40 builder admits against Re E;
  (c) slope-1 three-segment paths of growing depth H at E1: distances from the path to the poles and to the
      kernel's singular points, and the smallest Re Z over C x C;
  (d) first legs steeper than 1 (depth 300 MeV) at E1 and 2 MeV above the PV threshold.

The S40 builder (_s40geom.py) is a line-by-line replica of Xb2Continuation.graph_path
(code/Xb2Continuation/src/paths.jl), vertical (P) certification included; the script prints its vertices for
comparison with the package.
Run: uv run --script notes/07-continued-lse/deep_paths.py
A plot of the note's formulas, not a check. Units MeV.
"""
import math
from pathlib import Path

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402
from matplotlib.patches import Circle  # noqa: E402

from _s40geom import *  # noqa: E402,F403  shared constants, S40 builder replica, singular points

E1 = complex(-22.62, -10.0)
ENT = complex(-DM + 2.0, -10.0)  # 2 MeV above the PV threshold
OUT = Path(__file__).with_suffix("")


# ================================================================ numbers
fmt = lambda z: f"{z.real:.6f}{z.imag:+.6f}i"  # noqa: E731
print("E1 =", E1, "MeV; poles (fourth-quadrant member):")
for p in poles(E1):
    print(f"  {p['name']}: {'+' if p['flipped'] else '-'}k_{p['idx']} = {fmt(p['q4'])}  flipped={p['flipped']}")
print("S40 default paths at E1 (compare: package 351.581311-94.838622i -> 3905.161378-94.838622i at 20 MeV):")
paths = {}
for d in (5.0, 20.0, 40.0, 100.0, 197.0, 199.0):
    V = s40_path(E1, d)
    paths[d] = V
    if V is None:
        print(f"  d_k = {d:5.1f} MeV: excluded")
        continue
    exact = loops_closed(E1)
    cauchy = loops_cauchy(V, E1)
    print(f"  d_k = {d:5.1f} MeV: {' -> '.join(fmt(v) for v in V)}; first-leg slope {-V[1].imag / V[1].real:.3f};"
          f" pole margin {pole_margin(V, E1):.2f}; |Cauchy-closed|/|closed| = "
          f"{np.max(np.abs(cauchy - exact) / np.abs(exact)):.1e}")

NODES = (8, 12, 16, 24, 32, 48, 64, 96, 128, 192, 256)
DKS = (5.0, 20.0, 40.0, 100.0, 197.0)
conv = {}
exact = loops_closed(E1)
print("\nworst relative loop error over (VV, PV, PP) at E1 [package at 20 MeV: n=64 3.4e-04, n=128 2.7e-07]:")
for d in DKS:
    conv[d] = [np.max(np.abs(loops_gl(paths[d], E1, n) - exact) / np.abs(exact)) for n in NODES]
    print(f"  d_k = {d:5.1f}: " + "  ".join(f"n={n}:{e:.1e}" for n, e in zip(NODES, conv[d]) if n in (16, 32, 64, 128)))

print("\nkernel singular points at E1 (smallest distance from the path, MeV):")
for d in (20.0, 197.0):
    d_ex, d_tb = kernel_distances(paths[d], E1, n=4000)
    print(f"  d_k = {d:5.1f}: exchanged-meson {d_ex:.2f}, three-body {d_tb:.2f}, poles {pole_margin(paths[d], E1):.2f}")
    pts = [(side, inside(paths[d], z)) for _, _, side, z in onshell_points(E1)]
    print(f"           on-shell points of V(k_F, q) inside R(C): {sum(i for _, i in pts)} of {len(pts)}; down points"
          f" (swept by C): {sum(i for s, i in pts if s == 'down')}, up points (crossed [0, Lambda]):"
          f" {sum(i for s, i in pts if s == 'up')}")

# ---- depth scan, slope-1 family at E1
HS = np.concatenate([np.arange(80.0, 400.0, 10.0), np.arange(400.0, 1960.0, 40.0)])
depth = {"pole": [], "ex": [], "tb": []}
for H in HS:
    V = leg_path(H)
    depth["pole"].append(pole_margin(V, E1))
    d_ex, d_tb = kernel_distances(V, E1)
    depth["ex"].append(d_ex)
    depth["tb"].append(d_tb)
HZ = np.array([80.0, 200.0, 300.0, 500.0, 609.0, 800.0, 1200.0, 1600.0, 1950.0])
reZ = []
print("\nslope-1 paths at E1: min Re Z over C x C (sampled) against S35 as printed, 47.58 - H^2/mB - Re E:")
for H in HZ:
    best, where = min_re_Z(leg_path(H), E1)
    reZ.append(best)
    print(f"  H = {H:6.0f}: min Re Z = {best:7.2f} MeV ({where[0]}, beta={where[1]}, tau={where[2]:+d}, "
          f"p'={where[3].real:.0f}{where[3].imag:+.0f}i, q={where[4].real:.0f}{where[4].imag:+.0f}i, |Z|={where[5]:.1f});"
          f" S35 bound {E3 - H * H / mB - E1.real:7.2f}")
print("  three-body points: smallest distance over the depth scan "
      f"{np.min(depth['tb']):.2f} MeV at H = {HS[int(np.argmin(depth['tb']))]:.0f} MeV")

# ---- steep first legs, depth 300 MeV
SL = np.geomspace(0.25, 6.0, 60)
steep = {}
for E in (E1, ENT):
    rows = {"pole": [], "ex": [], "tb": []}
    for s in SL:
        V = leg_path(300.0, s)
        rows["pole"].append(pole_margin(V, E))
        d_ex, d_tb = kernel_distances(V, E)
        rows["ex"].append(d_ex)
        rows["tb"].append(d_tb)
    steep[E] = {k: np.array(v) for k, v in rows.items()}
    both = np.minimum(steep[E]["pole"], steep[E]["tb"])  # NaN where the sheet placement fails
    best = np.nanargmax(both)
    print(f"\nsteep legs at E = {E}: best min(pole, three-body) = {both[best]:.1f}"
          f" MeV at slope {SL[best]:.2f}; there exchanged-meson {steep[E]['ex'][best]:.1f}, three-body "
          f"{steep[E]['tb'][best]:.1f}, poles {steep[E]['pole'][best]:.1f}")
    i1 = np.argmin(np.abs(SL - 1.0))
    print(f"  at slope {SL[i1]:.2f}: poles {steep[E]['pole'][i1]:.1f}, three-body {steep[E]['tb'][i1]:.1f}")

# ---- largest admitted d_k against Re E
REs = np.arange(-88.0, 45.01, 0.5)
IMS = (-1.0, -10.0, -50.0)
dmax = {y: np.array([largest_dk(complex(x, y)) for x in REs]) for y in IMS}
DK_E1 = largest_dk(E1)
print(f"\nlargest d_k admitted by the S40 builder (MeV); at E1: {DK_E1:.2f}")
for x in (-80.0, -67.5, -50.0, -40.0, -22.5, -5.0, 5.0, 22.5, 40.0):
    i = int(np.argmin(np.abs(REs - x)))
    print(f"  Re E = {REs[i]:6.1f}: " + "  ".join(f"Im E={y:g}: {dmax[y][i]:6.1f}" for y in IMS))
for y in IMS:
    ok = dmax[y] >= MPHI["pi"] / math.sqrt(2)
    print(f"  Im E = {y:g}: d_k >= m_pi/sqrt2 on {100 * np.mean(ok):.0f}% of the Re E grid")

# ================================================================ figure 1: geometry
BCOL = {1: "tab:orange", 2: "tab:green", 3: "tab:purple", 4: "tab:purple"}


def draw(ax, V, E, d, nodes=32, full=True):
    xs, ys = [v.real for v in V], [v.imag for v in V]
    ax.fill_between(xs, ys, 0, color="0.92", zorder=0)
    ax.axhline(0, color="0.75", lw=0.6, zorder=0)
    ax.axvline(0, color="0.75", lw=0.6, zorder=0)
    ax.plot([0, 1200], [0, -1200], ":", color="0.4", lw=1.0)
    pp = sample(V, 6000)
    if full:
        for phi in ("eta", "pi"):
            for beta in (1, 2, 3, 4):
                pts = three_body_all(pp, E, mesons=(phi,), betas=(beta,))
                ax.plot(pts.real, pts.imag, ".", ms=1.6 if phi == "pi" else 1.0, color=BCOL[beta],
                        alpha=1.0 if phi == "pi" else 0.45, rasterized=True, zorder=2)
        for m, ls in ((MPHI["pi"], "--"), (MPHI["eta"], "-.")):
            for sp in (1, -1):
                for sm in (1, -1):
                    z = sp * pp + sm * 1j * m
                    ax.plot(z.real, z.imag, ls, color="0.25", lw=0.9, zorder=3)
        ex_k, tb_k = fixed_k_points(E)
        ax.plot(ex_k.real, ex_k.imag, "*", ms=11, mfc="gold", mec="k", mew=0.8, zorder=7)
        ax.plot(tb_k.real, tb_k.imag, "P", ms=7, mfc="gold", mec="k", mew=0.8, zorder=7)
    ax.plot(xs, ys, "-", color="k", lw=2.4, zorder=5)
    q, _ = gl_rule(V, nodes)
    ax.plot(q.real, q.imag, "o", ms=2.6, color="white", mec="k", mew=0.6, zorder=6)
    for p in poles(E):
        z = p["q4"]
        if p["flipped"]:
            ax.plot(z.real, z.imag, "o", ms=8, color="crimson", zorder=8)
        else:
            ax.plot(z.real, z.imag, "o", ms=8, mfc="white", mec="navy", mew=2, zorder=8)
        ax.plot(-z.real, -z.imag, "x", ms=7, color="0.35", mew=1.5, zorder=8)
        ax.add_patch(Circle((z.real, z.imag), d, fill=False, color="crimson" if p["flipped"] else "navy",
                            lw=1.0, ls="-", zorder=7))


fig1, axes1 = plt.subplots(1, 2, figsize=(17, 7.9))
titles = {20.0: "(a) default S40 path, $d_k=20$ MeV (the slow case)",
          197.0: "(b) same builder, $d_k=197$ MeV (the largest it admits at $E_1$)"}
for ax, d in zip(axes1, (20.0, 197.0)):
    V = paths[d]
    draw(ax, V, E1, d)
    ax.set_xlim(-250, 1150)
    ax.set_ylim(-680, 330)
    ax.set_aspect("equal")
    ax.set_xlabel("Re $q$ (MeV)")
    ax.set_ylabel("Im $q$ (MeV)")
    ax.set_title(titles[d], fontsize=11)
    for p in poles(E1):
        z = p["q4"]
        lab = f"{'+' if p['flipped'] else '-'}$k_{p['idx']}$ ({p['name']})"
        ax.annotate(lab, (z.real, z.imag), xytext=(-8, 9) if p["flipped"] else (9, 5), textcoords="offset points",
                    ha="right" if p["flipped"] else "left", fontsize=9,
                    color="crimson" if p["flipped"] else "navy", zorder=9)
    d_ex, d_tb = kernel_distances(V, E1, n=4000)
    upper = d == 20.0
    ax.text(0.985, 0.985 if upper else 0.015,
            f"$E_1={E1.real:g}{E1.imag:+g}i$ MeV, sheet $(-,-,+)$\n"
            f"depth {-V[1].imag:.1f} MeV, first-leg slope {-V[1].imag / V[1].real:.2f}\n"
            f"flat to {V[2].real:.0f} MeV, then back to $\\Lambda=4$ GeV\n"
            f"nearest pole: {pole_margin(V, E1):.1f} MeV\n"
            f"nearest exchanged-meson point: {d_ex:.1f} MeV\n"
            f"nearest three-body point: {d_tb:.1f} MeV\n"
            f"free-loop error, 64 nodes/segment: {conv[d][NODES.index(64)]:.1e}",
            transform=ax.transAxes, fontsize=8.4, va="top" if upper else "bottom", ha="right",
            bbox=dict(boxstyle="round", fc="white", ec="0.7"), zorder=10)
    ax.annotate("", xy=(1150, V[2].imag), xytext=(1060, V[2].imag),
                arrowprops=dict(arrowstyle="->", color="k", lw=1.5))
axins = axes1[0].inset_axes([0.40, 0.025, 0.59, 0.27])
draw(axins, paths[20.0], E1, 20.0, full=False)
axins.set_xlim(300, 680)
axins.set_ylim(-125, 5)
axins.set_aspect("equal")
axins.tick_params(labelsize=7)
axins.text(0.01, 0.04, "zoom: 32 nodes/segment, 20 MeV circles", transform=axins.transAxes, fontsize=8)
axes1[0].indicate_inset_zoom(axins, edgecolor="0.4")
has_b2 = any(three_body_all(sample(paths[d], 3000), E1, betas=(2,)).size for d in (20.0, 197.0))
print("three-body points with beta = 2 on either plotted path:", has_b2)
handles = [
    Line2D([], [], color="k", lw=2.4, marker="o", ms=4, mfc="white", label="path $\\mathcal{C}$, 32 GL nodes per segment"),
    Line2D([], [], color="0.92", lw=8, label="$R(\\mathcal{C})$, between $[0,\\Lambda]$ and $\\mathcal{C}$"),
    Line2D([], [], ls="", marker="o", ms=8, color="crimson", label="flipped $+k_\\alpha$ (must lie in $R$)"),
    Line2D([], [], ls="", marker="o", ms=8, mfc="white", mec="navy", mew=2, label="unflipped $-k_\\alpha$ (outside)"),
    Line2D([], [], ls="", marker="x", ms=7, color="0.35", mew=1.5, label="partner pole $\\mp k_\\alpha$"),
    Line2D([], [], ls=":", color="0.4", label="slope-1 line through 0"),
    Line2D([], [], ls="--", color="0.45", label="$q=\\pm p'\\pm im_\\pi$, $p'\\in\\mathcal{C}$ (S33)"),
    Line2D([], [], ls="-.", color="0.45", label="$q=\\pm p'\\pm im_\\eta$"),
    Line2D([], [], ls="", marker="o", ms=4, color=BCOL[1], label="three-body $\\beta=1$ ($B\\bar B\\pi$), $p'\\in\\mathcal{C}$"),
    *([Line2D([], [], ls="", marker="o", ms=4, color=BCOL[2], label="three-body $\\beta=2$ ($B^*\\bar B^*\\pi$)")]
      if has_b2 else []),
    Line2D([], [], ls="", marker="o", ms=4, color=BCOL[3], label="three-body $\\beta=3,4$ ($B\\bar B^*\\pi$); faint: $\\eta$"),
    Line2D([], [], ls="", marker="*", ms=11, mfc="gold", mec="k", label="$k_F\\pm im_\\pi$: $V(k_F,q)$, on-shell only (S32)"),
    Line2D([], [], ls="", marker="P", ms=7, mfc="gold", mec="k", label="three-body points of $V(k_F,q)$"),
]
fig1.legend(handles=handles, loc="lower center", ncol=4, fontsize=8.6, frameon=False)
fig1.suptitle("S40: the path, the free-resolvent poles and the singular points of $V^{\\rm(OME)}(p',q;E)$ "
              "in the loop-momentum plane", fontsize=12)
fig1.tight_layout(rect=(0, 0.1, 1, 0.96))
fig1.savefig(f"{OUT}_geometry.png", dpi=150)

# ================================================================ figure 2: limits
fig2, ax2 = plt.subplots(2, 2, figsize=(15, 11))
ax = ax2[0, 0]
for d, col in zip(DKS, plt.cm.viridis(np.linspace(0, 0.85, len(DKS)))):
    ax.loglog(NODES, conv[d], "o-", color=col, label=f"$d_k={d:g}$ MeV (depth {-paths[d][1].imag:.0f})")
ax.set_xscale("log", base=2)
ax.set_xticks(NODES, [str(n) for n in NODES], fontsize=8)
ax.set_xlabel("Gauss–Legendre nodes per segment")
ax.set_ylabel("worst $|J^{\\rm path}_\\alpha-J_\\alpha|/|J_\\alpha|$ over VV, PV, PP")
ax.set_title(f"(a) free loops on the S40 path at $E_1={E1.real:g}{E1.imag:+g}i$ MeV", fontsize=10.5)
ax.grid(alpha=0.3, which="both")
ax.legend(fontsize=8.5)

ax = ax2[0, 1]
for y, col in zip(IMS, ("tab:blue", "k", "tab:red")):
    ax.plot(REs, dmax[y], "-", color=col, lw=1.6, label=f"Im $E={y:g}$ MeV")
# S35 as printed allows depth H < sqrt(mB (E3 - Re E)); the builder's depth is max|Im k_F| + d_k.
cap10 = []
for x in REs:
    deepest = max((-p["q4"].imag for p in poles(complex(x, -10.0)) if p["flipped"]), default=np.nan)
    cap10.append(math.sqrt(mB * (E3 - x)) - deepest)
ax.plot(REs, np.minimum(dmax[-10.0], np.array(cap10)), ":", color="k", lw=1.6,
        label="Im $E=-10$ MeV, depth capped by S35 as printed")
for _, delta, _, idx in CH:
    ax.axvline(delta, color="0.6", lw=0.8)
top = ax.secondary_xaxis("top")
top.set_xticks([delta for _, delta, _, _ in CH], [f"{name} threshold" for name, _, _, _ in CH], fontsize=8)
ax.axhline(20, color="0.3", ls=":", lw=1, label="20 MeV: panel (a) of the geometry figure")
ax.axhline(MPHI["pi"] / math.sqrt(2), color="tab:green", ls="--", lw=1,
           label="$m_\\pi/\\sqrt{2}$: exchanged-meson points next to a slope-1 leg")
ax.plot([E1.real], [DK_E1], "o", color="crimson", ms=6)
ax.annotate("$E_1$", (E1.real, DK_E1), xytext=(5, 6), textcoords="offset points", fontsize=8.5, color="crimson")
ax.set_xlim(-92, 45)
ax.set_ylim(0, 410)
ax.set_xlabel("Re $E$ (MeV, from the $B^*\\bar B^*$ threshold)")
ax.set_ylabel("largest pole margin $d_k$ the S40 builder admits (MeV)")
ax.set_title("(b) how far the S40 path can stay from the poles", fontsize=10.5)
ax.grid(alpha=0.3)
ax.legend(fontsize=8.2, loc="upper center")

ax = ax2[1, 0]
ax.plot(HS, depth["pole"], "-", color="crimson", lw=1.8, label="poles $\\pm k_\\alpha$")
ax.plot(HS, depth["ex"], "--", color="0.35", lw=1.6, label="exchanged-meson points, $p'\\in\\mathcal{C}$")
ax.plot(HS, depth["tb"], "-", color="tab:orange", lw=1.8, label="three-body (TOPT) points, $p'\\in\\mathcal{C}$")
ax.axvline(-paths[197.0][1].imag, color="crimson", ls=":", lw=1)
ax.text(-paths[197.0][1].imag + 15, 380, "S40, $d_k=197$", fontsize=8, color="crimson", rotation=90, va="top")
HS35 = math.sqrt(mB * (E3 - E1.real))
ax.axvline(HS35, color="k", ls=":", lw=1)
ax.text(HS35 + 15, 380, "S35 bound as printed", fontsize=8, rotation=90, va="top")
ax.set_xlabel("depth $H$ of the slope-1 path $0\\to H(1-i)\\to\\Lambda-H-iH\\to\\Lambda$ (MeV)")
ax.set_ylabel("smallest distance from the path (MeV)")
ax.set_ylim(0, 400)
ax.set_xlim(HS[0], HS[-1])
ax.grid(alpha=0.3)
ax.text(0.98, 0.62,
        "min Re $Z$ over $\\mathcal{C}\\times\\mathcal{C}$ (600$\\times$600 pairs, $\\pi$ and $\\eta$, all $\\beta$):\n"
        f"{min(reZ):.2f}–{max(reZ):.2f} MeV for every $H$ in {HZ[0]:.0f}–{HZ[-1]:.0f} MeV,\n"
        f"i.e. $E_{{3,1}}-{{\\rm Re}}\\,E_1={E3 - E1.real:.2f}$ MeV; S35 as printed: "
        f"$E_{{3,1}}-H^2/m_B-{{\\rm Re}}\\,E_1<0$ beyond {HS35:.0f} MeV",
        transform=ax.transAxes, fontsize=8, ha="right", va="top", bbox=dict(boxstyle="round", fc="white", ec="0.7"))
ax.legend(fontsize=8.2, loc="upper right")
ax.set_title("(c) deeper paths, slopes $\\leq1$, at $E_1$", fontsize=10.5)

ax = ax2[1, 1]
for E, ls in ((E1, "-"), (ENT, "--")):
    r = steep[E]
    ax.plot(SL, r["pole"], ls, color="crimson", lw=1.8)
    ax.plot(SL, r["tb"], ls, color="tab:orange", lw=1.8)
    ax.plot(SL, r["ex"], ls, color="0.35", lw=1.2)
r = steep[ENT]
both = np.minimum(r["pole"], np.minimum(r["tb"], r["ex"]))
ib = int(np.nanargmax(both))
ax.plot([SL[ib]], [both[ib]], "o", color="k", ms=6)
ax.annotate(f"best near threshold: {both[ib]:.0f} MeV at slope {SL[ib]:.2f}", (SL[ib], both[ib]),
            xytext=(-10, -28), textcoords="offset points", fontsize=8, ha="center")
ax.axvline(1.0, color="k", ls=":", lw=1)
ax.text(0.97, 395, "slope 1 (S35)", fontsize=8, rotation=90, va="top", ha="right")
ax.set_xscale("log")
ax.xaxis.set_minor_formatter(matplotlib.ticker.NullFormatter())
ax.set_xticks([0.25, 0.5, 1, 2, 3, 4, 6], ["0.25", "0.5", "1", "2", "3", "4", "6"])
ax.set_xlabel("first-leg slope (path $0\\to x_1-300i\\to3700-300i\\to\\Lambda$, $x_1=300$ MeV / slope)")
ax.set_ylabel("smallest distance from the path (MeV)")
ax.set_ylim(0, 400)
ax.grid(alpha=0.3)
ax.legend(handles=[Line2D([], [], color="crimson", lw=1.8, label="poles $\\pm k_\\alpha$"),
                   Line2D([], [], color="tab:orange", lw=1.8, label="three-body (TOPT) points"),
                   Line2D([], [], color="0.35", lw=1.2, label="exchanged-meson points"),
                   Line2D([], [], color="k", ls="-", label=f"$E_1={E1.real:g}{E1.imag:+g}i$"),
                   Line2D([], [], color="k", ls="--", label=f"${ENT.real:.2f}{ENT.imag:+g}i$: PV threshold + 2 MeV")],
          fontsize=8, loc="upper right")
ax.set_title("(d) steeper first legs: poles against the kernel's singular points", fontsize=10.5)
fig2.suptitle("S40: pushing the path away from the poles, and what the TOPT kernel allows", fontsize=12)
fig2.tight_layout(rect=(0, 0, 1, 0.97))
fig2.savefig(f"{OUT}_limits.png", dpi=150)
print("\nwrote", f"{OUT}_geometry.png", "and", f"{OUT}_limits.png")
