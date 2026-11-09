# Slide-continuation handoff

Agreed with the user on 2026-11-08 through grilling. Status: scope agreed; implementation not started. The user explicitly chose **save the handoff**, not implementation in this session.

This is task bookkeeping, not a physics source or a derivation.

## Contract

- Complete `learning/pre/slides-continue.tex`, including every explicit placeholder and conceptual question.
- Preserve the user's order and operator-based derivation route. Correct local errors and supply missing transitions rather than replacing the draft with a different treatment.
- Physics and purpose first; assumptions, domains and all intermediate algebra afterward. Assume graduate quantum mechanics, operators, scattering and angular momentum. Introduce the relevant EFT/chiral ingredients as inputs; constructing the entire chiral EFT from symmetry is outside this task.
- Retain full energy-dependent TOPT OME. Distinguish its dynamical use from the local static limit used for BO matching; do not silently make a static approximation in the scattering or probability sections.
- Keep the existing presentation style and conceptual progression as the eventual slide target. Slide design and slide modification are a later task.
- Leave `learning/pre/slides/main-v2.typ` and the finished paper `Xb.tex` untouched. No commits. Later slide work should use a new file rather than overwrite v2; do not create that file now.
- No new fits, spectrum predictions or extension to resonance probabilities.
- Halt at a genuinely unsettled physics choice or a suspected inconsistency in the source. Explain the evidence and ask the user; do not silently repair the paper or adopt a new convention.

## Sources and conventions

Read `NOTEBOOK.md`, `GLOSSARY.md` and `CONVENTIONS.md` at the start of implementation. The binding conventions identify the baseline paper as Zhang:2026iyr v1. Use the read-only local `Xb.tex` for the requested paper formulas, not the user's learning notes as a physics authority. Follow the established LSE sign, radial measure, channel phases, energy origin and symbol disambiguations. New binding terminology or notation needs user approval.

Useful source anchors, recorded from the present file and to be relocated if its lines change:

- `Xb.tex:508-670`: BO/partial-wave matching; especially the static potential at 541-581, Fourier–Bessel transform at 585-616, and short-range expansion/counting at 618-670.
- `Xb.tex:908-941`: separable interaction and its ingredients.
- `Xb.tex:943-1133`: OME construction; especially the TOPT figure around 946-970 and chiral interaction/vertices/three-body channels at 972-1018.
- `Xb.tex:1138-1224`: LSE, dressed vertices, reduced amplitude and loop matrix.
- `Xb.tex:1297-1370`: sectors, bound-state decomposition and component definitions.
- `Xb.tex:2288-2546`: pole residues and component probabilities; especially compact amplitudes at 2383-2406, three-body elimination at 2409-2466 and the loop derivative at 2468-2546.

These anchors are navigation, not a claim that the derivations have been independently checked.

## Work packages, in the draft's order

### 1. BO to partial-wave potential

- Reintroduce the existing transformation matrix and channel ordering clearly enough that the continuation can be followed with the current slides.
- Explain the physical content of the BO diagonal potential and its common-potential plus rank-one-splitting decomposition.
- Carry out the matrix multiplication explicitly, then identify the central and tensor radial potentials and their channel matrix.
- Use the **meson-pair** label `Sigma_g^{+prime}` consistently. The draft currently writes the unprimed compact-string label in this matching block; distinguish the two rather than propagating that error.
- State the heavy-quark/static-limit assumptions and distinguish the potential matrix from the centrifugal and threshold terms of the radial Hamiltonian.

### 2. Why the LO contact is constant; what the short-distance coefficients mean

- Explain what is being matched: unresolved short-range meson-pair dynamics, represented by a local derivative expansion, while the long-range interaction is supplied explicitly.
- Starting from the normalized partial-wave states, show the Fourier–Bessel transform, its phases and the small-argument spherical-Bessel expansion.
- Derive the momentum suppression for S–S, S–D and D–D short-range interactions. Show why the non-derivative LO contact is constant and acts only in channel 1.
- Explain the purpose of the paper's `C_{T,n}^{<}` as moments of the unresolved short-distance tensor potential; derive the displayed coefficients and channel relations rather than merely copying them.
- Separate centrifugal momentum suppression from the additional short-distance multipole hierarchy and its assigned power counting. State the paper's assumptions and scheme dependence. Do not present its additional counting assignment as necessary to establish the basic constant-contact result.
- Keep the static BO matching discussion distinct from adding interaction terms: it must not suggest adding the matched static potential again on top of OME and the contact interaction.

### 3. Fields, chiral vertices and TOPT intermediate states

- Define the heavy-meson and antimeson fields, spin/flavour indices, axial field, pseudoscalar matrix, coupling and decay constant.
- Correct the displayed pseudoscalar matrix against the source: its first diagonal entry is missing its eta term, its upper-right entry is missing the charged pion, and its lower-right eta coefficient is wrong.
- Expand the given LO chiral Lagrangian to one pseudoscalar field and evaluate the spin traces, with intermediate steps and antiparticle signs.
- Derive and define the two vertex types, their polarization structures and momentum routing.
- Include the requested TOPT diagrams, identify all four intermediate-state classes, and explain how their energy denominators enter the OME potential.
- Explain why the tensor/polarization dependence couples the listed S and D waves and how the partial-wave projection is defined. Define every object in the displayed projection formula.

### 4. Isoscalar OME combination

- Derive the pion and eta flavour weights explicitly in the established meson–antimeson and C-parity conventions.
- Obtain the requested channel-matrix relation with weights 3 and 1/3, keeping flavour factors distinct from the diagram/spin-kernel signs.
- Perform the selected independent check below.

### 5. Separable reduction and two-potential formula

- Define the free resolvent, its outgoing prescription, integration measure, finite-rank map and channel embedding. Keep the convention `T = V - V G T` throughout.
- Treat compact exchange **and contact together** as the separable part wherever the derivation uses that split.
- Explain why a separable interaction permits a separable solution and precisely which assumptions are required for existence, uniqueness and recovering the reduced equation. Do not cancel finite-rank maps without justification; distinguish a redundant representation from an independent basis.
- Give the reduced equation before using inverse formulas. State the additional conditions needed for each inverse and explain how poles or vanishing couplings are handled without assuming an invertible coupling matrix everywhere.
- Preserve the user's derivation via the OME scattering state, dressed resolvent and auxiliary transition operator. Supply all resolvent identities and operator-ordering steps.
- Correct the OME-only scattering-state identity that currently uses the full `T` instead of `T_U`. Make the auxiliary reduced-amplitude notation consistent instead of switching unexplained between sigma and tau.
- State the domains of the inverse identities and the meaning of the geometric expansions; do not imply their naive series converge at every energy.
- Derive the full two-potential formula and then its radial/channel representation, including both dressed vertices and all forms of the J matrix requested from the paper.
- Explain the physical separation between OME background and the dressed compact/contact contribution before discussing the computational benefit of a finite matrix inversion.

### 6. Probabilities through pole residues

The user selected the full connection to the scattering solution, not only sector identities.

- Extend the existing projector/elimination route to three mutually orthogonal sectors: compact, two-body and three-body. State how this extends the earlier two-sector treatment without editing the frozen slides.
- Write the sector equations and eliminate compact and three-body amplitudes separately. Make the vertex assumptions and the energy dependence of the effective interaction explicit.
- Derive compact, individual two-body and three-body norms, their sum rule and their energy-derivative identities, with all intermediate steps and signs.
- Interpret these as probabilities for normalized bound states, as in the source. Do not extend that interpretation to resonances.
- Connect the bound-state vertex/wave function to the reduced amplitude's pole residue and derive its normalization.
- Derive the J derivative and its decomposition into two-body and three-body contributions; connect the compact contribution to the derivative of the compact exchange.
- Define and explain the paper's S-wave compositeness, including its three-body part, and state the limitations of a component/probability interpretation rather than suggesting every component is an observable.

## Independent check authorized by the user

**Only the isospin-factor check was selected.**

Use an explicit charged/neutral flavour-channel calculation and compare the isoscalar eigenvalue with total-isospin algebra, including the eta identity coupling. Track the antiparticle convention and distinguish flavour factors from the sign already carried by the dynamical OME kernel. The target is the relative pion/eta weights 3 and 1/3 in the stated channel convention.

Follow the project's `cross-check` workflow. An executable check worth rerunning belongs in `checks/`; use exact algebra where practical and follow existing dependency conventions. Record the route, assumptions, command/calculation and observed outcome.

The user did **not** select the proposed BO/contact Fourier–Bessel check, direct finite-matrix LSE check or explicit three-sector Hamiltonian normalization check. Do not execute or claim those without further approval. The remaining derivations should be fully written and compared with the source, but must not be described as independently checked. Building and inspecting the document are document validation, not additional physics checks.

## Completion criteria for implementation

- Every existing placeholder and explicit conceptual question in `slides-continue.tex` is resolved; all requested definitions, vertices, diagrams and formulas are present.
- The user's order and operator route remain recognizable, with physics motivation preceding technical details.
- All assumptions, domains, normalizations, signs and intermediate steps needed to reproduce the requested derivations are stated.
- `just tex learning/pre/slides-continue.tex` builds the final PDF with no undefined citation or reference; inspect the rendered document for legibility and diagram/equation layout.
- Report the selected isospin check's actual outcome, and distinguish source comparison from independent verification elsewhere.
- Update `NOTEBOOK.md` with the actual result and show its diff. Follow the history rule if the user accepts a substantive superseded result or decision.
- No edits to the deck or finished paper; no commits or new numerical predictions.

## Next-session starting instruction

Read this handoff, the current notebook and binding conventions, then the continuation draft and relevant frozen-paper sections. Implement the agreed continuation only. The scope is already confirmed; ask only at a new physics choice or source inconsistency. Slide modification remains a separate later task.
