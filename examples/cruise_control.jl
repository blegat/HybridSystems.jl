# Section 6.1 : Truck without trailer of
# [RMT13] Rungger, Matthias and Mazo Jr, Manuel and Tabuada, Paulo
# Specification-guided controller synthesis for linear systems and safe linear-time temporal logic
# Proceedings of the 16th international conference on Hybrid systems: computation and control, 2013

N = 1

using HybridSystems
G = LightAutomaton(N)
add_transition!(G, 1, 1, 1)
##add_transition!(A, 2, 3, 1)
##add_transition!(A, 3, 4, 1)
##add_transition!(A, 4, 4, 1)
#add_transition!(A, 1, 5, 1)
#add_transition!(A, 5, 6, 1)
#add_transition!(A, 6, 7, 1)

using Polyhedra
using CDDLib
const D = 0.5
const U = 4
const va = 15.6
const vb = 24.5
const ks = 4500
const kd = 4600
const m = 1000
P0 = polyhedron(SimpleHRepresentation([-1. 0  0  0;
                                        1  0  0  0;
                                        0 -1  0  0;
                                        0  1  0  0;
                                        0  0 -1  0;
                                        0  0  1  0;
                                        0  0  0 -1;
                                        0  0  0  1],
                                      [D, D, -5., 35, -5, 35, U, U]), CDDLibrary())
Pa = polyhedron(SimpleHRepresentation([0 1. 0  0;
                                       0 0  1. 0], [va, va]), CDDLibrary())
Pb = polyhedron(SimpleHRepresentation([1. 0], [vb]), CDDLibrary())

is = DiscreteIdentitySystem(4)
#s = DiscreteLinearControlSystem([1. 0; 0 1], reshape([1.; 0], 2, 1), U)
const h = 0.4
Ac = [0    -1    1
      ks/m -kd/m kd/m
      0    0     0]
A = [eye(3)+h*Ac [0,0,h]
     zeros(3)'   0]
s = DiscreteLinearControlSystem(A, reshape([0; 0; 0; 1.], 4, 1))

sw = AutonomousSwitching()

using SemialgebraicSets
fs = FullSpace()

M = LightGraphs.ne(G.G)

S = ConstantVector(is, N)
Gu = ConstantVector(fs, M)
Re = ConstantVector(s, M)
Sw = ConstantVector(sw, N)

#I = [P0, P0, P0, P0 ∩ Pa]
#I = [P0, P0 ∩ Pa]
I = [P0 ∩ Pa]

hs = HybridSystem(G, S, I, Gu, Re, Sw)
