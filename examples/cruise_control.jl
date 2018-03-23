# Section 6.1 of
# [RMT13] Rungger, Matthias and Mazo Jr, Manuel and Tabuada, Paulo
# Specification-guided controller synthesis for linear systems and safe linear-time temporal logic
# Proceedings of the 16th international conference on Hybrid systems: computation and control, 2013

using FillArrays
using SemialgebraicSets
using HybridSystems
using Polyhedra
using CDDLib

function cruise_control_example(N, M; vmin = 5., vmax = 35., v = (15.6, 24.5), U = 4, D = 0.5, ks = 4500, kd = 4600, m = 1000, m0 = 100, H = 0.8, T = 2, h = H / T, sym = false)
    function Pv(v, maxspeed)
        s = maxspeed ? 1. : -1.
        Pvi = polyhedron(SimpleHRepresentation([0 s], [s*v]), CDDLibrary())
        Pv0 = polyhedron(SimpleHRepresentation([s 0], [s*v]), CDDLibrary())
        if M >= 1
            Pvi^M * Pv0
        else
            Pv0
        end
    end
    PD = polyhedron(SimpleHRepresentation([-1. 0
                                            1  0],
                                          [D, D]), CDDLibrary())
    PU = polyhedron(SimpleHRepresentation([0 -1.;
                                           0  1.], [U, U]), CDDLibrary())
    if M >= 1
        P0 = PD^M * PU
    else
        P0 = PU
    end
    if sym
        Pv0max = Pv(vmax, true) ∩ Pv(-vmax, false)
        Pvimax = Pv.(v, true) .∩ Pv.(.-(v), false)
        P1 = P0
    else
        Pv0max = Pv(vmax, true)
        Pvimax = Pv.(v, true)
        Pvmin = Pv(vmin, false)
        P1 = P0 ∩ Pvmin
    end

    G = LightAutomaton(N)
    if N == 1
        add_transition!(G, 1, 1, 1)
        I = [P1 ∩ Pvimax[1]]
    elseif N == 2
        add_transition!(G, 1, 2, 1)
        add_transition!(G, 2, 2, 1)
        I = [P1 ∩ Pv0max, P1 ∩ Pvimax[1]]
    else
        @assert N == 1 + (T+1) * length(v)
        I = Vector{typeof(P1)}(N)
        function new_speed_signal!(u)
            for (j, vj) in enumerate(v)
                w = (T+1)*(j-1) + T+1
                add_transition!(G, u, w, 2)
            end
        end
        for (i, vi) in enumerate(v)
            for t in 1:(T+1)
                u = (T+1)*(i-1) + t
                if t == 1
                    add_transition!(G, u, u, 1)
                    I[u] = P1 ∩ Pvimax[i]
                else
                    add_transition!(G, u, u-1, 1)
                    I[u] = P1 ∩ Pv0max
                end
                new_speed_signal!(u)
            end
        end
        add_transition!(G, N, N, 1)
        I[N] = P1 ∩ Pv0max
        new_speed_signal!(N)
    end

    d = 2M + 2
    is = DiscreteIdentitySystem(d)
    #s = DiscreteLinearControlSystem([1. 0; 0 1], reshape([1.; 0], 2, 1), U)
    A = zeros(d-1, d-1)
    for i in 1:M
        di = 2i-1
        vi = 2i
        vj = i == 1 ? d-1 : 2(i-1)
        A[di, vi] = -1
        A[di, vj] =  1
        A[vi, vj] =  kd/m
        A[vi, di] =  ks/m
        A[vi, vi] = -kd/m
        if i < M
            dj = 2i+1
            vk = 2(i+1)
            A[vi, vi] += -kd/m
            A[vi, dj]  = -ks/m
            A[vi, vk]  =  kd/m
        end
    end
    A[d-1, 1]   =  ks/m0
    A[d-1, d-1] = -kd/m0
    A[d-1, 2]   =  kd/m0
    A1 = [eye(d-1)+h*A [zeros(d-2); h]
          zeros(d-1)'  0]
    B = reshape([zeros(d-1); 1.], d, 1)
    s1 = DiscreteLinearControlSystem(A1, B)
    A2 = [eye(d-1)     zeros(d-1)
          zeros(d-1)'  0]
    s2 = DiscreteLinearControlSystem(A2, B)

    sw = AutonomousSwitching()

    fs = FullSpace()

    M = LightGraphs.ne(G.G)

    S = Fill(is, N)
    Gu = Fill(fs, M)
    Re = [s1, s2]
    Sw = Fill(sw, N)

    HybridSystem(G, S, I, Gu, Re, Sw)
end
