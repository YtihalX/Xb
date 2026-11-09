# Route 1: note 07 S21, direct straight-x quadrature on every recorded node pair
# with no x0 or candidate x1 passage in either stage of S30. The oracle never
# uses closed moments, lifted logarithms, or a residue correction.
# Run: julia --project=checks checks/moments_straight_x.jl
using Xb2Continuation
include(joinpath(@__DIR__, "_stage2_probes.jl"))
include(joinpath(@__DIR__, "_xplane.jl"))
using .XPlaneChecks
run_xcheck(Xb2Continuation,PROBE_PATHS,PROBE_ENERGIES,PROBE_MESONS,probe_nodes) || exit(1)
