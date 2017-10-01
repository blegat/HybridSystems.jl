# Section 4 of
# [PEDJ16] M. Philippe, R. Essick, G. E. Dullerud and R. M. Jungers.
# Stability of discrete-time switching systems with constrained switching sequences.
# Automatica, 72:242-250, 2016
# and running example of
# [LJP16] Legat, B.; Jungers, R. M. & Parrilo, P. A.
# Generating unstable trajectories for Switched Systems via Dual Sum-Of-Squares techniques
# Proceedings of the 19th International Conference on Hybrid Systems: Computation and Control, ACM, 2016, 51-60
# The JSR is 0.9748171979372074

using HybridSystems
using StaticArrays

A = @SMatrix [0.94 0.56; 0.14 0.46]
B = [0; 1]
k1 = -0.49
k2 = 0.27
As = [A + B * [k1 k2], A + B * [0 k2], A + B * [k1 0], A]
@assert eltype(As) <: SMatrix
G = LightAutomaton(4)
add_transition!(G, 1, 2, 3)
add_transition!(G, 2, 1, 2)
add_transition!(G, 1, 3, 1)
add_transition!(G, 3, 1, 2)
add_transition!(G, 2, 3, 1)
add_transition!(G, 3, 2, 3)
add_transition!(G, 3, 3, 1)
add_transition!(G, 3, 4, 4)
add_transition!(G, 4, 3, 1)
hs = discreteswitchedsystem(As, G)
