# Route 3: note 07 S21, explicit polygonal x-contour quadrature for every
# recorded pair whose x0 or candidate x1 crossed the straight segment.
# Signed actual-pole passages fix a lasso representative of the pushed contour;
# the integrand, including its square root continued from x=-1 along every
# polygon edge, is integrated directly. No residue formula is used.
# Regular squared-equation candidates are compared too, but require no push:
# they are not singularities on the continued integrand's square-root sheet.
# Run: julia --project=checks checks/moments_deformed_x.jl
using Xb2Continuation
include(joinpath(@__DIR__, "_stage2_probes.jl"))
include(joinpath(@__DIR__, "_xplane.jl"))
using .XPlaneChecks
run_xcheck(Xb2Continuation,PROBE_PATHS,PROBE_ENERGIES,PROBE_MESONS,probe_nodes;deformed=true) || exit(1)
