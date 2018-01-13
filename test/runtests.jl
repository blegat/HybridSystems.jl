using HybridSystems
using Base.Test
using Polyhedra

include("../examples/horizontal_jump.jl")
horizontal_jump_example(SimplePolyhedraLibrary{Float64}(), false)
horizontal_jump_example(SimplePolyhedraLibrary{Float64}(), true)
