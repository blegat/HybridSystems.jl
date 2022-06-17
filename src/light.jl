import MappedArrays
import Graphs

using MappedArrays: ReadonlyMappedArray

"""
    LightAutomaton{GT, ET} <: AbstractAutomaton

A hybrid automaton that uses the `Graphs` backend. See the constructor
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
HybridSystems.LightTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 1 => 1, 1)

julia> add_transition!(a, 2, 2, 1) # Add a self-loop of label 1 for state 2
HybridSystems.LightTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 2 => 2, 2)

julia> add_transition!(a, 1, 2, 2) # Add a transition from state 1 to state 2 with label 2
HybridSystems.LightTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 1 => 2, 3)

julia> add_transition!(a, 2, 1, 3) # Add a transition from state 2 to state 1 with label 3
HybridSystems.LightTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 2 => 1, 4)
```
"""
function LightAutomaton(n::Int)
    G = Graphs.DiGraph(n)
    Σ = Dict{Graphs.edgetype(G), Dict{Int, Int}}()
    LightAutomaton(G, Σ, 0, 0)
end

struct LightTransition{ET} <: AbstractTransition
    edge::ET
    id::Int
end

"""
    struct LightTransitionIterator{GT, ET, VT}
        automaton::LightAutomaton{GT, ET}
        edge_iterator::VT
    end

Iterate over the transitions of `automaton` by iterating over the edges `edge`
of `edge_iterator` and the ids `id` of `automaton.Σ[edge]` for each one. Its
elements are `LightTransition(edge, id)`.
"""
struct LightTransitionIterator{GT, ET, VT}
    automaton::LightAutomaton{GT, ET}
    edge_iterator::VT
end
Base.eltype(::LightTransitionIterator{GT, ET}) where {GT, ET} = LightTransition{ET}
function Base.length(tit::LightTransitionIterator)
    eit = tit.edge_iterator
    # empty iterator must be handled separately (see #29)
    return isempty(eit) ? 0 : sum(edge -> length(tit.automaton.Σ[edge]), eit)
end
function new_id_iterate(tit::LightTransitionIterator, edge, edge_state, ids, ::Nothing)
    return new_edge_iterate(tit, iterate(tit.edge_iterator, edge_state))
end
function new_id_iterate(tit::LightTransitionIterator, edge, edge_state, ids, id_item_state)
    idσ, id_state = id_item_state
    return LightTransition(edge, idσ[1]), (edge, edge_state, ids, id_state)
end
new_edge_iterate(::LightTransitionIterator, ::Nothing) = nothing
function new_edge_iterate(tit::LightTransitionIterator, edge_item_state)
    edge, edge_state = edge_item_state
    ids = tit.automaton.Σ[edge]
    return new_id_iterate(tit, edge, edge_state, ids, iterate(ids))
end
function Base.iterate(tit::LightTransitionIterator)
    return new_edge_iterate(tit, iterate(tit.edge_iterator))
end
function Base.iterate(tit::LightTransitionIterator, edge_id_state)
    edge, edge_state, ids, id_state = edge_id_state
    return new_id_iterate(tit, edge, edge_state, ids, iterate(ids, id_state))
end

states(A::LightAutomaton) = Graphs.vertices(A.G)
nstates(A::LightAutomaton) = Graphs.nv(A.G)

transitiontype(A::LightAutomaton) = LightTransition{Graphs.edgetype(A.G)}
function transitions(A::LightAutomaton)
    return LightTransitionIterator(A, Graphs.edges(A.G))
end
ntransitions(A::LightAutomaton) = A.nt

function edge_object(A::LightAutomaton, q, r)
    @assert 1 <= q <= nstates(A)
    @assert 1 <= r <= nstates(A)
    return Graphs.Edge(q, r)
end

# return transitions with source `q` and target `r`
function transitions(A::LightAutomaton{GT, ET}, q, r) where {GT, ET}
    e = edge_object(A, q, r)
    LightTransitionIterator(A, Fill(e, Graphs.has_edge(A.G, e) ? 1 : 0))
end

function add_transition!(A::LightAutomaton, q, r, σ)
    edge = edge_object(A, q, r)
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
        Graphs.add_edge!(A.G, edge)
        A.Σ[edge] = ids
    end
    return LightTransition(edge, id)
end
function has_transition(A::LightAutomaton, q, r)
    return Graphs.has_edge(A.G, edge_object(A, q, r))
end
function has_transition(A::LightAutomaton, t::LightTransition)
    return Graphs.has_edge(A.G, t.edge) && haskey(A.Σ[t.edge], t.id)
end
function rem_transition!(A::LightAutomaton, t::LightTransition)
    ids = A.Σ[t.edge]
    delete!(ids, t.id)
    A.nt -= 1
    if isempty(ids)
        Graphs.rem_edge!(A.G, t.edge)
        delete!(A.Σ, t.edge)
    end
end

function rem_state!(A::LightAutomaton, st)
    # We need to collect as we delete them in the loop
    for t in collect(in_transitions(A, st))
        rem_transition!(A, t)
    end
    for t in collect(out_transitions(A, st))
        rem_transition!(A, t)
    end
    return Graphs.rem_vertex!(A.G, st)
end

function add_state!(A::LightAutomaton)
    return Graphs.add_vertex!(A.G)
end

source(::LightAutomaton, t::LightTransition) = t.edge.src
event(A::LightAutomaton, t::LightTransition) = A.Σ[t.edge][t.id]
target(::LightAutomaton, t::LightTransition) = t.edge.dst

function in_transitions(A::LightAutomaton{GT, ET}, s) where {GT, ET}
    f(src) = edge_object(A, src, s)
    inneigh = Graphs.inneighbors(A.G, s)
    edges = ReadonlyMappedArray{ET, 1, typeof(inneigh), typeof(f)}(f, inneigh)
    LightTransitionIterator(A, edges)
end
function out_transitions(A::LightAutomaton{GT, ET}, s) where {GT, ET}
    f(dst) = edge_object(A, s, dst)
    outneigh = Graphs.outneighbors(A.G, s)
    edges = ReadonlyMappedArray{ET, 1, typeof(outneigh), typeof(f)}(f, outneigh)
    LightTransitionIterator(A, edges)
end

struct LightStateProperty{GT, ET, T} <: StateProperty{T}
    automaton::LightAutomaton{GT, ET}
    value::Vector{T}
end
function state_property_type(::Type{LightAutomaton{GT, ET}},
                             T::Type) where {GT, ET}
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
