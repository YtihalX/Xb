# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8", "mpmath>=1.3"]
# ///
"""Sokhotski-Plemelj on a free contour: once the propagator pole is subtracted, where may the contour go?
A plot of the note's formulas with numerical evidence; not a recorded check.

Integrals with one on-shell leg in the flipped PV channel, p = k_5, 1 MeV above the PV threshold:
  static: App. D's J(p; m_pi) = int_0^inf q dq / (p^2 - q^2) [Log w_-(q) - Log w_+(q)], exact i pi Log(1 - 2ip/m);
          split logs, pole term and quadrature of checks/appd_contours.py; GeV, 20 digits;
  TOPT:   J = int_0^Lambda dq q^2 [2 mu_5 / (q^2 - k_5^2)] M_0(nu_1)(k_5, q), the m = 0 moment of S3 for the
          B B-bar pi ordering (beta = 1) of PV<-PV, principal branches; MeV, 20 digits. Reference: the S40 path at
          d_k = d_k,max/2 without subtraction (route 1 of onshell_topt.py), cross-checked against the path through
          k_5 with subtraction (route 3).
Contours C_h: 0 -> Re k_5 - i h -> 2 Re k_5 -> the real axis (to infinity, static; to Lambda, TOPT): depth h where the
contour crosses Re q = Re k_5. h = 0 is the real path; h = |Im k_5| passes through the pole.
  SP:           int_C [f(q) - (pole part at k_5)] + the pole term of the sheet (contour below k_5), for every C_h;
  unsubtracted: int_C f(q), right only if C_h passes below k_5.
The on-shell kernel's singular points sit at k_5 +- i m_pi (exchanged-meson; the principal cuts of Log w_- run
vertically away from them) and the three-body points beside them. A contour is right when it passes below the up
points and above the down points: depth h in (|Im k_5| - m_pi, |Im k_5| + m_pi) for the static kernel.
Figure sp_window.png: (a) the q plane at Gamma = 20 MeV with the family; (b), (c) relative errors against h at
Gamma = 20 and 10 MeV.
Run: uv run --script notes/07-continued-lse/sp_window.py
"""
import cmath
import sys
from pathlib import Path

import matplotlib
import mpmath as mp
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402
from matplotlib.patches import Patch, Rectangle  # noqa: E402

from _s40geom import *  # noqa: E402,F403

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "checks"))
import appd_contours as appd  # noqa: E402

OUT = Path(__file__).with_suffix("")
MPI = MPHI["pi"]
DPV, MUPV = CH[1][1], CH[1][2]
EPS = 1.0
DPS = 20


def k5(E):
    return cmath.sqrt(2 * MUPV * (E - DPV))


def family(k, h):
    a = k.real
    return [0j, complex(a, -h), complex(2 * a, 0.0)]


def j_static(E, h, subtract):
    k = k5(E)
    with mp.workdps(DPS):
        p = mp.mpc(k.real, k.imag) / 1000
        m = mp.mpf(MPI) / 1000
        exact = 1j * mp.pi * mp.log(1 - 2j * p / m)
        f = lambda q: q / (p * p - q * q) * appd.split_logs(q, p, m)  # noqa: E731
        verts = [mp.mpc(v.real, v.imag) / 1000 for v in family(k, h)]
        quad = appd.Quadrature()
        splits = [("re", mp.re(p))]
        if subtract:
            fp = p * appd.split_logs(p, p, m)
            g = lambda q: f(q) - fp / (p * p - q * q)  # noqa: E731
            val = quad.path(g, verts, splits) + quad.ray(g, verts[-1], splits) - 1j * mp.pi * fp / (2 * p)
        else:
            val = quad.path(f, verts, splits) + quad.ray(f, verts[-1], splits)
        return float(abs(val - exact) / abs(exact))


def U(k, q, E, beta, m):
    t, hh, aa = ORD[beta]
    nu = t + hh * k * k + aa * q * q - E
    zp = mp.sqrt(m * m + (k + q) ** 2) + nu
    zm = mp.sqrt(m * m + (k - q) ** 2) + nu
    return (mp.log(zp) - mp.log(zm)) / (2 * k * q)


def j_topt(E, verts, subtract, beta=1):
    k = k5(E)
    with mp.workdps(DPS):
        km, Em, m, mu = mp.mpc(k.real, k.imag), mp.mpc(E.real, E.imag), mp.mpf(MPI), mp.mpf(MUPV)
        V = [mp.mpc(v.real, v.imag) for v in verts]
        quad = appd.Quadrature()
        splits = [("re", mp.re(km))]
        if subtract:
            ukk = U(km, km, Em, beta, m)
            g = lambda q: 2 * mu * (q * q * U(km, q, Em, beta, m) - km * km * ukk) / (q * q - km * km)  # noqa: E731
            I = (mp.log((LAM - km) / (LAM + km)) + 1j * mp.pi) / (2 * km)
            val = quad.path(g, V, splits) + 2 * mu * km * km * ukk * I
        else:
            val = quad.path(lambda q: 2 * mu * q * q * U(km, q, Em, beta, m) / (q * q - km * km), V, splits)
        return complex(val)


HS = np.arange(0.0, 345.0, 5.0)
results = {}
for gam in (20.0, 10.0):
    E = complex(DPV + EPS, -gam / 2)
    k = k5(E)
    ref1 = j_topt(E, s40_path(E, largest_dk(E) / 2), subtract=False)
    ref3 = j_topt(E, sp_polygon(E), subtract=True)
    print(f"Gamma = {gam:g} MeV: k_5 = {k.real:.2f}{k.imag:+.2f}i MeV; static window: depth "
          f"{abs(k.imag) - MPI:.1f} to {abs(k.imag) + MPI:.1f} MeV; TOPT reference: route 1 vs route 3 "
          f"{abs(ref1 - ref3) / abs(ref1):.1e}")
    rows = {"static SP": [], "static unsubtracted": [], "TOPT SP": [], "TOPT unsubtracted": []}
    for h in HS:
        near_pole = abs(h - abs(k.imag)) < 2.0
        rows["static SP"].append(j_static(E, h, True))
        rows["static unsubtracted"].append(np.nan if near_pole else j_static(E, h, False))
        verts = family(k, h) + [complex(LAM, 0.0)]
        rows["TOPT SP"].append(abs(j_topt(E, verts, True) - ref1) / abs(ref1))
        rows["TOPT unsubtracted"].append(np.nan if near_pole else abs(j_topt(E, verts, False) - ref1) / abs(ref1))
    results[gam] = (E, k, {key: np.array(v) for key, v in rows.items()})
    for key, v in results[gam][2].items():
        ok = HS[np.nan_to_num(v, nan=1.0) < 1e-12]
        print(f"   {key:20s}: error < 1e-12 for depth h in {ok.min():.0f}..{ok.max():.0f} MeV" if ok.size
              else f"   {key:20s}: never below 1e-12")
        bad = np.nan_to_num(v, nan=0.0)
        if (bad >= 1e-12).any():
            print(f"   {'':20s}  outside it: {np.nanmin(np.where(bad >= 1e-12, v, np.nan)):.1e} to {np.nanmax(v):.1e}")

# ================================================================ figure
fig = plt.figure(figsize=(19, 7.2))
gs = fig.add_gridspec(1, 3, width_ratios=(1.05, 1, 1))
ax = fig.add_subplot(gs[0, 0])
E, k, _ = results[20.0]
a = k.real
ax.axhline(0, color="0.6", lw=0.8)
ax.axvline(0, color="0.8", lw=0.6)
ax.add_patch(Rectangle((a - 7, k.imag - MPI), 14, 2 * MPI, fc="#c7e9c0", ec="none", zorder=0))
ax.text(255, -255, "window: the contour\ncrosses Re $q$ = Re $k_5$\nbetween the up and\ndown points",
        fontsize=8.6, color="darkgreen")
ax.plot([a, a], [k.imag + MPI, 200], ls=(0, (4, 3)), color="saddlebrown", lw=1.3)
ax.plot([a, a], [k.imag - MPI, -400], ls=(0, (4, 3)), color="saddlebrown", lw=1.3)
for h, col in zip((0, 40, 100, 155, 230, 320), ("0.55", "tab:green", "tab:green", "tab:green", "tab:green", "0.55")):
    V = family(k, h) + [complex(700, 0)]
    ax.plot([v.real for v in V], [v.imag for v in V], color=col, lw=1.8 if col != "0.55" else 1.4,
            ls="-" if col != "0.55" else "--", zorder=3)
    ax.text(a - 58, -h - 3 if h else 6, f"$h={h}$", fontsize=8, color=col if col != "0.55" else "0.35")
ax.plot(k.real, k.imag, "o", ms=9, color="crimson", zorder=8)
ax.annotate("$+k_5$ (flipped):\nthe subtracted pole", (k.real, k.imag), xytext=(255, -150), fontsize=8.6,
            color="crimson", arrowprops=dict(arrowstyle="->", color="crimson", lw=0.8))
ax.plot([a, a], [k.imag + MPI, k.imag - MPI], "*", ms=13, mfc="gold", mec="k", zorder=8)
tb = np.concatenate([three_body(np.array([k]), E, MPI, b, tau).ravel() for b in (1, 2, 4) for tau in (1, -1)])
tb = tb[~np.isnan(tb)]
ax.plot(tb.real, tb.imag, "P", ms=7, mfc="gold", mec="k", zorder=8)
ax.annotate("up points: $k_5+im_\\pi$ and\nthree-body points beside it", (a, k.imag + MPI), xytext=(260, 60),
            fontsize=8.6, arrowprops=dict(arrowstyle="->", color="k", lw=0.8))
ax.annotate("down points", (a, k.imag - MPI), xytext=(260, -330), fontsize=8.6,
            arrowprops=dict(arrowstyle="->", color="k", lw=0.8))
ax.set_xlim(-30, 560)
ax.set_ylim(-400, 160)
ax.set_aspect("equal")
ax.set_xlabel("Re $q$ (MeV)")
ax.set_ylabel("Im $q$ (MeV)")
ax.set_title(f"(a) contours $\\mathcal{{C}}_h$ at $E=\\delta_{{PV}}+1-10i$ MeV ($\\Gamma=20$ MeV)\n"
             "green: in the window; grey dashed: outside", fontsize=10.5)
for col, gam in ((1, 20.0), (2, 10.0)):
    ax = fig.add_subplot(gs[0, col])
    E, k, rows = results[gam]
    lo, hi = abs(k.imag) - MPI, abs(k.imag) + MPI
    ax.axvspan(max(lo, HS[0]), hi, color="#c7e9c0", zorder=0)
    ax.axvline(abs(k.imag), color="crimson", lw=1.2, ls=":")
    ax.text(abs(k.imag) + 3, 1e-14, "contour through\nthe pole", color="crimson", fontsize=8.4)
    ax.axvline(k5(E).real, color="0.4", lw=0.8, ls="--")
    ax.text(k5(E).real + 3, 1e-11, "first leg steeper\nthan 1 beyond here", color="0.35", fontsize=8.2)
    ax.text(0.02, 0.03, "inside the window: equal to the reference to the 20-digit working precision",
            transform=ax.transAxes, fontsize=8, color="darkgreen")
    style = {"static SP": ("tab:green", "-", "o"), "static unsubtracted": ("k", "--", "s"),
             "TOPT SP": ("tab:orange", "-", "D"), "TOPT unsubtracted": ("tab:orange", ":", "^")}
    labels = {"static SP": "App. D's $J$ (static): SP", "static unsubtracted": "App. D's $J$: no subtraction",
              "TOPT SP": "TOPT $J$ ($B\\bar B\\pi$ ordering): SP", "TOPT unsubtracted": "TOPT $J$: no subtraction"}
    for key, (c, ls, mk) in style.items():
        ax.semilogy(HS, np.maximum(rows[key], 1e-17), ls=ls, marker=mk, ms=3.5, color=c, lw=1.4, label=labels[key])
    ax.set_ylim(3e-18, 10)
    ax.set_xlim(HS[0], HS[-1])
    ax.set_xlabel("depth $h$ at which $\\mathcal{C}_h$ crosses Re $q$ = Re $k_5$ (MeV); $h=0$: the real path")
    ax.set_ylabel("relative error")
    ax.grid(alpha=0.3, which="both")
    ax.set_title(f"({'b' if col == 1 else 'c'}) $\\Gamma={gam:g}$ MeV: $|\\mathrm{{Im}}\\,k_5|={abs(k.imag):.0f}$ MeV, "
                 f"window {max(lo, 0):.0f}–{hi:.0f} MeV (green)", fontsize=10.5)
    if col == 1:
        ax.legend(fontsize=8.2, loc="center")
fig.tight_layout()
fig.savefig(f"{OUT}.png", dpi=140)
print("wrote", f"{OUT}.png")
