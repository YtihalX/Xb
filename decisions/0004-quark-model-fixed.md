# The quark model is fixed by the 1++ fit; no 2++ fit

Decided by: you
Date: 2026-10-28
Source: a collaborator's comment, relayed in the slicing session of 2026-10-28 and quoted below

The quark model ($m_b$, $\sigma$, $\gamma=-\frac43\alpha_s$, $V_0$) is fixed by the $1^{++}$ fit at each cutoff and is used unchanged for the bare states of every $J^{PC}$. The fit of $V_0^{(2^{++})}$ to $\chi_{b2}(9912)$ and $\chi_{b2}(10269)$ in decisions/0001 is withdrawn, so those two states are no longer inputs. Kept from 0001:
- $g=57$ MeV, $C$, $N=4$, and $\Lambda$ come from the $1^{++}$ fit;
- hadron masses are the code values; the $1^{++}$ regression keeps $\mu_{\rm PV}=2.650950$ GeV, and the $2^{++}$ reduced masses are derived from the code masses;
- $\chi_{b2}(10524)$ is neither an input nor a check.

Three questions are decided after the $2^{++}$ OME slice, and the $2^{++}$ spectrum slices wait for that decision:
- which bare $\chi_{b2}$ masses enter: the $1^{++}$ bare masses, or those masses shifted by the spin-dependent terms of [@Zhang:2026iyr] v1, Eq. (B4);
- what role $\chi_{b2}(9912)$ and $\chi_{b2}(10269)$ play;
- which states the spin-dependent computation covers.

The comment:

> Generally speaking, quark model is fixed once and forever (m_b, sigma, alpha_S, V0) and should be used for any calculation of the quark states for all quantum numbers. Thus, at the moment, we just use the parameters we fixed before. Quark model works quite well for heavy quarkonia, so I would not expect severe problems with the spectrum. Yet, some tuning or discussion may be needed. You can calculate the spectrum of 2++ b-bar-b states, including the spin-dependent terms. All formulae are given in our paper.

## Consequences

- decisions/0001 is superseded.
- In decisions/0003, the out-of-scope item "$1/m_b$ corrections beyond $V_0^{(2^{++})}$" is superseded.
- CONVENTIONS.md "Sector shift" is removed.
- GLOSSARY.md "Spin-independent bare spectrum" and "Strict HQSS limit" are revised.
- Plan claim 3 and its falsifier wait for the bare-$\chi_{b2}$ decision.
