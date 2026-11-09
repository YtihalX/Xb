# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "sympy>=1.13", "mpmath>=1.3"]
# ///
"""Exact endpoint polynomials and path-continued on-shell OME moments.

All internal units are GeV. No LSE solution or pole position is assumed.
The logarithm tracker follows A+B and A-B separately from E=+30 MeV;
the two-body square roots are also unwrapped along the path. Half-plane
doglegs define boundary values; loops around thresholds reach adjacent
sheets without resetting the logarithm windings.
"""
from __future__ import annotations

import json
from pathlib import Path
import numpy as np
import sympy as sp
from kinematics import (SECTOR_2PP, SECTOR_1PP, M_B, M_BSTAR, EXCHANGE_MASS,
                        momentum, nu, orderings, continued_momentum, energy)

HERE = Path(__file__).resolve().parent
TRANSITIONS = [(1, 1, "VV–VV"), (5, 5, "PV–PV"), (1, 5, "VV–PV"), (1, 6, "VV–PP")]
COLORS = {"VV–VV": "#0072B2", "PV–PV": "#009E73", "VV–PV": "#D55E00", "VV–PP": "#CC79A7"}
E_SYMBOL = sp.Symbol("E")


def rat(value):
    return sp.Rational(str(value))


def symbolic(out, inc, meson, sector=SECTOR_2PP):
    """Rational polynomial before any numerical root finding (decimal masses exact)."""
    # Build reduced masses from the decimal heavy masses, not rounded float mu.
    b, v = rat(M_B), rat(M_BSTAR)
    masses = {"PP": (b, b), "PV": (b, v), "VV": (v, v)}
    origin = 2*v if sector.name == "2++" else b+v
    def squared(index):
        c = sector.channel(index)
        m1, m2 = masses[c.pair]
        mu = m1*m2/(m1+m2)
        return 2*mu*(E_SYMBOL-(m1+m2-origin))
    u, w = squared(out), squared(inc)
    beta = orderings(sector, out, inc)[0]
    n = {1: 2*b-origin+(u+w)/(2*b)-E_SYMBOL,
         2: 2*v-origin+(u+w)/(2*v)-E_SYMBOL,
         3: b+v-origin+w/(2*b)+u/(2*v)-E_SYMBOL,
         4: b+v-origin+u/(2*b)+w/(2*v)-E_SYMBOL}[beta]
    n = sp.factor(n)
    A = sp.expand(u+w+rat(EXCHANGE_MASS[meson])**2-n*n)
    return u, w, n, A, sp.Poly(sp.expand(A*A-4*u*w), E_SYMBOL)


def coefficients(E, out, inc, meson, sector=SECTOR_2PP):
    """A,B of the on-shell rational angular denominator A-B*x."""
    E = np.asarray(E, dtype=complex)
    p = np.sqrt(2*sector.channel(inc).mu*(E-sector.channel(inc).delta)+0j)
    q = np.sqrt(2*sector.channel(out).mu*(E-sector.channel(out).delta)+0j)
    n = nu(orderings(sector, out, inc)[0], q, p, E, sector)
    return p*p+q*q+EXCHANGE_MASS[meson]**2-n*n, 2*p*q


def roots(out, inc, meson, sector=SECTOR_2PP):
    u, w, n, A, poly = symbolic(out, inc, meson, sector)
    # Rational isolation keeps tiny leading coefficients and widely separated roots.
    vals = [complex(r.evalf(35)) for r in sp.polys.polytools.all_roots(poly)]
    return sorted(vals, key=lambda z: (abs(z), z.real, z.imag))


def tracked_moments(path, out, inc, meson, sector=SECTOR_2PP):
    """Moments m=0..4 along a sampled path; endpoint logs independently unwrapped.

    Path starts in the physical real region E>0; refine samples to test winding.
    The recurrence is exact away from B=0. It is deliberately not a production
    small-B evaluator, since the probes stay away from the thresholds.
    """
    path = np.asarray(path, dtype=complex)
    def root(index):
        c = sector.channel(index)
        z = 2*c.mu*(path-c.delta)
        return np.sqrt(abs(z))*np.exp(.5j*np.unwrap(np.angle(z)))
    p, q = root(inc), root(out)
    n = nu(orderings(sector, out, inc)[0], q, p, path, sector)
    A, B = p*p+q*q+EXCHANGE_MASS[meson]**2-n*n, 2*p*q
    fp, fm = A+B, A-B
    lp = np.log(abs(fp))+1j*np.unwrap(np.angle(fp))
    lm = np.log(abs(fm))+1j*np.unwrap(np.angle(fm))
    vals = [(lp-lm)/B]
    for m in range(1, 5):
        vals.append(A/B*vals[-1]-(1-(-1)**m)/(m*B))
    return np.array(vals)


def path_to(E, side=1, n=24001, height=0.025):
    """Upper/lower-half-plane dogleg, ending at E, starting at +30 MeV."""
    E = complex(E)
    points = [0.030+0j, 0.030+side*height*1j, E.real+side*height*1j, E]
    return np.concatenate([np.linspace(a,b,n//3,endpoint=False) for a,b in zip(points[:-1], points[1:])] + [np.array([E])])


def boundary(E, out, inc, meson, side=1, epsilon=1e-9, n=24001):
    return tracked_moments(path_to(E+side*epsilon*1j, side, n), out, inc, meson)[:, -1]


def jump(E, out, inc, meson, epsilon=1e-9, n=24001):
    return boundary(E,out,inc,meson,1,epsilon,n)-boundary(E,out,inc,meson,-1,epsilon,n)


def principal_moments(E, out, inc, meson):
    A,B = coefficients(E,out,inc,meson)
    return np.log((A+B)/(A-B))/B


def wu_data(out, inc, meson):
    high, low = sorted([SECTOR_2PP.channel(out), SECTOR_2PP.channel(inc)], key=lambda c:c.delta, reverse=True)
    # Choose the heavy line which changes V<->P; PV elastic swaps that line.
    mi, mj = (M_BSTAR, M_B) if high.pair != low.pair else ((M_BSTAR,M_B) if high.pair=="PV" else (M_BSTAR,M_BSTAR))
    gap = high.delta-low.delta
    aa = (mi-mj)**2+2*gap*(mj/mi)*high.mu
    bb = (mi-mj)**2+2*gap*((mj/mi)*high.mu-(mi/mj)*low.mu)
    mass2 = EXCHANGE_MASS[meson]**2
    case = 1 if mass2>aa else 2 if mass2==aa else 3 if mi/mj>=np.sqrt(high.mu/low.mu) or mass2>bb else 4
    u,w,n,A,poly = symbolic(high.index,low.index,meson)
    Aw = sp.expand(rat(mj)/rat(mi)*u+rat(mi)/rat(mj)*w+rat(EXCHANGE_MASS[meson])**2-(rat(mi)-rat(mj))**2)
    wp = sp.Poly(Aw*Aw-4*u*w,E_SYMBOL)
    wr = sorted([complex(r.evalf(35)) for r in sp.polys.polytools.all_roots(wp)],key=abs)
    near = roots(out,inc,meson)[0]
    return {"A_GeV2":aa,"B_GeV2":bb,"case":case,"mi1_GeV":mi,"mj1_GeV":mj,
            "f_A_difference":str(sp.factor(A-Aw)),"near_Wu_E_MeV":1000*wr[0].real,
            "near_TOPTs_minus_Wu_MeV":1000*(near.real-wr[0].real),
            "Wu_roots_E_MeV":[[1000*z.real,1000*z.imag] for z in wr]}


def record(out, inc, label, meson):
    u,w,n,A,poly=symbolic(out,inc,meson)
    rr=roots(out,inc,meson)
    endpoints=[]
    for E in rr:
        kvals={str(i):[float(momentum(SECTOR_2PP.channel(i),E).real*1000),float(momentum(SECTOR_2PP.channel(i),E).imag*1000)] for i in (1,5,6)}
        # Substitute a 40-digit algebraic root before conversion to machine precision.
        zz=sp.N(sp.polys.polytools.all_roots(poly)[min(range(poly.degree()),key=lambda j:abs(complex(sp.polys.polytools.all_roots(poly)[j])-E))],40)
        residual=abs(complex(poly.as_expr().subs(E_SYMBOL,zz).evalf()))
        endpoints.append({"E_MeV":[1000*E.real,1000*E.imag],"near":abs(E)<1,"k_MeV":kvals,"polynomial_residual_GeV4":residual})
    near=rr[0].real
    lower=min(SECTOR_2PP.channel(out).delta,SECTOR_2PP.channel(inc).delta)
    case=wu_data(out,inc,meson)["case"]
    # Finite cuts at huge recoil roots are retained in JSON; figures clip at -800 MeV.
    probes=[near-0.020, (near+lower)/2 if case==3 else near+0.0002]
    samples=[]
    for E in probes:
        jj=jump(E,out,inc,meson)
        jj2=jump(E,out,inc,meson,n=48001)
        av,bv=coefficients(E+1e-9j,out,inc,meson)
        single=2*np.pi/abs(bv)
        samples.append({"E_MeV":1000*E,"jump_m0_GeVminus2":[jj[0].real,jj[0].imag],
                        "jump_abs_m0":float(abs(jj[0])),"single_2pi_over_absB":float(single),
                        "normalized_jump":float(abs(jj[0])/single),
                        "moments_jump_abs":[float(x) for x in abs(jj)],
                        "doubling_path_samples_max_change":float(max(abs(jj2-jj)))})
    reverse_poly = symbolic(inc,out,meson)[-1]
    reverse_equal = sp.expand(poly.as_expr()-reverse_poly.as_expr()) == 0
    assert reverse_equal, "Time-reversed endpoint polynomial differs"
    return {"transition":label,"out":out,"in":inc,"meson":meson,"nu_on":str(n),"endpoint_polynomial":str(poly.as_expr()),
            "ordered_transitions":[[out,inc]] if out==inc else [[out,inc],[inc,out]],
            "reverse_endpoint_polynomial_exactly_equal":reverse_equal,
            "roots":endpoints,"wu":wu_data(out,inc,meson),"cut_case":case,"jump_probes":samples}


def threshold_monodromy(out, inc, meson):
    """Loop about the lower participating threshold, with radius 0.1 MeV.

    The radius stays inside the closest endpoint (VV–PV η, 0.546 MeV).
    The sign of the lower-channel momentum changes; the Case-3 branch
    leaves a residue term odd in B.
    """
    low = min(SECTOR_2PP.channel(out).delta, SECTOR_2PP.channel(inc).delta)
    radius = .0001
    start = low+radius+1e-8j
    circle = low+(start-low)*np.exp(1j*np.linspace(0,2*np.pi,16001))
    path = np.concatenate([path_to(start,1),circle[1:]])
    before = tracked_moments(path_to(start,1),out,inc,meson)[0,-1]
    after = tracked_moments(path,out,inc,meson)[0,-1]
    return {"probe_E_MeV":[start.real*1000,start.imag*1000],
            "before_m0":[before.real,before.imag],"after_m0":[after.real,after.imag],
            "change_abs":float(abs(after-before))}


def adjacent_boundary(E, out, inc, meson, crossed, side):
    """One fixed adjacent-sheet germ, then upper/lower approaches from it.

    From +30 MeV, encircle each crossed threshold counterclockwise by a
    0.1 MeV circle, returning on the same upper dogleg. Crucially the
    prefix is IDENTICAL for both banks: conjugate circuits would compare
    different logarithm germs rather than a discontinuity of one germ.
    """
    pieces = []
    for index in crossed:
        center = SECTOR_2PP.channel(index).delta
        start = center+.0001+1e-8j
        approach = path_to(start,1,n=12001)
        circle = center+(start-center)*np.exp(1j*np.linspace(0,2*np.pi,8001))
        pieces.extend([approach,circle[1:],approach[-2::-1]])
    pieces.append(path_to(E+side*1e-9j,side))
    return tracked_moments(np.concatenate(pieces),out,inc,meson)[:,-1]


def adjacent_jumps(entries):
    rows = []
    for entry in entries:
        for crossed,sheet in [((6,), "(-,+,+)"),((6,5), "(-,-,+)"),((6,5,1), "(-,-,-)")]:
            probes = []
            energies = [p["E_MeV"]/1000 for p in entry["jump_probes"]]
            if entry["out"] != entry["in"]:
                energies += [(SECTOR_2PP.channel(entry["out"]).delta+SECTOR_2PP.channel(entry["in"]).delta)/2,.020]
            for E in energies:
                upper = adjacent_boundary(E,entry["out"],entry["in"],entry["meson"],crossed,1)
                lower = adjacent_boundary(E,entry["out"],entry["in"],entry["meson"],crossed,-1)
                diff = upper-lower
                _, bb = coefficients(E+1e-9j,entry["out"],entry["in"],entry["meson"])
                probes.append({"E_MeV":E*1000,"jump_m0":[float(diff[0].real),float(diff[0].imag)],
                               "normalized_jump":float(abs(diff[0])/(2*np.pi/abs(bb)))})
            rows.append({"transition":entry["transition"],"meson":entry["meson"],"sheet":sheet,"probes":probes})
    return rows


def chart_boundary(kappa, out, inc, meson, side, epsilon, plane_index=1, axis="imag"):
    """Boundary within one momentum chart; other roots use continued_momentum."""
    plane = SECTOR_2PP.channel(plane_index)
    start = float(momentum(plane,.030).real)
    points = ([start+1e-8j, .1+.02j, side*.1+.02j,
               side*.1+1j*kappa, side*epsilon+1j*kappa] if axis=="imag" else
              [start+1e-8j, .1+.02j, .1+side*.02j,
               kappa+side*.02j, kappa+side*epsilon*1j])
    kp = np.concatenate([np.linspace(a,b,6000,endpoint=False)
                         for a,b in zip(points[:-1],points[1:])] +
                        [np.array([points[-1]])])
    E = energy(plane,kp)
    def root(index):
        return kp if index==plane_index else continued_momentum(plane,SECTOR_2PP.channel(index),kp)
    p,q = root(inc),root(out)
    n = nu(orderings(SECTOR_2PP,out,inc)[0],q,p,E)
    A,B = p*p+q*q+EXCHANGE_MASS[meson]**2-n*n,2*p*q
    fp,fm = A+B,A-B
    lp=np.log(abs(fp))+1j*np.unwrap(np.angle(fp))
    lm=np.log(abs(fm))+1j*np.unwrap(np.angle(fm))
    return ((lp-lm)/B)[-1]


def chart_jumps():
    rows=[]
    for out,inc,label in TRANSITIONS:
        for meson in EXCHANGE_MASS:
            bp=roots(out,inc,meson)[0].real
            lower=min(SECTOR_2PP.channel(out).delta,SECTOR_2PP.channel(inc).delta)
            kappas=[.250]
            if out==inc:kappas += [float(momentum(SECTOR_2PP.channel(1),bp-.020).imag)]
            else:
                kappas += [float(momentum(SECTOR_2PP.channel(1),(bp+lower)/2).imag),
                           float(momentum(SECTOR_2PP.channel(1),bp-.020).imag)]
            for kap in kappas:
                samples=[]
                for eps in (1e-6,1e-7,1e-8):
                    right=chart_boundary(kap,out,inc,meson,1,eps)
                    left=chart_boundary(kap,out,inc,meson,-1,eps)
                    A,B=coefficients(energy(SECTOR_2PP.channel(1),1j*kap)+1e-12j,out,inc,meson)
                    diff=right-left
                    samples.append({"epsilon_k_MeV":eps*1000,
                                    "jump_m0":[float(diff.real),float(diff.imag)],
                                    "normalized_jump":float(abs(diff)/(2*np.pi/abs(B)))})
                rows.append({"transition":label,"meson":meson,"kappa_MeV":kap*1000,"samples":samples})
    return rows


def chart_segments(entries):
    """Numerically locate axis cuts of the continued scalar moment in each chart.

    Break the axes at every known endpoint and other-root threshold, and
    approach each open segment from both banks WITHIN THE CHART. No E-bank
    discontinuity is blindly pulled back as a chart cut.
    """
    result=[]
    for index in (1,5,6):
        plane=SECTOR_2PP.channel(index)
        for row in entries:
            endpoints=[momentum(plane,row["roots"][0]["E_MeV"][0]/1000)]
            endpoints += [momentum(plane,SECTOR_2PP.channel(j).delta)
                          for _,j in SECTOR_2PP.thresholds if j!=index]
            for axis in ("real","imag"):
                breaks=[0.,1.]
                for z in endpoints:
                    val=abs(float(z.real if axis=="real" else z.imag))
                    if 1e-8<val<1:breaks.append(val)
                breaks=sorted(set(breaks))
                for sign in (-1,1):
                    for left,right in zip(breaks[:-1],breaks[1:]):
                        mid=sign*(left+right)/2
                        diffs=[]
                        for eps in (1e-7,1e-8):
                            a=chart_boundary(mid,row["out"],row["in"],row["meson"],1,eps,index,axis)
                            b=chart_boundary(mid,row["out"],row["in"],row["meson"],-1,eps,index,axis)
                            diffs.append(a-b)
                        k=mid if axis=="real" else 1j*mid
                        E=energy(plane,k)
                        p=continued_momentum(plane,SECTOR_2PP.channel(row["in"]),k) if row["in"]!=index else k
                        q=continued_momentum(plane,SECTOR_2PP.channel(row["out"]),k) if row["out"]!=index else k
                        norm=2*np.pi/abs(2*p*q)
                        ratio=float(abs(diffs[-1])/norm)
                        result.append({"plane":index,"transition":row["transition"],"meson":row["meson"],
                                       "axis":axis,"start_MeV":sign*left*1000,"end_MeV":sign*right*1000,
                                       "probe_k_MeV":mid*1000,"jump_m0":[float(diffs[-1].real),float(diffs[-1].imag)],
                                       "normalized_jump":ratio,"is_cut":ratio>.1,
                                       "offset_reduction_ratio":float(abs(diffs[-1])/max(abs(diffs[0]),1e-300))})
    return result


def dataset():
    entries=[record(o,i,label,m) for o,i,label in TRANSITIONS for m in EXCHANGE_MASS]
    checks=[]
    for m in EXCHANGE_MASS:
        E=roots(1,1,m,SECTOR_1PP)[0]
        k=momentum(SECTOR_1PP.channel(1),E)
        checks.append({"meson":m,"E_MeV":1000*E.real,"kappa_MeV":1000*k.imag})
    return {"units":"Internal GeV; displayed E and k MeV. Momenta on physical sheet, plus their negatives on reversed sheets.",
            "route":"Rational endpoint polynomial; split endpoint logs independently unwrapped on half-plane doglegs.",
            "entries":entries,"one_plus_plus":checks,
            "adjacent_sheet_route":"One fixed germ at +30 MeV from CCW 0.1-MeV threshold circuits on upper doglegs; identical prefix for both banks, then upper/lower doglegs to the probe.",
            "adjacent_sheet_jumps":adjacent_jumps(entries),
            "k1_chart_route":"Other momenta from continued_momentum; approach banks via Re k=±100 MeV, crossing Im k=20 MeV below endpoints.",
            "k1_chart_jumps":chart_jumps(),
            "chart_cut_segments":chart_segments(entries),
            "lower_threshold_monodromy":[{"transition":label,"meson":m,
                  **threshold_monodromy(o,i,m)} for o,i,label in TRANSITIONS
                  if o!=i for m in EXCHANGE_MASS]}


def main():
    data=dataset()
    (HERE/"data").mkdir(exist_ok=True)
    (HERE/"data/lhc_onshell.json").write_text(json.dumps(data,indent=2)+"\n")
    print("On-shell OME endpoint roots (MeV); k images: physical +i values below thresholds")
    for row in data["entries"]:
        print(f"{row['transition']:6s} {row['meson']:3s} Wu Case {row['wu']['case']}; Aij={row['wu']['A_GeV2']:.9f}, Bij={row['wu']['B_GeV2']:.9f} GeV²; nu={row['nu_on']}")
        print(f"  ordered transitions {row['ordered_transitions']}; near TOPT−Wu={row['wu']['near_TOPTs_minus_Wu_MeV']:.9g} MeV")
        for r in row["roots"]:
            print(f"  E={r['E_MeV'][0]: .9f}{r['E_MeV'][1]:+.3g}i  {'NEAR' if r['near'] else 'FAR NR artefact'} k={r['k_MeV']}")
        print("  jump / (2pi/|B|):", [(round(p['E_MeV'],6),round(p['normalized_jump'],7)) for p in row['jump_probes']])
    for row in data["one_plus_plus"]:
        print(f"1++ {row['meson']}: kappa_lhc = {row['kappa_MeV']:.3f} MeV [Zhang v1 Eq. (9)]")


if __name__=="__main__":
    main()
