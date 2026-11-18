# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""Plot the actual Julia S40 tiling and five representative certified paths.

Run from any directory with: uv run notes/07-continued-lse/s40_tiling.py
The summary supplies the Julia parameter provenance; no physics inputs are duplicated.
"""
import argparse
import cmath
import csv
import json
import re
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.collections import PatchCollection
from matplotlib.lines import Line2D
from matplotlib.patches import Patch, Rectangle

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CSV = ROOT / "code/Xb2Continuation/scripts/s40_tiling.csv"
CHANNELS = ("VV", "PV", "PP")
SHEETS = ("(-,+,+)", "(-,-,+)", "(-,-,-)")


def load_cells(path):
    with path.open(newline="") as stream:
        cells = list(csv.DictReader(stream))
    if not cells:
        raise ValueError("The tiling CSV contains no cells")
    for cell in cells:
        for name in ("re_lo", "re_hi", "im_lo", "im_hi"):
            cell[name] = float(cell[name])
        cell["centre"] = complex((cell["re_lo"] + cell["re_hi"]) / 2,
                                 (cell["im_lo"] + cell["im_hi"]) / 2)
    return cells


def rectangle(cell):
    return Rectangle((cell["re_lo"], cell["im_lo"]), cell["re_hi"] - cell["re_lo"],
                     cell["im_hi"] - cell["im_lo"])


def contains(cell, point):
    return (cell["re_lo"] - 1e-9 <= point.real <= cell["re_hi"] + 1e-9
            and cell["im_lo"] - 1e-9 <= point.imag <= cell["im_hi"] + 1e-9)


def select_representatives(cells, pv):
    certified = [c for c in cells if c["status"] == "certified"]
    selected = []
    specifications = [
        (SHEETS[0], complex(-67.85, -5), "A1", "contains", "A1 interior"),
        (SHEETS[1], complex(-22.62, -5), "A2", "contains", "A2 interior"),
        (SHEETS[1], complex(pv, -5), "A2", "threshold", "A2 PV edge"),
        (SHEETS[1], complex(-22.62, -45), "B2", "nearest", "B2 deep"),
        (SHEETS[2], complex(20, -5), "C1", "nearest", "C1 interior"),
    ]
    for sheet, target, region, mode, label in specifications:
        candidates = [c for c in certified if c["sheet"] == sheet and c["region"] == region]
        if mode == "contains":
            candidates = [c for c in candidates if contains(c, target)]
        elif mode == "threshold":
            candidates = [c for c in candidates if abs(c["re_lo"] - pv) < 1e-8]
        if not candidates:
            raise ValueError(f"No certified cell satisfies representative {label}: {mode} {target}")
        # Deep means Im E near -45; prioritize that coordinate before Re E.
        if mode == "nearest" and region == "B2":
            cell = min(candidates, key=lambda c: (abs(c["centre"].imag-target.imag),
                                                  abs(c["centre"].real-target.real)))
        else:
            cell = min(candidates, key=lambda c: abs(c["centre"] - target))
        selected.append((label, cell))
    return selected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--output", type=Path, default=Path(__file__).with_suffix(".png"))
    args = parser.parse_args()
    cells = load_cells(args.csv)
    summary = args.csv.with_name("s40_tiling_summary.md").read_text()
    match = re.search(r"<!-- s40_metadata: (.*?) -->", summary)
    if match is None:
        raise ValueError("Missing Julia parameter provenance in tiling summary")
    metadata = json.loads(match.group(1))
    thresholds, mu = metadata["thresholds"], metadata["mu"]
    representatives = select_representatives(cells, thresholds[1])
    node_sets = sorted({c["nodes"] for c in cells if c["status"] == "certified"})
    cmap = plt.get_cmap("tab10")
    node_colours = {key: cmap(i % 10) for i, key in enumerate(node_sets)}
    reasons = sorted({c["reason"] for c in cells if c["status"] == "excluded"})
    hatches = {reason: ("", "///", "xx", "...", "\\\\")[i % 5] for i, reason in enumerate(reasons)}
    fig, axes = plt.subplots(2, 2, figsize=(15, 10), layout="constrained")
    for ax, sheet in zip(axes.flat, SHEETS):
        panel = [c for c in cells if c["sheet"] == sheet]
        for reason in reasons:
            group = [rectangle(c) for c in panel if c["status"] == "excluded" and c["reason"] == reason]
            if group:
                ax.add_collection(PatchCollection(group, facecolor="0.82", edgecolor="0.50",
                                                  linewidth=0.25, hatch=hatches[reason], zorder=1))
        for nodes in node_sets:
            group = [rectangle(c) for c in panel if c["status"] == "certified" and c["nodes"] == nodes]
            if group:
                ax.add_collection(PatchCollection(group, facecolor="none", edgecolor=node_colours[nodes],
                                                  linewidth=0.55, zorder=2))
        lo, hi = min(c["re_lo"] for c in panel), max(c["re_hi"] for c in panel)
        for channel, delta in zip(CHANNELS, thresholds):
            if lo-0.1 <= delta <= hi+0.1:
                ax.axvline(delta, ls="--", lw=1, color="0.25", zorder=3)
                ax.text(delta, 0.9, channel, ha="center", va="bottom", fontsize=9)
        if sheet == SHEETS[2]:
            ax.axvline(metadata["E31"], ls="--", color="0.25", lw=1)
            ax.text(metadata["E31"], 0.9, "$E_{31}$", ha="center", va="bottom", fontsize=9)
        for index, (label, cell) in enumerate(representatives, 1):
            if cell["sheet"] == sheet:
                z = cell["centre"]
                ax.plot(z.real, z.imag, "o", ms=5, color=cmap(index-1), markeredgecolor="black", zorder=5)
                ax.annotate(str(index), (z.real, z.imag), xytext=(4, 5), textcoords="offset points", fontsize=9)
        ax.axhline(-10, color="0.45", lw=0.6)
        ax.set(xlim=(lo-1, hi+1), ylim=(-51, 4), xlabel="Re $E$ (MeV)", ylabel="Im $E$ (MeV)",
               title=f"Sheet {sheet}")
        handles = [Patch(facecolor="none", edgecolor=node_colours[key], label=f"nodes {key}")
                   for key in node_sets if any(c["nodes"] == key for c in panel)]
        handles += [Patch(facecolor="0.82", edgecolor="0.5", hatch=hatches[reason],
                          label=reason.replace("sampled-along-the-path ", "sampled "))
                    for reason in reasons if any(c["reason"] == reason for c in panel)]
        ax.legend(handles=handles, loc="lower left", fontsize=7, frameon=False)
    ax = axes.flat[3]
    markers = ("s", "^", "o")
    for index, (label, cell) in enumerate(representatives, 1):
        colour = cmap(index-1)
        vertices = np.array([complex(*map(float, pair.split(":"))) for pair in cell["vertices"].split(";")])
        z = cell["centre"]
        ax.plot(vertices.real, vertices.imag, color=colour, lw=1.6,
                label=f"{index}. {label}: {z.real:.2f}{z.imag:+.2f}i MeV", zorder=2)
        for channel, delta, mass, marker in zip(CHANNELS, thresholds, mu, markers):
            k = cmath.sqrt(2*mass*(z-delta))
            is_node = channel in cell["nodes"].split("+")
            ax.plot(k.real, k.imag, marker=marker, ms=6, linestyle="none", markeredgecolor=colour,
                    markerfacecolor=colour if is_node else "none", zorder=4)
        print(f"Representative {index} ({label}), {cell['sheet']}: "
              f"Re [{cell['re_lo']:.9g}, {cell['re_hi']:.9g}], "
              f"Im [{cell['im_lo']:.9g}, {cell['im_hi']:.9g}] MeV; nodes {cell['nodes']}")
    ax.axhline(0, color="0.6", lw=0.6)
    ax.axvline(0, color="0.6", lw=0.6)
    ax.set(xlim=(-10, 1200), ylim=(-780, 30), xlabel="Re $q$ (MeV)", ylabel="Im $q$ (MeV)",
           title="Representative paths and principal on-shell momenta")
    path_legend = ax.legend(loc="lower right", fontsize=7.5, frameon=False)
    ax.add_artist(path_legend)
    ax.legend(handles=[Line2D([], [], marker=m, color="0.25", linestyle="none", label=ch)
                       for ch, m in zip(CHANNELS, markers)], title="Filled: node; open: non-node",
              title_fontsize=8, fontsize=8, loc="upper right", frameon=False)
    fig.suptitle("S40 rectangle certificates: rigorous in energy; C5 sampled along the momentum path", fontsize=13)
    fig.savefig(args.output, dpi=160, transparent=True)
    print("Wrote", args.output)


if __name__ == "__main__":
    main()
