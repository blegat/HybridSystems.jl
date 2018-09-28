using Compat, Compat.Test
using FillArrays
using HybridSystems
using Polyhedra

@testset "Switched System" begin
    square = convexhull([1, 1], [-1, 1], [-1, -1], [1, -1])
    simplex = convexhull([0, 0], [0, 1], [1, 0])

    @testset "Switched System" begin
        s = discreteswitchedsystem([ones(2, 2), zeros(2, 2)])
        @test nstates(s) == 1
        @test states(s) == Base.OneTo(1)
        @test statedim(s, 1) == 2
        @test ntransitions(s) == 2
        @test eltype(transitions(s)) == transitiontype(s)
        @test transitions(s) == HybridSystems.OneStateTransition.([1, 2])
        @test source.(s, transitions(s)) == [1, 1]
        @test event.(s, transitions(s)) == [1, 2]
        @test target.(s, transitions(s)) == [1, 1]
        @test length(transitions(s)) == 2
        @test in_transitions(s, 1) == HybridSystems.OneStateTransition.([1, 2])
        @test out_transitions(s, 1) == HybridSystems.OneStateTransition.([1, 2])
    end

    @testset "State Dependent Switched System" begin
        s = discreteswitchedsystem([ones(2, 2), zeros(2, 2)], [square, simplex])
        @test nstates(s) == 2
        @test states(s) == 1:2
        @test all(statedim.(s, states(s)) .== 2)
        @test stateset(s, 1) === square
        @test stateset(s, 2) === simplex
        @test length(transitions(s)) == 4
        @test ntransitions(s) == 4
    end

    @testset "State Dependent Switched System" begin
        s = discreteswitchedsystem([ones(2, 2), zeros(2, 2)], Fill(square, 2))
        @test nstates(s) == 2
        @test states(s) == 1:2
        @test all(statedim.(s, states(s)) .== 2)
        @test stateset(s, 1) === square
        @test stateset(s, 2) === square
        @test length(transitions(s)) == 4
        @test ntransitions(s) == 4
    end
end

@testset "Examples" begin
    @testset "Horizontal jump" begin
        include("../examples/horizontal_jump.jl")
        for shift in (false, true)
            s = horizontal_jump_example(SimplePolyhedraLibrary{Float64}(), shift)
            @test nstates(s) == 2
            @test states(s) == 1:2
            for u in states(s)
                @test statedim(s, u) == 2
                @test stateset(s, u) isa Polyhedra.SimplePolyhedron{Float64}
            end
            @test length(transitions(s)) == 2
            @test ntransitions(s) == 2
            for t in transitions(s)
                @test stateset(s, t) isa Polyhedra.SimplePolyhedron{Float64}
                @test inputset(s, t) isa Polyhedra.SimplePolyhedron{Float64}
            end
        end
    end
    @testset "Cruise Control" begin
        include("../examples/cruise_control.jl")
        for sym in (false, true)
            s = cruise_control_example(7, 1, sym=sym)
            @test nstates(s) == 7
            @test transitiontype(s) == LightGraphs.SimpleGraphs.SimpleEdge{Int}
            t = first(transitions(s))
            @test target(s, t) == 1
            @test source(s, t) == 1
            #@test sprint(show, s) == "Hybrid System with automaton HybridSystems.LightAutomaton{LightGraphs.SimpleGraphs.SimpleDiGraph{Int64},LightGraphs.SimpleGraphs.SimpleEdge{Int64}}({7, 21} directed simple Int64 graph, Dict(Edge 2 => 3=>2,Edge 6 => 5=>1,Edge 2 => 1=>1,Edge 4 => 4=>1,Edge 4 => 3=>2,Edge 3 => 6=>2,Edge 6 => 3=>2,Edge 4 => 6=>2,Edge 7 => 7=>1,Edge 6 => 6=>2,Edge 3 => 2=>1,Edge 5 => 4=>1,Edge 5 => 6=>2,Edge 7 => 6=>2,Edge 1 => 3=>2,Edge 5 => 3=>2,Edge 2 => 6=>2,Edge 1 => 1=>1,Edge 1 => 6=>2,Edge 3 => 3=>2,Edge 7 => 3=>2))"
            @test iszero(inputdim(s, 1))
            @test iszero(inputdim(s, 2))
        end
    end
end
