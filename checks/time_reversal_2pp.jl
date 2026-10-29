# Slice 04: reciprocity of the projected full OME, not a matrix-storage test.
# Independent route: time reversal with real Condon–Shortley channel phases.
# Fixed tolerance before derivation: 2e-12 max(1, |forward|, |reverse|).
using HadronDynamics
const B = HadronDynamics.BOchiEFT
# --- input: the missing six-channel kernel, supplied by the guarded step ---
cfg = B.Parameters()
# --- end input ---
failed = false
for (r,p,E) in ((0.061,0.173,-0.11),(0.237,0.094,-0.043),(0.42,0.31,-0.019)),
        (name,m,w) in (("pi",cfg.mpi,3.0),("eta",cfg.meta,1/3)), a in 1:6, b in a:6
    # Equal exchange masses isolate a meson through the public total-OME seam.
    one = B.Parameters(mpi=m,meta=m)
    model = B.OMEInteraction(one; channels=B.channels_2pp())
    forward = w/(3+1/3)*B.ome_potential(model,a,b,r,p,E)
    reverse = w/(3+1/3)*B.ome_potential(model,b,a,p,r,E)
    residual = abs(forward-reverse)
    ok = residual <= 2e-12*max(1,abs(forward),abs(reverse))
    global failed |= !ok
    println(ok ? "PASS" : "FAIL", " time reversal ",name," entry=",(a,b),
        " p'=",r," p=",p," residual=",residual)
end
failed && exit(1)
