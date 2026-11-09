import numpy as np
from cornell import solve_cornell, form_factor
HBARC = 0.1973269804
r, dr, eps, u = solve_cornell(nstates=7)
r1, r2, r0 = 0.95/HBARC, 1.51/HBARC, 0.5/HBARC   # Brambilla 2604.12603 Eq. (2.9), in GeV^-1
prof = np.where(r < r1, r/r1, np.where(r <= r2, 1.0, np.exp(-(r - r2)/r0)))
for p in (0.0, 0.3, 0.7):
    k = r if p == 0 else np.sin(p*r)/p
    const = (k[:, None]*u).sum(0)
    rd = (k[:, None]*prof[:, None]*u).sum(0)
    print(f"p={p}: ratio f^(r-dep)/f^(const) per n:", np.round(rd/const, 3))
