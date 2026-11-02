# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "sympy>=1.13"]
# ///
"""Strict-HQSS OME checked independently by Wigner 9j/6j.

Expectations and tolerances frozen before recoupling derivation:
* exact symbolic orthogonality and Bruschini:2023zkb v3 Table 2 comparison;
* fixed (s_H,J_light) block diagonality in the complete six-channel basis;
* identical J_light=1 S/D blocks in 2++ and canonical D1-phase 1++;
* numerical residual <= 2e-10 max(1, maxabs(V_2), maxabs(V_1)) GeV^-2.
No Cartesian projector or projected polynomial enters the rotation.
Run: uv run --script checks/hqss_2pp.py (Julia uses --project=checks).
"""
from pathlib import Path
import subprocess
import sys

import numpy as np
import sympy as sp
from sympy.physics.wigner import wigner_6j, wigner_9j

TOLERANCE = 2e-10
POINTS = ((.043, .117, -.031), (.139, .071, -.063), (.091, .091, -.019))
# Table 2, source labels gtable, rows (l,l')=(1,0),(1,2), in canonical order.
# These are PAPER phases; the bridge below supplies only independently fixed signs.
TABLE_1PP_PAPER = sp.Matrix([[1/sp.sqrt(3), 1/sp.sqrt(6), 1/sp.sqrt(2)]])
TABLE_2PP_PAPER = sp.Matrix([[-1/sp.sqrt(3), -1/sp.sqrt(30),
                            sp.sqrt(sp.Rational(7, 30)), 0,
                            sp.sqrt(sp.Rational(3, 10)), -1/sp.sqrt(10)]])

# Canonical ket = phase * Bruschini ket; derived in the pinned bridge.
# Do not fit these phases to a package matrix.
PHASE_1PP = sp.diag(1, 1, -1)
PHASE_2PP = sp.diag(1, 1, 1, 1, 1, -1)
PARTICLE_1PP = (('PV', 1, 0), ('PV', 1, 2), ('VV', 2, 2))
PARTICLE_2PP = (('VV', 2, 0), ('VV', 0, 2), ('VV', 2, 2),
                ('VV', 2, 4), ('PV', 1, 2), ('PP', 0, 2))
# Each row is (s_H,s_l,J_light,L); J_light here INCLUDES relative L.
HEAVY_1PP = ((1, 1, 1, 0), (1, 1, 1, 2), (1, 1, 2, 2))
HEAVY_2PP = ((1, 1, 1, 0), (1, 1, 1, 2), (1, 1, 2, 2),
             (1, 1, 3, 2), (1, 1, 3, 4), (0, 0, 2, 2))


def spin_overlap(j1, j2, spin, heavy, light):
    """Four spin-1/2's: ((h1,l1)j1,(h2,l2)j2)S -> ((h1,h2)h,(l1,l2)l)S."""
    half = sp.Rational(1, 2)
    return (sp.sqrt((2*j1+1)*(2*j2+1)*(2*heavy+1)*(2*light+1))
            * wigner_9j(half, half, j1, half, half, j2, heavy, light, spin))


def rotation(total, particles, heavy_basis, phases):
    """U[row,alpha]=<h,(s_l,L)J_light;J | alpha>; V_HQSS=U V U.T.

    Antimeson constituent order is (l2,h2), producing (-1)^(1-j2).
    Thus paper PP has -9j; its C-even PV minus becomes the sum of the
    (j1,j2)=(0,1),(1,0) 9j's. This is not the separate PP orbital rephase.
    First recouple ((h,l)S,L)J with a 6j; convert the physical (L,S)J
    ordering using (-1)^(L+S-J). No projector constructs any matrix entry.
    """
    rows = []
    for heavy, light, jlight, orbital in heavy_basis:
        row = []
        for species, spin, ell in particles:
            if ell != orbital:
                row.append(sp.S.Zero)
                continue
            if species == 'PV':
                overlap = (spin_overlap(0, 1, spin, heavy, light)
                           + spin_overlap(1, 0, spin, heavy, light))/sp.sqrt(2)
            elif species == 'PP':
                overlap = -spin_overlap(0, 0, spin, heavy, light)
            else:
                overlap = spin_overlap(1, 1, spin, heavy, light)
            sixj = (sp.Integer(-1)**(heavy+light+ell+total)
                    * sp.sqrt((2*spin+1)*(2*jlight+1))
                    * wigner_6j(heavy, light, spin, ell, total, jlight))
            order = sp.Integer(-1)**(ell+spin-total)
            row.append(sp.simplify(overlap*sixj*order))
        rows.append(row)
    return sp.simplify(sp.Matrix(rows)*phases)

# The public six-channel OME supplies the package comparison.
JULIA_INPUT = r'''using HadronDynamics
const B = HadronDynamics.BOchiEFT
physical = B.Parameters()
mbar = (physical.mB + 3physical.mBstar)/4
cfg = B.Parameters(mB=mbar, mBstar=mbar, muPV=mbar/2)
model2 = B.OMEInteraction(cfg; channels=B.channels_2pp())
model1 = B.OMEInteraction(cfg)
println("MASS ", join((cfg.mB,cfg.mBstar,cfg.muPV), ","))
for (r,p,E) in POINTS
    for (sector,model,n) in ((2,model2,6),(1,model1,3)), a in 1:n, b in 1:n
        v = B.ome_potential(model,a,b,r,p,E)
        println("VALUE ", sector, ",", a, ",", b, ",", real(v), ",", imag(v))
    end
end
'''
# --- end input seam ---


def package_input():
    point_text = '[' + ','.join(f'({r!r},{p!r},{e!r})' for r, p, e in POINTS) + ']'
    result = subprocess.run(
        ['julia', '--project=checks', '--startup-file=no', '-e',
         JULIA_INPUT.replace('POINTS', point_text)],
        cwd=Path(__file__).resolve().parent.parent, text=True, capture_output=True)
    if result.returncode:
        print('FAIL public 2++ OME input (channels_2pp must exist)', flush=True)
        print(result.stderr.strip(), file=sys.stderr)
        raise SystemExit(1)
    return result.stdout.splitlines()


def main():
    # Fetch first: no self-test can mask absence of the required public API.
    lines = package_input()
    failed = False

    def report(name, ok, detail=''):
        nonlocal failed
        failed |= not ok
        print(f'{"PASS" if ok else "FAIL"} {name} {detail}'.rstrip(), flush=True)

    u1 = rotation(1, PARTICLE_1PP, HEAVY_1PP, PHASE_1PP)
    u2 = rotation(2, PARTICLE_2PP, HEAVY_2PP, PHASE_2PP)
    for name, matrix in (('1++', u1), ('2++', u2)):
        report(f'{name} exact Wigner orthogonality',
               sp.simplify(matrix*matrix.T) == sp.eye(matrix.rows))
    # Table 2 is the longitudinal string-breaking row, NOT one pure-L ket.
    # The L=2 coefficient has opposite sign at total J=1 and J=2.
    table1 = u1[0, :]/sp.sqrt(3) - sp.sqrt(sp.Rational(2, 3))*u1[1, :]
    table2 = -u2[0, :]/sp.sqrt(3) + sp.sqrt(sp.Rational(2, 3))*u2[1, :]
    report('1++ J_light=1 longitudinal row vs bridged Table 2',
           sp.simplify(table1 - TABLE_1PP_PAPER*PHASE_1PP) == sp.zeros(1, 3))
    report('2++ J_light=1 longitudinal row vs bridged Table 2',
           sp.simplify(table2 - TABLE_2PP_PAPER*PHASE_2PP) == sp.zeros(1, 6))

    masses = [line[5:] for line in lines if line.startswith('MASS ')]
    values = [line[6:] for line in lines if line.startswith('VALUE ')]
    expected_count = len(POINTS)*(6**2 + 3**2)
    complete = len(masses) == 1 and len(values) == expected_count
    report('public OME input completeness', complete)
    if not complete:
        return 1
    mb, mv, mu = map(float, masses[0].split(','))
    mbar = (5.27952 + 3*5.32475)/4
    report('strict HQSS masses and reduced mass',
           max(abs(mb-mbar), abs(mv-mbar), abs(mu-mbar/2)) <= 1e-14)
    numeric1 = np.array(u1, dtype=float)
    numeric2 = np.array(u2, dtype=float)
    keys = [(h, j) for h, light, j, ell in HEAVY_2PP]
    forbidden = np.array([[left != right for right in keys] for left in keys])
    cursor = 0
    for sample, (pout, pin, energy) in enumerate(POINTS, 1):
        matrices = []
        for sector, size in ((2, 6), (1, 3)):
            matrix = np.empty((size, size), dtype=complex)
            for a in range(size):
                for b in range(size):
                    actual_sector, out, incoming, real, imag = values[cursor].split(',')
                    if (int(actual_sector), int(out), int(incoming)) != (sector, a+1, b+1):
                        report('public OME channel ordering', False)
                        return 1
                    matrix[a, b] = complex(float(real), float(imag))
                    cursor += 1
            matrices.append(matrix)
        v2, v1 = matrices
        scale = max(1.0, float(np.max(np.abs(v2))), float(np.max(np.abs(v1))))
        tolerance = TOLERANCE*scale
        transformed2 = numeric2 @ v2 @ numeric2.T
        transformed1 = numeric1 @ v1 @ numeric1.T
        residual = float(np.max(np.abs(transformed2[forbidden])))
        report(f'sample={sample} complete 2++ fixed (s_H,J_light) blocks',
               residual <= tolerance,
               f'max_forbidden={residual:.3g} tolerance={tolerance:.3g} GeV^-2')
        residual1 = float(np.max(np.abs(transformed1[:2, 2])))
        residual1 = max(residual1, float(np.max(np.abs(transformed1[2, :2]))))
        report(f'sample={sample} 1++ J_light=1 decouples',
               residual1 <= tolerance,
               f'max_forbidden={residual1:.3g} tolerance={tolerance:.3g} GeV^-2')
        shared = float(np.max(np.abs(transformed2[:2, :2]-transformed1[:2, :2])))
        report(f'sample={sample} 2++ and 1++ J_light=1 S/D blocks identical',
               shared <= tolerance,
               f'max_difference={shared:.3g} tolerance={tolerance:.3g} GeV^-2')
    return int(failed)


if __name__ == '__main__':
    sys.exit(main())
