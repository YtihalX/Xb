# Certificates of the example rectangles drawn by cert_conditions.py: two that pass (A in the search domain, D at
# Gamma about 95 MeV), a kept and a dropped near node just below the PV threshold (B, Bd), and two exclusions, by
# C4 (F4) and by C5 (F5). Writes cert_conditions.csv (margins in MeV). Plot data, not a check.
# Run from the repository root:
#   julia --startup-file=no --project=code/Xb2Continuation notes/07-continued-lse/cert_conditions.jl
using Xb2Continuation

const LABELS = ("VV", "PV", "PP")
const MEV = 1000.0
const EXAMPLES = (
    ("A", "(-,-,+)", (-25.0, -20.0), (-10.0, -5.0)),
    ("D", "(-,-,+)", (-25.0, -20.0), (-50.0, -45.0)),
    ("B", "(-,+,+)", (-45.85, -45.75), (-0.35, -0.25)),
    ("Bd", "(-,+,+)", (-46.70, -46.60), (-0.40, -0.30)),
    ("F4", "(-,-,-)", (-30.0, -28.0), (-2.0, -1.0)),
    ("F5", "(-,-,+)", (-46.6, -46.4), (-0.2, -0.1)),
)

function main()
    ths = thresholds_2pp()
    open(joinpath(@__DIR__, "cert_conditions.csv"), "w") do io
        println(io, "name,sheet,re_lo,re_hi,im_lo,im_hi,status,reason,nodes,dropped,slope,s35_margin,window_margin,z_margin,clearance")
        for (name, sheet, re, im) in EXAMPLES
            c = certify_rectangle(EnergyRectangle(re ./ MEV, im ./ MEV), Sheet(sheet), ths)
            head = "$name,\"$sheet\",$(re[1]),$(re[2]),$(im[1]),$(im[2])"
            if c isa RectangleCertificate
                println(io, head, ",certified,,", join((LABELS[a] for a in c.nodes), "+"), ",",
                        join((LABELS[a] for a in c.dropped), "+"), ",", c.slope, ",", MEV * c.s35_margin, ",",
                        MEV * c.window_margin, ",", MEV * c.z_margin, ",", MEV * c.clearance)
            else
                println(io, head, ",excluded,\"", c.reason, "\",,,,,,,")
            end
        end
    end
    print(read(joinpath(@__DIR__, "cert_conditions.csv"), String))
end

main()
