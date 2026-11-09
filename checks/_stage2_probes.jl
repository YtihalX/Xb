# Helper, not a check: the recorded probe set of the Stage-2 gate, shared by
# checks/moments_straight_x.jl, checks/moments_deformed_x.jl, checks/moments_winding.jl
# and checks/branch_gate.jl.
# Source: notes/07-continued-lse.tex, S45 (st:gate2); NOTEBOOK.md, Decisions, Checks per
# stage; details chosen by the user on 2026-11-05 ("Three paths, two E").
# Units GeV, energies measured from 2 m_{B*}. Every path is a graph path of depth 0.2 GeV:
# a first leg to 0.010-0.200i (slope 20, the recorded steep leg), 0.300-0.200i (slope 2/3)
# or 0.600-0.200i (slope 1/3), flat to 1.5-0.2i, then up to Lambda = 4 GeV. Each segment
# carries 16 Gauss-Legendre nodes: 48 nodes and 2304 kernel pairs per path.
using QuadGK: gauss
using HadronDynamics: BOchiEFT

const PROBE_PATHS = (
    steep=ComplexF64[0, 0.010 - 0.200im, 1.5 - 0.2im, 4.0],
    gentle_2_3=ComplexF64[0, 0.300 - 0.200im, 1.5 - 0.2im, 4.0],
    gentle_1_3=ComplexF64[0, 0.600 - 0.200im, 1.5 - 0.2im, 4.0],
)
const PROBE_ENERGIES = (-0.06785 - 0.100im, -0.02262 - 0.050im)
const PROBE_MESONS = (pi=BOchiEFT.Parameters().mpi, eta=BOchiEFT.Parameters().meta)
const NODES_PER_SEGMENT = 16

# Polygon point at parameter u in [0, number of segments], linear on each segment.
function path_point(vertices, u)
    nseg = length(vertices) - 1
    k = clamp(floor(Int, u), 0, nseg - 1)
    vertices[k+1] + (u - k) * (vertices[k+2] - vertices[k+1])
end

# Node parameters u, ascending: Gauss-Legendre nodes mapped onto each segment [k, k+1].
function probe_parameters(vertices)
    x, _ = gauss(NODES_PER_SEGMENT)
    [k + (xi + 1) / 2 for k in 0:length(vertices)-2 for xi in x]
end

probe_nodes(vertices) = [path_point(vertices, u) for u in probe_parameters(vertices)]
