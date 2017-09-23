#using Plots
#
#function plotinvariants(H::HybridSystem, args...; kws...)
#    plot(first(H.invariants), args...; kws...)
#    for inv in Iterators.drop(H.invariants, 1)
#        plot!(inv, args...; kws...)
#    end
#end
#function plotinvariants!(H::HybridSystem, args...; kws...)
#    for inv in H.invariants
#        plot!(inv, args...; kws...)
#    end
#end

function algebraiclift(s::DiscreteLinearControlSystem{T, MT, FullSpace}) where {T, MT}
    n = statedim(s)
    z = find(i -> iszero(sum(abs.(s.B[i,:]))), 1:n)
    # TODO ty - 1//2y^3 + 3//1xy + 2//1yhe affine space may not be parallel to classical axis
    DiscreteLinearAlgebraicSystem(s.A[z, :], (eye(n))[z, :])
end
algebraiclift(s::DiscreteIdentitySystem) = s
algebraiclift(S::AbstractVector) = algebraiclift.(S)
algebraiclift(S::ConstantVector) = ConstantVector(algebraiclift(first(S)), length(S))
function algebraiclift(h::HybridSystem)
    HybridSystem(h.automaton, algebraiclift(h.modes), h.invariants, h.guards, algebraiclift(h.resetmaps), h.switchings)
end

function r(A::Matrix{T}, c::Vector{T}=zeros(T, size(A, 1))) where T
    [one(T) zeros(T, 1, size(A, 2))
     c A]
end

function householder(x)
    y = copy(x)
    t = LinAlg.reflector!(y)
    v = [1; y[2:end]]
    eye(length(x)) - t * v * v'
end

using DynamicPolynomials
using MultivariatePolynomials
using PolyJuMP
using SumOfSquares
using JuMP
using LightGraphs
function ATrp(p, A)
    @show p
    @show A
    x = variables(p)
    B = r(A)'
    @show B
    y = x[1:size(B, 2)]
    @show p(x => r(A)' * y)
    p(x => r(A)' * y)
end
function lhs(p, Re::ConstantVector)
    ATrp(p, first(Re).A)
end

function getp(m::Model, c, x, z::AbstractVariable)
    y = [z; x]
    n = length(x)
    Q = @variable m [1:n, 1:n] SDP
    b = zeros(n)
    P = [-1 b'
         b  Q]
    H = householder([1; c]) # We add 1, for z
    display(P)
    println()
    HPH = H * P * H
    display(HPH)
    println()
    p = y' * HPH * y
    @show p
    ConeLyap(p, Q, c, H)
    #@constraint m sum(Q) == 1 # dehomogenize
    #@variable m L[1:n, 1:n]
    #@variable m λinv[1:(n-1)] >= 0
    #@SDconstraint m [Q  L
    #                 L' diagm([λinv; -1])] ⪰ 0
    #ConeLyap(x' * Q * x, Q, L, λinv)
end
function getis(s::HybridSystem, solver, c)
    g = s.automaton.G
    n = nv(g)
    m = SOSModel(solver=solver)
    @polyvar x[1:2] z
    y = [z; x]
    l = [getp(m, c[u], x, z) for u in 1:n]
    #X = monomials(x, 2)
    #@variable m p[1:n] Poly(X)
    #@variable m vol
    #@objective m Max vol
    
    @objective m Max sum(p -> trace(p.Q), l)
    
    for u in 1:n
        # Constraint 1
        #@variable m λout[1:m] >= 0
        #@constraint m sum(λin) == 1
        Σ = symbol.(s.automaton, Edge.(u, out_neighbors(g, u)))
        expr = lhs(l[u].p, s.resetmaps[Σ])
        for (j, v) in enumerate(out_neighbors(g, u))
            E = s.resetmaps[Σ[j]].E
            #expr -= λout[j] * p[v](x => r(E)' * x)
            newp = ATrp(l[v].p, E)
            @show expr
            @show newp
            expr -= newp
        end
        @show expr
        @constraint m expr >= 0
        # Constraint 2
        #@SDconstraint m differentiate(p[u], x, 2) >= 0
        # Constraint 3
        for hs in ineqs(s.invariants[u])
            @show hs
            @show l[u].p(y => [-hs.β; hs.a])
            @constraint m l[u].p(y => [-hs.β; hs.a]) <= 0
        end
    end

    status = solve(m)

    @show status
    @assert status == :Optimal
    ellipsoid.(l)
#    if uc
#        [Ellipsoid(inv(Q[u].value), c[u] + 2*reshape(C[u].value, d)) for u in vertices(g)]
#    else
#        [Ellipsoid(inv(Q[u].value), c[u]) for u in vertices(g)]
#    end
end
