/* kernel.c: the angular moments M_m(nu) of notes/07-continued-lse.tex, S12 and
 * S22, and the OME kernel V_{a'a}(p', q; E) = -(g_b^2/(8F_pi^2)) sum_m
 * c_{a'a,m} [M_m(nu_b1) + M_m(nu_b2)], summed as 3 V(m_pi) + V(m_eta)/3. */
#include <complex.h>
#include <float.h>
#include <math.h>

#include "impl.h"

#pragma STDC CX_LIMITED_RANGE ON

/* The bracket of S12 in powers of Z_pm = s_pm + nu: with a = A - nu^2 and c_k
 * the coefficients of (a + 2 nu u - u^2)^m, M_m = [c_0 (L_+ - L_-) +
 * sum_{k=1}^{2m} c_k (Z_+^k - Z_-^k)/k] / B^{m+1}, where Z_+^k - Z_-^k grows
 * from Z_+ - Z_- = 2B/(s_+ + s_-) without cancellation. Returns kappa, the
 * largest sum of the moduli of a bracket's summands over the bracket's modulus.
 */
static double closed(int order, double complex a, double complex b,
					 double complex nu, double complex dz, double complex dl,
					 double complex zp, double complex zm,
					 double complex out[static 5]) {
	double complex c[9] = {1}, denominator = b;
	double kappa = 1;
	for (int m = 0;; m++) {
		double complex value = c[0] * dl, difference = 0, power = 1;
		double size = cabs(value);
		for (int k = 1; k <= 2 * m; k++) {
			difference = zp * difference + dz * power;
			const double complex summand = c[k] * difference / k;
			value += summand;
			size += cabs(summand);
			power *= zm;
		}
		out[m] = value / denominator;
		kappa = fmax(kappa, value == 0 ? (size == 0 ? 1 : INFINITY)
									   : size / cabs(value));
		if (m == order)
			return kappa;
		denominator *= b;
		for (int k = 2 * m + 2; k >= 0; k--)
			c[k] = (k <= 2 * m ? a * c[k] : 0) +
				   (k >= 1 && k <= 2 * m + 1 ? 2 * nu * c[k - 1] : 0) -
				   (k >= 2 ? c[k - 2] : 0);
	}
}

/* The same bracket with every quantity recomputed from the inputs at `bits`
 * bits. */
enum {
	P,
	Q,
	E,
	M2,
	NU,
	A,
	B,
	SP,
	SM,
	ZP,
	ZM,
	DL,
	AA,
	DZ,
	VAL,
	DIF,
	POW,
	DEN,
	T1,
	T2,
	C
};
static_assert(C + 9 <= XB_MP);

static xb_status closed_mp(mpc_t z[static XB_MP], mpfr_prec_t bits, int order,
						   double mphi, double t, double h, double ha,
						   double complex p, double complex q, double complex e,
						   double complex out[static 5]) {
	constexpr mpc_rnd_t rnd = MPC_RNDNN;
	for (int i = 0; i < C + 9; i++)
		mpc_set_prec(z[i], bits);
	mpc_set_dc(z[P], p, rnd);
	mpc_set_dc(z[Q], q, rnd);
	mpc_set_dc(z[E], e, rnd);
	mpc_set_d(z[M2], mphi, rnd);
	mpc_sqr(z[M2], z[M2], rnd);
	/* nu = t + (h p^2 + a q^2) - E, A = m^2 + (p^2 + q^2), B = 2 p q */
	mpc_sqr(z[T1], z[P], rnd);
	mpc_sqr(z[T2], z[Q], rnd);
	mpc_add(z[A], z[T1], z[T2], rnd);
	mpc_add(z[A], z[M2], z[A], rnd);
	mpc_set_d(z[NU], h, rnd);
	mpc_mul(z[T1], z[T1], z[NU], rnd);
	mpc_set_d(z[NU], ha, rnd);
	mpc_mul(z[T2], z[T2], z[NU], rnd);
	mpc_add(z[T1], z[T1], z[T2], rnd);
	mpc_set_d(z[NU], t, rnd);
	mpc_add(z[NU], z[NU], z[T1], rnd);
	mpc_sub(z[NU], z[NU], z[E], rnd);
	mpc_mul(z[B], z[P], z[Q], rnd);
	mpc_mul_ui(z[B], z[B], 2, rnd);
	/* s_pm = sqrt(m^2 + (p +- q)^2), Z_pm = s_pm + nu, principal */
	mpc_add(z[T1], z[P], z[Q], rnd);
	mpc_sqr(z[T1], z[T1], rnd);
	mpc_add(z[T1], z[T1], z[M2], rnd);
	mpc_sqrt(z[SP], z[T1], rnd);
	mpc_sub(z[T1], z[P], z[Q], rnd);
	mpc_sqr(z[T1], z[T1], rnd);
	mpc_add(z[T1], z[T1], z[M2], rnd);
	mpc_sqrt(z[SM], z[T1], rnd);
	mpc_add(z[ZP], z[SP], z[NU], rnd);
	mpc_add(z[ZM], z[SM], z[NU], rnd);
	mpc_add(z[T2], z[SP], z[SM], rnd);
	if (mpc_cmp_si(z[ZP], 0) == 0 || mpc_cmp_si(z[ZM], 0) == 0 ||
		mpc_cmp_si(z[T2], 0) == 0)
		return XB_EDOM;
	mpc_log(z[DL], z[ZP], rnd);
	mpc_log(z[T1], z[ZM], rnd);
	mpc_sub(z[DL], z[DL], z[T1], rnd);
	mpc_sqr(z[T1], z[NU], rnd);
	mpc_sub(z[AA], z[A], z[T1], rnd);
	mpc_mul_ui(z[DZ], z[B], 2, rnd);
	mpc_div(z[DZ], z[DZ], z[T2], rnd);
	mpc_set_ui(z[C], 1, rnd);
	for (int k = 1; k < 9; k++)
		mpc_set_ui(z[C + k], 0, rnd);
	mpc_set(z[DEN], z[B], rnd);
	for (int m = 0;; m++) {
		mpc_mul(z[VAL], z[C], z[DL], rnd);
		mpc_set_ui(z[DIF], 0, rnd);
		mpc_set_ui(z[POW], 1, rnd);
		for (int k = 1; k <= 2 * m; k++) {
			mpc_mul(z[DIF], z[DIF], z[ZP], rnd);
			mpc_mul(z[T1], z[DZ], z[POW], rnd);
			mpc_add(z[DIF], z[DIF], z[T1], rnd);
			mpc_mul(z[T1], z[C + k], z[DIF], rnd);
			mpc_div_ui(z[T1], z[T1], (unsigned long)k, rnd);
			mpc_add(z[VAL], z[VAL], z[T1], rnd);
			mpc_mul(z[POW], z[POW], z[ZM], rnd);
		}
		mpc_div(z[T1], z[VAL], z[DEN], rnd);
		out[m] = mpc_get_dc(z[T1], rnd);
		if (m == order)
			return XB_OK;
		mpc_mul(z[DEN], z[DEN], z[B], rnd);
		for (int k = 2 * m + 2; k >= 0; k--) {
			if (k <= 2 * m)
				mpc_mul(z[T1], z[AA], z[C + k], rnd);
			else
				mpc_set_ui(z[T1], 0, rnd);
			if (k >= 1 && k <= 2 * m + 1) {
				mpc_mul(z[T2], z[NU], z[C + k - 1], rnd);
				mpc_mul_ui(z[T2], z[T2], 2, rnd);
				mpc_add(z[T1], z[T1], z[T2], rnd);
			}
			if (k >= 2)
				mpc_sub(z[T1], z[T1], z[C + k - 2], rnd);
			mpc_set(z[C + k], z[T1], rnd);
		}
	}
}

/* M_m(nu_beta), m = 0..order, of time ordering b with principal roots and
 * logarithms: on a certified plan every logarithm of the kernel is principal
 * (S40(e)). S22: double precision where |B| >= ratio sigma, sigma = max(|A|,
 * |nu|^2), unless 16 eps kappa > 1e-10; extended precision otherwise, with
 * (order + 1) log2(sigma/|B|) guard bits. */
static xb_status moments(const xb_model *model, xb_ws *ws, int b, double mphi,
						 double complex p, double complex q, double complex e,
						 double complex out[static 5]) {
	/* Sums grouped so that (p, q, beta) and (q, p, beta') with h_beta' = a_beta
	 * round alike: the kernel is then reciprocal to the last bit. */
	const int order = model->order;
	const double complex mm = mphi * mphi,
						 nu = model->t[b] +
							  (model->h[b] * p * p + model->a[b] * q * q) - e;
	const double complex bb = 2 * p * q, aa = mm + (p * p + q * q);
	const double complex sp = csqrt(mm + (p + q) * (p + q)),
						 sm = csqrt(mm + (p - q) * (p - q));
	const double complex zp = sp + nu, zm = sm + nu;
	if (bb == 0) {
		if (zp == 0)
			return XB_EDOM;
		for (int m = 0; m <= order; m++)
			out[m] = m % 2 ? 0 : 1 / ((m + 1) * sp * zp);
		ws->timing.moments_double++;
		return XB_OK;
	}
	/* An endpoint that rounds to zero in double precision is decided at
	 * extended precision. */
	const double ratio = cabs(bb) / fmax(cabs(aa), cabs(nu) * cabs(nu));
	double extra = 0;
	if (ratio >= model->ratio && zp != 0 && zm != 0 && sp + sm != 0) {
		const double kappa =
			closed(order, aa - nu * nu, bb, nu, 2 * bb / (sp + sm),
				   clog(zp) - clog(zm), zp, zm, out);
		if (16 * DBL_EPSILON * kappa <= 1e-10) {
			ws->timing.moments_double++;
			return XB_OK;
		}
		extra = isfinite(kappa) ? ceil(log2(kappa)) : 256;
	}
	const double bits =
		fmax(256, ceil((order + 1) * fmax(0, -log2(ratio))) + extra + 128);
	if (!(bits <= (double)XB_MAX_PREC))
		return XB_EPREC;
	const int64_t start = xb_clock();
	const xb_status status =
		closed_mp(ws->z, (mpfr_prec_t)bits, order, mphi, model->t[b],
				  model->h[b], model->a[b], p, q, e, out);
	ws->timing.moments_extended_ns += xb_clock() - start;
	ws->timing.moments_extended++;
	return status;
}

xb_status xb_ome_block(const xb_model *model, xb_ws *ws, double complex p,
					   double complex q, double complex e, int out, int in,
					   size_t n, xb_cplx v[static n], xb_cplx eta[n]) {
	const int64_t start = xb_clock(),
				  extended = ws->timing.moments_extended_ns;
	const unsigned mask = model->p.g_b == 0 ? 0 : model->order_mask[out][in];
	const double mass[2] = {model->p.m_pi, model->p.m_eta};
	double complex mom[2][4][5];
	for (int phi = 0; phi < 2; phi++)
		for (int b = 0; b < 4; b++)
			if (mask >> b & 1u) {
				const xb_status status =
					moments(model, ws, b, mass[phi], p, q, e, mom[phi][b]);
				if (status != XB_OK)
					return status;
			}
	const double scale =
		-model->p.g_b * model->p.g_b / (8 * model->p.f_pi * model->p.f_pi);
	const double complex mono[3] = {p * p, p * q, q * q};
	const int32_t nc = model->n_ch;
	for (int32_t i = 0; i < nc; i++) {
		if (out != XB_ALL_SPECIES && out != model->species[i])
			continue;
		for (int32_t j = 0; j < nc; j++) {
			if (in != XB_ALL_SPECIES && in != model->species[j])
				continue;
			const size_t at = (size_t)(i * nc + j);
			if (mask == 0 || model->pair[i][j][0] == 0) {
				v[at] = (xb_cplx){};
				if (eta != nullptr)
					eta[at] = (xb_cplx){};
				continue;
			}
			const int32_t *pair = model->pair[i][j];
			double complex sum[2] = {};
			for (int m = 0; m <= model->order; m++) {
				const double *c = model->c[i][j][m];
				const double complex cm =
					(c[0] * mono[0] + c[2] * mono[2]) + c[1] * mono[1];
				for (int phi = 0; phi < 2; phi++)
					sum[phi] += cm * (mom[phi][pair[0] - 1][m] +
									  mom[phi][pair[1] - 1][m]);
			}
			const double complex pion = 3 * scale * sum[0],
								 other = scale * sum[1] / 3;
			const double complex value = eta == nullptr ? pion + other : pion;
			v[at] = (xb_cplx){creal(value), cimag(value)};
			if (eta != nullptr)
				eta[at] = (xb_cplx){creal(other), cimag(other)};
		}
	}
	ws->timing.kernel_double_ns +=
		xb_clock() - start - (ws->timing.moments_extended_ns - extended);
	return XB_OK;
}

xb_status xb_kernel(const xb_model *model, xb_ws *ws, xb_cplx p, xb_cplx q,
					xb_cplx energy, size_t n, xb_cplx v_pi[static n],
					xb_cplx v_eta[static n]) {
	if (model == nullptr || ws == nullptr || ws->model != model ||
		n != (size_t)model->n_ch * (size_t)model->n_ch || !isfinite(p.re) ||
		!isfinite(p.im) || !isfinite(q.re) || !isfinite(q.im) ||
		!isfinite(energy.re) || !isfinite(energy.im))
		return XB_EARG;
	return xb_ome_block(model, ws, __builtin_complex(p.re, p.im),
						__builtin_complex(q.re, q.im),
						__builtin_complex(energy.re, energy.im), XB_ALL_SPECIES,
						XB_ALL_SPECIES, n, v_pi, v_eta);
}
