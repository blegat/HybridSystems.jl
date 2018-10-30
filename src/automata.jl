export LightAutomaton, AbstractAutomaton, OneStateAutomaton
export states, modes, nstates, nmodes, transitions, ntransitions
export source, event, symbol, target, transitiontype
export add_transition!, has_transition, rem_transition!, rem_state!
export in_transitions, out_transitions

abstract type StateProperty{T} end
function typed_map(T::Type, f::Function, sp::StateProperty)
    new_sp = state_property(sp.automaton, T)
    for s in states(sp.automaton)
        new_sp[s] = f(sp[s])
    end
    return new_sp
end

abstract type TransitionProperty{T} end
function typed_map(T::Type, f::Function, tp::TransitionProperty)
    new_tp = transition_property(tp.automaton, T)
    for t in transitions(tp.automaton)
        new_tp[t] = f(tp[t])
    end
    return new_tp
end

"""
    AbstractAutomaton

Abstract type for an automaton.
"""
abstract type AbstractAutomaton end

"""
    AbstractTransition

Abstract type for the transition of an automaton.
"""
abstract type AbstractTransition end

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
    has_transition(A::AbstractAutomaton, t::AbstractTransition)

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
    source(A::AbstractAutomaton, t::AbstractTransition)

Returns the source of the transition `t`.
"""
function source end
"""
    event(A::AbstractAutomaton, t::AbstractTransition)

Returns the event/symbol of the transition `t` in the automaton `A`.
It has the alias `symbol`.
"""
function event end
const symbol = event
"""
    target(A::AbstractAutomaton, t::AbstractTransition)

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

"""
    OneStateTransition

Transition of `OneStateAutomaton` with label `σ`.
"""
struct OneStateTransition <: AbstractTransition
    σ::Int
end

states(A::OneStateAutomaton) = Base.OneTo(1)
nstates(A::OneStateAutomaton) = 1
transitiontype(A::OneStateAutomaton) = OneStateTransition
transitions(A::OneStateAutomaton) = OneStateTransition.(Base.OneTo(A.nt))
ntransitions(A::OneStateAutomaton) = A.nt
source(::OneStateAutomaton, t::OneStateTransition) = 1
event(::OneStateAutomaton, t::OneStateTransition) = t.σ
target(::OneStateAutomaton, t::OneStateTransition) = 1
in_transitions(A::OneStateAutomaton, s) = transitions(A)
out_transitions(A::OneStateAutomaton, s) = transitions(A)

mutable struct OneStateStateProperty{T} <: StateProperty{T}
    automaton::OneStateAutomaton
    value::Union{Nothing, T}
end
state_property_type(::Type{OneStateAutomaton}, T::Type) = OneStateStateProperty{T}
function state_property(automaton::OneStateAutomaton, T::Type)
    return OneStateStateProperty{T}(automaton, nothing)
end
function Base.getindex(p::OneStateStateProperty,
                       s::Int)
    @assert isone(s)
    p.value
end
function Base.setindex!(p::OneStateStateProperty, value,
                        s::Int)
    @assert isone(s)
    p.value = value
end

struct OneStateTransitionProperty{T} <: TransitionProperty{T}
    automaton::OneStateAutomaton
    value::Vector{T}
end
transition_property_type(::Type{OneStateAutomaton}, T::Type) = OneStateTransitionProperty{T}
function transition_property(automaton::OneStateAutomaton, T::Type)
    return OneStateTransitionProperty(automaton, Vector{T}(undef, automaton.nt))
end
function Base.getindex(p::OneStateTransitionProperty,
                       t::OneStateTransition)
    p.value[t.σ]
end
function Base.setindex!(p::OneStateTransitionProperty, value,
                        t::OneStateTransition)
    p.value[t.σ] = value
end

using LightGraphs

"""
    LightAutomaton{GT, ET} <: AbstractAutomaton

A hybrid automaton that uses the `LightGraphs` backend. See the constructor
[`LightAutomaton(::Int)`](@ref).

###  Fields

- `G` -- graph of type `GT` whose vertices determine the states
- `Σ` -- dictionary mapping the edges to their labels
"""
mutable struct LightAutomaton{GT, ET} <: AbstractAutomaton
    G::GT
    Σ::Dict{ET, Dict{Int, Int}}
    next_id::Int
    nt::Int
end

"""
    LightAutomaton(n::Int)

Creates a `LightAutomaton` with `n` states 1, 2, ..., `n`.
The automaton is initialized without any transitions,
use [`add_transition!`](@ref) to add transitions.

## Examples

To create an automaton with 2 nodes 1, 2, self-loops of labels 1, a transition
from 1 to 2 with label 2 and transition from 2 to 1 with label 3, do the
following:
```jldoctest
julia> a = LightAutomaton(2);

julia> add_transition!(a, 1, 1, 1) # Add a self-loop of label 1 for state 1
Edge 1 => 1

julia> add_transition!(a, 2, 2, 1) # Add a self-loop of label 1 for state 2
Edge 2 => 2

julia> add_transition!(a, 1, 2, 2) # Add a transition from state 1 to state 2 with label 2
Edge 1 => 2

julia> add_transition!(a, 2, 1, 3) # Add a transition from state 2 to state 1 with label 3
Edge 2 => 1
```
"""
function LightAutomaton(n::Int)
    G = DiGraph(n)
    Σ = Dict{edgetype(G), Dict{Int, Int}}()
    LightAutomaton(G, Σ, 0, 0)
end

struct LightTransition{ET} <: AbstractTransition
    edge::ET
    id::Int
end

"""
    struct TransitionIterator{GT, ET, VT}
        automaton::LightAutomaton{GT, ET}
        edge_iterator::VT
    end

Iterate over the transitions of `automaton` by iterating over the edges `edge`
of `edge_iterator` and the ids `id` of `automaton.Σ[edge]` for each one. Its
elements are `LightTransition(edge, id)`.
"""
struct TransitionIterator{GT, ET, VT}
    automaton::LightAutomaton{GT, ET}
    edge_iterator::VT
end
eltype(::TransitionIterator{ET}) where {ET} = LightTransition{ET}
function new_id_iterate(tit::TransitionIterator, edge, edge_state, ids, ::Nothing)
    return new_edge_iterate(tit, iterate(tit.edge_iterator, edge_state))
end
function new_id_iterate(tit::TransitionIterator, edge, edge_state, ids, id_item_state)
    idσ, id_state = id_item_state
    return LightTransition(edge, idσ[1]), (edge, edge_state, ids, id_state)
end
new_edge_iterate(::TransitionIterator, ::Nothing) = nothing
function new_edge_iterate(tit::TransitionIterator, edge_item_state)
    edge, edge_state = edge_item_state
    ids = tit.automaton.Σ[edge]
    return new_id_iterate(tit, edge, edge_state, ids, iterate(ids))
end
function Base.iterate(tit::TransitionIterator)
    return new_edge_iterate(tit, iterate(tit.edge_iterator))
end
function Base.iterate(tit::TransitionIterator, edge_id_state)
    edge, edge_state, ids, id_state = edge_id_state
    return new_id_iterate(tit, edge, edge_state, ids, iterate(ids, id_state))
end

states(A::LightAutomaton) = vertices(A.G)
nstates(A::LightAutomaton) = nv(A.G)

transitiontype(A::LightAutomaton) = LightTransition{edgetype(A.G)}
transitions(A::LightAutomaton) = TransitionIterator(A, edges(A.G))
ntransitions(A::LightAutomaton) = A.nt

function add_transition!(A::LightAutomaton, q, r, σ)
    edge = Edge(q, r)
    A.next_id += 1
    A.nt += 1
    id = A.next_id
    ids = get(A.Σ, edge, nothing)
    new_ids = ids === nothing
    if new_ids
        ids = Dict{Int, Int}()
    end
    ids[id] = σ
    if new_ids
        add_edge!(A.G, edge)
        A.Σ[edge] = ids
    end
    return LightTransition(edge, id)
end
function has_transition(A::LightAutomaton, t::LightTransition)
    has_edge(A.G, t.edge) && haskey(A.Σ[edge], t.id)
end
function rem_transition!(A::LightAutomaton, t::LightTransition)
    ids = A.Σ[t.edge]
    delete!(ids, t.id)
    A.nt -= 1
    if isempty(ids)
        rem_edge!(A.G, t.edge)
        delete!(A.Σ, t.edge)
    end
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

source(::LightAutomaton, t::LightTransition) = t.edge.src
event(A::LightAutomaton, t::LightTransition) = A.Σ[t.edge][t.id]
target(::LightAutomaton, t::LightTransition) = t.edge.dst

function in_transitions(A::LightAutomaton, s)
    TransitionIterator(A, Edge.(inneighbors(A.G, s), s))
end
function out_transitions(A::LightAutomaton, s)
    TransitionIterator(A, Edge.(s, outneighbors(A.G, s)))
end

struct LightStateProperty{GT, ET, T} <: StateProperty{T}
    automaton::LightAutomaton{GT, ET}
    value::Vector{T}
end
function state_property_type(::Type{LightAutomaton{GT, ET}}, T::Type) where {GT, ET}
    return LightStateProperty{GT, ET, T}
end
function state_property(automaton::LightAutomaton, T::Type)
    return LightStateProperty(automaton, Vector{T}(undef, nstates(automaton)))
end
function Base.getindex(p::LightStateProperty,
                       s::Int)
    p.value[s]
end
function Base.setindex!(p::LightStateProperty, value,
                        s::Int)
    p.value[s] = value
end

struct LightTransitionProperty{GT, ET, T} <: TransitionProperty{T}
    automaton::LightAutomaton{GT, ET}
    value::Vector{T}
end
function transition_property_type(::Type{LightAutomaton{GT, ET}}, T::Type) where {GT, ET}
    return LightTransitionProperty{GT, ET, T}
end
function transition_property(automaton::LightAutomaton, T::Type)
    return LightTransitionProperty(automaton, Vector{T}(undef, automaton.next_id))
end
function Base.getindex(p::LightTransitionProperty,
                       t::LightTransition)
    p.value[t.id]
end
function Base.setindex!(p::LightTransitionProperty, value,
                        t::LightTransition)
    p.value[t.id] = value
end
