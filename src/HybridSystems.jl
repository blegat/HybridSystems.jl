module HybridSystems

include("automata.jl")
include("maps.jl")
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

- `automaton`  -- hybrid automaton
- `modes`      -- vector of modes indexed by the discrete states,
                  both the domain and the dynamic are stored in this field.
                  See [`stateset`](@ref) to access the domain.
- `resetmaps`  -- vector of reset maps indexed by the discrete states,
                  the guard is stored as constraint of the map in this field.
                  See [`stateset`](@ref) to access the guard.
- `switchings` -- vector of switchings, see [`AbstractSwitching`](@ref)
- `ext`        -- dictionary that can be used by extensions
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
for f in (:states, :nstates, :transitiontype, :transitions, :ntransitions, :source, :event, :target, :has_transition, :in_transitions, :out_transitions)
    @eval begin
        $f(hs::HybridSystem, args...) = $f(hs.automaton, args...)
    end
end

# System
export statedim, stateset, inputdim, inputset
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
    stateset(s::AbstractSystem, t)

Returns the guard for the transition `t`.
"""
MathematicalSystems.stateset(hs::HybridSystem, t) = stateset(hs.resetmaps[symbol(hs, t)])

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

Returns the st of allowed inputs for the transition `t`.
"""
MathematicalSystems.inputset(hs::HybridSystem, t) = inputset(hs.resetmaps[symbol(hs, t)])

function Base.show(io::IO, hs::HybridSystem)
    print(io, "Hybrid System with automaton ")
    print(io, hs.automaton)
end

# Particular cases
include("switchedsystems.jl")

end # module
