using FillArrays
using Systems
using HybridSystems
using Polyhedra

function horizontal_jump_example(lib::PolyhedraLibrary, shift::Bool=false)
    A = LightAutomaton(2)
    add_transition!(A, 1, 2, 1)
    add_transition!(A, 2, 1, 2)

    if shift
        H1 = polyhedron(hrep([eye(2); -eye(2)], [ones(2); ones(2)]), lib)
    else
        H1 = polyhedron(hrep([eye(2); -eye(2)], [1., 3, 1, -1]), lib)
    end
    H2 = polyhedron(hrep([eye(2); -eye(2)], [4, 1 + shift, -2, 1]), lib)
    U = polyhedron(hrep(reshape([1., -1.], 2, 1), [2., -2.]), lib)

    S = ConstrainedDiscreteIdentitySystem.(2, [H1, H2])

    s1 = ConstrainedLinearControlDiscreteSystem([1. 0; 0 1], reshape([1.; 0], 2, 1), H1, U)
    s2 = ConstrainedLinearControlDiscreteSystem([1. 0; 0 1], reshape([1.; 0], 2, 1), H2, U)
    Re = [s1, s2]

    sw = AutonomousSwitching()
    Sw = Fill(sw, 2)

    HybridSystem(A, S, Re, Sw)
end
