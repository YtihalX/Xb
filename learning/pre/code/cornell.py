"""Independent reproduction of the bare P-wave Cornell spectrum and the
j0 transition form factors of Xb.tex (Sect. III.A, App. A).

Units: GeV, GeV^-1. Parameters from HadronDynamics.jl data/bochiEFT/central.toml,
which coincide with Xb.tex Table I/II and Eq. (mb).
"""
import numpy as np
from scipy.linalg import eigh_tridiagonal

MB_QUARK = 4.534047672900046   # m_b [GeV]
SIGMA = 0.19840639309997352    # string tension [GeV^2]
GAMMA = -0.434                 # Coulomb coefficient (dimensionless)
M_B, M_BST = 5.27952, 5.32475  # B, B* masses [GeV]
M_TH = M_B + M_BST
MU = 2.6509501131648436        # B Bbar* reduced mass used in the code [GeV]
G_L = 0.035                    # lattice g_l [GeV]
G = 2.0 / np.sqrt(3.0) * np.sqrt(2.0) * G_L  # Eq. (g)
V0_FIT = 0.3714694358359325    # fitted V0 [GeV] (Table III, central)
C_FIT = -16.26782020427067     # fitted C [GeV^-2]


def solve_cornell(mb=MB_QUARK, sigma=SIGMA, gamma=GAMMA, nstates=7,
                  nr=12000, rbox=30.0):
    """Finite-difference P-wave radial problem, App. A Eq. (eq:radial):
    [-u''/m_b + 2/(m_b r^2) + sigma r + gamma/r] u = eps u, u(0)=u(rbox+dr)=0."""
    dr = rbox / nr
    r = dr * np.arange(1, nr + 1)
    w = 2.0 / (mb * r**2) + sigma * r + gamma / r
    diag = 2.0 / (mb * dr**2) + w
    off = -np.ones(nr - 1) / (mb * dr**2)
    eps, vec = eigh_tridiagonal(diag, off, select="i", select_range=(0, nstates - 1))
    u = vec / np.sqrt(dr)                 # int u^2 dr = 1
    for n in range(nstates):              # phase: f_n(0) > 0  <=>  int r u dr > 0
        if np.sum(r * u[:, n]) * dr < 0:
            u[:, n] *= -1
    return r, dr, eps, u


def form_factor(p, r, dr, u):
    """f_n(p) = sqrt(4 pi)/p int u_n(r) sin(p r) dr   (App. A Eq. (fneval)).
    p may be complex (p = i kappa gives the sinh form, Eq. (fnkappa))."""
    p = np.atleast_1d(np.asarray(p, dtype=complex))
    out = np.empty((p.size, u.shape[1]), dtype=complex)
    for i, pp in enumerate(p):
        if abs(pp) < 1e-12:
            kern = r                       # lim sin(pr)/p = r
        else:
            kern = np.sin(pp * r) / pp
        out[i] = np.sqrt(4 * np.pi) * (kern[:, None] * u).sum(axis=0) * dr
    return out


if __name__ == "__main__":
    r, dr, eps, u = solve_cornell()
    M0 = 2 * MB_QUARK + eps
    E0 = M0 - M_TH
    print("g =", G)
    print("n   eps_n      M_n^(0)    E_n^(0)    E_n^(0)+V0(353)  E_n^(0)+V0fit")
    for n in range(len(eps)):
        print(f"{n+1}  {eps[n]: .5f}  {M0[n]: .5f}  {E0[n]: .5f}  {E0[n]+0.353: .5f}  {E0[n]+V0_FIT: .5f}")
    # quark-model-only V0 fit (Eq. V0QM): minimise mean square deviation to exp masses
    mexp = np.array([9.89278, 10.25546, 10.5134])
    v0 = np.mean(mexp - M0[:3])
    dm = np.sqrt(np.mean((M0[:3] + v0 - mexp) ** 2))
    print(f"V0^(bb) = {v0*1e3:.1f} MeV, Delta M_min = {dm*1e3:.1f} MeV")
    sp_th = (M0[1] - M0[0]) - (M0[2] - M0[1])
    sp_ex = (mexp[1] - mexp[0]) - (mexp[2] - mexp[1])
    print(f"level-spacing difference: theory {sp_th*1e3:.1f} MeV, exp {sp_ex*1e3:.1f} MeV")
    f0 = form_factor([0.0], r, dr, u)[0].real
    print("f_n(0) [GeV^-3/2]:", np.round(f0, 4))
    # normalisation check  int_0^inf p^2 dp/(2 pi^2) |f_n(p)|^2 = 1 ?
    pg = np.linspace(1e-4, 12.0, 6000)
    ff = form_factor(pg, r, dr, u).real
    norms = np.trapezoid(pg[:, None] ** 2 * ff**2, pg, axis=0) / (2 * np.pi**2)
    print("int p^2dp/(2pi^2) f_n^2:", np.round(norms, 4))
    # rms radius and turning points
    rms = np.sqrt((r[:, None] ** 2 * u**2).sum(axis=0) * dr)
    print("rms radius [fm]:", np.round(rms * 0.1973269804, 3))
