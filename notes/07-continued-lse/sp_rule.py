# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""S40 proposal: the path through every flipped pole (sp_polygon), region by region. A plot of the note's formulas,
not a check; it backs notes/07-continued-lse/s40-proposal.tex.

Figure (sp_rule.png):
  (a) the energy plane: the strips between thresholds with the sheet attached there (S27), the search domain of this
      phase (Gamma <= 20 MeV on (-,+,+) and (-,-,+)), the widenings (Gamma <= 100 MeV; (-,-,-) above threshold),
      bound states on [0, Lambda], the excluded threshold lines, the region Re E >= E_31 = 47.58 MeV, and the probe
      energies of panels (b)-(g).
  (b)-(g) the path C(E) in the q plane at one probe energy per scenario: the flipped poles on it (vertices, pole
      subtracted), the unflipped fourth-quadrant poles, the slope-1 line, and the singular points of V(p', q; E) for
      p' on C: exchanged-meson (q = +-p' +- i m, S33) and three-body (S36), pion and eta, all orderings.
Scan (printed): per region, the largest slope of C(E); the smallest distance from C(E) to the exchanged-meson and to
the three-body points with p' on C; to the unflipped poles (with |k| of the nearest, to show the near-origin case);
and S35 as printed, 47.58 - H^2/m_B - Re E with H the depth of C(E), against the bound without the H^2 term.

Run: uv run --script notes/07-continued-lse/sp_rule.py
Units MeV.
"""
import math
from pathlib import Path

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402
from matplotlib.patches import Patch, Rectangle  # noqa: E402

from _s40geom import *  # noqa: E402,F403  shared constants, sp_polygon, singular points

OUT = Path(__file__).with_suffix("")
DPP, DPV, DVV = CH[2][1], CH[1][1], CH[0][1]


def scan_point(E):
    V = sp_polygon(E)
    slope = max(abs((b - a).imag) / (b - a).real for a, b in zip(V[:-1], V[1:]))
    d_ex, d_tb = kernel_distances(V, E, n=1600)
    unfl = [(path_dist(V, p["q4"]), abs(p["k"])) for p in poles(E) if not p["flipped"]]
    assert not any(inside(V, p["q4"]) for p in poles(E) if not p["flipped"])
    d_un, k_un = min(unfl) if unfl else (np.inf, np.nan)
    H = max(-v.imag for v in V)
    return slope, d_ex, d_tb, d_un, k_un, E3 - H * H / mB - E.real, E3 - E.real


def offsets(lo, hi):
    """Re E just above lo and just below hi, plus the middle."""
    near = (0.05, 0.2, 1.0, 3.0, 10.0)
    xs = [lo + e for e in near] + [0.5 * (lo + hi)] + [hi - e for e in near]
    return [x for x in xs if lo < x < hi]


REGIONS = {
    "bound states, [0, Lambda] (Im E = 0)": [complex(x, 0.0) for x in (-700.0, -300.0, -130.0, -100.0, -91.0)],
    "(-,+,+), Gamma <= 20 (search domain)": [complex(x, y) for x in offsets(DPP, DPV) for y in (-0.5, -2.0, -5.0, -10.0)],
    "(-,-,+), Gamma <= 20 (search domain)": [complex(x, y) for x in offsets(DPV, DVV) for y in (-0.5, -2.0, -5.0, -10.0)],
    "(-,+,+) and (-,-,+), 20 < Gamma <= 100": [complex(x, y) for x in offsets(DPP, DPV) + offsets(DPV, DVV)
                                               for y in (-20.0, -35.0, -50.0)],
    "(-,-,-), 0 < Re E < 37.58, Gamma <= 100": [complex(x, y) for x in (0.05, 0.2, 1.0, 3.0, 10.0, 20.0, 30.0)
                                                for y in (-0.5, -5.0, -10.0, -25.0, -50.0)],
    "(-,-,-), 37.58 <= Re E < 47.58, Gamma <= 100": [complex(x, y) for x in (37.6, 40.0, 43.0, 45.0, 46.5)
                                                     for y in (-0.5, -5.0, -10.0, -25.0, -50.0)],
}
print("region: largest slope | nearest exchanged-meson, three-body point | nearest unflipped pole (|k| there) | "
      "S35 as printed (min over E) | without H^2 (min)")
summary = {}
for name, Es in REGIONS.items():
    rows = np.array([scan_point(E) for E in Es])
    i_un = int(np.nanargmin(rows[:, 3])) if np.isfinite(rows[:, 3]).any() else None
    summary[name] = rows
    un = f"{rows[i_un, 3]:6.1f} ({rows[i_un, 4]:5.1f})" if i_un is not None else "  none      "
    print(f"{name:46s}: {rows[:, 0].max():.3f} | {rows[:, 1].min():6.1f}, {rows[:, 2].min():6.1f} | {un} | "
          f"{rows[:, 5].min():7.2f} | {rows[:, 6].min():6.2f}   ({len(Es)} energies)")
    if "37.58 <=" in name:
        for E, r in zip(Es, rows):
            if E.imag == -10.0:
                print(f"    {E}: nearest three-body point {r[2]:.1f} MeV")

# ================================================================ figure
PROBES = {
    "b": (complex(-110.0, 0.0), "bound states: $F=\\emptyset$, $\\mathcal{C}=[0,\\Lambda]$"),
    "c": (complex(-67.85, -10.0), "$(-,+,+)$: $0\\to k_6\\to\\Lambda$"),
    "d": (complex(DPV + 0.1, -10.0), "$(-,-,+)$, 0.1 MeV above the PV threshold"),
    "e": (complex(-2.0, -10.0), "$(-,-,+)$, 2 MeV below the VV threshold"),
    "f": (complex(-22.62, -1.0), "$(-,-,+)$, $\\Gamma=2$ MeV"),
    "g": (complex(20.0, -10.0), "$(-,-,-)$ (widening): $0\\to k_1\\to k_5\\to k_6\\to\\Lambda$"),
}
fig = plt.figure(figsize=(21, 9.6))
gs = fig.add_gridspec(2, 4, width_ratios=(1.25, 1, 1, 1))
ax = fig.add_subplot(gs[:, 0])
ax.add_patch(Rectangle((DPP, -10), DPV - DPP, 10, fc="#a6dba0", ec="none", label="search domain (S1)"))
ax.add_patch(Rectangle((DPV, -10), DVV - DPV, 10, fc="#a6dba0", ec="none"))
ax.add_patch(Rectangle((DPP, -50), DVV - DPP, 40, fc="#e5f5e0", ec="none", label="widening: $\\Gamma\\leq100$ MeV"))
ax.add_patch(Rectangle((DVV, -50), E3 - 10 - DVV, 50, fc="#fee8c8", ec="none", label="widening: $(-,-,-)$"))
ax.add_patch(Rectangle((E3 - 10, -50), 10, 50, fc="#fdbb84", ec="none",
                       label="$(-,-,-)$, within 10 MeV of $E_{3,1}$: grade towards $q=0$"))
ax.add_patch(Rectangle((E3, -50), 20, 55, fc="white", ec="0.3", hatch="///", label="$\\mathrm{Re}\\,E\\geq E_{3,1}$: outside"))
ax.plot([-140, DPP], [0, 0], color="tab:blue", lw=4, solid_capstyle="butt", label="bound states on $[0,\\Lambda]$")
for d, lab in ((DPP, "$2m_B$"), (DPV, "$m_B+m_{B^*}$"), (DVV, "$2m_{B^*}$")):
    ax.axvline(d, color="k", lw=1.0, ls="--")
    ax.text(d, 2.2, lab, ha="center", fontsize=9)
for x0, x1, sheet in ((-140, DPP, "$(+,+,+)$"), (DPP, DPV, "$(-,+,+)$"), (DPV, DVV, "$(-,-,+)$"), (DVV, E3, "$(-,-,-)$")):
    ax.text(0.5 * (max(x0, -135) + x1), -53.5, sheet, ha="center", fontsize=9.5)
for tag, (E, _) in PROBES.items():
    ax.plot(E.real, E.imag, "o", color="k", ms=5)
    ax.annotate(f"({tag})", (E.real, E.imag), xytext=(4, -11), textcoords="offset points", fontsize=9)
ax.axvspan(-30, 0, ymin=0, ymax=1, color="none")
ax.annotate("$X_{b2}$ region of interest", xy=(-12, -6), xytext=(-75, -30), fontsize=9,
            arrowprops=dict(arrowstyle="->", color="0.3"))
ax.set_xlim(-140, 68)
ax.set_ylim(-56, 5)
ax.set_xlabel("Re $E$ (MeV, from $2m_{B^*}$)")
ax.set_ylabel("Im $E$ (MeV)")
ax.set_title("(a) one rule: the path through every flipped pole\n(dashed: thresholds, excluded lines; sheet: below)",
             fontsize=10.5)
ax.legend(fontsize=8.2, loc="lower left", bbox_to_anchor=(0.0, 0.07))
slots = [gs[0, 1], gs[0, 2], gs[0, 3], gs[1, 1], gs[1, 2], gs[1, 3]]
for slot, (tag, (E, title)) in zip(slots, PROBES.items()):
    ax = fig.add_subplot(slot)
    V = sp_polygon(E)
    xs, ys = [v.real for v in V], [v.imag for v in V]
    ax.fill_between(xs, ys, 0, color="0.92", zorder=0)
    ax.axhline(0, color="0.75", lw=0.6, zorder=0)
    ax.axvline(0, color="0.75", lw=0.6, zorder=0)
    ax.plot([0, 700], [0, -700], ":", color="0.4", lw=1.0)
    pp = sample(V, 2500)
    for m, ls in ((MPHI["pi"], "--"), (MPHI["eta"], "-.")):
        for sp in (1, -1):
            for sm in (1, -1):
                z = sp * pp + sm * 1j * m
                ax.plot(z.real, z.imag, ls, color="0.45", lw=0.8, zorder=2)
    for phi, col in (("pi", "tab:orange"), ("eta", "tab:purple")):
        pts = three_body_all(pp, E, mesons=(phi,))
        ax.plot(pts.real, pts.imag, ".", ms=1.2, color=col, alpha=0.8, rasterized=True, zorder=2)
    ax.plot(xs, ys, color="tab:green", lw=2.4, zorder=5)
    for p in poles(E):
        z = p["q4"]
        if p["flipped"]:
            ax.plot(z.real, z.imag, "o", ms=8, color="crimson", zorder=7)
            ax.annotate(f"$+k_{p['idx']}$", (z.real, z.imag), xytext=(5, -13), textcoords="offset points",
                        fontsize=9, color="crimson")
        else:
            ax.plot(z.real, z.imag, "o", ms=8, mfc="white", mec="navy", mew=2, zorder=7)
            ax.annotate(f"$-k_{p['idx']}$", (z.real, z.imag), xytext=(6, 3), textcoords="offset points",
                        fontsize=9, color="navy")
    slope, d_ex, d_tb, d_un, k_un, _, _ = scan_point(E)
    txt = (f"largest slope {slope:.2f}\nnearest exchanged-meson point {d_ex:.0f} MeV\n"
           f"nearest three-body point {d_tb:.0f} MeV")
    if np.isfinite(d_un):
        txt += f"\nnearest unflipped pole {d_un:.0f} MeV"
    ax.text(0.98, 0.03, txt, transform=ax.transAxes, ha="right", va="bottom", fontsize=8,
            bbox=dict(boxstyle="round", fc="white", ec="0.7"), zorder=9)
    ax.set_xlim(-60, 760)
    ax.set_ylim(-420, 200)
    ax.set_aspect("equal")
    ax.set_title(f"({tag}) $E={E.real:g}{E.imag:+g}i$ MeV\n{title}", fontsize=9.8)
    ax.set_xlabel("Re $q$ (MeV); the path goes on to $\\Lambda=4$ GeV", fontsize=8.5)
    ax.set_ylabel("Im $q$ (MeV)", fontsize=8.5)
    ax.tick_params(labelsize=8)
handles = [Line2D([], [], color="tab:green", lw=2.4, label="path $\\mathcal{C}(E)$"),
           Line2D([], [], ls="", marker="o", ms=8, color="crimson", label="flipped $+k_\\alpha$: a vertex, pole subtracted"),
           Line2D([], [], ls="", marker="o", ms=8, mfc="white", mec="navy", mew=2,
                  label="unflipped $-k_\\alpha$: below the slope-1 line"),
           Line2D([], [], ls=":", color="0.4", label="slope-1 line"),
           Line2D([], [], ls="--", color="0.45", label="$\\pm p'\\pm im_\\pi$, $p'\\in\\mathcal{C}$"),
           Line2D([], [], ls="-.", color="0.45", label="$\\pm p'\\pm im_\\eta$"),
           Line2D([], [], ls="", marker="o", ms=4, color="tab:orange", label="three-body points, $\\pi$"),
           Line2D([], [], ls="", marker="o", ms=4, color="tab:purple", label="three-body points, $\\eta$"),
           Patch(fc="0.92", label="$R(\\mathcal{C})$")]
fig.legend(handles=handles, loc="lower center", ncol=9, fontsize=8.6, frameon=False)
fig.tight_layout(rect=(0, 0.045, 1, 1))
fig.savefig(f"{OUT}.png", dpi=140)
print("\nwrote", f"{OUT}.png")
