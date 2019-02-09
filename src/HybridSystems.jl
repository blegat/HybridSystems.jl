module HybridSystems

include("automata.jl")
include("switchings.jl")

using MathematicalSystems

export AbstractHybridSystem, HybridSystem

"""
    AbstractHybridSystem

Abstract supertype for a hybrid system.
"""
abstract type AbstractHybridSystem <: MathematicalSystems.AbstractSystem end

"""
    HybridSystem{A, S, R, W} <: AbstractHybridSystem

A hybrid system modelled as a hybrid automaton.

### Fields

- `automaton`  -- hybrid automaton of type `A`.
- `modes`      -- vector of modes of type `S` indexed by the discrete states,
                  both the domain and the dynamic are stored in this field.
                  See [`stateset`](@ref) to access the domain.
- `resetmaps`  -- vector of reset maps of type `R` indexed by the label of the
                  transition, the guard is stored as constraint of the map in
                  this field. See [`stateset`](@ref) to access the guard.
- `switchings` -- vector of switchings of type `W` indexed by the label of the
                  transition, see [`AbstractSwitching`](@ref).
- `ext`        -- dictionary that can be used by extensions.

### Notes

The automaton `automaton` of type `A` models the different discrete states and
the allowed transitions with corresponding labels.

The mode dynamic and domain are stored in a continuous dynamical system of type
`S` in the vector `modes`. They are indexed by the discrete states of the
automaton.

The reset maps and guards are given as a map or a discrete dynamical system of
type `R` in the vector `resetmaps`. They are indexed by the labels of the
corresponding transition.

The switching of type `W` is given in the `switchings` vector, indexed by the
label of the transition.

Additional data can be stored in the `ext` field.

### Examples

See [the Thermostat example](https://github.com/blegat/HybridSystems.jl/blob/master/examples/Thermostat.ipynb).
"""
struct HybridSystem{A, S, R, W} <: AbstractHybridSystem
    automaton::A
    modes::AbstractVector{S}
    resetmaps::AbstractVector{R}
    switchings::AbstractVector{W}
    # Can be used by extensions
    ext::Dict{Symbol, Any}
end
function HybridSystem(a, m, r, s)
    HybridSystem(a, m, r, s, Dict{Symbol, Any}())
end

if VERSION >= v"0.7-"
    Base.broadcastable(hs::HybridSystem) = Ref(hs)
end

# The hybrid system both acts like an automaton and a system

# Automaton
for f in [:state_property, :transition_property, :states, :nstates, :transitiontype, :transitions, :ntransitions, :source, :event, :target, :has_transition, :in_transitions, :out_transitions]
    @eval begin
        $f(hs::HybridSystem, args...) = $f(hs.automaton, args...)
    end
end
for f in [:state_property_type, :transition_property_type]
    @eval begin
        $f(::Type{<:HybridSystem{A}}, args...) where {A} = $f(A, args...)
    end
end

# System
export statedim, stateset, inputdim, inputset, guard, assignment, target_mode, resetmap
"""
    statedim(hs::HybridSystem, u::Int)

Returns the dimension of the state space of the system at mode `u`.
"""
MathematicalSystems.statedim(hs::HybridSystem, u::Int) = statedim(hs.modes[u])

"""
    stateset(s::AbstractSystem, u::Int)

Returns the set of allowed states of the system at mode `u`.
"""
MathematicalSystems.stateset(hs::HybridSystem, u::Int) = stateset(hs.modes[u])

"""
    target_mode(hs::HybridSystem, t)

Returns the target mode for the transition `t`.
"""
target_mode(hs::HybridSystem, t) = hs.modes[target(hs, t)]

"""
    resetmap(hs::HybridSystem, t)

Returns the reset map for the transition `t`.
"""
resetmap(hs::HybridSystem, t) = hs.resetmaps[symbol(hs, t)]

"""
    assignment(hs::HybridSystem, t)

Returns the assignment for the transition `t`.
"""
assignment(hs::HybridSystem{A,S,R,W}, t) where {A, S<:AbstractSystem, R<:AbstractMap, W} = (args...) -> apply(resetmap(hs, t), args...)

"""
    guard(hs::HybridSystem, t)

Returns the guard for the transition `t`.
"""
guard(hs::HybridSystem, t) = stateset(resetmap(hs, t))

# for completeness, extend the stateset function from MathematicalSystems
# because guards are given as the state constraints of the reset map
MathematicalSystems.stateset(hs::HybridSystem, t) = guard(hs, t)

"""
    inputdim(s::AbstractSystem, u::Int)

Returns the dimension of the input space of the system at mode `u`.
"""
MathematicalSystems.inputdim(hs::HybridSystem, u::Int) = inputdim(hs.modes[u])

"""
    inputset(s::AbstractSystem, u::Int)

Returns the set of allowed inputs of the system at mode `u`.
"""
MathematicalSystems.inputset(hs::HybridSystem, u::Int) = inputset(hs.modes[u])

"""
    inputset(s::AbstractSystem, t)

Returns the set of allowed inputs for the transition `t`.
"""
MathematicalSystems.inputset(hs::HybridSystem, t) = inputset(hs.resetmaps[symbol(hs, t)])

function Base.show(io::IO, hs::HybridSystem)
    print(io, "Hybrid System with automaton ")
    print(io, hs.automaton)
end

# Particular cases
include("switchedsystems.jl")

end # module
