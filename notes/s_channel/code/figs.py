"""Figures for the s-channel note. All inputs: Xb.tex tables / central.toml.
Outputs PDFs into OUT (argument 1)."""
import sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from cornell import solve_cornell, form_factor, G, MU, V0_FIT, M_TH, MB_QUARK
from toy import bound_states, compact_prob

OUT = sys.argv[1] if len(sys.argv) > 1 else "."
HBARC = 0.1973269804
plt.rcParams.update({"font.size": 10, "axes.labelsize": 11, "legend.fontsize": 8.5,
                     "figure.dpi": 150, "mathtext.fontset": "cm", "font.family": "serif"})
COL = plt.cm.viridis(np.linspace(0.0, 0.9, 7))

r, dr, eps, u = solve_cornell(nstates=7)
E0 = 2 * MB_QUARK + eps - M_TH
Ebare = E0 + V0_FIT

# ---------------------------------------------------------------- u_n(r)
fig, ax = plt.subplots(figsize=(5.2, 3.3))
rf = r * HBARC
for n in range(4):
    ax.plot(rf, u[:, n], color=COL[n], lw=1.6, label=fr"$n={n+1}$")
for n in range(4, 7):
    ax.plot(rf, u[:, n], color=COL[n], lw=0.9, ls="--", label=fr"$n={n+1}$")
ax.axhline(0, color="k", lw=0.5)
ax.axvline(1.21, color="gray", lw=0.8, ls=":")
ax.text(1.23, 0.62, r"$V(r)=\hat E_1$" "\n" r"($r\approx1.2$ fm)", fontsize=8, color="gray")
ax.set_xlim(0, 3.0)
ax.set_xlabel(r"$r$ [fm]")
ax.set_ylabel(r"$u_n(r)=rR_{1n}(r)$ [GeV$^{1/2}$]")
ax.legend(ncol=2, frameon=False)
fig.tight_layout()
fig.savefig(f"{OUT}/un_r.pdf")
plt.close(fig)

# ------------------------------------------- lattice model, Bulava 2024 Eq. (6)
V0L, SIG, GAM = -0.835 / 0.1443 * HBARC, 0.1061 / 0.1443**2 * HBARC**2, -0.434
E1L, E2L = 0.0034 / 0.1443 * HBARC, 0.1005 / 0.1443 * HBARC
GLL, GSL = 0.0256 / 0.1443 * HBARC, 0.0134 / 0.1443 * HBARC
rr = np.linspace(0.25, 2.0, 600) / HBARC          # GeV^-1
Vr = V0L + SIG * rr + GAM / rr
lev3 = []
for x, v in zip(rr, Vr):
    H = np.array([[v, np.sqrt(2) * GLL, GSL], [np.sqrt(2) * GLL, E1L, 0.0], [GSL, 0.0, E2L]])
    lev3.append(np.linalg.eigvalsh(H))
lev3 = np.array(lev3)
fig, ax = plt.subplots(figsize=(5.2, 3.3))
rf = rr * HBARC
ax.plot(rf, Vr * 1e3, color="gray", ls="--", lw=0.9, label=r"$\hat V(r)$ (string, diabatic)")
ax.axhline(E1L * 1e3, color="tab:blue", ls="--", lw=0.9, label=r"$\hat E_1$ ($B\bar B$, diabatic)")
ax.axhline(E2L * 1e3, color="tab:green", ls="--", lw=0.9, label=r"$\hat E_2$ ($B_s\bar B_s$, diabatic)")
for k in range(3):
    ax.plot(rf, lev3[:, k] * 1e3, color="k", lw=1.5, label="eigenvalues (adiabatic levels)" if k == 0 else None)
ax.axvline(1.211, color="tab:red", lw=0.7, ls=":")
ax.text(1.03, 330, r"$r_l^\star=1.21$ fm", color="tab:red", fontsize=8, ha="right")
ax.set_ylim(-500, 400)
ax.set_xlim(0.25, 2.0)
ax.set_xlabel(r"$r$ [fm]")
ax.set_ylabel(r"$E - 2E_{\bar Q l}$ [MeV]")
ax.legend(frameon=False, loc="lower right", fontsize=7.5, bbox_to_anchor=(1.0, 0.0))
fig.tight_layout()
fig.savefig(f"{OUT}/lattice_levels.pdf")
plt.close(fig)

# ---------------------------------------------------------------- f_n(p)
p = np.linspace(0.0, 2.5, 700)
f = form_factor(p, r, dr, u).real
fig, ax = plt.subplots(figsize=(5.2, 3.3))
for n in range(4):
    ax.plot(p, f[:, n], color=COL[n], lw=1.6, label=fr"$f_{n+1}(p)$")
for n in range(4, 7):
    ax.plot(p, f[:, n], color=COL[n], lw=0.9, ls="--", label=fr"$f_{n+1}(p)$")
ax.axhline(0, color="k", lw=0.5)
ax.axvline(0.695, color="gray", lw=0.8, ls=":")
ax.text(0.71, 30, r"$\kappa\simeq0.695$ GeV" "\n" r"($E_B=91$ MeV)", fontsize=8, color="gray")
ax.set_xlim(0, 2.5)
ax.set_xlabel(r"$p$ [GeV]")
ax.set_ylabel(r"$f_n(p)=\psi_n(p)/\sqrt{4\pi}$ [GeV$^{-3/2}$]")
ax.legend(ncol=2, frameon=False)
fig.tight_layout()
fig.savefig(f"{OUT}/fn_p.pdf")
plt.close(fig)

# ------------------------------------------------- V^(bb)(0,0;E) for N = 4
E = np.linspace(-0.85, 0.35, 4000)
f0 = form_factor([0.0], r, dr, u).real[0]
fig, ax = plt.subplots(figsize=(6.4, 3.3))
tot = np.zeros_like(E)
for n in range(4):
    term = G**2 * f0[n] ** 2 / (E - Ebare[n])
    tot += term
    ax.plot(E * 1e3, term, color=COL[n], lw=0.9, ls="--", label=fr"$n={n+1}$ term")
mask = np.min(np.abs(E[:, None] - Ebare[None, :4]), axis=1) < 0.004
tot[mask] = np.nan
ax.plot(E * 1e3, tot, color="k", lw=1.6, label=r"sum, $N=4$")
for n in range(4):
    ax.axvline(Ebare[n] * 1e3, color=COL[n], lw=0.6, ls=":")
ax.axhline(0, color="k", lw=0.5)
ax.axvline(0, color="r", lw=0.8)
ax.text(5, -55, r"$B\bar B^*$ thr.", color="r", fontsize=8)
ax.set_ylim(-60, 60)
ax.set_xlabel(r"$E=M-M_{\rm th}$ [MeV]")
ax.set_ylabel(r"$V^{(\bar bb)}_S(0,0;E)$ [GeV$^{-2}$]")
ax.legend(frameon=False, loc="upper left", bbox_to_anchor=(1.01, 1.0))
fig.tight_layout()
fig.savefig(f"{OUT}/V_of_E.pdf")
plt.close(fig)

# ------------------------------------------------------------ level diagram
exp = np.array([9.89278, 10.25546, 10.5134]) - M_TH
full = [("$\\chi_{b1}(1P)$", -0.711, COL[0]), ("$\\chi_{b1}(2P)$", -0.349, COL[1]),
        ("$X_b$", -0.091, "tab:red"), ("$\\chi_{b1}(3P)$", -0.061, COL[2])]
toyp = [-0.71361, -0.34943, -0.06055]
fig, (ax, az) = plt.subplots(1, 2, figsize=(7.4, 3.9), gridspec_kw={"width_ratios": [1.35, 1.0]})
w = 0.32
def lev(a, x, y, c, ls="-", lw=2.0):
    a.plot([x - w, x + w], [y * 1e3, y * 1e3], color=c, ls=ls, lw=lw)
for a in (ax, az):
    for n in range(5):
        lev(a, 0, E0[n], COL[n])
        lev(a, 1, Ebare[n], COL[n])
        if a is ax:
            a.plot([w, 1 - w], [E0[n] * 1e3, Ebare[n] * 1e3], color="gray", lw=0.4, ls=":")
    for n, y in enumerate(toyp):
        lev(a, 2, y, COL[n])
    for name, y, c in full:
        lev(a, 3, y, c)
    for y in exp:
        lev(a, 4, y, "k")
    a.axhline(0, color="r", lw=0.8)
    a.set_xticks(range(5))
    a.set_xticklabels(["reference\n$E_n^{(0)}$\n($V_0=0$)", "bare\n$E_n^{(0)}+V_0$",
                       "s-channel\nonly\n(this note)", "full LO\n(paper\nTab. V)", "exp.\n(RPP)"], fontsize=7.5)
    a.set_xlim(-0.5, 4.5)
ax.set_ylabel(r"$E=M-M_{\rm th}$ [MeV]")
ax.set_ylim(-1150, 520)
ax.text(4.45, 15, r"$B\bar B^*$ thr.", color="r", fontsize=7.5, ha="right", va="bottom")
ax.add_patch(plt.Rectangle((-0.5, -120), 5.0, 140, fill=False, ec="gray", lw=0.7, ls="--"))
az.set_ylim(-120, 20)
az.set_title("zoom: near threshold", fontsize=8.5)
for name, y, c in full:
    if y > -0.12:
        az.text(3.0, y * 1e3 - 7, name, fontsize=7.5, ha="center", color=c)
az.text(1.0, Ebare[2] * 1e3 + 3, r"bare $n=3$", fontsize=7.5, ha="center")
az.text(2.0, toyp[2] * 1e3 + 3, r"dressed $n=3$", fontsize=7.5, ha="center")
az.text(4.0, exp[2] * 1e3 + 4, r"10.513 GeV", fontsize=7.5, ha="center")
fig.tight_layout()
fig.savefig(f"{OUT}/levels.pdf")
plt.close(fig)

# ------------------------------------------------ toy poles vs coupling g
gs = np.linspace(0.002, 0.26, 130)
pts = []
for gg in gs:
    for pe in bound_states(4, g=gg, ngrid=3000):
        pts.append((gg, pe, compact_prob(pe, 4, g=gg).sum()))
pts = np.array(pts)
fig, ax = plt.subplots(figsize=(5.2, 3.4))
sc = ax.scatter(pts[:, 0] * 1e3, pts[:, 1] * 1e3, c=pts[:, 2], cmap="plasma", vmin=0, vmax=1, s=6)
cb = fig.colorbar(sc, ax=ax)
cb.set_label(r"${\cal P}_{\bar bb}$")
ax.axvline(G * 1e3, color="gray", ls=":", lw=0.9)
ax.text(G * 1e3 + 3, -650, r"$g=57$ MeV" "\n(lattice)", fontsize=8, color="gray")
ax.axhline(0, color="r", lw=0.8)
ax.set_xlabel(r"$g$ [MeV]")
ax.set_ylabel(r"bound-state energy $E$ [MeV]")
ax.set_ylim(-820, 20)
fig.tight_layout()
fig.savefig(f"{OUT}/toy_vs_g.pdf")
plt.close(fig)
print("figures written to", OUT)
