# Shallow-fit spurious pole: identification, removal, fit minimum, App. G numbers.
# NOTEBOOK.md, Established, Shallow-Xb fit
# Independent routes: GLOSSARY.md "Spurious pole" (predominantly hadronic member);
# [@Zhang:2026iyr] v1 Table VIII ("Not projected" row), App. G text after Eq. (G2)
# (unprojected shallow spurious pole at 10.13 GeV) and Eq. (G2) (epsilon=5 GeV shifts);
# Eq. (94) (V0 minimises Delta M at fixed E_B[X_b]).
# Mapping: literature/Zhang:2026iyr/bridge.md; GeV natural units.

include(joinpath(@__DIR__,"..","code","HadronDynamics.jl","examples","bochiEFT","shallow_fit.jl"))
results = ShallowFitExample.referee_results()

if results === nothing
    println("FAIL shallow spurious pole: no computed result yet")
    exit(1)
end

function require(name, ok, value)
    println(ok ? "PASS " : "FAIL ", name, ": ", value)
    @assert ok name
end

# Projected pole is the predominantly hadronic member of the two lowest poles.
s = results.spurious
require("projected pole equals hadronic member [GeV]", abs(s.energy - s.hadronic_energy) < 1e-8,
        s.energy - s.hadronic_energy)
require("spurious compact probability below partner's", s.compact < s.partner_compact,
        (s.compact, s.partner_compact))
require("spurious compact probability below 5 percent", s.compact < 0.05, s.compact)
require("spurious binding momentum exceeds 1 GeV", s.binding_momentum > 1, s.binding_momentum)

# The projected shallow model keeps exactly the four physical poles below threshold.
for (epsilon, count) in results.pole_counts
    require("projected shallow poles below threshold, epsilon=$(epsilon)", count == 4, count)
end

# Table VIII "Not projected" row and App. G unprojected spurious mass.
n = results.not_projected
require("not-projected C [GeV^-2]", abs(n.C - 2.52) < 0.005, n.C)
require("not-projected Delta M [GeV]", abs(n.deviation - 0.0159) < 5e-5, n.deviation)
require("not-projected spurious mass [GeV]", abs(n.spurious_mass - 10.13) < 0.005, n.spurious_mass)

# V0 minimises Delta M with C retuned to E_B[X_b] = 1 MeV.
for (V0, deviation) in results.neighbour_deviations
    require("Delta M at V0=$(V0) exceeds fitted [GeV]", deviation > results.deviation,
            (deviation, results.deviation))
end

# App. G Eq. (G2) at epsilon = 5 GeV: 1P shift 0.9 MeV, 2P and 3P below 0.33 MeV,
# compact probabilities change by less than 0.2 percent.
g = results.appendix_g
require("1P projection shift at epsilon=5 [GeV]", abs(abs(g.shifts["chi_b1_1P"]) - 0.0009) < 5e-5,
        g.shifts["chi_b1_1P"])
for name in ("chi_b1_2P", "chi_b1_3P")
    require("$(name) projection shift at epsilon=5 [GeV]", abs(g.shifts[name]) < 0.00033, g.shifts[name])
end
for (name, change) in g.compact_changes
    require("$(name) compact probability change at epsilon=5", abs(change) < 0.002, change)
end
