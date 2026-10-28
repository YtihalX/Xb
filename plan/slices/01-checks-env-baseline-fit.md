# 01: Checks environment and the baseline fit reproduced

Claim: We show that the HadronDynamics.jl BOχEFT model, run from this project's checks, reproduces the baseline fit. That means the four $1^{++}$ states of [@Zhang:2026iyr] v1, Table V (the $\chi_{b1}(1P)$- and $\chi_{b1}(2P)$-dominated states, the $X_b$, the $\chi_{b1}(3P)$-dominated state) from the full-precision parameters of its $\Lambda=4$ GeV fit. As checked out, the package does not load under Julia 1.13.3 ("failed to find source of parent package: ArrayInterface"). So the slice first makes it load and gives the checks a Julia environment that uses the submodule.
Assumptions:
- [CONVENTIONS.md](../../CONVENTIONS.md): "Units", "Energy origin and on-shell momentum", "Partial-wave states", "Loop measure and regulator", "Lippmann–Schwinger equation", "Bare–continuum vertex", "Separable s-channel and contact potential", "Quark–antiquark Hamiltonian".
- [GLOSSARY.md](../../GLOSSARY.md): "Baseline fit", "Isospin limit", "Compact probability".
- [decisions/0004](../../decisions/0004-quark-model-fixed.md): code hadron masses, $\mu_{\rm PV}=2.650950$ GeV.
Checks:
- Seam: the baseline-fit pole masses and component probabilities.
- Route: comparison with [@Zhang:2026iyr] v1, Table V and the $\Lambda=4$ GeV row of Table VI.
- Expected: masses within 1 MeV, and $\mathcal P_{\bar bb}$, $\mathcal P_S$, $\mathcal P_D$, $\mathcal P_{\text{3-body}}$ within 1% absolute.
- Red: the check fails with the uncorrected coupling $\sqrt2\,g_l$ in place of $\frac{2}{\sqrt3}\sqrt2\,g_l$.
- Check: `checks/baseline_fit.jl`; expectations fixed before computation.
  Initial red 2026-10-28: `just check` → `FAIL baseline fit: no computed result yet` (exit 1); only the new check fails.
  Coupling red 2026-10-28: set `config["model"]["coupling_convention"] = "original"` in the input block; `git diff -- checks/baseline_fit.jl` showed the mutation. `julia --project=checks checks/baseline_fit.jl` exited 1 on `AssertionError: chi_b1_2P mass [GeV]`: computed 10.256723528155927 GeV versus 10.255 GeV ± 0.001 GeV. Restored the corrected convention.
- Numerical resolution evidence: doubled `nq` 24 → 48, Cornell grid 12000 → 24000, transform quadrature 800 → 1600, retaining all physical inputs and the box/tail settings. The refined masses (1P, 2P, X_b, 3P) were 9.893264023369, 10.255276537992, 10.513276195595, 10.543615866787 GeV. Absolute shifts were 0.000135, 0.000349, 0.006017, 0.000658 MeV; the largest shift of any of the four probabilities was 0.000536 percentage points. Use 0.007 MeV and 0.001 percentage points as rounded resolution-shift estimates, not LO theory uncertainties.
  Reproduce with `julia --project=checks --startup-file=no -e 'include("code/HadronDynamics.jl/examples/bochiEFT/run.jl"); D=BOchiEFTExample; c=D.TOML.parsefile(D.DEFAULT_INPUT); D.BLAS.set_num_threads(1); c["numerics"]["nq"]=48; c["cornell"]["coordinate_ngrid"]=24000; c["cornell"]["coordinate_nr_interior"]=1600; for s in c["states"]; s["half_width_GeV"]=0.014; end; D.TOML.print(stdout,Dict("states"=>D.bound_rows(D.build_model(c),c)); sorted=true)'`.
- Package regression: `julia --startup-file=no --project=.. -e 'include("bochiEFT.jl")'` from `code/HadronDynamics.jl/test`, all five testsets green (9870 + 77 + 21 + 17 + 77 assertions).
- Environment: the original load failure was missing installed dependency sources, resolved by `Pkg.instantiate()` with authenticated Git access. The independently resolved checks lockfile initially selected GenericLinearAlgebra 0.4.0, which overwrites a Julia 1.13 LinearAlgebra method; updating that transitive package to 0.4.2 fixes precompilation without suppressing it or changing the physics.
Output: table of the $1^{++}$ inputs: the parameters $m_b$, $\sigma$, $\gamma$, $V_0$, $C$, $g$, $N$, $\Lambda$, and the four states (mass, $E_B$, $\mathcal P_{\bar bb}$) → `paper/sections/framework.tex`
Blocked by: none
Status: done

## Result

The baseline fit reproduces all four Table V masses within 1 MeV and all component probabilities within one percentage point absolute. The masses (1P, 2P, $X_b$, 3P) are 9.893264, 10.255276, 10.513270, 10.543615 GeV; the largest measured grid-refinement shift is below 0.007 MeV (probabilities: below 0.001 percentage points), not an LO theory uncertainty. Package loading required dependency instantiation, not a physics-code change.

- Derivation or computation: `code/HadronDynamics.jl/examples/bochiEFT/run.jl`, `code/HadronDynamics.jl/data/bochiEFT/central.toml`; checks environment in `checks/Project.toml` and `checks/Manifest.toml`.
- Checks: `checks/baseline_fit.jl`, green (20 assertions); both red runs recorded under Checks. Package `test/bochiEFT.jl`: all five testsets green; `just check`: green, including paper build.
- Paper: `paper/sections/framework.tex`.
- Referee: Standards 0 findings; Plan 0; Correctness 1 citation finding, resolved by correcting the axial-input reference to v1 Eq. (66) in the bridge. The bridge's state-label pointer was also corrected to CONVENTIONS.
