using HybridSystems
A = LightAutomaton(1)
add_transition!(A, 1, 1, 1)

using Polyhedra
using CDDLib
H = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [ones(2); ones(2)]), CDDLibrary())

is = DiscreteIdentitySystem(2)
s = DiscreteLinearControlSystem(eye(2), Matrix{Float64}(2, 0))

sw = ControlledSwitching()

using SemialgebraicSets
fs = FullSpace()

S = ConstantVector(is, 1)
In = ConstantVector(H, 1)
Gu = ConstantVector(fs, 1)
Re = ConstantVector(s, 1)
Sw = ConstantVector(sw, 1)

hs = HybridSystem(A, S, In, Gu, Re, Sw)
