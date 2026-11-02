# Spurious-pole projection at the physical-pole seam.
# NOTEBOOK.md, Established, Shallow-Xb fit
# Independent routes: [@Zhang:2026iyr] v1 App. G (epsilon=5--50 GeV),
# Sec. IV D (baseline projection shift below 1 MeV).
# Mapping: literature/Zhang:2026iyr/bridge.md; GeV natural units.

include(joinpath(@__DIR__,"..","code","HadronDynamics.jl","examples","bochiEFT","shallow_fit.jl"))
computed = ShallowFitExample.projection_results(;perturb=false)
results = merge(computed, (shallow_energies=computed.physical_energies,))

if results === nothing
    println("FAIL spurious-pole projection: no computed result yet")
    exit(1)
end

function require(name, ok, value)
    println(ok ? "PASS " : "FAIL ", name, ": ", value)
    @assert ok name
end
for (name, energies) in results.shallow_energies
    spread = maximum(energies)-minimum(energies)
    require("$(name) epsilon independence [GeV]", spread < 0.001, spread)
end
for (name, shift) in results.baseline_shifts
    require("$(name) baseline projection shift [GeV]", abs(shift) < 0.001, shift)
end
for pole in results.spurious
    require("$(pole.label) binding momentum exceeds 1 GeV", pole.binding_momentum > 1, pole.binding_momentum)
    require("$(pole.label) compact probability below 1 percent", pole.compact < 0.01, pole.compact)
end
require("spurious pole cutoff dependence [GeV]", results.cutoff_shift > 0.1, results.cutoff_shift)
