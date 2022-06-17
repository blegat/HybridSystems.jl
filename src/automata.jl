export GraphAutomaton, AbstractAutomaton, OneStateAutomaton
export states, modes, nstates, nmodes, transitions, ntransitions
export source, event, symbol, target, transitiontype
export add_transition!, has_transition, rem_transition!, rem_state!, add_state!
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

Base.broadcastable(A::AbstractAutomaton) = Ref(A)

"""
    AbstractTransition

Abstract type for the transition of an automaton.
"""
abstract type AbstractTransition end

Base.broadcastable(t::AbstractTransition) = Ref(t)

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

    transitions(A::AbstractAutomaton, q, r)

Returns an iterator over the transitions from state `q` to state `r` of the automaton `A`.
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
    has_transition(A::AbstractAutomaton, t::AbstractTransition)::Bool

Returns a `Bool` indicating whether the automaton `A` has the transition `t`.

    has_transition(A::AbstractAutomaton, q, r)::Bool

Returns a `Bool` indicating whether the automaton `A` has a transition from
state `q` to state `r`.
"""
function has_transition end

"""
    rem_transition!(A::AbstractAutomaton, t::AbstractTransition)

Remove the transition `t` from the automaton `A`.
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

include("onestate.jl")
include("light.jl")
