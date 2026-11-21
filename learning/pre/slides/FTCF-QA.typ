#import "../../../preamble.typ": *
#show: note.with(
  title: "FTCF talk: possible questions",
  author: "",
  date: datetime(year: 2026, month: 11, day: 20),
)

// Q&A preparation for FTCF-visual-v2.typ. Answers are drafts in spoken form.
// "Source" gives the line in the frozen paper Xb.tex, or says that the answer is not in the paper.

#let src(body) = block(above: 0.5em, below: 1.1em, text(size: 9pt, fill: luma(100))[Source: #body])
#let pressed(body) = block(above: 0.6em)[_If pressed:_ #body]
#let careful(body) = block(above: 0.6em, text(fill: rgb("#a02020"))[_Careful:_ #body])
#let likely = text(fill: rgb("#c05000"), size: 0.85em)[\[likely\]]

*How to answer.* Two or three sentences, then stop; offer details after the session. If a question goes beyond what we did, say so: "We have not studied that yet; it is part of the next steps." Never guess a number. Keep returning to the core message: leading order, two fitted parameters, lattice and experiment in one framework, charm is next.

#table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 0.5em, y: 0.3em),
  table.hline(),
  table.header([*Numbers to remember*], []),
  table.hline(stroke: 0.5pt),
  [$B macron(B)^*$ threshold], [$10.604$ GeV (isospin limit)],
  [$X_b$ (observed $10.513$ GeV)], [$E_B = 91$ MeV; $cal(P)_(macron(b)b) = 2%$, $S$ wave $41%$, $D$ wave $36%$, three-body $21%$],
  [Predicted compact state], [$10.544$ GeV, $cal(P)_(macron(b)b) = 85%$; $10.529$–$10.549$ GeV for $m_b = 4.3$–$5.3$ GeV],
  [Fit quality], [$Delta M = 0$ (deeply bound) versus $15$ MeV (shallow, $X_b$ fixed 1 MeV below threshold)],
  [Lattice], [$g_l = 35$ MeV $->$ $g = 57$ MeV; $sigma = 0.198 "GeV"^2$, $gamma = -0.434$],
  [Scales], [$Lambda_chi approx 1$ GeV; left-hand cuts at $kappa = 65$ ($pi$) and $273$ MeV ($eta$); $X_b$ binding momentum $0.695$ GeV],
  [Variations], [$Lambda = 3$–$5$ GeV and $N = 4$–$7$: masses unchanged, $cal(P)_(macron(b)b)$ within $1%$],
  [Scattering], [deep: $a = -1.00$ fm, $r = -2.5$ fm; shallow: $a = -3.01$ fm, $r = 0.57$ fm],
  table.hline(),
)

= The approach and the charm sector

== Why bottomonium and not charmonium, at a charm–tau factory meeting? #likely

The approach is general, and charmonium is the next step. We started with bottomonium for three reasons. In the $1^(++)$ charm sector there is only one established $chi_(c 1)$ state below threshold, which is not enough to fix even the two leading-order parameters without using the $X(3872)$ itself. The charm quark is much lighter, so the corrections to the static limit are larger. And the $D macron(D) pi$ three-body cut can go on shell, which makes the calculation numerically harder.

#pressed[Once the $chi_(c 1)(4010)$ seen by LHCb @LHCb:2024vfz, proposed to be a $chi_(c 1)(2P)$-dominated state, is established, we can do the same analysis for charm, with $1 slash m_c$ corrections. The contact terms cannot simply be carried over from bottom to charm, because their heavy-quark-mass dependence is not under control.]
#src[`Xb.tex` l. 1829–1836 (the three reasons); l. 1831 (contact terms).]

== What can a charm–tau factory measure that helps this approach? #likely

Precise masses, widths and line shapes of charmonium-like states near open-charm thresholds, the $X(3872)$ and its partners in particular. Our framework contains the hadronic channels explicitly, including the three-body $D macron(D) pi$ cut, so line shapes can be fitted directly. And we need more than one $chi_(c 1)$-type state to fix the parameters in the charm sector, so every additional well-measured state counts.

#careful[Production details, such as $e^+ e^- -> gamma X(3872)$ at BESIII energies, are not in our paper. Check them before quoting.]
#src[Not in the paper beyond l. 1829–1836; general knowledge.]

== Do you use the same lattice input for charm?

At leading order, yes. The lattice works with static sources, so the static potential and the string-breaking coupling $g_l$ do not depend on the heavy flavour, and the projection factors are the same for $D macron(D)^*$. What changes is the quarkonium wave functions (with $m_c$), the meson masses and thresholds, and the fitted $C$ and $V_0$. Beyond leading order the $1 slash m_c$ corrections are sizeable and need additional input.

#src[l. 377 (static limit); l. 1831, 1834 (charm caveats). That the projection factors carry over (same BO quantum numbers for $D macron(D)^*$) is our reasoning, not stated in the paper.]

== What is new compared with coupled-channel quark models?

Those models couple quarkonia to the open-flavour channels. We also include the meson exchanges between the mesons, with the tensor force, from chiral EFT, and there is a power counting, so the hadron–hadron interaction can be improved order by order, as in the chiral EFT for nucleons. The inputs come from lattice QCD, and at leading order only two parameters are fitted.

#src[l. 1813–1816.]

== What does the Born–Oppenheimer part do at leading order?

Three things: the static potential and the coupling come from lattice calculations with static sources; the BO quantum numbers tell us which light-quark configuration couples the bottomonium to the $S$-wave meson pair, which fixes the coupling; and they relate the partial waves to the BO configurations.

#pressed[The constraints of the cylindrical symmetry on the contact terms enter only at subleading orders.]
#src[l. 377; l. 439–449; l. 1601–1602, 1817.]

= The $X_b$ result

== Isn't the 10.513 GeV state simply the $chi_(b 1)(3P)$? CMS sees the $chi_(b 2)(3P)$ 10.6 MeV above it. #likely

CMS extracted both masses from the $Upsilon(3S) gamma$ channel alone. In the $Upsilon(2S) gamma$ spectrum there is only one peak, although the resolution there, 7 MeV, is smaller than the 10.6 MeV splitting. Our result suggests that the signal in all three channels is the same state, the $X_b$. How the $chi_(b 0)$ and $chi_(b 2)$ states are affected by the open-bottom channels still has to be worked out, so the $J = 2$ question is open.

#src[l. 1732–1740, 1748; @CMS:2018vgf.]

== Where is your compact state at 10.544 GeV? Why hasn't it been seen? #likely

Two possibilities. The steep drop of the CMS data in that mass region may come from the interplay of two states with the same quantum numbers, the $X_b$ and the compact one. Or its radiative decays are suppressed, for example by cancellations, since it is the only state with sizeable compact and molecular parts. The second is speculative. D0 reported a peak of unknown spin at $10.551 plus.minus 0.014 plus.minus 0.017$ GeV, which is compatible with our prediction.

#src[l. 1741–1750; @D0:2012pig.]

== Why do you prefer the deeply bound scenario? #likely

With the two leading-order parameters fitted to the three known $chi_(b 1)$ masses, the deeply bound scenario reproduces them exactly. Forcing the $X_b$ to lie just below threshold, as in BOEFT, gives a deviation of about 15 MeV. So it is the preferred scenario at leading order, not an exclusion of the other one.

#pressed[The two scenarios predict different scattering parameters: $a = -1.00$ fm and $r = -2.5$ fm for the deeply bound case, $a = -3.01$ fm and $r = 0.57$ fm for the shallow one. Other observable differences should be worked out, so that experiment can decide.]
#careful[The leading-order uncertainty has not been quantified, so do not present 15 MeV as a significance.]
#src[l. 1821–1822, 1827; l. 1560–1571.]

== How can a state bound by 91 MeV be the partner of the $X(3872)$, bound by less than 1 MeV?

"Partner" refers to the same quantum numbers and a molecular nature, not to the same binding energy. Heavy-quark symmetry does not fix the binding energy of a molecule: the short-range interaction depends on the heavy-quark mass in a way that is not under control. Even within BOEFT the predicted $X_b$ binding ranges from 233 keV to 15 MeV, depending on the long-range input. In our calculation the $X(3872)$ is not used as input at all.

#src[l. 1597–1598; l. 1637–1641; $X(3872)$ binding $160^(+74)_(-57)$ keV, l. 1635.]

== What are the uncertainties of your predictions? #likely

This is a leading-order calculation, and we have not yet quantified its uncertainty; that is the next step, following the experience from nucleon–nucleon chiral EFT. What we have done is vary everything we could: the cutoff, the number of bottomonium states, the $b$-quark mass, the treatment of the pion propagator, and the tensor force. The qualitative picture survives all of them.

#src[l. 358; l. 940.]

== How robust is the molecular interpretation of the 10.513 GeV state?

- Cutoff $Lambda = 3$–$5$ GeV: masses unchanged, $cal(P)_(macron(b)b)$ changes by at most 1%.
- Bottomonium tower $N = 4$–$7$: absorbed in $C$, from $-16.27$ to $-16.26 "GeV"^(-2)$.
- $m_b = 4.3$–$5.3$ GeV: the $X_b$ composition stays essentially the same ($cal(P)_(macron(b)b) = 1$–$2%$); the compact state moves within $10.529$–$10.549$ GeV.
- Tensor force off: still a molecular $X_b$ at 10.513 GeV, $X_S = 90%$.
- Different treatments of the pion propagator: $X_S$ of the $X_b$ between 39% and 53%; the compact state moves by about 3 MeV.

#src[l. 1447–1448; Table `tab:parametersN`, l. 1290–1292; l. 1418–1432; l. 2225; l. 1668–1669.]

== If the $X_b$ is at 10.513 GeV, why was nothing seen in $pi^+ pi^- Upsilon(1S)$?

For an isoscalar state, $pi^+ pi^- Upsilon(1S)$ goes through $rho Upsilon$, which violates isospin. For the $X(3872)$ this violation is enhanced by the 8 MeV gap between the neutral and charged $D macron(D)^*$ thresholds; in the bottom sector the gap is negligible, and our $X_b$ is far from threshold. The isospin-allowed $omega Upsilon(1S)$ channel is open, about 10.24 GeV; we have not computed rates.

#careful[None of this is in the paper. The 8 MeV and 10.24 GeV are PDG arithmetic; check before quoting.]
#src[Not in the paper; l. 254 for the negligible bottom isospin splitting.]

= Method

== What is the expansion parameter? The $X_b$ binding momentum, 0.7 GeV, is not far below $Lambda_chi approx 1$ GeV. #likely

That is a fair point. There are two expansions: the chiral one in momenta and pion mass over $Lambda_chi approx 1$ GeV, and the heavy-quark one in momentum over $m_b$. For a state this deep the chiral expansion parameter is not small, so convergence has to be demonstrated at higher orders; we do not claim precision at leading order. What leading order already shows is that the left-hand cuts at 65 and 273 MeV lie well inside the relevant momentum range, so pion and eta exchange cannot be replaced by contact terms.

#src[l. 290–316; l. 355–358; binding momentum $kappa_3 = 0.695$ GeV, l. 1256.]

== Why a cutoff of 3–5 GeV, and what is the deep spurious pole?

The cutoff only regularises the equation; the observables do not change when it is varied from 3 to 5 GeV, because $C$ absorbs the change. The spurious pole, between 8.96 and 9.40 GeV, is bound by the singular $1 slash r^3$ tensor force. Its binding momentum, 2.5 to 3 GeV, is far outside the range of the theory. This is known from chiral nuclear forces. Projecting it out changes the masses by less than 1 MeV, and it is absent for $Lambda <= 1.25$ GeV.

#careful[The paper does not say why 3–5 GeV rather than a cutoff near 1 GeV. If asked, say that observables are stable over the range studied; ask the collaborators for the reason before the talk.]
#src[l. 342–343; l. 1447–1455.]

== One $S$-wave contact term with a singular tensor force: is the amplitude properly renormalised?

Numerically, yes: across the cutoff range the masses stay put. The deep spurious state is the known signature of renormalising the singular attractive tensor force with a single counterterm, and it decouples from low-energy observables. Derivative contact terms, including $D$-wave ones, enter at higher order.

#careful[The analogy "in nucleon–nucleon chiral EFT the coupled ${}^3S_1$–${}^3D_1$ channel is also renormalised by one $S$-wave counterterm at leading order" is standard, but it is not stated in our paper.]
#src[l. 1451 (limit-cycle-like running, decoupling); l. 351 (derivative operators at higher orders).]

== Isn't the contact term a free knob that gives any answer you want?

It is the leading contact term that any EFT with pion exchange needs. Together with $V_0$ it is fixed by the three measured $chi_(b 1)$ masses, not tuned to the $X_b$. $C$ itself depends on the cutoff and is not an observable; the masses are. The plot on the "Connecting the two scenarios" slide shows exactly this: varying $C$ moves you between the scenarios, and the data pick one of them.

#src[l. 300; l. 1597; l. 1721–1725.]

== Why only $pi$ and $eta$ exchange? What about $rho$ and $omega$?

Vector-meson exchange has a range of about $1 slash m_rho approx 0.26$ fm, corresponding to momenta near $Lambda_chi$. In chiral EFT such short-range effects are absorbed into the contact terms, as in the nucleon–nucleon case.

#careful[Not discussed in the paper.]
#src[Not in the paper.]

== Why are the $B_s macron(B)_s^*$ channels left out?

At the $B_s macron(B)_s^*$ threshold the $B macron(B)^*$ momentum is 0.97 GeV, comparable to $Lambda_chi$, so this channel is a short-range effect absorbed into $C$.

#src[l. 301, 401.]

== You keep recoil terms that are formally higher order. Why?

They are formally $cal(O)(Q^2)$, but they change the analytic structure of the three-body propagator, so they are resummed. In charm the $D macron(D) pi$ state can go on shell, while $B macron(B) pi$ cannot; keeping these terms preserves that difference, which matters when the two sectors are compared.

#src[l. 1655.]

== What do the probabilities mean? Is $cal(P)_(macron(b)b)$ an observable?

Not in general. A model-independent compositeness exists only for shallow $S$-wave states at leading order in the weak-binding expansion. Within our leading-order calculation all components are UV convergent and change by at most 1% under cutoff variation, so we use them to characterise the structure within the framework.

#src[l. 1370; l. 1448.]

== The $X_b$ has 36% $D$ wave and 21% three-body components. Is that physical?

The $D$ wave comes from the tensor force of pion and eta exchange. The deuteron has about 5%, but the $X_b$ is much more deeply bound and so probes shorter distances. The molecular nature does not hinge on it: without the tensor force the $X_b$ is still molecular, with $X_S = 90%$. The three-body part consists of virtual $B macron(B)^((*)) pi$-type states; in bottom they never go on shell.

#careful[The three-body probability prescription is an open question in our own notes (`NOTEBOOK.md`, Open questions). Do not build an argument on the 21%.]
#src[l. 1446; l. 2225; l. 1655.]

= Lattice and quark-model input

== Why is $V_0$ free when the lattice gives it?

Only the combination $2 m_b + V_0$ sets the bottomonium levels relative to the threshold, and $m_b$ is a model parameter. In the fits $V_0$ moves almost one for one with $-2 m_b$: from 820 MeV at $m_b = 4.3$ GeV to $-1105$ MeV at $5.3$ GeV, so $2 m_b + V_0$ stays within $9.42$–$9.50$ GeV.

#careful[That the lattice constant also contains the self-energy of the static sources is standard lattice knowledge, not stated in the paper.]
#src[l. 402; l. 2190; Table `tab:parameters2`, l. 1271–1278.]

== Why $m_b = 4.534$ GeV?

We varied $m_b$ from 4.3 to 5.3 GeV, covering constituent quark-model values and the kinetic mass used in BOEFT. The value 4.534 GeV gives $Delta M = 0$ and is our central value. The $X_b$ composition is essentially independent of it; the compact state moves within $10.529$–$10.549$ GeV.

#src[l. 728–736; l. 1444–1445.]

== Where do the factors 2 and $1 slash sqrt(3)$ in $g$ come from? BOEFT uses $sqrt(2) g_l approx 50$ MeV.

The lattice two-meson operator contains the relevant light-spin-1 component only with coefficient $1 slash 2$; this factor was left out in the original string-breaking analysis of Bali et al., and a later reanalysis that included it doubled the mixing strength from about 25 to 50 MeV. The $1 slash sqrt(3)$ is the overlap of the $Sigma_g^(+')$ configuration with the $S$-wave $B macron(B)^*$ channel. The $sqrt(2) g_l approx 50$ MeV used in BOEFT is the chirally extrapolated value of an earlier analysis.

#careful[Mention the factors only to show that the details were checked; do not walk through them unless asked.]
#src[l. 439–456; @Bali:2005fu; @Bicudo:2019ymo; @Bulava:2019iut.]

== The lattice fit has no pion exchange. Is $g_l$ reliable?

The avoided crossing that drives the physics occurs at distances larger than the inverse pion mass of the lattice calculation, so we take $g_l$ as a reasonable approximation. How meson exchange affects it, especially at lighter pion masses, is left for further work. The $r$ dependence of the transition, which the lattice fit treats as constant, is of subleading order.

#src[l. 726; l. 458–461.]

== The Cornell potential does not break. Is it adequate near threshold?

Yes, because string breaking is not supposed to be in it. As in the lattice matrix potential, $V(r)$ is the unbroken string; string breaking appears through the coupling $g$ to the meson pairs, which our equation treats dynamically.

#src[l. 377–392.]

== Can lattice QCD test the $X_b$ directly?

A direct study is hard: $a m_b$ is large at current lattice spacings, so very fine lattices or dedicated heavy-quark formulations are needed. Our scattering lengths and effective ranges can be compared with future lattice results, but extracting them is complicated by the left-hand cuts close to threshold.

#src[l. 225; l. 1576–1577.]

= Comparison with BOEFT

== How does this compare with BOEFT? Who is right? #likely

Both use the same lattice static potentials, and both find four poles below the $B macron(B)^*$ threshold, the lowest three matching the observed states. The differences:
- short distances: BOEFT uses explicit $Sigma_g^(+')$ and $Pi_g$ potentials; we use contact terms;
- long distances: BOEFT parametrises them, while we use chiral pion and eta exchange with the correct left-hand cut, the tensor force, no free parameters, and three-body effects;
- parameters: BOEFT tunes them to the $X(3872)$ in charm and predicts bottom; we fit within bottom.

The compositions of the two heaviest states differ, and we trace that to how the parameters are fixed. The approaches are complementary, and the hope stated on our first slide is to merge them.

#careful[Stay respectful; these are close colleagues (the paper thanks Nora Brambilla for comments on the manuscript).]
#src[l. 1608–1661; l. 1824–1826; l. 1817.]

= Outlook

== What about the spin partners ($chi_(b 0)$, $chi_(b 2)$) and the $Z_b$ states?

How the $chi_(b 0)$ and $chi_(b 2)$ states are affected by the open-bottom channels is future work. The $Z_b$ states are isovector, so they have no compact $macron(b)b$ component; there only the hadronic part of the interaction acts. We have not studied them here.

#careful[The $2^(++)$ follow-up ($X_(b 2)$) is unpublished; mention it only if the collaborators agree.]
#src[l. 1748; the $Z_b$ remark is not in the paper.]

== What is the next step?

Exotic states in the charmonium spectrum, once the $chi_(c 1)(4010)$ is established, with $1 slash m_c$ corrections and the $D macron(D) pi$ cut; higher orders and an uncertainty estimate; the spin partners. Precise charm–tau factory data are the input this needs.

#src[l. 358; l. 1748; l. 1836.]

#bibliography("../../../refs.bib", style: "american-physics-society")
