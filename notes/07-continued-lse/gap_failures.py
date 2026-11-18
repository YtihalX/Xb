# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""The two kinds of S40 certificate failure in the tiling before near nodes were made optional (2026-11-15), and the
fixes proposed for them: near nodes optional, adopted on 2026-11-15, and S35 without its H^2 term, still open
(NOTEBOOK.md). Reads gap_failures_tiling_before.csv, a copy of code/Xb2Continuation/scripts/s40_tiling.csv as it
was before that decision. Plot evidence, not a check. Units MeV.

gap_failures.png, one row per search-domain gap:
  (a) the momentum plane at a representative energy: the S40 path, the poles, the near node that fails (red), the
      singular points of q -> V(k, q) for that node with pion exchange (S33 exchange points, S36 three-body points)
      and the cuts of the failing pair's square root and logarithm, and the vertical homotopy from the path to k;
  (b) the same around the node;
  (c) Z = s_+ + nu_beta at the node pair (k, k), followed along the homotopy that moves both momenta from the path
      to k, for several Im E at the same Re E; C5 asks Re Z > 0, the logarithm's cut is the negative real axis;
  (d) the energy plane: the cells excluded under the adopted rule, and the same cells with the near node switched
      off (gap_failures_fix.csv, written by gap_failures_fix.jl with r_near = 60 MeV).
s35_h2.png, the (-,-,-) exclusions next to E_{3,1}:
  (a) the momentum plane at E = 42 - 40i: the S40 path and the three-body points of V(p', q) for p' on the path;
  (b) along Im E = -40 and -10 MeV: the sampled smallest Re Z over pairs on the path, the S35 bound with its H^2
      term (certificate condition C2) and the bound without it (s40-proposal.tex, L4).
"""
import cmath
import csv
import pathlib

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Rectangle

import _s40geom as G

HERE = pathlib.Path(__file__).parent
TILING = HERE / "gap_failures_tiling_before.csv"
FIX = HERE / "gap_failures_fix.csv"
LAM, CH, MPHI, ORD = G.LAM, G.CH, G.MPHI, G.ORD
NAMES = ("VV", "PV", "PP")
COLOR = {"VV": "tab:purple", "PV": "tab:green", "PP": "tab:blue"}
ROWS = {0: (2, 3), 1: (1, 2, 4), 2: (4,)}  # orderings of V(k_alpha, q), note 07 S3 (code: _SP_ROWS)
MPI = MPHI["pi"]
R_NEAR = 100.0


def kprin(E, a):
    """Principal momentum of channel a: closed fourth quadrant (Xb2Continuation.principal_momentum)."""
    k = cmath.sqrt(2 * CH[a][2] * (E - CH[a][1]))
    return -k if k.imag > 0 else k


def sp_path(E, flips):
    """S40 path for a cell centred at E: vertex for every flipped channel and every channel above threshold."""
    chans = [a for a in range(3) if flips[a] or CH[a][1] < E.real]
    vs = sorted((complex(kprin(E, a).real, -min(abs(kprin(E, a).imag), kprin(E, a).real)) for a in chans),
                key=lambda z: z.real)
    return [0j] + vs + [complex(LAM, 0.0)], chans


def height(V, x):
    for a, b in zip(V[:-1], V[1:]):
        if a.real <= x <= b.real:
            return a.imag + (b.imag - a.imag) * (x - a.real) / (b.real - a.real)
    return 0.0


def Z(pp, q, E, m, beta, tau):
    t, h, a = ORD[beta]
    return np.sqrt(m * m + (pp + tau * q) ** 2 + 0j) + t + h * pp * pp + a * q * q - E


def log_cut(k, E, m, beta, tau, q0, rmax=400.0, dr=0.25):
    """The set Z(k, q) in (-inf, 0] from the three-body point q0, followed by Newton continuation in -Z. With the
    principal s it ends where it meets the cut of s (s -> 0 at the exchange point), so the trace stops there."""
    t, h, a = ORD[beta]
    out, q = [q0], complex(q0)
    for r in np.arange(dr, rmax, dr):
        prev = q
        for _ in range(30):
            s = cmath.sqrt(m * m + (k + tau * q) ** 2)
            if abs(s) < 0.5:
                return np.array(out + [q])
            f = s + t + h * k * k + a * q * q - E + r
            q -= f / (tau * (k + tau * q) / s + 2 * a * q)
            if abs(f) < 1e-10:
                break
        if abs(q - prev) > 5.0 or abs(q) > 2000:
            break
        out.append(q)
    return np.array(out)


def read_csv(path):
    with open(path) as f:
        return list(csv.DictReader(f))


CASES = (
    dict(tag="A1", title="(-,+,+), PV just below its threshold", flips=(False, False, True), E=complex(-46.60, -0.35),
         node=1, beta=1, tau=1, delta=CH[1][1], window=((-47.6, -45.0), (-1.1, 0.02)),
         ims=(-1.5, -0.35, -0.1, -0.02, -0.004)),
    dict(tag="A2", title="(-,-,+), VV just below its threshold", flips=(False, True, True), E=complex(-1.40, -0.04),
         node=0, beta=2, tau=1, delta=CH[0][1], window=((-2.4, 0.05), (-0.22, 0.005)),
         ims=(-0.5, -0.04, -0.01, -0.002, -0.0004)),
)


def failure_row(axs, case, tiling, fix):
    E, a, beta, tau = case["E"], case["node"], case["beta"], case["tau"]
    V, chans = sp_path(E, case["flips"])
    k = kprin(E, a)
    c = complex(k.real, height(V, k.real))
    name = NAMES[a]
    d_path = G.path_dist(V, k)
    ex = {"k+im": k + 1j * MPI, "k-im": k - 1j * MPI, "-k+im": -k + 1j * MPI, "-k-im": -k - 1j * MPI}
    tb = [(b, s, complex(z)) for b in ROWS[a] for s in (1, -1)
          for z in G.three_body(np.array([k]), E, MPI, b, s).ravel() if not np.isnan(z)]
    fail_tb = [z for b, s, z in tb if b == beta and s == tau]
    cuts = [log_cut(k, E, MPI, beta, tau, z) for z in fail_tb if z.imag < 0]
    zkk = complex(Z(k, k, E, MPI, beta, tau))
    print(f"{case['tag']}: E={E}; k_{name}={k:.2f}; c={c:.2f}; distance to path {d_path:.1f}; 2 Re k={2 * k.real:.2f}; "
          f"Z(k,k) [pi, beta={beta}, tau={tau:+d}] = {zkk:.2f}; three-body points of the failing pair: "
          + ", ".join(f"{z:.1f}" for z in fail_tb))

    for ax, zoom in ((axs[0], False), (axs[1], True)):
        P = np.array(V)
        ax.plot(P.real, P.imag, "k-", lw=1.6, label=r"path $\mathcal{C}_Q$" if not zoom else None, zorder=3)
        # square-root cuts of w_pm(k, q): vertical rays from the exchange points away from the path's side
        for key, z in ex.items():
            sgn = 1 if key.endswith("+im") else -1
            ax.plot([z.real, z.real], [z.imag, z.imag + sgn * 2000], color="0.55", lw=1.0, ls="-",
                    label=r"cuts of $s_\pm$ ($w_\pm\leq0$)" if key == "k+im" and not zoom else None, zorder=1)
        ax.plot([z.real for z in ex.values()], [z.imag for z in ex.values()], "x", color="0.3", ms=7, mew=1.5,
                label=r"$\pm k\pm im_\pi$ (S33)" if not zoom else None, zorder=4)
        if tb:
            ax.plot([z.real for _, _, z in tb], [z.imag for _, _, z in tb], "^", color="tab:orange", ms=6,
                    mfc="none", label="three-body points (S36)" if not zoom else None, zorder=4)
        for i, cut in enumerate(cuts):
            ax.plot(cut.real, cut.imag, color="tab:red", lw=1.2, ls="--",
                    label=rf"cut of $\log Z_+^{{({beta})}}(k,q)$" if i == 0 and not zoom else None, zorder=2)
            ax.plot(cut[0].real, cut[0].imag, "^", color="tab:red", ms=8, zorder=5)
        for b in range(3):
            kb = kprin(E, b)
            node = b in chans
            ax.plot(kb.real, kb.imag, "o", ms=8, color=COLOR[NAMES[b]], mfc=COLOR[NAMES[b]] if node else "none",
                    mew=1.5, zorder=5, label=(f"$k_{{{NAMES[b]}}}$, " + ("vertex node" if node else "no node"))
                    if b != a and not zoom else None)
        ax.plot([c.real, k.real], [c.imag, k.imag], ":", color="tab:red", lw=2.0, zorder=4,
                label=r"homotopy $c\to k$ of the node pair" if not zoom else None)
        ax.plot(k.real, k.imag, "*", color="tab:red", ms=15, mec="k", zorder=6,
                label=rf"$k_{{{name}}}$: near node (fails C5)" if not zoom else None)
        if not zoom:
            th = np.linspace(0, 2 * np.pi, 200)
            ax.plot(k.real + R_NEAR * np.cos(th), k.imag + R_NEAR * np.sin(th), color="tab:red", lw=0.8, alpha=0.6,
                    label=r"$|q-k|=r_{\rm near}=100$ MeV", zorder=2)
            ax.set_xlim(-250, 750)
            ax.set_ylim(-330, 250)
            ax.set_title(f"({'a' if case['tag'] == 'A1' else 'e'}) {case['title']}: $E={E.real:.2f}{E.imag:+.2f}i$ MeV",
                         fontsize=10)
            ax.legend(fontsize=7, loc="upper right", framealpha=0.9)
        else:
            ax.set_xlim(-75, 95)
            ax.set_ylim(-175, 25)
            y = k.imag + 8
            ax.annotate("", xy=(-k.real, y), xytext=(k.real, y), arrowprops=dict(arrowstyle="<->", color="k", lw=0.8))
            ax.text(0, y + 3, rf"$2\,\mathrm{{Re}}\,k={2 * k.real:.1f}$ MeV", ha="center", fontsize=8)
            ax.text(k.real + 3, k.imag - 9, rf"$k_{{{name}}}$, {d_path:.0f} MeV below the path", fontsize=8, color="tab:red")
            ax.set_title(f"({'b' if case['tag'] == 'A1' else 'f'}) around the node: the pair $(k,k)$ beside the cuts of "
                         "$V(k,\\cdot)$", fontsize=10)
        ax.axhline(0, color="0.8", lw=0.6, zorder=0)
        ax.axvline(0, color="0.8", lw=0.6, zorder=0)
        ax.set_xlabel(r"Re $q$ (MeV)")
        ax.set_ylabel(r"Im $q$ (MeV)")
        ax.set_aspect("equal")

    ax = axs[2]
    cmap = plt.get_cmap("viridis")
    for i, im in enumerate(case["ims"]):
        Ei = complex(E.real, im)
        Vi, _ = sp_path(Ei, case["flips"])
        ki = kprin(Ei, a)
        ci = complex(ki.real, height(Vi, ki.real))
        seg = ci + np.linspace(0, 1, 600) * (ki - ci)
        z = Z(seg, seg, Ei, MPI, beta, tau)
        col = cmap(i / max(1, len(case["ims"]) - 1))
        ax.plot(z.real, z.imag, color=col, lw=1.5, label=rf"Im $E={im:g}$ MeV")
        ax.plot(z[-1].real, z[-1].imag, "o", color=col, ms=6)
        ax.plot(z[0].real, z[0].imag, "s", color=col, ms=4)
    ax.axvline(0, color="k", lw=0.8, ls=":", label=r"C5 needs Re $Z>0$")
    ax.plot([-400, 0], [0, 0], color="tab:red", lw=2.5, label=r"cut of $\log Z$")
    ax.set_xlim(-80, 130)
    ax.set_ylim(-160, 40)
    ax.set_xlabel(r"Re $Z$ (MeV)")
    ax.set_ylabel(r"Im $Z$ (MeV)")
    ax.set_title(f"({'c' if case['tag'] == 'A1' else 'g'}) $Z_+^{{({beta})}}$ at the pair, $\\pi$: square at the path, "
                 "dot at $(k,k)$", fontsize=10)
    ax.legend(fontsize=7, loc="upper left")

    ax = axs[3]
    (x0, x1), (y0, y1) = case["window"]
    for r in tiling:
        if r["region"] != case["tag"]:
            continue
        a0, a1, b0, b1 = (float(r[s]) for s in ("re_lo", "re_hi", "im_lo", "im_hi"))
        if a1 < x0 or a0 > x1 or b1 < y0 or b0 > y1:
            continue
        if r["status"] == "certified":
            ax.add_patch(Rectangle((a0, b0), a1 - a0, b1 - b0, fill=False, ec="0.6", lw=0.5))
        else:
            ax.add_patch(Rectangle((a0, b0), a1 - a0, b1 - b0, fc="0.75", ec="0.5", lw=0.3))
    n_fix = n_all = 0
    clear = []
    for r in fix:
        if r["region"] != case["tag"]:
            continue
        n_all += 1
        if r["status_fix"] == "certified":
            n_fix += 1
            clear.append(float(r["clearance_fix"]))
            a0, a1, b0, b1 = (float(r[s]) for s in ("re_lo", "re_hi", "im_lo", "im_hi"))
            ax.add_patch(Rectangle((a0, b0), a1 - a0, b1 - b0, fill=False, ec="tab:green", lw=0.9))
    mu = CH[a][2]
    for kap, txt in ((np.sqrt(MPI ** 2 - (CH[2][1] - CH[1][1]) ** 2) / 2 if a == 1 else MPI / 2,
                      r"$\kappa=\sqrt{m_\pi^2-\Delta^2}/2$" if a == 1 else r"$\kappa=m_\pi/2$"),
                     (R_NEAR, r"$\kappa=r_{\rm near}$")):
        xe = case["delta"] - kap ** 2 / (2 * mu)
        ax.axvline(xe, color="tab:red", ls=":", lw=1.0)
        ax.text(xe, y0 + 0.04 * (y1 - y0), txt, rotation=90, fontsize=7, color="tab:red", ha="right", va="bottom")
    ax.axvline(case["delta"], color="k", ls="--", lw=0.8)
    ax.text(case["delta"], y0 + 0.5 * (y1 - y0), f"{name} threshold", rotation=90, fontsize=7, ha="right")
    ax.plot(E.real, E.imag, "*", color="tab:red", ms=12, mec="k")
    ax.set_xlim(x0, x1)
    ax.set_ylim(y0, y1)
    ax.set_xlabel(r"Re $E$ (MeV)")
    ax.set_ylabel(r"Im $E$ (MeV)")
    ax.add_patch(Rectangle((0, 0), 0, 0, fc="0.75", ec="0.5", label="excluded, adopted rule (C5)"))
    ax.add_patch(Rectangle((0, 0), 0, 0, fill=False, ec="tab:green", label=f"same cells, near node off: {n_fix}/{n_all} certified"))
    ax.add_patch(Rectangle((0, 0), 0, 0, fill=False, ec="0.6", label="certified, adopted rule"))
    ax.legend(fontsize=7, loc="lower left", bbox_to_anchor=(0.0, 0.12), framealpha=0.9)
    ax.set_title(f"({'d' if case['tag'] == 'A1' else 'h'}) the gap; fix: no node, pole $\\geq${min(clear):.1f} MeV "
                 "from the path" if clear else "the gap", fontsize=10)
    print(f"{case['tag']}: fix certifies {n_fix}/{n_all} gap cells; smallest clearance {min(clear) if clear else None} MeV")


def s35_figure(tiling):
    fig, axs = plt.subplots(1, 2, figsize=(15, 6.2))
    flips = (True, True, True)
    E = complex(42.0, -40.0)
    V, _ = sp_path(E, flips)
    H = -min(v.imag for v in V)
    ax = axs[0]
    P = np.array(V)
    pp = G.sample(V, 400)
    tb = G.three_body_all(pp, E)
    ax.plot(tb.real, tb.imag, ".", ms=1.5, color="tab:orange", label=r"three-body points of $V(p',q)$, $p'\in\mathcal{C}$")
    ax.plot(P.real, P.imag, "k-", lw=1.6, label=r"path $\mathcal{C}_Q$ through $k_{VV},k_{PV},k_{PP}$")
    for b in range(3):
        kb = kprin(E, b)
        ax.plot(kb.real, kb.imag, "o", ms=8, color=COLOR[NAMES[b]], label=f"$k_{{{NAMES[b]}}}$ (vertex node)")
    ax.axhline(-H, color="0.5", ls="--", lw=0.8, label=f"depth $H={H:.0f}$ MeV")
    xs = np.linspace(0, 1500, 10)
    ax.plot(xs, -xs, color="0.7", lw=0.8, ls=":", label="slope-1 line")
    dmin = G.path_dist_arr(V, tb).min() if tb.size else np.inf
    ax.set_xlim(-300, 1500)
    ax.set_ylim(-700, 500)
    ax.set_aspect("equal")
    ax.set_xlabel(r"Re $q$ (MeV)")
    ax.set_ylabel(r"Im $q$ (MeV)")
    ax.set_title(f"(a) $(-,-,-)$ at $E=42-40i$ MeV: nearest three-body point {dmin:.0f} MeV from the path", fontsize=10)
    ax.legend(fontsize=7, loc="upper right")
    print(f"S35: E={E}, H={H:.1f}, nearest three-body point {dmin:.1f} MeV from the path")

    ax = axs[1]
    e3 = {b: min(m + ORD[b][0] for m in MPHI.values()) for b in ORD}
    for im, ls in ((-40.0, "-"), (-10.0, "--")):
        res = np.linspace(20.0, 47.0, 28)
        zmin, b35, b4 = [], [], []
        for re in res:
            Ei = complex(re, im)
            Vi, _ = sp_path(Ei, flips)
            Hi = -min(v.imag for v in Vi)
            zmin.append(G.min_re_Z(Vi, Ei, n=500)[0])
            b35.append(min(m + t - (h + a) * Hi ** 2 - re for m in MPHI.values() for (t, h, a) in ORD.values()))
            b4.append(min(m + t for m in MPHI.values() for (t, h, a) in ORD.values()) - re)
        ax.plot(res, zmin, "o", color="k", ms=4, mfc="none" if im == -40.0 else "k",
                label=rf"sampled min Re $Z$ on $\mathcal{{C}}\times\mathcal{{C}}$, Im $E={im:g}$")
        ax.plot(res, b35, ls, color="tab:red", label=rf"S35 bound with $H^2$ (C2), Im $E={im:g}$")
        ax.plot(res, b4, ls, color="tab:green", label=rf"bound without $H^2$ (L4), Im $E={im:g}$")
        onset = min((float(r["re_lo"]) for r in tiling if r["region"] in ("C1", "C2") and r["status"] == "excluded"
                     and float(r["im_lo"]) <= im <= float(r["im_hi"])), default=np.nan)
        ax.axvline(onset, color="tab:red", ls=ls, lw=0.6, alpha=0.6)
        print(f"S35 scan Im E={im}: tiling excludes from Re E={onset:.2f}; bound with H^2 crosses zero near "
              f"{res[np.argmax(np.array(b35) < 0)] if (np.array(b35) < 0).any() else None}; min sampled Re Z={min(zmin):.2f}")
    ax.axhline(0, color="0.5", lw=0.8)
    ax.set_xlabel(r"Re $E$ (MeV) on $(-,-,-)$")
    ax.set_ylabel(r"Re $Z$ (MeV)")
    ax.set_title("(b) C2 fails where the $H^2$ term drives the bound negative; Re $Z$ stays positive", fontsize=10)
    ax.legend(fontsize=7, loc="upper right")
    fig.tight_layout()
    fig.savefig(HERE / "s35_h2.png", dpi=150)


def main():
    tiling = read_csv(TILING)
    fix = read_csv(FIX)
    fig, axs = plt.subplots(2, 4, figsize=(24, 11.5))
    for row, case in zip(axs, CASES):
        failure_row(row, case, tiling, fix)
    fig.suptitle("Search-domain gaps: a near node on its own channel's on-shell left-hand cut, and the gap with that "
                 "node switched off", fontsize=12)
    fig.tight_layout()
    fig.savefig(HERE / "gap_failures.png", dpi=130)
    s35_figure(tiling)


if __name__ == "__main__":
    main()
