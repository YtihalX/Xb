#import "../../../preamble.typ": *
#show: note.with(
  title: "FTCF speech",
  author: "",
  date: datetime(year: 2026, month: 11, day: 17),
)

// Math helpers: bra(psi), ket(psi), braket(phi, psi), mel(phi, A, psi),
// avg(A), dv(f, x), pdv(f, x), qty(10, GeV); also MeV.
// Built-ins: abs(x), norm(v), bold(p), mat(a, b; c, d).
// Label an equation: $ ... $ <eq-name>; refer with @eq-name.
// Cite with @Zhang:2026iyr; specify the version and equation in prose.
// FTCF-note-v2: your FTCF-note.typ unchanged, plus highlighted additions for the charm sector and the conclusions.

My talk is about our recent research about BO$chi$EFT which handles two different sources of information simultaneously. #highlight[The approach is general: it applies to any heavy quark, charm as well as bottom.]

Our knowledge of nonperturbative QCD relies both high energy experimental data and first-principle lattice calculations.

The lattice method provides unique access to quantities unreachable in experiments like static $Q macron(Q)$ potentials that gives us information short range physics.

While the line shapes and branching fractions from experiment give us information for long-range physics.

However incorporate two sources of information in a single unified approach faces challenges since there are two different degrees of freedom operating at different distance scales: quarks and gluons at short distances versus hadrons at long distances.

We propose a novel theoretical framework dubbed born-oppenheimer chiral effective field theory to combine hadronic effective field theory with the scale separation under BO approximation for dynamics of slow heavy quarks and fast light quarks and gluons.

Compared with BOEFT, in which a coupled schrodinger equation is solved in coordinate space. They have direct correspondence to lattice potentials, yet lack  of connection to hadronic degrees of freedom  as well as long range physics.

In our BOchiEFT we take care of long range physics and hadronic dynamics rigorously via well developed chiral EFT. Though connection to short range physics remains nontrivial

But the hope is that we will be able to merge both approaches to a systematically improvable method. #highlight[And this holds for all heavy quarks.]

*As a proof of concept application at LO* We consider the scattering of BB\* bar system in 1++ section via such a potential that, t-channel meson  exchanges from chiral EFT takes care of long range physics and parameters taking value from lattice results.

plus an s-channel exchangge of bottomonium states, whose parameters are extracted from lattice-QCD calculations, yet comes with one undetermined parameters.

As well as a short range contact interaction to absorb higher order effects and together with  parameter from bottomonium potential to be fixed to the experimental spectrum of chi b1. #highlight[Bottomonium is our first test case; the construction is the same for charmonium.]

*The information encodes short range physics* that enter bottomonium potential comes from a Schrodinger equation, which at leading order, uses a static spin-independent color singlet cornell potential. In agreement with the lattice-QCD study we use their values of the physical parameters. While V0 provides a  global offset, it's left to be fitted. For the b quark mass in quark model, we adopt 4.534GeV #highlight[Since the static potential does not depend on the heavy-quark flavour, the same potential applies to charmonium, with $m_c$ instead of $m_b$.]

here we use bbbar nP to denote bottomonium states with 1++ quantum numbers, at leading order it  only couple to S-wave BB*bar mesons, the wave function of the physical states reads

The probability of finding compact bottomonium components in bound state wavefunction is given by

Together the S-wave short range potential is

The coupling constant g is defined via the matrix element of the transition operator g between the bottomonium state and meson pairs, where we used the Frank condon approximation, in heavy light mesons heavy quarks carries most of the  momentum, so the momentum of mesons goes into the wavefunction of the bottomoinum wavefunction.

And the form factor is

At LO the quarkonium states only couple to S-wave channel, but OME couples both S and D wave channels with quantum number 1++, so here we have 3 channels and 4 different 3-body intermediate states.

*Let Q stand for a momentum scale below the EFT hard scale*, in our power counting the vertex couples mesons and bottomonium scales as zeroth order of Q. For states near the threshold the exchange propagator is kinematically enhanced to Q to negative power of 2, such states must be included in the sum of bottomonium tower. For states  far away from the threshold both the propagator and exchange contribution counts Q to zeroth order, these contributions can be absorbed into the zeroth order local counterterm C.

B mesons emit light pseudoscalar mesons in P wave, each chiral vertex counts order of Q, two vertives combined with the meson propagator gives a total of zeroth order in OME potential. The pi and eta exchanges include left hand cuts within the energy range of interest, their effects cannot be expaned into a derivative based local operators so it should be included explicitly. This OME interaction must be accompanied by a short range contact term that  encapsulates dynamics of integrated out modes like strange B mesons.

Proceeding to  higher orders would imply momentum dependent counterterms and multi meson exchanges, the quark antiquark states should be calculated using an higher order interquark potential.

*To exploit the advantage* of BO separation in the slow heavy-quark dynamics and fast light dynamics, at leading order, the heavy and anti heavy sources are static and define a spatial axis r hat, giving us the so called BO symmetries, which contain cylindrical symmetry, PC parity and reflection symmetry with their corresponding quantum numbers Lambda, eta and sigma. In the heavy quark limit the eigenenergier of LDF at different fixed separation r define a r dependent static BO potential. Both quantum numbers of light and heavy degrees of freedom in the final state can be either 0-+ or 1--, yet only 1-- for both give us wanted 1++.

with 1-- of light degrees of freedom we can have both sigma g plus prime and pi g configurations which will determine the coupling of bottomonium states to S-wave mesons.

D-wave meson pairs make things a little bit complicated, in partial wave channels we have two D wave channels with different total spin, 1 or 2. Yet S is not a compatible quantum number with Lambda, since they do not commute, we can now couple light spin with orbital angular momentum first and label it as capital J sub l, for the JPC equals 1 plus plus the BO configurations can be labeled by J_l and lambda_l , J_l = 1, lambda_l = 0 gives sigma g plus prime, and lambda_l = plus minus 1 J_l = 1 or 2 for two different Pi g states.

An orthorgonal transformation connects the two basis. Fort fixed heavy sources, the two pi configurations share the same static potential, the partial channel potential can be expressed in the static potentials using the orthorgonal transformation.

In the local static limit, the sigma and pi potentials become degenerate as r-> 0 and appproach the same meson-pair threshold at large distances, but may differ significantly at intermediate distances.

In BO chi EFT the long range interaction is described by OME potential and contribute to radial potential in static limit.

The short range interaction is parameterized by a derivative expansion of local operators, since the two hadron states are taken as dynamical degrees of freedom without resolving the internal structure at short distances. At leading order it's  a constant contact term only in S wave. Higher orders would include contact terms with additional powers of in and out momentum , which in coordinate space correspond to delta function and derivatives.

*The input for the interquark potential and the quarkonium coupling to open-flavor channels* aare  obtained from the unquenched lattice sstudies of static quark-antiquark pair, corresponding to the heavy quark limit. @Bulava:2024jpj investigates the static potential between bottom quark and antiquark, including string-breaking effects by light quark pairs, with the coupling sqrt 2 gl, due to BO symmetry, to get the real coupling, we need to project the pseudoscalar mesons into bases with definete lambda_l, then we need the same quantum number as the string which is 10 10 here, so an additional 2 is multiplied, as well as a 1 over sqrt 3 from the coupling of sigma to S wave. #highlight[Since the lattice works with static sources, the same input applies to charm.]

*now with all the ingredient* obtained, we solve the BOchiEFT to Xb, the LO potential in 1++ sector is and the LSE reads with nonrelativistic two-body green's function as. And we work in the isospin limit, the two free parameters C and V0 are fitted to minimize the mean square of mass deviation two bottomonium spectrum #highlight[The $X_b$ is the bottom partner of the $X(3872)$; in the charm sector the same construction applies with $D$ mesons instead of $B$ mesons.]

There two types of solutions are found, one gives delta M 0, indicates that the predominantly molecular Xb corresponds to the state with mass 10.513 GeV, a predominantly compact state is also predicted between it and the threshold. While there's another scenario taht Xb lies just below the threshold which is the case found in BOEFT studies, can be realizd by tuning the contact term C to place Xb to 1MeV below threshold, in this case delta M is given to be 15MeV

*To conclude*, this plot shows how the two scenarios are connected. Here we keep $V_0$ at its deeply bound value and vary only the contact term $C$. The right edge of each panel is the deeply bound scenario, the left edge is the shallow one. As $C$ changes, the two states near the threshold undergo an avoided level crossing and exchange their compact bottomonium content, as you can see in the lower panel. In the left panel there is also a deep spurious pole coming from the $1\/r^3$ behaviour of the OME tensor force; this is well known from chiral nuclear forces, and we remove it with the projection method, which gives the middle panel.

*Let me conclude* with this picture. Lattice QCD gives us the static quark-antiquark potentials and string breaking, experiment gives us masses and line shapes, and BO$chi$EFT brings the two together to describe hadrons with charm or bottom quarks: their spectrum, and whether they are compact or molecular.

We propose a new approach, BO$chi$EFT, for ordinary and exotic hadrons containing heavy quarks, and it is firmly anchored in chiral EFT. It combines chiral EFT in momentum space with the BO separation of slow heavy quarks and fast light degrees of freedom, so it accounts not only for the coupling of quarkonia to open-flavour channels but also for the meson-exchange interactions between the mesons.

Its strong point is that it extracts information on hadronic states from both lattice QCD and experimental data, in one framework.

Our goal is an accurate and systematically improvable approach. Thanks to the power counting, the full chiral force, including three-body cuts, can be included order by order, and the higher orders will also give us an estimate of the theoretical uncertainties.

The approach is general and applies to all heavy quarks. Bottomonium was our first proof-of-concept test, and it already gives a nontrivial result: the state at 10.513 GeV, long regarded as the $chi_(b 1)(3P)$, can be a predominantly molecular $X_b$, the bottom partner of the $X(3872)$, and a predominantly compact state is predicted at 10.544 GeV, about 60 MeV below the $B macron(B)^*$ threshold.

The work on exotic states in the charmonium spectrum is under way. Here precise data on charmonium-like states from a charm-tau factory will be very important for this approach, both as input and as a test. Thank you for your attention.

#bibliography("../../../refs.bib", style: "american-physics-society")
