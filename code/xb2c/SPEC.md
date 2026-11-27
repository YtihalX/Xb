# C library and Zig driver for the $X_{b2}$ pole search (Stages 5–7)

## Problem Statement

The follow-up study asks whether LO BOχEFT, with every parameter fixed by the baseline fit of the $1^{++}$ sector, produces a molecule-dominated spin-2 partner $X_{b2}$ near the $B^*\bar B^*$ threshold, and where the $\chi_{b2}(1P)$-, $\chi_{b2}(2P)$- and $\chi_{b2}(3P)$-dominated states lie. The method is settled and checked up to Stage 4. The continued Lippmann–Schwinger equation is solved by the deformed SP method on an S40 path built per rectangle of the energy plane, with a certificate that the kernel is analytic at every momentum pair the equation uses. That certificate covers the whole search domain: $\Gamma\le20$ MeV on the sheets $(-,+,+)$ and $(-,-,+)$, below the $B^*\bar B^*$ threshold.

The C library evaluates $\tilde D$ and refines individual zeros. The Zig driver (`src/driver.zig`, command `xb2c`) runs the whole search from one configuration file: it certifies, counts, refines and subdivides rectangles on a pool of workers and writes JSON lines. `NOTEBOOK.md` (Stage 7, first baseline search) records the baseline $2^{++}$ counts, candidates and validation status. The Julia reference that carried Stages 0–4 does not run in this checkout: a private dependency cannot be cloned, and its HadronDynamics checkout is no longer at the pinned commit.

The search must run fast enough to repeat under variations of the quadrature, the path, the sharp cutoff and the tower truncation. Today no tool can answer the $X_{b2}$ question.

## Solution

A C numerical library evaluates the continued equation one rectangle at a time. It is built on GSL, with an optimized BLAS and LAPACK, and on MPFR/MPC for extended precision. It:
- solves the quark model for the bare spectrum;
- evaluates the full OME at complex momenta;
- certifies a rectangle and builds its S40 path with on-shell nodes;
- returns the diagnostic $\tilde D(E)$, the free loops, the on-shell $T$, the separable-sector loop matrix and refined zeros.

A Zig program drives it. One worker per core keeps its own workspace for its whole life and takes rectangles from a shared queue. Each job certifies its rectangle and counts the zeros of $\tilde D$ inside it by the argument principle. It then refines a single zero, closes an empty rectangle, or splits the rectangle and queues the children. Every rectangle becomes one JSON line: its certificate (or its first failed condition), its zero count, the refined poles with their residuals and, on request, the boundary samples.

The physicist runs one command with one configuration file. The same tool first reproduces the four bound states of the $1^{++}$ baseline fit, then searches the $2^{++}$ domain.

## User Stories

1. As the physicist, I want to run the $2^{++}$ pole search over the search domain with one command and one configuration file, so that the $X_{b2}$ question is answered without assembling stages by hand.
2. As the physicist, I want every pole reported as $E=M-i\Gamma/2$ relative to $2m_{B^*}$, with $M$, $\Gamma$, its sheet label and the rectangle that certified it, so that I can compare it with the measured peaks.
3. As the physicist, I want each refined pole reported with its residual $|\tilde D|$ and its number of refinement iterations, so that I can judge its convergence.
4. As the physicist, I want empty rectangles reported with their path certificate and empirical zero count, distinct from unresolved rectangles and from missing output.
5. As the physicist, I want a rectangle that fails the certificate reported with its first failed condition, (C1)–(C5), and that condition's margin, and never counted, so that no zero count rests on a kernel continued past a branch point.
6. As the physicist, I want excluded rectangles split down to a minimum size before they are given up, so that a thin excluded band does not hide the certified area around it.
7. As the physicist, I want the $X_{b2}$ candidate and the $\chi_{b2}(1P,2P,3P)$-dominated states from the same run, so that the spectrum comes from one consistent set of inputs.
8. As the physicist, I want the same program to compute the $1^{++}$ sector and reproduce the four bound states of the baseline fit, so that I can trust its $2^{++}$ results.
9. As the physicist, I want the bare $\chi_b$ energies computed by solving the quark model from $m_b$, $\sigma$ and $\gamma$, so that no bare energy is copied from a table.
10. As the physicist, I want the bare $\chi_{b2}$ masses equal to the bare $\chi_{b1}$ masses for now (quark model plus the baseline $V_0$, no fine splitting), so that any dressed $\chi_{b2}$–$\chi_{b1}$ splitting is the coupled-channel part alone.
11. As the physicist, I want $2^{++}$ energies measured from $2m_{B^*}$ and $1^{++}$ energies from $m_B+m_{B^*}$, so that no bare energy is shifted by $\Delta m$.
12. As the physicist, I want every parameter in the configuration file, so that another fit (the shallow-$X_b$ fit, later) or a cutoff or tower variation needs no code change.
13. As the physicist, I want the meson masses in the configuration too, so that the strict HQSS limit is just another parameter set.
14. As the physicist, I want the $2^{++}$ channels numbered by increasing threshold, $B\bar B(^1D_2)$, $B\bar B^*(^3D_2)$, then $B^*\bar B^*(^5S_2,{}^1D_2,{}^5D_2,{}^5G_2)$, in inputs, outputs and code, so that the code reads like the notes and the paper.
15. As the physicist, I want sheet labels ordered $(B\bar B,B\bar B^*,B^*\bar B^*)$, so that results carry the labels of the notes.
16. As the physicist, I want the search to use every core, so that a full domain run and its variations finish quickly.
17. As the physicist, I want identical results for any number of worker threads, so that a parallel run is reproducible.
18. As the physicist, I want real-axis scans of $\tilde D$ and the on-shell $T$ as parallel per-energy jobs, so that the speed plot and the continuity checks come from the same tool.
19. As the physicist, I want each rectangle's boundary samples $(E,\log|\tilde D|,\text{phase})$ written on request, so that I can inspect a doubtful zero count.
20. As the physicist, I want the output as JSON lines, so that the existing Python plotting reads it directly.
21. As the physicist, I want each run to report where its time goes (double- and extended-precision angular moments, matrix assembly, LU), so that I know what to optimise.
22. As the physicist, I want the kernel continued analytically, without conjugating incoming vertices, so that $\tilde D$ is the analytic continuation of the physical-sheet determinant.
23. As the physicist, I want the sheet to enter only as the sign of $i\pi$ in each on-shell node term, and the path deformed only to keep the kernel's exchanged-meson and three-body branch points off every pair the equation uses, so that the code follows the recorded purpose of the deformation.
24. As the physicist, I want one certified S40 graph path per rectangle, with slopes at most 1, held fixed over the whole rectangle. The path is chosen for kernel analyticity, with no requirement to pass through subtracted propagator poles.
25. As the physicist, I want near nodes for unflipped channels within $r_{\rm near}$ of the path, kept only when they pass (C4) and (C5), so that the plain quadrature stays accurate next to a nearby pole.
26. As the physicist, I want the on-shell node weights in closed form with the sign set by the sheet, so that a pole crossing the path inside a rectangle changes nothing.
27. As the physicist, I want an energy that falls next to a quadrature node evaluated at a slightly shifted point, so that the removable 0/0 of the node term costs no digits.
28. As the physicist, I want every angular moment to $10^{-10}$ relative, with extended precision wherever the closed form cancels, so that the "Moment precision" decision holds in production.
29. As the physicist, I want the full OME ($\pi$ and $\eta$, all four time orderings) assembled from the generated projected spin numerators in the current channel order, so that the 21 entries agree with note 04 and the paper's appendix.
30. As the physicist, I want the bare–continuum coupling and the contact term to act only in the $^5S_2$ channel, so that the $2^{++}$ separable sector matches CONVENTIONS.
31. As the physicist, I want $\tilde D=D\prod_n(E-\varepsilon_n)$ computed directly, never by dividing out the bare-state poles, so that the zero count sees an analytic function.
32. As the physicist, I want $\log|\tilde D|$ and the phase taken from the LU factors, so that $\tilde D$ neither overflows nor loses its phase.
33. As the physicist, I want the first search to use Delves–Lyness Method B with explicit complex root solves near suspect boundary segments, so that changes of count or signs of a near-edge zero are investigated rather than silently accepted.
34. As the physicist, I want a rectangle with two or more zeros, or an unresolved count, split until each child holds at most one, so that refinement always starts in the right basin.
35. As the physicist, I want split lines placed off-centre and moved away from any zero found on them, so that no zero sits on a child's edge.
36. As the physicist, I want a refined pole accepted only inside its rectangle, so that one zero is never reported twice or credited to the wrong rectangle.
37. As the physicist, I want the margin path available as a second plan for any rectangle, so that the Stage 6 path-independence check compares two admissible paths.
38. As the physicist, I want the free loop of each channel on a plan, so that the node weights can be checked against their closed form on every sheet.
39. As the physicist, I want the kernel $V(p',q;E)$ for any pair of complex momenta, so that reciprocity, the strict-HQSS block and kernel plots need no solve.
40. As the physicist, I want the on-shell $T$ between the node channels from the same factorisation, so that continuity to $T(E+i0)$, $\operatorname{Im}T^{-1}=\rho$ and later couplings use the same machinery.
41. As the physicist, I want the separable-sector loop matrix $\hat J_{\mathcal C}$ on a plan, so that $D_{\mathcal C}=D^{\rm(OME)}_{\mathcal C}\det(1+\hat v\hat J_{\mathcal C})$ can be checked.
42. As the physicist, I want physical-sheet rectangles that straddle the real axis below the lowest threshold accepted, so that bound states are found by the same search.
43. As the driver developer, I want one C23 header that Zig's translate-c reads without hand-written bindings, so that Zig calls the library directly.
44. As the driver developer, I want complex numbers to cross the boundary as $\{re,im\}$ pairs, so that translate-c accepts every prototype.
45. As the driver developer, I want every call to return a status and never abort or print, so that the driver decides what a failure means.
46. As the driver developer, I want the model built once and read-only afterwards, so that all workers share it without locks.
47. As the driver developer, I want each worker to create its workspace and plan buffer at start and destroy them on the same thread at exit, so that per-thread extended-precision caches are released correctly.
48. As the driver developer, I want the plan size reported by the library and plans written only by certification, so that each worker reuses one plan buffer for every job.
49. As the driver developer, I want no allocation in any per-energy call, so that the time per energy is predictable and workers never contend in the allocator.
50. As the driver developer, I want BLAS forced to one thread by the one-time initialisation, so that $N$ workers do not oversubscribe the cores.
51. As the driver developer, I want split rectangles pushed back on the shared queue and the queue closed after the last pending rectangle, so that workers stop cleanly.
52. As the driver developer, I want rectangle ids that encode the subdivision path, so that records from different runs and thread counts can be compared line by line.
53. As the maintainer, I want the C code in three modules (model, kernel, continued LSE) plus generated constant tables, so that it stays small until real duplication appears.
54. As the maintainer, I want the BLAS/LAPACK backend chosen by a build option (Accelerate on macOS, OpenBLAS on Linux), so that the same code builds on both.
55. As the maintainer, I want warning-free builds under strict warnings with clang and GCC, plus a GCC static-analyzer pass, so that contract errors surface at compile time.
56. As the maintainer, I want the projected-spin-numerator tables regenerated by the existing generator in the current channel order, so that tables and notes cannot drift apart.
57. As the maintainer, I want the certificate to return the margin of each condition, so that a margin shrinking under a change is visible before it fails.
58. As the maintainer, I want evaluation refused on an uncertified plan, so that no branch tracker is needed in this version.
59. As a collaborator, I want each reported pole traceable to its certificate, its refinement record and the configuration that produced it, so that I can check it independently.
60. As a collaborator, I want acceptance tests that reproduce the recorded Stage 2–4 numbers and the $1^{++}$ fit, so that the C port is shown to match the reference.

## Implementation Decisions

### Physics inputs and conventions

- **Scope.** The baseline fit only; the shallow-$X_b$ fit is deferred (user, 2026-11-25).
- **Parameters.** These values live only in the configuration:
  - quark model: $m_b=4.534$ GeV, $\sigma=0.198\ \text{GeV}^2$, $\gamma=-0.434$;
  - fit: $V_0=371.47$ MeV, $C=-16.268\ \text{GeV}^{-2}$;
  - couplings: bare–continuum coupling $g=57$ MeV, $g_b=0.56$, $F_\pi=92.2$ MeV;
  - tower truncation $N=4$ and sharp cutoff $\Lambda=4$ GeV;
  - isospin-limit masses $m_B=5.27952$ GeV, $m_{B^*}=5.32475$ GeV, $m_\pi=138.039$ MeV, $m_\eta=548$ MeV.
- **Bare spectrum** (spin-independent bare spectrum).
  - The quark model is solved on the reference's 12,000-point radial grid with $V_0=0$, which gives the reference masses $M^{(0)}_n$.
  - Each bare energy is $\varepsilon_n=M^{(0)}_n+V_0-M_{\rm th}$, with $M_{\rm th}=m_B+m_{B^*}$ in $1^{++}$ and $2m_{B^*}$ in $2^{++}$.
  - For $2^{++}$ this is provisional: there is no fine splitting (NOTEBOOK decision "Bare $\chi_{b2}$ masses, provisional").
- **Channels.**
  - $1^{++}$: $B\bar B^*(^3S_1)$, $B\bar B^*(^3D_1)$, $B^*\bar B^*(^5D_1)$.
  - $2^{++}$: $\alpha=1$ $B\bar B(^1D_2)$, $\alpha=2$ $B\bar B^*(^3D_2)$ ($C$-even), $\alpha=3$–$6$ $B^*\bar B^*(^5S_2,{}^1D_2,{}^5D_2,{}^5G_2)$. The thresholds relative to $2m_{B^*}$ are $-90.46$, $-45.23$ and $0$ MeV, with reduced masses $2639.76$, $2651.02$ and $2662.38$ MeV computed from the masses.
  - The $1^{++}$ sector keeps the fit's historical $\mu_{PV}=2650.95$ MeV, so that the fitted bound states are reproduced exactly.
  - Sheet labels are ordered $(B\bar B,B\bar B^*,B^*\bar B^*)$.
- **Separable sector.**
  - The bare–continuum coupling and the contact term act in the $S$-wave channel only: $\delta_{\alpha'1}\delta_{\alpha1}$ in $1^{++}$, $\delta_{\alpha'3}\delta_{\alpha3}$ in $2^{++}$.
  - The bare vertices $g f_n(q)$ are continued to complex $q$ without conjugation. The reference's potential and loop assembly, which conjugate the incoming vertex, are not ported.
- **Kernel.**
  - Full OME in TOPT: $V=3V^\pi+\frac13V^\eta$ with $V_{\alpha'\alpha}=-\frac{g_b^2}{8F_\pi^2}\sum_m c_{\alpha'\alpha,m}\Delta_m$.
  - The projected spin numerators $c$ are generated constant tables. $\Delta_m$ ($m=0$–$4$) are the angular moments of the four time orderings, numbered as in the paper's Eq. (77).
  - Reciprocity, $V_{\alpha'\alpha}(p',q)=V_{\alpha\alpha'}(q,p')$, halves the number of pair evaluations.
- **Angular moments.**
  - Above the switch of S22, the closed form in double precision is used, together with its cancellation measure $\kappa$.
  - Extended precision (MPFR/MPC) is used below the switch, and wherever $16\epsilon\kappa>10^{-10}$.
  - The target is $10^{-10}$ relative per moment (decision "Moment precision", unchanged).
- **Form factors.** $f_n(q)$ at complex $q$ comes from the quark-model radial wave functions:
  - quadrature over the radial grid in the interior;
  - the tail matched to the Cornell asymptotics with GSL's ODE solver;
  - the eigenvectors interpolated with GSL.

### Continuation (deformed SP method)

- **Path.** Under S40 a certified path may pass on either side of a subtracted propagator pole or through it. Deformation serves kernel analyticity, including at pairs with on-shell momenta. The real path is allowed if it passes the certificate.
  - `certify_s40` tries $[0,\Lambda]$ with the mandatory on-shell nodes first. Only a path-dependent (C4) or (C5) failure triggers deformation. It tries the reference polygon at quarter, half, three-quarter, then full depth, first at the affected channels' abscissae and then, if needed, with all mandatory channels' abscissae. Each trial must pass the same certificate. Bending cannot improve a failed (C5) bound evaluated on the actual momenta at a mandatory node–node pair. If no trial certifies, the builder returns the real-path failure for subdivision.
  - It is discretised by Gauss–Legendre panels. The starting values come from the reference: 16 nodes per 250 MeV panel.
- **On-shell nodes.**
  - Every flipped channel and every unflipped channel with threshold strictly below the rectangle's upper real-energy edge gets a mandatory on-shell node. Any other channel gets an optional node when its pole is within $r_{\rm near}=100$ MeV of the path and the node passes (C4) and (C5).
  - Each node is attached to every partial wave of its threshold ($2^{++}$: PP → 1, PV → 2, VV → 3–6).
  - Its weight is $W_\alpha=2\mu_\alpha k_\alpha^2\big[I_\sigma(k_\alpha)-\sum_j\omega_j/(q_j^2-k_\alpha^2)\big]$, with $I_\pm(k)=\frac{1}{2k}\big[\operatorname{Log}\frac{\Lambda-k}{\Lambda+k}\pm i\pi\big]$, $\sigma=+$ for a flipped channel and the principal Log.
  - For a channel with a node, the sheet enters only through $\sigma$.
- **Certificate.** Conditions (C1)–(C5) of S40(d), each bounded over the whole rectangle:
  - (C1) slopes at most 1, and $|k_\alpha|<\Lambda$;
  - (C2) the rectangle lies left of $E_{3,1}-H^2/m_B$;
  - (C3) the poles of channels without a node stay clear of the path;
  - (C4) every node lies within $m_\pi$ of the path;
  - (C5) $\operatorname{Re}Z>0$ at the node rows, columns and node–node pairs.
- **Certificate records.**
  - A certified plan records its node set, its dropped near nodes and the margin of each condition.
  - An excluded rectangle records its first failed condition and that condition's margin.
  - Evaluation on an uncertified plan is refused, and there is no branch tracker. On a certified rectangle every logarithm in the kernel is principal (S30 and S40(e); S30 still awaits sign-off).
- **Physical sheet.** Physical-sheet rectangles that straddle the real axis below the lowest threshold use $[0,\Lambda]$ with no nodes. Bound states are therefore found by the same search.
- **Margin path.** $0\to H-iH\to\Lambda-H-iH\to\Lambda$, with $H=d_k+\max_{F,E\in Q}|\operatorname{Im}k_F(E)|$, is the second plan for path-independence checks. It carries no nodes. It is available on the adjacent sheet of a rectangle between thresholds (also on the physical sheet below the lowest threshold). The bounds check the flipped poles above the path inside the cutoff, the other poles outside, clearance $\ge d_k$ throughout the rectangle, and (C1)–(C2). Touching a threshold line off the real axis is allowed if those bounds pass.
- **Removable 0/0.** Near $q_j$, the singular path and node weights grow with $|w_j q_j|/|k_\alpha-q_j|$ and cancel. The calibration used the reference polygon on rectangle A at 16 nodes per 250 MeV panel. Comparison to a Cauchy-circle Taylor reference at three $PV$ hits found relative direct-LU losses of order $\epsilon_{\rm mach}(|w_j q_j|/|k_\alpha-q_j|)^2$ in GeV units. Screen at $|k_\alpha-q_j|\le (0.01\,\text{GeV}^{-1})|w_j q_j|$. Choose four shifted energies inside the certificate, with each momentum clearing twice the trigger distance. Extrapolate back to $E$ by the cubic Lagrange rule in the nearest node threshold's momentum: for $\xi_i=k_{\rm near}(E_i)-k_{\rm near}(E)$ the weights are $\prod_{j\ne i}(-\xi_j)/(\xi_i-\xi_j)$. This retains the square-root behaviour at a threshold. Apply the rule to the determinant and to the determinant times the requested amplitude, then divide; use the OME determinant for $\hat J_{\mathcal C}$. If no stencil fits, return `XB_EDOM`. For `xb_loop` at a collision, cancel $q_j^2/(q_j^2-k^2)-k^2/(q_j^2-k^2)=1$ before summing; elsewhere use the direct sum to check the weights.

### Determinant, solve and refinement

- **Matrix.** With $A=1+(V^{\rm(OME)}+C F_C F_C^{\rm T})\mathcal G$ on the path and on-shell entries and $F_b$ the bare form-factor columns, factor $\mathcal A=\bigl(\begin{smallmatrix}A&g F_b\\-g F_b^{\rm T}\mathcal G&\operatorname{diag}(E-\varepsilon_n)\end{smallmatrix}\bigr)$. Eliminating the bare rows gives $1+V\mathcal G$ with the full potential. Thus $\det\mathcal A=\tilde D=D_{\mathcal C}\prod_n(E-\varepsilon_n)/\text{GeV}^N$, with no division by bare energy gaps. In $2^{++}$ the matrix is about $1700\times1700$ complex.
- **LU.** GSL's complex LU runs on the optimized CBLAS, one thread per worker. `xb_det` returns $\log|\tilde D|$ and its principal phase from the factors.
- **On-shell $T$.** Optional output of `xb_det` from the same LU. For a node channel $\beta$, use RHS $[(V^{\rm(OME)}+C F_C F_C^{\rm T})_{\cdot\beta},-g F_b(k_\beta)^{\rm T}]^{\rm T}$, i.e. the potential column without its quadrature weight and the bare source. Eliminating the bare rows gives the full $V_{\cdot\beta}$ as the RHS; read the node entries of the solution. No division by a vanishing node weight.
- **Separable-sector loop.** `xb_jhat` uses the OME-only LU to compute $\hat J_{\mathcal C}=F^{\rm T}\mathcal G(1+V^{\rm(OME)}\mathcal G)^{-1}F$, with columns of $F=(F_b,F_C)$ and transposes, not adjoints.
- **Refinement.** GSL's two-dimensional hybrid solver works on $(\operatorname{Re}\tilde D,\operatorname{Im}\tilde D)$, seeded inside the rectangle, in place of the secant iteration named in S41. A result outside the rectangle or above the residual bound is reported as not converged.
- **Libraries.** LAPACK's tridiagonal solver (`dstevr`) gives the quark model's lowest $N$ eigenpairs; it is the one routine GSL lacks. GSL provides every other numerical routine: Gauss–Legendre tables, ODE, interpolation, symmetric eigenproblems, Brent and hybrid root finding, complex LU.

### C library

- **Language and build.**
  - C2y (`gnu2y` with Microsoft extensions), built with zig cc (clang 22) and also compiled with GCC 16 for its static analyzer. Strict warnings are treated as errors.
  - `-fgnuc-version=14` makes GSL 2.8 treat `gsl_complex` as `double complex`; this also needs `<complex.h>` included first and inline functions on. Library headers enter as system headers.
  - Hot code uses `CX_LIMITED_RANGE`. Fast-math is off, because it would break the $\kappa$ measure and the NaN checks.
- **Style.** The code follows the user's modern-c and flavor-c rules:
  - `constexpr` constants and `nullptr`;
  - a `[[nodiscard]]` status enum with an `int32_t` base;
  - lengths before array parameters, declared `[static n]`;
  - cleanup attributes in constructors and checked size arithmetic;
  - no `extern "C"` and no wrapper functions;
  - abstractions extracted only after real duplication appears.
- **Modules.**
  - model: thresholds, reduced masses, orderings, quark model, form-factor data;
  - kernel: angular moments and OME assembly;
  - continued LSE: paths, nodes, certificate, matrix, LU, $\tilde D$, loops, $T$, $\hat J_{\mathcal C}$, refinement;
  - generated constant tables, and one public header.
- **Memory.**
  - One allocation per model and one per workspace, with checked sizes. Buffers live inside the structs, the matrix as a flexible array member.
  - The plan is a caller-owned buffer whose size the library reports. Certification writes it; after that it is read-only.
  - No per-energy call allocates. Extended-precision temporaries are allocated once, at maximum precision.
- **Threads.** The library starts none.
  - The model is immutable after creation, and a workspace belongs to one thread.
  - A one-time initialisation (`pthread_once`) turns GSL's abort handler off and sets BLAS to one thread.
  - MPFR is the thread-safe build. A workspace is destroyed on the thread that created it.
- **Public primitives (seam 1).**
  - one-time initialisation;
  - model create/destroy, and access to its bare energies;
  - workspace create/destroy, and its cumulative timing by stage (`xb_ws_timing`);
  - plan size;
  - certify: rectangle, sheet label and path family in; plan and certificate record out;
  - on a plan at energy $E$: $\tilde D$, the free loop of each channel, the on-shell $T$, $\hat J_{\mathcal C}$;
  - the kernel at one complex momentum pair (no plan needed);
  - refine.

  Every call returns a status. A rectangle the certificate excludes is a result, not an error.
- **Boundary types.** These come from the 2026-11-25 translate-c probe, trimmed. translate-c turned the enum into `i32` and accepted the structs; C complex types are rejected, which is why the `{re, im}` pair exists:

  ```c
  typedef struct xb_cplx { double re, im; } xb_cplx;
  enum [[nodiscard]] xb_status : int32_t { XB_OK = 0, XB_EARG, XB_ENOMEM, XB_EGSL, XB_ENOCERT /* … */ };
  typedef struct xb_sheet { int8_t pp, pv, vv; } xb_sheet;   /* one sign per threshold */
  typedef struct xb_rect  { double re_lo, re_hi, im_lo, im_hi; } xb_rect;
  ```

### Zig driver

- **Threads.** Zig 0.17.1. `std.Io.Threaded` with an `Io.Group` starts $N$ persistent workers, which take rectangles and scan energies from an `Io.Queue`. A pending counter closes the queue after the last job. Children that do not fit in the queue stay with the worker that made them. The translated header is called directly.
- **Jobs.** One job is one rectangle, run on one worker:
  1. Certify.
  2. Excluded: record it and split, down to the minimum size.
  3. Certified: walk the boundary and count zeros. An accepted empirical count of zero ends the job. A count of one is refined; if refinement does not converge, the count stands without a pole. Two or more, or an unresolved count, trigger subdivision down to the minimum size. A rectangle still unresolved at that size is reported as unresolved.

  Children go back on the queue. A split cuts the longer side at $1/\sqrt5$ of its length from the lower end. A splittable rectangle longer than 2.5 times its width is certified and split without a count: its corner-started meshes give the long sides segments that can span several zeros near the real axis, and three such meshes agreed on 2 instead of 4 zeros for the $1^{++}$ box $[-750,-1]\times[-10,10]$ MeV.
- **Sampling.** `src/rectangle.zig` uses [Delves–Lyness (1967), §5, Method B](https://doi.org/10.1090/S0025-5718-1967-0228165-4), Eq. (5.17) for signed phase crossings. Start with the four corners and bisect each contour segment, evaluating only the new midpoints. Accept three successive matching counts, subject to the boundary safeguard. The default limit is 64 segments per side. This is empirical: the path certificate concerns analyticity, not sampling completeness.
- **Boundary safeguard and splits.** Mark an exact sampled zero directly. A change in a segment's signed crossing count on bisection, antipodal endpoint phases, or a modulus at least eight times smaller than both neighbours prompts a complex root solve near the suspect sample. Use a secant prediction from existing samples to seed `xb_refine` within the certificate. A solved root outside the boundary-clearance band contributes a lower bound to the empirical count, and later warnings within its segment are not solved again; a failed solve or a root within that band leaves the count unresolved. The default clearance is $10^{-10}$ GeV. The rectangle job reports the suspect sample and any located boundary root without moving the boundary. In the subdivision driver, splits are off-centre; move an internal split away from a located zero too close to assign and recount both children. Report outer-boundary candidates separately; keep the specified outer limits unchanged.
- **Split families** (`src/driver.zig`). The two children of a split are settled together once both are counted. The line moves when a child locates a root within the clearance band of the line, or when a child's boundary solve fails on the line or within 20% of the parent's side of a root the other child located: such a sibling dips eightfold at a corner on the coarsest mesh. The moved line keeps 20% of the parent's side from every such root and from the lines it replaces; at most four moves, after which the children are resolved as they stand. Children inherit the roots located inside them by their ancestors, and a count of one is refined from those before the centre: otherwise a zero just inside an outer edge, already located by the parent, escapes the refinement and is reported as an unconverged count.
- **Ids.** Rectangle ids encode the subdivision path: the region index, then one digit per split, $2m$ for the lower and $2m+1$ for the upper child of the line after $m$ moves (`0/0121`). Records are keyed by id, so their content does not depend on scheduling.
- **Configuration.** In ZON (`config/*.zon`, run with `zig build run -Doptimize=ReleaseFast -- config/search-2pp.zon`): sector, parameters, domain regions with their sheets and path family, quadrature starting values, minimum rectangle size, sampling, worker count, output path. The library validates the parameters when it creates the model.
- **Output.** JSON lines of four kinds, energies in GeV from $M_{\rm th}$, non-finite numbers as `null`: `run` (every input, the thresholds and bare energies), one `rectangle` record per rectangle (bounds, sheet, certificate or exclusion, empirical zero count or unresolved, the pole with $E$, $M$, $\Gamma$, residual and iterations, the boundary warning with whether its root lies next to the split line, another internal line or an outer edge, optional samples), one `scan` record per scan energy, and a `summary` with the poles, the outer-boundary candidates, the open records and the timings (the kernel in double precision, the moments in extended precision, assembly, LU, from `xb_ws_timing`). Superseded children of a moved line keep their records. Outer-boundary candidates are distinct from the counted interior poles.
- **Real-axis scans.** They run as per-energy jobs with no rectangle state: a box of half-width $10^{-6}$ GeV certified with the energy on its top edge, by default on the sheet that flips every threshold below the energy, which gives $T(E+i0)$.

## Testing Decisions

- **What a good test is.**
  - It drives one of the two seams with a probe energy, a rectangle or a parameter set, and checks an observable outcome against an independent oracle: a recorded value, a closed form, or an identity (reciprocity, the strict HQSS limit, Cauchy's theorem, path independence, unitarity).
  - It never inspects internal functions, intermediate arrays or the order of internal steps, and it never uses the code's own earlier output as the oracle.
  - It is deterministic and runs in the full suite.
- **Two seams, tests written in Zig** (user, 2026-11-26).
- **Seam 1, the public C header,** called through translate-c exactly as the driver calls it.
  1. Model creation solves the quark model with a normalisation residual of at most $10^{-10}$ and tail matching of at most $2\times10^{-4}$. A missing or nonphysical parameter returns an argument status.
  2. $1^{++}$ baseline, refinement seeded 1 MeV away (user, 2026-11-26):
     - on $[0,\Lambda]$ with the reference's single 24-node Gauss–Legendre rule, the zeros match the recorded $X_b$ at $-90.9998248$ MeV and $\chi_{b1}(1P,2P,3P)$ at $-711.0061$, $-348.9938$ and $-60.6548$ MeV (relative to $m_B+m_{B^*}$; full precision in `central.toml`) within $10^{-8}$ GeV;
     - with the production rule (16 nodes per 250 MeV panel), the zeros on a deformed physical-sheet margin path reproduce those on $[0,\Lambda]$ within $10^{-10}$ GeV.

     The recorded energies carry the 24-node rule's discretization error, up to 6 keV for $X_b$, so no other path can reproduce them (`history/LOG.md`, 2026-11-26).
  3. Reciprocity, $V_{\alpha'\alpha}(p',q;E)=V_{\alpha\alpha'}(q,p';E)$, holds to rounding at complex probe momenta: all 21 entries, $\pi$ and $\eta$.
  4. Strict HQSS limit (glossary definition): the $j_\ell=1$ block of the $2^{++}$ kernel, recoupled with $U_2$ from the Bruschini bridge, equals the $1^{++}$ kernel.
  5. At pairs with one small momentum, the kernel matches GSL's adaptive angular quadrature, computed in the test, to $10^{-10}$ relative.
  6. On every sheet, the free loop of each channel matches $2\mu_\alpha[\Lambda+k_\alpha^2I_\sigma(k_\alpha)]$ at the Stage 3 probe energies: $\operatorname{Im}E=-10$ MeV with $\operatorname{Re}E$ from $-88$ to $+45$ MeV in 1 MeV steps, and $\operatorname{Im}E=-1,-10,-50$ MeV at $\operatorname{Re}E=-67.85$ and $-22.62$ MeV. The bar is the reference's quadrature level, a worst case of $5\times10^{-14}$.
  7. The recorded certificate outcomes are reproduced:
     - A: certified on $[0,\Lambda]$ with its two mandatory nodes;
     - Bd: certified, with its PV near node dropped by (C5);
     - F5: excluded by (C5) without a deformation;
     - the BB kernel-window test: the real path fails (C4) at a corner, and a bend shallower than the centre pole certifies.

     Both Stage 4 search strips certify down to the same tiling floor; each has real and deformed cells. The certificate margins need not reproduce those of the reference polygon.
  8. Cauchy: $\oint\tilde D\,dE$ vanishes, relative to $\max|\tilde D|$ times the perimeter, around a certified rectangle in which a flipped pole crosses the path.
  9. Path independence: $\tilde D$ on the S40 plan and on the margin-path plan agree at probe energies, within the Stage 6 quadrature tolerance.
  10. Continuity: the on-shell $T$ at $E-i\eta$ tends to the physical-sheet $T(E+i0)$ as $\eta\to0^+$. On the real axis, $\operatorname{Im}T^{-1}=\rho$ and, at fixed path and node set, reversing the open-channel signs gives $\tilde D_{\rm lower}/\tilde D_{\rm upper}=\det(1-2iT_{\rm upper}\rho)$.
  11. Factorisation: $\tilde D$ equals $\tilde D^{\rm(OME)}\det(1+\hat v\hat J_{\mathcal C})$ away from the $\varepsilon_n$ and from the zeros of $D^{\rm(OME)}$. The OME-only model is the same model with $g=0$ and $C=0$.
  12. Removable node collisions: the determinant at and near a collision agrees with its Cauchy circle mean. With OME and the bare coupling turned off, $\tilde D$, $T_{SS}$, $\hat J_{CC}$ and the free loops agree with their closed forms at collisions, including at a threshold endpoint and in a very narrow rectangle.
- **Seam 2, the Zig rectangle job** (rectangle and sheet in; certificate, count, refined poles and samples out), plus a small domain run.
  1. $1^{++}$ physical sheet:
     - a rectangle straddling the real axis around $X_b$ counts one zero, refined on the reference's single 24-node rule to the recorded energy within $10^{-8}$ GeV (the seam-1 bar for the same comparison; user, 2026-11-26);
     - a rectangle without a bound state counts zero;
     - a rectangle holding both $X_b$ and $\chi_{b1}(3P)$ splits and yields both poles, neither lost on a split line.
     - a pole on or too near an internal split line causes the split to move; an unresolved outer edge remains unresolved and is not silently moved.
  2. $2^{++}$: in a certified rectangle where a flipped pole crosses the S40 path, the count equals the sum of its children's counts, and equals the count of the same rectangle on the margin-path plan.
  3. F5 is reported as excluded by (C5), split to the minimum size, and never counted.
  4. A small domain run gives identical records with 1 worker and with $N$ workers.
  5. With sampling on, every record's count equals the winding number computed from its own samples.
  6. Single-job pilot (`zig build test-seam2 -Doptimize=ReleaseFast`): reproduce $X_b$ on the small reference rule, distinguish an empty box from one with two decoupled bare levels, locate a zero $5\times10^{-11}$ GeV inside an edge without assigning it, and leave an edge unresolved when its nearby zero is outside. A decoupled two-level rectangle with three aliased zero counts must not be reported empty.
- **No other seams.** Angular moments, node weights, path geometry and the boundary walk get no tests of their own; the two seams cover them.
- **Milestone order.** Quark model → $1^{++}$ bound states → angular moments → $2^{++}$ kernel → nodes and certificate → $\tilde D$ → search. Each milestone's tests pass before the next one starts.
- **Prior art.**
  - The Julia reference's rank-one SP check: 75 cases against closed forms on every sheet, worst loop error $5\times10^{-14}$.
  - Its S40 contour tests: Cauchy's theorem across a crossing PV pole, $9.8\times10^{-17}$.
  - Stage 2: four independent routes agree on 110,592 probe records of the continued moments.
  - Stage 4: the certified tiling (smallest (C5) margin 20.4 MeV) and the certificate examples A, B, Bd and F5 of the S40 proposal.
  - The $1^{++}$ reproduction of the paper's Tables V and VIII, and HadronDynamics' construction checks of the quark model.
  - The $2^{++}$ contraction script of note 04 (block structure in the strict HQSS limit) and the reciprocity assertion of the spin-numerator generator.
  - The guard figures of note 07 are plot evidence, not oracles.

## Out of Scope

- The shallow-$X_b$ fit, its refits at $\Lambda=3$ and 5 GeV, and the spurious-pole projection (S42). A spurious pole found in the baseline run is reported, not projected out.
- Stage 8 regions:
  - virtual states with respect to $B^*\bar B^*$;
  - hidden poles on sheets reached only around a threshold;
  - the sheet $(-,-,-)$ above the $B^*\bar B^*$ threshold;
  - $\operatorname{Re}E\ge47.58$ MeV, and three-body sheets;
  - poles outside the certified domain, and $\Gamma$ above 20 MeV.
- Couplings, residues, compositeness and compact probability; the effective-range expansion; scans in $g$.
- A branch tracker for uncertified rectangles. The three-body locator remains a diagnostic outside the library.
- The quark-model fine splitting of the bare $\chi_{b2}$ masses.
- The charm partners and the CMS line shapes. The real-axis scan prepares the line shapes but does not compute them.
- Repairing the Julia reference.
- A C++ interface.

## Further Notes

- **Pending sign-off.** Stage 7 results do not count as validated until S30 (the default homotopy) is signed off. S38, for the search domain, and the Stage 3, Stage 4 and milestone 6 tolerances were approved on 2026-11-26.
- **No Julia oracle.** Kernel entries are compared with the reference's OME on $[0,\Lambda]$ below $E_{3,1}$ only once the reference runs again. Until then the oracles are recorded values, closed forms and identities.
- **Measured and unmeasured costs.**
  - LU at $n=1200$, measured: 0.036 s with Accelerate, 0.32 s with GSL's own CBLAS.
  - Extended-precision moments, not measured: estimated at 1.5–4 s per energy, possibly the dominant cost. The angular-moment milestone measures it.
- **Form factors.** The complex form factors reach $7.6\times10^{-6}$ on the production grid; the user accepted $10^{-5}$ for the pole search (2026-11-26). The $10^{-6}$ target returns for on-shell $T$ in Stage 8.
- **Channel order.** The generator's write mode for the paper table still uses the earlier channel order, so the C tables must be generated in the current order. Comparisons with HadronDynamics map its code channel $i$ to $(3,4,5,6,2,1)_i$.
- **Accuracy targets.** On-shell $T$: $10^{-6}$ relative. Pole positions: 0.1 MeV.
- **Decisions this spec rests on.**
  - NOTEBOOK: "C implementation", "Purpose of the path deformation", "Bare $\chi_{b2}$ masses, provisional", "§I scope", "Moment precision", "Checks per stage", "LO contact term", "$2^{++}$ channel order", "Certification in the search domain", "Complex $f_n$ tolerance", "Order of the remaining Stage 6 checks".
  - note 07: S22, S23, S30, S38, S40, S41.
  - CONVENTIONS: "Continuation to other sheets", "2++ channel basis and projectors", "2++ bare–continuum vertex".
  - Glossary: "Deformed SP method".
