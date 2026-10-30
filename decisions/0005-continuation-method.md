# Poles off the physical sheet come from a deformed loop contour

Decided by: you
Date: 2026-10-30
Source: the grilling session of 2026-10-29/30

Poles off the physical sheet, narrow and broad, are found by solving the LSE on an admissible contour from $0$ to $\Lambda$ (CONVENTIONS.md "Continuation to other sheets"). The sharp cutoff rules out complex scaling to infinity, and App. D of [@Wu:2026wxb] v1 shows that keeping the real axis needs explicit cut terms once $|\operatorname{Im}k_\alpha|>m_\pi$. The package's on-shell-point route, with the on-shell momentum $k_\alpha$ made complex, is kept as an independent cross-check where it is valid, $|\operatorname{Im}k_\alpha|<m_\pi$. Kernel branches follow the split-log rule (CONVENTIONS.md "Continued angular moments"), checked by an independent continuity tracker; $f_n$ off the real axis follows [@Zhang:2026iyr] v1, Eqs. (A10)–(A12), with the bilinear form of its footnote 13 (CONVENTIONS.md "Bare-state term off the real axis").

Scope:
- On-shell couplings of bound states are not computed. Every Table V state ($\kappa\ge0.57$ GeV) lies on the OME left-hand cut, which starts at $\kappa_{\rm lhc}=65$ MeV ([@Zhang:2026iyr] v1, Eq. (9)). There the on-shell residue is complex and depends on the side of the cut. Composition stays $\mathcal P_{\bar bb}$; resonance couplings follow CONVENTIONS.md "Resonance couplings".
- The three-body singularity locator is built and tested so that §II can use it. No charm channel, $D^*$ width or three-body unitarity is built; decisions/0003 is unchanged.
- A target pole with no admissible contour is reported together with its obstruction (which singularity, where), and the work stops for your decision.

## Considered options

- The on-shell-point route alone: exact on the real axis, but limited to $|\operatorname{Im}k_\alpha|<m_\pi$, about $\Gamma\lesssim50$ MeV for a shallow-fit $X_{b2}$ decaying to $B\bar B^*$ (linearised estimate).
- App. D's indented contour $C_R'$: the real grid plus $2\pi i$ integrals along every crossed cut. It needs $T$ at complex points along each cut, for $\pi$ and $\eta$, both time orderings and every channel pair.
- Complex scaling $q\to qe^{-i\theta}$ out to infinity, which the sharp cutoff excludes.
- The contour route without a second route.
- Bound-state couplings on the upper side of the left-hand cut, App. D cases (c)/(d).

## Consequences

CONVENTIONS.md "Continuation to other sheets", "Bare-state term off the real axis", "Continued angular moments", "Resonance couplings"; plan claim 2 and slices 05–07; `paper/sections/app-continuation.tex`; in the package, `src/common/ExchangeMoments.jl` (the log of a ratio is replaced), `src/common/MomentumDynamics.jl` (adjoints become transposes; contour meshes; sheet labels), `src/common/cornell_coordinate.jl` (complex $p$).
