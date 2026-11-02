# chi_c1(4010) width toy, mass band M = 4012.5 +- 10 MeV (toy/chi_c1_4010_width/plot.jl).
# Under test: the package's coordinate-space psi_2(p) at the band momenta, and the widths,
# node and slope d ln Gamma/dM that plot.jl prints from it.
# Route: a second method, the finite-difference radial solve of toy/chi_c1_4010_width/run.jl
# (own tridiagonal Hamiltonian, normalisation and sine transform), sign fixed by psi_2(0) > 0
# (CONVENTIONS.md "Bare–continuum vertex"). Kinematics p(M) and the width formula are shared.
# Tolerances, fixed before the comparison: half a unit in the last digit plot.jl prints,
# 5e-4 GeV^-3/2 for psi_2, 5e-3 MeV for Gamma, 0.05 MeV for the node, 0.005 %/MeV for the
# slope. The FD route's own changes under step doubling (N = 20000 -> 10000) and a larger box
# (rmax = 30 -> 40 GeV^-1 at fixed step) must stay below the same tolerances.
# Run: julia --project=checks --startup-file=no checks/chi_c1_4010_band.jl
redirect_stdout(devnull) do
    include(joinpath(@__DIR__, "..", "toy", "chi_c1_4010_width", "run.jl"))
end

failed = false
function report(ok, text)
    global failed |= !ok
    println(ok ? "PASS " : "FAIL ", text)
end

const Mshift = 0.010
const MASSES = (M - Mshift, M - Mshift / 2, M, M + Mshift / 2, M + Mshift)
const TOL_PSI, TOL_GAMMA, TOL_NODE, TOL_SLOPE = 5e-4, 5e-6, 5e-5, 5e-5  # GeV units; slope per MeV

# --- input: the result under test, psi_2 as plot.jl evaluates it ---
pkg(p) = psi_pkg(p)[2]
# --- end input ---

function fd_psi2(; kw...)
    _, psi = fd_solve(; kw...)
    s = sign(psi(1e-4)[2])
    return p -> s * psi(p)[2]
end
fd = fd_psi2()                          # run.jl defaults: N = 20000, rmax = 30 GeV^-1
fd_step = fd_psi2(N=10000)
fd_box = fd_psi2(N=26667, rmax=40.0)    # same step, larger box

gamma_of(f, m) = width(f(pdecay(m)), pdecay(m); m=m)
slope(f; h=1e-5) = (log(gamma_of(f, M + h)) - log(gamma_of(f, M - h))) / (2h) / 1000

function bisect(f, a, b; iters=60)
    fa = f(a)
    for _ in 1:iters
        c = (a + b) / 2
        fc = f(c)
        sign(fc) == sign(fa) ? ((a, fa) = (c, fc)) : (b = c)
    end
    return (a + b) / 2
end
function first_node(f; scan=range(0.01, 2.0, length=400))
    v = f.(scan)
    i = findfirst(k -> sign(v[k]) != sign(v[k+1]), 1:length(scan)-1)
    return bisect(f, scan[i], scan[i+1])
end

for m in MASSES
    p = pdecay(m)
    psi_a, psi_b = pkg(p), fd(p)
    report(abs(psi_a - psi_b) < TOL_PSI,
           @sprintf("psi_2 at M = %.1f MeV, p = %.1f MeV: package %+.6f, FD %+.6f GeV^-3/2",
                    1e3m, 1e3p, psi_a, psi_b))
    ga, gb = gamma_of(pkg, m), gamma_of(fd, m)
    report(abs(ga - gb) < TOL_GAMMA, @sprintf("Gamma at M = %.1f MeV: package %.5f, FD %.5f MeV", 1e3m, 1e3ga, 1e3gb))
end
dstep = maximum(abs(fd(pdecay(m)) - fd_step(pdecay(m))) for m in MASSES)
dbox = maximum(abs(fd(pdecay(m)) - fd_box(pdecay(m))) for m in MASSES)
report(max(dstep, dbox) < TOL_PSI,
       @sprintf("FD psi_2 on the band: step change %.1e, box change %.1e GeV^-3/2", dstep, dbox))

na, nb = first_node(pkg), first_node(fd)
report(abs(na - nb) < TOL_NODE, @sprintf("first node of psi_2: package %.4f, FD %.4f MeV", 1e3na, 1e3nb))
dnode = max(abs(nb - first_node(fd_step)), abs(nb - first_node(fd_box)))
report(dnode < TOL_NODE, @sprintf("FD node under step doubling and larger box: change %.1e MeV", 1e3dnode))

sa, sb = slope(pkg), slope(fd)
report(abs(sa - sb) < TOL_SLOPE, @sprintf("d ln Gamma/dM at M = %.1f MeV: package %.5f, FD %.5f %%/MeV",
                                          1e3M, 100sa, 100sb))
dslope = max(abs(sb - slope(fd_step)), abs(sb - slope(fd_box)))
report(dslope < TOL_SLOPE, @sprintf("FD slope under step doubling and larger box: change %.1e %%/MeV", 100dslope))
failed && exit(1)
