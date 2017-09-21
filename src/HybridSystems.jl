module HybridSystems

include("automata.jl")
include("systems.jl")
include("maps.jl")
include("switchings.jl")

export AbstractHybridSystem, HybridSystem

abstract type AbstractHybridSystem end

struct HybridSystem{A, S, I, G, R, W} <: AbstractHybridSystem
    automaton::A
    modes::AbstractVector{S}
    invariants::AbstractVector{I}
    guards::AbstractVector{G}
    resetmaps::AbstractVector{R}
    switchings::AbstractVector{W}
end

function Base.show(io::IO, hs::HybridSystem)
    print(io, "Hybrid System with automaton ")
    print(io, hs.automaton)
end

include("constantvector.jl")

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

#function liftinputalg(s::DiscreteLinearControlSystem)
#    n = HybridSystems.dim(s)
#    z = find(i -> iszero(sum(abs.(s.B[i,:]))), 1:n)
#    # TODO the affine space may not be parallel to classical axis
#    DiscreteLinearAlgebraicSystem(s.A[z, :], (eye(n))[z, :])
#end
#
#import MultivariatePolynomials
#const MP = MultivariatePolynomials
#
## Unbounded input
#function liftinputalg(s::ConstrainedSystem{<:AbstractSystem, LightAutomaton{P, MP.FullSpace}}, c) where P
#    ConstrainedSystem(liftinputalg(s.s), s.a), c
#end
#function liftinputalg(s::ConstrainedSystem, c)
#    n = HybridSystems.dim(s.s)
#    nu = size(s.s.B, 2)
#    A = [s.s.A s.s.B;
#         zeros(nu, n+nu)]
#    B = [zeros(n, nu); eye(nu)]
#    newc = [[c[v]; zeros(nu)] for v in vertices(s.a.G)]
#    newinv = [s.a.inv[v] * s.a.inputbounds[v] for v in vertices(s.a.G)]
#    newinb = [MP.FullSpace() for v in vertices(s.a.G)]
#    newa = Automaton(s.a.G, newinv, newinb)
#    liftinputalg(ConstrainedSystem(LinearControlSystem(A, B), newa), newc)
#end
#
#function liftmat(Q, o, c)
#    [o*o'-Q c-o; c'-o' 1]
#end
#function liftmat(Q, o, c, A)
#    @show Q
#    @show c
#    @show A
#    liftmat(A*Q*A', A*o, A*c)
#end
#
#using Convex
#using SCS
#using Polyhedra
#export getcis
#function getcis(sin::ConstrainedSystem, c, uc=false)
#    s, c = liftinputalg(sin, c)
#    as = s.s
#    @show as.A
#    @show as.E
#    g = s.a.G
#    n = LightGraphs.nv(g)
#    d = HybridSystems.dim(as)
#    Q = [Semidefinite(d) for v in vertices(g)]
#    if uc
#        C = [Variable(d) for v in vertices(g)]
#    else
#        C = [zeros(d) for v in vertices(g)]
#    end
#
##   Sol = [diagm([1, 1, 2])
##   constr1 = Q >= eye(dim(s))
#    constrs = Constraint[]
#    for u in vertices(g)
#        m = outdegree(g, u)
#        constr = liftmat(Q[u], c[u], C[u], as.A)
##       test = liftmat(eye(d), c[u], as.A)
##       display(liftmat(eye(d), c[u], as.A))
#        for v in out_neighbors(g, u)
#            constr -= 1/m * liftmat(Q[v], c[v], C[v], as.E)
##           display(liftmat(eye(d), c[v], as.E))
##           test -= 1/m * liftmat(eye(d), c[v], as.E)
#        end
##       @show constr
##       println("test")
##       display(test)
##       println()
##       @show eigmin(test)
#        push!(constrs, constr >= 0)
#        P = liftmat(Q[u], c[u], C[u])
#        for hs in ineqs(s.a.inv[u])
#            a = [hs.a; hs.β]
#            push!(constrs, a' * P * a >= 0)
#        end
#    end
#
#    problem = maximize(sum(logdet(Q[i]) for i in 1:n), constrs)
#
#    solve!(problem, SCSSolver())
#
#    @show problem.status
#    @show problem.optval
#    @show sum(i -> log(det(Q[i].value)), 1:n)
#
#    for i in vertices(g)
#        display(Q[i].value)
#        if uc
#            display(liftmat(Q[i].value, c[i], C[i].value))
#        end
#    end
#    if uc
#        [Ellipsoid(inv(Q[u].value), c[u] + 2*reshape(C[u].value, d)) for u in vertices(g)]
#    else
#        [Ellipsoid(inv(Q[u].value), c[u]) for u in vertices(g)]
#    end
#end

end # module
