# Bare-state form factors f_n(p) at complex momentum.
# Seam: f_n(p) = sqrt(4pi)/p int_0^inf dr u_n(r) sin(pr), Zhang:2026iyr v1, Eq. (A10),
# evaluated off the real axis (CONVENTIONS.md "Bare-state term off the real axis").
# Routes:
#  - a second representation: the momentum-space (Nystrom) wave function with the
#    matched Cornell tail, against the coordinate-space route of Eq. (A10), N <= 4;
#  - convergence of the coordinate route in its box size and tail radius, N = 4-7,
#    and in its radial grid (the production grid's precision at complex p);
#  - Schwarz reflection f_n(p*)^* = f_n(p) of a real radial function.
# Grid: Re p in [0, Lambda] with Lambda = 4 GeV, |Im p| <= 1 GeV, step 0.25 GeV.
# Tolerances, fixed before the guarded step:
#  - representations: 5e-6 relative to max(|f_n(p)|, max_real |f_n|). Stated, not the
#    1e-6 default: measured before the step (scratch probe, internal sums), the matched-
#    tail evaluator itself moves by 3.5e-6 between its default (600) and 900 Nystrom nodes
#    at |Im p| = 1 GeV, against the 96000-point coordinate route.
#  - radial grid, production 12000 points against 96000: 1e-5 on the same scale
#    (measured before the step: 7.6e-6 at |Im p| = 1 GeV). This is the stated precision of
#    the production f_n off the real axis.
#  - box (30 -> 34 GeV^-1 at fixed step) and tail (36 -> 42 GeV^-1): 1e-6 on the same scale.
#  - Schwarz reflection: 1e-10 relative to |f_n(p)|.
# Inputs: the baseline-fit Cornell parameters, code/HadronDynamics.jl/data/bochiEFT/central.toml.
# Run: julia --project=checks --startup-file=no checks/drafts/complex_form_factors.jl
using HadronDynamics, TOML
const B = HadronDynamics.BOchiEFT
config = TOML.parsefile(joinpath(pkgdir(HadronDynamics), "data", "bochiEFT", "central.toml"))
const mb = config["model"]["mb"]
const sigma = config["model"]["sigma"]
const LAMBDA = config["numerics"]["cutoff"]
const GRID = [complex(x, y) for x in 0.0:0.25:LAMBDA, y in -1.0:0.25:1.0]

failed = false
function report(ok, text)
    global failed |= !ok
    println(ok ? "PASS " : "FAIL ", text)
end

# --- input: the package's evaluators of Eq. (A10) at complex p, supplied by the guarded step ---
evaluate(provider, p) = B.form_factors_at(provider, p)
# --- end input ---

function probe(provider, label)
    try
        evaluate(provider, complex(0.5, -0.5))
        return true
    catch err
        report(false, "$label: f_n at complex p unavailable ($(sprint(showerror, err)))")
        return false
    end
end
realscale(provider, n) = maximum(abs(evaluate(provider, complex(x))[n]) for x in range(0, LAMBDA, length=33))

function compare(a, b, nstates, tolerance, label)
    scale = [realscale(b, n) for n in 1:nstates]
    worst = zeros(nstates)
    where = fill(0.0im, nstates)
    for p in GRID
        x = evaluate(a, p)[1:nstates]
        y = evaluate(b, p)[1:nstates]
        for n in 1:nstates
            e = abs(x[n] - y[n]) / max(abs(y[n]), scale[n])
            e > worst[n] && (worst[n] = e; where[n] = p)
        end
    end
    for n in 1:nstates
        report(worst[n] <= tolerance,
            "$label, n=$n: max relative deviation $(round(worst[n], sigdigits=3)) at p=$(where[n]) (tolerance $tolerance)")
    end
end

coordinate_fine = B.form_factors(; mb, sigma, nstates=4, backend=:coordinate,
    coordinate_ngrid=96000, coordinate_nr_interior=1600)
coordinate_production = B.form_factors(; mb, sigma, nstates=4, backend=:coordinate)
matched_tail = B.form_factors(; mb, sigma, nstates=4, backend=:momentum, matched_tail=true,
    nquad=900, nr=900)

if probe(coordinate_fine, "coordinate route, Eq. (A10)") && probe(matched_tail, "matched-tail evaluator")
    compare(coordinate_fine, matched_tail, 4, 5e-6,
        "Eq. (A10) coordinate route (96000 points) vs matched-tail evaluator (900 nodes)")
    compare(coordinate_production, coordinate_fine, 4, 1e-5,
        "production radial grid (12000) vs 96000")
    seven = B.form_factors(; mb, sigma, nstates=7, backend=:coordinate)
    box = B.form_factors(; mb, sigma, nstates=7, backend=:coordinate,
        coordinate_box_rmax=34.0, coordinate_ngrid=13600)
    tail = B.form_factors(; mb, sigma, nstates=7, backend=:coordinate, tail_rmax=42.0)
    compare(box, seven, 7, 1e-6, "box 30 -> 34 GeV^-1, N=7")
    compare(tail, seven, 7, 1e-6, "tail 36 -> 42 GeV^-1, N=7")
    reflection = maximum(maximum(abs.(conj.(evaluate(provider, conj(p))) .- evaluate(provider, p)) ./
                                 abs.(evaluate(provider, p)))
                         for provider in (seven, matched_tail), p in GRID if imag(p) != 0)
    report(reflection <= 1e-10,
        "Schwarz reflection f_n(p*)^* = f_n(p) on the grid, N = 7 coordinate and N = 4 matched tail: max relative deviation $(round(reflection, sigdigits=3)) (tolerance 1e-10)")
end
failed && exit(1)
