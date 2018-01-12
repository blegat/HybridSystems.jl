using Systems
using HybridSystems
using Polyhedra
using CDDLib

function horizontal_jump_example(shift::Bool=false)
    A = LightAutomaton(2)
    add_transition!(A, 1, 2, 1)
    add_transition!(A, 2, 1, 1)

    if shift
        H1 = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [ones(2); ones(2)]), CDDLibrary())
    else
        H1 = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [1, 3, 1, -1]), CDDLibrary())
    end
    H2 = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [4, 1 + shift, -2, 1]), CDDLibrary())
    U = polyhedron(SimpleHRepresentation(reshape([1., -1.], 2, 1), [2., -2.]), CDDLibrary())

    S = ConstrainedDiscreteIdentitySystem.(2, [H1, H2])

    s = LinearControlDiscreteSystem([1. 0; 0 1], reshape([1.; 0], 2, 1))
    Re = ConstantVector(s, 2)

    sw = AutonomousSwitching()
    Sw = ConstantVector(sw, 2)

    hs = HybridSystem(A, S, Re, Sw)
end
