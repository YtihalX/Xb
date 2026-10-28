# 2++ parameters and inputs come from 1++, except one sector shift

Decided by: you
Date: 2026-10-28
Source: the grilling session of 2026-10-28
Status: superseded by 0004

The $2^{++}$ calculation takes $g=57$ MeV, $C$, $m_b$, $N=4$, and $\Lambda$ from the $1^{++}$ fit (baseline and shallow-$X_b$) and fits only the sector shift $V_0^{(2^{++})}$, minimising $\Delta M^{(2^{++})}$ over $\chi_{b2}(9912)$ and $\chi_{b2}(10269)$: the LO bare spectrum is spin-independent, so the $1/m_b^2$ fine splitting (10–20 MeV) is absorbed into one $V_0$ per $J^{PC}$ sector, as [@Zhang:2026iyr] v1 did for $1^{++}$. $\chi_{b2}(10524)$ is neither an input nor a check, only compared afterwards: CMS is its only source and assigned its $J$ by mass ordering ([@CMS:2018vgf] v2), and [@Zhang:2026iyr] v1, Sec. IV G, suggests the CMS signals there may all be the $X_b$. All hadron masses are the code values with which $C$ and $V_0^{(1^{++})}$ were fitted ($m_B=5.27952$, $m_{B^*}=5.32475$ GeV, $m_\pi=138.039$ MeV).

Reduced masses: the $1^{++}$ regression keeps the code's historical $\mu_{\rm PV}=2.650950$ GeV (computed from the rounded masses 5.279 and 5.325 GeV) so that it reproduces the paper exactly; every $2^{++}$ reduced mass ($m_{B^*}/2$, $m_Bm_{B^*}/(m_B+m_{B^*})=2.651019$ GeV, $m_B/2$) is derived from the code masses.

## Considered options

- Strict LO, $V_0^{(2^{++})}=V_0^{(1^{++})}$, with the fine-splitting mismatch reported as the LO error.
- The spin-dependent shifts of [@Zhang:2026iyr] v1, Eq. (B4), from Cornell wave functions: a partial $1/m_b^2$ correction with the other $1/m_b^2$ terms absent.
- $V_0^{(2^{++})}$ from $\chi_{b2}(9912)$ alone, leaving $\chi_{b2}(10269)$ as a prediction.
- Refitting $m_b$ as well: no degrees of freedom left.

## Consequences

CONVENTIONS.md "Sector shift"; GLOSSARY.md "Spin-independent bare spectrum", "Isospin limit"; the $\Lambda=3,5$ GeV runs take $(m_b, C)$ from Table VI of [@Zhang:2026iyr] v1, and the shallow-$X_b$ fit needs $1^{++}$ refits at those cutoffs first; falsifier: $\Delta M^{(2^{++})}$ or $|V_0^{(2^{++})}-V_0^{(1^{++})}|$ far above the measured fine splittings.
