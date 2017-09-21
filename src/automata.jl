export LightAutomaton, AbstractAutomaton
export symbol, add_transition!

abstract type AbstractAutomaton end

"""
    add_transition!(A::AbstractAutomaton, q, r, σ)

Adds a transition between states `q` and `r` with symbol `σ` to the automaton `A`.
"""
function add_transition! end

"""
    symbol(A::AbstractAutomaton, t)

Returns the symbol of the transition `t` in the automaton `A`.
"""
function symbol end

using LightGraphs

struct LightAutomaton{GT, ET} <: AbstractAutomaton
    G::GT
    Σ::Dict{ET, Int}
end
function LightAutomaton(n::Int)
    G = DiGraph(n)
    Σ = Dict{edgetype(G), Int}()
    LightAutomaton(G, Σ)
end

symbol(A::LightAutomaton, t::Edge) = A.Σ[t]
function add_transition!(A::LightAutomaton, q, r, σ)
    t = Edge(q, r)
    add_edge!(A.G, t)
    A.Σ[t] = σ
end
