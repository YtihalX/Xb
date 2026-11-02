# The start of the OME left-hand cuts in 1++, from the singularity-map code.
# Seam: the branch points of the on-shell projected OME V_11(k, k; E), B Bbar*(3S1),
# E = k^2/(2 mu_PV), as located by the map code from the full TOPT kernel (mass
# splitting, recoil and energy dependence kept), pion and eta exchange separately.
# Route: literature value, Zhang:2026iyr v1, Eq. (9): kappa_lhc = 65 and 273 MeV for
# pi and eta, printed to 1 MeV (its Eq. (8) is the static-limit formula behind them).
# The start is the real branch point below threshold nearest to it; that it starts a cut
# is checked on the imaginary k axis: V_11 jumps across it 1% above kappa_lhc, not 1% below.
# Expected: round(kappa) = 65 and 273 MeV; jump above, none below.
# Run: julia --project=checks --startup-file=no checks/lhc_1pp.jl
using HadronDynamics
const B = HadronDynamics.BOchiEFT
model = B.OMEInteraction(B.Parameters(); channels=B.channels_1pp())

failed = false
function report(ok, text)
    global failed |= !ok
    println(ok ? "PASS " : "FAIL ", text)
end

# --- input: the guarded singularity-map code ---
branch_points(meson) = B.on_shell_cut_points(model, 1, 1, 0.0; meson)
reduced_mass = try B.channel_kinematics(model)[1].reduced_mass catch; NaN end
# --- end input ---

function on_shell_potential(k, meson)
    mphi = meson == :pion ? model.parameters.mpi : model.parameters.meta
    single = B.OMEInteraction(B.Parameters(mpi=mphi, meta=mphi); channels=B.channels_1pp())
    B.ome_potential(single, 1, 1, k, k, k^2 / (2reduced_mass))
end

for (meson, printed) in ((:pion, 65), (:eta, 273))
    points = try
        branch_points(meson)
    catch err
        report(false, "$meson: singularity-map code unavailable ($(sprint(showerror, err)))")
        continue
    end
    below = [z.E for z in points if abs(imag(z.E)) <= 1e-12 && real(z.E) < 0]
    if isempty(below)
        report(false, "$meson: no real branch point below threshold")
        continue
    end
    start = maximum(real, below)
    kappa = sqrt(-2reduced_mass * start)
    report(round(Int, 1e3kappa) == printed,
        "$meson: lhc starts at kappa = $(round(1e3kappa, digits=3)) MeV (Zhang:2026iyr v1, Eq. (9): $printed MeV)")
    jump(k) = abs(on_shell_potential(1e-9 + im * k, meson) - on_shell_potential(-1e-9 + im * k, meson))
    scale = abs(on_shell_potential(im * kappa, meson))
    above, under = jump(1.01kappa), jump(0.99kappa)
    report(above > 1e-3scale && under < 1e-6scale,
        "$meson: jump across the imaginary k axis $(round(above / scale, sigdigits=3)) at 1.01 kappa, " *
        "$(round(under / scale, sigdigits=3)) at 0.99 kappa (relative to |V_11(i kappa)|)")
end
failed && exit(1)
