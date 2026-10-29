"""Pinned Baru:2019xnh v2 App. B tensors and canonical Cartesian vertices.

No analytic partial-wave coefficients, angular moments, or HQSS rotations enter.
The generic double-sphere integrator remains in _projection.py unchanged.
"""
import numpy as np
from _projection import Channel, EPSILON, potential_1pp, propagator, topt_offset


def spin_two_basis():
    """Real orthonormal symmetric-traceless Cartesian total-J polarisations."""
    basis = np.zeros((5, 3, 3))
    basis[0] = np.diag([1, -1, 0]) / np.sqrt(2)
    basis[1] = np.diag([-1, -1, 2]) / np.sqrt(6)
    for index, (a, b) in enumerate(((0, 1), (0, 2), (1, 2)), 2):
        basis[index, a, b] = basis[index, b, a] = 1 / np.sqrt(2)
    return basis


def projectors_2pp():
    """Canonical order, literal App. B signs; PV denotes canonical C-even PV.

    Contract the two total-J tensor indices with five orthonormal tensors;
    this is exactly the spin-2 trace in Eq. (80), not an extra normalisation.
    """
    eye = np.eye(3)
    polarisation = spin_two_basis()
    # S[ab,ij] = delta_ai delta_bj + delta_aj delta_bi - 2 delta_ab delta_ij/3.
    spin = (np.einsum('ai,bj->abij', eye, eye)
            + np.einsum('aj,bi->abij', eye, eye)
            - 2 / 3 * np.einsum('ab,ij->abij', eye, eye))

    def tensors(n):
        return np.einsum('ti,tj->tij', n, n) - eye / 3

    def ss(n):
        value = np.einsum('abij,mij->abm', spin / 2, polarisation)
        return np.broadcast_to(value.reshape(1, 9, 5), (len(n), 9, 5))

    def singlet_d(n):
        value = -np.sqrt(5 / 2) * np.einsum(
            'ab,tij,mij->tabm', eye, tensors(n), polarisation)
        return value.reshape(len(n), 9, 5)

    def quintet_d(n):
        v = tensors(n)
        value = (np.einsum('abik,tkj->tabij', spin, v)
                 + np.einsum('abjk,tki->tabij', spin, v)
                 - 2 / 3 * np.einsum('ij,abkl,tkl->tabij', eye, spin, v))
        value = -np.sqrt(45 / 56) * np.einsum('tabij,mij->tabm', value, polarisation)
        return value.reshape(len(n), 9, 5)

    def quintet_g(n):
        value = np.einsum('ti,tj,tk,tl->tijkl', n, n, n, n)
        value -= (np.einsum('ti,tj,kl->tijkl', n, n, eye)
                  + np.einsum('ti,tk,jl->tijkl', n, n, eye)
                  + np.einsum('ti,tl,jk->tijkl', n, n, eye)
                  + np.einsum('tj,tk,il->tijkl', n, n, eye)
                  + np.einsum('tj,tl,ik->tijkl', n, n, eye)
                  + np.einsum('tk,tl,ij->tijkl', n, n, eye)) / 7
        value += (np.einsum('ij,kl->ijkl', eye, eye)
                  + np.einsum('ik,jl->ijkl', eye, eye)
                  + np.einsum('il,jk->ijkl', eye, eye)) / 35
        value = np.sqrt(175 / 32) * np.einsum(
            'abkl,tijkl,mij->tabm', spin, value, polarisation)
        return value.reshape(len(n), 9, 5)

    def pv_d(n):
        v = tensors(n)
        value = -0.5j * np.sqrt(5) * (
            np.einsum('ikl,tlj->tkij', EPSILON, v)
            + np.einsum('jkl,tli->tkij', EPSILON, v))
        return np.einsum('tkij,mij->tkm', value, polarisation)

    def pp_d(n):
        value = -np.sqrt(15 / 2) * np.einsum('tij,mij->tm', tensors(n), polarisation)
        return value[:, None, :]

    return [Channel(('V', 'V'), ss), Channel(('V', 'V'), singlet_d),
            Channel(('V', 'V'), quintet_d), Channel(('V', 'V'), quintet_g),
            Channel(('P', 'V'), pv_d), Channel(('P', 'P'), pp_d)]


def potential_2pp(masses, gb, fpi, meson_mass):
    """Canonical Eq. (68) vertices, with every allowed species transition.

    Existing PV/VV Cartesian blocks are Eqs. (72)-(75), not projected kernels.
    PP-VV adds +g_b^2 q_a q_b/(4 F_pi^2); both time orderings have the same
    mixed intermediate pair. There is no PP-PP or PP-PV one-boson exchange.
    """
    pv_vv = potential_1pp(masses, gb, fpi, meson_mass)
    prefactor = gb**2 / (4 * fpi**2)
    pp = ('P', 'P')
    vv = ('V', 'V')

    def potential(q, out, incoming, pout, pin, total):
        if pp not in (out, incoming):
            return pv_vv(q, out, incoming, pout, pin, total)
        if {out, incoming} != {pp, vv}:
            nout = 1 if out == pp else 3
            nin = 1 if incoming == pp else 3
            return np.zeros((*q.shape[:-1], nout, nin))
        offset = topt_offset(masses[out[0]], pout, masses[incoming[0]], pin, total)
        denominator = 2 * propagator(q, meson_mass, offset)
        value = prefactor * np.einsum('...a,...b->...ab', q, q)
        value = value.reshape(*q.shape[:-1], 9) * denominator[..., None]
        return value[..., :, None] if out == vv else value[..., None, :]

    return potential
