# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "sympy>=1.13"]
# ///
"""Slice 04: generated projected spin numerator, package and Eq. (80) seams.

Expectations frozen before the symbolic route: N_m=-5 c_m; factor 1/10;
no isospin weights in either single-meson comparison. Seed 80429.
Independent Cartesian projectors/vertices and double-sphere quadrature are
from _projection_2pp, not the symbolic helper. Package values are executed.
"""
from pathlib import Path
import subprocess
import sys
import numpy as np
from _projection import project
from _projection_2pp import projectors_2pp, potential_2pp

ROOT = Path(__file__).resolve().parent.parent
try:
    from _spin_numerator import entries, latex_table, p, r
except ImportError:
    print('FAIL generated table: symbolic helper does not exist')
    raise SystemExit(1)

rng = np.random.default_rng(80429)
points = [(float(rng.uniform(.035, .12)), float(rng.uniform(.035, .12)),
           float(rng.uniform(-.09, -.015))) for _ in range(3)]
rows = entries()
failed = False

def report(ok, name, detail=''):
    global failed
    failed |= not ok
    print(('PASS ' if ok else 'FAIL ') + name + detail, flush=True)

path = ROOT / 'paper/tables/projected-spin-numerator-2pp.tex'
report(path.exists() and path.read_bytes() == latex_table(rows).encode(),
       'generated table byte-for-byte')

julia = '''using HadronDynamics
B = HadronDynamics.BOchiEFT
cfg = B.Parameters(); channels = B.channels_2pp()
println("INPUT ", join((cfg.mB,cfg.mBstar,cfg.gb,cfg.fpi,cfg.mpi,cfg.meta), ","))
for (r,p,E) in POINTS, a in 1:6, b in a:6
    c = B.projection_coefficients(channels,a,b,r,p)
    pairs = B._ome_intermediates(channels[a].species,channels[b].species)
    labels = Dict((:P,:P)=>1,(:V,:V)=>2,(:V,:P)=>3,(:P,:V)=>4)
    println("ROW ",join(c,","),";",join((labels[pair] for pair in pairs),","))
end
'''.replace('POINTS', repr(points))
proc = subprocess.run(['julia', '--project=checks', '--startup-file=no', '-e', julia],
                      cwd=ROOT, text=True, capture_output=True)
if proc.returncode:
    report(False, 'package coefficients and offset pairs', ': ' + proc.stderr.strip())
    raise SystemExit(1)
lines = proc.stdout.splitlines()
mb, mv, gb, fpi, mpi, meta = map(float, next(v[6:] for v in lines if v.startswith('INPUT ')).split(','))
package = [v[4:].split(';') for v in lines if v.startswith('ROW ')]
worst = 0.; offsets_ok = True
for sample, (rr, pp, _) in enumerate(points):
    for index, (key, row) in enumerate(rows.items()):
        cs, pair = package[sample * 21 + index]
        expected = -5 * np.array(list(map(float, cs.split(','))))
        actual = np.array([float(c.subs({p: pp, r: rr})) for c in row['coefficients']])
        worst = max(worst, float(np.max(np.abs(actual-expected))))
        # D_beta1 + D_beta2 is unordered: the package enumerates VV first
        # for PV->VV, whereas the pinned diagram order is (3,2).
        offsets_ok &= sorted(map(int, pair.split(','))) == sorted(row['offsets']) if pair else row['offsets'] == ()
# Float64 evaluation only: 2e-13 absolute at momenta <= .12 GeV is generous
# relative to coefficient roundoff, but catches diagram signs/normalisations.
report(worst <= 2e-13 and offsets_ok, 'package coefficients and offset pairs',
       f' max_error={worst:.3g} offsets_match={offsets_ok}')

# Orders 12/18 reproduce the established Eq. (80) quadrature convergence;
# 64/96 nodes independently bound moment quadrature error. Both convergence
# and agreement must be <= 5e-9 max(1,|V|) GeV^-2, fixed before derivation.
def moments(order, rr, pp, total, mass, offsets):
    x, w = np.polynomial.legendre.leggauss(order)
    omega = np.sqrt(pp**2+rr**2-2*pp*rr*x+mass**2)
    nu = {1: 2*mb+(pp**2+rr**2)/(2*mb)-total,
          2: 2*mv+(pp**2+rr**2)/(2*mv)-total,
          3: mb+mv+rr**2/(2*mv)+pp**2/(2*mb)-total,
          4: mb+mv+rr**2/(2*mb)+pp**2/(2*mv)-total}
    d = sum((1/(2*omega*(omega+nu[b])) for b in offsets), np.zeros_like(x))
    return np.array([np.dot(w, x**m*d) for m in range(5)])

worst = convergence = 0.; valid = True
channels = projectors_2pp()
for rr, pp, energy in points:
    total = 2*mv+energy
    valid &= total < 2*mb+min(mpi,meta)
    for mass in (mpi, meta):
        potential = potential_2pp({'P': mb, 'V': mv}, gb, fpi, mass)
        coarse = project(channels, potential, rr, pp, total, 12, 2)
        fine = project(channels, potential, rr, pp, total, 18, 2)
        for (a,b), row in rows.items():
            c = np.array([float(v.subs({p:pp,r:rr})) for v in row['coefficients']])
            v = gb**2/(40*fpi**2)*np.dot(c,moments(96,rr,pp,total,mass,row['offsets']))
            vc = gb**2/(40*fpi**2)*np.dot(c,moments(64,rr,pp,total,mass,row['offsets']))
            scale = max(1,abs(v))
            worst = max(worst, abs(v-fine[a-1,b-1])/scale)
            convergence = max(convergence, abs(fine[a-1,b-1]-coarse[a-1,b-1])/scale, abs(v-vc)/scale)
report(valid and worst <= 5e-9 and convergence <= 5e-9,
       'angular moments versus double-solid-angle Eq. (80), pi and eta',
       f' max_scaled_error={worst:.3g} quadrature_delta={convergence:.3g} below_threshold={valid}')
sys.exit(int(failed))
