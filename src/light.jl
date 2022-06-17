import MappedArrays
import Graphs

using MappedArrays: ReadonlyMappedArray

"""
    GraphAutomaton{GT, ET} <: AbstractAutomaton

A hybrid automaton that uses the `Graphs` backend. See the constructor
[`GraphAutomaton(::Int)`](@ref).

###  Fields

- `G` -- graph of type `GT` whose vertices determine the states
- `Σ` -- dictionary mapping the edges to their labels
"""
mutable struct GraphAutomaton{GT, ET} <: AbstractAutomaton
    G::GT
    Σ::Dict{ET, Dict{Int, Int}}
    next_id::Int
    nt::Int
end

"""
    GraphAutomaton(n::Int)

Creates a `GraphAutomaton` with `n` states 1, 2, ..., `n`.
The automaton is initialized without any transitions,
use [`add_transition!`](@ref) to add transitions.

## Examples

To create an automaton with 2 nodes 1, 2, self-loops of labels 1, a transition
from 1 to 2 with label 2 and transition from 2 to 1 with label 3, do the
following:
```jldoctest
julia> a = GraphAutomaton(2);

julia> add_transition!(a, 1, 1, 1) # Add a self-loop of label 1 for state 1
HybridSystems.GraphTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 1 => 1, 1)

julia> add_transition!(a, 2, 2, 1) # Add a self-loop of label 1 for state 2
HybridSystems.GraphTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 2 => 2, 2)

julia> add_transition!(a, 1, 2, 2) # Add a transition from state 1 to state 2 with label 2
HybridSystems.GraphTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 1 => 2, 3)

julia> add_transition!(a, 2, 1, 3) # Add a transition from state 2 to state 1 with label 3
HybridSystems.GraphTransition{Graphs.SimpleGraphs.SimpleEdge{Int64}}(Edge 2 => 1, 4)
```
"""
function GraphAutomaton(n::Int)
    G = Graphs.DiGraph(n)
    Σ = Dict{Graphs.edgetype(G), Dict{Int, Int}}()
    GraphAutomaton(G, Σ, 0, 0)
end

struct GraphTransition{ET} <: AbstractTransition
    edge::ET
    id::Int
end

"""
    struct GraphTransitionIterator{GT, ET, VT}
        automaton::GraphAutomaton{GT, ET}
        edge_iterator::VT
    end

Iterate over the transitions of `automaton` by iterating over the edges `edge`
of `edge_iterator` and the ids `id` of `automaton.Σ[edge]` for each one. Its
elements are `GraphTransition(edge, id)`.
"""
struct GraphTransitionIterator{GT, ET, VT}
    automaton::GraphAutomaton{GT, ET}
    edge_iterator::VT
end
Base.eltype(::GraphTransitionIterator{GT, ET}) where {GT, ET} = GraphTransition{ET}
function Base.length(tit::GraphTransitionIterator)
    eit = tit.edge_iterator
    # empty iterator must be handled separately (see #29)
    return isempty(eit) ? 0 : sum(edge -> length(tit.automaton.Σ[edge]), eit)
end
function new_id_iterate(tit::GraphTransitionIterator, edge, edge_state, ids, ::Nothing)
    return new_edge_iterate(tit, iterate(tit.edge_iterator, edge_state))
end
function new_id_iterate(tit::GraphTransitionIterator, edge, edge_state, ids, id_item_state)
    idσ, id_state = id_item_state
    return GraphTransition(edge, idσ[1]), (edge, edge_state, ids, id_state)
end
new_edge_iterate(::GraphTransitionIterator, ::Nothing) = nothing
function new_edge_iterate(tit::GraphTransitionIterator, edge_item_state)
    edge, edge_state = edge_item_state
    ids = tit.automaton.Σ[edge]
    return new_id_iterate(tit, edge, edge_state, ids, iterate(ids))
end
function Base.iterate(tit::GraphTransitionIterator)
    return new_edge_iterate(tit, iterate(tit.edge_iterator))
end
function Base.iterate(tit::GraphTransitionIterator, edge_id_state)
    edge, edge_state, ids, id_state = edge_id_state
    return new_id_iterate(tit, edge, edge_state, ids, iterate(ids, id_state))
end

states(A::GraphAutomaton) = Graphs.vertices(A.G)
nstates(A::GraphAutomaton) = Graphs.nv(A.G)

transitiontype(A::GraphAutomaton) = GraphTransition{Graphs.edgetype(A.G)}
function transitions(A::GraphAutomaton)
    return GraphTransitionIterator(A, Graphs.edges(A.G))
end
ntransitions(A::GraphAutomaton) = A.nt

function edge_object(A::GraphAutomaton, q, r)
    @assert 1 <= q <= nstates(A)
    @assert 1 <= r <= nstates(A)
    return Graphs.Edge(q, r)
end

# return transitions with source `q` and target `r`
function transitions(A::GraphAutomaton{GT, ET}, q, r) where {GT, ET}
    e = edge_object(A, q, r)
    GraphTransitionIterator(A, Fill(e, Graphs.has_edge(A.G, e) ? 1 : 0))
end

function add_transition!(A::GraphAutomaton, q, r, σ)
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
    return GraphTransition(edge, id)
end
function has_transition(A::GraphAutomaton, q, r)
    return Graphs.has_edge(A.G, edge_object(A, q, r))
end
function has_transition(A::GraphAutomaton, t::GraphTransition)
    return Graphs.has_edge(A.G, t.edge) && haskey(A.Σ[t.edge], t.id)
end
function rem_transition!(A::GraphAutomaton, t::GraphTransition)
    ids = A.Σ[t.edge]
    delete!(ids, t.id)
    A.nt -= 1
    if isempty(ids)
        Graphs.rem_edge!(A.G, t.edge)
        delete!(A.Σ, t.edge)
    end
end

function rem_state!(A::GraphAutomaton, st)
    # We need to collect as we delete them in the loop
    for t in collect(in_transitions(A, st))
        rem_transition!(A, t)
    end
    for t in collect(out_transitions(A, st))
        rem_transition!(A, t)
    end
    return Graphs.rem_vertex!(A.G, st)
end

function add_state!(A::GraphAutomaton)
    return Graphs.add_vertex!(A.G)
end

source(::GraphAutomaton, t::GraphTransition) = t.edge.src
event(A::GraphAutomaton, t::GraphTransition) = A.Σ[t.edge][t.id]
target(::GraphAutomaton, t::GraphTransition) = t.edge.dst

function in_transitions(A::GraphAutomaton{GT, ET}, s) where {GT, ET}
    f(src) = edge_object(A, src, s)
    inneigh = Graphs.inneighbors(A.G, s)
    edges = ReadonlyMappedArray{ET, 1, typeof(inneigh), typeof(f)}(f, inneigh)
    GraphTransitionIterator(A, edges)
end
function out_transitions(A::GraphAutomaton{GT, ET}, s) where {GT, ET}
    f(dst) = edge_object(A, s, dst)
    outneigh = Graphs.outneighbors(A.G, s)
    edges = ReadonlyMappedArray{ET, 1, typeof(outneigh), typeof(f)}(f, outneigh)
    GraphTransitionIterator(A, edges)
end

struct GraphStateProperty{GT, ET, T} <: StateProperty{T}
    automaton::GraphAutomaton{GT, ET}
    value::Vector{T}
end
function state_property_type(::Type{GraphAutomaton{GT, ET}},
                             T::Type) where {GT, ET}
    return GraphStateProperty{GT, ET, T}
end
function state_property(automaton::GraphAutomaton, T::Type)
    return GraphStateProperty(automaton, Vector{T}(undef, nstates(automaton)))
end
function Base.getindex(p::GraphStateProperty,
                       s::Int)
    p.value[s]
end
function Base.setindex!(p::GraphStateProperty, value,
                        s::Int)
    p.value[s] = value
end

struct GraphTransitionProperty{GT, ET, T} <: TransitionProperty{T}
    automaton::GraphAutomaton{GT, ET}
    value::Vector{T}
end
function transition_property_type(::Type{GraphAutomaton{GT, ET}}, T::Type) where {GT, ET}
    return GraphTransitionProperty{GT, ET, T}
end
function transition_property(automaton::GraphAutomaton, T::Type)
    return GraphTransitionProperty(automaton, Vector{T}(undef, automaton.next_id))
end
function Base.getindex(p::GraphTransitionProperty,
                       t::GraphTransition)
    p.value[t.id]
end
function Base.setindex!(p::GraphTransitionProperty, value,
                        t::GraphTransition)
    p.value[t.id] = value
end
