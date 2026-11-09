# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1"]
# ///
"""Shared kinematics for notes/05-singularity-map.md: channels, thresholds, momenta, sheets, TOPT offsets.

Imported by the analysis and figure scripts in this folder (each runs with `uv run --script <file>`;
the script's folder is on sys.path). `uv run --script kinematics.py` prints a summary.

Units: GeV. Masses: GLOSSARY.md "Isospin limit" (package defaults,
code/HadronDynamics.jl/src/models/BOchiEFT/BOchiEFT.jl:45-47).
Energy origin and reduced masses: CONVENTIONS.md "Energy origin and on-shell momentum".
TOPT offsets nu_beta and time orderings: CONVENTIONS.md "Reduced masses and TOPT energy offsets";
notes/04-ome-2pp.md, Sec. 2 ([@Zhang:2026iyr] v1, Eq. (76) with M = M_th + E).
Sheet labels: CONVENTIONS.md "Pole position and Riemann sheets".
"""
from __future__ import annotations

from dataclasses import dataclass

import numpy as np

M_B = 5.27952
M_BSTAR = 5.32475
M_PI = 0.138039407
M_ETA = 0.548
DM = M_BSTAR - M_B
LAMBDA = 4.0  # sharp cutoff of the baseline fit (GLOSSARY.md "Sharp cutoff")
EXCHANGE_MASS = {"pi": M_PI, "eta": M_ETA}
HEAVY_MASS = {"P": M_B, "V": M_BSTAR}

# Strange mesons are not channels of the model; their masses only mark physical thresholds
# the model omits (package parameter strange_threshold, BOchiEFT.jl:47).
M_BS = 5.36692
M_BS_STAR = 5.4154


def reduced_mass(m1: float, m2: float) -> float:
    return m1 * m2 / (m1 + m2)


@dataclass(frozen=True)
class Channel:
    index: int  # 2++: CONVENTIONS.md "2++ channel basis and projectors"; 1++: [@Zhang:2026iyr] v1 basis
    label: str
    pair: str  # heavy-meson species of (meson, antimeson): "VV", "PV" or "PP"
    L: int  # orbital angular momentum
    delta: float  # threshold minus M_th
    mu: float  # reduced mass


@dataclass(frozen=True)
class Sector:
    name: str
    M_th: float  # energy origin: M = M_th + E
    channels: tuple[Channel, ...]
    # distinct two-body thresholds in increasing order: (label, representative channel index);
    # a sheet is the tuple of signs of Im k at these thresholds, in this order
    thresholds: tuple[tuple[str, int], ...]

    def channel(self, index: int) -> Channel:
        return next(c for c in self.channels if c.index == index)


_MU_PV = reduced_mass(M_B, M_BSTAR)

SECTOR_2PP = Sector(
    "2++",
    2 * M_BSTAR,
    (
        Channel(1, "B*B*(5S2)", "VV", 0, 0.0, M_BSTAR / 2),
        Channel(2, "B*B*(1D2)", "VV", 2, 0.0, M_BSTAR / 2),
        Channel(3, "B*B*(5D2)", "VV", 2, 0.0, M_BSTAR / 2),
        Channel(4, "B*B*(5G2)", "VV", 4, 0.0, M_BSTAR / 2),
        Channel(5, "BB*(3D2)", "PV", 2, -DM, _MU_PV),
        Channel(6, "BB(1D2)", "PP", 2, -2 * DM, M_B / 2),
    ),
    (("BB", 6), ("BB*", 5), ("B*B*", 1)),
)

SECTOR_1PP = Sector(
    "1++",
    M_B + M_BSTAR,
    (
        Channel(1, "BB*(3S1)", "PV", 0, 0.0, _MU_PV),
        Channel(2, "BB*(3D1)", "PV", 2, 0.0, _MU_PV),
        Channel(3, "B*B*(5D1)", "VV", 2, DM, M_BSTAR / 2),
    ),
    (("BB*", 1), ("B*B*", 3)),
)


def momentum(channel: Channel, E, sheet: int = +1):
    """On-shell momentum k, k^2 = 2 mu (E - delta), on one sheet of this channel's threshold.

    sheet=+1: Im k > 0; on the real axis above threshold the E+i0 value, k > 0.
    sheet=-1: Im k < 0; on the real axis above threshold the E-i0 value reached from the
    physical real axis, k > 0 (the two sheets are glued there). Below threshold +-i|k|.
    Accepts scalars or arrays.
    """
    k = np.sqrt(2 * channel.mu * (np.asarray(E, dtype=complex) - channel.delta))
    k_phys = np.where(k.imag < 0, -k, k)
    if sheet > 0:
        return k_phys
    on_rhc = (k_phys.imag == 0) & (k_phys.real > 0)
    return np.where(on_rhc, k_phys, -k_phys)


def energy(channel: Channel, k):
    """E (from M_th) at on-shell momentum k of this channel."""
    k = np.asarray(k, dtype=complex)
    return channel.delta + k**2 / (2 * channel.mu)


def momenta(sector: Sector, E, sheet: tuple[int, ...]):
    """{representative channel index: k} on the sheet given as signs in sector.thresholds order."""
    return {index: momentum(sector.channel(index), E, s) for (_, index), s in zip(sector.thresholds, sheet)}


def continued_momentum(plane: Channel, other: Channel, k):
    """Momentum of `other` as an analytic function of the on-shell momentum k of `plane`.

    k_other^2 = k0^2 + (mu_o/mu_p) k^2 with k0^2 = 2 mu_o (delta_p - delta_o), continued from k = 0,
    where k0 is real positive (other threshold lower) or +i|k0| (higher):
    k_other = k0 sqrt(1 + (mu_o/mu_p) k^2/k0^2) with the principal root. Its cuts lie on the axes of
    the k plane beyond the image of the other threshold, k = +-sqrt(-(mu_p/mu_o) k0^2). Near k = 0 the
    four quadrants of the k plane are then four sheets (sheet_of).
    """
    k = np.asarray(k, dtype=complex)
    ratio = other.mu / plane.mu
    k0_sq = 2 * other.mu * (plane.delta - other.delta)
    if k0_sq == 0:
        return np.sqrt(ratio) * k
    k0 = np.sqrt(complex(k0_sq)) if k0_sq > 0 else 1j * np.sqrt(-k0_sq)
    return k0 * np.sqrt(1 + ratio * k**2 / k0**2)


def sheet_of(sector: Sector, plane_index: int, k):
    """Sheet (signs of Im k_t, sector.thresholds order) at point k of the k plane of `plane_index`,
    the other momenta continued as in continued_momentum."""
    plane = sector.channel(plane_index)
    signs = []
    for _, index in sector.thresholds:
        other = sector.channel(index)
        k_t = np.asarray(k, dtype=complex) if other.delta == plane.delta else continued_momentum(plane, other, k)
        signs.append(np.where(np.imag(k_t) >= 0, 1, -1))
    return tuple(signs)


def threshold_images(sector: Sector, plane_index: int):
    """k of every distinct two-body threshold in the k plane of `plane_index` (the +k image)."""
    plane = sector.channel(plane_index)
    return {label: momentum(plane, sector.channel(index).delta) for label, index in sector.thresholds}


THREE_BODY_PAIRS = {"BB": 2 * M_B, "BB*": M_B + M_BSTAR, "B*B*": 2 * M_BSTAR}


def three_body_thresholds(sector: Sector):
    """{(pair, phi): E} of the TOPT intermediate states B^(*) Bbar^(*) phi, relative to M_th."""
    return {(pair, phi): mass + EXCHANGE_MASS[phi] - sector.M_th for pair, mass in THREE_BODY_PAIRS.items() for phi in EXCHANGE_MASS}


def nu(beta: int, p_out, p_in, E, sector: Sector = SECTOR_2PP):
    """TOPT offset nu_beta = intermediate heavy-pair energy - M, omega_H(p) = m_H + p^2/(2 m_H).

    beta = 1: B(p') Bbar(p); 2: B*(p) Bbar*(p'); 3: B(p) Bbar*(p'); 4: B(p') Bbar*(p), with
    p' = p_out, p = p_in (notes/04-ome-2pp.md, Sec. 2). Complex arguments allowed.
    """
    E = np.asarray(E, dtype=complex)
    p_out = np.asarray(p_out, dtype=complex)
    p_in = np.asarray(p_in, dtype=complex)
    if beta == 1:
        return 2 * M_B - sector.M_th + (p_in**2 + p_out**2) / (2 * M_B) - E
    if beta == 2:
        return 2 * M_BSTAR - sector.M_th + (p_in**2 + p_out**2) / (2 * M_BSTAR) - E
    if beta == 3:
        return M_B + M_BSTAR - sector.M_th + p_in**2 / (2 * M_B) + p_out**2 / (2 * M_BSTAR) - E
    if beta == 4:
        return M_B + M_BSTAR - sector.M_th + p_out**2 / (2 * M_B) + p_in**2 / (2 * M_BSTAR) - E
    raise ValueError(f"beta must be 1..4, got {beta}")


INTERMEDIATE = {1: "B Bbar phi", 2: "B* Bbar* phi", 3: "B Bbar* phi", 4: "B Bbar* phi"}

# (out pair, in pair) -> the two time orderings (beta1, beta2); notes/04-ome-2pp.md, Sec. 2 table.
# PP-PP, PP-PV and PV-PP have no one-meson exchange (no PP phi vertex).
ORDERINGS = {
    ("PV", "PV"): (1, 2),
    ("VV", "PV"): (2, 3),
    ("PV", "VV"): (2, 4),
    ("VV", "VV"): (2, 2),
    ("VV", "PP"): (3, 3),
    ("PP", "VV"): (4, 4),
}


def orderings(sector: Sector, out_index: int, in_index: int):
    """(beta1, beta2) of the transition in_index -> out_index, or None if no exchange."""
    return ORDERINGS.get((sector.channel(out_index).pair, sector.channel(in_index).pair))


def s_pm(m_phi, p_out, p_in, sign: int):
    """s_+- = sqrt(m_phi^2 + (p_out +- p_in)^2), principal root (CONVENTIONS.md "Continued angular moments")."""
    p_out = np.asarray(p_out, dtype=complex)
    p_in = np.asarray(p_in, dtype=complex)
    return np.sqrt(m_phi**2 + (p_out + sign * p_in) ** 2)


if __name__ == "__main__":
    s = SECTOR_2PP
    print(f"{s.name}: M_th = 2 m_B* = {s.M_th:.5f} GeV, Delta m = {1e3 * DM:.2f} MeV")
    for label, index in s.thresholds:
        c = s.channel(index)
        print(f"  two-body {label:5s} E = {1e3 * c.delta:8.2f} MeV  mu = {c.mu:.6f} GeV")
    for (pair, phi), E in sorted(three_body_thresholds(s).items(), key=lambda kv: kv[1]):
        print(f"  three-body {pair:5s}{phi:4s} E = {1e3 * E:8.2f} MeV")
    for _, index in s.thresholds:
        images = {label: np.round(k, 4) for label, k in threshold_images(s, index).items()}
        print(f"  k plane of channel {index}: threshold images {images}")
    print("  quadrant sheets (BB, BB*, B*B*):")
    for index in (1, 5, 6):
        quads = [tuple(int(x) for x in sheet_of(s, index, 0.05 * z)) for z in (1 + 1j, -1 + 1j, -1 - 1j, 1 - 1j)]
        print(f"    plane {index}: Q1..Q4 = {quads}")
    E = 0.013 - 0.004j
    for out, inc in ((1, 1), (5, 5), (1, 5), (5, 1), (1, 6), (6, 1)):
        b1, b2 = orderings(s, out, inc)
        k_out = momentum(s.channel(out), E)
        k_in = momentum(s.channel(inc), E)
        total = nu(b1, k_out, k_in, E) + nu(b2, k_out, k_in, E)
        print(f"  on-shell nu_{b1} + nu_{b2} for {inc}->{out}: {abs(total):.1e}")
