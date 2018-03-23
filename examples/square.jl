using FillArrays
using HybridSystems
A = LightAutomaton(1)
add_transition!(A, 1, 1, 1)

using Polyhedra
using CDDLib
H = polyhedron(SimpleHRepresentation([eye(2); -eye(2)], [ones(2); ones(2)]), CDDLibrary())

is = DiscreteIdentitySystem(2)
s = DiscreteLinearControlSystem(eye(2), Matrix{Float64}(2, 0))

sw = AutonomousSwitching()

using SemialgebraicSets
fs = FullSpace()

S = Fill(is, 1)
In = Fill(H, 1)
Gu = Fill(fs, 1)
Re = Fill(s, 1)
Sw = Fill(sw, 1)

hs = HybridSystem(A, S, In, Gu, Re, Sw)
