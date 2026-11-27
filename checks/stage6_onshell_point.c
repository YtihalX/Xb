/* Stage 6, note 06 eq:Dflip: from code/xb2c, run
 *   zig build check-onshell-point -Doptimize=ReleaseFast
 * Shares the OME kernel and bare-state input with xb2c, but not the path grid,
 * SP weights, or matrix assembly. F = BB or (BB, BB*); only VV(5S2) has the
 * contact and bare exchange. All momenta and energies are in GeV. */
#include "impl.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include <gsl/gsl_integration.h>
#include <gsl/gsl_linalg.h>

#pragma STDC CX_LIMITED_RANGE ON

enum { nc = 6, vv_s = 2, nb = 4, max_flip = 2, edges_max = 2 + 3 * max_flip };

/* Pinned baseline of config/search-2pp.zon, not the shallow fit. */
static constexpr xb_params baseline = {
    .sector = XB_2PP, .n_bare = nb, .panel_nodes = 16,
    .m_b = 4.534047672900046, .sigma = 0.19840639309997352, .gamma = -0.434,
    .v0 = 0.3714694358359325, .contact = -16.26782020427067,
    .g = 0.05715476066494084, .g_b = 0.56, .f_pi = 0.0922,
    .cutoff = 4.0, .m_B = 5.27952, .m_Bstar = 5.32475,
    .m_pi = 0.138039407, .m_eta = 0.548, .mu_pv = NAN,
    .panel_length = 0.25, .pole_margin = 0.05,
};

typedef struct probe {
  const char *name;
  xb_cplx energy;
  xb_rect rect;
  size_t nf;
  bool bent;
} probe;

static const probe probes[] = {
    {"lower (-,+,+)", {-0.06785, -0.010}, {-0.06795, -0.06775, -0.0101, -0.0099}, 1, false},
    {"upper (-,-,+)", {-0.02262, -0.010}, {-0.02272, -0.02252, -0.0101, -0.0099}, 2, false},
    /* The centre of the BB kernel-window fixture in test/fixtures.zig. */
    {"bent  (-,+,+)", {-0.07746, -0.00825}, {-0.08046, -0.07446, -0.016, -0.0005}, 1, true},
};

typedef struct kinematics {
  double delta[3], mu[3];
  double complex k[max_flip];
} kinematics;

typedef struct real_node {
  double q;
  double complex weight[3], f[nb];
} real_node;

typedef struct result {
  double complex sp, on_shell;
  double depth, z_min;
  size_t real_nodes;
  int32_t path_nodes;
} result;

static void ok(int status, const char *step) {
  if (status != 0) {
    fprintf(stderr, "FAIL %s (status %d)\n", step, status);
    exit(EXIT_FAILURE);
  }
}

static inline double complex cx(xb_cplx z) {
  return __builtin_complex(z.re, z.im);
}

static inline size_t species(size_t channel) {
  return channel < 2 ? channel : 2;
}

static kinematics momenta(const probe *p) {
  const double m = baseline.m_B, ms = baseline.m_Bstar, dm = ms - m;
  kinematics k = {.delta = {-2 * dm, -dm, 0}, .mu = {m / 2, m * ms / (m + ms), ms / 2}};
  const double complex e = cx(p->energy);
  ok(!(cimag(e) < 0 && k.delta[p->nf - 1] < creal(e) && creal(e) < k.delta[p->nf]),
     "probe must be below the axis in its adjacent strip");
  for (size_t s = 0; s < p->nf; s++) {
    k.k[s] = csqrt(2 * k.mu[s] * (e - k.delta[s]));
    ok(!(cabs(k.k[s]) < baseline.cutoff), "external momentum inside cutoff");
  }
  return k;
}

/* Throughout the strip between the paths, and at each external k_F,
 * Re q >= |Im q| and -b <= Im q <= 0. Thus Re(p+q)^2 >= 0 and
 * Re(p-q)^2 >= -b^2. Re nu >= -2 (m_B* - m_B) - Re E because recoils
 * are nonnegative. This bounds both square roots and TOPT logs, including
 * the fixed external legs, over the entire homotopy at this E. Closed
 * unflipped propagator poles lie outside the wedge; no residue for them. */
static double kernel_margin(const probe *p, const kinematics *k, xb_cert cert) {
  ok(!(cert.slope <= 1 && (cert.depth > 0) == p->bent), "path geometry for this probe");
  double b = cert.depth;
  for (size_t s = 0; s < p->nf; s++)
    b = fmax(b, -cimag(k->k[s]));
  const double mpi = baseline.m_pi;
  ok(!(b < mpi), "exchanged-meson window of the real-momentum route");
  const double z = sqrt(mpi * mpi - b * b) + k->delta[0] - p->energy.re;
  ok(!(z > 0), "TOPT log window of the real-momentum route");
  return z;
}

static int cmp_edge(const void *lhs, const void *rhs) {
  const double a = *(const double *)lhs, b = *(const double *)rhs;
  return (a > b) - (a < b);
}

/* Independent real grid: break at x_F and x_F +/- 2|Im k_F| to resolve the
 * narrow free denominator by ordinary quadrature, not by subtraction. */
static real_node *real_grid(const xb_model *model, const probe *p,
                            const kinematics *k, size_t order, size_t *nq) {
  double edges[edges_max] = {0, baseline.cutoff};
  size_t n_edges = 2;
  for (size_t s = 0; s < p->nf; s++) {
    const double x = creal(k->k[s]), width = -2 * cimag(k->k[s]);
    edges[n_edges++] = fmax(0, x - width);
    edges[n_edges++] = x;
    edges[n_edges++] = fmin(baseline.cutoff, x + width);
  }
  qsort(edges, n_edges, sizeof edges[0], cmp_edge);
  size_t pieces[edges_max - 1], n_panels = 0;
  for (size_t i = 0; i + 1 < n_edges; i++) {
    pieces[i] = (size_t)ceil((edges[i + 1] - edges[i]) / 0.4);
    n_panels += pieces[i];
  }
  *nq = n_panels * order;
  real_node *nodes = malloc(*nq * sizeof *nodes);
  gsl_integration_glfixed_table *rule = gsl_integration_glfixed_table_alloc(order);
  ok(nodes == nullptr || rule == nullptr, "real quadrature allocation");
  const double complex e = cx(p->energy);
  size_t j = 0;
  for (size_t i = 0; i + 1 < n_edges; i++) {
    if (pieces[i] == 0)
      continue;
    const double step = (edges[i + 1] - edges[i]) / (double)pieces[i];
    for (size_t l = 0; l < pieces[i]; l++) {
      const double lo = edges[i] + (double)l * step;
      const double hi = l + 1 == pieces[i] ? edges[i + 1] : lo + step;
      for (size_t n = 0; n < order; n++, j++) {
        double q = 0, w = 0;
        ok(gsl_integration_glfixed_point(lo, hi, n, &q, &w, rule), "real quadrature node");
        nodes[j].q = q;
        const double qq = q * q, radial = w * qq / (2 * xb_pi * xb_pi);
        for (size_t s = 0; s < 3; s++)
          nodes[j].weight[s] = radial / (qq / (2 * k->mu[s]) + k->delta[s] - e);
        xb_form_factors(model, q, nb, nodes[j].f);
      }
    }
  }
  gsl_integration_glfixed_table_free(rule);
  return nodes;
}

/* Solve A_0 X = V_QF, A_0 = 1 + V_QQ G_0. Q contains only real grid points.
 * T_FF = V_FF - V_FQ G_0 X, using the transpose (not adjoint) of V_QF.
 * The bare term is inserted as g^2 f_n(p) f_n(q)/(E - epsilon_n), not as
 * augmented rows. Multiply det A_0 by the bare gaps for the same D~ convention. */
static double complex real_route(const xb_model *model, xb_ws *ws, const probe *p,
                                 const kinematics *k, const xb_info *info,
                                 size_t order, size_t *n_real) {
  size_t nq = 0;
  real_node *nodes = real_grid(model, p, k, order, &nq);
  *n_real = nq;
  const size_t dim = nq * nc, nf = p->nf;
  const double complex e = cx(p->energy);
  gsl_matrix_complex *a = gsl_matrix_complex_alloc(dim, dim);
  gsl_permutation *perm = gsl_permutation_alloc(dim);
  gsl_vector_complex *x = gsl_vector_complex_alloc(dim);
  double complex (*source)[dim] = malloc(nf * sizeof *source);
  ok(a == nullptr || perm == nullptr || x == nullptr || source == nullptr, "reference LU allocation");

  double complex log_bare = 0, coeff[nb];
  for (size_t n = 0; n < nb; n++) {
    const double complex gap = e - info->bare[n].energy;
    coeff[n] = baseline.g * baseline.g / gap;
    log_bare += clog(gap);
  }
  xb_cplx v[nc * nc];
  for (size_t i = 0; i < nq; i++) {
    for (size_t j = i; j < nq; j++) {
      ok(xb_ome_block(model, ws, nodes[i].q, nodes[j].q, e,
                      XB_ALL_SPECIES, XB_ALL_SPECIES, nc * nc, v, nullptr), "V_QQ");
      double complex separable = baseline.contact;
      for (size_t n = 0; n < nb; n++)
        separable += coeff[n] * nodes[i].f[n] * nodes[j].f[n];
      for (size_t r = 0; r < nc; r++)
        for (size_t c = 0; c < nc; c++) {
          const double complex val = cx(v[nc * r + c]) + (r == vv_s && c == vv_s ? separable : 0);
          const size_t ir = nc * i + r, jc = nc * j + c;
          gsl_matrix_complex_set(a, ir, jc, val * nodes[j].weight[species(c)] + (ir == jc));
          if (i != j)
            gsl_matrix_complex_set(a, jc, ir, val * nodes[i].weight[species(r)]);
        }
    }
    for (size_t s = 0; s < nf; s++) {
      ok(xb_ome_block(model, ws, nodes[i].q, k->k[s], e,
                      XB_ALL_SPECIES, (int)s, nc * nc, v, nullptr), "V_QF");
      for (size_t r = 0; r < nc; r++)
        source[s][nc * i + r] = cx(v[nc * r + s]);
    }
  }
  int sign = 0;
  ok(gsl_linalg_complex_LU_decomp(a, perm, &sign), "real determinant LU");
  const double complex log_real = gsl_linalg_complex_LU_lndet(a) +
      I * carg(gsl_linalg_complex_LU_sgndet(a, sign)) + log_bare;

  double complex update[max_flip][max_flip];
  for (size_t s = 0; s < nf; s++) {
    const gsl_vector_complex_const_view b = gsl_vector_complex_const_view_array((const double *)source[s], dim);
    ok(gsl_linalg_complex_LU_solve(a, perm, &b.vector, x), "real half-on-shell solve");
    for (size_t r = 0; r < nf; r++) {
      ok(xb_ome_block(model, ws, k->k[r], k->k[s], e,
                      (int)r, (int)s, nc * nc, v, nullptr), "V_FF");
      double complex t = cx(v[nc * r + s]);
      for (size_t j = 0; j < nq; j++)
        for (size_t c = 0; c < nc; c++) {
          const size_t jc = nc * j + c;
          t -= source[r][jc] * nodes[j].weight[species(c)] * gsl_vector_complex_get(x, jc);
        }
      /* Note 06: I + 2i rho_F T_FF, rho_r = mu_r k_r / (2 pi). */
      update[r][s] = (r == s) + (I / xb_pi) * k->mu[r] * k->k[r] * t;
    }
  }
  double complex det_update = update[0][0];
  if (nf == 2)
    det_update = det_update * update[1][1] - update[0][1] * update[1][0];
  free(source);
  gsl_vector_complex_free(x);
  gsl_permutation_free(perm);
  gsl_matrix_complex_free(a);
  free(nodes);
  return log_real + clog(det_update);
}

static void run_rule(int32_t sp_order, size_t real_order, result results[static _Countof(probes)]) {
  xb_params params = baseline;
  params.panel_nodes = sp_order;
  xb_model *model = nullptr;
  xb_ws *ws = nullptr;
  xb_info info;
  size_t plan_size = 0;
  ok(xb_model_create(&params, &model), "baseline model");
  ok(xb_model_info(model, &info), "bare inputs");
  ok(xb_ws_create(model, &ws), "solver workspace");
  ok(xb_plan_size(model, &plan_size), "plan size");
  xb_plan *plan = malloc(plan_size);
  ok(plan == nullptr, "plan allocation");
  for (size_t i = 0; i < _Countof(probes); i++) {
    const probe *p = &probes[i];
    const kinematics k = momenta(p);
    const xb_sheet sheet = {.pp = -1, .pv = p->nf == 2 ? -1 : 1, .vv = 1};
    xb_cert cert;
    ok(xb_certify(model, p->rect, sheet, XB_PATH_S40, plan, &cert), "S40 plan");
    ok(cert.failed, "S40 certificate");
    for (size_t s = 0; s < 3; s++)
      ok(cert.node[s] != (s < p->nf), "probe uses just the open-channel nodes");
    result *out = &results[i];
    out->depth = cert.depth;
    out->z_min = kernel_margin(p, &k, cert);
    out->path_nodes = cert.n_path;
    xb_cplx log_det;
    ok(xb_det(model, ws, plan, p->energy, &log_det, 0, nullptr), "S40 determinant");
    out->sp = cx(log_det);
    out->on_shell = real_route(model, ws, p, &k, &info, real_order, &out->real_nodes);
  }
  free(plan);
  xb_ws_destroy(ws);
  xb_model_destroy(model);
}

/* |exp(log_a - log_b) - 1|, without cancellation at a small log difference
 * or a false mismatch at a wrap of the determinant's phase. */
static double drift(double complex log_a, double complex log_b) {
  const double a = creal(log_a) - creal(log_b), b = cimag(log_a) - cimag(log_b);
  return hypot(expm1(a), 2 * exp(a / 2) * sin(b / 2));
}

int main(void) {
  result coarse[_Countof(probes)], fine[_Countof(probes)];
  run_rule(16, 16, coarse);
  run_rule(32, 24, fine);
  bool failed = false;
  for (size_t i = 0; i < _Countof(probes); i++) {
    const result c = coarse[i], f = fine[i];
    const double r_drift = drift(c.on_shell, f.on_shell), sp_drift = drift(c.sp, f.sp);
    /* Empirical error allowance from both refinements, with an LU roundoff
     * floor. Require convergence separately so a bad grid can't raise the bar. */
    const double bar = fmax(1e-10, 4 * (r_drift + sp_drift));
    const double mismatch = drift(c.sp, f.on_shell), fine_mismatch = drift(f.sp, f.on_shell);
    const bool pass = c.depth == f.depth && r_drift <= 1e-7 && sp_drift <= 1e-7 &&
                      mismatch <= bar && fine_mismatch <= bar;
    printf("%s %s E=(%.2f,%+.2f) MeV H=%.2f MeV Re Z>=%.2f MeV; "
           "S40 %d->%d nodes drift=%.3e; real %zu->%zu nodes drift=%.3e; "
           "mismatch=%.3e refined=%.3e bar=%.3e\n",
           pass ? "PASS" : "FAIL", probes[i].name, 1e3 * probes[i].energy.re,
           1e3 * probes[i].energy.im, 1e3 * c.depth, 1e3 * c.z_min,
           c.path_nodes, f.path_nodes, sp_drift, c.real_nodes, f.real_nodes, r_drift,
           mismatch, fine_mismatch, bar);
    failed |= !pass;
  }
  return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}
