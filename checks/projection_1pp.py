# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1"]
# ///
"""Slice 03: Eq. (80) with 3D spin matrices and D1 projectors vs analytic kernel.

Pinned source: Zhang:2026iyr v1 Eqs. (72)-(80), (D1). The two full solid
angles are integrated independently, not replaced by App. D polynomials.
π and η are compared separately with isospin weights 3 and 1/3. We call
BOchiEFT.tc_vphi directly: OMEInteraction(exchange=:pion|:eta) leaves both
mesons in S-S, so that selector is NOT a per-meson comparison.
Tolerance fixed before derivation: |difference| <= 5e-9 max(1, |V|), with
independent order-12 vs order-18 double-sphere convergence at that precision.
The result input is D1's VV projector sign, filled after the worked note.
"""
from pathlib import Path
import subprocess
import sys
import numpy as np
from _projection import project, projectors_1pp, potential_1pp

# --- input: filled by the guarded derivation ---
PROJECTOR_SIGN = +1
# --- end input ---
if PROJECTOR_SIGN is None:
    sys.exit("FAIL no worked projection result yet: D1 phase input is missing")

# --flip-5d1 is the deliberate broken-result run; never changes expectations.
sign = -PROJECTOR_SIGN if '--flip-5d1' in sys.argv else PROJECTOR_SIGN
rng = np.random.default_rng(80301)
points = [(float(rng.uniform(.035, .15)), float(rng.uniform(.035, .15)),
           float(rng.uniform(-.09, -.015))) for _ in range(3)]
# Julia emits constants and analytic per-meson entries without importing any
# quadrature/projector code from this independent route.
point_text = '[' + ','.join(f'({r!r},{p!r},{e!r})' for r, p, e in points) + ']'
julia = '''using HadronDynamics
const B = HadronDynamics.BOchiEFT
cfg = B.Parameters()
model = B.OMEInteraction(cfg)
println("INPUT ", join((cfg.mB,cfg.mBstar,cfg.gb,cfg.fpi,cfg.mpi,cfg.meta), ","))
for (r,p,E) in POINTS, (m,w) in ((cfg.mpi,3.0),(cfg.meta,1/3)), a in 1:3, b in 1:3
    v = w * B.tc_vphi(model,a,b,r,p,E,m;method=:analytic)
    println("VALUE ", real(v), ",", imag(v))
end
'''.replace('POINTS', point_text)
root = Path(__file__).resolve().parent.parent
result = subprocess.run(['julia', '--project=checks', '--startup-file=no', '-e', julia],
                        cwd=root, text=True, capture_output=True, check=True)
constants = next(line for line in result.stdout.splitlines() if line.startswith('INPUT '))
mb, mv, gb, fpi, mpi, meta = map(float, constants[6:].split(','))
expected = np.array([complex(*map(float, line[6:].split(',')))
                     for line in result.stdout.splitlines() if line.startswith('VALUE ')])
expected = expected.reshape(len(points), 2, 3, 3)
channels = projectors_1pp(sign)
failed = False
for sample, (r, p, energy) in enumerate(points):
    # Below even the lowest three-body threshold, BBπ: E < mπ - Δm.
    assert energy < mpi - (mv - mb)
    for meson, (name, mass, weight) in enumerate((('pi', mpi, 3), ('eta', meta, 1/3))):
        potential = potential_1pp({'P': mb, 'V': mv}, gb, fpi, mass)
        coarse = weight * project(channels, potential, r, p, mb + mv + energy, 12, 1)
        fine = weight * project(channels, potential, r, p, mb + mv + energy, 18, 1)
        for a in range(3):
            for b in range(3):
                analytic = expected[sample, meson, a, b]
                tolerance = 5e-9 * max(1, abs(analytic))
                error = abs(fine[a, b] - analytic)
                convergence = abs(fine[a, b] - coarse[a, b])
                ok = error <= tolerance and convergence <= tolerance
                failed |= not ok
                print(f'{"PASS" if ok else "FAIL"} {name} sample={sample+1} '
                      f'entry=({a+1},{b+1}) numerical={fine[a,b].real:.12g} '
                      f'analytic={analytic.real:.12g} error={error:.3g} '
                      f'quadrature_delta={convergence:.3g}', flush=True)
sys.exit(int(failed))
