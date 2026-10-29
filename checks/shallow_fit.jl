# Shallow-Xb fit at the fitted-parameter and bound-state seams.
# Slice: plan/slices/02-shallow-fit-spurious-projection.md
# Independent route: [@Zhang:2026iyr] v1 Table VIII, projected row; Eq. (94).
# Mapping: literature/Zhang:2026iyr/bridge.md. GeV, probabilities as fractions.
const expected = [
    (name="chi_b1_1P", mass=9.884, compact=1.00, XS=nothing),
    (name="chi_b1_2P", mass=10.246, compact=0.99, XS=0.01),
    (name="chi_b1_3P", mass=10.535, compact=0.86, XS=0.13),
    (name="X_b", mass=10.60327, compact=0.08, XS=0.66),
]
# --- input: the guarded computation fills this block ---
results = nothing
# --- end input ---
if results === nothing
    println("FAIL shallow-Xb fit: no computed result yet")
    exit(1)
end
function assert_close(name, actual, target, tolerance)
    ok = isfinite(actual) && abs(actual-target) <= tolerance
    println(ok ? "PASS " : "FAIL ", name, ": ", actual,
        " (published ", target, ", absolute tolerance ", tolerance, ")")
    @assert ok name
end
assert_close("C [GeV^-2]", results.C, 2.66, 0.005)
assert_close("V0 [GeV]", results.V0, 0.362, 0.0005)
assert_close("Delta M [GeV]", results.deviation, 0.0150, 0.00005)
assert_close("X_b binding below B Bstar [GeV]", -results.states["X_b"].energy, 0.001, 1e-9)
for reference in expected
    state = results.states[reference.name]
    assert_close("$(reference.name) mass [GeV]", state.mass, reference.mass, 0.001)
    assert_close("$(reference.name) compact probability", state.compact, reference.compact, 0.01)
    if reference.XS === nothing
        ok = 0 <= state.XS < 0.01
        println(ok ? "PASS " : "FAIL ", "$(reference.name) X_S below 1 percent: ", state.XS)
        @assert ok
    else
        assert_close("$(reference.name) X_S", state.XS, reference.XS, 0.01)
    end
end
