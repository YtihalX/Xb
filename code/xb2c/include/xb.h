/* xb.h: the continued Lippmann–Schwinger equation of the X_b2 pole search
 * (code/xb2c/SPEC.md; notes/07-continued-lse.tex).
 *
 * Units are GeV throughout; the contact term C is in GeV^-2 and the kernel V in
 * GeV^-2. An energy E is measured from M_th: m_B + m_B* in 1++, 2 m_B* in 2++.
 * Channels follow CONVENTIONS.md: 1++ PV(3S1), PV(3D1), VV(5D1); 2++ PP(1D2),
 * PV(3D2), VV(5S2), VV(1D2), VV(5D2), VV(5G2).
 *
 * Every fallible call returns an xb_status; no call aborts or prints. A model is
 * immutable after xb_model_create and may be read by any number of threads. A
 * workspace belongs to the thread that created it and is destroyed on that thread.
 * Complex numbers cross this boundary as {re, im} pairs. */
#pragma once

#include <stddef.h>
#include <stdint.h>

typedef struct xb_cplx { double re, im; } xb_cplx;

/* Declared before its definition: GCC 16 warns, wrongly, when the attribute sits on the
 * definition of an enum with a fixed underlying type, and applies it all the same. */
enum [[nodiscard]] xb_status : int32_t;
enum xb_status : int32_t {
    XB_OK = 0,
    XB_EARG,    /* missing (NaN or 0) or nonphysical parameter, invalid argument */
    XB_ENOMEM,  /* allocation failed or a size overflowed */
    XB_EGSL,    /* a GSL, LAPACK or MPFR routine failed or is unusable */
    XB_ENOCERT, /* the plan is not certified */
    XB_EDOM,    /* the kernel or a free propagator is singular at the requested point */
    XB_EPREC,   /* an angular moment needs more than XB_MAX_PREC bits */
};
typedef enum xb_status xb_status;

enum xb_sector : int32_t { XB_1PP = 1, XB_2PP = 2 };

/* Path families of a plan.
 * XB_PATH_S40: the S40 path of notes/07-continued-lse.tex, built at the rectangle's centre
 *   and held fixed over it: a vertex at Re k + i max(Im k, -Re k) for every flipped channel
 *   and every channel whose threshold lies below the rectangle's right edge, each with an
 *   on-shell node, plus an optional node for an unflipped pole within r_near = 100 MeV of
 *   the path that passes (C4) and (C5). The rectangle lies in the closed lower half plane,
 *   except on the physical sheet below the lowest threshold, where it may straddle the real
 *   axis and the path is [0, Lambda] without nodes.
 * XB_PATH_MARGIN: 0 -> H - iH -> Lambda - H - iH -> Lambda without nodes, the second path of the
 *   path-independence check. H is d_k plus the largest |Im k| of a flipped pole over the
 *   rectangle. The certificate checks the adjacent sheet's pole placement and clearance
 *   of at least d_k, including where an edge touches a threshold line off the real axis.
 *   Only on the physical sheet below the lowest threshold may the rectangle straddle the axis. */
enum xb_path : int32_t { XB_PATH_S40 = 1, XB_PATH_MARGIN = 2 };

enum { XB_MAX_BARE = 16, XB_MAX_PREC = 4096 };

/* A sheet carries one sign per threshold, +1 or -1, ordered (BB, BB*, B*B*). */
typedef struct xb_sheet { int8_t pp, pv, vv; } xb_sheet;
typedef struct xb_rect { double re_lo, re_hi, im_lo, im_hi; } xb_rect;

/* Model parameters. A missing double is NaN, a missing integer is 0. */
typedef struct xb_params {
    enum xb_sector sector;
    int32_t n_bare;           /* tower truncation N, 1 to XB_MAX_BARE */
    int32_t panel_nodes;      /* Gauss–Legendre nodes per path panel */
    double m_b, sigma, gamma; /* quark model: m_b, sigma (GeV^2), gamma = -4 alpha_s/3 */
    double v0, contact;       /* V0, C */
    double g, g_b, f_pi;      /* bare–continuum coupling, axial coupling, F_pi */
    double cutoff;            /* sharp cutoff Lambda */
    double m_B, m_Bstar, m_pi, m_eta;
    double mu_pv;             /* 1++: the fit's PV reduced mass; 2++: NaN (from the masses) */
    double panel_length;      /* path panel length L_p */
    double pole_margin;       /* pole margin d_k of the margin path */
} xb_params;

typedef struct xb_bare {
    double energy;         /* epsilon_n = M0_n + V0 - M_th */
    double reference_mass; /* M0_n, the quark model at V0 = 0 (GLOSSARY.md, "Bare state") */
    double norm_residual;  /* |integral of u_n^2 - 1| after normalisation */
    double tail_residual;  /* relative residual of the matched tail on its window */
} xb_bare;

typedef struct xb_info {
    int32_t n_channels;
    int32_t n_bare;
    double threshold[3];    /* delta of the BB, BB*, B*B* thresholds; NaN where absent */
    double reduced_mass[3]; /* their reduced masses; NaN where absent */
    xb_bare bare[XB_MAX_BARE];
} xb_info;

/* Certificate record of a plan: (C1)-(C5) of notes/07-continued-lse.tex, S40(d), each
 * bounded over the whole rectangle as code/Xb2Continuation/src/sp_contours.jl does. Margins
 * are in GeV, +inf where a condition is vacuous, NaN where an exclusion stopped short of it:
 *   margin[0] (C1) Lambda - |k| over the node momenta; the slope part of (C1) is `slope` <= 1;
 *   margin[1] (C2) the S35 margin, min over beta of E_{3,beta} - (h + a) H^2 - Re E;
 *   margin[2] (C3) the distance from the path of the poles without a node;
 *   margin[3] (C4) m_pi - |Im k - h(Re k)| over the node momenta;
 *   margin[4] (C5) the lower bound of Re Z at the node rows, columns and node-node pairs.
 * node and dropped are indexed (BB, BB*, B*B*) like the thresholds of xb_info. */
typedef struct xb_cert {
    int32_t failed;    /* 0 when certified, else the first failed condition, 1 to 5 */
    int32_t n_path;    /* path nodes */
    int8_t node[3];    /* 1 where the threshold carries an on-shell node */
    int8_t dropped[3]; /* 4 or 5 where a near node failed (C4), else (C5), and was dropped */
    double depth;      /* path depth H */
    double slope;      /* largest slope of the path; +inf where a vertex shares a real part */
    double margin[5];
} xb_cert;

typedef struct xb_root {
    xb_cplx energy;
    double residual;    /* |D~(E)| at the returned energy */
    int32_t iterations;
    int32_t converged;  /* 1 inside the plan's rectangle with the residual within bound */
} xb_root;

typedef struct xb_model xb_model;
typedef struct xb_ws xb_ws;
/* A plan is a caller-owned buffer of xb_plan_size bytes, aligned to max_align_t.
 * Only xb_certify writes it; it is read-only afterwards. */
typedef struct xb_plan xb_plan;

/* GSL's abort handler off and BLAS single-threaded: once per process, and for Accelerate,
 * whose setting is per thread, on every calling thread. Model and workspace creation call it. */
xb_status xb_init(void);

/* Solves the quark model and builds the form factors; validates every parameter. The
 * destructors cannot fail and return nothing; a null pointer is a no-op. */
xb_status xb_model_create(const xb_params params[static 1], xb_model *model[static 1]);
void xb_model_destroy(xb_model *model);
xb_status xb_model_info(const xb_model *model, xb_info info[static 1]);

/* One workspace per thread; it holds the matrix and the extended-precision temporaries. */
xb_status xb_ws_create(const xb_model *model, xb_ws *ws[static 1]);
void xb_ws_destroy(xb_ws *ws);

/* Where a workspace's time went since its creation, summed over the calls on it (SPEC.md,
 * user story 21), in nanoseconds of the monotonic clock. */
typedef struct xb_timing {
    int64_t kernel_double_ns;    /* the kernel outside extended precision: the moments in
                                    double precision and their contraction with the tables */
    int64_t moments_extended_ns; /* moments in extended precision (MPFR/MPC) */
    int64_t assembly_ns;         /* the rest of the matrix assembly */
    int64_t lu_ns;               /* LU factorisation, log D~, and the solves for T or J^ */
    int64_t moments_double;      /* moment sets in double precision */
    int64_t moments_extended;    /* moment sets in extended precision */
    int64_t matrices;            /* matrices assembled */
} xb_timing;

xb_status xb_ws_timing(const xb_ws *ws, xb_timing timing[static 1]);

xb_status xb_plan_size(const xb_model *model, size_t size[static 1]);

/* Builds and certifies a path fixed over the rectangle. S40 tries the real path first.
 * An excluded rectangle is a result (cert->failed != 0), not an error; its plan is not
 * certified. */
xb_status xb_certify(const xb_model *model, xb_rect rect, xb_sheet sheet, enum xb_path path,
                     xb_plan *plan, xb_cert cert[static 1]);

/* The free loop of each channel at E on the plan's path: the sum over the path nodes of
 * w_j q_j^2 2 mu / (q_j^2 - k^2) plus its threshold's on-shell node weight
 * W = 2 mu k^2 [I_sigma(k) - sum_j w_j / (q_j^2 - k^2)], where
 * I_sigma(k) = [Log((Lambda - k)/(Lambda + k)) + sigma i pi] / (2k), k is the
 * closed-fourth-quadrant root of 2 mu (E - delta) and sigma = + on a flipped threshold. With
 * a node the loop is 2 mu [Lambda + k^2 I_sigma(k)]; the matrix holds loop terms / (2 pi^2).
 * At a removable node collision, xb_loop cancels the two singular terms algebraically
 * before evaluating the loop. Away from collisions it sums the actual quadrature weights.
 * n = n_channels; E lies in the plan's closed rectangle. */
xb_status xb_loop(const xb_model *model, const xb_plan *plan, xb_cplx energy, size_t n,
                  xb_cplx loop[static n]);

/* log D~(E) = {log|D~|, arg D~ in (-pi, pi]}, D~ = D_C prod_n (E - epsilon_n) / GeV^N, for E
 * in the plan's closed rectangle (XB_ENOCERT elsewhere); an exact zero gives {-inf, 0}.
 * If n is n_channels^2, also return the on-shell T between node channels from the same LU:
 * row-major, outgoing channel first, both parts NaN where either channel lacks a node.
 * Pass n = 0 and t = nullptr for the determinant alone. Near a removable node collision the
 * result is extrapolated to E from points inside the certificate (SPEC.md, "Removable 0/0").
 * XB_EDOM if that stencil does not fit, or if T is requested at a singular solve. */
xb_status xb_det(const xb_model *model, xb_ws *ws, const xb_plan *plan, xb_cplx energy,
                 xb_cplx log_det[static 1], size_t n, xb_cplx t[]);

/* J^_C = F^T G (1 + V^(OME) G)^(-1) F at E (note 07, S10), row-major with n = (n_bare + 1)^2:
 * F holds f_n on the S-wave entries, its on-shell node's included, in column n < n_bare,
 * and 1 there in the last column, the contact term's; transposes only, no conjugation. With
 * v^ = diag(g^2 / (E - epsilon_n), C), D~ = D~(OME) det(1 + v^ J^), where D~(OME) is xb_det
 * of the same model with g = 0 and C = 0. Same domain and removable-0/0 treatment as
 * xb_det; XB_EDOM where D^(OME)_C vanishes exactly. */
xb_status xb_jhat(const xb_model *model, xb_ws *ws, const xb_plan *plan, xb_cplx energy,
                  size_t n, xb_cplx jhat[static n]);

/* One zero of D~ by GSL's two-dimensional hybrid solver, seeded at seed inside the plan's
 * rectangle. An iterate that leaves the rectangle ends the search unconverged. */
xb_status xb_refine(const xb_model *model, xb_ws *ws, const xb_plan *plan, xb_cplx seed,
                    double residual_bound, xb_root root[static 1]);

/* The OME kernel V_{a'a}(p, q; E), p outgoing and q incoming: v_pi = 3 V(m_pi) and
 * v_eta = V(m_eta)/3, row-major with n = n_channels^2 entries each. */
xb_status xb_kernel(const xb_model *model, xb_ws *ws, xb_cplx p, xb_cplx q, xb_cplx energy,
                    size_t n, xb_cplx v_pi[static n], xb_cplx v_eta[static n]);
