/* Internal layout shared by model.c, kernel.c and lse.c. */
#pragma once

#include <complex.h>
#include <stddef.h>
#include <stdint.h>
#include <time.h>

#include <mpc.h>

#include "xb.h"

constexpr double xb_pi = 0x1.921fb54442d18p+1;

/* Threshold species, or the full channel set for a path momentum. */
enum { XB_PP = 0, XB_PV = 1, XB_VV = 2, XB_ALL_SPECIES = 3 };

struct xb_model {
  xb_params p;
  int32_t n_ch; /* channels: 3 in 1++, 6 in 2++ */
  int32_t
      s_ch; /* the S-wave channel, 0-based: the bare states and C act there */
  int32_t order; /* highest angular moment: 3 in 1++, 4 in 2++ */
  double ratio;  /* S22 switch: double precision where |B| >= ratio * sigma */
  int32_t species[6]; /* threshold species of each channel */
  double delta[3],
      mu[3]; /* threshold relative to M_th and reduced mass of each species */
  double t[4], h[4],
      a[4]; /* time orderings beta = 1..4: nu = t + h p'^2 + a q^2 - E */
  double c[6][6][5][3];  /* projected spin numerators, src/tables.h */
  int32_t pair[6][6][2]; /* time orderings of each entry, 0 for no exchange */
  unsigned order_mask[4][4]; /* used orderings by outgoing/incoming species,
                                including ALL */
  xb_bare bare[XB_MAX_BARE];
  size_t n_r; /* radial quadrature points: interior Gauss–Legendre, then the
                 tail */
  size_t n_q_max; /* path nodes of the longest path a plan holds */
  size_t dim_max; /* largest matrix dimension */
  const double
      *gl;       /* Gauss–Legendre panel rule on [-1, 1]: nodes, then weights */
  double data[]; /* r[n_r], w[n_r][n_bare] with f_n(q) = sum_k w[k][n] j0(q
                    r_k), gl */
};

/* Extended-precision temporaries of one moment evaluation (kernel.c). */
enum { XB_MP = 30 };

struct xb_ws {
  const xb_model *model;
  double complex
      *g; /* G by threshold: 3 sets of n_q path weights and one node weight */
  double complex *b; /* right-hand sides of the solves, dim_max each */
  size_t *perm;      /* LU permutation */
  xb_timing timing;  /* cumulative, read by xb_ws_timing */
  mpc_t z[XB_MP];    /* initialised at XB_MAX_PREC bits, reset per evaluation */
  double complex a[]; /* the matrix, then g, b and perm */
};

/* Nanoseconds of the monotonic clock, for xb_timing; zero if the clock fails, which
 * CLOCK_MONOTONIC does not. */
static inline int64_t xb_clock(void) {
  struct timespec t;
  if (clock_gettime(CLOCK_MONOTONIC, &t) != 0)
    return 0;
  return (int64_t)t.tv_sec * 1000000000 + t.tv_nsec;
}

/* f_n(q), n < n_bare, at complex q: no conjugation (CONVENTIONS.md, "Bare-state
 * term off the real axis"). */
void xb_form_factors(const xb_model *model, double complex q, size_t n,
                     double complex f[static n]);

/* OME on one block of a momentum pair. v receives the sum, or the pion
 * contribution if eta is nonnull. Only entries in the requested species block
 * are written. */
xb_status xb_ome_block(const xb_model *model, xb_ws *ws, double complex p,
                       double complex q, double complex e, int out, int in,
                       size_t n, xb_cplx v[static n], xb_cplx eta[n]);
