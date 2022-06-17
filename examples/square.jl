using FillArrays
using MathematicalSystems
using HybridSystems
using Polyhedra
using LinearAlgebra

function square_example(lib::Polyhedra.Library)
    automaton = GraphAutomaton(1)
    add_transition!(automaton, 1, 1, 1)

    domain_hrep = HalfSpace([1, 0], 1) ∩ HalfSpace([-1, 0], 1) ∩ HalfSpace([0, 1], 1) ∩ HalfSpace([0, -1], 1)
    domain = polyhedron(domain_hrep, lib)

    mode = ConstrainedContinuousIdentitySystem(2, domain)
    reset_map = LinearControlDiscreteSystem(Matrix(1.0I, 2, 2), Matrix{Float64}(undef, 2, 0))

    switching_type = AutonomousSwitching()

    modes = Fill(mode, 1)
    reset_maps = Fill(reset_map, 1)
    switching_types = Fill(switching_type, 1)

    return HybridSystem(automaton, modes, reset_maps, switching_types)
end
