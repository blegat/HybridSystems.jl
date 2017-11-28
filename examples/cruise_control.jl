# Section 6.1 of
# [RMT13] Rungger, Matthias and Mazo Jr, Manuel and Tabuada, Paulo
# Specification-guided controller synthesis for linear systems and safe linear-time temporal logic
# Proceedings of the 16th international conference on Hybrid systems: computation and control, 2013

using SemialgebraicSets
using HybridSystems
using Polyhedra
using CDDLib

function cruise_control_example(N, with_trailer; vmin = 5., vmax = 35., v = (15.6, 24.5), U = 4, D = 0.5, ks = 4500, kd = 4600, m = 1000, h = 0.4, sym=false)
    G = LightAutomaton(N)
    if N == 1
        add_transition!(G, 1, 1, 1)
    elseif N == 2
        add_transition!(G, 1, 2, 1)
        add_transition!(G, 2, 2, 1)
    else
        @assert N == 7
        add_transition!(G, 2, 3, 1)
        add_transition!(G, 3, 4, 1)
        add_transition!(G, 4, 4, 1)
        add_transition!(G, 1, 5, 1)
        add_transition!(G, 5, 6, 1)
        add_transition!(G, 6, 7, 1)
    end

    function Pv(v, maxspeed)
        s = maxspeed ? 1. : -1.
        if with_trailer
            polyhedron(SimpleHRepresentation([0 s 0 0
                                              0 0 s 0], [s*v, s*v]), CDDLibrary())
        else
            polyhedron(SimpleHRepresentation([s 0], [s*v]), CDDLibrary())
        end
    end
    if with_trailer
        P0 = polyhedron(SimpleHRepresentation([-1. 0  0  0;
                                                1  0  0  0;
                                                0  0  0 -1;
                                                0  0  0  1],
                                              [D, D, U, U]), CDDLibrary())
    else
        P0 = polyhedron(SimpleHRepresentation([0 -1.;
                                               0  1.], [U, U]), CDDLibrary())
    end
    if sym
        Pvmax = Pv(vmax, true) ∩ Pv(vmax, false)
        Pvi = Pv.(v, true) .∩ Pv.(v, false)
        P1 = P0
    else
        Pvmax = Pv(vmax, true)
        Pvi = Pv.(v, true)
        Pvmin = Pv(vmin, false)
        P1 = P0 ∩ Pvmin
    end
    if N == 1
        I = [P1 ∩ Pvi[1]]
    elseif N == 2
        I = [P1 ∩ Pvmax, P1 ∩ Pvi[1]]
    else
        error("TODO")
    end

    d = with_trailer ? 4 : 2
    is = DiscreteIdentitySystem(with_trailer ? 4 : 2)
    #s = DiscreteLinearControlSystem([1. 0; 0 1], reshape([1.; 0], 2, 1), U)
    if with_trailer
        Ac = [0    -1    1
              ks/m -kd/m kd/m
              0    0     0]
    else
        Ac = zeros(1, 1)
    end
    A = [eye(d-1)+h*Ac [zeros(d-2); h]
         zeros(d-1)'   0]
    s = DiscreteLinearControlSystem(A, reshape([zeros(d-1); 1.], d, 1))

    sw = AutonomousSwitching()

    fs = FullSpace()

    M = LightGraphs.ne(G.G)

    S = ConstantVector(is, N)
    Gu = ConstantVector(fs, M)
    Re = ConstantVector(s, M)
    Sw = ConstantVector(sw, N)

    HybridSystem(G, S, I, Gu, Re, Sw)
end
