# Section 6.1 : Truck without trailer of
# [RMT13] Rungger, Matthias and Mazo Jr, Manuel and Tabuada, Paulo
# Specification-guided controller synthesis for linear systems and safe linear-time temporal logic
# Proceedings of the 16th international conference on Hybrid systems: computation and control, 2013

N = 2

using FillArrays
using HybridSystems
A = GraphAutomaton(N)
add_transition!(A, 1, 2, 1)
add_transition!(A, 2, 2, 1)
##add_transition!(A, 2, 3, 1)
##add_transition!(A, 3, 4, 1)
##add_transition!(A, 4, 4, 1)
#add_transition!(A, 1, 5, 1)
#add_transition!(A, 5, 6, 1)
#add_transition!(A, 6, 7, 1)

using Polyhedra
using CDDLib
const U = 4
const va = 15.6
const vb = 24.5
P0 = polyhedron(SimpleHRepresentation([-1. 0; 1 0; 0 -1; 0 1], [0., 35, U, U]), CDDLibrary())
Pa = polyhedron(SimpleHRepresentation([1. 0], [va]), CDDLibrary())
Pb = polyhedron(SimpleHRepresentation([1. 0], [vb]), CDDLibrary())

is = ContinuousIdentitySystem(2)
#s = DiscreteLinearControlSystem([1. 0; 0 1], reshape([1.; 0], 2, 1), U)
const h = 0.4
s = DiscreteLinearControlSystem([1 h; 0 0], reshape([0; h], 2, 1)) # TODO [0; 1] should be equivalent and more correct

sw = AutonomousSwitching()

using SemialgebraicSets
fs = FullSpace()

M = Graphs.ne(A.G)

S = Fill(is, N)
Gu = Fill(fs, M)
Re = Fill(s, M)
Sw = Fill(sw, N)

#I = [P0, P0, P0, P0 ∩ Pa]
I = [P0, P0 ∩ Pa]

hs = HybridSystem(A, S, I, Gu, Re, Sw)
