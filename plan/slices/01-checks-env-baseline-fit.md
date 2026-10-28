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
Output: table of the $1^{++}$ inputs: the parameters $m_b$, $\sigma$, $\gamma$, $V_0$, $C$, $g$, $N$, $\Lambda$, and the four states (mass, $E_B$, $\mathcal P_{\bar bb}$) → `paper/sections/framework.tex`
Blocked by: none
Status: claimed
