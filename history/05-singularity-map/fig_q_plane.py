# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "scipy>=1.14", "matplotlib>=3.9"]
# ///
"""Page-width loop-plane figures from the saved, verified contour scan.

Run: uv run --script notes/05-singularity-map/fig_q_plane.py
This renderer does not repeat the contour optimization: loop-plane-data.json is
its explicit numerical input. The root loci are evaluated from loop_plane.py.
All figures are 7.5 inches wide with text at least 12 pt, and saved at 200 dpi.
"""
from pathlib import Path
import json
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from kinematics import M_PI, M_ETA, LAMBDA, SECTOR_2PP, momenta
from loop_plane import (log_roots, sqrt_points, sample_contour, track_roots,
                        graph_contour, virtual_contour, PAIR, BETAS, REP, ORDERINGS)

HERE = Path(__file__).resolve().parent
FIGURES = HERE / "figures"
COLORS = {1: "#bf3984", 2: "#7651a8", 3: "#dc8524", 4: "#dc8524"}
POLE = {1: "#2257a0", 5: "#ca6323", 6: "#198564"}
plt.rcParams.update({"font.size": 12, "axes.titlesize": 12, "axes.labelsize": 12,
                     "xtick.labelsize": 12, "ytick.labelsize": 12, "legend.fontsize": 12})


def swept(ax, contour, E, n=801):
    p = sample_contour(contour, n)
    for mass, alpha in ((M_PI, .85), (M_ETA, .22)):
        for points in sqrt_points(p, mass).T:
            ax.plot(points.real*1000, points.imag*1000, ":", color="#2495b1", lw=1.1, alpha=alpha)
    for beta in BETAS:
        for sign in (-1, 1):
            roots = log_roots(p, E, beta, sign=sign)
            q, physical = track_roots(roots)
            for j in range(4):
                z = np.where(physical[:, j], q[:, j], np.nan+1j*np.nan)
                ax.plot(z.real*1000, z.imag*1000, color=COLORS[beta], lw=1.0,
                        alpha=.8 if beta != 4 else .45)


def external(ax, E, sheet):
    ks = momenta(SECTOR_2PP, E, sheet)
    for pair, index in REP.items():
        p = complex(ks[index]); z = sqrt_points(p)
        ax.scatter(z.real*1000, z.imag*1000, marker="x", s=18, color="#147c94", lw=.8, zorder=5)
        if E.real <= SECTOR_2PP.channel(index).delta:
            continue
        betas = {b for (out, _), order in ORDERINGS.items() if out == pair for b in order}
        for beta in betas:
            for sign in (-1, 1):
                roots = log_roots(p, E, beta, sign=sign)
                z = roots.q[roots.physical]
                ax.scatter(z.real*1000, z.imag*1000, marker="^", s=20,
                           facecolors="none", edgecolors=COLORS[beta], lw=.9, zorder=5)


def poles(ax, E, sheet, labels=True):
    xmin, xmax = ax.get_xlim(); ymin, ymax = ax.get_ylim()
    for index, k in momenta(SECTOR_2PP, E, sheet).items():
        for sign in (1, -1):
            z = 1000*sign*complex(k)
            if xmin < z.real < xmax and ymin < z.imag < ymax:
                ax.scatter([z.real], [z.imag], s=36, facecolors=POLE[index] if sign > 0 else "white",
                           edgecolors=POLE[index], lw=1.1, zorder=8)
                if labels:
                    ax.annotate(("" if sign > 0 else "−")+f"k{index}", (z.real, z.imag),
                                xytext=(5, 6 if sign > 0 else -15), textcoords="offset points",
                                color=POLE[index], fontsize=12)


def frame(ax, xlim, ylim):
    ax.set(xlim=xlim, ylim=ylim, xlabel="Re q [MeV]", ylabel="Im q [MeV]")
    ax.axhline(0, color=".7", lw=.6); ax.axvline(0, color=".7", lw=.6)
    ax.grid(alpha=.12)


def continuation_arrow(ax, contour):
    """The displayed right edge is a crop, NOT the finite contour endpoint."""
    xmax = ax.get_xlim()[1]
    y = np.interp(xmax/1000, contour.real, contour.imag)*1000
    ax.annotate("", xy=(xmax+80, y), xytext=(xmax-150, y),
                arrowprops={"arrowstyle": "->", "color": "black", "lw": 1.2}, annotation_clip=False)
    # A pair of break strokes on the contour at the cropped edge.
    dy = (ax.get_ylim()[1]-ax.get_ylim()[0])*.017
    for dx in (-25, 8):
        ax.plot([xmax+dx-12, xmax+dx+12], [y-dy, y+dy], color="white", lw=3.2, clip_on=False, zorder=10)
        ax.plot([xmax+dx-12, xmax+dx+12], [y-dy, y+dy], color="black", lw=.9, clip_on=False, zorder=11)
    ax.set_xlabel("Re q [MeV]   (C runs on to Λ = 4000)", fontsize=11)


def contour_for(data, E, sheet):
    record = next(r for r in data["probes"] if np.allclose(r["E_MeV"], [1000*E.real, 1000*E.imag])
                  and r["sheet"] == list(sheet))
    return graph_contour(E, sheet, *record["parameters"]), record


def resonance(data):
    fig, axes = plt.subplots(2, 2, figsize=(7.5, 9.5))
    cases = [(-.02262+1e-10j, (1, 1, 1)), (-.02262-.01j, (-1, -1, 1)),
             (.02379-.01j, (-1, -1, -1)), (-.02262-.06j, (-1, -1, 1))]
    for j, (E, sheet) in enumerate(cases):
        ax = axes.flat[j]
        c, record = (np.array([0j, LAMBDA+0j]), None) if j == 0 else contour_for(data, E, sheet)
        frame(ax, (-300, 1200), (-450, 450))
        ax.set_xticks([0, 600, 1200]); ax.set_yticks([-400, 0, 400])
        sh = "("+",".join("+" if s > 0 else "−" for s in sheet)+")"
        energy = f"{1000*E.real:+.2f}"+(" + i0" if j == 0 else f" − {abs(1000*E.imag):g}i")
        ax.set_title(f"({'abcd'[j]}) {sh}\nE = {energy} MeV\nprobe energy, not a pole", pad=10)
        if j == 3:
            shown = sample_contour(c, 1001)
            ax.fill_between(shown.real*1000, shown.imag*1000, 0, color="#e3ce9b", alpha=.35, zorder=0)
            ax.text(.43, .6, "between old\nand new contour", transform=ax.transAxes,
                    ha="center", fontsize=12, color="#65522c")
        swept(ax, c, E)
        if j:
            external(ax, E, sheet)
        ax.plot(c.real*1000, c.imag*1000, color="black", lw=1.8, zorder=7)
        poles(ax, E, sheet)
        continuation_arrow(ax, c)
        if j == 3:
            z = complex(*record["enclosed_external_log_MeV"])
            ax.scatter([z.real], [z.imag], s=145, facecolors="none", edgecolors="crimson", lw=1.6, zorder=12)
            ax.annotate("external\nendpoint", (z.real, z.imag), xytext=(700, 160), color="crimson",
                        fontsize=12, arrowprops={"arrowstyle": "->", "color": "crimson"})
    handles = [Line2D([], [], color="black", lw=1.8, label="loop contour C"),
               Line2D([], [], color="#2495b1", ls=":", label="sqrt endpoint loci (η pale)"),
               *[Line2D([], [], color=COLORS[b], label=f"log endpoint loci: {PAIR[b]}") for b in (1, 3, 2)]]
    fig.legend(handles=handles, loc="lower center", ncol=2, frameon=False,
               bbox_to_anchor=(.5, .015), columnspacing=1.1, handlelength=1.8)
    fig.subplots_adjust(left=.11, right=.95, bottom=.18, top=.93, hspace=.59, wspace=.44)
    fig.savefig(FIGURES/"q-plane-resonance.png", dpi=200)
    plt.close(fig)


def intersections(curve, contour):
    a = curve[:-1, None]; u = np.diff(curve)[:, None]
    b = contour[None, :-1]; v = np.diff(contour)[None, :]
    cross = lambda z, w: (np.conj(z)*w).imag
    den = cross(u, v)
    with np.errstate(divide="ignore", invalid="ignore"):
        t = cross(b-a, v)/den; s = cross(b-a, u)/den
    hit = (abs(den)>1e-20)&(t>=0)&(t<=1)&(s>=0)&(s<=1)
    return (a+t*u)[hit]


def virtual():
    fig, axes = plt.subplots(1, 2, figsize=(7.5, 5.7))
    for j, E in enumerate((-.0005-.0001j, -.02262-.0005j)):
        ax = axes[j]; sheet = (-1, -1, -1)
        c = virtual_contour(E, depth_margin=.0001, width=.002)
        frame(ax, (-8, 18) if j == 0 else (-8, 25), (-56, -46) if j == 0 else (-375, -180))
        ax.set_xticks([-5, 5, 15] if j == 0 else [0, 10, 20])
        ax.set_yticks([-56, -52, -48] if j == 0 else [-350, -275, -200])
        ax.set_title(f"({'ef'[j]}) (−,−,−)\nE = {1000*E.real:.2f} − {abs(1000*E.imag):g}i MeV\n"
                     "probe energy, not a pole", pad=12)
        swept(ax, c, E, n=1201)
        ax.plot(c.real*1000, c.imag*1000, color="black" if j == 0 else "crimson", lw=1.8, zorder=7)
        poles(ax, E, sheet)
        if j == 1:
            hits = np.concatenate([intersections(z, c) for z in sqrt_points(c).T])
            k = complex(momenta(SECTOR_2PP, E, sheet)[1])
            point = min(hits, key=lambda z: abs(z-k))*1000
            ax.scatter([point.real], [point.imag], s=260, facecolors="none", edgecolors="crimson", lw=1.8, zorder=12)
            ax.annotate("endpoint locus\ncrosses contour\nhere", (point.real, point.imag), xytext=(5, -325),
                        fontsize=12, color="crimson", arrowprops={"arrowstyle": "->", "color": "crimson"})
            print(f"Virtual-panel sqrt intersection: q={point.real:.9f}{point.imag:+.9f}i MeV")
        inset = ax.inset_axes([.51, .73, .47, .25])
        frame(inset, (-300, 1200), (-450, 450))
        swept(inset, c, E, n=401)
        inset.plot(c.real*1000, c.imag*1000, color="black" if j == 0 else "crimson", lw=1)
        poles(inset, E, sheet, labels=False)
        inset.set_xlabel(""); inset.set_ylabel(""); inset.set_xticks([0, 1000]); inset.set_yticks([])
        inset.text(.03, .95, "wide view", transform=inset.transAxes, fontsize=10, va="top", ha="left")
    fig.text(.5, .035, "Common contour in all channels; zooms resolve the excursion.\n"
             "Black: shallow allowed path. Red: blocked path.", ha="center", fontsize=12)
    fig.subplots_adjust(left=.12, right=.96, bottom=.22, top=.79, wspace=.48)
    fig.savefig(FIGURES/"q-plane-virtual.png", dpi=200)
    plt.close(fig)


def margins(data):
    fig, axes = plt.subplots(3, 1, figsize=(7.5, 8.3), sharex=True)
    for ax, record in zip(axes, data["scan"]):
        rows = record["rows"]
        ys = [r["y_MeV"] for r in rows]
        ax.plot(ys, [r["margin_MeV"] for r in rows], "o-", ms=3, lw=1.3,
                label="final clearance (all sets incl. propagator poles)")
        ax.plot(ys, [r["homotopy_margin_MeV"] for r in rows], "--", lw=1.2,
                label="smallest kernel-endpoint clearance along the deformation")
        sheet = "("+",".join("+" if s > 0 else "−" for s in record["sheet"])+")"
        ax.set_title(f"{sheet}; Re E = {record['Re_E_MeV']:+.2f} MeV — probe energies, not poles")
        ax.set_ylabel("clearance [MeV]"); ax.set_xlim(0, 100); ax.grid(alpha=.2)
    axes[-1].set_xlabel("y = −Im E [MeV]")
    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="lower center", ncol=1, frameon=False, bbox_to_anchor=(.5, .012))
    fig.subplots_adjust(left=.13, right=.97, top=.95, bottom=.18, hspace=.6)
    fig.savefig(FIGURES/"contour-margin.png", dpi=200)
    plt.close(fig)


if __name__ == "__main__":
    FIGURES.mkdir(exist_ok=True)
    data = json.loads((HERE/"loop-plane-data.json").read_text())
    resonance(data)
    virtual()
    margins(data)
