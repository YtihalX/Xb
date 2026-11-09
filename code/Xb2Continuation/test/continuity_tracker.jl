"""
Independent continuity tracker for the continued OME angular moments (tests only).

It follows, along a caller-supplied path τ ∈ [0,1] ↦ (p′(τ), p(τ), E(τ)), the square
roots s± = √(m² + (p′ ± p)²) and the logarithms L± = log(s± + ν_β) of every time
ordering β, choosing at each step the branch nearest the previous value. At τ = 0 the
path must sit at real momenta below the three-body thresholds, where every s± and L±
is principal. At τ = 1 it assembles the moments ∫₋₁¹ xⁿ dx/[2ω(ω+ν)] from the tracked
values by polynomial division, (A − ω²)ⁿ = Qₙ(ω)(ω + ν) + (A − ν²)ⁿ, in extended
precision, sharing no code with `HadronDynamics.ExchangeMoments` or `Xb2Continuation`.
The assembly takes the tracked L± in double precision, so it loses accuracy at small
B = 2p′p, where L₊ − L₋ cancels.

The offsets ν_β come from the caller (`offsets(p′, p, E)`), so errors in ν are shared.
Written for HadronDynamics.jl's tests (untracked there) and moved here on 2026-11-05.
"""
module ContinuityTracker

export tracked_branches, tracked_moments

# Nearest value of log(z) to `previous`.
function nearest_log(z, previous)
    l = log(z)
    n = round((imag(previous) - imag(l)) / (2pi))
    l + 2pi * im * n
end

"""
    tracked_branches(path, offsets, mphi)

Continued (s₊, s₋, ν, L₊, L₋) at the end of `path`, one entry of ν, L₊, L₋ per time
ordering returned by `offsets`. `path(τ)` returns (p′, p, E).
"""
function tracked_branches(path, offsets, mphi; mindt=1e-12)
    pout, pin, E = path(0.0)
    nus = offsets(pout, pin, E)
    sp = sqrt(complex(mphi^2 + (pout + pin)^2)); sm = sqrt(complex(mphi^2 + (pout - pin)^2))
    Lp = [log(sp + nu) for nu in nus]; Lm = [log(sm + nu) for nu in nus]
    τ = 0.0; dt = 1 / 64
    while τ < 1
        t = min(1.0, τ + dt)
        a, b, e = path(t)
        nn = offsets(a, b, e)
        cp = sqrt(complex(mphi^2 + (a + b)^2)); cm = sqrt(complex(mphi^2 + (a - b)^2))
        cp = abs(cp - sp) <= abs(-cp - sp) ? cp : -cp
        cm = abs(cm - sm) <= abs(-cm - sm) ? cm : -cm
        np = [nearest_log(cp + nu, l) for (nu, l) in zip(nn, Lp)]
        nm = [nearest_log(cm + nu, l) for (nu, l) in zip(nn, Lm)]
        small = abs(cp - sp) <= 0.05 * max(abs(sp), abs(cp), 1e-3) &&
                abs(cm - sm) <= 0.05 * max(abs(sm), abs(cm), 1e-3) &&
                all(abs(imag(x - y)) <= pi / 8 for (x, y) in zip(np, Lp)) &&
                all(abs(imag(x - y)) <= pi / 8 for (x, y) in zip(nm, Lm))
        if small
            sp, sm, Lp, Lm, nus = cp, cm, np, nm, nn
            τ = t; dt = min(2dt, 1 / 16)
        else
            dt /= 2
            dt >= mindt || error("tracking stalled at τ=$τ: a branch point lies on the path")
        end
    end
    (sp, sm, nus, Lp, Lm)
end

"""
    tracked_moments(path, offsets, mphi, order)

Moments n = 0:order, summed over the time orderings returned by `offsets`, at the end
of `path`, with s± and L± continued along it.
"""
function tracked_moments(path, offsets, mphi, order; mindt=1e-12)
    sp, sm, nus, Lp, Lm = tracked_branches(path, offsets, mphi; mindt)
    pout, pin, E = path(1.0)
    assemble(pout, pin, mphi, sp, sm, nus, Lp, Lm, order)
end

# ∫₋₁¹ xⁿ/[2ω(ω+ν)] dx = B^{-(n+1)} ∫_{s₋}^{s₊} (A − ω²)ⁿ/(ω + ν) dω, B = 2p′p.
function assemble(pout, pin, mphi, sp, sm, nus, Lp, Lm, order)
    setprecision(BigFloat, 512) do
        big(z) = Complex{BigFloat}(BigFloat(real(z)), BigFloat(imag(z)))
        A = big(pout)^2 + big(pin)^2 + big(mphi)^2
        Bv = 2big(pout) * big(pin)
        moments = zeros(Complex{BigFloat}, order + 1)
        for (nu, lp, lm) in zip(nus, Lp, Lm)
            ν = big(nu)
            for n in 0:order
                # (A − ω²)ⁿ as coefficients c[j+1] of ω^j, then synthetic division by (ω + ν).
                c = zeros(Complex{BigFloat}, 2n + 1)
                for j in 0:n
                    c[2j + 1] = binomial(n, j) * A^(n - j) * (-1)^j
                end
                quotient = zeros(Complex{BigFloat}, max(2n, 1))
                remainder = zero(Complex{BigFloat})
                if n == 0
                    remainder = c[1]
                else
                    carry = zero(Complex{BigFloat})
                    for j in 2n:-1:0  # highest power first
                        value = c[j + 1] + carry
                        if j == 0
                            remainder = value
                        else
                            quotient[j] = value          # coefficient of ω^{j-1}
                            carry = -ν * value
                        end
                    end
                end
                integral = remainder * (big(lp) - big(lm))
                for j in 1:2n
                    integral += quotient[j] * (big(sp)^j - big(sm)^j) / j
                end
                moments[n + 1] += integral / Bv^(n + 1)
            end
        end
        ComplexF64.(moments)
    end
end

end
