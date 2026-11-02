# Baseline fit: four 1++ pole masses and component probabilities.
# NOTEBOOK.md, Established, Baseline 1++ spectrum
# Independent route: [@Zhang:2026iyr] v1 Table V (dagger rows), Table VI (Lambda=4 GeV).
# Mapping: literature/Zhang:2026iyr/bridge.md, Eqs. (104)-(106).
# Units: GeV; probabilities are fractions, not percent.

const expected = [
    (name="chi_b1_1P", mass=9.893, compact=1.00, S=0.00, D=0.00, three_body=0.00),
    (name="chi_b1_2P", mass=10.255, compact=0.98, S=0.01, D=0.00, three_body=0.00),
    (name="X_b", mass=10.513, compact=0.02, S=0.41, D=0.36, three_body=0.21),
    (name="chi_b1_3P", mass=10.544, compact=0.85, S=0.14, D=0.01, three_body=0.00),
]

using HadronDynamics, TOML
include(joinpath(@__DIR__, "..", "code", "HadronDynamics.jl", "examples", "bochiEFT", "run.jl"))
const driver = BOchiEFTExample
config = TOML.parsefile(driver.DEFAULT_INPUT)
driver.BLAS.set_num_threads(config["numerics"]["blas_threads"])
# Local neighborhoods track the four named states, not a complete pole census.
for state in config["states"]
    state["half_width_GeV"] = 0.014
end
model = driver.build_model(config)
rows = driver.bound_rows(model, config)
results = Dict(row["name"] => (
    mass=row["mass_GeV"], compact=row["P_compact"], S=row["P_PV_S"],
    D=row["P_PV_D"] + row["P_VV_D"], three_body=row["P_OME_derivative"],
) for row in rows)
for row in rows
    println("RESULT ", row["name"], " mass_GeV=", row["mass_GeV"],
            " binding_MeV=", row["binding_MeV"], " P_compact=", row["P_compact"])
end

if results === nothing
    println("FAIL baseline fit: no computed result yet")
    exit(1)
end

function assert_close(name, actual, target, tolerance)
    ok = isfinite(actual) && abs(actual - target) <= tolerance
    println(ok ? "PASS " : "FAIL ", name, ": ", actual,
            " (published ", target, ", absolute tolerance ", tolerance, ")")
    @assert ok name
end

for reference in expected
    result = results[reference.name]
    assert_close("$(reference.name) mass [GeV]", result.mass, reference.mass, 0.001)
    for key in (:compact, :S, :D, :three_body)
        assert_close("$(reference.name) $(key)", getproperty(result, key),
                     getproperty(reference, key), 0.01)
    end
end
