# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""The five conditions C1-C5 of the S40 rectangle certificate (notes/07-continued-lse.tex, S40(d)) in pictures:
what each one asks, on a rectangle that passes and on a case that fails. Plot evidence, not a check. Units MeV.
The certificates and their margins come from cert_conditions.csv, written by cert_conditions.jl (run it first).

Examples (sheet labels in PP, PV, VV order):
  A   (-,-,+)  Re E in [-25, -20],        Im E in [-10, -5]      certified, on-shell nodes PV and PP (vertices)
  D   (-,-,+)  Re E in [-25, -20],        Im E in [-50, -45]     certified, the same deeper down (Gamma about 95 MeV)
  B   (-,+,+)  Re E in [-45.85, -45.75],  Im E in [-0.35, -0.25] certified, the near on-shell node of PV kept
  Bd  (-,+,+)  Re E in [-46.70, -46.60],  Im E in [-0.40, -0.30] certified, the near on-shell node of PV dropped
  F4  (-,-,-)  Re E in [-30, -28],        Im E in [-2, -1]       excluded by C4 (VV flipped 29 MeV below threshold)
  F5  (-,-,+)  Re E in [-46.6, -46.4],    Im E in [-0.2, -0.1]   excluded by C5 (PV flipped 1.3 MeV below threshold)
and, as a path that C1 rejects, the steep probe path of the Stage-2 gate (checks/_stage2_probes.jl):
0 -> 10 - 200i -> 1500 - 200i -> Lambda, first leg of slope 20.

cert_path_pairs.png  C1 and C2: pairs with both momenta on the path.
  (a) the path inside the cone |Im q| <= Re q; (b) w_pm = m_pi^2 + (p' pm q)^2 for all sampled pairs, in units of
  m_pi^2; (c) Z = s_pm + nu_beta for all sampled pairs, pion, the four orderings, with the bound of C2.
cert_poles.png       C3: a channel without an on-shell node.
  (a) the pole of PV, unflipped and just below its threshold, under the path; (b) the error of the plain panel
  quadrature of that channel's loop against the distance of the pole from the path.
cert_nodes.png       C4 and C5: pairs with an on-shell node.
  (a), (b) the window |Im q - h(Re q)| < m_pi around the path, the node momenta k(Q) and the branch points
  k pm i m_pi of s_-(k, q) with their cuts, for A and F4; (c) the principal s_-(k, q) along the path next to
  Re q = Re k; (d) Z at the node pairs of A and F5, with the certified bound of A.
"""
import cmath
import csv
import math
import pathlib

import matplotlib.pyplot as plt
import numpy as np

import _s40geom as G
from gap_failures import Z, kprin

HERE = pathlib.Path(__file__).parent
LAM, CH, MPHI, ORD = G.LAM, G.CH, G.MPHI, G.ORD
NAMES = ("VV", "PV", "PP")
COLOR = {"VV": "tab:purple", "PV": "tab:green", "PP": "tab:blue"}
MPI = MPHI["pi"]
R_NEAR = 100.0
# orderings of the block (outgoing, incoming), channels in (VV, PV, PP) order: _SP_BLOCKS of sp_contours.jl
BLOCKS = {(0, 0): (2,), (0, 1): (2, 3), (0, 2): (3,), (1, 0): (2, 4), (1, 1): (1, 2), (2, 0): (4,)}
ROWS = {a: sorted({b for (o, _), bs in BLOCKS.items() if o == a for b in bs}) for a in range(3)}
COLS = {a: sorted({b for (_, i), bs in BLOCKS.items() if i == a for b in bs}) for a in range(3)}
STEEP = [0j, 10.0 - 200.0j, 1500.0 - 200.0j, complex(LAM, 0.0)]
EX = {  # flips in (VV, PV, PP) order
    "A": dict(flips=(False, True, True), re=(-25.0, -20.0), im=(-10.0, -5.0)),
    "D": dict(flips=(False, True, True), re=(-25.0, -20.0), im=(-50.0, -45.0)),
    "B": dict(flips=(False, False, True), re=(-45.85, -45.75), im=(-0.35, -0.25)),
    "Bd": dict(flips=(False, False, True), re=(-46.70, -46.60), im=(-0.40, -0.30)),
    "F4": dict(flips=(True, True, True), re=(-30.0, -28.0), im=(-2.0, -1.0)),
    "F5": dict(flips=(False, True, True), re=(-46.6, -46.4), im=(-0.2, -0.1)),
}


def centre(ex):
    return complex(sum(ex["re"]) / 2, sum(ex["im"]) / 2)


def s40_path(ex):
    """S40(a): a vertex at the centre for every flipped channel and every channel with delta < max Re E."""
    Ec = centre(ex)
    chans = [a for a in range(3) if ex["flips"][a] or CH[a][1] < ex["re"][1]]
    vs = sorted((complex(kprin(Ec, a).real, -min(abs(kprin(Ec, a).imag), kprin(Ec, a).real)) for a in chans),
                key=lambda z: z.real)
    return [0j] + vs + [complex(LAM, 0.0)], chans


def hgt(V, x):
    return np.interp(x, [v.real for v in V], [v.imag for v in V])


def corners(ex):
    return [complex(x, y) for x in ex["re"] for y in ex["im"]]


def boundary(ex, n=30):
    (x0, x1), (y0, y1) = ex["re"], ex["im"]
    t = np.linspace(0.0, 1.0, n, endpoint=False)
    return np.concatenate([x0 + (x1 - x0) * t + 1j * y0, x1 + 1j * (y0 + (y1 - y0) * t),
                           x1 - (x1 - x0) * t + 1j * y1, x0 + 1j * (y1 - (y1 - y0) * t)])


def kpatch(ex, a):
    return np.array([kprin(E, a) for E in boundary(ex)])


def path_sample(V, n_low=240, s_low=1000.0, n_high=90):
    """Points of the path: dense over the first s_low MeV of arclength, coarse up to Lambda, vertices included."""
    Vc = np.asarray(V, complex)
    L = np.abs(np.diff(Vc))
    cum = np.concatenate([[0.0], np.cumsum(L)])
    s = np.unique(np.concatenate([np.linspace(0.0, s_low, n_low), np.linspace(s_low, cum[-1], n_high), cum]))
    j = np.clip(np.searchsorted(cum, s, side="right") - 1, 0, len(L) - 1)
    return Vc[j] + (s - cum[j]) / L[j] * (Vc[j + 1] - Vc[j])


def panel_rule(V, Lp=250.0, npan=16):
    """panel_rule of sp_contours.jl: Gauss-Legendre panels of at most Lp on every segment."""
    x, w = np.polynomial.legendre.leggauss(npan)
    qs, ws = [], []
    for a, b in zip(V[:-1], V[1:]):
        n = max(1, math.ceil(abs(b - a) / Lp))
        step = (b - a) / n
        for p in range(n):
            qs.append(a + p * step + (x + 1) * step / 2)
            ws.append(w * step / 2)
    return np.concatenate(qs), np.concatenate(ws)


def cut_crossings(Zg):
    """Re Z where Z crosses the negative real axis between neighbouring pairs of the sample grid."""
    out = []
    for A, B in ((Zg[:-1, :], Zg[1:, :]), (Zg[:, :-1], Zg[:, 1:])):
        m = (A.imag * B.imag < 0) & (A.real < 0) & (B.real < 0)
        t = A.imag[m] / (A.imag[m] - B.imag[m])
        out.append(A.real[m] + t * (B.real[m] - A.real[m]))
    return np.concatenate(out)


def cloud(ax, z, xlim, ylim, label=None, **kw):
    keep = (z.real > xlim[0]) & (z.real < xlim[1]) & (z.imag > ylim[0]) & (z.imag < ylim[1])
    ax.plot(z.real[keep], z.imag[keep], ".", rasterized=True, **kw)
    if label:
        ax.plot([], [], "o", ms=5, color=kw["color"], label=label)


def read_cert():
    with open(HERE / "cert_conditions.csv") as f:
        return {r["name"]: r for r in csv.DictReader(f)}


# ------------------------------------------------------------------------------------------ C1, C2: path pairs
def fig_path_pairs(cert):
    ex = EX["D"]
    V, _ = s40_path(ex)
    S = STEEP
    c = cert["D"]
    fig, axs = plt.subplots(1, 3, figsize=(20, 6.4))

    ax = axs[0]
    ax.fill([0, 900, 900], [0, 0, -900], color="tab:green", alpha=0.09, lw=0,
            label=r"cone $|\mathrm{Im}\,q|\leq\mathrm{Re}\,q$: where a path with slopes $\leq1$ runs")
    P = np.array(V)
    ax.plot(P.real, P.imag, "k-", lw=2.0, label=rf"S40 path of rectangle D (largest slope {float(c['slope']):.2f})")
    Sp = np.array(S)
    ax.plot(Sp.real, Sp.imag, "-", color="tab:orange", lw=1.6,
            label="a path C1 rejects: the steep probe path of Stage 2 (first leg of slope 20)")
    p0 = V[1]
    for sgn in (1, -1):
        ax.plot([p0.real - 330, p0.real + 330], [p0.imag - sgn * 330, p0.imag + sgn * 330], ":", color="0.35", lw=1.0)
    ax.plot(p0.real, p0.imag, "o", color="k", ms=5, zorder=6)
    ax.annotate(r"$45^\circ$ lines through a point $p'$ of the path:" "\n" r"every other point $q$ of the path lies" "\n"
                r"left or right of both, $|\mathrm{Im}(p'-q)|\leq|\mathrm{Re}(p'-q)|$",
                xy=(p0.real + 200, p0.imag + 200), xytext=(250, 120), fontsize=8.5,
                arrowprops=dict(arrowstyle="-", color="0.5", lw=0.6))
    for a in range(3):
        patch = kpatch(ex, a)
        ax.fill(patch.real, patch.imag, color=COLOR[NAMES[a]], alpha=0.75, lw=0.8,
                label=rf"$k_{{{NAMES[a]}}}(E)$ for $E$ in the rectangle")
    ax.axhline(0, color="0.8", lw=0.6, zorder=0)
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.set_xlim(-60, 900)
    ax.set_ylim(-560, 200)
    ax.set_aspect("equal")
    ax.set_xlabel(r"Re $q$ (MeV)")
    ax.set_ylabel(r"Im $q$ (MeV)")
    ax.set_title(r"(a) C1: slopes $\leq1$", fontsize=11)
    ax.legend(fontsize=8, loc="upper center", bbox_to_anchor=(0.5, -0.13), ncol=2)

    Pg, Ps = path_sample(V, n_low=320), path_sample(S, n_low=520)
    ax = axs[1]
    xlim, ylim = (-9.0, 9.0), (-6.5, 6.5)
    stats = {}
    for name, P_, col in (("steep", Ps, "tab:orange"), ("S40", Pg, "tab:blue")):
        W = np.concatenate([(MPI ** 2 + (P_[:, None] + t * P_[None, :]) ** 2).ravel() for t in (1, -1)]) / MPI ** 2
        stats[name] = W.real.min()
        cloud(ax, W, xlim, ylim, ms=1.6, color=col, alpha=0.45,
              label=rf"{name} path: smallest Re $w={W.real.min():.2f}\,m_\pi^2$")
    ax.axvline(1.0, color="tab:blue", ls="--", lw=1.0, label=r"Re $w=m_\pi^2$ (S35)")
    ax.plot([xlim[0], 0], [0, 0], color="tab:red", lw=3.0, solid_capstyle="butt", label=r"cut of $s=\sqrt{w}$")
    ax.axhline(0, color="0.8", lw=0.6, zorder=0)
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.set_xlabel(r"Re $w_\pm/m_\pi^2$")
    ax.set_ylabel(r"Im $w_\pm/m_\pi^2$")
    ax.set_title(r"(b) what C1 buys: $w_\pm=m_\pi^2+(p'\pm q)^2$ for all pairs $p',q$ on the path", fontsize=11)
    ax.legend(fontsize=8, loc="upper center", bbox_to_anchor=(0.5, -0.13), ncol=2)
    print(f"C1: smallest Re w / m_pi^2 on sampled pairs: S40 path {stats['S40']:.4f}, steep path {stats['steep']:.2f}")

    ax = axs[2]
    xlim, ylim = (-170.0, 430.0), (-430.0, 170.0)
    Ec = centre(ex)
    cross = []
    zs = []
    for beta in ORD:
        for tau in (1, -1):
            Zg = Z(Ps[:, None], Ps[None, :], Ec, MPI, beta, tau)
            zs.append(Zg.ravel())
            cross.append(cut_crossings(Zg))
    zs, cross = np.concatenate(zs), np.concatenate(cross)
    cloud(ax, zs, xlim, ylim, ms=1.6, color="tab:orange", alpha=0.4,
          label=rf"steep path at the centre of D: Re $Z$ down to {zs.real.min():.0f} MeV")
    zg = np.concatenate([Z(Pg[:, None], Pg[None, :], E, MPI, beta, tau).ravel()
                         for E in corners(ex) for beta in ORD for tau in (1, -1)])
    cloud(ax, zg, xlim, ylim, ms=1.6, color="tab:blue", alpha=0.45,
          label=rf"S40 path, the four corners of D: smallest Re $Z={zg.real.min():.1f}$ MeV")
    bound = float(c["s35_margin"])
    ax.axvline(bound, color="tab:blue", ls="--", lw=1.2,
               label=rf"C2 bound over D: $E_{{3,1}}-H^2/m_B-\max\mathrm{{Re}}\,E={bound:.1f}$ MeV")
    ax.plot([xlim[0], 0], [0, 0], color="tab:red", lw=3.0, solid_capstyle="butt", label=r"cut of $\log Z$")
    if cross.size:
        ax.plot(cross, np.zeros_like(cross), "x", color="k", ms=6, mew=1.2, zorder=6,
                label="steep path: $Z$ on the cut between neighbouring sampled pairs")
    ax.axhline(0, color="0.8", lw=0.6, zorder=0)
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.set_xlabel(r"Re $Z$ (MeV)")
    ax.set_ylabel(r"Im $Z$ (MeV)")
    ax.set_title(r"(c) C2: $Z^{(\beta)}_\pm=s_\pm+\nu_\beta$ for all pairs on the path, $\pi$, $\beta=1..4$", fontsize=11)
    ax.legend(fontsize=8, loc="upper center", bbox_to_anchor=(0.5, -0.13), ncol=1)
    zeta = np.concatenate([Z(Pg[:, None], Pg[None, :], E, MPHI["eta"], beta, tau).ravel()
                           for E in corners(ex) for beta in ORD for tau in (1, -1)])
    print(f"C2 (D): sampled min Re Z pion {zg.real.min():.3f}, eta {zeta.real.min():.1f}; package bound {bound:.3f}; "
          f"steep path at {Ec}: min Re Z {zs.real.min():.1f}, cut crossings {cross.size}")
    fig.tight_layout()
    fig.savefig(HERE / "cert_path_pairs.png", dpi=125)


# ------------------------------------------------------------------------------------------ C3: no on-shell node
def fig_poles(cert):
    fig, axs = plt.subplots(1, 2, figsize=(16, 6.6))
    ax = axs[0]
    V, _ = s40_path(EX["Bd"])
    ax.fill([0, 400, 400], [0, 0, -400], color="tab:green", alpha=0.09, lw=0,
            label="cone where paths with slopes $\\leq1$ run")
    xs, ys = np.linspace(-90, 330, 421), np.linspace(-200, 60, 261)
    X, Y = np.meshgrid(xs, ys)
    D = np.where(Y <= 0.0, G.path_dist_arr(V, X + 1j * Y), np.nan)
    ax.contourf(X, Y, D, levels=[0.0, R_NEAR], colors=["tab:red"], alpha=0.07)
    ax.contour(X, Y, D, levels=[R_NEAR], colors="tab:red", linestyles="--", linewidths=1.0)
    ax.plot([], [], "--", color="tab:red", lw=1.0, label=r"$r_{\rm near}=100$ MeV from the path")
    P = np.array(V)
    ax.plot(P.real, P.imag, "k-", lw=2.0, label=r"S40 path on $(-,+,+)$: one vertex, at $k_{PP}$ (off to the right)")
    xline = np.linspace(0, 200, 2)
    ax.plot(xline, -xline, ":", color="0.35", lw=1.0, label="line of slope 1 through the origin")
    delta, mu = CH[1][1], CH[1][2]
    traj = np.array([kprin(complex(delta + d, -0.3), 1) for d in np.linspace(-1e-4, -3.7, 500)])
    ax.plot(traj.real, traj.imag, "-", color=COLOR["PV"], lw=1.6,
            label=r"$k_{PV}(E)$, PV unflipped: $E$ from its threshold to 3.7 MeV below, Im $E=-0.3$ MeV")
    far = complex(delta - 3.3, -0.3)
    for name, E, marker, text in (
            ("B", centre(EX["B"]), dict(marker="*", ms=15, mfc="tab:red", mec="k"),
             "kept as on-shell node\n(passes C4, C5)"),
            ("Bd", centre(EX["Bd"]), dict(marker="o", ms=9, mfc="none", mec="tab:red", mew=1.8),
             "near, but its node fails C5:\ndropped, plain quadrature"),
            ("far", far, dict(marker="o", ms=9, mfc="none", mec="0.3", mew=1.8),
             r"beyond $r_{\rm near}$: no node")):
        k = kprin(E, 1)
        Vk, _ = s40_path(EX[name]) if name in EX else (V, None)
        d = G.path_dist(Vk, k)
        ax.plot(k.real, k.imag, ls="none", zorder=5, **marker)
        ax.annotate(f"{text}\n$k={k.real:.0f}{k.imag:+.0f}i$, {d:.0f} MeV from the path", xy=(k.real, k.imag),
                    xytext=(k.real + 55, k.imag + 4), fontsize=8.5, va="center",
                    arrowprops=dict(arrowstyle="-", color="0.5", lw=0.6))
        print(f"C3: {name}: E={E}, k_PV={k:.2f}, distance to its path {d:.2f} MeV"
              + (f"; package clearance {float(cert[name]['clearance']):.2f}" if name == "Bd" else ""))
    ax.text(-85, -186, "below the line of slope 1: on the sheet's side\nof every path with slopes $\\leq1$",
            fontsize=8.5, color="0.25")
    ax.axhline(0, color="0.8", lw=0.6, zorder=0)
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.set_xlim(-90, 330)
    ax.set_ylim(-200, 30)
    ax.set_aspect("equal")
    ax.set_xlabel(r"Re $q$ (MeV)")
    ax.set_ylabel(r"Im $q$ (MeV)")
    ax.set_title("(a) C3: the pole of a channel without an on-shell node stays under the path", fontsize=11)
    ax.legend(fontsize=7.5, loc="upper right")

    ax = axs[1]
    kappas = np.linspace(6.0, 150.0, 97)
    for npan, col in ((8, "0.65"), (16, "tab:blue"), (32, "0.35")):
        dist, err = [], []
        for kap in kappas:
            E = complex(delta - kap ** 2 / (2 * mu), -0.1)
            kpp = kprin(E, 2)
            Vp = [0j, complex(kpp.real, -min(abs(kpp.imag), kpp.real)), complex(LAM, 0.0)]
            q, w = panel_rule(Vp, npan=npan)
            k = kprin(E, 1)
            exact = 2 * mu * (LAM + k * k * (cmath.log((LAM - k) / (LAM + k)) - 1j * math.pi) / (2 * k))
            plain = np.sum(w * q * q * 2 * mu / (q * q - k * k))
            dist.append(G.path_dist(Vp, k))
            err.append(abs(plain - exact) / abs(exact))
        ax.semilogy(dist, err, "-", color=col, lw=1.8 if npan == 16 else 1.1,
                    label=rf"$n_p={npan}$ nodes per panel" + (" (starting value)" if npan == 16 else ""))
        if npan == 16:
            for d0 in (17.0, 45.0, 65.0, 86.0):
                j = int(np.argmin(np.abs(np.array(dist) - d0)))
                print(f"C3: plain quadrature, n_p=16: pole {dist[j]:.1f} MeV from the path, relative error {err[j]:.2e}")
    ax.axvline(R_NEAR, color="tab:red", ls="--", lw=1.0, label=r"$r_{\rm near}=100$ MeV: closer poles take a node if it certifies")
    ax.axvline(53.9, color="tab:red", ls=":", lw=1.0, label="closest dropped pole in the tiling, 53.9 MeV")
    ax.set_ylim(1e-17, 1e-1)
    ax.set_xlim(0, 150)
    ax.set_xlabel("distance of the pole from the path (MeV)")
    ax.set_ylabel("relative error of the PV loop without on-shell node")
    ax.set_title(r"(b) what the distance buys: plain panel quadrature, $L_p=250$ MeV", fontsize=11)
    ax.legend(fontsize=8, loc="upper right")
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(HERE / "cert_poles.png", dpi=125)


# ------------------------------------------------------------------------------------------ C4, C5: on-shell nodes
def window_panel(ax, ex, a, xlim, ylim, title, fail):
    V, chans = s40_path(ex)
    xs = np.linspace(xlim[0], xlim[1], 600)
    h = hgt(V, np.clip(xs, 0, LAM))
    ax.fill_between(xs, h - MPI, h + MPI, where=xs >= 0, color="tab:green", alpha=0.13, lw=0,
                    label=r"window $|\mathrm{Im}\,q-h(\mathrm{Re}\,q)|<m_\pi$")
    P = np.array(V)
    ax.plot(P.real, P.imag, "k-", lw=2.0, label="S40 path (fixed over the rectangle)")
    Es = corners(ex) + [centre(ex)]
    deltas = [kprin(E, a).imag - float(hgt(V, kprin(E, a).real)) for E in Es]
    E = Es[int(np.argmax(np.abs(deltas)))]
    k = kprin(E, a)
    name = NAMES[a]
    col = "tab:red" if fail else COLOR[name]
    for b in chans:
        if b != a:
            pb = kpatch(ex, b)
            ax.fill(pb.real, pb.imag, color=COLOR[NAMES[b]], alpha=0.8, lw=0.8,
                    label=rf"$k_{{{NAMES[b]}}}(E)$ over the rectangle")
    pa = kpatch(ex, a)
    ax.fill(pa.real, pa.imag, color=col, alpha=0.85, lw=0.8, label=rf"on-shell node $k_{{{name}}}(E)$ over the rectangle")
    for sgn in (1, -1):
        bp = pa + sgn * 1j * MPI
        ax.fill(bp.real, bp.imag, color="tab:orange", alpha=0.9, lw=0.8,
                label=rf"branch points $k_{{{name}}}\pm im_\pi$ of $s_-(k,q)$" if sgn == 1 else None)
        z0 = k + sgn * 1j * MPI
        ax.plot([z0.real, z0.real], [z0.imag, ylim[1] if sgn == 1 else ylim[0]], "-", color="tab:orange", lw=1.6,
                label=r"their cuts ($w_-\leq0$)" if sgn == 1 else None)
    c = complex(k.real, float(hgt(V, k.real)))
    off = 14.0
    ax.annotate("", xy=(k.real + off, k.imag), xytext=(c.real + off, c.imag),
                arrowprops=dict(arrowstyle="<->", color=col, lw=1.4), zorder=7)
    ax.text(k.real + off + 8, (k.imag + c.imag) / 2, rf"$\Delta=\mathrm{{Im}}\,k-h(\mathrm{{Re}}\,k)={max(deltas, key=abs):.1f}$ MeV",
            color=col, fontsize=9, va="center", zorder=8, bbox=dict(fc="white", ec="none", alpha=0.85, pad=1.5))
    if fail and abs(max(deltas, key=abs)) > MPI:
        ax.plot(c.real, c.imag, "x", color="tab:red", ms=13, mew=2.5, zorder=6, label="a cut crosses the path")
    ax.axhline(0, color="0.8", lw=0.6, zorder=0)
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.set_aspect("equal")
    ax.set_xlabel(r"Re $q$ (MeV)")
    ax.set_ylabel(r"Im $q$ (MeV)")
    ax.set_title(title, fontsize=11)
    ax.legend(fontsize=7.5, loc="upper right")
    print(f"C4: {title[:3]} node {name}: largest |Delta| at corners/centre {max(abs(d) for d in deltas):.2f} MeV, "
          f"m_pi - |Delta| = {MPI - max(abs(d) for d in deltas):.2f}; shown E={E}, k={k:.2f}, c={c:.2f}")
    return V, E, k


def node_pairs(ex, E, V, nodes, P):
    """Z at the pairs with an on-shell node, pion: (rows and columns, node-node, traces of the node-node pairs
    while both momenta move from the path to the node)."""
    rc, nn, traces = [], [], []
    ks = {a: kprin(E, a) for a in nodes}
    cs = {a: complex(ks[a].real, float(hgt(V, ks[a].real))) for a in nodes}
    for a in nodes:
        for tau in (1, -1):
            rc += [Z(ks[a], P, E, MPI, beta, tau) for beta in ROWS[a]]
            rc += [Z(P, ks[a], E, MPI, beta, tau) for beta in COLS[a]]
    lam = np.linspace(0.0, 1.0, 200)
    for a in nodes:
        for b in nodes:
            for beta in BLOCKS.get((a, b), ()):
                for tau in (1, -1):
                    nn.append(complex(Z(ks[a], ks[b], E, MPI, beta, tau)))
                    traces.append(Z(cs[a] + lam * (ks[a] - cs[a]), cs[b] + lam * (ks[b] - cs[b]), E, MPI, beta, tau))
    return np.concatenate(rc), np.array(nn), traces


def fig_nodes(cert):
    fig, axs = plt.subplots(2, 2, figsize=(17, 13.5))
    VA, EA, kA = window_panel(axs[0, 0], EX["A"], 1, (130.0, 600.0), (-250.0, 190.0),
                              r"(a) C4 holds: rectangle A, the on-shell node of PV", False)
    VF, EF, kF = window_panel(axs[0, 1], EX["F4"], 0, (-170.0, 420.0), (-560.0, 170.0),
                              r"(b) C4 fails: $(-,-,-)$, VV flipped 29 MeV below its threshold", True)

    ax = axs[1, 0]
    dx = np.linspace(-90.0, 90.0, 721)
    for V, E, k, col, lab in ((VA, EA, kA, COLOR["PV"], "A, PV node"), (VF, EF, kF, "tab:red", "F4, VV node")):
        x = k.real + dx
        ok = x >= 0
        q = x[ok] + 1j * hgt(V, x[ok])
        s = np.sqrt(MPI ** 2 + (k - q) ** 2 + 0j)
        delta = k.imag - float(hgt(V, k.real))
        ax.plot(dx[ok], s.imag, "-", color=col, lw=1.8, label=rf"Im $s_-$, {lab} ($\Delta={delta:.1f}$ MeV)")
        ax.plot(dx[ok], s.real, "--", color=col, lw=1.2, label=rf"Re $s_-$, {lab}")
        j = int(np.argmin(np.abs(dx[ok])))
        print(f"C4: {lab}: at Re q = Re k, w_- = m^2 - Delta^2 = {MPI ** 2 - delta ** 2:.0f} MeV^2, s_- = {s[j]:.2f}; "
              f"jump of Im s_- across it {s.imag[min(j + 1, len(s) - 1)] - s.imag[max(j - 1, 0)]:.1f} MeV")
    ax.axvline(0, color="0.6", lw=0.8, ls=":")
    ax.axhline(0, color="0.8", lw=0.6)
    ax.set_xlabel(r"Re $q-\mathrm{Re}\,k$ along the path (MeV)")
    ax.set_ylabel(r"principal $s_-(k,q)=\sqrt{m_\pi^2+(k-q)^2}$ (MeV)")
    ax.set_title(r"(c) what C4 prevents: the principal root jumps where a cut crosses the path", fontsize=11)
    ax.legend(fontsize=8, loc="upper right")
    ax.grid(alpha=0.3)

    ax = axs[1, 1]
    xlim, ylim = (-140.0, 470.0), (-230.0, 150.0)
    for name, nodes, col, lab in (("F5", (1, 2), "tab:red", "F5 (excluded; PV flipped 1.3 MeV below its threshold)"),
                                  ("A", (1, 2), "tab:blue", "A (certified)")):
        ex = EX[name]
        V, _ = s40_path(ex)
        P = path_sample(V, n_low=500, s_low=1500.0, n_high=200)
        rc, nn, traces = [], [], []
        for E in corners(ex) + [centre(ex)]:
            r, n, t = node_pairs(ex, E, V, nodes, P)
            rc.append(r)
            nn.append(n)
            traces += t
        rc, nn = np.concatenate(rc), np.concatenate(nn)
        cloud(ax, rc, xlim, ylim, ms=1.6, color=col, alpha=0.35, label=f"{lab}: node rows and columns, $(k,q)$ and $(q,k)$")
        for i, t in enumerate(traces):
            ax.plot(t.real, t.imag, "-", color=col, lw=0.6, alpha=0.6,
                    label=f"{lab}: node-node pairs followed from the path to the nodes" if i == 0 else None)
        ax.plot(nn.real, nn.imag, "*", color=col, ms=11, mec="k", mew=0.6, ls="none", zorder=5,
                label=f"{lab}: node-node pairs $(k,k')$, smallest Re $Z={nn.real.min():.1f}$ MeV")
        print(f"C5: {name}: sampled min Re Z rows/columns {rc.real.min():.2f}, node-node {nn.real.min():.2f} MeV; "
              f"package: {cert[name]['status']} {cert[name]['z_margin'] or cert[name]['reason']}")
    bound = float(cert["A"]["z_margin"])
    ax.axvline(bound, color="tab:blue", ls="--", lw=1.2, label=rf"certified bound of A over the rectangle: {bound:.1f} MeV")
    ax.plot([xlim[0], 0], [0, 0], color="tab:red", lw=3.0, solid_capstyle="butt", label=r"cut of $\log Z$")
    ax.axhline(0, color="0.8", lw=0.6, zorder=0)
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.set_xlabel(r"Re $Z$ (MeV)")
    ax.set_ylabel(r"Im $Z$ (MeV)")
    ax.set_title(r"(d) C5: $Z=s_\pm+\nu_\beta$ at the pairs with an on-shell node, $\pi$", fontsize=11)
    ax.legend(fontsize=7.5, loc="lower right")
    fig.tight_layout()
    fig.savefig(HERE / "cert_nodes.png", dpi=115)


def main():
    cert = read_cert()
    fig_path_pairs(cert)
    fig_poles(cert)
    fig_nodes(cert)


if __name__ == "__main__":
    main()
