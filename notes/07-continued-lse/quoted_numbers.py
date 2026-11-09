# /// script
# dependencies = ["mpmath>=1.3"]
# ///
"""Every computed number quoted in notes/07-continued-lse.tex.

Run: uv run --script notes/07-continued-lse/quoted_numbers.py

These are evaluations of the note's own formulas (a derivation aid), not checks:
nothing here is an independent route. Units: MeV.
"""
import mpmath as mp

mp.mp.dps = 30

# Isospin-limit masses (GLOSSARY.md, "Isospin limit").
mB = mp.mpf("5279.52")  # b in notes/05
mV = mp.mpf("5324.75")  # v
dm = mV - mB  # d
S = mB + mV
MPHI = {"pi": mp.mpf("138.039"), "eta": mp.mpf("548")}

# Channels: threshold delta (from 2 m_B*), 2 mu.
CH = {
    "VV": (mp.mpf(0), mV),  # 2 mu_1 = m_B*
    "PV": (-dm, 2 * mB * mV / S),
    "PP": (-2 * dm, mB),  # 2 mu_6 = m_B
}


def k(ch, E):
    """Principal root of k^2 = 2 mu (E - delta): the physical-sheet momentum for real E.

    For Im E < 0 it is the fourth-quadrant root of the pair: the flipped +k (channel open at
    Re E, reached through the real axis above threshold) or the unflipped -k.
    """
    delta, two_mu = CH[ch]
    return mp.sqrt(two_mu * (E - delta))


def f(x, n=6):
    return mp.nstr(x, n)


print("== channels")
for ch, (delta, two_mu) in CH.items():
    print(f"{ch}: delta = {f(delta)}  mu = {f(two_mu / 2)}")

# TOPT offsets nu_beta(p', q; E) = t_beta + h_beta p'^2 + a_beta q^2 - E,
# q the incoming (loop) momentum, p' the outgoing one (notes/04-ome-2pp.md, Sec. 2).
ORD = {
    1: (-2 * dm, 1 / (2 * mB), 1 / (2 * mB)),  # B(p') Bbar(q)
    2: (mp.mpf(0), 1 / (2 * mV), 1 / (2 * mV)),  # B*(.) Bbar*(.)
    3: (-dm, 1 / (2 * mV), 1 / (2 * mB)),  # B(q) Bbar*(p')
    4: (-dm, 1 / (2 * mB), 1 / (2 * mV)),  # B(p') Bbar*(q)
}

print("\n== three-body thresholds E_3,beta = m_phi + t_beta")
for phi, m in MPHI.items():
    print(phi, "  ".join(f"beta={b}: {f(m + t)}" for b, (t, h, a) in ORD.items()))

print("\n== three-body branch points at p' = 0: sqrt(m^2+q^2) + t + a q^2 - E = 0")
for phi in ("pi",):
    m = MPHI[phi]
    for E in (mp.mpf("-22.62"), mp.mpf(0)):
        for b, (t, h, a) in ORD.items():
            c = t - E
            # a^2 T^2 + (2ac-1) T + c^2 - m^2 = 0, T = q^2; near root by (P18) of notes/05
            T = 2 * (c**2 - m**2) / (1 - 2 * a * c + mp.sqrt(1 - 4 * a * c + 4 * a**2 * m**2))
            s = mp.sqrt(m**2 + T)  # principal: the continued branch on graph paths
            nu = c + a * T
            genuine = abs(s + nu) < abs(s - nu)
            q = mp.sqrt(T)
            print(
                f"{phi} E={f(E)} beta={b}: q = +-{f(q)}  s+nu = {f(s + nu, 3)}  s-nu = {f(s - nu, 3)}"
                f"  -> {'genuine' if genuine else 'spurious (s = +nu)'}"
            )

print("\n== on-shell endpoint candidates F(E) = (U+W+m^2-nu^2)^2 - 4UW = 0")
# U = p'^2 (out), W = p^2 (in), nu_on; history/05-singularity-map.md (P5), inputs re-derived in 07.
BLOCKS = {
    "VV<-VV": (lambda E: mV * E, lambda E: mV * E, lambda E: 0 * E, ("VV", "VV")),
    "PV<-PV": (
        lambda E: 2 * mB * mV * (E + dm) / S,
        lambda E: 2 * mB * mV * (E + dm) / S,
        lambda E: dm * (E - 2 * mB) / S,
        ("PV", "PV"),
    ),
    "VV<-PV": (
        lambda E: mV * E,
        lambda E: 2 * mB * mV * (E + dm) / S,
        lambda E: dm * (2 * mB - E) / (2 * S),
        ("VV", "PV"),
    ),
    "VV<-PP": (lambda E: mV * E, lambda E: mB * (E + 2 * dm), lambda E: 0 * E, ("VV", "PP")),
}


def poly_coeffs(fun, deg):
    """Exact polynomial coefficients of fun(E) (degree <= deg) by interpolation."""
    xs = [mp.mpf(i) for i in range(deg + 1)]
    ys = [fun(x) for x in xs]
    # solve Vandermonde
    Vm = mp.matrix([[x**j for j in range(deg + 1)] for x in xs])
    c = mp.lu_solve(Vm, mp.matrix(ys))
    return [c[j] for j in range(deg + 1)]  # ascending


for name, (U, W, nu, (cout, cin)) in BLOCKS.items():
    for phi, m in MPHI.items():
        F = lambda E: (U(E) + W(E) + m**2 - nu(E) ** 2) ** 2 - 4 * U(E) * W(E)
        c = poly_coeffs(F, 4)
        while abs(c[-1]) < mp.mpf(10) ** (-20) * max(abs(x) for x in c):
            c.pop()
        roots = mp.polyroots(list(reversed(c)), maxsteps=200, extraprec=200)
        for r in roots:
            if abs(r) > 2000:
                continue
            r = mp.re(r) if abs(mp.im(r)) < 1e-12 else r
            pin, pout = k(cin, r), k(cout, r)
            A_on = pout**2 + pin**2 + m**2 - nu(r) ** 2
            Hp = A_on - 2 * pout * pin  # endpoint x = +1
            Hm = A_on + 2 * pout * pin  # endpoint x = -1
            end = "x=+1" if abs(Hp) < abs(Hm) else "x=-1"
            print(
                f"{name} {phi}: E_L = {f(r, 7)}  ({end} with physical-sheet momenta)"
                f"  k_1 = {f(k('VV', r))}  k_5 = {f(k('PV', r))}  k_6 = {f(k('PP', r))}"
            )

print("\n== fourth-quadrant pole of each channel at Im E = -10 MeV, vertical energy path")
for ReE in (mp.mpf("-67.85"), mp.mpf("-22.62")):
    E = mp.mpc(ReE, -10)
    for ch in ("VV", "PV", "PP"):
        flipped = CH[ch][0] < ReE
        side = "+k, flipped: between [0,Lambda] and C" if flipped else "-k, unflipped: outside"
        print(f"E = {f(ReE)}-10i  {ch}: {f(k(ch, E))}  ({side})")
for ch in ("PV", "PP"):
    two_mu = CH[ch][1]
    print(f"flipped pole at its threshold, {ch}: -Im k = Re k = sqrt(mu |Im E|) = {f(mp.sqrt(two_mu / 2 * 10))}")

print("\n== width at which |Im k_5| reaches a depth, Re E = -22.62 on (-,-,+)")
two_mu5 = CH["PV"][1]
for depth in (mp.mpf(119), mp.mpf("130"), MPHI["pi"]):
    # k = a - i depth with k^2 = 2mu(E - delta): Re k^2 = a^2 - depth^2 = 2mu(ReE - delta)
    re_k2 = two_mu5 * (mp.mpf("-22.62") + dm)
    a = mp.sqrt(re_k2 + depth**2)
    im_E = -2 * a * depth / two_mu5
    print(f"|Im k_5| = {f(depth)}: k_5 = {f(a)} - {f(depth)} i at Gamma = {f(-2 * im_E, 4)}")
