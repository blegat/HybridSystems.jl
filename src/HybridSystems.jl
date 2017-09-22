module HybridSystems

include("automata.jl")
include("systems.jl")
include("maps.jl")
include("switchings.jl")

export AbstractHybridSystem, HybridSystem

abstract type AbstractHybridSystem end

struct HybridSystem{A, S, I, G, R, W} <: AbstractHybridSystem
    automaton::A
    modes::AbstractVector{S}
    invariants::AbstractVector{I}
    guards::AbstractVector{G}
    resetmaps::AbstractVector{R}
    switchings::AbstractVector{W}
end

function Base.show(io::IO, hs::HybridSystem)
    print(io, "Hybrid System with automaton ")
    print(io, hs.automaton)
end

include("constantvector.jl")

end # module
