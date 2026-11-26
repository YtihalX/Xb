/* lse.c: paths, on-shell nodes and their certificates, the free loops, the matrix of the
 * continued equation, D~ from its LU factors, and the refinement of a zero
 * (notes/07-continued-lse.tex, S9, S40, S41). */
#include <complex.h>
#include <float.h>
#include <math.h>
#include <stdckdint.h>
#include <stdlib.h>
#include <string.h>

#include <gsl/gsl_errno.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_multiroots.h>
#include <gsl/gsl_permutation.h>

#include "impl.h"

#pragma STDC CX_LIMITED_RANGE ON

constexpr uint64_t plan_magic = 0x786232632d706c6eULL; /* "xb2c-pln" */
/* The certificate's constants, as code/Xb2Continuation/src/sp_contours.jl sets them. */
constexpr size_t n_sub = 8;         /* energy sub-cells per rectangle side */
constexpr double r_near = 0.1;      /* GeV: an unflipped pole nearer the path gets an optional node */
constexpr double q_spacing = 0.001; /* GeV: (C5) is bounded on path pieces at most this long */
constexpr double q_floor = 1e-5;    /* GeV: an inconclusive piece is bisected down to this length */
/* Empirical near-node trigger (SPEC.md, "Removable 0/0"): |k - q_j| < node_gap |w_j q_j|. */
constexpr double node_gap = 0.01; /* GeV^-1 */

struct xb_plan {
    uint64_t magic;           /* plan_magic once certified */
    const xb_model *model;    /* the model the plan was certified for */
    xb_rect rect;
    int8_t flip[3];           /* 1 where the plan's sheet flips the threshold */
    xb_cert cert;
    size_t n_q;               /* path nodes */
    size_t n_vertex;
    double complex vertex[5]; /* the path's corners, 0 first and Lambda last */
    double complex data[];    /* q[n_q], w[n_q], f[n_q][n_bare] */
};

static void free_ws(xb_ws **p) { free(*p); }
static void free_solver(gsl_multiroot_fsolver **p)
{
    if (*p != nullptr)
        gsl_multiroot_fsolver_free(*p);
}

xb_status xb_ws_create(const xb_model *model, xb_ws *out[static 1])
{
    *out = nullptr;
    if (model == nullptr)
        return XB_EARG;
    const xb_status status = xb_init();
    if (status != XB_OK)
        return status;
    /* g holds one G per matrix column; b one right-hand side per channel (the on-shell T) or
     * per column of F (J^_C: the bare vertices and the contact term). */
    const size_t dim = model->dim_max, nc = (size_t)model->n_ch, nf = (size_t)model->p.n_bare + 1;
    const size_t rhs = nc > nf ? nc : nf;
    size_t cells, extra, bytes, perm;
    if (ckd_mul(&cells, dim, dim) || ckd_mul(&extra, rhs + 1, dim) || ckd_add(&cells, cells, extra)
        || ckd_mul(&bytes, cells, sizeof(double complex)) || ckd_mul(&perm, dim, sizeof(size_t))
        || ckd_add(&bytes, bytes, perm) || ckd_add(&bytes, bytes, sizeof(xb_ws)))
        return XB_ENOMEM;
    [[gnu::cleanup(free_ws)]] xb_ws *ws = malloc(bytes);
    if (ws == nullptr)
        return XB_ENOMEM;
    ws->model = model;
    ws->g = ws->a + dim * dim;
    ws->b = ws->g + dim;
    ws->perm = (size_t *)(ws->b + rhs * dim);
    /* Extended-precision temporaries at the largest precision, and MPFR's thread-local
     * constants cached at it, so that a moment evaluation only resets precisions. */
    for (int i = 0; i < XB_MP; i++)
        mpc_init2(ws->z[i], XB_MAX_PREC);
    mpfr_const_pi(mpc_realref(ws->z[0]), MPFR_RNDN);
    mpfr_const_log2(mpc_realref(ws->z[0]), MPFR_RNDN);
    *out = ws;
    ws = nullptr;
    return XB_OK;
}

void xb_ws_destroy(xb_ws *ws)
{
    if (ws == nullptr)
        return;
    for (int i = 0; i < XB_MP; i++)
        mpc_clear(ws->z[i]);
    free(ws);
    mpfr_free_cache2(MPFR_FREE_LOCAL_CACHE);
}

xb_status xb_plan_size(const xb_model *model, size_t size[static 1])
{
    if (model == nullptr)
        return XB_EARG;
    size_t cells, bytes;
    if (ckd_mul(&cells, model->n_q_max, (size_t)model->p.n_bare + 2)
        || ckd_mul(&bytes, cells, sizeof(double complex)) || ckd_add(&bytes, bytes, sizeof(xb_plan)))
        return XB_ENOMEM;
    *size = bytes;
    return XB_OK;
}

static double segment_distance(double complex a, double complex b, double complex q)
{
    const double complex v = b - a;
    const double t = fmin(1, fmax(0, creal((q - a) * conj(v)) / (creal(v) * creal(v) + cimag(v) * cimag(v))));
    return cabs(q - (a + t * v));
}

/* Distance from the box [x0, x1] x [y0, y1] to the segment ab, zero where they meet: for
 * disjoint convex sets it is attained at an endpoint of one or a corner of the other. */
static double box_distance(double complex a, double complex b, double x0, double x1, double y0, double y1)
{
    const double ax = creal(a), ay = cimag(a), dx = creal(b) - ax, dy = cimag(b) - ay;
    const double p[4] = {-dx, dx, -dy, dy}, s[4] = {ax - x0, x1 - ax, ay - y0, y1 - ay};
    double t0 = 0, t1 = 1;
    bool meets = true;
    for (int k = 0; k < 4 && meets; k++)
        if (p[k] == 0)
            meets = s[k] >= 0;
        else {
            const double r = s[k] / p[k];
            if (p[k] < 0)
                t0 = fmax(t0, r);
            else
                t1 = fmin(t1, r);
            meets = t0 <= t1;
        }
    if (meets)
        return 0;
    double d = INFINITY;
    for (int k = 0; k < 2; k++) {
        const double ex = k ? creal(b) : ax, ey = k ? cimag(b) : ay;
        d = fmin(d, hypot(fmax(fmax(x0 - ex, 0), ex - x1), fmax(fmax(y0 - ey, 0), ey - y1)));
    }
    for (int k = 0; k < 4; k++)
        d = fmin(d, segment_distance(a, b, __builtin_complex(k & 1 ? x1 : x0, k & 2 ? y1 : y0)));
    return d;
}

/* (C3) for the paths without nodes: a lower bound of the distance from the path of the
 * poles q = +-k_a, k_a^2 = 2 mu (E - delta), over every energy of a physical-sheet rectangle
 * below the threshold. With Re E < delta, w = 2 mu (delta - E) has Re w > 0 and the poles
 * are -+i sqrt(w); per energy sub-cell the lower one, v - iu with u + iv = sqrt(w), lies in a
 * box below the real axis with a corner at Re q <= 0, outside the region between [0, Lambda]
 * and the path, so a positive distance also places the whole box outside that region. The
 * upper pole is at least u from any path in the closed lower half plane. */
static double pole_margin(size_t n, const double complex v[static n], xb_rect rect, double delta, double mu)
{
    if (!(rect.re_hi < delta))
        return 0;
    double margin = INFINITY;
    const double dx = (rect.re_hi - rect.re_lo) / n_sub, dy = (rect.im_hi - rect.im_lo) / n_sub;
    for (size_t i = 0; i < n_sub; i++)
        for (size_t j = 0; j < n_sub; j++) {
            const double re_lo = rect.re_lo + (double)i * dx, re_hi = i + 1 == n_sub ? rect.re_hi : re_lo + dx;
            const double im_lo = rect.im_lo + (double)j * dy, im_hi = j + 1 == n_sub ? rect.im_hi : im_lo + dy;
            const double wr_lo = 2 * mu * (delta - re_hi), wr_hi = 2 * mu * (delta - re_lo);
            const double wi = 2 * mu * fmax(fabs(im_lo), fabs(im_hi));
            const double u_lo = sqrt(wr_lo), u_hi = sqrt((hypot(wr_hi, wi) + wr_hi) / 2);
            const double v_hi = wi / (2 * u_lo);
            double d = u_lo;
            for (size_t k = 0; k + 1 < n; k++)
                d = fmin(d, box_distance(v[k], v[k + 1], -v_hi, v_hi, -u_hi, -u_lo));
            margin = fmin(margin, d - 64 * DBL_EPSILON * fmax(1, u_hi + cabs(v[n - 1])));
        }
    return margin;
}

static double path_distance(size_t n, const double complex v[static n], double complex q)
{
    double d = INFINITY;
    for (size_t i = 0; i + 1 < n; i++)
        d = fmin(d, segment_distance(v[i], v[i + 1], q));
    return d;
}

/* The largest slope of a graph path, +inf where two vertices share a real part. */
static double path_slope(size_t n, const double complex v[static n])
{
    double slope = 0;
    for (size_t i = 0; i + 1 < n; i++) {
        const double dx = creal(v[i + 1] - v[i]);
        slope = fmax(slope, dx > 0 ? fabs(cimag(v[i + 1] - v[i])) / dx : INFINITY);
    }
    return slope;
}

/* The height h(x) of a graph path, 0 outside [0, Lambda]. */
static double height(size_t n, const double complex v[static n], double x)
{
    if (!(0 <= x && x <= creal(v[n - 1])))
        return 0;
    size_t j = 0;
    while (j + 2 < n && creal(v[j + 1]) <= x)
        j++;
    return cimag(v[j]) + (x - creal(v[j])) * cimag(v[j + 1] - v[j]) / creal(v[j + 1] - v[j]);
}

/* k^2 = 2 mu (E - delta) of a threshold with Im 0 kept as -0, the limit from below on the
 * real axis: its principal root k lies in the closed fourth quadrant. */
static double complex k_squared(double re, double im, double delta, double mu)
{
    return __builtin_complex(2 * mu * (re - delta), im == 0 ? -0.0 : 2 * mu * im);
}

/* Outward-rounded interval arithmetic of the certificate; up and down step to the
 * neighbouring double, as Julia's nextfloat and prevfloat. */
typedef struct ivl { double lo, hi; } ivl;

static inline double up(double x)
{
    if (!(x < INFINITY))
        return x;
    if (x == 0)
        return 0x1p-1074;
    uint64_t u;
    memcpy(&u, &x, sizeof u);
    u = x > 0 ? u + 1 : u - 1;
    memcpy(&x, &u, sizeof x);
    return x;
}

static inline double down(double x) { return -up(-x); }
static inline ivl out(double lo, double hi) { return (ivl){.lo = down(lo), .hi = up(hi)}; }
static inline double absmax(ivl a) { return fmax(fabs(a.lo), fabs(a.hi)); }
static inline double absmin(ivl a) { return a.lo <= 0 && 0 <= a.hi ? 0 : fmin(fabs(a.lo), fabs(a.hi)); }
static inline ivl add(ivl a, ivl b) { return out(a.lo + b.lo, a.hi + b.hi); }
static inline ivl sub(ivl a, ivl b) { return out(a.lo - b.hi, a.hi - b.lo); }
static inline ivl mul(double c, ivl a) { return c >= 0 ? out(c * a.lo, c * a.hi) : out(c * a.hi, c * a.lo); }

static inline ivl sqr(ivl a)
{
    const double l = a.lo * a.lo, h = a.hi * a.hi;
    return out(a.lo <= 0 && 0 <= a.hi ? 0 : fmin(l, h), fmax(l, h));
}

/* A value assembled outside the primitive operations (a root, a distance, an interpolated
 * height) is widened by 64 eps times its scale. */
static inline ivl pad(double lo, double hi, double scale)
{
    const double e = up(64 * DBL_EPSILON * fmax(1, scale));
    return out(lo - e, hi + e);
}

/* A box of momenta over one energy cell: a node momentum k (graph false; Re k^2 =
 * mu2 (Re E - delta), kept exact in Re E) or path points (graph true; sq encloses Re q^2). */
typedef struct box { ivl x, y, sq; double mu2, delta; bool graph; } box;

static double vertex_scale(size_t n, const double complex v[static n])
{
    double scale = 0;
    for (size_t i = 0; i < n; i++)
        scale = fmax(scale, cabs(v[i]));
    return scale;
}

/* The boxes of a threshold over the cell c: k is monotone in Re E and |Im E| per quadrant,
 * so four corners bound it; b[0] holds the path above Re k, b[1] the node momentum k. */
static void node_boxes(xb_rect c, double delta, double mu, size_t n, const double complex v[static n],
                       double vscale, box b[static 2])
{
    const double complex k1 = csqrt(k_squared(c.re_lo, c.im_hi, delta, mu));
    const double complex k2 = csqrt(k_squared(c.re_hi, c.im_lo, delta, mu));
    const double complex k3 = csqrt(k_squared(c.re_lo, c.im_lo, delta, mu));
    const double complex k4 = csqrt(k_squared(c.re_hi, c.im_hi, delta, mu));
    const double extent = fmax(fmax(fabs(c.re_lo), fabs(c.re_hi)), fmax(fabs(c.im_lo), fabs(c.im_hi)));
    const double scale = fmax(fmax(fmax(cabs(k1), cabs(k2)), fmax(cabs(k3), cabs(k4))),
                              fmax(fmax(fabs(delta), mu), fmax(extent, vscale)));
    const ivl x = pad(creal(k1), creal(k2), scale), y = pad(cimag(k3), cimag(k4), scale);
    const double h0 = height(n, v, x.lo), h1 = height(n, v, x.hi);
    double lo = fmin(h0, h1), hi = fmax(h0, h1);
    for (size_t i = 0; i < n; i++)
        if (x.lo <= creal(v[i]) && creal(v[i]) <= x.hi) {
            lo = fmin(lo, cimag(v[i]));
            hi = fmax(hi, cimag(v[i]));
        }
    const ivl h = pad(lo, hi, fmax(absmax(x), vscale));
    b[0] = (box){.x = x, .y = h, .sq = sub(sqr(x), sqr(h)), .graph = true};
    b[1] = (box){.x = x, .y = y, .sq = mul(2 * mu, out(c.re_lo - delta, c.re_hi - delta)), .mu2 = 2 * mu,
                 .delta = delta};
}

/* A lower bound of the distance from the path of every point of the box b. */
static double clearance(size_t n, const double complex v[static n], double vscale, const box b[static 1])
{
    const double complex mid = __builtin_complex((b->x.lo + b->x.hi) / 2, (b->y.lo + b->y.hi) / 2);
    const double scale = fmax(fmax(cabs(mid), vscale), fmax(absmax(b->x), absmax(b->y)));
    const double lower = path_distance(n, v, mid) - hypot(b->x.hi - b->x.lo, b->y.hi - b->y.lo) / 2;
    return fmax(0, pad(lower, lower, scale).lo);
}

/* (C2), S35: the smallest E_{3,beta} - (h_beta + a_beta) H^2 - Re E over the rectangle,
 * widened as the reference widens it. */
static double s35_margin(const xb_model *m, double depth, xb_rect r)
{
    const double hh = depth * depth;
    double value = INFINITY, scale = fmax(fmax(m->p.m_pi, m->p.m_eta), fmax(hh, fmax(fabs(r.re_lo), fabs(r.re_hi))));
    for (int b = 0; b < 4; b++) {
        value = fmin(value, fmin(m->p.m_pi + m->t[b] - (m->h[b] + m->a[b]) * hh - r.re_hi,
                                 m->p.m_eta + m->t[b] - (m->h[b] + m->a[b]) * hh - r.re_hi));
        scale = fmax(scale, fmax(fabs(m->t[b]), fmax(fabs(m->h[b]), fabs(m->a[b]))));
    }
    return pad(value, value, scale).lo;
}

/* A lower bound of Re sqrt(w) over Re w >= a and |Im w| >= c, both of which it grows with;
 * for a < 0 the rationalised c / sqrt(2 (|w| - a)) avoids the cancellation. */
static double root_bound(double a, double c)
{
    if (a < 0)
        return fmax(0, down(c / up(sqrt(up(2 * up(up(hypot(a, c)) - a))))));
    return fmax(0, down(sqrt(fmax(0, down(down(hypot(a, c)) + a) / 2))));
}

/* A lower bound of Re s_+- = Re sqrt(m^2 + (p +- q)^2) over the boxes of p and q; m itself for
 * two path points, whose sum and difference stay within 45 degrees of the real axis (S34). */
static double s_bound(const box *p, const box *q, double mass)
{
    if (p->graph && q->graph)
        return mass;
    double s = INFINITY;
    for (int sign = -1; sign <= 1; sign += 2) {
        const ivl x = add(p->x, mul(sign, q->x)), y = add(p->y, mul(sign, q->y));
        const ivl w = add(out(mass * mass, mass * mass), sub(sqr(x), sqr(y)));
        s = fmin(s, root_bound(w.lo, fmax(0, down(2 * down(absmin(x) * absmin(y))))));
    }
    return s;
}

/* One (C5) query: an ordering's nu = t + h p'^2 + a q^2 - E, the exchanged meson, Re E over
 * the energy cell, and the side of a node: its row (node momentum outgoing) or its column. */
typedef struct query {
    ivl re;
    double t, h, a, mass;
    double scale; /* the path's, to widen its pieces */
    bool row;
} query;

/* A lower bound of Re nu over the cell; a node's Re k^2 enters as mu2 (Re E - delta), so that
 * its Re E is collected with -Re E before the bound. */
static double nu_bound(const box *p, const box *q, const query *y)
{
    const box *b[2] = {p, q};
    const double recoil[2] = {y->h, y->a};
    ivl coefficient = {.lo = -1, .hi = -1}, constant = {.lo = y->t, .hi = y->t};
    for (int i = 0; i < 2; i++)
        if (b[i]->graph)
            constant = add(constant, mul(recoil[i], b[i]->sq));
        else {
            const ivl c = mul(recoil[i], (ivl){.lo = b[i]->mu2, .hi = b[i]->mu2});
            coefficient = add(coefficient, c);
            constant = sub(constant, mul(b[i]->delta, c));
        }
    const double lower = fmin(add(constant, mul(y->re.lo, coefficient)).lo,
                              add(constant, mul(y->re.hi, coefficient)).lo);
    const double scale = fmax(fmax(fmax(fabs(y->t), fabs(y->h)), fmax(fabs(y->a), absmax(y->re))),
                              fmax(absmax(p->sq), absmax(q->sq)));
    return pad(lower, lower, scale).lo;
}

/* A lower bound of Re Z = Re s + Re nu over every pair of node x other, the node's boxes
 * outgoing in a row query and incoming in a column one; the root and recoil terms are
 * minimised apart. */
static double pair_bound(size_t nn, const box node[static nn], size_t no, const box other[static no],
                         const query *y)
{
    double sn = INFINITY, nu = INFINITY;
    for (size_t i = 0; i < nn; i++)
        for (size_t j = 0; j < no; j++) {
            const box *p = y->row ? &node[i] : &other[j], *q = y->row ? &other[j] : &node[i];
            sn = fmin(sn, s_bound(p, q, y->mass));
            nu = fmin(nu, nu_bound(p, q, y));
        }
    return down(sn + nu);
}

/* The path piece from a to b: its box, with Re q^2 enclosed by squaring it (its height is affine). */
static box piece(double complex a, double complex b, double scale)
{
    const ivl x = pad(fmin(creal(a), creal(b)), fmax(creal(a), creal(b)), scale);
    const ivl y = pad(fmin(cimag(a), cimag(b)), fmax(cimag(a), cimag(b)), scale);
    return (box){.x = x, .y = y, .sq = sub(sqr(x), sqr(y)), .graph = true};
}

/* (C5) at a node's row or column over the piece p from a to b; an inconclusive piece whose
 * ends pass is bisected down to q_floor. */
static double piece_bound(const query *y, const box node[static 2], double complex a, double complex b,
                          const box *p)
{
    const double lower = pair_bound(2, node, 1, p, y);
    if (lower > 0 || cabs(b - a) <= q_floor)
        return lower;
    const box first = piece(a, a, y->scale), last = piece(b, b, y->scale);
    if (!(fmin(pair_bound(2, node, 1, &first, y), pair_bound(2, node, 1, &last, y)) > 0))
        return lower;
    const double complex mid = a + (b - a) / 2;
    const box left = piece(a, mid, y->scale), right = piece(mid, b, y->scale);
    return fmin(piece_bound(y, node, a, mid, &left), piece_bound(y, node, mid, b, &right));
}

/* (C5) at one node's row and column over one path piece and energy cell: the smallest bound
 * over both mesons and the orderings of its blocks (bit b of rows and cols). The root and
 * recoil terms of pair_bound are shared among them; an inconclusive one goes to piece_bound. */
static double node_piece(const xb_model *m, const box node[static 2], double complex pa, double complex pb,
                         const box *p, unsigned rows, unsigned cols, ivl re, double scale)
{
    const double mass[2] = {m->p.m_pi, m->p.m_eta};
    double least = INFINITY;
    for (int side = 0; side < 2; side++) {
        query y = {.re = re, .scale = scale, .row = side == 0};
        const box *out_k = y.row ? &node[1] : p, *in_k = y.row ? p : &node[1];
        const double s[2] = {fmin(mass[0], s_bound(out_k, in_k, mass[0])), fmin(mass[1], s_bound(out_k, in_k, mass[1]))};
        for (int b = 0; b < 4; b++) {
            if (!((y.row ? rows : cols) >> b & 1u))
                continue;
            y.t = m->t[b];
            y.h = m->h[b];
            y.a = m->a[b];
            double nu = INFINITY;
            for (int i = 0; i < 2; i++)
                nu = fmin(nu, y.row ? nu_bound(&node[i], p, &y) : nu_bound(p, &node[i], &y));
            for (int f = 0; f < 2; f++) {
                y.mass = mass[f];
                const double lower = down(s[f] + nu);
                least = fmin(least, lower > 0 ? lower : piece_bound(&y, node, pa, pb, p));
            }
        }
    }
    return least;
}

/* The edges of the n_sub x n_sub energy cells of r, both outer edges exact. */
static void cell_edges(xb_rect r, double xs[static n_sub + 1], double ys[static n_sub + 1])
{
    for (size_t i = 0; i <= n_sub; i++) {
        xs[i] = i == n_sub ? r.re_hi : r.re_lo + (double)i * ((r.re_hi - r.re_lo) / n_sub);
        ys[i] = i == n_sub ? r.im_hi : r.im_lo + (double)i * ((r.im_hi - r.im_lo) / n_sub);
    }
}

/* The paths without nodes. [0, Lambda] serves a physical-sheet rectangle below the lowest
 * threshold, which may straddle the real axis. The margin path 0 -> H - iH -> Lambda - H - iH
 * -> Lambda serves a rectangle on the sheet adjacent to the real axis (CONVENTIONS.md, "Pole
 * margin of a path"): every pole at least d_k from it, a flipped one, above its threshold,
 * between [0, Lambda] and the path, the others under the line of slope 1. */
static void certify_fixed(const xb_model *m, xb_rect r, enum xb_path path, xb_plan *plan, xb_cert *cert)
{
    const double lambda = m->p.cutoff, dk = m->p.pole_margin;
    double complex *v = plan->vertex;
    double depth = 0;
    if (path == XB_PATH_MARGIN) {
        /* H = d_k plus the deepest flipped pole: above its threshold |Im k| grows with |Im E|
         * and falls with Re E, so over the rectangle it is deepest at (re_lo, im_lo). A
         * relative cushion of 2^-30 keeps d_k through the rounding allowances of (C3). */
        double deepest = 0;
        for (int s = 0; s < 3; s++)
            if (plan->flip[s])
                deepest = fmax(deepest, -cimag(csqrt(k_squared(r.re_lo, r.im_lo, m->delta[s], m->mu[s]))));
        depth = deepest > 0 ? (deepest + dk) * (1 + 0x1p-30) : dk;
        /* The return vertex is rounded inward so that its slope is at most 1 in floating point. */
        plan->n_vertex = 4;
        v[1] = __builtin_complex(depth, -depth);
        v[2] = __builtin_complex(nextafter(lambda - depth, 0), -depth);
        v[3] = lambda;
    } else {
        plan->n_vertex = 2;
        v[1] = lambda;
    }
    const size_t n = plan->n_vertex;
    cert->depth = depth;
    cert->slope = path_slope(n, v);
    cert->margin[0] = INFINITY;
    if (!(cert->slope <= 1)) { /* a depth beyond Lambda / 2 */
        cert->failed = 1;
        return;
    }
    cert->margin[1] = s35_margin(m, depth, r);
    if (!(cert->margin[1] > 0)) {
        cert->failed = 2;
        return;
    }
    /* (C3): pole placement and clearance over the rectangle, not just its centre.
     * For a flipped pole x-iy above threshold, x-y, Lambda-x-y and H-y grow as |Im E|
     * decreases. So clearing the legs and the floor also places it above the path along
     * the vertical continuation. Unflipped poles below threshold stay under the slope-1 line. */
    const double vscale = vertex_scale(n, v);
    double xs[n_sub + 1], ys[n_sub + 1], clear = INFINITY;
    cell_edges(r, xs, ys);
    for (int s = 0; s < 3; s++) {
        if (isnan(m->delta[s]))
            continue;
        if (plan->flip[s] ? r.re_lo < m->delta[s] : r.re_hi > m->delta[s]) {
            clear = 0; /* the vertical continuation would give a different sheet */
            break;
        }
        if (r.im_hi > 0) { /* physical sheet below all thresholds */
            clear = fmin(clear, pole_margin(n, v, r, m->delta[s], m->mu[s]));
            continue;
        }
        for (size_t c = 0; c < n_sub * n_sub; c++) {
            const xb_rect cell = {.re_lo = xs[c / n_sub], .re_hi = xs[c / n_sub + 1],
                                  .im_lo = ys[c % n_sub], .im_hi = ys[c % n_sub + 1]};
            box b[2];
            node_boxes(cell, m->delta[s], m->mu[s], n, v, vscale, b);
            const ivl bx = b[1].x, by = b[1].y;
            const double x = (bx.lo + bx.hi) / 2, y = (by.lo + by.hi) / 2;
            const bool placed = !plan->flip[s] || (0 < bx.lo && bx.hi < lambda && y > height(n, v, x));
            double d = placed ? INFINITY : 0;
            for (size_t k = 0; k + 1 < n; k++)
                d = fmin(d, box_distance(v[k], v[k + 1], bx.lo, bx.hi, by.lo, by.hi));
            clear = fmin(clear, d - 64 * DBL_EPSILON * fmax(1, absmax(bx) + absmax(by) + vscale));
        }
    }
    cert->margin[2] = clear;
    if (!(path == XB_PATH_MARGIN ? clear >= dk : clear > 0)) {
        cert->failed = 3;
        return;
    }
    cert->margin[3] = cert->margin[4] = INFINITY;
}

/* The S40 path of a rectangle in the closed lower half plane and its certificate, bounded
 * as the reference's certify_rectangle bounds them: monotone root bounds and outward-rounded
 * intervals on n_sub x n_sub energy cells. */
static void certify_s40(const xb_model *m, xb_rect r, xb_plan *plan, xb_cert *cert)
{
    const double lambda = m->p.cutoff;
    bool present[3], vertex[3], optional[3], node[3];
    double complex *v = plan->vertex;
    size_t n = 1;
    const double re_c = (r.re_lo + r.re_hi) / 2, im_c = (r.im_lo + r.im_hi) / 2;
    for (int s = 0; s < 3; s++) {
        present[s] = !isnan(m->delta[s]);
        vertex[s] = present[s] && (plan->flip[s] || m->delta[s] < r.re_hi);
        if (!vertex[s])
            continue;
        const double complex k = csqrt(k_squared(re_c, im_c, m->delta[s], m->mu[s]));
        if (!(0 < creal(k) && creal(k) < lambda)) {
            /* (C1): a vertex at Re k = 0 would share the origin's real part, or lies past the cutoff. */
            cert->failed = 1;
            cert->margin[0] = lambda - cabs(k);
            if (!(creal(k) > 0))
                cert->slope = INFINITY;
            return;
        }
        /* Sorted by real part; a pole below the slope-1 line moves up onto it. */
        const double complex x = __builtin_complex(creal(k), -fmin(fabs(cimag(k)), creal(k)));
        size_t j = n++;
        for (; j > 1 && creal(v[j - 1]) > creal(x); j--)
            v[j] = v[j - 1];
        v[j] = x;
    }
    v[n++] = lambda;
    plan->n_vertex = n;
    double depth = 0;
    for (size_t i = 0; i < n; i++)
        depth = fmax(depth, -cimag(v[i]));
    cert->depth = depth;
    cert->slope = path_slope(n, v);
    if (!(cert->slope <= 1 + 16 * DBL_EPSILON)) {
        cert->failed = 1;
        return;
    }
    cert->margin[1] = s35_margin(m, depth, r);
    if (!(cert->margin[1] > 0)) {
        cert->failed = 2;
        return;
    }

    /* Every threshold's boxes on every energy cell, c = i n_sub + j with i along Re E and j
     * along Im E, and the distance of its pole from the path. */
    const double vscale = vertex_scale(n, v);
    double xs[n_sub + 1], ys[n_sub + 1];
    cell_edges(r, xs, ys);
    box e[n_sub * n_sub][3][2];
    double dist[3] = {INFINITY, INFINITY, INFINITY};
    for (size_t c = 0; c < n_sub * n_sub; c++)
        for (int s = 0; s < 3; s++)
            if (present[s]) {
                const xb_rect cell = {.re_lo = xs[c / n_sub], .re_hi = xs[c / n_sub + 1],
                                      .im_lo = ys[c % n_sub], .im_hi = ys[c % n_sub + 1]};
                node_boxes(cell, m->delta[s], m->mu[s], n, v, vscale, e[c][s]);
                dist[s] = fmin(dist[s], clearance(n, v, vscale, &e[c][s][1]));
            }
    for (int s = 0; s < 3; s++) {
        optional[s] = present[s] && !vertex[s] && dist[s] < r_near;
        node[s] = vertex[s] || optional[s];
    }

    /* (C4): every node momentum lies within m_pi of the path above it. */
    double window[3] = {INFINITY, INFINITY, INFINITY};
    for (size_t c = 0; c < n_sub * n_sub; c++)
        for (int s = 0; s < 3; s++)
            if (node[s])
                window[s] = fmin(window[s], down(m->p.m_pi - absmax(sub(e[c][s][1].y, e[c][s][0].y))));

    /* (C5): Re Z > 0 for both mesons and every ordering of a node's blocks, at its row and
     * column along the whole path, piece by piece, and at the node-node pairs. */
    double rowcol[3] = {INFINITY, INFINITY, INFINITY}, pairs[3][3];
    for (size_t g = 0; g + 1 < n; g++) {
        const double complex a = v[g], b = v[g + 1];
        const double count = fmax(1, ceil(cabs(b - a) / q_spacing));
        for (size_t i = 0; (double)i < count; i++) {
            const double t0 = (double)i / count, t1 = (double)(i + 1) / count;
            const double complex pa = (1 - t0) * a + t0 * b, pb = (1 - t1) * a + t1 * b;
            const box p = piece(pa, pb, vscale);
            for (size_t c = 0; c < n_sub * n_sub; c++)
                for (int s = 0; s < 3; s++)
                    if (node[s])
                        rowcol[s] = fmin(rowcol[s], node_piece(m, e[c][s], pa, pb, &p,
                                                               m->order_mask[s][XB_ALL_SPECIES],
                                                               m->order_mask[XB_ALL_SPECIES][s],
                                                               (ivl){.lo = xs[c / n_sub], .hi = xs[c / n_sub + 1]},
                                                               vscale));
        }
    }
    const double mass[2] = {m->p.m_pi, m->p.m_eta};
    for (int s = 0; s < 3; s++)
        for (int t = 0; t < 3; t++) {
            pairs[s][t] = INFINITY;
            for (size_t c = 0; c < n_sub * n_sub && node[s] && node[t]; c++)
                for (int b = 0; b < 4; b++)
                    for (int f = 0; f < 2 && (m->order_mask[s][t] >> b & 1u); f++) {
                        const query y = {.re = {.lo = xs[c / n_sub], .hi = xs[c / n_sub + 1]},
                                         .t = m->t[b], .h = m->h[b], .a = m->a[b], .mass = mass[f], .row = true};
                        pairs[s][t] = fmin(pairs[s][t], pair_bound(2, e[c][s], 2, e[c][t], &y));
                    }
        }

    /* Optional nodes that fail (C4) or (C5) are dropped until the remaining nodes pass. */
    int8_t dropped[3] = {};
    for (bool again = true; again;) {
        bool failing[3] = {};
        for (int s = 0; s < 3; s++) {
            bool pair_fails = false;
            for (int t = 0; t < 3; t++)
                pair_fails = pair_fails || (node[t] && fmin(pairs[s][t], pairs[t][s]) <= 0);
            failing[s] = node[s] && optional[s] && (window[s] <= 0 || rowcol[s] <= 0 || pair_fails);
        }
        again = false;
        for (int s = 0; s < 3; s++)
            if (failing[s]) {
                node[s] = false;
                dropped[s] = window[s] <= 0 ? 4 : 5;
                again = true;
            }
    }

    /* (C1): every node momentum stays inside the cutoff. */
    double inside_cutoff = INFINITY;
    for (size_t c = 0; c < n_sub * n_sub; c++)
        for (int s = 0; s < 3; s++)
            if (node[s])
                inside_cutoff = fmin(inside_cutoff, lambda - up(hypot(absmax(e[c][s][1].x), absmax(e[c][s][1].y))));
    cert->margin[0] = inside_cutoff;
    if (!(inside_cutoff > 0)) {
        cert->failed = 1;
        return;
    }
    /* (C3): the poles without a node, a dropped near pole among them, clear the path. */
    double clear = INFINITY, least_window = INFINITY, z = INFINITY;
    for (int s = 0; s < 3; s++) {
        if (present[s] && !node[s])
            clear = fmin(clear, dist[s]);
        cert->node[s] = node[s];
        cert->dropped[s] = dropped[s];
    }
    cert->margin[2] = clear;
    if (!(clear > 0)) {
        cert->failed = 3;
        return;
    }
    for (int s = 0; s < 3; s++)
        if (node[s]) {
            least_window = fmin(least_window, window[s]);
            z = fmin(z, rowcol[s]);
            for (int t = 0; t < 3; t++)
                if (node[t])
                    z = fmin(z, pairs[s][t]);
        }
    cert->margin[3] = least_window;
    if (!(least_window > 0)) {
        cert->failed = 4;
        return;
    }
    cert->margin[4] = z;
    if (!(z > 0))
        cert->failed = 5;
}

xb_status xb_certify(const xb_model *model, xb_rect rect, xb_sheet sheet, enum xb_path path,
                     xb_plan *plan, xb_cert cert[static 1])
{
    if (model == nullptr || plan == nullptr)
        return XB_EARG;
    plan->magic = 0;
    const int8_t sign[3] = {sheet.pp, sheet.pv, sheet.vv};
    bool valid = isfinite(rect.re_lo) && isfinite(rect.re_hi) && isfinite(rect.im_lo) && isfinite(rect.im_hi)
              && rect.re_lo < rect.re_hi && rect.im_lo < rect.im_hi
              && (path == XB_PATH_S40 || path == XB_PATH_MARGIN);
    bool physical = true;
    double lowest = INFINITY;
    for (int s = 0; s < 3; s++) {
        const bool present = !isnan(model->delta[s]);
        valid = valid && (sign[s] == 1 || (sign[s] == -1 && present));
        physical = physical && sign[s] == 1;
        if (present)
            lowest = fmin(lowest, model->delta[s]);
    }
    /* Only the physical sheet below all thresholds may extend into Im E > 0. */
    if (!valid || (rect.im_hi > 0 && !(physical && rect.re_hi < lowest)))
        return XB_EARG;
    const bool fixed = path == XB_PATH_MARGIN || rect.im_hi > 0;

    *plan = (xb_plan){.model = model, .rect = rect, .flip = {sign[0] < 0, sign[1] < 0, sign[2] < 0}};
    *cert = (xb_cert){.depth = NAN, .slope = NAN, .margin = {NAN, NAN, NAN, NAN, NAN}};
    if (fixed)
        certify_fixed(model, rect, path, plan, cert);
    else
        certify_s40(model, rect, plan, cert);
    if (cert->failed != 0) {
        plan->cert = *cert;
        return XB_OK;
    }

    /* Gauss–Legendre panels of length at most L_p on every segment, weights w = gamma'(t) dt. */
    const size_t np = (size_t)model->p.panel_nodes, nb = (size_t)model->p.n_bare;
    size_t panels[4], n_q = 0;
    for (size_t s = 0; s + 1 < plan->n_vertex; s++) {
        const double count = ceil(cabs(plan->vertex[s + 1] - plan->vertex[s]) / model->p.panel_length);
        panels[s] = count < 1 ? 1 : (size_t)count;
        n_q += np * panels[s];
    }
    if (n_q > model->n_q_max)
        return XB_EARG;
    double complex *q = plan->data, *w = q + n_q, *f = w + n_q;
    size_t j = 0;
    for (size_t s = 0; s + 1 < plan->n_vertex; s++) {
        const double complex a = plan->vertex[s], step = (plan->vertex[s + 1] - a) / (double)panels[s];
        for (size_t panel = 0; panel < panels[s]; panel++)
            for (size_t i = 0; i < np; i++, j++) {
                q[j] = a + (double)panel * step + (model->gl[i] + 1) * step / 2;
                w[j] = model->gl[np + i] * step / 2;
                xb_form_factors(model, q[j], nb, f + j * nb);
            }
    }
    plan->n_q = n_q;
    cert->n_path = (int32_t)n_q; /* n_q <= n_q_max <= INT32_MAX, checked by xb_model_create */
    plan->cert = *cert;
    plan->magic = plan_magic;
    return XB_OK;
}

static bool inside(xb_rect r, double re, double im)
{
    return re >= r.re_lo && re <= r.re_hi && im >= r.im_lo && im <= r.im_hi;
}

/* An evaluation on a plan at E: XB_EARG for a missing argument, XB_ENOCERT unless the plan
 * is certified for the model and E lies in its closed rectangle. */
static xb_status usable(const xb_model *model, const xb_plan *plan, xb_cplx energy)
{
    if (model == nullptr || plan == nullptr || !isfinite(energy.re) || !isfinite(energy.im))
        return XB_EARG;
    if (plan->magic != plan_magic || plan->model != model || plan->cert.failed != 0
        || !inside(plan->rect, energy.re, energy.im))
        return XB_ENOCERT;
    return XB_OK;
}

static inline double abs2(double complex z) { return creal(z) * creal(z) + cimag(z) * cimag(z); }

static inline bool node_close(double complex k, double complex q, double complex w, double gap)
{
    return abs2(k - q) <= gap * gap * abs2(w) * abs2(q);
}

/* 2 k I_sigma(k), nonsingular even at the threshold. */
static double complex node_log(double lambda, double complex k, bool flipped)
{
    return clog((lambda - k) / (lambda + k)) + __builtin_complex(0.0, flipped ? xb_pi : -xb_pi);
}

/* W of S40(c), with pole = sum_j w_j / (q_j^2 - k^2). */
static double complex node_weight(const xb_model *m, int s, bool flipped, double complex kk,
                                  double complex k, double complex pole)
{
    return m->mu[s] * (k * node_log(m->p.cutoff, k, flipped) - 2 * kk * pole);
}

xb_status xb_loop(const xb_model *model, const xb_plan *plan, xb_cplx energy, size_t n,
                  xb_cplx loop[static n])
{
    if (model == nullptr || n != (size_t)model->n_ch)
        return XB_EARG;
    const xb_status status = usable(model, plan, energy);
    if (status != XB_OK)
        return status;
    const double complex *q = plan->data, *w = q + plan->n_q;
    double complex sum[3] = {};
    for (int s = 0; s < 3; s++) {
        if (isnan(model->delta[s]))
            continue;
        const bool node = plan->cert.node[s] != 0;
        const double complex kk = k_squared(energy.re, energy.im, model->delta[s], model->mu[s]);
        const double complex k = node ? csqrt(kk) : 0;
        const double mu2 = 2 * model->mu[s];
        double complex path = 0, pole = 0;
        bool collision = false;
        for (size_t j = 0; j < plan->n_q; j++) {
            const double complex qq = q[j] * q[j], d = qq - kk;
            if (node && (d == 0 || node_close(k, q[j], w[j], node_gap))) {
                collision = true;
                break;
            }
            if (d == 0)
                return XB_EDOM;
            const double complex residue = w[j] / d;
            path += residue * qq * mu2;
            if (node)
                pole += residue;
        }
        /* Use the actual quadrature terms for comparisons away from collisions. At a hit,
         * first cancel q_j^2/(q_j^2 - k^2) - k^2/(q_j^2 - k^2) = 1 analytically. */
        sum[s] = collision ? mu2 * model->p.cutoff + model->mu[s] * k * node_log(model->p.cutoff, k, plan->flip[s])
                           : path + (node ? node_weight(model, s, plan->flip[s], kk, k, pole) : 0);
        if (!isfinite(creal(sum[s])) || !isfinite(cimag(sum[s])))
            return XB_EDOM;
    }
    for (int32_t c = 0; c < model->n_ch; c++)
        loop[c] = (xb_cplx){.re = creal(sum[model->species[c]]), .im = cimag(sum[model->species[c]])};
    return XB_OK;
}

/* A threshold's momentum is shared, but each of its partial waves has its own matrix row
 * and column, appended after the path entries in channel order. Zero marks no node. */
typedef struct onshell {
    size_t n, entry[6];
    double complex k[3];
} onshell;

static inline double complex as_complex(xb_cplx z) { return __builtin_complex(z.re, z.im); }

/* A is 1 + V^(OME) G on all path and on-shell entries. For the full equation, add C in
 * the S wave and border A by [[A, g F], [-g F^T G, E - epsilon]], giving tilde D (S9/S10).
 * For T, save the unweighted (V^(OME) + C) node columns and the bare sources -g f_n(k).
 * Eliminating the bare rows gives (1 + V G) T = V with the full potential, without ever
 * dividing by a bare-energy gap or a node weight. */
static xb_status assemble(const xb_model *m, xb_ws *ws, const xb_plan *plan, double complex e, bool full,
                          bool rhs, onshell o[static 1], size_t dim[static 1])
{
    const size_t nq = plan->n_q, nc = (size_t)m->n_ch, nb = (size_t)m->p.n_bare, sc = (size_t)m->s_ch;
    const size_t np = nc * nq;
    const double complex *q = plan->data, *w = q + nq, *f = w + nq;
    double complex *a = ws->a;
    const double norm = 2 * xb_pi * xb_pi, contact = full ? m->p.contact : 0;

    /* Compute the weights once per threshold. Path and node terms use the same k^2 and
     * denominators, so the singular parts of their weights cancel. */
    double complex kk[3] = {}, pole[3] = {};
    double complex *const weights[3] = {ws->g, ws->g + (nq + 1), ws->g + 2 * (nq + 1)};
    const bool present[3] = {!isnan(m->delta[0]), !isnan(m->delta[1]), !isnan(m->delta[2])};
    for (int s = 0; s < 3; s++)
        if (present[s])
            kk[s] = k_squared(creal(e), cimag(e), m->delta[s], m->mu[s]);
    for (size_t j = 0; j < nq; j++) {
        const double complex qq = q[j] * q[j];
        for (int s = 0; s < 3; s++) {
            if (!present[s])
                continue;
            const double complex d = qq - kk[s];
            if (d == 0)
                return XB_EDOM;
            const double complex residue = w[j] / d;
            weights[s][j] = residue * qq * (2 * m->mu[s]) / norm;
            if (plan->cert.node[s])
                pole[s] += residue;
        }
    }
    *o = (onshell){};
    for (int s = 0; s < 3; s++)
        if (plan->cert.node[s]) {
            o->k[s] = csqrt(kk[s]);
            weights[s][nq] = node_weight(m, s, plan->flip[s], kk[s], o->k[s], pole[s]) / norm;
        }
    const double complex *g[6];
    for (size_t c = 0; c < nc; c++) {
        g[c] = weights[m->species[c]];
        if (plan->cert.node[m->species[c]])
            o->entry[c] = np + o->n++;
    }
    const size_t continuum = np + o->n, nd = continuum + (full ? nb : 0);
    *dim = nd;

    double complex *b = ws->b; /* b[(node entry - np) nd + row] */
    xb_cplx v_ome[36];
    const size_t nn = nc * nc;
    /* One kernel call serves both pairs: V_{rc}(p, q) = V_{cr}(q, p). */
    for (size_t i = 0; i < nq; i++)
        for (size_t j = i; j < nq; j++) {
            const xb_status status = xb_ome_block(m, ws, q[i], q[j], e, XB_ALL_SPECIES, XB_ALL_SPECIES,
                                                  nn, v_ome, nullptr);
            if (status != XB_OK)
                return status;
            for (size_t r = 0; r < nc; r++)
                for (size_t c = 0; c < nc; c++) {
                    const double complex v = as_complex(v_ome[r * nc + c]) + (r == sc && c == sc ? contact : 0);
                    a[(r * nq + i) * nd + c * nq + j] = v * g[c][j];
                    if (i != j)
                        a[(c * nq + j) * nd + r * nq + i] = v * g[r][i];
                }
        }
    /* Each node's row and column, then the node-node pairs. */
    for (int s = 0; s < 3; s++) {
        if (!plan->cert.node[s])
            continue;
        const double complex k = o->k[s];
        for (size_t j = 0; j < nq; j++) {
            const xb_status status = xb_ome_block(m, ws, k, q[j], e, s, XB_ALL_SPECIES, nn, v_ome, nullptr);
            if (status != XB_OK)
                return status;
            for (size_t r = 0; r < nc; r++) {
                if (m->species[r] != s)
                    continue;
                const size_t row = o->entry[r];
                for (size_t c = 0; c < nc; c++) {
                    const double complex v = as_complex(v_ome[r * nc + c]) + (r == sc && c == sc ? contact : 0);
                    a[row * nd + c * nq + j] = v * g[c][j];
                    a[(c * nq + j) * nd + row] = v * g[r][nq];
                    if (rhs)
                        b[(row - np) * nd + c * nq + j] = v;
                }
            }
        }
        for (int t = s; t < 3; t++) {
            if (!plan->cert.node[t])
                continue;
            const xb_status status = xb_ome_block(m, ws, k, o->k[t], e, s, t, nn, v_ome, nullptr);
            if (status != XB_OK)
                return status;
            for (size_t r = 0; r < nc; r++)
                for (size_t c = 0; c < nc; c++)
                    if (m->species[r] == s && m->species[c] == t) {
                        const size_t row = o->entry[r], col = o->entry[c];
                        const double complex v = as_complex(v_ome[r * nc + c]) + (r == sc && c == sc ? contact : 0);
                        a[row * nd + col] = v * g[c][nq];
                        if (rhs)
                            b[(col - np) * nd + row] = v;
                        if (s != t) {
                            a[col * nd + row] = v * g[r][nq];
                            if (rhs)
                                b[(row - np) * nd + col] = v;
                        }
                    }
        }
    }
    for (size_t i = 0; i < continuum; i++)
        a[i * nd + i] += 1;
    if (!full)
        return XB_OK;
    /* All continuum entries were set above. Only clear the sparse bare border and sources. */
    for (size_t i = 0; i < continuum; i++)
        memset(a + i * nd + continuum, 0, nb * sizeof *a);
    memset(a + continuum * nd, 0, nb * nd * sizeof *a);
    if (rhs)
        for (size_t i = 0; i < o->n; i++)
            memset(b + i * nd + continuum, 0, nb * sizeof *b);
    const size_t sn = o->entry[sc];
    double complex fk[XB_MAX_BARE];
    if (sn != 0 && m->p.g != 0)
        xb_form_factors(m, o->k[m->species[sc]], nb, fk);
    for (size_t n = 0; n < nb; n++) {
        const size_t d = continuum + n;
        a[d * nd + d] = e - m->bare[n].energy;
        if (m->p.g == 0)
            continue;
        for (size_t j = 0; j < nq; j++) {
            const double complex vertex = m->p.g * f[j * nb + n];
            a[(sc * nq + j) * nd + d] = vertex;
            a[d * nd + sc * nq + j] = -vertex * g[sc][j];
        }
        if (sn != 0) {
            const double complex vertex = m->p.g * fk[n];
            a[sn * nd + d] = vertex;
            a[d * nd + sn] = -vertex * g[sc][nq];
            if (rhs)
                b[(sn - np) * nd + d] = -vertex;
        }
    }
    return XB_OK;
}

/* LU factors of the assembled matrix in place, and log D~ = {log|D~|, arg D~} from them;
 * {-inf, 0} where a factor vanishes exactly. */
static xb_status factor(xb_ws *ws, size_t dim, double complex log_det[static 1])
{
    gsl_matrix_complex_view view = gsl_matrix_complex_view_array((double *)ws->a, dim, dim);
    gsl_permutation perm = {.size = dim, .data = ws->perm};
    int signum = 0;
    const int status = gsl_linalg_complex_LU_decomp(&view.matrix, &perm, &signum);
    const double lndet = status == GSL_SUCCESS ? gsl_linalg_complex_LU_lndet(&view.matrix) : NAN;
    if (isfinite(lndet)) {
        const double phase = carg(gsl_linalg_complex_LU_sgndet(&view.matrix, signum));
        if (!isfinite(phase))
            return XB_EGSL;
        *log_det = __builtin_complex(lndet, phase);
        return XB_OK;
    }
    /* GSL 2.8 can return a positive zero-pivot index rather than a gsl_errno. In the
     * recursive factorisation it may index a sub-block; inspect the actual diagonal. */
    bool zero = false;
    for (size_t i = 0; i < dim; i++) {
        const double complex pivot = ws->a[i * dim + i];
        if (!isfinite(creal(pivot)) || !isfinite(cimag(pivot)))
            return XB_EGSL;
        zero = zero || pivot == 0;
    }
    if (!zero)
        return XB_EGSL;
    *log_det = __builtin_complex(-(double)INFINITY, 0.0);
    return XB_OK;
}

/* Solves the factored matrix in place for the n right-hand sides in ws->b, dim apart. */
static xb_status solve(xb_ws *ws, size_t dim, size_t n)
{
    gsl_matrix_complex_view lu = gsl_matrix_complex_view_array((double *)ws->a, dim, dim);
    gsl_permutation perm = {.size = dim, .data = ws->perm};
    for (size_t i = 0; i < n; i++) {
        gsl_vector_complex_view x = gsl_vector_complex_view_array((double *)(ws->b + i * dim), dim);
        if (gsl_linalg_complex_LU_svx(&lu.matrix, &perm, &x.vector) != GSL_SUCCESS)
            return XB_EGSL;
    }
    return XB_OK;
}

/* J^_C = F^T G (1 + V^(OME) G)^(-1) F (S10) from the factored 1 + V^(OME) G: F holds f_n on
 * the S-wave entries in column n < N and 1 there in column N, the contact term's. */
static xb_status jhat_from_lu(const xb_model *m, xb_ws *ws, const xb_plan *plan, const onshell o[static 1],
                              size_t dim, double complex out[])
{
    const size_t nq = plan->n_q, nb = (size_t)m->p.n_bare, nf = nb + 1, sc = (size_t)m->s_ch;
    const size_t sn = o->entry[sc];
    const double complex *f = plan->data + 2 * nq, *g = ws->g + (size_t)m->species[sc] * (nq + 1);
    double complex fk[XB_MAX_BARE + 1], *b = ws->b;
    if (sn != 0)
        xb_form_factors(m, o->k[m->species[sc]], nb, fk);
    fk[nb] = 1;
    memset(b, 0, sizeof(double complex) * nf * dim);
    for (size_t c = 0; c < nf; c++) {
        for (size_t j = 0; j < nq; j++)
            b[c * dim + sc * nq + j] = c < nb ? f[j * nb + c] : 1;
        if (sn != 0)
            b[c * dim + sn] = fk[c];
    }
    const xb_status status = solve(ws, dim, nf);
    if (status != XB_OK)
        return status;
    for (size_t r = 0; r < nf; r++)
        for (size_t c = 0; c < nf; c++) {
            const double complex *x = b + c * dim;
            double complex sum = sn != 0 ? fk[r] * g[nq] * x[sn] : 0;
            for (size_t j = 0; j < nq; j++)
                sum += (r < nb ? f[j * nb + r] : 1) * g[j] * x[sc * nq + j];
            out[r * nf + c] = sum;
        }
    return XB_OK;
}

/* The on-shell T between the node channels from the factored full matrix (S40(f)): column b
 * of T solves it for the right-hand side assemble wrote for node entry b, and its node rows
 * hold T_{a b}(k_a, k_b). Row-major over the channels, NaN outside the node channels. */
static xb_status onshell_t(const xb_model *m, xb_ws *ws, const xb_plan *plan, const onshell o[static 1],
                           size_t dim, double complex out[])
{
    const size_t nc = (size_t)m->n_ch, np = nc * plan->n_q;
    const xb_status status = solve(ws, dim, o->n);
    if (status != XB_OK)
        return status;
    for (size_t r = 0; r < nc; r++)
        for (size_t c = 0; c < nc; c++)
            out[r * nc + c] = o->entry[r] != 0 && o->entry[c] != 0 ? ws->b[(o->entry[c] - np) * dim + o->entry[r]]
                                                                  : __builtin_complex((double)NAN, (double)NAN);
    return XB_OK;
}

/* At E: log D~ from the LU factors of the full matrix, or log D^(OME)_C of 1 + V^(OME) G, and
 * with n > 0 the n entries of the on-shell T (full) or of J^_C (OME only) from the same factors. */
static xb_status evaluate(const xb_model *m, xb_ws *ws, const xb_plan *plan, double complex e, bool full,
                          size_t n, double complex out[], double complex log_det[static 1])
{
    onshell o;
    size_t dim;
    xb_status status = assemble(m, ws, plan, e, full, full && n > 0, &o, &dim);
    if (status == XB_OK)
        status = factor(ws, dim, log_det);
    if (status != XB_OK || n == 0)
        return status;
    if (!isfinite(creal(*log_det)))
        return XB_EDOM;
    return full ? onshell_t(m, ws, plan, &o, dim, out) : jhat_from_lu(m, ws, plan, &o, dim, out);
}

/* Screen only node channels: only their path poles are removable. */
static bool nodes_clear(const xb_model *m, const xb_plan *plan, double complex e, double gap)
{
    const double complex *q = plan->data, *w = q + plan->n_q;
    for (int s = 0; s < 3; s++)
        if (plan->cert.node[s]) {
            const double complex k = csqrt(k_squared(creal(e), cimag(e), m->delta[s], m->mu[s]));
            for (size_t j = 0; j < plan->n_q; j++)
                if (node_close(k, q[j], w[j], gap))
                    return false;
        }
    return true;
}

constexpr int stencil_size = 4;

/* Try the ray toward the centre and the axes toward the farther edges. Scale the starting
 * step down for narrow rectangles, and require four distinct, certified samples. */
static bool node_stencil(const xb_model *m, const xb_plan *plan, double complex e,
                         double complex samples[static stencil_size])
{
    const xb_rect r = plan->rect;
    const double width_re = r.re_hi - r.re_lo, width_im = r.im_hi - r.im_lo;
    const double complex towards = __builtin_complex(r.re_lo + width_re / 2, r.im_lo + width_im / 2) - e;
    const double complex dir[3] = {towards == 0 ? 0 : towards / cabs(towards),
                                   creal(towards) < 0 ? -1 : 1, cimag(towards) < 0 ? -I : I};
    const double start = fmax(DBL_TRUE_MIN, fmin(0x1p-40, 0x1p-16 * fmax(width_re, width_im)));
    for (double h = start; h < 1; h *= 2) {
        bool room = false;
        for (size_t axis = 0; axis < 3; axis++) {
            const double complex step = h * dir[axis], last = e + stencil_size * step;
            if (step == 0 || !inside(r, creal(last), cimag(last)))
                continue;
            room = true;
            double complex prev = e;
            int i = 0;
            for (; i < stencil_size; i++) {
                const double complex ei = e + (i + 1) * step;
                if (ei == prev || !nodes_clear(m, plan, ei, 2 * node_gap))
                    break;
                samples[i] = prev = ei;
            }
            if (i == stencil_size)
                return true;
        }
        if (!room)
            break;
    }
    return false;
}

/* Cubic Lagrange weights at E in the nearest node threshold's momentum, not in E. This
 * keeps the square-root cusp in the expansion, including when E is a threshold endpoint. */
static void node_stencil_weights(const xb_model *m, const xb_plan *plan, double complex e,
                                 const double complex samples[static stencil_size],
                                 double complex weights[static stencil_size])
{
    int nearest = 0;
    double distance = INFINITY;
    for (int s = 0; s < 3; s++)
        if (plan->cert.node[s]) {
            const double d = fabs(creal(e) - m->delta[s]);
            if (d < distance) {
                distance = d;
                nearest = s;
            }
        }
    const double delta = m->delta[nearest], mu = m->mu[nearest];
    const double complex k = csqrt(k_squared(creal(e), cimag(e), delta, mu));
    double complex offset[stencil_size];
    for (int i = 0; i < stencil_size; i++) {
        const double complex ki = csqrt(k_squared(creal(samples[i]), cimag(samples[i]), delta, mu));
        /* Proportional to ki - k, without subtracting nearly equal momenta. */
        offset[i] = (samples[i] - e) / (ki + k);
    }
    for (int i = 0; i < stencil_size; i++) {
        weights[i] = 1;
        for (int j = 0; j < stencil_size; j++)
            if (j != i)
                weights[i] *= -offset[j] / (offset[i] - offset[j]);
    }
}

/* The largest output block an evaluation carries: J^_C with XB_MAX_BARE bare states. */
enum { max_out = (XB_MAX_BARE + 1) * (XB_MAX_BARE + 1) };

/* At a removable hit the coalescing rows and columns cancel in det and det*out. Extrapolate
 * those regular functions at E before dividing to recover T or J^. */
static xb_status evaluate_near(const xb_model *m, xb_ws *ws, const xb_plan *plan, double complex e, bool full,
                               size_t n, double complex out[], double complex log_det[static 1])
{
    if (nodes_clear(m, plan, e, node_gap))
        return evaluate(m, ws, plan, e, full, n, out, log_det);
    double complex samples[stencil_size], weights[stencil_size];
    if (!node_stencil(m, plan, e, samples))
        return XB_EDOM;
    node_stencil_weights(m, plan, e, samples, weights);
    double scale = -INFINITY;
    double complex sum = 0, acc[max_out];
    for (size_t j = 0; j < n; j++)
        acc[j] = 0;
    for (int i = 0; i < stencil_size; i++) {
        double complex ld;
        const xb_status status = evaluate(m, ws, plan, samples[i], full, n, out, &ld);
        if (status != XB_OK)
            return status;
        const double mag = creal(ld);
        if (mag == -INFINITY) /* A zero contributes nothing to the determinant-only sum. */
            continue;
        if (mag > scale) {
            const double shrink = exp(scale - mag);
            sum *= shrink;
            for (size_t j = 0; j < n; j++)
                acc[j] *= shrink;
            scale = mag;
        }
        const double complex d = weights[i] * cexp(__builtin_complex(mag - scale, cimag(ld)));
        sum += d;
        for (size_t j = 0; j < n; j++)
            acc[j] += d * out[j];
    }
    if (!isfinite(creal(sum)) || !isfinite(cimag(sum)))
        return XB_EDOM;
    if (sum == 0) {
        *log_det = __builtin_complex(-(double)INFINITY, 0.0);
        return n == 0 ? XB_OK : XB_EDOM;
    }
    *log_det = __builtin_complex(scale + log(cabs(sum)), carg(sum));
    for (size_t j = 0; j < n; j++)
        out[j] = acc[j] / sum;
    return XB_OK;
}

xb_status xb_det(const xb_model *model, xb_ws *ws, const xb_plan *plan, xb_cplx energy,
                 xb_cplx log_det[static 1], size_t n, xb_cplx t[])
{
    if (ws == nullptr || ws->model != model || model == nullptr
        || (n != 0 && (n != (size_t)model->n_ch * (size_t)model->n_ch || t == nullptr)))
        return XB_EARG;
    xb_status status = usable(model, plan, energy);
    if (status != XB_OK)
        return status;
    double complex ld, out[36];
    status = evaluate_near(model, ws, plan, __builtin_complex(energy.re, energy.im), true, n, out, &ld);
    if (status != XB_OK)
        return status;
    *log_det = (xb_cplx){creal(ld), cimag(ld) <= -xb_pi ? xb_pi : cimag(ld)};
    for (size_t i = 0; i < n; i++)
        t[i] = (xb_cplx){creal(out[i]), cimag(out[i])};
    return XB_OK;
}

xb_status xb_jhat(const xb_model *model, xb_ws *ws, const xb_plan *plan, xb_cplx energy, size_t n,
                  xb_cplx jhat[static n])
{
    if (ws == nullptr || ws->model != model || model == nullptr
        || n != ((size_t)model->p.n_bare + 1) * ((size_t)model->p.n_bare + 1))
        return XB_EARG;
    xb_status status = usable(model, plan, energy);
    if (status != XB_OK)
        return status;
    double complex ld, out[max_out];
    status = evaluate_near(model, ws, plan, __builtin_complex(energy.re, energy.im), false, n, out, &ld);
    if (status != XB_OK)
        return status;
    for (size_t i = 0; i < n; i++)
        jhat[i] = (xb_cplx){creal(out[i]), cimag(out[i])};
    return XB_OK;
}

typedef struct refine_args {
    const xb_model *model;
    xb_ws *ws;
    const xb_plan *plan;
    double scale; /* log|D~(seed)| */
    xb_status status;
    bool outside; /* an iterate left the rectangle */
} refine_args;

/* (Re, Im) of D~(E) / |D~(seed)|, analytic in E with the zeros of D~. */
static int scaled_det(const gsl_vector *x, void *params, gsl_vector *f)
{
    refine_args *r = params;
    const double re = gsl_vector_get(x, 0), im = gsl_vector_get(x, 1);
    if (!inside(r->plan->rect, re, im)) {
        r->outside = true;
        return GSL_EBADFUNC;
    }
    xb_cplx ld;
    r->status = xb_det(r->model, r->ws, r->plan, (xb_cplx){re, im}, &ld, 0, nullptr);
    if (r->status != XB_OK)
        return GSL_EBADFUNC;
    const double size = exp(ld.re - r->scale);
    gsl_vector_set(f, 0, size * cos(ld.im));
    gsl_vector_set(f, 1, size * sin(ld.im));
    return GSL_SUCCESS;
}

xb_status xb_refine(const xb_model *model, xb_ws *ws, const xb_plan *plan, xb_cplx seed,
                    double residual_bound, xb_root root[static 1])
{
    if (!(residual_bound > 0))
        return XB_EARG;
    xb_cplx ld;
    const xb_status status = xb_det(model, ws, plan, seed, &ld, 0, nullptr);
    if (status != XB_OK)
        return status;
    if (ld.re == -INFINITY) {
        *root = (xb_root){.energy = seed, .residual = 0, .converged = 1};
        return XB_OK;
    }
    refine_args args = {model, ws, plan, ld.re, XB_OK, false};
    gsl_multiroot_function fn = {scaled_det, 2, &args};
    [[gnu::cleanup(free_solver)]] gsl_multiroot_fsolver *solver =
        gsl_multiroot_fsolver_alloc(gsl_multiroot_fsolver_hybrids, 2);
    if (solver == nullptr)
        return XB_ENOMEM;
    double start[2] = {seed.re, seed.im};
    gsl_vector_view x0 = gsl_vector_view_array(start, 2);
    const bool set = gsl_multiroot_fsolver_set(solver, &fn, &x0.vector) == GSL_SUCCESS;
    if (args.status != XB_OK)
        return args.status;
    int32_t iterations = 0;
    for (int step = GSL_SUCCESS; set && step == GSL_SUCCESS && iterations < 100;) {
        iterations++;
        step = gsl_multiroot_fsolver_iterate(solver);
        if (args.status != XB_OK)
            return args.status;
        if (step == GSL_SUCCESS && gsl_multiroot_test_delta(solver->dx, solver->x, 1e-14, 1e-13) == GSL_SUCCESS)
            break;
    }
    /* A failed start keeps the seed; a failed iterate keeps the last accepted point. */
    const xb_cplx e = set ? (xb_cplx){gsl_vector_get(solver->x, 0), gsl_vector_get(solver->x, 1)} : seed;
    const double size = set ? hypot(gsl_vector_get(solver->f, 0), gsl_vector_get(solver->f, 1)) : 1;
    const double residual = size == 0 ? 0 : exp(log(size) + ld.re);
    *root = (xb_root){.energy = e, .residual = residual, .iterations = iterations,
                      .converged = set && !args.outside && inside(plan->rect, e.re, e.im)
                                && residual <= residual_bound};
    return XB_OK;
}
