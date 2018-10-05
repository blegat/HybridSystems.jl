using FillArrays
using HybridSystems
A = LightAutomaton(1)
add_transition!(A, 1, 1, 1)

using Polyhedra
using CDDLib
using LinearAlgebra
hr = HalfSpace([1, 0], 1) ∩ HalfSpace([-1, 0], 1) ∩ HalfSpace([0, 1], 1) ∩ HalfSpace([0, -1], 1)
H = polyhedron(hr, CDDLibrary())

using MathematicalSystems
is = ConstrainedContinuousIdentitySystem(2, H)
s = LinearControlDiscreteSystem(Matrix(1.0I, 2, 2), Matrix{Float64}(undef, 2, 0))

sw = AutonomousSwitching()

S = Fill(is, 1)
Re = Fill(s, 1)
Sw = Fill(sw, 1)

hs = HybridSystem(A, S, Re, Sw)
