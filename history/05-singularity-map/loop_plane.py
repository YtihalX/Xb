# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "scipy>=1.14"]
# ///
"""Loop-plane geometry (GeV): verified quartics and finite-contour diagnostics.

Certificates are numerical, mesh-dependent diagnostics, NOT a proof that arbitrary
branch cuts or continuous homotopies have been resolved. `best_graph` maximizes
clearance within the explicitly stated polygon family, not among all graphs.
The branch points are invariant; drawing principal-log cuts is not a branch prescription.
"""
from __future__ import annotations
from dataclasses import dataclass
import numpy as np
from scipy.optimize import minimize, linear_sum_assignment, brentq, linprog
from kinematics import (M_B, M_BSTAR, M_PI, M_ETA, LAMBDA, SECTOR_2PP,
                        ORDERINGS, momentum, momenta, nu, s_pm)

BETAS = tuple(sorted({b for pair in ORDERINGS.values() for b in pair}))
PAIR = {1: "BBπ", 2: "B*B*π", 3: "BB*π", 4: "BB*π"}
REP = {"VV": 1, "PV": 5, "PP": 6}

@dataclass
class Roots:
    q: np.ndarray
    physical: np.ndarray
    residual: np.ndarray
    other_residual: np.ndarray


def log_roots(p, E, beta, mass=M_PI, sign=-1):
    """All four squared roots, with principal-sqrt branch classification.

    nu=a q²+b gives a²q⁴+(2ab−1)q²−2 sign p q+b²−m²−p²=0.
    Physical means |principal(s)+nu|<1e-10; other_residual verifies the
    opposite sqrt sheet. Outside |Im(p+sign*q)|<m, continuation along a
    specified path, rather than this local principal label, is required.
    """
    p = np.asarray(p, complex)
    a = 1 / (2 * (M_B if beta in (1, 3) else M_BSTAR))
    b = nu(beta, p, 0, E)
    coeff = np.zeros(p.shape + (4, 4), complex)
    coeff[..., 0, :] = np.stack([np.zeros_like(b), -(2*a*b-1)/a**2,
                                2*sign*p/a**2, -(b*b-mass*mass-p*p)/a**2], axis=-1)
    coeff[..., 1, 0] = coeff[..., 2, 1] = coeff[..., 3, 2] = 1
    q = np.linalg.eigvals(coeff)
    # Newton polishing of the squared polynomial; no unsquared root is manufactured.
    for _ in range(3):
        n = a*q*q + b[..., None]
        f = n*n - mass*mass - (p[..., None]+sign*q)**2
        df = 4*a*q*n - 2*sign*(p[..., None]+sign*q)
        q -= np.divide(f,df,out=np.zeros_like(f),where=abs(df)>1e-24)
    n = nu(beta, p[..., None], q, E)
    s = s_pm(mass, p[..., None], q, sign)
    residual = abs(s+n)
    other = abs(-s+n)
    return Roots(q, residual < 1e-10, residual, other)


def sqrt_points(p, mass=M_PI):
    p = np.asarray(p, complex)
    return np.stack([p+1j*mass, p-1j*mass, -p+1j*mass, -p-1j*mass], axis=-1)


def sample_contour(nodes, n=121):
    """Arc-length samples plus every vertex; endpoints are always retained."""
    nodes = np.asarray(nodes, complex)
    d = abs(np.diff(nodes)); cumulative = np.r_[0, np.cumsum(d)]
    t = np.unique(np.r_[np.linspace(0, cumulative[-1], n), cumulative])
    return np.interp(t, cumulative, nodes.real) + 1j*np.interp(t, cumulative, nodes.imag)


def point_distances(points, contour):
    """Exact distance from each point to the polygon, vectorized in bounded batches."""
    points = np.asarray(points, complex).ravel()
    c = np.asarray(contour, complex)
    a, v = c[:-1], np.diff(c)
    result = np.empty(len(points))
    for start in range(0, len(points), 2048):
        z = points[start:start+2048, None]-a
        t = np.clip((z*np.conj(v)).real/abs(v)**2, 0, 1)
        result[start:start+2048] = np.min(abs(z-t*v), axis=1)
    return result


def curve_distance(curve, contour):
    """Exact polygon-to-polygon distance, including segment intersections."""
    curve = np.asarray(curve, complex); contour = np.asarray(contour, complex)
    if len(curve) < 2:
        return float(np.min(point_distances(curve, contour)))
    a = curve[:-1, None]; u = np.diff(curve)[:, None]
    b = contour[None, :-1]; v = np.diff(contour)[None, :]
    cross = lambda z, w: (np.conj(z)*w).imag
    den = cross(u, v)
    with np.errstate(divide="ignore", invalid="ignore"):
        t = cross(b-a, v)/den
        s = cross(b-a, u)/den
    hit = (abs(den)>1e-20)&(t>=0)&(t<=1)&(s>=0)&(s<=1)
    if np.any(hit):
        return 0.
    return float(min(np.min(point_distances(curve, contour)),
                     np.min(point_distances(contour, curve))))


def track_roots(roots):
    """Match adjacent quartic root sets before interpolating swept curves."""
    q = roots.q.copy(); physical = roots.physical.copy()
    for j in range(1, len(q)):
        _, permutation = linear_sum_assignment(abs(q[j-1, :, None]-q[j, None, :]))
        q[j] = q[j, permutation]; physical[j] = physical[j, permutation]
    return q, physical


def winding(point, contour):
    """Winding of real segment 0→Λ followed by reversed C; clockwise = −1."""
    polygon = np.r_[0j, LAMBDA+0j, np.asarray(contour, complex)[::-1], 0j]
    z = polygon-point
    if np.min(abs(z)) < 1e-12:
        return np.nan
    return int(np.rint(np.sum(np.angle(z[1:]/z[:-1]))/(2*np.pi)))


def pole_check(contour, E, sheet):
    records = []
    for (label, index), s in zip(SECTOR_2PP.thresholds, sheet):
        k = complex(momentum(SECTOR_2PP.channel(index), E, s))
        for sign in (+1, -1):
            point = sign*k
            expected = -1 if s < 0 and sign == 1 else 0
            got = winding(point, contour)
            records.append((f"G:{label}:{sign:+d}k", point, got, expected))
    return all(r[2] == r[3] for r in records), records


@dataclass
class Margin:
    distance: float
    limiting: str
    point: complex
    p_out: complex
    max_root_residual: float = 0.


def kernel_margin(contour, E, sheet, n=81, external=True, all_sqrt_sheets=False):
    """Endpoint branch-point clearance for p' on C and allowed external rows.

    Both mesons are included. For external row a only ORDERINGS[(a,b)]
    enter, avoiding fictitious singularities from forbidden transitions.
    `all_sqrt_sheets=True` additionally checks opposite-sheet EXTERNAL roots;
    they are labelled candidates, not asserted to be reached singularities.
    Sampling p' is not a continuous-set certificate: refine n before quoting.
    """
    c = np.asarray(contour, complex)
    p = sample_contour(c, n)
    best = Margin(np.inf, "none", 0j, 0j)
    def consider(points, parents, label):
        nonlocal best
        points = np.asarray(points).ravel(); parents = np.broadcast_to(parents, np.shape(points)) if np.ndim(parents)==0 else np.asarray(parents).ravel()
        if len(points) == 0:
            return
        d = point_distances(points, c); j = np.argmin(d)
        if d[j] < best.distance:
            best = Margin(float(d[j]), label, complex(points[j]), complex(parents[j]), best.max_root_residual)
    def consider_curves(points, masks, label):
        nonlocal best
        for j in range(points.shape[1]):
            indices = np.flatnonzero(masks[:, j])
            for block in np.split(indices, np.flatnonzero(np.diff(indices)>1)+1):
                if len(block)<2:
                    continue
                d = curve_distance(points[block,j], c)
                if d < best.distance:
                    best = Margin(d, label, complex(points[block[0],j]),
                                  complex(p[block[0]]), best.max_root_residual)
    sources = [("C", p, BETAS)]
    if external:
        ks = momenta(SECTOR_2PP, E, sheet)
        for pair, index in REP.items():
            bs = tuple(sorted({b for (out, _), order in ORDERINGS.items() if out == pair for b in order}))
            sources.append((f"external k{index}", np.array([ks[index]]), bs))
    maximum = 0.
    for source, ps, betas in sources:
        for mass, phi in ((M_PI, "π"), (M_ETA, "η")):
            points = sqrt_points(ps, mass)
            consider(points, np.broadcast_to(ps[:, None], points.shape), f"sqrt {phi}; {source}")
            if source == "C":
                consider_curves(points, np.ones(points.shape,bool), f"sqrt {phi}; C")
            for beta in betas:
                for sign in (-1, 1):
                    roots = log_roots(ps, E, beta, mass, sign)
                    keep = roots.physical
                    checked = np.minimum(roots.residual, roots.other_residual)
                    maximum = max(maximum, float(np.max(checked)))
                    parents = np.broadcast_to(ps[:, None], roots.q.shape)
                    consider(roots.q[keep], parents[keep], f"log β{beta} {phi}; {source}")
                    if all_sqrt_sheets and source != "C":
                        consider(roots.q[~keep],parents[~keep],
                                 f"other-sqrt candidate β{beta} {phi}; {source}")
                    if source == "C":
                        tracked, mask = track_roots(roots)
                        consider_curves(tracked, mask, f"log β{beta} {phi}; C")
    best.max_root_residual = maximum
    return best


def graph_contour(E, sheet, clearance=.04, scale=.15, end=2.5):
    """Re-increasing piecewise-linear graph; depth follows flipped poles.

    Shape h(x)=x/(scale+x)*(1-x/end), 0<x<end. A fixed mesh includes
    pole abscissae, so every flipped positive-Re pole has vertical clearance.
    An unflipped fourth-quadrant pole is not silently enclosed: pole_check
    rejects any candidate which gets its winding wrong.
    """
    if clearance < 0:
        return constrained_graph(E,sheet,slope=-clearance,fraction=scale,end=end)
    ks = momenta(SECTOR_2PP, E, sheet)
    flipped = [ks[index] for (_, index), s in zip(SECTOR_2PP.thresholds, sheet) if s < 0]
    if not flipped:
        return np.array([0j, LAMBDA+0j])
    if any(k.real <= 0 or k.real >= end for k in flipped):
        raise ValueError("A graph cannot enclose this pole: use a negative-Re excursion.")
    def shape(x): return x/(scale+x)*np.maximum(1-x/end, 0)
    depth = max((-k.imag+clearance)/shape(k.real) for k in flipped)
    xs = np.unique(np.r_[np.linspace(0, end, 35), [k.real for k in flipped], LAMBDA])
    return xs-1j*depth*shape(xs)


def external_lower_points(E,sheet):
    """External endpoints that must stay below a graph on this vertical route."""
    result=[]
    for (_,index),sign in zip(SECTOR_2PP.thresholds,sheet):
        channel=SECTOR_2PP.channel(index)
        if sign>0 and E.real>channel.delta: continue
        p=complex(momentum(channel,E,sign)); lower=[]
        if sign<0 and E.real>channel.delta:
            lower.append((p-1j*M_PI,f"sqrt π; external k{index} below-side"))
        elif sign>0:
            p0=complex(momentum(channel,E.real+1e-8j,+1))
            for mass,phi in ((M_PI,"π"),(M_ETA,"η")):
                # A point initially ABOVE the real contour may later enter
                # the lens through the real segment without crossing C.
                # Do not incorrectly force it to the lower side at that time.
                z0=sqrt_points(p0,mass)
                lower.extend((z,f"sqrt {phi}; external k{index} below-side")
                             for z,initial in zip(sqrt_points(p,mass),z0)
                             if z.imag<0 and initial.imag<0)
        betas={b for (out,_),order in ORDERINGS.items() if out==channel.pair for b in order}
        for beta in betas:
            for direction in (-1,1):
                roots=log_roots(p,E,beta,M_PI,direction)
                selected=roots.q[roots.physical] if sign<0 else roots.q
                lower.extend((z,f"log β{beta} π; external k{index} below-side") for z in selected
                             if z.real>0 and z.imag<(p.imag if sign<0 else 0))
        result.extend((z,label,p) for z,label in lower if 0<z.real<LAMBDA)
    return result


def constrained_graph(E,sheet,slope=2.,fraction=.7,end=1.5):
    """A slope-limited LP graph allows a delayed drop past closed-channel endpoints.

    Negative first entries in the three-number contour descriptor select this
    family: (-slope, fraction, end), rather than (clearance, scale, end).
    The LP maximizes vertical pole/endpoint clearance with |h'|<=slope;
    fraction then chooses a conservative fraction of that clearance.
    """
    ks=momenta(SECTOR_2PP,E,sheet)
    upper=[complex(ks[index]) for (_,index),s in zip(SECTOR_2PP.thresholds,sheet) if s<0]
    if any(z.real<=0 for z in upper): raise ValueError("Graph needs a negative-Re excursion")
    lower=[z for z,_,_ in external_lower_points(E,sheet)]
    lower.extend(-complex(ks[index]) for (_,index),s in zip(SECTOR_2PP.thresholds,sheet)
                 if s>0 and (-complex(ks[index])).real>0)
    end=max(end,max(z.real for z in upper)+.2)
    xs=np.unique(np.r_[0.,[z.real for z in upper],[z.real for z in lower],end,LAMBDA])
    N=len(xs)
    def solve(clearance=None):
        A=[];b=[]
        for z in upper:
            row=np.zeros(N+1);row[np.searchsorted(xs,z.real)]=1;row[-1]=1
            A.append(row);b.append(z.imag)
        for z in lower:
            row=np.zeros(N+1);row[np.searchsorted(xs,z.real)]=-1;row[-1]=1
            A.append(row);b.append(-z.imag)
        for j,dx in enumerate(np.diff(xs)):
            for sign in (-1,1):
                row=np.zeros(N+1);row[j]=-sign;row[j+1]=sign
                A.append(row);b.append(slope*dx)
        bounds=[(-2.,0.)]*N+([(0.,.12)] if clearance is None else [(clearance,clearance)])
        bounds[0]=bounds[N-1]=(0.,0.)
        objective=np.r_[np.full(N,-1e-7),-1. if clearance is None else 0.]
        solved=linprog(objective,A_ub=np.asarray(A),b_ub=np.asarray(b),bounds=bounds,method="highs")
        if not solved.success: raise ValueError("Slope-limited graph infeasible")
        return solved.x
    optimum=solve()
    if optimum[-1]<=1e-7: raise ValueError("No positive graph clearance")
    solution=solve(fraction*optimum[-1])
    return xs+1j*solution[:-1]


def contour_margin(contour, E, sheet, n=81):
    ok, records = pole_check(contour, E, sheet)
    if not ok:
        return Margin(-1., "wrong pole winding", 0j, 0j)
    km = kernel_margin(contour, E, sheet, n=n)
    # The lower external endpoint starts BELOW the contour. Keeping only
    # its unsigned final distance would incorrectly accept a contour that
    # has already crossed it. Open external momenta stay in Re p'>0.
    if np.all(np.diff(np.asarray(contour).real)>0):
        for root,label,p in external_lower_points(E,sheet):
            signed=np.interp(root.real,np.asarray(contour).real,np.asarray(contour).imag)-root.imag
            if signed<=0:
                return Margin(float(signed),label+" violated",complex(root),p,km.max_root_residual)
    points = np.array([r[1] for r in records]); d = point_distances(points, contour); j = np.argmin(d)
    if d[j] < km.distance:
        return Margin(float(d[j]), records[j][0], complex(points[j]), 0j, km.max_root_residual)
    return km


def best_graph(E, sheet, n=61, refine=False):
    """Best sampled margin across smooth-dip and slope-constrained graph families."""
    candidates = []
    def objective(par):
        clearance, scale, end = par
        try:
            c = graph_contour(E, sheet, clearance, scale, end)
            m = contour_margin(c, E, sheet, n)
        except ValueError:
            return 1.
        candidates.append((m.distance, c, m, par))
        return -m.distance
    for clearance in (.025, .06, .12):
        for scale in (.04, .18, .6):
            for end in (1.1, 1.6, 2.8):
                objective((clearance, scale, end))
    for slope in (.8,1.5,3.,6.):
        for fraction in (.4,.7,.95):
            objective((-slope,fraction,1.5))
    best = max(candidates, key=lambda item: item[0])
    if refine:
        seed=max((item for item in candidates if item[3][0]>0),key=lambda item:item[0])
        minimize(objective, seed[3], method="Nelder-Mead", bounds=((.002,.3),(.005,2.),(.9,4.)),
                 options={"maxiter": 35, "xatol": .002, "fatol": .0001})
        best = max(candidates, key=lambda item: item[0])
    return best[1], best[2], np.array(best[3])


@dataclass
class Homotopy:
    passed: bool
    margin: Margin
    poles_ok: bool
    samples: int
    note: str


def external_crossings(route):
    """Detect crossings BETWEEN samples, independently tracking sqrt phases.

    A squared quartic crossing counts only on the sqrt sheet reached at C.
    `route` contains (E, sheet, Re-increasing contour) triples.
    """
    previous_s = {}; previous_points = {}; crossings = []
    grid = np.unique(np.r_[np.linspace(0,1.2,401),np.linspace(1.2,LAMBDA,151)])
    for step,(E,sheet,c) in enumerate(route):
        c = np.asarray(c)
        cq = grid+1j*np.interp(grid,c.real,c.imag)
        for pair,index in REP.items():
            p = complex(momenta(SECTOR_2PP,E,sheet)[index])
            betas = tuple(sorted({b for (out,_),order in ORDERINGS.items() if out==pair for b in order}))
            for mass,phi in ((M_PI,"π"),(M_ETA,"η")):
                for sign in (-1,1):
                    key=(index,phi,sign)
                    principal=s_pm(mass,p,cq,sign)
                    old=previous_s.get(key)
                    reached=principal if old is None else np.where(abs(principal-old)<=abs(-principal-old),principal,-principal)
                    previous_s[key]=reached
                    sets=[(f"sqrt {phi}; external k{index}",np.array([-sign*p+1j*mass,-sign*p-1j*mass]),None)]
                    for beta in betas:
                        roots=log_roots(p,E,beta,mass,sign)
                        sets.append((f"log β{beta} {phi}; external k{index}",roots.q,beta))
                    for label,points,beta in sets:
                        pkey=(key,label)
                        previous=previous_points.get(pkey)
                        if previous is not None:
                            old_points,old_heights,old_inside=previous
                            _,permutation=linear_sum_assignment(abs(old_points[:,None]-points[None,:]))
                            points=points[permutation]
                        inside=(points.real>0)&(points.real<LAMBDA)
                        heights=points.imag-np.interp(points.real,c.real,c.imag)
                        if previous is not None:
                            crossing=inside&old_inside&(heights*old_heights<0)
                            for j in np.flatnonzero(crossing):
                                physical=True
                                if beta is not None:
                                    tracked=np.interp(points[j].real,grid,reached.real)+1j*np.interp(points[j].real,grid,reached.imag)
                                    sr=complex(s_pm(mass,p,points[j],sign))
                                    sr=sr if abs(sr-tracked)<=abs(-sr-tracked) else -sr
                                    physical=abs(sr+nu(beta,p,points[j],E))<1e-10
                                if physical:
                                    crossings.append((step,label,complex(points[j])))
                        previous_points[pkey]=(points,heights,inside)
    return crossings

def homotopy_test(E, sheet, parameters, steps=25, n=121):
    """Straight vertical adjacent-sheet energy route, with rebuilt graph C(E).

    Starts at E_mid+i0, crosses only its open thresholds. This route is
    unavailable for non-adjacent sheets (e.g. virtual VV below threshold).
    The infinitesimal initial pole pinch is prescribed by +i0; margins
    here concern the kernel, not an impossible positive uniform G margin
    at the real-axis crossing. External roots are conservatively checked
    on both sqrt sheets. For p',q on a Re-increasing graph, Re(p'−q)=0
    implies p'=q and Re(p'+q)>0 except at the origin, so neither s² can
    cross the negative real axis: their continued roots are principal.
    """
    expected = tuple(-1 if E.real > SECTOR_2PP.channel(index).delta else 1
                     for _, index in SECTOR_2PP.thresholds)
    if tuple(sheet) != expected:
        raise ValueError("Vertical route does not reach requested non-adjacent sheet.")
    worst = Margin(np.inf, "none", 0j, 0j); poles_ok = True
    route = []
    # First lower C while E remains on the physical upper rim. Only then
    # cross the open-channel cut and descend in E. This includes the
    # otherwise easily missed real-segment→finite-dip part of the homotopy.
    base = graph_contour(E.real-1e-8j, sheet, *parameters)
    for fraction in np.linspace(0, 1, steps):
        c = base.real+1j*fraction*base.imag
        route.append((E.real+1e-8j,(1,1,1),c))
        m = kernel_margin(c, E.real+1e-8j, (1,1,1), n=n,
                          all_sqrt_sheets=True)
        if m.distance < worst.distance: worst = m
    for y in np.linspace(1e-8, max(-E.imag, 1e-8), steps):
        Et = E.real-1j*y
        c = graph_contour(Et, sheet, *parameters)
        route.append((Et,sheet,c))
        pok, _ = pole_check(c, Et, sheet); poles_ok &= pok
        m = kernel_margin(c, Et, sheet, n=n, all_sqrt_sheets=True)
        if m.distance < worst.distance: worst = m
    crossings = external_crossings(route)
    if crossings:
        _,label,point = crossings[0]
        worst = Margin(0.,label+" crossing",point,0j)
    return Homotopy(bool(poles_ok and worst.distance > 1e-5), worst, poles_ok, steps,
                    "Sampled conservative endpoint test; refine meshes; no cut-crossing proof.")


def virtual_contour(E, depth_margin=.008, width=.025):
    """Negative-Re excursion followed by a positive-Re graph to enclose k1."""
    ks = momenta(SECTOR_2PP, E, (-1,-1,-1)); k = ks[1]
    left = min(-width, k.real-width)
    depth = -k.imag+depth_margin
    open_depth = max(-ks[i].imag+depth_margin for i in (5,6))
    return np.array([0j, left-1j*depth, .08-1j*depth,
                     .28-1j*open_depth, 1.1-1j*open_depth, 2.8+0j, LAMBDA+0j])


def best_virtual(E, n=251):
    candidates = []
    for width in (.002, .008, .025):
        for margin in (.0001, .0004, .001, .003, .008):
            c = virtual_contour(E, margin, width)
            m = contour_margin(c, E, (-1,-1,-1), n=n)
            candidates.append((m.distance, c, m, width, margin))
    _, c, m, width, margin = max(candidates, key=lambda z:z[0])
    return c, m, (width, margin)


def transition_margin(c_out, c_in, E, betas, n=401):
    """Reached near-contour endpoint sets for one species transition."""
    p=sample_contour(c_out,n)
    best=Margin(np.inf,"none",0j,0j)
    for mass,phi in ((M_PI,"π"),(M_ETA,"η")):
        sets=[(sqrt_points(p,mass),None,f"sqrt {phi}")]
        for beta in set(betas):
            for sign in (-1,1):
                roots=log_roots(p,E,beta,mass,sign)
                q,mask=track_roots(roots)
                sets.append((q,mask,f"log β{beta} {phi}"))
        for points,mask,label in sets:
            if mask is None: mask=np.ones(points.shape,bool)
            for j in range(points.shape[1]):
                ids=np.flatnonzero(mask[:,j])
                for block in np.split(ids,np.flatnonzero(np.diff(ids)>1)+1):
                    if len(block)==0: continue
                    distance=curve_distance(points[block,j],c_in)
                    if distance<best.distance:
                        best=Margin(distance,label,complex(points[block[0],j]),complex(p[block[0]]))
    return best


def channel_virtual_contours(E, margin=.00001, width=.002):
    """Only VV goes round k1; PV and PP stay just below their open poles."""
    k=complex(momenta(SECTOR_2PP,E,(-1,-1,-1))[1])
    depth=-k.imag+margin
    c1=np.array([0j,-width-1j*depth,.008-1j*depth,.12+0j,LAMBDA+0j])
    opened=graph_contour(E,(-1,-1,1),clearance=.003,scale=.1,end=1.5)
    return {"VV":c1,"PV":opened,"PP":opened}


def channel_virtual_margins(E, margin=.00001, n=801):
    contours=channel_virtual_contours(E,margin)
    ks=momenta(SECTOR_2PP,E,(-1,-1,-1))
    for pair,index in REP.items():
        assert winding(complex(ks[index]),contours[pair])==-1
        assert winding(-complex(ks[index]),contours[pair])==0
    results={}
    for (out,inc),betas in ORDERINGS.items():
        results[f"{out}←{inc}"]=transition_margin(contours[out],contours[inc],E,betas,n)
    return contours,results


def channel_virtual_limit(margin=.00001,n=801):
    """Numerical bisection of the first V11 reflected endpoint intersection.

    For each trial the off-diagonal blocks are evaluated too; the returned
    limiting block is measured rather than assumed. Limit margin→0 is mπ/2.
    """
    lo=.04;hi=.08
    for _ in range(22):
        k=(lo+hi)/2;E=-k*k/M_BSTAR-1e-12j
        _,results=channel_virtual_margins(E,margin,n)
        if min(m.distance for m in results.values())<1e-10: hi=k
        else: lo=k
    k=(lo+hi)/2;E=-k*k/M_BSTAR-1e-12j
    _,results=channel_virtual_margins(E,margin,n)
    return k,E,results


def virtual_homotopy(E, parameters, steps=41, n=201):
    """Cross VV threshold above it, then move left in the lower E half-plane."""
    width, margin = parameters
    worst = Margin(np.inf, "none", 0j, 0j); poles_ok = True
    route = np.r_[.001-1j*np.linspace(1e-8,-E.imag,steps),
                  np.linspace(.001,E.real,steps)+1j*E.imag]
    base = virtual_contour(route[0], margin, width)
    for fraction in np.linspace(0,1,steps):
        c = base.real+1j*fraction*base.imag
        m = kernel_margin(c,.001+1e-8j,(1,1,1),n=n,all_sqrt_sheets=True)
        if m.distance < worst.distance: worst=m
    for Et in route:
        c = virtual_contour(Et, margin, width)
        poles_ok &= pole_check(c,Et,(-1,-1,-1))[0]
        m = kernel_margin(c,Et,(-1,-1,-1),n=n,all_sqrt_sheets=True)
        if m.distance < worst.distance: worst=m
    return Homotopy(bool(poles_ok and worst.distance>1e-5),worst,poles_ok,
                    len(route)+steps,"Sampled conservative virtual-state route.")


def virtual_limit():
    """Real-axis pinch of the reflected BBπ endpoint at q=p'=−iκ."""
    def equation(kappa):
        E = -kappa*kappa/M_BSTAR
        return (np.sqrt(M_PI*M_PI-4*kappa*kappa)
                + nu(1,-1j*kappa,-1j*kappa,E).real)
    kappa = brentq(equation, 0, M_PI/2*(1-1e-12), xtol=1e-15)
    return kappa, -kappa*kappa/M_BSTAR, equation(kappa)


def self_test():
    maximum = 0.
    for E in (0j, -.02262-.01j, .02379-.01j, -.02262-.06j):
        for p in (0j, .3-.1j, .8-.3j):
            for beta in BETAS:
                for mass in (M_PI, M_ETA):
                    for sign in (-1,1):
                        r = log_roots(p,E,beta,mass,sign)
                        maximum = max(maximum, float(np.max(np.minimum(r.residual,r.other_residual))))
                        assert np.all(np.minimum(r.residual,r.other_residual)<1e-10)
    print(f"PASS quartic direct unsquared root checks: max residual {maximum:.3e} GeV")
    threshold=M_PI-2*(M_BSTAR-M_B)
    threshold_roots=log_roots(0,threshold,1)
    assert np.all(np.isfinite(threshold_roots.q))
    assert min(abs(threshold_roots.q[threshold_roots.physical]))<1e-7
    print(f"PASS BBπ threshold endpoint coalescence at E={1000*threshold:.6f} MeV")
    r = log_roots(0,0,1)
    print("E=0,p'=0,BBπ: physical roots (MeV)",np.round(r.q[r.physical]*1000,6),
          "; opposite-sqrt roots",np.round(r.q[~r.physical]*1000,6))
    print("Opposite-sqrt far roots are not physical-branch log points.")
    for E,s in ((-.06785-.01j,(-1,1,1)),(-.02262-.01j,(-1,-1,1)),
                (.02379-.01j,(-1,-1,-1)),(-.02262-.06j,(-1,-1,1))):
        c,m,par=best_graph(E,s,n=121,refine=True)
        h=homotopy_test(E,s,par,steps=31,n=151)
        assert h.passed
        print(f"E={1000*E} MeV sheet={s}: final {1000*m.distance:.3f} MeV [{m.limiting}]; "
              f"homotopy kernel {1000*h.margin.distance:.3f} MeV [{h.margin.limiting}], "
              f"sampled {'PASS' if h.passed else 'FAIL'}; parameters={par}")
    E=-.02262-.01j;s=(-1,-1,1)
    missed=pole_check(np.array([0j,LAMBDA+0j]),E,s)[0]
    assert not missed
    print("PASS deliberately missed flipped-pole contour: winding test rejects real segment")
    p=.35-.05j; branch=p-1j*M_PI
    bad=np.array([0j,p,branch,LAMBDA+0j])
    d=kernel_margin(bad,E,s,n=121).distance
    assert d<1e-12
    print(f"PASS deliberately crossing branch point: exact point-to-contour distance {d:.2e} GeV")
    for E in (-.0005-.0001j,-.02262-.0005j):
        c,m,par=best_virtual(E,n=501)
        print(f"Virtual probe {1000*E} MeV: endpoint distance {1000*m.distance:.4f} MeV [{m.limiting}]; "
              f"parameters={par}; {'CLEAR' if m.distance>1e-5 else 'BLOCKED'} in this family")
        if E.real > -.001:
            h=virtual_homotopy(E,par,steps=31,n=251)
            print(f"  virtual-route kernel margin {1000*h.margin.distance:.5f} MeV "
                  f"[{h.margin.limiting}]: {'PASS' if h.passed else 'FAIL'}")
            assert h.passed
        else:
            assert m.distance==0
    print(f"Static virtual necessary bound κ<mπ/2: κ={M_PI*500:.6f} MeV; "
          f"|E|<mπ²/(8μVV)={1000*M_PI**2/(8*SECTOR_2PP.channel(1).mu):.6f} MeV")
    kappa, Ecrit, residual = virtual_limit()
    print(f"Full TOPT reflected BBπ pinch: κ={1000*kappa:.6f} MeV; "
          f"E={1000*Ecrit:.6f} MeV; direct residual={residual:.3e} GeV")
    for margin in (.0001,.00001):
        k,E,results=channel_virtual_limit(margin=margin,n=1001)
        assert abs(k+margin-M_PI/2)<1e-6
        assert all(m.distance>.05 for block,m in results.items() if block!="VV←VV")
        print(f"Channel-dependent contours, excursion margin {1000*margin:g} MeV: "
              f"κcrit={1000*k:.6f} MeV, Ecrit={1000*E.real:.6f} MeV")
        for block,m in results.items():
            print(f"  {block}: {1000*m.distance:.6f} MeV [{m.limiting}]")

if __name__ == "__main__":
    self_test()
