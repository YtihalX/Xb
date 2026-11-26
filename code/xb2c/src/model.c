/* model.c: parameters, thresholds and time orderings, the quark model and the bare
 * form factors (code/xb2c/SPEC.md, "Physics inputs and conventions"). */
#include <complex.h>
#include <float.h>
#include <math.h>
#include <pthread.h>
#include <stdckdint.h>
#include <stdlib.h>
#include <string.h>

#include <gsl/gsl_errno.h>
#include <gsl/gsl_integration.h>
#include <gsl/gsl_interp.h>
#include <gsl/gsl_odeiv2.h>
#include <mpfr.h>

#include "impl.h"
#include "tables.h"

#pragma STDC CX_LIMITED_RANGE ON

#if defined(XB_BLAS_OPENBLAS)
void openblas_set_num_threads(int n);
#elif defined(XB_BLAS_ACCELERATE)
/* <vecLib/thread_api.h>: a thread-local setting; 1 is BLAS_THREADING_SINGLE_THREADED. */
int BLASSetThreading(unsigned int threading);
#endif

/* LAPACK, Fortran convention; the trailing lengths belong to jobz and range. */
void dstevr_(const char *jobz, const char *range, const int *n, double *d, double *e,
             const double *vl, const double *vu, const int *il, const int *iu,
             const double *abstol, int *m, double *w, double *z, const int *ldz, int *isuppz,
             double *work, const int *lwork, int *iwork, const int *liwork, int *info,
             size_t jobz_len, size_t range_len);

/* The reference's coordinate solution and tail: code/HadronDynamics.jl/data/bochiEFT/
 * central.toml, [cornell], and src/common/cornell_coordinate.jl. */
constexpr int grid_n = 12000;
constexpr double grid_rmax = 30.0;
constexpr size_t interior_n = 800;
constexpr double tail_rmax = 36.0;
constexpr double tail_max_step = 0.0025;
constexpr double match_min = 8.3;
constexpr double match_width = 1.0;
constexpr double match_scan = 0.05;
constexpr double match_margin = 0.25;

static pthread_once_t once = PTHREAD_ONCE_INIT;
static xb_status init_status;

static void init(void)
{
    gsl_set_error_handler_off();
#if defined(XB_BLAS_OPENBLAS)
    openblas_set_num_threads(1);
#endif
    init_status = mpfr_buildopt_tls_p() ? XB_OK : XB_EGSL;
}

/* The one-time part runs once per process; Accelerate's BLAS setting is per thread, so every
 * call also applies it to the calling thread (model and workspace creation call this). */
xb_status xb_init(void)
{
    if (pthread_once(&once, init) != 0)
        return XB_EGSL;
#if defined(XB_BLAS_ACCELERATE)
    if (BLASSetThreading(1) != 0)
        return XB_EGSL;
#endif
    return init_status;
}

static void free_doubles(double **p) { free(*p); }
static void free_ints(int **p) { free(*p); }
static void free_model(xb_model **p) { free(*p); }
static void free_interp(gsl_interp **p)
{
    if (*p != nullptr)
        gsl_interp_free(*p);
}
static void free_table(gsl_integration_glfixed_table **p)
{
    if (*p != nullptr)
        gsl_integration_glfixed_table_free(*p);
}
static void free_driver(gsl_odeiv2_driver **p)
{
    if (*p != nullptr)
        gsl_odeiv2_driver_free(*p);
}

static bool positive(double x) { return isfinite(x) && x > 0; }

static bool valid(const xb_params p[static 1])
{
    const double dm = p->m_Bstar - p->m_B;
    const bool sector = p->sector == XB_1PP ? positive(p->mu_pv)
                                            : p->sector == XB_2PP && isnan(p->mu_pv);
    return sector && p->n_bare >= 1 && p->n_bare <= XB_MAX_BARE && p->panel_nodes >= 1
        && positive(p->m_b) && positive(p->sigma) && isfinite(p->gamma) && p->gamma <= 0
        && isfinite(p->v0) && isfinite(p->contact) && isfinite(p->g) && p->g >= 0
        && isfinite(p->g_b) && p->g_b >= 0 && positive(p->f_pi) && positive(p->cutoff)
        && positive(p->m_B) && isfinite(p->m_Bstar) && dm >= 0
        && positive(p->m_pi) && p->m_pi > dm && positive(p->m_eta) && p->m_eta > dm
        && positive(p->panel_length) && positive(p->pole_margin);
}

/* u'' = Q u for the reduced radial function with l = 1 and 2 mu = m_b. */
static double radial_q(double r, double mb, double sigma, double gamma, double e)
{
    return 2 / (r * r) + mb * (sigma * r + gamma / r - e);
}

static int radial_rhs(double r, const double y[static 2], double f[static 2], void *params)
{
    const double *c = params;
    f[0] = y[1];
    f[1] = radial_q(r, c[0], c[1], c[2], c[3]) * y[0];
    return GSL_SUCCESS;
}

/* Lowest n eigenpairs of -u''/m_b + [2/(m_b r^2) + gamma/r + sigma r] u on the sites
 * r_i = i h, u = 0 one step beyond the last: u[k][i] = u_k(r_i) with sum_i h u^2 = 1 and
 * sum_i h r_i u > 0, the sign of f_n(0). */
static xb_status eigenpairs(const xb_params p[static 1], double h, int n, double e[static n],
                            double u[static grid_n * n])
{
    [[gnu::cleanup(free_doubles)]] double *d = malloc(sizeof(double[23 * grid_n]));
    [[gnu::cleanup(free_ints)]] int *iw = malloc(sizeof(int[10 * grid_n + 2 * XB_MAX_BARE]));
    if (d == nullptr || iw == nullptr)
        return XB_ENOMEM;
    double *sub = d + grid_n, *w = sub + grid_n, *work = w + grid_n;
    const double hop = 1 / (p->m_b * h * h);
    for (int i = 0; i < grid_n; i++) {
        const double r = (i + 1) * h;
        d[i] = 2 * hop + 2 / (p->m_b * r * r) + (p->gamma / r + p->sigma * r);
        sub[i] = -hop;
    }
    const int nn = grid_n, il = 1, ldz = grid_n, lwork = 20 * grid_n, liwork = 10 * grid_n;
    const double vl = 0, vu = 0, abstol = 2 * DBL_MIN;
    int found = 0, info = 0;
    dstevr_("V", "I", &nn, d, sub, &vl, &vu, &il, &n, &abstol, &found, w, u, &ldz,
            iw + 10 * grid_n, work, &lwork, iw, &liwork, &info, 1, 1);
    if (info != 0 || found != n)
        return XB_EGSL;
    const double scale = 1 / sqrt(h);
    for (int k = 0; k < n; k++) {
        double *uk = u + (size_t)k * grid_n, phase = 0;
        for (int i = 0; i < grid_n; i++) {
            uk[i] *= scale;
            phase += (i + 1) * h * uk[i];
        }
        if (fabs(h * phase) <= 1e-14)
            return XB_EGSL;
        if (phase < 0)
            for (int i = 0; i < grid_n; i++)
                uk[i] = -uk[i];
        e[k] = w[k];
    }
    return XB_OK;
}

xb_status xb_model_create(const xb_params p[static 1], xb_model *out[static 1])
{
    *out = nullptr;
    xb_status status = xb_init();
    if (status != XB_OK)
        return status;
    if (!valid(p))
        return XB_EARG;
    const int nb = p->n_bare;
    const size_t snb = (size_t)nb;

    /* Path nodes of the longest path a plan can hold: slopes at most 1 give a length of at
     * most sqrt 2 Lambda over at most four segments. */
    const double panels = ceil(sqrt(2.0) * p->cutoff / p->panel_length) + 4;
    const int32_t n_ch = p->sector == XB_1PP ? 3 : 6;
    size_t n_q_max, dim_max;
    if (!(panels < 1e9) || ckd_mul(&n_q_max, (size_t)panels, (size_t)p->panel_nodes) || n_q_max > INT32_MAX
        || ckd_mul(&dim_max, n_q_max, (size_t)n_ch) || ckd_add(&dim_max, dim_max, (size_t)n_ch + snb))
        return XB_EARG;

    /* Quark model at V0 = 0 on the reference grid; its box puts the last site at grid_rmax. */
    const double h = grid_rmax * (1 + 1.0 / grid_n) / (grid_n + 1);
    double e[XB_MAX_BARE];
    [[gnu::cleanup(free_doubles)]] double *grid =
        malloc(sizeof(double) * ((size_t)(grid_n + 1) * 2 + (size_t)grid_n * snb));
    if (grid == nullptr)
        return XB_ENOMEM;
    double *nodes = grid, *values = nodes + grid_n + 1, *u = values + grid_n + 1;
    status = eigenpairs(p, h, nb, e, u);
    if (status != XB_OK)
        return status;
    nodes[0] = 0;
    for (int i = 0; i < grid_n; i++)
        nodes[i + 1] = (i + 1) * h;

    /* Matching radius: the first window of width match_width beyond every turning point. */
    double r_match = NAN;
    for (double x = fmax(match_min, match_width + match_scan); x <= nodes[grid_n] - match_margin;
         x += match_scan) {
        bool forbidden = true;
        for (int k = 0; k < nb; k++)
            forbidden = forbidden && radial_q(x - match_width, p->m_b, p->sigma, p->gamma, e[k]) > 0;
        if (forbidden) {
            r_match = x + match_margin;
            break;
        }
    }
    if (isnan(r_match))
        return XB_EARG;

    /* Tail grid: an even number of Simpson steps from r_match to tail_rmax, preceded by the
     * matching window of nmatch steps. */
    size_t ntail = (size_t)ceil((tail_rmax - r_match) / tail_max_step);
    ntail += ntail % 2;
    const double step = (tail_rmax - r_match) / (double)ntail;
    const size_t nmatch = (size_t)fmax(4, nearbyint(match_width / step));
    const double r_lo = r_match - (double)nmatch * step;
    const size_t nt = nmatch + ntail + 1, n_r = interior_n + ntail + 1;

    const size_t np = (size_t)p->panel_nodes;
    size_t bytes, words;
    if (ckd_mul(&words, n_r, snb + 1) || ckd_add(&words, words, 2 * np)
        || ckd_mul(&bytes, words, sizeof(double)) || ckd_add(&bytes, bytes, sizeof(xb_model)))
        return XB_ENOMEM;
    [[gnu::cleanup(free_model)]] xb_model *m = malloc(bytes);
    [[gnu::cleanup(free_doubles)]] double *tmp = malloc(sizeof(double) * (2 * nt + 2 * n_r));
    [[gnu::cleanup(free_interp)]] gsl_interp *lin = gsl_interp_alloc(gsl_interp_linear, grid_n + 1);
    [[gnu::cleanup(free_table)]] gsl_integration_glfixed_table *gl =
        gsl_integration_glfixed_table_alloc(interior_n);
    [[gnu::cleanup(free_table)]] gsl_integration_glfixed_table *panel =
        gsl_integration_glfixed_table_alloc(np);
    if (m == nullptr || tmp == nullptr || lin == nullptr || gl == nullptr || panel == nullptr)
        return XB_ENOMEM;
    double *r = m->data, *wf = m->data + n_r, *rule = wf + n_r * snb;
    double *r_tail = tmp, *tail = r_tail + nt, *qw = tail + nt, *col = qw + n_r;
    m->n_r = n_r;
    m->gl = rule;
    for (size_t i = 0; i < np; i++)
        if (gsl_integration_glfixed_point(-1, 1, i, &rule[i], &rule[np + i], panel) != GSL_SUCCESS)
            return XB_EGSL;

    /* Radial quadrature: Gauss–Legendre on [0, r_match], composite Simpson on the tail. */
    for (size_t i = 0; i < interior_n; i++)
        if (gsl_integration_glfixed_point(0, r_match, i, &r[i], &qw[i], gl) != GSL_SUCCESS)
            return XB_EGSL;
    for (size_t i = 0; i < nt; i++)
        r_tail[i] = i + 1 == nt ? tail_rmax : r_lo + (double)i * ((tail_rmax - r_lo) / (double)(nt - 1));
    for (size_t i = 0; i <= ntail; i++) {
        r[interior_n + i] = r_tail[nmatch + i];
        qw[interior_n + i] = step / 3 * (i == 0 || i == ntail ? 1 : i % 2 ? 4 : 2);
    }

    const double m_th = p->sector == XB_1PP ? p->m_B + p->m_Bstar : 2 * p->m_Bstar;
    for (int k = 0; k < nb; k++) {
        const double *uk = u + (size_t)k * grid_n;
        /* Interior: R = u/r, linear between the sites, R(0) = 0. */
        values[0] = 0;
        for (int i = 0; i < grid_n; i++)
            values[i + 1] = uk[i] / nodes[i + 1];
        if (gsl_interp_init(lin, nodes, values, (size_t)grid_n + 1) != GSL_SUCCESS)
            return XB_EGSL;
        for (size_t i = 0; i < interior_n; i++)
            col[i] = gsl_interp_eval(lin, nodes, values, r[i], nullptr);

        /* Decaying tail: GSL's ODE solver inward from tail_rmax, WKB log-derivative there. */
        double c[4] = {p->m_b, p->sigma, p->gamma, e[k]};
        const gsl_odeiv2_system sys = {radial_rhs, nullptr, 2, c};
        [[gnu::cleanup(free_driver)]] gsl_odeiv2_driver *ode =
            gsl_odeiv2_driver_alloc_y_new(&sys, gsl_odeiv2_step_rk8pd, -step, 0, 1e-12);
        if (ode == nullptr)
            return XB_ENOMEM;
        const double q0 = radial_q(tail_rmax, p->m_b, p->sigma, p->gamma, e[k]);
        const double dq0 = -4 / (tail_rmax * tail_rmax * tail_rmax)
                         + p->m_b * (p->sigma - p->gamma / (tail_rmax * tail_rmax));
        double y[2] = {1, -sqrt(q0) - dq0 / (4 * q0)}, at = tail_rmax;
        tail[nt - 1] = 1;
        for (size_t i = nt - 1; i-- > 0;) {
            if (radial_q(r_tail[i], p->m_b, p->sigma, p->gamma, e[k]) <= 0)
                return XB_EARG;
            if (gsl_odeiv2_driver_apply(ode, &at, r_tail[i], y) != GSL_SUCCESS)
                return XB_EGSL;
            tail[i] = y[0];
        }

        /* Least-squares scale of the tail against u on the matching window. */
        for (int i = 0; i < grid_n; i++)
            values[i + 1] = uk[i];
        if (gsl_interp_init(lin, nodes, values, (size_t)grid_n + 1) != GSL_SUCCESS)
            return XB_EGSL;
        double tt = 0, tu = 0, uu = 0;
        for (size_t i = 0; i <= nmatch; i++) {
            const double ui = gsl_interp_eval(lin, nodes, values, r_tail[i], nullptr);
            tt += tail[i] * tail[i];
            tu += tail[i] * ui;
            uu += ui * ui;
        }
        const double scale = tu / tt;
        if (!isfinite(scale) || scale == 0)
            return XB_EGSL;
        double res = 0;
        for (size_t i = 0; i <= nmatch; i++) {
            const double d = scale * tail[i] - gsl_interp_eval(lin, nodes, values, r_tail[i], nullptr);
            res += d * d;
        }
        m->bare[k].tail_residual = sqrt(res) / fmax(sqrt(uu), 1e-14);
        for (size_t i = 0; i <= ntail; i++)
            col[interior_n + i] = scale * tail[nmatch + i] / r_tail[nmatch + i];

        /* One normalisation of interior and tail together, then the weights of
         * f_n(q) = sqrt(4 pi) int r^2 j0(q r) R_n(r) dr. */
        double norm = 0, check = 0;
        for (size_t i = 0; i < n_r; i++)
            norm += qw[i] * r[i] * r[i] * col[i] * col[i];
        if (!isfinite(norm) || !(norm > 0))
            return XB_EGSL;
        const double inv = 1 / sqrt(norm);
        for (size_t i = 0; i < n_r; i++) {
            col[i] *= inv;
            check += qw[i] * r[i] * r[i] * col[i] * col[i];
            wf[i * snb + (size_t)k] = sqrt(4 * xb_pi) * qw[i] * r[i] * r[i] * col[i];
        }
        m->bare[k].norm_residual = fabs(check - 1);
        m->bare[k].reference_mass = 2 * p->m_b + e[k];
        m->bare[k].energy = m->bare[k].reference_mass + p->v0 - m_th;
    }

    /* Channels, thresholds and the time orderings of note 07, S2. */
    const bool one = p->sector == XB_1PP;
    const double dm = p->m_Bstar - p->m_B;
    m->p = *p;
    m->n_ch = n_ch;
    m->s_ch = one ? 0 : 2;
    m->order = one ? 3 : 4;
    m->ratio = one ? 0.06 : 0.3;
    m->n_q_max = n_q_max;
    m->dim_max = dim_max;
    const int32_t species[2][6] = {{XB_PV, XB_PV, XB_VV}, {XB_PP, XB_PV, XB_VV, XB_VV, XB_VV, XB_VV}};
    memcpy(m->species, species[!one], sizeof m->species);
    const double delta[2][3] = {{NAN, 0, dm}, {-2 * dm, -dm, 0}};
    const double mu[2][3] = {{NAN, p->mu_pv, p->m_Bstar / 2},
                             {p->m_B / 2, p->m_B * p->m_Bstar / (p->m_B + p->m_Bstar), p->m_Bstar / 2}};
    const double t[2][4] = {{-dm, dm, 0, 0}, {-2 * dm, 0, -dm, -dm}};
    memcpy(m->delta, delta[!one], sizeof m->delta);
    memcpy(m->mu, mu[!one], sizeof m->mu);
    memcpy(m->t, t[!one], sizeof m->t);
    const double hp = 1 / (2 * p->m_B), hv = 1 / (2 * p->m_Bstar);
    memcpy(m->h, (double[4]){hp, hv, hv, hp}, sizeof m->h);
    memcpy(m->a, (double[4]){hp, hv, hp, hv}, sizeof m->a);
    memset(m->c, 0, sizeof m->c);
    memset(m->pair, 0, sizeof m->pair);
    memset(m->order_mask, 0, sizeof m->order_mask);
    for (int32_t i = 0; i < n_ch; i++)
        for (int32_t j = 0; j < n_ch; j++) {
            memcpy(m->c[i][j], one ? xb_spin_1pp[i][j] : xb_spin_2pp[i][j], sizeof m->c[i][j]);
            for (int s = 0; s < 2; s++)
                m->pair[i][j][s] = one ? xb_order_1pp[i][j][s] : xb_order_2pp[i][j][s];
            const int32_t *pair = m->pair[i][j];
            if (pair[0] != 0) {
                const unsigned mask = 1u << (pair[0] - 1) | 1u << (pair[1] - 1);
                const int outgoing = m->species[i], incoming = m->species[j];
                m->order_mask[outgoing][incoming] |= mask;
                m->order_mask[outgoing][XB_ALL_SPECIES] |= mask;
                m->order_mask[XB_ALL_SPECIES][incoming] |= mask;
                m->order_mask[XB_ALL_SPECIES][XB_ALL_SPECIES] |= mask;
            }
        }
    for (int k = nb; k < XB_MAX_BARE; k++)
        m->bare[k] = (xb_bare){NAN, NAN, NAN, NAN};

    *out = m;
    m = nullptr;
    return XB_OK;
}

void xb_model_destroy(xb_model *model)
{
    free(model);
}

xb_status xb_model_info(const xb_model *model, xb_info info[static 1])
{
    if (model == nullptr)
        return XB_EARG;
    *info = (xb_info){.n_channels = model->n_ch, .n_bare = model->p.n_bare};
    memcpy(info->threshold, model->delta, sizeof info->threshold);
    memcpy(info->reduced_mass, model->mu, sizeof info->reduced_mass);
    memcpy(info->bare, model->bare, sizeof info->bare);
    return XB_OK;
}

void xb_form_factors(const xb_model *model, double complex q, size_t n, double complex f[static n])
{
    const size_t nb = (size_t)model->p.n_bare;
    const double *r = model->data, *w = model->data + model->n_r;
    for (size_t j = 0; j < n; j++)
        f[j] = 0;
    for (size_t k = 0; k < model->n_r; k++, w += nb) {
        const double complex z = q * r[k];
        const double complex j0 = cabs(z) < 1e-3 ? 1 - z * z / 6 * (1 - z * z / 20) : csin(z) / z;
        for (size_t j = 0; j < n; j++)
            f[j] += w[j] * j0;
    }
}
