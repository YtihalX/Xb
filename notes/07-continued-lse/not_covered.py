# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""Pictures of the cases the deformed SP method does not cover (s40-proposal.tex, Scenarios), with one covered case
for contrast. Computed from note 07's formulas but drawn for the idea; not a check. Units MeV.

(a) covered, for contrast: (-,-,+) at -22.62 - 10i; the path through the flipped poles, the singular points of
    V(p', q) for p' on the path (exchanged-meson, S33; three-body, S36; pion).
(b) the B*B-bar* on-shell momentum k_1 = sqrt(2 mu_1 E): which wedge of the k_1 plane each X_b2 scenario occupies,
    and the VV pion cut of the on-shell amplitude, k_1^2 < -m_pi^2/4 (note 06, Sec. lhc), on both halves.
(c) a B*B-bar* virtual state, E_B = 0.38 MeV: k_1 = -i kappa; the path squeezed onto the imaginary axis; the singular
    points that its vertical leg brings along: -p' - i m_pi (VV<-VV) and the B B-bar pi point of PV<-PV (beta = 1).
(d) the same against kappa: the shallowest of those points against the bottom of the leg; they meet at
    kappa = 52.1 MeV (beta = 1, one common path) and 69.0 MeV (m_pi / 2).
(e) a hidden pole: sheet (+,-,+) at -20 - 10i, PP unflipped above its threshold; the polygon through the flipped
    poles puts PP's pole inside R(C); the remedy; inset: the energy path that reaches the sheet.
(f) the B B-bar pi threshold: the beta = 1 three-body points of V(p', q) for real p' in [0, 500] MeV at real E.

Run: uv run --script notes/07-continued-lse/not_covered.py
"""
import cmath
import math
from pathlib import Path

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402
from matplotlib.patches import Arc, FancyArrowPatch, Patch, Polygon  # noqa: E402

from _s40geom import *  # noqa: E402,F403  constants, sp_polygon, poles, sample, three_body

OUT = Path(__file__).with_suffix("")
MPI = MPHI["pi"]
MU = {name: mu for name, _, mu, _ in CH}
DELTA = {name: d for name, d, _, _ in CH}
GREEN, RED, NAVY, ORANGE, BROWN, CUT = "tab:green", "crimson", "navy", "tab:orange", "saddlebrown", "darkred"


def root(E, name):
    """Principal sqrt(2 mu (E - delta)): the flipped pole, or the fourth-quadrant member of an unflipped pair."""
    return cmath.sqrt(2 * MU[name] * (E - DELTA[name]))


def qframe(ax, xl, yl, title):
    ax.axhline(0, color="0.6", lw=0.8, zorder=1)
    ax.axvline(0, color="0.8", lw=0.6, zorder=1)
    ax.set_xlim(*xl)
    ax.set_ylim(*yl)
    ax.set_aspect("equal")
    ax.set_xlabel("Re $q$ (MeV)")
    ax.set_ylabel("Im $q$ (MeV)")
    ax.set_title(title, fontsize=10.5)


def slope1(ax, r=1200.0):
    ax.plot([0, r], [0, -r], ":", color="0.35", lw=1.0, zorder=2)


def note(ax, x, y, text, **kw):
    kw.setdefault("fontsize", 8.4)
    ax.text(x, y, text, transform=ax.transAxes, bbox=dict(boxstyle="round", fc="white", ec="0.7"), zorder=12, **kw)


fig = plt.figure(figsize=(21, 13.6))
gs = fig.add_gridspec(2, 3)

# ================================================================ (a) covered, for contrast
ax = fig.add_subplot(gs[0, 0])
E = complex(-22.62, -10.0)
V = sp_polygon(E)
qframe(ax, (-60, 760), (-420, 200), "(a) covered, for contrast: $(-,-,+)$, $E=-22.6-10i$ MeV")
slope1(ax)
ax.fill_between([v.real for v in V], [v.imag for v in V], 0, color="0.9", zorder=0)
pp = sample(V, 2500)
for sp in (1, -1):
    for sm in (1, -1):
        z = sp * pp + sm * 1j * MPI
        ax.plot(z.real, z.imag, "--", color="0.5", lw=0.8, zorder=2)
tb = three_body_all(pp, E, mesons=("pi",))
ax.plot(tb.real, tb.imag, ".", ms=1.3, color=ORANGE, zorder=2, rasterized=True)
ax.plot([v.real for v in V], [v.imag for v in V], color=GREEN, lw=2.6, zorder=5)
for p in poles(E):
    z = p["q4"]
    if p["flipped"]:
        ax.plot(z.real, z.imag, "o", ms=8, color=RED, zorder=7)
        ax.annotate(f"$+k_{p['idx']}$", (z.real, z.imag), xytext=(4, -14), textcoords="offset points", color=RED)
    else:
        ax.plot(z.real, z.imag, "o", ms=8, mfc="white", mec=NAVY, mew=2, zorder=7)
        ax.annotate(f"$-k_{p['idx']}$ (unflipped)", (z.real, z.imag), xytext=(7, 2), textcoords="offset points",
                    color=NAVY)
note(ax, 0.47, 0.04, "flipped poles lie above the slope-1 line,\nso a path with slopes $\\leq1$ runs through them;\n"
                     "the kernel's singular points stay $\\geq90$ MeV away")

# ================================================================ (b) the k_1 plane
ax = fig.add_subplot(gs[0, 1])
R = 400.0
wedges = [([(0, 0), (R, 0), (R, -R)], "#c7e9c0", (-11, 0, 150),
           "$(-,-,-)$, Re $E>0$:\nresonance above\nthreshold: covered"),
          ([(0, 0), (R, -R), (0, -R)], "#fcbba1", (-67, 0, 175), "$(-,-,-)$, Re $E<0$:\nvirtual state:\nnot covered"),
          ([(0, 0), (0, R), (-R, R)], "#c6dbef", (112, 0, 180),
           "$(-,-,+)$, Re $E<0$:\nbound-state-like:\nposition covered"),
          ([(0, 0), (-R, R), (-R, 0)], "#fdd0a2", (158, 0, 175), "$(-,-,+)$, Re $E>0$:\nhidden pole:\nnot covered"),
          ([(0, 0), (R, 0), (R, R), (0, R)], "0.95", (45, 0, 175), "Im $E>0$\n(mirror image)"),
          ([(0, 0), (0, -R), (-R, -R), (-R, 0)], "0.95", (-135, 0, 175), "Im $E>0$\n(mirror image)")]
for verts, col, (ang, _, rad), lab in wedges:
    ax.add_patch(Polygon(verts, closed=True, fc=col, ec="none", zorder=0))
    a = math.radians(ang)
    ax.text(rad * math.cos(a), rad * math.sin(a), lab, ha="center", va="center", fontsize=8.2, zorder=6)
ax.plot([0, R], [0, -R], ":", color="0.3", lw=1.0)
ax.plot([0, -R], [0, R], ":", color="0.3", lw=1.0)
ax.axhline(0, color="0.5", lw=0.8)
ax.axvline(0, color="0.5", lw=0.8)
kc = MPI / 2
for s in (1, -1):
    ax.plot([0, 0], [s * kc, s * 255], color=CUT, lw=4.5, solid_capstyle="butt", zorder=5)
    ax.plot([0], [s * kc], "o", ms=7, mfc="white", mec=CUT, mew=2, zorder=6)
ax.annotate("VV pion cut, $k_1^2<-m_\\pi^2/4$:\n$|k_1|>69$ MeV, $E_B>0.89$ MeV", (0, 205), xytext=(18, 200), fontsize=8.2,
            color=CUT, va="center", arrowprops=dict(arrowstyle="->", color=CUT))
ax.annotate("", (0, -205), xytext=(18, -205), arrowprops=dict(arrowstyle="->", color=CUT))
ax.text(20, -205, "same cut", color=CUT, fontsize=8.2, va="center")
k52 = 52.13
ax.plot([-8, 8], [-k52, -k52], color="k", lw=1.6, zorder=6)
ax.annotate("$-52$ MeV: one common path\nfails here ($E_B=0.51$ MeV)", (-8, -k52), xytext=(-245, -40), fontsize=8,
            arrowprops=dict(arrowstyle="->", color="k", lw=0.8))
ax.text(150, -128, "Re $E=0$, Im $E<0$:\nthe threshold line", fontsize=8, rotation=-45, ha="center", va="center",
        color="0.25")
examples = [(complex(6, -6), "flipped", "resonance\n$6-6i$", (-20, -26)),
            (complex(-0.4, -0.3), "flipped", "virtual\n$-0.4-0.3i$", (8, -2)),
            (complex(-2.0, -0.3), "flipped", "virtual\n$-2-0.3i$", (8, -8)),
            (complex(-3.0, -1.0), "unflipped", "bound-like\n$-3-1i$", (-62, -4)),
            (complex(5.0, -10.0), "unflipped", "hidden\n$5-10i$", (7, -4))]
for Ex, kind, lab, offs in examples:
    k = cmath.sqrt(2 * MU["VV"] * Ex)
    if kind == "unflipped":
        k = -k  # physical-sheet root, Im k > 0
    ax.plot(k.real, k.imag, "*", ms=12, mfc="gold", mec="k", zorder=8)
    ax.annotate(lab, (k.real, k.imag), xytext=offs, textcoords="offset points", fontsize=7.8, zorder=9)
ax.set_xlim(-255, 255)
ax.set_ylim(-255, 255)
ax.set_aspect("equal")
ax.set_xlabel("Re $k_1$ (MeV)")
ax.set_ylabel("Im $k_1$ (MeV)")
ax.set_title("(b) the $B^*\\bar B^*$ momentum $k_1=\\sqrt{2\\mu_1E}$: where each $X_{b2}$ case lives\n"
             "(stars: example poles, $E$ in MeV from $2m_{B^*}$)", fontsize=10.5)

# ================================================================ (c) virtual state, geometry
ax = fig.add_subplot(gs[0, 2])
kap = 45.0
E = complex(-kap ** 2 / mV, 0.0)
k5, k6 = root(E, "PV"), root(E, "PP")
V = [0j, -1j * kap, k5, k6, complex(LAM, 0)]
qframe(ax, (-85, 245), (-170, 45),
       f"(c) $B^*\\bar B^*$ virtual state, $E_B={kap ** 2 / mV:.2f}$ MeV: $+k_1=-i\\kappa_1$, $\\kappa_1={kap:g}$ MeV")
ax.add_patch(Polygon([(0, 0), (300, -300), (0, -300)], closed=True, fc="#fde0dd", ec="none", zorder=0))
ax.text(18, -163, "no path with slopes $\\leq1$ enters this wedge", fontsize=8.4, color="firebrick")
slope1(ax)
ax.fill_between([v.real for v in V[:3]], [v.imag for v in V[:3]], 0, color="0.9", zorder=0)
ax.plot([v.real for v in V], [v.imag for v in V], color=GREEN, lw=2.6, zorder=5)
ax.plot(0, -kap, "o", ms=9, color=RED, zorder=8)
ax.annotate("$+k_1=-i\\kappa_1$", (0, -kap), xytext=(-62, -3), textcoords="offset points", color=RED,
            fontsize=9.5)
for g in (1.0, 3.0):
    z = cmath.sqrt(2 * MU["VV"] * complex(E.real, -g))
    ax.plot(z.real, z.imag, "o", ms=7, mfc="white", mec=RED, mew=1.5, zorder=8)
ax.annotate("the same pole at Im $E=-1,-3$ MeV:\nin the wedge, so the path needs\na leg steeper than 1",
            (cmath.sqrt(2 * MU["VV"] * complex(E.real, -3.0)).real, cmath.sqrt(2 * MU["VV"] * complex(E.real, -3.0)).imag),
            xytext=(110, -135), fontsize=8.2, color=RED, arrowprops=dict(arrowstyle="->", color=RED, lw=0.8))
off = 9.0
ax.plot([-off, -off], [-(MPI - kap), -MPI], color=BROWN, lw=5, solid_capstyle="butt", zorder=6)
ax.annotate("$-p'-im_\\pi$, $p'$ on the vertical leg\n(VV$\\leftarrow$VV exchange)", (-off, -(MPI - kap) - 10),
            xytext=(-80, 30), fontsize=8.0, color=BROWN, arrowprops=dict(arrowstyle="->", color=BROWN, lw=0.8))
legs = -1j * np.linspace(0.0, kap, 160)
tbv = np.concatenate([three_body(legs, E, MPI, 1, tau).ravel() for tau in (1, -1)])
tbv = tbv[~np.isnan(tbv)]
tbv = tbv[(np.abs(tbv.real) < 2.0) & (tbv.imag < 0)]
ax.plot(tbv.real + off, tbv.imag, "s", ms=3.2, color=ORANGE, zorder=6)
ax.annotate("$B\\bar B\\pi$ point of PV$\\leftarrow$PV,\n$p'$ on the vertical leg", (off + 2, -80),
            xytext=(105, -85), fontsize=8.0, color="chocolate", arrowprops=dict(arrowstyle="->", color=ORANGE, lw=0.8))
ax.text(0.99, 0.97, "bars drawn 9 MeV either side of the imaginary axis, on which they lie", transform=ax.transAxes,
        fontsize=7.4, color="0.35", ha="right", va="top")

# ================================================================ (d) virtual state, against kappa
ax = fig.add_subplot(gs[1, 0])
kaps = np.linspace(2.0, 90.0, 177)
tb_top = []
for kp in kaps:
    Ek = complex(-kp ** 2 / mV, 0.0)
    r = np.concatenate([three_body(-1j * np.linspace(0.0, kp, 90), Ek, MPI, 1, tau).ravel() for tau in (1, -1)])
    r = r[~np.isnan(r)]
    r = r[(np.abs(r.real) < 2.0) & (r.imag < 0)]
    tb_top.append(-r.imag.max() if r.size else np.nan)
tb_top = np.array(tb_top)
ax.fill_between(kaps, 0, kaps, color="#c7e9c0", zorder=0, label="the vertical leg: depth 0 to $\\kappa_1$")
ax.plot(kaps, MPI - kaps, color=BROWN, lw=2.2, label="shallowest $-p'-im_\\pi$ (VV$\\leftarrow$VV)")
ax.plot(kaps, tb_top, color=ORANGE, lw=2.2, label="shallowest $B\\bar B\\pi$ point (PV$\\leftarrow$PV)")
i_tb = int(np.nanargmin(np.abs(tb_top - kaps)))
for kx, lab, col in ((kaps[i_tb], f"one common path fails:\n$\\kappa_1={kaps[i_tb]:.0f}$ MeV, $E_B={kaps[i_tb] ** 2 / mV:.2f}$ MeV",
                      ORANGE),
                     (MPI / 2, f"the amplitude's own branch point:\n$\\kappa_1=m_\\pi/2={MPI / 2:.0f}$ MeV, "
                               f"$E_B={(MPI / 2) ** 2 / mV:.2f}$ MeV", BROWN)):
    ax.axvline(kx, color=col, ls="--", lw=1.0)
    ax.plot(kx, kx, "o", ms=8, color=col, zorder=6)
    ax.annotate(lab, (kx, kx), xytext=(kx - 47 if col == ORANGE else kx + 3, kx + 33 if col == ORANGE else kx - 40),
                fontsize=8.4, color="k", arrowprops=dict(arrowstyle="->", color=col, lw=0.9))
ax.set_xlim(0, 90)
ax.set_ylim(0, 145)
ax.set_xlabel("$\\kappa_1$ (MeV): virtual state at $k_1=-i\\kappa_1$")
ax.set_ylabel("depth below the real axis, $-\\mathrm{Im}\\,q$ (MeV)")
top = ax.secondary_xaxis("top", functions=(lambda k: np.sign(k) * k ** 2 / mV, lambda e: np.sqrt(np.abs(e) * mV)))
top.set_xticks([0.1, 0.3, 0.5, 0.89, 1.2, 1.5])
top.set_xlabel("$E_B$ (MeV)")
ax.legend(fontsize=8.4, loc="upper right")
ax.grid(alpha=0.3)
ax.set_title("(d) a deeper virtual state brings the singular points onto the path", fontsize=10.5)

# ================================================================ (e) hidden pole
ax = fig.add_subplot(gs[1, 1])
E = complex(-20.0, -10.0)
k5, q6, q1 = root(E, "PV"), root(E, "PP"), root(E, "VV")
V = [0j, k5, complex(LAM, 0)]
qframe(ax, (-60, 780), (-400, 130), "(e) hidden pole: sheet $(+,-,+)$ at $E=-20-10i$ MeV,\n"
                                    "$B\\bar B$ left unflipped above its threshold")
slope1(ax)
ax.fill_between([v.real for v in V], [v.imag for v in V], 0, color="0.9", zorder=0)
ax.plot([v.real for v in V], [v.imag for v in V], color=GREEN, lw=2.6, zorder=5)
ax.plot(k5.real, k5.imag, "o", ms=8, color=RED, zorder=8)
ax.annotate("$+k_5$ (flipped)", (k5.real, k5.imag), xytext=(-20, -18), textcoords="offset points", color=RED)
ax.plot(q6.real, q6.imag, "o", ms=9, mfc="white", mec=NAVY, mew=2, zorder=8)
ax.plot(q6.real, q6.imag, "x", ms=14, mew=2.2, color="firebrick", zorder=9)
ax.annotate("$PP$ pole, unflipped: must stay outside\n$R(\\mathcal{C})$, but the polygon puts it inside",
            (q6.real, q6.imag), xytext=(300, 75), fontsize=8.4, color=NAVY,
            arrowprops=dict(arrowstyle="->", color=NAVY, lw=0.8))
ax.plot(q1.real, q1.imag, "o", ms=8, mfc="white", mec=NAVY, mew=2, zorder=8)
ax.annotate("$VV$ pole, unflipped:\nbelow the path, fine", (q1.real, q1.imag), xytext=(10, -4), textcoords="offset points",
            fontsize=8.4, color=NAVY)
r_ind = 14.0
xs = [0, k5.real, q6.real - r_ind]
ys = [0, k5.imag, q6.imag + (k5.imag - q6.imag) * r_ind / (q6.real - k5.real)]
ax.plot(xs, ys, "--", color="tab:olive", lw=1.8, zorder=4)
ax.add_patch(Arc((q6.real, q6.imag), 2 * r_ind, 2 * r_ind, theta1=0, theta2=180, color="tab:olive", lw=1.8, ls="--"))
ax.plot([q6.real + r_ind, 780], [q6.imag, q6.imag * (LAM - 780) / (LAM - q6.real - r_ind)], "--", color="tab:olive",
        lw=1.8)
ax.annotate("remedy: a vertex at the $PP$ pole,\npassed above it", (q6.real + 16, q6.imag + 10), xytext=(440, -150),
            fontsize=8.4, color="tab:olive", arrowprops=dict(arrowstyle="->", color="tab:olive", lw=0.8))
ins = ax.inset_axes([0.47, 0.045, 0.5, 0.36])
ins.axhline(0, color="0.4", lw=0.8)
for d, lab in ((-90.46, "$2m_B$"), (-45.23, "$m_B+m_{B^*}$"), (0.0, "$2m_{B^*}$")):
    ins.plot(d, 0, "x", color="k", ms=6, mew=1.6)
    ins.text(d, 2.2, lab, ha="center", fontsize=7)
    ins.plot([d, 15], [0, 0], color=CUT, lw=1.0, alpha=0.5)
loop = [(-20, -6), (-100, -6), (-100, 7), (-70, 7), (-70, -12), (-22, -12)]
for (x0, y0), (x1, y1) in zip(loop[:-1], loop[1:]):
    ins.add_patch(FancyArrowPatch((x0, y0), (x1, y1), arrowstyle="->", mutation_scale=9, color="tab:blue", lw=1.3))
ins.plot(-20, -6, "o", ms=5, color="tab:blue")
ins.text(-17, -4.5, "start, on $(-,-,+)$", fontsize=7)
ins.text(-17, -14, "end, on $(+,-,+)$", fontsize=7)
ins.text(-106, -21.5, "circling the $B\\bar B$ threshold flips the $PP$ sign", fontsize=7)
ins.plot(-22, -12, "s", ms=5, color="tab:blue")
ins.set_xlim(-110, 12)
ins.set_ylim(-24, 12)
ins.set_xticks([])
ins.set_yticks([])
ins.set_title("energy plane", fontsize=7.5, pad=2)

# ================================================================ (f) three-body threshold
ax = fig.add_subplot(gs[1, 2])
qframe(ax, (-60, 280), (-110, 110), "(f) Re $E\\geq47.58$ MeV: the $B\\bar B\\pi$ points reach the path,\n"
                                    "first at its fixed endpoint $q=0$")
ax.plot([0, 280], [0, 0], color=GREEN, lw=2.6, zorder=3)
preal = np.linspace(0.0, 500.0, 700) + 0j
for Er, col in zip((37.0, 44.0, 47.58, 52.0, 60.0), plt.cm.plasma(np.linspace(0.05, 0.85, 5))):
    r = np.concatenate([three_body(preal, complex(Er, 0.0), MPI, 1, tau).ravel() for tau in (1, -1)])
    r = r[~np.isnan(r)]
    ax.plot(r.real, r.imag, ".", ms=2.4, color=col, zorder=4, label=f"$E={Er:g}$ MeV", rasterized=True)
ax.plot(0, 0, "s", ms=9, mfc="white", mec="k", mew=2, zorder=8)
ax.annotate("$q=0$: the endpoint\nevery path shares", (0, 0), xytext=(-55, -95), fontsize=8.4,
            arrowprops=dict(arrowstyle="->", color="k", lw=0.8))
ax.legend(fontsize=8.2, loc="upper right", markerscale=4, title="$B\\bar B\\pi$ points, real $p'\\in[0,500]$",
          title_fontsize=8)
note(ax, 0.02, 0.73, "below 47.58: in pairs off the real axis\nat 47.58: they pinch $q=0$\n"
                     "above: on the real path itself,\nthe $B\\bar B\\pi$ cut; new sheets", fontsize=8.2)

handles = [Line2D([], [], color=GREEN, lw=2.6, label="path $\\mathcal{C}$"),
           Patch(fc="0.9", label="$R(\\mathcal{C})$: between $[0,\\Lambda]$ and the path"),
           Line2D([], [], ls="", marker="o", ms=8, color=RED, label="flipped pole (inside $R$)"),
           Line2D([], [], ls="", marker="o", ms=8, mfc="white", mec=NAVY, mew=2, label="unflipped pole (outside $R$)"),
           Line2D([], [], ls=":", color="0.35", label="slope-1 line"),
           Line2D([], [], ls="--", color="0.5", label="$\\pm p'\\pm im_\\pi$, $p'\\in\\mathcal{C}$"),
           Line2D([], [], ls="", marker="o", ms=4, color=ORANGE, label="three-body ($B\\bar B\\pi$, …) points"),
           Line2D([], [], color=CUT, lw=4.5, label="pion cut of the amplitude")]
fig.legend(handles=handles, loc="lower center", ncol=8, fontsize=9, frameon=False)
fig.tight_layout(rect=(0, 0.03, 1, 1))
fig.savefig(f"{OUT}.png", dpi=130)
print(f"(d): B B-bar pi point meets the leg at kappa = {kaps[i_tb]:.2f} MeV; pion point at {MPI / 2:.2f} MeV")
print("wrote", f"{OUT}.png")
