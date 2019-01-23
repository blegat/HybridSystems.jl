# Section 6.1 of [RMT13] and running example of [LTJ18]
#
# [RMT13] Rungger, Matthias and Mazo Jr, Manuel and Tabuada, Paulo
# Specification-guided controller synthesis for linear systems and safe linear-time temporal logic
# Proceedings of the 16th international conference on Hybrid systems: computation and control, 2013
#
# [LTJ18] Legat, Benoît and Tabuada, Paulo and Jungers, Raphaël M.
# Computing controlled invariant sets for hybrid systems with applications to model-predictive control
# https://www.sciencedirect.com/science/article/pii/S2405896318311480

using Compat, Compat.LinearAlgebra
using FillArrays
import LightGraphs
using MathematicalSystems
using HybridSystems
using Polyhedra

"""
    cruise_control_example(N, M; vmin = 5., vmax = 35., v = (15.6, 24.5), U = 4,
                           D = 0.5, ks = 4500, kd = 4600, m = 1000, m0 = 100,
                           H = 0.8, T = 2, h = H / T, sym = false)

Hybrid System representing the speed of a truck and its `M` trailers.
The mass of the truck is `m0` and the mass of each trailer is `m`.
The dynamic is discretized over step sizes of length `h`.
"""
function cruise_control_example(N, M; vmin = 5., vmax = 35., v = (15.6, 24.5), U = 4, D = 0.5, ks = 4500, kd = 4600, m = 1000, m0 = 100, H = 0.8, T = 2, h = H / T, sym = false, lib::Polyhedra.Library = Polyhedra.default_library(2M+2, Float64))
    function Pv(v, maxspeed)
        s = maxspeed ? 1. : -1.
        Pvi = intersect(HalfSpace([0, s], s*v))
        Pv0 = intersect(HalfSpace([s, 0], s*v))
        if M >= 1
            Base.power_by_squaring(Pvi, M) * Pv0
        else
            Pv0
        end
    end
    PD = HalfSpace([-1., 0], D) ∩ HalfSpace([1., 0], D)
    PU = HalfSpace([0., -1], U) ∩ HalfSpace([0, 1.], U)
    if M >= 1
        P0 = Base.power_by_squaring(PD, M) * PU
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
        safe_sets = [P1 ∩ Pvimax[1]]
    elseif N == 2
        add_transition!(G, 1, 2, 1)
        add_transition!(G, 2, 2, 1)
        safe_sets = [P1 ∩ Pv0max, P1 ∩ Pvimax[1]]
    else
        @assert N == 1 + (T+1) * length(v)
        safe_sets = Vector{typeof(P1)}(undef, N)
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
                    safe_sets[u] = P1 ∩ Pvimax[i]
                else
                    add_transition!(G, u, u-1, 1)
                    safe_sets[u] = P1 ∩ Pv0max
                end
                new_speed_signal!(u)
            end
        end
        add_transition!(G, N, N, 1)
        safe_sets[N] = P1 ∩ Pv0max
        new_speed_signal!(N)
    end

    d = 2M + 2
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
    A1 = [I+h*A [zeros(d-2); h]
          zeros(d-1)'  0]
    B = reshape([zeros(d-1); 1.], d, 1)
    s1 = LinearControlDiscreteSystem(A1, B)
    A2 = [Matrix(1.0I, d-1, d-1) zeros(d-1)
          zeros(d-1)'            0]
    s2 = LinearControlDiscreteSystem(A2, B)

    sw = AutonomousSwitching()

    M = LightGraphs.ne(G.G)

    S = ConstrainedDiscreteIdentitySystem.(d, polyhedron.(safe_sets, lib))
    Re = [s1, s2]
    Sw = Fill(sw, N)

    HybridSystem(G, S, Re, Sw)
end
