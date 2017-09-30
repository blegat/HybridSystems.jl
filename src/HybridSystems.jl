module HybridSystems

include("automata.jl")
include("systems.jl")
include("maps.jl")
include("switchings.jl")

export AbstractHybridSystem, HybridSystem

abstract type AbstractHybridSystem <: AbstractSystem end

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

# The hybrid system both acts like an automaton and a system

# Automaton
for f in (:states, :nstates, :source, :event, :target, :in_transitions, :out_transitions)
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
