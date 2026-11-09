# Continued angular moments and graph paths API

`Xb2Continuation` implements the TOPT one-ordering angular moments in
`notes/07-continued-lse.tex` (note 07). All momenta, masses, energies, and `Z`
values use GeV; energy is measured from `2mBstar`. Moments have units GeV⁻².
`pout` is outgoing and `pin` is incoming. Endpoint tuples always mean `(plus, minus)`.
The binding branch convention is CONVENTIONS.md, “Continued angular moments”.

## Exported names

- `Ordering(t::Float64, h::Float64, a::Float64)` stores the ordering's threshold
  shift `t` in GeV and recoil coefficients `h`, `a` in GeV⁻¹ (S3, `st:offsets`).
- `nu(o::Ordering, pout, pin, E)` returns `t + h*pout^2 + a*pin^2 - E` in GeV
  (S3). No momentum or energy is conjugated.
- `ordering(beta::Integer; params=HadronDynamics.BOchiEFT.Parameters())`
  returns the physical `Ordering` for `beta=1:4`, with the mass splitting and
  outgoing/incoming recoil placement of the S3 table. Other indices are errors.
- `block_orderings(block::Symbol)::NTuple{2,Int}` returns the two S3 ordering
  indices, retaining multiplicity: `:VV_VV => (2,2)`, `:PV_PV => (1,2)`,
  `:VV_PV => (2,3)`, `:PV_VV => (2,4)`, `:VV_PP => (3,3)`,
  `:PP_VV => (4,4)`. Blocks with no OME are errors.
- `Branch(logz::ComplexF64, sqrtz::ComplexF64)` holds the separately lifted
  logarithm and square root of one complex variable. `Branch(z::Number)`
  selects their principal germ (S13 and S17, `st:germ`, `st:branch`).
  The variable's units depend on the caller: GeV² for `w`, GeV for `Z`.
- `BranchTrackingError <: Exception` reports failure to certify a nonzero
  continuation, rather than guessing a branch (S18, `st:tracker`).
- `continue_branch(z, dzbound, lam0, lam1, b0::Branch;
  floor=1e-14, minstep=1e-12)::Branch` applies the S18 product rule to
  both lifted functions. `z(lambda)` returns the complex variable and
  `dzbound(a,b)` must bound `abs(dz/dlambda)` on the entire closed interval.
  A step is accepted only when `bound*abs(step) <= abs(z(start))/2`.
  Parameters are dimensionless; `floor` uses the variable's units. Failure
  below the floor or minimum step throws `BranchTrackingError`. The caller
  supplies a germ consistent with `z(lam0)`.
- `LiftedPair` stores `pout`, `pin`, `E`, `mphi`, `ordering`, endpoint roots
  `s`, endpoint arguments `Z`, lifted logarithms `L`, integer windings `n`,
  and `zmin`. The latter is a conservative lower bound in GeV on the
  minimum `abs(Z±)` along both stages of this pair's default homotopy.
  It does **not** certify an entire path or the free-resolvent pole margins
  (S23, `st:admissible`). `s` and `Z` use GeV; `L` and `n` are dimensionless
  logarithmic coordinates in the fixed GeV convention.
- `lift_default(o::Ordering, mphi::Real, pout::Number, pin::Number,
  E1::Number)::LiftedPair` implements S30 (`st:default`). For `imag(E1)<0`,
  stage (a) scales both momentum depths from zero at `conj(E1)`; stage (b)
  lowers the energy vertically to `E1`. Upper-half-plane targets use `E1`
  itself as starting energy, so real momenta remain on the principal germ.
  The routine asserts that `w±` never touches `(-Inf,0]` during depth
  scaling, and uses principal roots as required by S34 (`st:graph`).
  The derivative bound combines the exact quadratic momentum derivatives
  with `abs(ds/dlambda) <= abs(dw/dlambda)/(2sqrt(wlower))`, where
  `wlower = abs(w(a)) - sup(abs(dw/dlambda))*(b-a)`; steps with no positive
  lower bound are subdivided. Stage (a)'s `zmin` is the minimum accepted
  step-disk lower bound. Stage (b) uses S19 (`st:energyexact`) and the exact
  Euclidean distance of `E*=s+t+h*pout^2+a*pin^2` from the vertical energy
  segment. A zero or unresolvable close approach throws `BranchTrackingError`.
- `moments(lp::LiftedPair; order::Int=4)::Vector{ComplexF64}` returns
  `M_0` through `M_order` for **one** ordering, without isospin, spin,
  coupling, or ordering multiplicity factors. The normalization is
  `integral(x^m/(2s*(s+nu)), x=-1:1)` (S3). Production uses S12's
  polynomial-in-`Z` formula (`st:closed`), with separately lifted `L±`,
  never an untracked logarithm of their ratio. Power differences use the
  factored `Zplus-Zminus=2B/(splus+sminus)`. At `B=0` it uses the analytic
  limit from S15 (`st:Bzero`), rejecting unequal logarithm windings.
  Negative orders are errors.

## Precision policy

The nominal S22 (`st:evaluation`) switch selects Float64 when
`abs(B) >= beta*sigma`, with `sigma=max(abs(A),abs(nu)^2)`,
`beta=0.06` through order 3 and `beta=0.3` from order 4.
Below this threshold the calculation uses
`max(256, ceil((order+1)*max(0,-log2(abs(B)/sigma)))+128)` bits.

**Production policy decided by the user on 2026-11-05:** the target is
`1e-10` relative per moment. Above the nominal switch, Float64 evaluation measures the
cancellation ratio `kappa = sum(abs(summand))/abs(bracket)` for each S12
closed-form bracket. The summands include its logarithmic term and every
polynomial power-difference term. If `16*eps(Float64)*max(kappa) > 1e-10`,
the complete moment vector is recomputed in BigFloat. The sixteen-ulp
allowance accounts for coefficient and power-difference assembly as well
as bracket summation. The precision is the nominal rule with an additional
`ceil(log2(max(kappa)))` guard bits; a nonzero numerator magnitude with a
zero rounded bracket requests 256 additional bits. This extends, rather
than moves, the nominal `0.3` threshold. Independent 192-bit angular
quadrature exposed errors up to `9.71e-12` relative above that threshold
without escalation, within the production target; no oracle tolerances are widened.

All extended-precision kinematics, roots, and logarithms are recomputed
from the original Float64 inputs. In particular, the lift is reconstructed
as `Log(Z±) + 2*pi*im*n±` **in BigFloat**, rather than promoting the
rounded tracked logarithms. No straight-angular quadrature is used in production.

## Graph paths and path quadrature (Stage 3)

The two added public seams are the **path builder** and **path quadrature**.
All momentum vertices, pole margins, thresholds, and reduced masses use GeV.
The three threshold entries are ordered **VV, PV, PP**; the conventional sheet
label is instead written in ascending threshold order **PP, PV, VV**.

- `Threshold(delta::Float64, mu::Float64)` stores a threshold and reduced mass.
- `thresholds_2pp(; params=HadronDynamics.BOchiEFT.Parameters())::NTuple{3,Threshold}`
  returns `(0,mBstar/2)`, `(-(mBstar-mB),mB*mBstar/(mB+mBstar))`,
  and `(-2(mBstar-mB),mB/2)` (S2).
- `flipped(E::Number, th::Threshold)::Bool` means `th.delta < real(E)` (S27).
- `sheet_momentum(E::Number, th::Threshold)::ComplexF64` squares to
  `2th.mu*(E-th.delta)`, selecting `imag(k)<0` for flipped channels and
  `imag(k)>=0` for unflipped channels. For nonreal probe energies this fixes
  the sign uniquely. On the real axis, a real square root has zero imaginary
  part; a real-axis target with flipped channels is excluded by the builder.
- `GraphPath(vertices::Vector{ComplexF64})` stores a polygon with first vertex
  zero, last vertex real and positive, strictly increasing real coordinates,
  and nonpositive imaginary coordinates. Real/mixed numeric vectors are
  converted to `ComplexF64`; invalid polygons throw `ArgumentError`.
- `PathExclusion(reason::String)` records an excluded probe energy, never a
  forced path or an empty quadrature rule.
- `graph_path(E::Number, ths; Lambda::Real=4.0, margin::Real)::Union{GraphPath,PathExclusion}`
  builds the S40 polygon described below. `margin` is required and positive.
  An upper-half-plane target, or a target with no flipped channel, uses
  `[0,Lambda]` if that real segment clears all endpoint poles by `margin`.
- `inside_region(path::GraphPath, q::Number)::Bool` tests the **open** region
  `0<x<Lambda, h(x)<imag(q)<0`; neither the real axis nor the polygon belongs
  to the region (S27).
- `path_distance(path::GraphPath, q::Number)::Float64` returns the minimum
  Euclidean distance to the polygon's line segments, including its endpoints.
- `path_rule(path::GraphPath, n::Integer)::Tuple{Vector{ComplexF64},Vector{ComplexF64}}`
  returns `n` Gauss–Legendre nodes **per segment**, in path order, and complex
  oriented weights. `n<=0` throws `ArgumentError`. The rule reuses
  HadronDynamics' existing ThreeBodyToolkit Gauss–Legendre provider; no new
  dependency is required.

### Shape and maximum-clearance rule

For a lower-half-plane target with flipped set `F`, the polygon is
`0 -> x1-iH -> x2-iH -> Lambda`, where
`H=max(abs(imag(k_alpha)) for alpha in F)+margin` (S40).
The depth is rounded upward by one floating-point step so that subtracting a
pole depth cannot undershoot the requested margin. The flat part covers all
flipped real pole positions. The first and last legs have slope magnitude
at most one (S35).

At fixed `H`, the deepest flipped pole gives an upper bound
`cap=H-max(abs(imag(k_alpha)))` on the smallest distance from **any** pole to
the polygon: this pole is directly above the flat part. Thus a path attaining
this cap is a global maximum-clearance path, not merely a sampled best path.
Choose `x2=Lambda-H` (rounded inward to keep its actual floating-point slope
at most one), the latest possible return leg. Choose the **largest** `x1`
in `[H,min(real(k_alpha) for alpha in F)]` for which every flipped pole has
distance at least `cap` from the incoming segment. This monotone constraint
is solved by bisection until the bracket consists of adjacent Float64 values.
This tie-break makes the first leg as shallow as possible, hence maximises
clearance from the unflipped fourth-quadrant poles while retaining the cap.
The complete polygon is then checked against **both signs of every pole**,
the requested margin, and the S27 inside/outside placements. The cap and
requested margin differ only by the documented upward rounding.

### Vertical energy segment and exclusions

The builder certifies free-resolvent condition **(P)** on the entire vertical
segment from `conj(E)` to `E`, not just at its endpoint. It uses **adaptive
sampling with a Lipschitz bound**, not root solving. For each channel,

```text
|dk/deta| <= mu/sqrt(2mu*abs(real(E)-delta)) = Lk.
```

The distance of the unordered pair `(+k,-k)` to the polygon is therefore
`Lk`-Lipschitz. An interval of width `deta` is certified only if its midpoint
distance exceeds `Lk*deta/2` plus a `64eps(Float64)` coordinate-scale rounding
allowance; otherwise it is bisected. A zero or a gap not resolvable above
that allowance produces a `PathExclusion`. Depth scaling at `conj(E)` obeys
(P) by S29. This Stage-3 result does **not** certify the exchange-kernel
condition **(K)** over the whole path/homotopy; that is the Stage-4 validator.

Exclusions identify the failed condition: exact threshold equality (S27),
a real-axis flipped pole, finite-cutoff sheet range (S27), slope/flat-coverage
incompatibility, a pole margin that the slope-one incoming leg cannot meet,
wrong sheet placement, insufficient separation of flipped and unflipped
poles, or failure to certify vertical (P). Near thresholds the allowed pole
margin closes (the paragraph after the S40 pole table); such energies are
excluded with the geometric reason, not silently displaced. Nonfinite
inputs, nonpositive cutoff/margin/reduced mass, and empty threshold lists
are input errors (`ArgumentError`), not physical exclusions.

### Oriented quadrature

On a segment from `a` to `b`, for real Gauss–Legendre nodes and weights
`(t_j,w_j)` on `[-1,1]`, the returned entries are
`q_j=a+(t_j+1)*(b-a)/2` and `omega_j=w_j*(b-a)/2` (S9).
Neither the node nor the Jacobian is conjugated, and weights are **not**
arc-length weights. Integrating an analytic function means
`sum(omega .* f.(q))`; do not use a conjugating dot product.

```julia
ths = thresholds_2pp()
path = graph_path(-0.02262-0.010im, ths; margin=0.010)
if path isa GraphPath
    q, omega = path_rule(path, 32)
    integral = sum(omega .* exp.(q))
else
    println("excluded: ", path.reason)
end
```

## Tests

Run from the repository root:

```fish
julia --project=code/Xb2Continuation code/Xb2Continuation/test/runtests.jl
```

Tests cover the original three public seams (certified branch tracking,
default lifting including the S3 offset map, and lifted moments), plus the
two Stage-3 seams above. The original tests reuse the recorded geometry from
`checks/_stage2_probes.jl`; its QuadGK import is resolved through the
repository's existing `checks` environment.
The independent nearest-branch tracker and 512-bit polynomial-division
oracle remain test-only. The established HadronDynamics `J_j` moments are
requested with `order=4` (its public convenience wrapper defaults to 3).
Printed tolerances derive from oracle precision comparisons and roundoff
estimates and remain provisional under S46 (`st:tolerances`).
The graph-path tests use the independently rounded S40 pole table, exact
sheet placements and margin inequalities, plus dense vertical-energy probes.
Path quadrature integrates polynomials through degree `2n-1` and `exp(q)` on
an asymmetric polygon. Polynomial tolerances are an operation-count
roundoff allowance times the absolute weighted-sum scale. The exponential
test adds the analytic Gauss–Legendre remainder bound, independently of the
production residual, and prints the doubled-node difference.
