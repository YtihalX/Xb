using LinearAlgebra: eigvals

# Relative residual tolerance on the unsquared equation (GeV scale floor).
const THREE_BODY_RTOL = 1e-10

function _three_body_roots(pout, c, a, mphi, tau)
    tau in (-1, 1) || throw(ArgumentError("tau must be +1 or -1"))
    all(isfinite, (pout, c, a, mphi)) && mphi > 0 ||
        throw(ArgumentError("finite coefficients and positive meson mass required"))
    coefficients = a == 0 ? ComplexF64[c^2-mphi^2-pout^2, -2tau*pout, -1] :
        ComplexF64[c^2-mphi^2-pout^2, -2tau*pout, 2a*c-1, 0, a^2]
    n = length(coefficients)-1
    companion = zeros(ComplexF64, n, n)
    for j in 1:n-1
        companion[j+1,j] = 1
    end
    companion[:,n] .= -coefficients[1:n] ./ coefficients[end]
    roots = eigvals(companion)
    map(roots) do q
        for _ in 1:12
            value = coefficients[end]
            derivative = zero(q)
            for j in n:-1:1
                derivative = derivative*q + value
                value = value*q + coefficients[j]
            end
            iszero(derivative) && break
            step = value/derivative
            q -= step
            abs(step) <= 4eps(Float64)*max(1,abs(q)) && break
        end
        s = sqrt(complex(mphi^2+(pout+tau*q)^2))
        v = c+a*q^2
        (pin=q, principal=abs(s+v) <= THREE_BODY_RTOL*max(1,abs(s),abs(v)))
    end
end

"""
    three_body_roots(pout, E, ord::Ordering, mphi; tau=1)

All polynomial candidates of S36 (note 07 `st:quartic`), including extraneous
squared roots. Each `(pin, principal)` marks the principal-square-root zero
using `abs(s+nu) <= 1e-10 * max(1,abs(s),abs(nu))`. Units are GeV.
"""
function three_body_roots(pout, E, ord::Ordering, mphi; tau=1)
    _three_body_roots(pout, ord.t+ord.h*pout^2-E, ord.a, mphi, tau)
end

"""
    three_body_points(model, out, incoming, pout, E; meson=:pion)

Locate candidates for each entry-local TOPT ordering and both endpoint signs.
Offsets are obtained from the checked `tc_alphas` input, not channel guesses.
Returns named tuples `(pin, ordering, sign, principal)`.
"""
function three_body_points(model, out, incoming, pout, E; meson=:pion)
    B = HadronDynamics.BOchiEFT
    mphi = meson === :pion ? model.parameters.mpi :
           meson === :eta ? model.parameters.meta :
           throw(ArgumentError("meson must be :pion or :eta"))
    cs = B.tc_alphas(model,out,incoming,pout,0.0,E)
    ones = B.tc_alphas(model,out,incoming,pout,1.0,E)
    thirds = B.tc_alphas(model,out,incoming,pout,0.5,E)
    result = NamedTuple{(:pin,:ordering,:sign,:principal),Tuple{ComplexF64,Int,Int,Bool}}[]
    for beta in eachindex(cs)
        c = cs[beta]; a = ones[beta]-c
        isapprox(thirds[beta], c+a/4; atol=128eps(Float64)*max(1,abs(c),abs(a)), rtol=128eps(Float64)) ||
            throw(ArgumentError("tc_alphas is not affine in incoming momentum squared"))
        for tau in (1,-1), root in _three_body_roots(pout,c,a,mphi,tau)
            push!(result,(pin=root.pin,ordering=beta,sign=tau,principal=root.principal))
        end
    end
    result
end
