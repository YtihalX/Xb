# /// script
# requires-python = ">=3.12"
# dependencies = ["mpmath>=1.3"]
# ///
"""Wu:2026wxb v1, App. D (D1)-(D4): all contours and their sheet mirrors.

Independent reference: J = i*pi*Log(1-2*i*p/m). To obtain it without
any App. D contour prescription, put p=i*kappa (kappa>0), differentiate
the real-axis integral in m, and integrate the resulting rational function
by residues: dJ/dm = -2*i*pi*kappa/[m*(m+2*kappa)]. J(m=infinity)=0
fixes the constant. Analytic continuation in Re p>0 fixes the displayed
principal Log on BOTH sheets (its argument stays in the lower half-plane).
Thus no contour, log-jump term, or pole-residue correction under test enters
the reference. All momenta and masses below are in GeV.

Upper-sheet terms are App. D. For the lower sheet the contour passes BELOW
the pole p, not its Schwarz-conjugate contour above it. Cbar_R0 encloses p
clockwise relative to Cbar_R, hence J = J_real + 2*pi*i*Res_p, with
Res_p = -(Log(m^2)-Log(4*p^2+m^2))/2. For |Im p|>m the downward
w_- cut adds -2*pi*i*integral[Re p,p+i*m] q*dq/(p^2-q^2).
Cbar_L crosses the w_+ cut below-to-above, n_+=-1 on Cbar_S,
so its correction is +2*pi*i*integral_Cbar_S. In (D4) both horizontal
u cuts lie above the lower contour: Im q=|Im p| +/- m > 0.

Red tests deliberately replace the split logs by Log(w_-/w_+) on C_R'
and Cbar_R', KEEPING the contour's pole/cut terms. For real q the extra
ratio-log cut crosses at q*=sqrt(|p|^2-m^2)>Re p when |Im p|>m.
On Re p<q<q*, split-minus-ratio = -sign(Im p)*2*pi*i. Thus the
predicted INTEGRATED discrepancy is a 2*pi*i multiple of a propagator
integral, not generally an integer multiple of 2*pi*i in J itself.

Each quadrature supplies an error estimate. The provisional absolute
allowance is 32*(sum of estimates + arithmetic floor), enlarged by the
observed 30-to-45-digit change; it is never fitted to a reference residual.
Bridge: literature/Wu:2026wxb/bridge.md. This is the static Yukawa example,
not a test of the TOPT kernel or Julia implementation.
Run: uv run --script checks/appd_contours.py
"""
import mpmath as mp

POINTS = {
    "a": [("0.30", "0.08"), ("0.12", "0.05")],
    "b": [("0.30", "0.20"), ("0.55", "0.40")],
    "c": [("0.02", "0.20"), ("0.01", "0.35")],
}


class Quadrature:
    """Carry absolute quadrature estimates through sums and jump factors."""

    def __init__(self):
        self.error = mp.mpf(0)
        self.magnitude = mp.mpf(0)
        self.count = 0

    def quad(self, f, nodes):
        value, error = mp.quad(f, nodes, error=True)
        self.error += abs(error)
        self.magnitude += abs(value)
        self.count += 1
        return value

    def path(self, f, nodes, splits=()):
        total = mp.mpc(0)
        for a, b in zip(nodes[:-1], nodes[1:]):
            d = b - a
            ts = {mp.mpf(0), mp.mpf(1)}
            for kind, value in splits:
                component = mp.re if kind == "re" else mp.im
                if component(d):
                    t = (value - component(a)) / component(d)
                    if 0 < t < 1:
                        ts.add(t)
            ts = sorted(ts)
            for t0, t1 in zip(ts[:-1], ts[1:]):
                total += self.quad(lambda t: f(a + d*t)*d, [t0, t1])
        return total

    def ray(self, f, start, splits):
        y = mp.im(start)
        xs = sorted({mp.re(start)} | {v for k, v in splits
                                      if k == "re" and v > mp.re(start)})
        total = sum((self.quad(lambda x: f(x + 1j*y), [x0, x1])
                     for x0, x1 in zip(xs[:-1], xs[1:])), mp.mpc(0))
        return total + self.quad(lambda x: f(x + 1j*y),
                                 [xs[-1], xs[-1]+1, mp.inf])

    def allowance(self):
        # 2*pi factors multiply some path estimates; 32 exceeds 2*pi and
        # allows accumulation/roundoff. The floor scales with work and size.
        floor = mp.power(10, -mp.mp.dps + 3)*(1+self.magnitude)*(1+self.count)
        return 32*(self.error + floor)


def split_logs(q, p, m):
    return mp.log((q-p)**2+m*m) - mp.log((q+p)**2+m*m)


def left_logs(q, p, m):
    return mp.log((q-p)**2+m*m) - mp.log(q+p-1j*m) - mp.log(q+p+1j*m)


def pole_term(p, m, quad):
    # Clockwise lower-sheet enclosure; the upper real contour has no pole term.
    residue = -(mp.log(m*m)-mp.log(4*p*p+m*m))/2
    return 2j*mp.pi*residue


def right_cut(p, m, quad):
    sign = mp.sign(mp.im(p))
    return sign*2j*mp.pi*quad.path(lambda q: q/(p*p-q*q),
                                 [mp.re(p), p-sign*1j*m])


def left_cut(p, m, quad, r, h):
    sign = mp.sign(mp.im(p))
    a = mp.re(p)
    return -sign*2j*mp.pi*quad.path(lambda q: q/(p*p-q*q),
                                  [-a, -r, -r+sign*1j*h, -a+sign*1j*h])


PRESCRIPTIONS = {
    "C_R0": lambda p, m, q: mp.mpc(0),
    "C_R'": right_cut,
    "C_L": left_cut,
    "Cbar_R0": pole_term,
    "Cbar_R'": lambda p, m, q: pole_term(p, m, q)+right_cut(p, m, q),
    "Cbar_L": left_cut,
}


def evaluate(case, real, imag, sheet, digits):
    with mp.workdps(digits):
        m = mp.mpf("0.138039407")
        p = mp.mpc(real, imag)*1  # parse decimal inputs at each precision
        if sheet == "(-)":
            p = mp.conj(p)
        a, b = mp.re(p), mp.im(p)
        sign = mp.sign(b)
        prefix = "C" if sign > 0 else "Cbar"
        h = (max(b-m, 0)+b)/2 if sign > 0 else -b+m/2
        splits = [("re", a), ("re", -a)]
        reference = 1j*mp.pi*mp.log(1-2j*p/m)
        results = {}

        def store(label, compute, expected=reference):
            quad = Quadrature()
            value = compute(quad)
            results[label] = (value, expected, quad.allowance())

        f = lambda q: q/(p*p-q*q)*split_logs(q, p, m)
        store(prefix+"_R", lambda quad: quad.path(f, [0, sign*1j*h], splits)
              + quad.ray(f, sign*1j*h, splits))
        right_label = prefix+("_R0" if abs(b)<m else "_R'")
        correction = PRESCRIPTIONS[right_label]
        store(right_label, lambda quad: quad.ray(f, mp.mpc(0), splits)
              + correction(p, m, quad))
        if abs(b)>m:
            r = a+mp.mpf("0.4")
            store(prefix+"_L", lambda quad: quad.path(f, [0, -r, -r+sign*1j*h], splits)
                  + quad.ray(f, -r+sign*1j*h, splits)
                  + PRESCRIPTIONS[prefix+"_L"](p, m, quad, r, h))
            radius = h/2
            fl = lambda q: q/(p*p-q*q)*left_logs(q, p, m)
            def left_arc(quad):
                centre = sign*1j*radius
                def arc(t):
                    q = centre+radius*mp.expj(t)
                    return fl(q)*1j*radius*mp.expj(t)
                return quad.quad(arc, [-sign*mp.pi/2, -sign*3*mp.pi/2]) \
                    + quad.ray(fl, sign*1j*h, splits)
            store(prefix+"_L'", left_arc)

            # The interval and winding are geometric predictions, not obtained
            # by subtracting the numerical split and ratio logarithms.
            qstar = mp.sqrt(abs(p)**2-m*m)
            red_splits = splits+[("re", qstar)]
            fr = lambda q: q/(p*p-q*q)*mp.log(((q-p)**2+m*m)/((q+p)**2+m*m))
            def red(quad):
                ratio_value = quad.ray(fr, mp.mpc(0), red_splits)+correction(p, m, quad)
                predicted = sign*2j*mp.pi*quad.path(lambda q: q/(p*p-q*q), [a, qstar])
                # Zero tests the predicted nonzero discrepancy, not equality.
                return ratio_value-reference-predicted
            store(right_label+" ratio-log jump", red, mp.mpc(0))
            # An explicit red assertion also requires the bad answer to differ
            # significantly, so a zero jump cannot produce a vacuous PASS.
            jumpquad = Quadrature()
            predicted = sign*2j*mp.pi*jumpquad.path(lambda q: q/(p*p-q*q), [a, qstar])
            results[right_label+" ratio-log is wrong"] = (predicted, None, jumpquad.allowance())
        return results


def main():
    failed = False
    for case, points in POINTS.items():
        for real, imag in points:
            for sheet in ("(+)", "(-)"):
                low = evaluate(case, real, imag, sheet, 30)
                high = evaluate(case, real, imag, sheet, 45)
                with mp.workdps(45):
                    for label, (value, reference, estimate) in high.items():
                        convergence = abs(value-low[label][0])
                        tolerance = estimate+low[label][2]+32*convergence
                        deviation = abs(value) if reference is None else abs(value-reference)
                        ok = deviation>tolerance if reference is None else deviation<=tolerance
                        failed |= not ok
                        print("PASS" if ok else "FAIL",
                              f"App.D ({case}) sheet {sheet} p=({real},{imag}) {label}:",
                              f"{'jump' if reference is None else 'residual'}={mp.nstr(deviation, 5)}",
                              f"tol={mp.nstr(tolerance, 5)}",
                              f"[32*(quad errors+roundoff)={mp.nstr(estimate+low[label][2], 4)};",
                              f"32*|45dps-30dps|={mp.nstr(32*convergence, 4)}; provisional]")
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
