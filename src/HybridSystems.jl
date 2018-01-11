module HybridSystems

include("automata.jl")
include("systems.jl")
include("maps.jl")
include("switchings.jl")

export AbstractHybridSystem, HybridSystem

"""
    AbstractHybridSystem

Abstract supertype for a hybrid system.
"""
abstract type AbstractHybridSystem <: AbstractSystem end

"""
    HybridSystem{A, S, I, G, R, W} <: AbstractHybridSystem

A hybrid system modelled as a hybrid automaton.

### Fields

- `automaton`  -- hybrid automaton
- `modes`      -- vector of modes
- `invariants` -- vector of invariants
- `guards`     -- vector of guards
- `resetmaps`  -- vector of reset maps
- `switchings` -- vector of switchings
- `ext`        -- dictionary that can be used by extensions
"""
struct HybridSystem{A, S, I, G, R, W} <: AbstractHybridSystem
    automaton::A
    modes::AbstractVector{S}
    invariants::AbstractVector{I}
    guards::AbstractVector{G}
    resetmaps::AbstractVector{R}
    switchings::AbstractVector{W}
    # Can be used by extensions
    ext::Dict{Symbol, Any}
end
function HybridSystem(a, m, i, g, r, s)
    HybridSystem(a, m, i, g, r, s, Dict{Symbol, Any}())
end

# The hybrid system both acts like an automaton and a system

# Automaton
for f in (:states, :nstates, :transitiontype, :transitions, :ntransitions, :source, :event, :target, :has_transition, :in_transitions, :out_transitions)
    @eval begin
        $f(hs::HybridSystem, args...) = $f(hs.automaton, args...)
    end
end

# System
statedim(hs::HybridSystem, s) = statedim(hs.modes[s])

function Base.show(io::IO, hs::HybridSystem)
    print(io, "Hybrid System with automaton ")
    print(io, hs.automaton)
end

include("constantvector.jl")

# Particular cases
include("switchedsystems.jl")

end # module
