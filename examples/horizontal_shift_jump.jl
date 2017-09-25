using HybridSystems
A = LightAutomaton(2)
add_transition!(A, 1, 2, 1)
add_transition!(A, 2, 1, 1)

using Polyhedra
using CDDLib
H1 = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [1, 3, 1, -1]), CDDLibrary())
H2 = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [4, 2, -2, 1]), CDDLibrary())
#H2 = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [4, 2, -2, 0]), CDDLibrary())
U = polyhedron(SimpleHRepresentation(reshape([1., -1.], 2, 1), [2., -2.]), CDDLibrary())

is = DiscreteIdentitySystem(2)
#s = DiscreteLinearControlSystem([1. 0; 0 1], reshape([1.; 0], 2, 1), U)
s = DiscreteLinearControlSystem([1. 0; 0 1], reshape([1.; 0], 2, 1))

sw = ControlledSwitching()

using SemialgebraicSets
fs = FullSpace()

S = ConstantVector(is, 2)
Gu = ConstantVector(fs, 2)
Re = ConstantVector(s, 2)
Sw = ConstantVector(sw, 2)

hs = HybridSystem(A, S, [H1, H2], Gu, Re, Sw)
