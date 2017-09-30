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
states(hs::HybridSystem) = states(hs.A)
nstates(hs::HybridSystem) = nstates(hs.A)
source(::HybridSystem, t) = 1
event(::HybridSystem, t) = t
target(::HybridSystem, t) = 1
in_transitions(A::HybridSystem, s) = 1:s.nt
out_transitions(A::HybridSystem, s) = 1:s.nt

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
