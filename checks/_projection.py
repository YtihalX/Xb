"""Independent Eq. (80) double-solid-angle quadrature (Zhang:2026iyr v1).

Channel projectors are data: arrays [direction, spin state, J polarisation].
A potential callback receives q[t,s,3], outgoing/incoming species, p', p,
and total energy, and returns V[t,s,out-spin,in-spin]. No partial-wave
coefficients or package moment functions enter this route. Slice 04 can
supply six channels and its species-changing 3D potentials unchanged here.
"""
from dataclasses import dataclass
import numpy as np


@dataclass(frozen=True)
class Channel:
    species: tuple[str, str]
    projector: object


def sphere(order):
    """Product Gauss-Legendre/trapezoidal rule, weights sum to one."""
    z, w = np.polynomial.legendre.leggauss(order)
    phi = 2 * np.pi * np.arange(2 * order) / (2 * order)
    radial = np.sqrt(1 - z[:, None] ** 2)
    n = np.stack(np.broadcast_arrays(radial * np.cos(phi),
                                     radial * np.sin(phi), z[:, None]), axis=-1)
    return n.reshape(-1, 3), np.repeat(w / (4 * order), 2 * order)


def topt_offset(m_out, p_out, m_in, p_in, total_energy):
    """Intermediate pair energies, not external-channel reduced masses.

    Select the two intermediate species at the vertices; this also covers
    PP <-> VV (same offset in both time orderings). Energy is absolute.
    """
    return (m_out + p_out**2 / (2 * m_out)
            + m_in + p_in**2 / (2 * m_in) - total_energy)


def propagator(q, mass, offset):
    omega = np.sqrt(np.einsum('...i,...i->...', q, q) + mass**2)
    return 1 / (2 * omega * (omega + offset))


def project(channels, potential, pout, pin, total_energy, order, j, chunk=24):
    """Integrate both solid angles explicitly, without fixing either axis."""
    n, weights = sphere(order)
    projectors = [channel.projector(n) for channel in channels]
    result = np.zeros((len(channels), len(channels)), dtype=complex)
    for start in range(0, len(n), chunk):
        stop = start + chunk
        outgoing = n[start:stop]
        q = pin * n[None, :, :] - pout * outgoing[:, None, :]
        w = weights[start:stop, None] * weights[None, :] / (2 * j + 1)
        # Cache species blocks inside the callback, if several channels share them.
        blocks = {}
        for a, out in enumerate(channels):
            for b, incoming in enumerate(channels):
                key = (out.species, incoming.species)
                if key not in blocks:
                    blocks[key] = potential(q, *key, pout, pin, total_energy)
                integrand = np.einsum('tam,tsab,sbm->ts',
                                      projectors[a][start:stop].conj(),
                                      blocks[key], projectors[b], optimize=True)
                result[a, b] += np.sum(w * integrand)
    return result


EPSILON = np.zeros((3, 3, 3))
EPSILON[0, 1, 2] = EPSILON[1, 2, 0] = EPSILON[2, 0, 1] = 1
EPSILON[0, 2, 1] = EPSILON[2, 1, 0] = EPSILON[1, 0, 2] = -1


def projectors_1pp(sign):
    """Eq. (D1), including its imaginary VV phase and traceless tensor."""
    def s(n):
        return np.broadcast_to(np.eye(3), (len(n), 3, 3))

    def d(n):
        return -3 / np.sqrt(2) * (np.einsum('ta,tb->tab', n, n) - np.eye(3) / 3)

    def vv(n):
        tensor = np.einsum('ta,tb->tab', n, n) - np.eye(3) / 3
        value = -sign * np.sqrt(3) / 2 * 1j * (
            np.einsum('iak,tkb->tabi', EPSILON, tensor)
            + np.einsum('ibk,tka->tabi', EPSILON, tensor))
        return value.reshape(len(n), 9, 3)

    return [Channel(('P', 'V'), s), Channel(('P', 'V'), d),
            Channel(('V', 'V'), vv)]


def potential_1pp(masses, gb, fpi, meson_mass):
    """Cartesian spin matrices from Eqs. (72)-(75), not App. D polynomials."""
    prefactor = gb**2 / (4 * fpi**2)

    def potential(q, out, incoming, pout, pin, total):
        pp = propagator(q, meson_mass, topt_offset(masses['P'], pout, masses['P'], pin, total))
        vv = propagator(q, meson_mass, topt_offset(masses['V'], pout, masses['V'], pin, total))
        # R[a,c] = epsilon[c,a,k] q[k]: A = i R / sqrt(2).
        r = np.einsum('cak,...k->...ac', EPSILON, q)
        if out == incoming == ('P', 'V'):
            return -prefactor * np.einsum('...a,...b->...ab', q, q) * (pp + vv)[..., None, None]
        if out == incoming == ('V', 'V'):
            value = prefactor * np.einsum('...ac,...bd->...abcd', r, r)
            return value.reshape(*q.shape[:-1], 9, 9) * (2 * vv)[..., None, None]
        # C-even PV contains both possible vector meson lines.
        value = prefactor * 1j / np.sqrt(2) * (
            np.einsum('...ac,...b->...abc', r, q)
            + np.einsum('...bc,...a->...abc', r, q))
        if out == ('V', 'V'):
            mixed = propagator(q, meson_mass, topt_offset(masses['V'], pout, masses['P'], pin, total))
            return value.reshape(*q.shape[:-1], 9, 3) * (vv + mixed)[..., None, None]
        mixed = propagator(q, meson_mass, topt_offset(masses['P'], pout, masses['V'], pin, total))
        return value.reshape(*q.shape[:-1], 9, 3).conj().swapaxes(-1, -2) * (vv + mixed)[..., None, None]

    return potential
