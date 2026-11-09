# /// script
# dependencies = ["numpy>=1.26", "matplotlib>=3.8"]
# ///
"""Branch points of the TOPT OME kernel V(p', q; E) in the loop-momentum plane, p' on the real path.

Exchanged-meson branch points: q = +-p' +- i m_phi (notes/07-continued-lse.tex, S33).
Three-body branch points: the genuine roots of the quartic of S36, s_tau + nu_beta = 0 with the principal
s_tau, which is the continuation of the real-axis kernel along vertical segments in q.
p' runs over [0, 1000] MeV; beyond p' ~ 850 MeV no three-body branch point exists at these energies.

Run: uv run --script notes/07-continued-lse/branch_points_real_path.py
Writes notes/07-continued-lse/branch_points_real_path.png and prints the numbers quoted with the figure.
A plot of the note's formulas, not a check. Units MeV.
"""
from pathlib import Path

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

mB, mV = 5279.52, 5324.75
dm = mV - mB
MPHI = {"pi": 138.039, "eta": 548.0}
ORD = {1: (-2 * dm, 1 / (2 * mB), 1 / (2 * mB)), 2: (0.0, 1 / (2 * mV), 1 / (2 * mV)),
       3: (-dm, 1 / (2 * mV), 1 / (2 * mB)), 4: (-dm, 1 / (2 * mB), 1 / (2 * mV))}
ENERGIES = (-67.85, -22.62, 0.0, 20.0, 45.0)
PP = np.linspace(0.0, 1000.0, 4001)


def three_body(beta, m, E, tau):
    """Genuine three-body branch points for p' in PP: arrays (upper, lower), NaN where none."""
    t, h, a = ORD[beta]
    up = np.full(PP.size, np.nan + 0j)
    lo = np.full(PP.size, np.nan + 0j)
    worst = 0.0
    for i, p in enumerate(PP):
        c = t + h * p * p - E
        for q in np.roots([a * a, 0.0, 2 * a * c - 1, -2 * tau * p, c * c - m * m - p * p]):
            if abs(q) > 3000:
                continue
            s = np.sqrt(complex(m * m + (p + tau * q) ** 2))
            if abs(s) > 1e-3:  # polish on F = s + nu, principal s
                for _ in range(3):
                    s = np.sqrt(complex(m * m + (p + tau * q) ** 2))
                    q = q - (s + c + a * q * q) / (tau * (p + tau * q) / s + 2 * a * q)
            s = np.sqrt(complex(m * m + (p + tau * q) ** 2))
            nu = c + a * q * q
            if abs(s + nu) <= 1e-9 * (abs(s) + abs(nu) + 1):
                worst = max(worst, abs(s + nu))
                if q.imag > 0:
                    up[i] = q
                else:
                    lo[i] = q
    return up, lo, worst


curves = {(phi, beta, E, tau): three_body(beta, m, E, tau)
          for phi, m in MPHI.items() for beta in ORD for E in ENERGIES for tau in (-1, 1)}

# ---- numbers quoted with the figure
print("max |s + nu| at plotted points:", max(v[2] for v in curves.values()), "MeV")
print("\np' = 0 (q = +-i kappa) and last p' with a genuine branch point (pion, tau = -1):")
for beta in ORD:
    t, h, a = ORD[beta]
    for E in ENERGIES:
        up, lo, _ = curves[("pi", beta, E, -1)]
        ok = ~np.isnan(lo.real)
        if not ok.any():
            print(f"  beta={beta} E={E:7.2f}: none")
            continue
        last = PP[ok][-1]
        estimate = np.sqrt((E - t) / (h + a)) if E > t else float("nan")
        print(f"  beta={beta} E={E:7.2f}: q(0) = {lo[0].real:+.2f}{lo[0].imag:+.2f}i, ends at p' = {last:6.1f} "
              f"(nu(p',p') = 0 at {estimate:6.1f}), end point {lo[ok][-1].real:.1f}{lo[ok][-1].imag:+.1f}i")
diffs = [np.abs(curves[("pi", 3, E, -1)][1] - curves[("pi", 4, E, -1)][1]) for E in ENERGIES]
d34 = max(np.nanmax(d) for d in diffs if not np.all(np.isnan(d)))
print(f"\nmax |q(beta=3) - q(beta=4)| over the pion curves: {d34:.3f} MeV")
for E in (-67.85 - 10j, -22.62 - 10j):
    up, lo, _ = three_body(1, MPHI["pi"], E, -1)
    print(f"pion beta=1 E={E}: q(0) = {lo[0].real:+.2f}{lo[0].imag:+.2f}i and {up[0].real:+.2f}{up[0].imag:+.2f}i")
for E in ENERGIES:
    up, lo, _ = curves[("eta", 1, E, -1)]
    print(f"eta beta=1 E={E:7.2f}: q(0) = {lo[0].imag:+.2f}i, i.e. {MPHI['eta'] + lo[0].imag:.1f} MeV inside the line")

# ---- matplotlib figure (repository copy)
colors = plt.cm.viridis(np.linspace(0, 0.9, len(ENERGIES)))
fig, axes = plt.subplots(2, 2, figsize=(12, 8.8))
panels = [("pi", (1,), "(a) $\\pi$, $\\beta=1$: $B\\bar B\\pi$ (in $PV\\leftarrow PV$), $E_3=47.58$ MeV"),
          ("pi", (3, 4), "(b) $\\pi$, $\\beta=3,4$: $B\\bar B^*\\pi$ ($VV\\leftrightarrow PV$, $VV\\leftrightarrow PP$), "
                         "$E_3=92.81$ MeV"),
          ("pi", (2,), "(c) $\\pi$, $\\beta=2$: $B^*\\bar B^*\\pi$ ($VV\\leftarrow VV$, $PV\\leftarrow PV$, "
                       "$VV\\leftrightarrow PV$), $E_3=138.04$ MeV"),
          ("eta", (1, 2, 3, 4), "(d) $\\eta$, all orderings, upper half: $E_3\\geq457.54$ MeV")]
for ax, (phi, betas, title) in zip(axes.flat, panels):
    m = MPHI[phi]
    for k, E in enumerate(ENERGIES):
        for beta in betas:
            for tau in (-1, 1):
                up, lo, _ = curves[(phi, beta, E, tau)]
                style = "-" if beta in (1, 3) or phi == "eta" else (":" if beta == 4 else "--")
                label = f"E = {E:g} MeV" if (beta == betas[0] and tau == -1) else None
                ax.plot(up.real, up.imag, style, color=colors[k], lw=1.6, label=label)
                ax.plot(lo.real, lo.imag, style, color=colors[k], lw=1.6)
                ok = ~np.isnan(lo.real)
                if ok.any() and tau == -1:
                    ax.plot([lo[0].real, up[0].real], [lo[0].imag, up[0].imag], "o", color=colors[k], ms=4)
    ax.axhline(m, color="0.45", ls=(0, (5, 4)), lw=1.1)
    ax.axhline(-m, color="0.45", ls=(0, (5, 4)), lw=1.1, label="exchanged-meson: $q=\\pm p'\\pm im_\\phi$")
    ax.plot([0, 1000], [0, 0], color="k", lw=3.2, solid_capstyle="butt", label="real path $[0,\\Lambda]$, $\\Lambda=4$ GeV")
    ax.axvline(0, color="0.8", lw=0.6, zorder=0)
    ax.set_xlim(-150, 950)
    ax.set_ylim(*((-175, 175) if phi == "pi" else (470, 565)))
    ax.set_xlabel("Re $q$ (MeV)")
    ax.set_ylabel("Im $q$ (MeV)")
    ax.set_title(title, fontsize=9.5)
up, lo, _ = curves[("pi", 1, 45.0, -1)]
for pv in (0, 200, 400, 600):
    i = int(round(pv / (PP[1] - PP[0])))
    axes[0, 0].annotate(f"$p'={pv}$", (lo[i].real, lo[i].imag), xytext=(5, 5), textcoords="offset points", fontsize=8)
    axes[0, 0].plot(lo[i].real, lo[i].imag, "k.", ms=5)
axes[1, 0].text(560, -150, "$E\\leq0$: none (root has $s=+\\nu$)", fontsize=8.5)
axes[0, 1].text(330, -165, "$\\beta=4$ (dotted) on top of $\\beta=3$", fontsize=8.5)
handles, labels = axes[0, 0].get_legend_handles_labels()
fig.legend(handles, labels, loc="lower center", ncol=7, fontsize=8.5, frameon=False)
fig.suptitle("Branch points of $V(p',q;E)$ in the $q$ plane as $p'$ runs over the real path (principal $s_\\pm$)\n"
             "lower half mirrors the upper for real $E$; beyond Re $q\\approx850$ MeV only the dashed lines continue, "
             "to $\\pm\\Lambda$", fontsize=10.5)
fig.tight_layout(rect=(0, 0.03, 1, 1))
out = Path(__file__).with_suffix(".png")
fig.savefig(out, dpi=150)
print("\nwrote", out)
