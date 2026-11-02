# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1"]
# ///
"""All 21 independent 2++ OME entries from brute-force Eq. (80).

Route: literal Cartesian Baru:2019xnh v2 App. B projectors, canonical
Zhang:2026iyr v1 Eq. (68) vertices and Eqs. (72)-(77) TOPT propagators.
Both solid angles are integrated independently by the double-solid-angle helper;
no analytic coefficients, moments, or HQSS rotation are imported.
See literature/Baru:2019xnh/bridge.md for phases and normalisations.

Frozen before analytic derivation: seed 80402; three off-shell p',p and
absolute-M samples; orders 12 and 18; error AND quadrature change must each
be <= 5e-9 max(1, |V|), in GeV^-2. Pion and eta are separate comparisons.
The public six-channel OME supplies the package comparison.
Run: uv run --script checks/projection_2pp.py
"""
from pathlib import Path
import subprocess
import sys
import numpy as np
from _projection import project, sphere
from _projection_2pp import projectors_2pp, potential_2pp


# The public six-channel OME supplies the package comparison.
def package_values(points):
    point_text = '[' + ','.join(f'({r!r},{p!r},{offset!r})'
                              for r, p, offset in points) + ']'
    julia = '''using HadronDynamics
const B = HadronDynamics.BOchiEFT
cfg = B.Parameters()
channels = B.channels_2pp()
println("INPUT ", join((cfg.mB,cfg.mBstar,cfg.gb,cfg.fpi,cfg.mpi,cfg.meta), ","))
for (r,p,offset) in POINTS, (mass,weight) in ((cfg.mpi,3.0),(cfg.meta,1/3))
    # With both exchange masses equal, even legacy S-S selection gives
    # (3 + 1/3) V(mass). This isolates one meson through the public seam.
    single = B.Parameters(mpi=mass,meta=mass)
    model = B.OMEInteraction(single;channels=channels,exchange=:both,angular_method=:analytic)
    M = 2cfg.mBstar + offset
    for a in 1:6, b in a:6
        v = weight/(3+1/3) * B.ome_potential(model,a,b,r,p,M-2cfg.mBstar)
        println("VALUE ", real(v), ",", imag(v))
    end
end
'''.replace('POINTS', point_text)
    root = Path(__file__).resolve().parent.parent
    result = subprocess.run(
        ['julia', '--project=checks', '--startup-file=no', '-e', julia],
        cwd=root, text=True, capture_output=True)
    if result.returncode:
        print('FAIL package 2++ OME result unavailable: channels_2pp / OMEInteraction input',
              flush=True)
        print(result.stderr, file=sys.stderr, end='')
        raise SystemExit(1)
    constants = next(line for line in result.stdout.splitlines() if line.startswith('INPUT '))
    values = np.array([complex(*map(float, line[6:].split(',')))
                       for line in result.stdout.splitlines() if line.startswith('VALUE ')])
    return tuple(map(float, constants[6:].split(','))), values.reshape(len(points), 2, 21)


TOLERANCE = 5e-9
COARSE_ORDER, FINE_ORDER = 12, 18
rng = np.random.default_rng(80402)
points = [(float(rng.uniform(.035, .12)), float(rng.uniform(.035, .12)),
           float(rng.uniform(-.09, -.015))) for _ in range(3)]
(mb, mv, gb, fpi, mpi, meta), expected = package_values(points)
channels = projectors_2pp()
failed = False
# The source normalisation and orthogonality are checked separately from V.
n, weights = sphere(COARSE_ORDER)
projectors = [channel.projector(n) for channel in channels]
for a in range(6):
    for b in range(a, 6):
        if channels[a].species != channels[b].species:
            continue
        overlap = np.einsum('t,tam,tam->', weights,
                            projectors[a].conj(), projectors[b]) / 5
        target = 1 if a == b else 0
        ok = abs(overlap - target) <= 1e-12
        failed |= not ok
        print(f'{"PASS" if ok else "FAIL"} projector overlap ({a+1},{b+1}) '
              f'value={overlap.real:.12g}', flush=True)
for sample, (r, p, offset) in enumerate(points):
    total = 2 * mv + offset
    below_cut = total < 2 * mb + mpi
    failed |= not below_cut
    print(f'{"PASS" if below_cut else "FAIL"} sample={sample+1} '
          f'absolute_M={total:.12g} below BBpi threshold', flush=True)
    if not below_cut:
        continue
    for meson, (name, mass, weight) in enumerate((('pi', mpi, 3), ('eta', meta, 1/3))):
        potential = potential_2pp({'P': mb, 'V': mv}, gb, fpi, mass)
        coarse = weight * project(channels, potential, r, p, total, COARSE_ORDER, 2)
        fine = weight * project(channels, potential, r, p, total, FINE_ORDER, 2)
        entry = 0
        for a in range(6):
            for b in range(a, 6):
                analytic = expected[sample, meson, entry]
                tolerance = TOLERANCE * max(1, abs(analytic))
                error = abs(fine[a, b] - analytic)
                convergence = abs(fine[a, b] - coarse[a, b])
                ok = error <= tolerance and convergence <= tolerance
                failed |= not ok
                print(f'{"PASS" if ok else "FAIL"} {name} sample={sample+1} '
                      f'entry=({a+1},{b+1}) numerical={fine[a,b]:.12g} '
                      f'analytic={analytic:.12g} error={error:.3g} '
                      f'quadrature_delta={convergence:.3g}', flush=True)
                entry += 1
sys.exit(int(failed))
