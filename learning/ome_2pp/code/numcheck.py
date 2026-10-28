"""Brute-force check of the projected OME, independent of the n = e_z reduction.

For physical masses (Xb.tex Eqs. (2),(6)), g_b = 0.56, F_pi = 0.0922 GeV, a real
energy below all thresholds, and a few (p', p), evaluate Eq. (80) by direct
quadrature over BOTH unit spheres, with the TOPT propagators D_beta(q) of
Eqs. (76),(77) evaluated at each q = p - p'.  Compare with
sum_m C_m Delta_m^{(b1 b2)}, Delta_m from 1D Gauss-Legendre in x.

Run: uv run --no-project --with numpy --with sympy python numcheck.py
"""
import itertools
import os

import numpy as np
import sympy as sp

import ome
from ome import CHANNELS_1PP, CHANNELS_2PP, PROJ, NPOL, project, spin_tensor

mB, mBs = 5.279, 5.325
dm = mBs - mB
gb, fpi = 0.56, 0.0922
masses = {"pi": 0.138, "eta": 0.548}

nvec = sp.symbols("n0:3", real=True)
qvec = sp.symbols("q0:3", real=True)


def lambdify_tensor(arr, args):
    flat = np.asarray(arr, dtype=object).ravel()
    f = sp.lambdify(args, list(flat), "numpy")
    shape = np.asarray(arr, dtype=object).shape

    def ev(*vals):
        out = f(*vals)
        size = np.broadcast(*vals).shape
        return np.array([np.broadcast_to(np.asarray(o, dtype=complex), size) for o in out]).reshape(shape + size)
    return ev


PROJ_NUM = {name: lambdify_tensor(spec[2](np.array(nvec, dtype=object)), nvec) for name, spec in PROJ.items()}
SPIN_NUM = {}
for ko, ki in itertools.product(("PP", "PV", "VV"), repeat=2):
    V, pref, combo = spin_tensor(ko, ki, np.array(qvec, dtype=object))
    if V is not None:
        SPIN_NUM[(ko, ki)] = (lambdify_tensor(V, qvec), float(pref), combo)


def mus(pv, ppv, E):
    """Eq. (77): mu_1..mu_4 (p incoming, p' outgoing), E counted from m_B + m_B*."""
    return {1: -dm + (pv**2 + ppv**2) / (2 * mB) - E,
            2: dm + (pv**2 + ppv**2) / (2 * mBs) - E,
            3: pv**2 / (2 * mB) + ppv**2 / (2 * mBs) - E,
            4: ppv**2 / (2 * mB) + pv**2 / (2 * mBs) - E}


def Dsum(combo, q2, pv, ppv, E, m):
    om = np.sqrt(q2 + m**2)
    mu = mus(pv, ppv, E)
    return sum(1 / (2 * om * (om + mu[b])) for b in combo)


# quadrature on the sphere: Gauss-Legendre in cos(theta) x uniform in phi
nt, nphi = (int(v) for v in os.environ.get("NUMCHECK_GRID", "20,24").split(","))
ct, wt = np.polynomial.legendre.leggauss(nt)
ph = 2 * np.pi * np.arange(nphi) / nphi
CT, PH = np.meshgrid(ct, ph, indexing="ij")
ST = np.sqrt(1 - CT**2)
NS = np.stack([ST * np.cos(PH), ST * np.sin(PH), CT]).reshape(3, -1)  # (3, npts)
WS = (np.repeat(wt, nphi) / (2 * nphi)).reshape(-1)                    # weights sum to 1 = dOmega/4pi
xg, wg = np.polynomial.legendre.leggauss(64)


def brute(name_out, name_in, pv, ppv, E, m):
    ko, J = PROJ[name_out][0], PROJ[name_out][1]
    ki = PROJ[name_in][0]
    if (ko, ki) not in SPIN_NUM:
        return 0.0
    Vf, pref, combo = SPIN_NUM[(ko, ki)]
    no, ni = NPOL[ko], NPOL[ki]
    Xo = PROJ_NUM[name_out](*NS).reshape(3**no, -1, NS.shape[1])   # (B, J, b) at n'
    Xi = PROJ_NUM[name_in](*NS).reshape(3**ni, -1, NS.shape[1])    # (A, J, a) at n
    # q = p n - p' n' for all pairs (n: index a, chunked; n': index b)
    val = 0.0
    for start in range(0, NS.shape[1], 48):
        sl = slice(start, start + 48)
        Q = pv * NS[:, sl, None] - ppv * NS[:, None, :]       # (3, na, nb)
        Vt = Vf(*Q).reshape(3**no, 3**ni, *Q.shape[1:])       # (B, A, na, nb)
        Ds = Dsum(combo, (Q**2).sum(0), pv, ppv, E, m)         # (na, nb)
        tr = np.einsum("BJb,BAab,AJa->ab", Xo.conj(), Vt, Xi[:, :, sl])
        val += np.einsum("a,b,ab->", WS[sl], WS, tr * Ds)
    return pref * val / (2 * J + 1)


def formula(name_out, name_in, pv, ppv, E, m):
    coeffs, combo = project(name_out, name_in)
    if not coeffs:
        return 0.0
    q2 = pv**2 + ppv**2 - 2 * pv * ppv * xg
    Ds = Dsum(combo, q2, pv, ppv, E, m)
    tot = 0.0
    for mm, c in coeffs.items():
        cval = float(c.subs({ome.p: pv, ome.pp: ppv}))
        tot += cval * np.sum(wg * xg**mm * Ds)
    return tot


print(f"sphere grid: {nt} x {nphi} points per sphere")
E = -0.120  # GeV below the B Bbar* threshold: below all three thresholds, D_beta real
for chans in (CHANNELS_1PP, CHANNELS_2PP):
    worst, where = 0.0, None
    for (pv, ppv) in [(0.31, 0.57), (0.83, 0.22)]:
        for m in masses.values():
            vals = {(o, i): (brute(o, i, pv, ppv, E, m), formula(o, i, pv, ppv, E, m)) for o in chans for i in chans}
            scale = max(abs(f) for _, f in vals.values())
            for key, (b, f) in vals.items():
                assert abs(complex(b).imag) < 1e-12 * scale, (key, b)
                dev = abs(complex(b).real - f) / scale
                if dev > worst:
                    worst, where = dev, (key, pv, ppv, m)
    print(f"== {chans}: max |brute - formula| / max|V| = {worst:.1e}  (at {where})")
# sample values (units GeV^-2 after multiplying by g_b^2/F_pi^2), pion exchange, isospin factor 3 not included
print("\n== sample: 2++ elements at p'=0.57, p=0.31 GeV, E=-0.12 GeV, m_pi (times g_b^2/F_pi^2 = %.1f GeV^-2)" % (gb**2 / fpi**2))
for o in CHANNELS_2PP:
    row = [formula(o, i, 0.31, 0.57, E, masses["pi"]) * gb**2 / fpi**2 for i in CHANNELS_2PP]
    print(f"  {o:>4}: " + " ".join(f"{v:+.4f}" for v in row))
