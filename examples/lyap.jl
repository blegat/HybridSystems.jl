using MultivariatePolynomials
using JuMP

struct ConeLyap{T, P<:AbstractPolynomial{T}, S}
    p::P
    Q::Matrix{S}
    b::Vector{S}
    c::Vector{Float64}
    H::Matrix{Float64}
    #L::Matrix{JuMP.Variable}
    #λinv::Vector{JuMP.Variable}
end

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
