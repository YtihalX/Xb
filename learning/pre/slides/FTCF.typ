#import "@preview/touying:0.8.0": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9", config-info(
  title: [Towards Born-Oppenheimer chiral effective field theory],
  autho: [Yu Zhang],
  institution: [Institute of Theoretical Physics, Chinese Academy of Sciences \
    University of Chinese Academy of Sciences],
))
#set text(font: "New Computer Modern", size: 18pt, lang: "en")


#title-slide[
  = Towards Born-Oppenheimer chiral effective field theory

  #v(2em)

  Yu Zhang #footnote[ITP CAS]#h(1em)
  Feng-Kun Guo #footnote[ITP CAS]#h(1em)
  Christoph Hanhart #footnote[Institute for Advanced Simulation and Cluster of Excellence "Color meets Flavor", Forschungszentrum Julich]#h(1em)
  Alexey Nefdiev#footnote[Bonn Uni]#h(1em)
  Paul Putz#footnote[Technical University of Munich]
]

== BO$chi$EFT approach to ordinary and exotic hadrons
Main sources of information on hadronic states:
- #text(fill: blue)[Lattice QCD] $->$ First principle calculations of static interquark potentials, including string breaking effects $->$ input for #text(fill: rgb("#FF6600"))[short-range physics]
- #text(fill: blue)[High-energy experiment] $->$ Line shapes and branching fractions in terms of hadronic states $->$ input for #text(fill: rgb("#FF6600"))[long-range physics]

#text(fill: red)[*Problem: How to incorporate both sources of information in a single approach?*]

#text(fill: blue)[BOEFT] (Braaten, Brambilla, et al.): Coupled Schrödinger equations in coordinate space
- #text(fill: rgb("#FF6600"))[Pro:] Direct correspondence to lattice potentials $->$ short-range physics naturally captured
- #text(fill: rgb("#FF6600"))[Con:] Missing connection to hadronic degrees of freedom $->$ long-range physics parametrised

#text(fill: blue)[BOχEFT]: Coupled Lippmann-Schwinger equations in momentum space:
- #text(fill: rgb("#FF6600"))[Pro:] Long-range physics naturally captured, including multibody effects and exchanges
- #text(fill: rgb("#FF6600"))[Con:] Connection to short-range physics is nontrivial (comes as chiral expansion in $p^2/Lambda_chi^2$)
#text(fill: red)[*Hope: Merge both approaches to unified systematically improvable method*]

== Proof-of-concept BO$chi$EFT calculation at LO
Scattering of $B macron(B)^*$system with $J^(P C) = 1^(+ +)$ via potential
$ V = V^"(OME)" + sum_(n = 1)^N V_n^((macron(b) b)) + C(Lambda, N) $
- #text(fill: blue)[_s_-channel exchange of bottomonium states] $->$ potential #text(fill: red)[$V^((macron(b) b))$]:\ Parameters of interquark interaction and strength of transition $macron(b)b ->B macron(B)^*$ can be extracted from lattice-QCD calculations
#v(0.5em)
- #text(fill: blue)[_t_-channel meson exchanges] $->$ potential #text(fill: red)[$V^"(OME)"$]:\ No free parameters
#v(0.5em)
- #text(fill: blue)[Short-range counterterm] $->$  #text(fill: red)[$C$]:\ Absorbs all neglected effects
#v(0.5em)
Remaining free parameters can be fixed to the experimental spectrum of $chi_(b 1)$ bottomonia

