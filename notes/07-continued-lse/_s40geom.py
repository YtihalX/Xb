"""Shared geometry for the S40 figure scripts of this folder (deep_paths.py, onshell_lhc.py); not a check.

Channels and TOPT offsets of notes/07-continued-lse.tex (S3), the free-resolvent poles +-k_alpha with the sheet
placement of S27, a line-by-line replica of Xb2Continuation.graph_path (code/Xb2Continuation/src/paths.jl,
vertical (P) certification included), the singular points of V(p', q; E) (S33, S36) and the rank-one free loops
of checks/rank_one_paths.jl. Units MeV.
"""
import cmath
import math

import numpy as np

mB, mV = 5279.52, 5324.75  # HadronDynamics BOchiEFT.Parameters()
DM = mV - mB
LAM = 4000.0
CH = (("VV", 0.0, mV / 2, 1), ("PV", -DM, mB * mV / (mB + mV), 5), ("PP", -2 * DM, mB / 2, 6))
MPHI = {"pi": 138.039, "eta": 548.0}
ORD = {1: (-2 * DM, 1 / (2 * mB), 1 / (2 * mB)), 2: (0.0, 1 / (2 * mV), 1 / (2 * mV)),
       3: (-DM, 1 / (2 * mV), 1 / (2 * mB)), 4: (-DM, 1 / (2 * mB), 1 / (2 * mV))}
E3 = MPHI["pi"] + ORD[1][0]  # 47.58 MeV, lowest three-body threshold (S5)
EPS = np.finfo(float).eps


# ---------------------------------------------------------------- poles and the S40 builder (paths.jl replica)
def sheet_k(E, delta, mu):
    """sheet_momentum of paths.jl: flipped k has Im k <= 0, unflipped Im k >= 0."""
    k = cmath.sqrt(2 * mu * (E - delta))
    flipped = delta < E.real
    if (k.imag > 0) if flipped else (k.imag < 0):
        k = -k
    return k, flipped


def poles(E):
    out = []
    for name, delta, mu, idx in CH:
        k, f = sheet_k(E, delta, mu)
        out.append({"name": name, "idx": idx, "k": k, "flipped": f, "q4": k if f else -k})
    return out


def seg_dist(a, b, z):
    v = b - a
    t = min(max(((z - a) * v.conjugate()).real / abs(v) ** 2, 0.0), 1.0)
    return abs(z - (a + t * v))


def path_dist(V, z):
    return min(seg_dist(V[j], V[j + 1], z) for j in range(len(V) - 1))


def path_dist_arr(V, z):
    z = np.asarray(z, complex)
    best = np.full(z.shape, np.inf)
    for a, b in zip(V[:-1], V[1:]):
        v = b - a
        t = np.clip(((z - a) * np.conj(v)).real / abs(v) ** 2, 0.0, 1.0)
        best = np.minimum(best, np.abs(z - (a + t * v)))
    return best


def inside(V, z):
    x, y = z.real, z.imag
    if not (0 < x < V[-1].real and y < 0):
        return False
    for a, b in zip(V[:-1], V[1:]):
        if a.real <= x <= b.real:
            return a.imag + (x - a.real) * (b - a).imag / (b - a).real < y
    return False


def vertical_clear(V, E):
    """_vertical_poles_clear: no pole touches the path while E runs down from E* to E."""
    radius = abs(E.imag)
    if radius == 0:
        return True
    roundoff = 64 * EPS * max(1000.0, abs(E), V[-1].real)
    for _, delta, mu, _ in CH:
        speed = mu / math.sqrt(2 * mu * abs(E.real - delta))
        stack = [(-radius, radius)]
        while stack:
            a, b = stack.pop()
            mid = a + (b - a) / 2
            k = cmath.sqrt(2 * mu * complex(E.real - delta, mid))
            dist = min(path_dist(V, k), path_dist(V, -k))
            if dist > speed * (b - a) / 2 + roundoff:
                continue
            if not (dist > roundoff and a < mid < b):
                return False
            stack += [(a, mid), (mid, b)]
    return True


def s40_path(E, d, vertical=True):
    """graph_path(E, ths; margin=d) for Im E < 0 with a flipped channel; None where the package excludes.
    vertical=False skips the vertical (P) certification, for scans that re-check it on the final path."""
    P = poles(E)
    fl = [p["q4"] for p in P if p["flipped"]]
    if E.imag >= 0 or not fl or any(E.real == delta for _, delta, _, _ in CH):
        return None
    if any(E.real >= delta + LAM ** 2 / (2 * mu) for _, delta, mu, _ in CH):
        return None
    # One upward rounding, as in paths.jl, so that H - |Im k| cannot undershoot the margin.
    H = math.nextafter(max(-k.imag for k in fl) + d, math.inf)
    A, B = min(k.real for k in fl), max(k.real for k in fl)
    x2 = math.nextafter(LAM - H, -math.inf)
    if not (H <= A and B <= x2 and H < x2):
        return None
    cap = H - max(-k.imag for k in fl)

    def clears(x):
        return all(seg_dist(0j, complex(x, -H), k) >= cap for k in fl)

    if not clears(H):
        return None
    lo, hi = H, A
    if clears(hi):
        lo = hi
    else:
        for _ in range(200):
            mid = lo + (hi - lo) / 2
            if mid in (lo, hi):
                break
            lo, hi = (mid, hi) if clears(mid) else (lo, mid)
    x1 = lo
    if not x1 < x2:
        return None
    V = [0j, complex(x1, -H), complex(x2, -H), complex(LAM, 0.0)]
    for p in P:
        if inside(V, p["q4"]) != p["flipped"]:
            return None
        if min(path_dist(V, p["k"]), path_dist(V, -p["k"])) < d:
            return None
    return V if not vertical or vertical_clear(V, E) else None


def leg_path(H, s=1.0):
    """Three segments: first leg of slope s to depth H, flat, last leg of slope 1 back to Lambda."""
    return [0j, complex(H / s, -H), complex(LAM - H, -H), complex(LAM, 0.0)]


def pole_margin(V, E):
    """Smallest distance of +-k_alpha from the path, or NaN if a pole is on the wrong side (S27)."""
    P = poles(E)
    if any(inside(V, p["q4"]) != p["flipped"] for p in P):
        return float("nan")
    return min(min(path_dist(V, p["k"]), path_dist(V, -p["k"])) for p in P)


# ---------------------------------------------------------------- loops (rank-one model, form factor 1)
def gl_rule(V, n):
    x, w = np.polynomial.legendre.leggauss(n)
    q, wq = [], []
    for a, b in zip(V[:-1], V[1:]):
        h = (b - a) / 2
        q.append(a + (x + 1) * h)
        wq.append(w * h)
    return np.concatenate(q), np.concatenate(wq)


def loops_gl(V, E, n):
    q, w = gl_rule(V, n)
    return np.array([np.sum(w * q * q * (2 * mu / (q * q - 2 * mu * (E - delta)))) / (2 * np.pi ** 2)
                     for _, delta, mu, _ in CH])


def loops_closed(E):
    """r1_f of checks/_rank_one.jl on the sheet of S27."""
    return np.array([mu / np.pi ** 2 * (LAM + k / 2 * (cmath.log((LAM - k) / (LAM + k)) + 1j * np.pi))
                     for (_, delta, mu, _), k in ((c, sheet_k(E, c[1], c[2])[0]) for c in CH)])


def loops_cauchy(V, E):
    """Exact integral along the polygon: principal Log per straight segment; independent of the sheet choice."""
    out = []
    for _, delta, mu, _ in CH:
        k = cmath.sqrt(2 * mu * (E - delta))
        tot = sum((b - a) + k / 2 * (cmath.log((b - k) / (a - k)) - cmath.log((b + k) / (a + k)))
                  for a, b in zip(V[:-1], V[1:]))
        out.append(mu / np.pi ** 2 * tot)
    return np.array(out)


# ---------------------------------------------------------------- singular points of V(p', q; E)
def sample(V, n):
    V = np.asarray(V, complex)
    L = np.abs(np.diff(V))
    cum = np.concatenate([[0.0], np.cumsum(L)])
    s = np.linspace(0.0, cum[-1], n)
    j = np.clip(np.searchsorted(cum, s, side="right") - 1, 0, len(L) - 1)
    return V[j] + (s - cum[j]) / L[j] * (V[j + 1] - V[j])


def three_body(pp, E, m, beta, tau):
    """Genuine roots of the S36 quartic for each p' in pp: array (N, 4), NaN where none. Solved in GeV."""
    t, h, a = ORD[beta]
    P = np.atleast_1d(np.asarray(pp, complex)) / 1e3
    Eg, mg, tg, hg, ag = E / 1e3, m / 1e3, t / 1e3, h * 1e3, a * 1e3
    c = tg + hg * P * P - Eg
    comp = np.zeros((P.size, 4, 4), complex)
    comp[:, 0, 1] = -(2 * ag * c - 1) / ag ** 2
    comp[:, 0, 2] = 2 * tau * P / ag ** 2
    comp[:, 0, 3] = -(c * c - mg * mg - P * P) / ag ** 2
    comp[:, 1, 0] = comp[:, 2, 1] = comp[:, 3, 2] = 1
    q = np.linalg.eigvals(comp)
    Pc, cc = P[:, None], c[:, None]
    with np.errstate(all="ignore"):
        for _ in range(4):  # polish on F = s + nu with the principal s
            s = np.sqrt(mg * mg + (Pc + tau * q) ** 2)
            step = (s + cc + ag * q * q) / (tau * (Pc + tau * q) / s + 2 * ag * q)
            q = np.where(np.abs(s) > 1e-6, q - step, q)
        s = np.sqrt(mg * mg + (Pc + tau * q) ** 2)
        nu = cc + ag * q * q
        ok = (np.abs(s + nu) <= 1e-9 * (np.abs(s) + np.abs(nu) + 1e-3)) & (np.abs(q) < 6.0)
    return np.where(ok, q * 1e3, np.nan)


def three_body_all(pp, E, mesons=("pi", "eta"), betas=(1, 2, 3, 4)):
    pts = [three_body(pp, E, MPHI[phi], beta, tau).ravel()
           for phi in mesons for beta in betas for tau in (-1, 1)]
    pts = np.concatenate(pts)
    return pts[~np.isnan(pts)]


def exchanged(pp, m):
    return np.concatenate([pp + 1j * m, pp - 1j * m, -pp + 1j * m, -pp - 1j * m])


def kernel_distances(V, E, n=2500):
    """Smallest distance from the path to the exchanged-meson and to the three-body points, p' on the path."""
    pp = sample(V, n)
    d_ex = min(path_dist_arr(V, exchanged(pp, m)).min() for m in MPHI.values())
    tb = three_body_all(pp, E)
    return d_ex, (path_dist_arr(V, tb).min() if tb.size else np.inf)


def min_re_Z(V, E, n=600):
    """Smallest Re Z = Re(s_pm + nu_beta) over sampled pairs of C x C, all mesons and orderings (S35)."""
    pp = sample(V, n)
    Pm, Qm = np.meshgrid(pp, pp, indexing="ij")
    best, where = np.inf, None
    for phi, m in MPHI.items():
        for beta, (t, h, a) in ORD.items():
            for tau in (1, -1):
                Z = np.sqrt(m * m + (Pm + tau * Qm) ** 2) + t + h * Pm * Pm + a * Qm * Qm - E
                i = np.argmin(Z.real)
                if Z.real.flat[i] < best:
                    best, where = Z.real.flat[i], (phi, beta, tau, Pm.flat[i], Qm.flat[i], abs(Z.flat[i]))
    return best, where


# Orderings beta that occur with the on-shell momentum in channel F, in the row form V(k_F, q): the blocks
# VV<-VV (2,2), VV<-PV (2,3), VV<-PP (3,3); PV<-PV (1,2), PV<-VV (2,4); PP<-VV (4,4) (note 07, S3). The column
# V(p', k_F) gives the same set after the h <-> a swap (beta 3 <-> 4), by time reversal.
ONSHELL_BETAS = {"VV": (2, 3), "PV": (1, 2, 4), "PP": (4,)}


def fixed_k_points(E):
    """Singular points of q -> V(k_F, q; E) at the flipped on-shell momenta (S32), pion exchange."""
    ex, tb = [], []
    for p in poles(E):
        if p["flipped"]:
            k = p["k"]
            ex += [k + 1j * MPHI["pi"], k - 1j * MPHI["pi"]]
            tb += list(three_body_all(np.array([k]), E, mesons=("pi",), betas=ONSHELL_BETAS[p["name"]]))
    return np.array(ex), np.array(tb)


def onshell_points(E):
    """The points of fixed_k_points, labelled: (channel, kind, side, z) with kind "ex" (k_F +- i m_pi, S33) or "tb"
    (three-body, S36) and side "up" or "down" by the nearer of k_F + i m_pi and k_F - i m_pi ("far" when
    -k_F +- i m_pi is nearer). Up points lie above [0, Lambda] on the physical sheet and may cross it during the
    continuation; down points start below the path and must stay below it (S32: the depth window at Re k_F)."""
    out = []
    for p in poles(E):
        if not p["flipped"]:
            continue
        k = p["k"]
        refs = {"up": k + 1j * MPHI["pi"], "down": k - 1j * MPHI["pi"],
                "far": -k + 1j * MPHI["pi"], "far2": -k - 1j * MPHI["pi"]}
        out += [(p["name"], "ex", "up", refs["up"]), (p["name"], "ex", "down", refs["down"])]
        for z in three_body_all(np.array([k]), E, mesons=("pi",), betas=ONSHELL_BETAS[p["name"]]):
            side = min(refs, key=lambda s: abs(z - refs[s]))
            out.append((p["name"], "tb", side if side in ("up", "down") else "far", complex(z)))
    return out


def sp_polygon(E):
    """Path through every flipped pole, sorted by Re k: 0 -> k_(1) -> ... -> Lambda (pole subtracted at each vertex).
    Flipped poles lie between [0, inf) and the slope-1 line and, at fixed E, on Re k |Im k| = mu Gamma / 2, so the
    slopes stay below 1 up to the small spread of mu_alpha."""
    fl = sorted((p["k"] for p in poles(E) if p["flipped"]), key=lambda z: z.real)
    return [0j] + fl + [complex(LAM, 0.0)]



def largest_dk(E):
    """Bisection on the margin argument of the builder; NaN where even 0.01 MeV is excluded."""
    if s40_path(E, 0.01) is None:
        return np.nan
    lo, hi = 0.01, 600.0
    for _ in range(40):
        mid = 0.5 * (lo + hi)
        lo, hi = (mid, hi) if s40_path(E, mid) is not None else (lo, mid)
    return lo
