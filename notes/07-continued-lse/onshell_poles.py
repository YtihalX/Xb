# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""On-shell momenta k_alpha(E), the propagator poles q = +-k_alpha of the LSE integrand, as functions of energy.

(a) Im k_alpha of the fourth-quadrant pole against Re E for Im E = -1, -10, -50 MeV. Above its threshold a
    channel is flipped and the path must pass below the pole; below it, above (notes/07-continued-lse.tex, S27).
(b) The q plane at Im E = -10 MeV. k depends on E only through E - delta_alpha (and mu_alpha, equal to 1%), so
    one trajectory serves all channels; points are labelled by Re E - delta_alpha. For flipped poles the bar runs
    between q = k -+ i m_pi, the exchanged-meson branch points of V(k, q; E) with the outgoing momentum on shell
    (S33, S36); they matter only for on-shell T and couplings.
Run: uv run --script notes/07-continued-lse/onshell_poles.py
Writes notes/07-continued-lse/onshell_poles.png and prints the numbers quoted with it. Not a check. Units MeV.
"""
from pathlib import Path

import matplotlib
import numpy as np
from matplotlib.lines import Line2D

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

mB, mV, mpi = 5279.52, 5324.75, 138.039
dm = mV - mB
CH = {"VV": (0.0, mV / 2), "PV": (-dm, mB * mV / (mB + mV)), "PP": (-2 * dm, mB / 2)}  # (delta, mu)
COLORS = {"VV": "tab:blue", "PV": "tab:orange", "PP": "tab:green"}
TB_PVPV = 130.4  # three-body branch point of V_{PV<-PV}(k5, q) at q ~ k5 -+ i sqrt(m_pi^2 - Delta m^2) (note 07, S32)
ABOVE = (-40, -20, -10, -5, 0, 2, 5, 10, 20, 45, 90, 135)  # Re E - delta for panel (b)


def k4(E, ch):
    """Fourth-quadrant pole for Im E < 0: principal root of 2 mu (E - delta)."""
    delta, mu = CH[ch]
    return np.sqrt(2 * mu * (np.asarray(E, dtype=complex) - delta))


# ---- numbers quoted with the figure
print("poles at the note-07 path-table energies:")
for E in (-67.85 - 10j, -22.62 - 10j):
    print(f"  E = {E}: " + ", ".join(f"{c} {k4(E, c):.2f}" for c in CH))
print("\nflipped pole at its threshold, sqrt(mu |Im E|)(1 - i):")
for eta in (1, 10, 50):
    print(f"  Im E = -{eta}: " + ", ".join(f"{c} {np.sqrt(CH[c][1] * eta):.1f}" for c in CH))
print("\nhow far above threshold the flipped pole is deeper than a given depth b (Im E = -eta):")
for eta in (1, 10, 50):
    for b in (mpi, TB_PVPV):
        mu = CH["PV"][1]
        a = mu * eta / b
        dE = (a * a - b * b) / (2 * mu)
        print(f"  Im E = -{eta}, depth {b:.1f}: " + (f"Re E - delta < {dE:.2f} MeV" if dE > 0 else "never above threshold"))
print("\npanel (b) points, Re E - delta: k (PV masses)")
for x in ABOVE:
    print(f"  {x:5g}: {k4(CH['PV'][0] + x - 10j, 'PV'):.1f}")

# ---- figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.8))
reE = np.linspace(-100, 47, 2941)
for c in CH:
    delta = CH[c][0]
    for eta, ls, lw in ((1, "-", 0.9), (10, "-", 2.4), (50, "--", 1.1)):
        ax1.plot(reE, k4(reE - 1j * eta, c).imag, ls, color=COLORS[c], lw=lw)
    ax1.axvline(delta, color=COLORS[c], lw=0.6, alpha=0.6)
    ax1.text(delta + 1, -392, f"{c} threshold", color=COLORS[c], fontsize=8, rotation=90, va="bottom")
ax1.axhline(-mpi, color="0.4", ls=(0, (5, 4)), lw=1)
ax1.axhline(-TB_PVPV, color="0.4", ls=":", lw=1)
ax1.text(46, -mpi - 13, "$-m_\\pi$", fontsize=8.5, color="0.3", ha="right")
ax1.text(46, -TB_PVPV + 4, "$-130.4$", fontsize=8.5, color="0.3", ha="right")
handles = [Line2D([], [], color=COLORS[c], lw=2.4, label=c) for c in CH]
handles += [Line2D([], [], color="0.3", lw=lw, ls=ls, label=f"Im $E=-{eta}$ MeV")
            for eta, ls, lw in ((1, "-", 0.9), (10, "-", 2.4), (50, "--", 1.1))]
ax1.legend(handles=handles, fontsize=8, loc="upper center", bbox_to_anchor=(0.5, -0.13), ncol=6, frameon=False)
ax1.set_xlim(-100, 47)
ax1.set_ylim(-400, 5)
ax1.set_xlabel("Re $E$ (MeV)")
ax1.set_ylabel("Im $k_\\alpha$, fourth-quadrant pole (MeV)")
ax1.set_title("(a) pole depth against energy", fontsize=10)

mu = CH["PV"][1]
x = np.linspace(-45, 140, 800)
traj = np.sqrt(2 * mu * (x - 10j))
ax2.plot(traj.real, traj.imag, color="0.6", lw=1.2, zorder=0)
for xv in ABOVE:
    k = np.sqrt(2 * mu * (xv - 10j))
    if xv > 0:
        ax2.plot([k.real, k.real], [k.imag - mpi, k.imag + mpi], color="tab:purple", lw=1, alpha=0.8)
        ax2.plot([k.real] * 2, [k.imag - mpi, k.imag + mpi], "_", color="tab:purple", ms=8)
    ax2.plot(k.real, k.imag, "o", ms=6, color="k", mfc="k" if xv > 0 else "white", zorder=3)
    ax2.annotate(f"{xv:+g}" if xv else "0", (k.real, k.imag), xytext=(6, -4), textcoords="offset points", fontsize=8)
ax2.plot([0, 900], [0, 0], color="k", lw=3, solid_capstyle="butt")
ax2.text(890, 8, "real path $[0,\\Lambda]$", ha="right", fontsize=8.5)
ax2.set_xlim(0, 900)
ax2.set_ylim(-420, 180)
ax2.set_aspect("equal")
ax2.set_xlabel("Re $q$ (MeV)")
ax2.set_ylabel("Im $q$ (MeV)")
ax2.set_title("(b) $q$ plane at Im $E=-10$ MeV; labels: Re $E-\\delta_\\alpha$ (MeV)", fontsize=10)
fig.tight_layout()
out = Path(__file__).with_suffix(".png")
fig.savefig(out, dpi=150)
print("\nwrote", out)
