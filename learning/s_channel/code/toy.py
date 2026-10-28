"""Toy: s-channel bottomonium exchange ONLY (no OME, no contact), to isolate
what the s-channel term does. Bound states from det[(E-E_n)/g^2 delta + J(E)] = 0,
J_nm(E) = int_0^Lam q^2dq/(2pi^2) f_n(q) f_m(q) 2mu/(q^2+kappa^2),  E = -kappa^2/(2mu).
This is Xb.tex Eq. (det) with T^OME = 0 and the contact row removed (C -> 0).
"""
import numpy as np
from scipy.optimize import brentq
from cornell import solve_cornell, form_factor, G, MU, V0_FIT, M_TH

r, dr, eps, u = solve_cornell(nstates=7)
E0 = 2 * 4.534047672900046 + eps - M_TH          # reference energies (V0 = 0)

LAM = 4.0
xq, wq = np.polynomial.legendre.leggauss(400)
q = 0.5 * LAM * (xq + 1)
wq = 0.5 * LAM * wq
fq = form_factor(q, r, dr, u).real                 # (nq, 7)


def jmat(E, nst):
    kap2 = -2 * MU * E
    gfun = 2 * MU / (q**2 + kap2)
    w = wq * q**2 / (2 * np.pi**2) * gfun
    f = fq[:, :nst]
    return f.T @ (w[:, None] * f)


def mmat(E, nst, g=G, V0=V0_FIT):
    Eb = E0[:nst] + V0
    return np.diag((E - Eb) / g**2) + jmat(E, nst)


def detfun(E, nst, g=G, V0=V0_FIT):
    # scale rows by g^2 to keep the determinant O(1)
    M = mmat(E, nst, g, V0) * g**2
    return np.linalg.det(M)


def bound_states(nst, g=G, V0=V0_FIT, emin=-1.2, emax=-1e-6, ngrid=6000):
    Es = np.linspace(emin, emax, ngrid)
    vals = np.array([detfun(E, nst, g, V0) for E in Es])
    roots = []
    for i in range(ngrid - 1):
        if np.sign(vals[i]) != np.sign(vals[i + 1]):
            roots.append(brentq(detfun, Es[i], Es[i + 1], args=(nst, g, V0), xtol=1e-12))
    return roots


def compact_prob(E, nst, g=G, V0=V0_FIT, h=1e-6):
    M = mmat(E, nst, g, V0)
    w, v = np.linalg.eigh(M)
    c = v[:, np.argmin(abs(w))]
    dM = (mmat(E + h, nst, g, V0) - mmat(E - h, nst, g, V0)) / (2 * h)
    norm = c @ dM @ c
    c = c / np.sqrt(norm)                         # c^T dM/dE c = 1  (Eq. residue-normalisation)
    lam = c / g                                   # lambda_n = c_n / g
    return lam**2


if __name__ == "__main__":
    print("bare energies E_n^(0)+V0 [MeV]:", np.round((E0 + V0_FIT) * 1e3, 1))
    for nst in (4, 7):
        print(f"--- s-channel only, N={nst}, g={G*1e3:.1f} MeV, V0={V0_FIT*1e3:.1f} MeV")
        for Ep in bound_states(nst):
            lam2 = compact_prob(Ep, nst)
            print(f"  pole E = {Ep*1e3:8.2f} MeV  M = {M_TH+Ep:.4f} GeV  "
                  f"P_bb = {lam2.sum()*100:6.2f}%  per n: {np.round(lam2*100, 2)}")
    # coupling dependence for N=4
    print("--- N=4, poles vs g (MeV):")
    for gg in (0.0001, 0.02, 0.057154760664, 0.1, 0.15, 0.2):
        ps = bound_states(4, g=gg)
        print(f"  g={gg*1e3:6.1f}: " + "  ".join(f"{p*1e3:8.2f}" for p in ps))
