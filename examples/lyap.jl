using MultivariatePolynomials
using JuMP

struct ConeLyap{T, P<:AbstractPolynomial{T}, S}
    p::P
    Q::Matrix{S}
    c::Vector{Float64}
    H::Matrix{Float64}
    #L::Matrix{JuMP.Variable}
    #λinv::Vector{JuMP.Variable}
end
ConeLyap(p::P, Q::Matrix{S}, c, H) where {T, P<:AbstractPolynomial{T}, S} = ConeLyap{T, P, S}(p, Q, c, H)
JuMP.getvalue(p::ConeLyap) = ConeLyap(getvalue(p.p), getvalue(p.Q), p.c, p.H)
ellipsoid(p::ConeLyap{T, P, JuMP.Variable}) where {T, P<:AbstractPolynomial{T}} = ellipsoid(getvalue(p))
ellipsoid(p::ConeLyap) = Ellipsoid(inv(p.Q), p.c)

using RecipesBase

export Ellipsoid

struct Ellipsoid{T}
    Q::Matrix{T}
    c::Vector{T}
end

@recipe function f(ell::Ellipsoid)
    @assert Base.LinAlg.checksquare(ell.Q) == 2
    αs = linspace(0, 2π, 64)
    ps = [[cos(α), sin(α)] for α in αs]
    r = [sqrt(dot(p, ell.Q * p)) for p in ps]
    seriestype --> :shape
    legend --> false
    ell.c[1] .+ cos.(αs) ./ r, ell.c[2] .+ sin.(αs) ./ r
end
