export LightAutomaton, AbstractAutomaton, OneStateAutomaton
export states, modes, nstates, nmodes, transitions, ntransitions
export source, event, symbol, target, transitiontype
export add_transition!, has_transition, rem_transition!, rem_state!
export in_transitions, out_transitions

abstract type AbstractAutomaton end

"""
    states(A::AbstractAutomaton)

Returns an iterator over the states of the automaton `A`.
It has the alias `modes`.
"""
function states end
const modes = states

"""
    nstates(A::AbstractAutomaton)

Returns the number of states of the automaton `A`.
It has the alias `nmodes`.
"""
function nstates end
const nmodes = nstates

"""
    transitiontype(A::AbstractAutomaton)

Returns type of the transitions of the automaton `A`.
"""
function transitiontype end

"""
    transitions(A::AbstractAutomaton)

Returns an iterator over the transitions of the automaton `A`.
"""
function transitions end

"""
    ntransitions(A::AbstractAutomaton)

Returns the number of transitions of the automaton `A`.
"""
function ntransitions end

"""
    add_transition!(A::AbstractAutomaton, q, r, σ)

Adds a transition between states `q` and `r` with symbol `σ` to the automaton `A`.
"""
function add_transition! end
"""
    has_transition(A::AbstractAutomaton, t)

Returns `true` if the automaton `A` has the transition `t`.
"""
function has_transition end
"""
    rem_transition!(A::AbstractAutomaton, q, r, σ)

Remove the transition between states `q` and `r` with symbol `σ` to the automaton `A`.
"""
function rem_transition! end
"""
    rem_state!(A::AbstractAutomaton, q)

Remove the state `q` to the automaton `A`.
"""
function rem_state! end

"""
    source(A::AbstractAutomaton, t)

Returns the source of the transition `t`.
"""
function source end
"""
    event(A::AbstractAutomaton, t)

Returns the event/symbol of the transition `t` in the automaton `A`.
It has the alias `symbol`.
"""
function event end
const symbol = event
"""
    target(A::AbstractAutomaton, t)

Returns the target of the transition `t`.
"""
function target end
"""
    in_transitions(A::AbstractAutomaton, s)

Returns an iterator over the transitions with target `s`.
"""
function in_transitions end
"""
    out_transitions(A::AbstractAutomaton, s)

Returns an iterator over the transitions with source `s`.
"""
function out_transitions end

"""
    OneStateAutomaton

Automaton with one state and the `nt` events 1, ..., `nt`.
"""
struct OneStateAutomaton <: AbstractAutomaton
    nt::Int
end

states(A::OneStateAutomaton) = Base.OneTo(1)
nstates(A::OneStateAutomaton) = 1
transitiontype(A::OneStateAutomaton) = Int
transitions(A::OneStateAutomaton) = Base.OneTo(A.nt)
ntransitions(A::OneStateAutomaton) = A.nt
source(::OneStateAutomaton, t::Int) = 1
event(::OneStateAutomaton, t::Int) = t
target(::OneStateAutomaton, t::Int) = 1
in_transitions(A::OneStateAutomaton, s) = transitions(A)
out_transitions(A::OneStateAutomaton, s) = transitions(A)

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

states(A::LightAutomaton) = vertices(A.G)
nstates(A::LightAutomaton) = nv(A.G)

transitiontype(A::LightAutomaton) = edgetype(A.G)
transitions(A::LightAutomaton) = edges(A.G)
ntransitions(A::LightAutomaton) = ne(A.G)

function add_transition!(A::LightAutomaton, q, r, σ)
    t = Edge(q, r)
    add_edge!(A.G, t)
    A.Σ[t] = σ
end
# FIXME this is nonsense for multiples edges with different labels
function has_transition(A::LightAutomaton, t)
    edge = Edge(source(A, t), target(A, t))
    has_edge(A.G, edge)
end
function rem_transition!(A::LightAutomaton, t)
    edge = Edge(source(A, t), target(A, t))
    rem_edge!(A.G, edge)
    delete!(A.Σ, edge)
end

function rem_state!(A::LightAutomaton, st)
    for t in in_transitions(A, st)
        rem_transition!(A, t)
    end
    for t in out_transitions(A, st)
        rem_transition!(A, t)
    end
    rem_vertex!(A.G, st)
end

source(::LightAutomaton, t::Edge) = t.src
event(A::LightAutomaton, t::Edge) = A.Σ[t]
target(::LightAutomaton, t::Edge) = t.dst

function in_transitions(A::LightAutomaton, s)
    Edge.(in_neighbors(A.G, s), s)
end
function out_transitions(A::LightAutomaton, s)
    Edge.(s, out_neighbors(A.G, s))
end
