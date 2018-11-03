import MappedArrays

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
function transitions(A::OneStateAutomaton)
    # mappedarray avoid allocation
    MappedArrays.mappedarray(OneStateTransition, Base.OneTo(A.nt))
end
ntransitions(A::OneStateAutomaton) = A.nt
source(::OneStateAutomaton, t::OneStateTransition) = 1
event(::OneStateAutomaton, t::OneStateTransition) = t.σ
target(::OneStateAutomaton, t::OneStateTransition) = 1
in_transitions(A::OneStateAutomaton, s) = transitions(A)
out_transitions(A::OneStateAutomaton, s) = transitions(A)
function has_transition(A::OneStateAutomaton, q, r)
    @assert q == 1
    @assert r == 1
    return !iszero(A.nt)
end
function has_transition(A::OneStateAutomaton, t::OneStateTransition)
    return 1 <= t.σ <= A.nt
end

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
