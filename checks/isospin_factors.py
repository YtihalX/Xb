#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["sympy>=1.13"]
# ///
"""Exact charged-channel versus total-isospin OME flavour check.

Run: uv run --script checks/isospin_factors.py
Source convention: Zhang:2026iyr v1, Xb.tex:952-1010,1051,1116-1125.
This checks only flavour weights, not TOPT denominators or spin kernels.

Route 1 contracts the neutral/charged pion fields in the displayed Phi,
using its transposed heavy-meson flavour index and untransposed antimeson
index. Route 2 uses Clebsch--Gordan states and the total-isospin Casimir,
without constructing exchange from pion-field matrices. The SU(2)
pseudoreality map connects the two bases; eta is an identity coupling.
Axial spin/antiparticle and C-projection signs already belong to the
paper's spin kernels and are NOT multiplied into the flavour factor again.
"""
import sys

import sympy as sp
from sympy.physics.wigner import clebsch_gordan


def equal(actual, expected):
    """Exact symbolic equality for scalar or matrix expressions."""
    difference = actual - expected
    if isinstance(difference, sp.MatrixBase):
        return all(sp.simplify(entry) == 0 for entry in difference)
    return sp.simplify(difference) == 0


def main():
    failures = 0

    def check(label, actual, expected):
        nonlocal failures
        passed = equal(actual, expected)
        print(f"{'PASS' if passed else 'FAIL'} {label}")
        if not passed:
            failures += 1
            print(f"  actual: {actual}")
            print(f"  expected: {expected}")

    one = sp.eye(2)
    tau1 = sp.Matrix([[0, 1], [1, 0]])
    tau2 = sp.Matrix([[0, -sp.I], [sp.I, 0]])
    tau3 = sp.diag(1, -1)
    taus = (tau1, tau2, tau3)
    half = sp.Rational(1, 2)

    # Phi = pi0*z + pi+*plus + pi-*minus + eta*eta.
    # Only <pi0 pi0>, <pi+ pi-> and <pi- pi+> contract.
    z = sp.diag(1, -1)
    plus = sp.Matrix([[0, sp.sqrt(2)], [0, 0]])
    minus = sp.Matrix([[0, 0], [sp.sqrt(2), 0]])
    eta = one / sp.sqrt(3)
    neutral = sp.kronecker_product(z.T, z)
    charged = (sp.kronecker_product(plus.T, minus)
               + sp.kronecker_product(minus.T, plus))
    pion = neutral + charged
    eta_exchange = sp.kronecker_product(eta.T, eta)

    # Product basis: |B- B+>, |B- B0>, |Bbar0 B+>, |Bbar0 B0>.
    # Neutral charge subspace: n = |Bbar0 B0>, c = |B- B+>.
    n = sp.eye(4)[:, 3]
    c = sp.eye(4)[:, 0]
    embedding = sp.Matrix.hstack(n, c)
    pion_nc = embedding.T * pion * embedding
    eta_nc = embedding.T * eta_exchange * embedding
    check("neutral-pion charged/neutral matrix", embedding.T * neutral * embedding,
          sp.eye(2))
    check("charged-pion conversion has both sqrt(2) vertices",
          embedding.T * charged * embedding, sp.Matrix([[0, 2], [2, 0]]))
    check("full charged/neutral pion matrix", pion_nc, sp.Matrix([[1, 2], [2, 1]]))
    check("eta identity on all four flavour states", eta_exchange, sp.eye(4) / 3)
    check("eta neutral-charge matrix", eta_nc, sp.eye(2) / 3)

    # Heavy fields carry anti-light flavour, antimesons light flavour.
    # R=i*tau2 converts the former anti-doublet into an ordinary doublet.
    r = sp.I * tau2
    basis_map = sp.kronecker_product(r, one)
    check("pseudoreality basis map is unitary", basis_map * basis_map.H, sp.eye(4))
    for index, tau in enumerate(taus, start=1):
        check(f"physical anti-doublet generator {index}",
              r * (-tau.T / 2) * r.H, tau / 2)
        check(f"axial transposed flavour matrix {index}",
              r * tau.T * r.H, -tau)
    check("eta does not acquire the pion minus under pseudoreality",
          r * eta.T * r.H, eta)

    # Independent route: SU(2) addition in an ordinary doublet product.
    # No pion exchange matrix or charged-field coefficient enters this route.
    magnetic = (half, -half)

    def coupled_state(total, projection):
        return sp.Matrix([
            clebsch_gordan(half, half, total, m1, m2, projection)
            for m1 in magnetic for m2 in magnetic
        ])

    def pion_casimir(total):
        # -4 I1.I2 = -2 [I(I+1)-I1(I1+1)-I2(I2+1)].
        return -2 * (total * (total + 1) - 2 * half * (half + 1))

    isoscalar_nc = sp.Matrix([1, 1]) / sp.sqrt(2)
    isoscalar = embedding * isoscalar_nc
    check("charged-channel isoscalar maps to CG singlet", basis_map * isoscalar,
          coupled_state(0, 0))
    check("isoscalar pion eigenvalue from independent Casimir",
          pion * isoscalar, pion_casimir(0) * isoscalar)
    check("isoscalar pion weight", pion_casimir(0), sp.Integer(3))
    check("isoscalar eta eigenvalue", eta_exchange * isoscalar, isoscalar / 3)
    check("relative isoscalar pion/eta weight", pion_casimir(0) / sp.Rational(1, 3),
          sp.Integer(9))
    for projection in (-1, 0, 1):
        triplet = basis_map.H * coupled_state(1, projection)
        check(f"isovector M={projection} pion eigenvalue from Casimir",
              pion * triplet, pion_casimir(1) * triplet)
        check(f"isovector M={projection} eta identity", eta_exchange * triplet,
              triplet / 3)

    # C P = Pbar and C V = -Vbar; even L gives C=-swap(PV,VP).
    c_operator = sp.Matrix([[0, -1], [-1, 0]])
    c_even = sp.Matrix([1, -1]) / sp.sqrt(2)
    check("paper PV-minus-VP combination is C even", c_operator * c_even, c_even)
    check("C operator squares to identity", c_operator * c_operator, one)
    c_full = sp.kronecker_product(c_operator, sp.eye(4))
    pion_full = sp.kronecker_product(one, pion)
    eta_full = sp.kronecker_product(one, eta_exchange)
    state = sp.kronecker_product(c_even, isoscalar)
    check("C projection commutes with pion flavour contraction",
          c_full * pion_full - pion_full * c_full, sp.zeros(8))
    check("C-even isoscalar retains pion weight 3", pion_full * state, 3 * state)
    check("C-even isoscalar retains eta weight 1/3", eta_full * state, state / 3)

    print(f"{failures} failed assertion(s)")
    return int(failures != 0)


if __name__ == "__main__":
    sys.exit(main())
