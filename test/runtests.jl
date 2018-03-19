using HybridSystems
using Base.Test
using Polyhedra

@testset "Horizontal jump" begin
    include("../examples/horizontal_jump.jl")
    for shift in (false, true)
        s = horizontal_jump_example(SimplePolyhedraLibrary{Float64}(), shift)
        @test nstates(s) == 2
        @test states(s) == 1:2
        for u in states(s)
            @test statedim(s, u) == 2
            @test stateset(s, u) isa Polyhedra.SimplePolyhedron{2,Float64}
        end
        @test length(transitions(s)) == 2
        @test ntransitions(s) == 2
        for t in transitions(s)
            @test stateset(s, t) isa Polyhedra.SimplePolyhedron{2,Float64}
            @test inputset(s, t) isa Polyhedra.SimplePolyhedron{1,Float64}
        end
    end
end

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
    s = discreteswitchedsystem([ones(2, 2), zeros(2, 2)], ConstantVector(square, 2))
    @test nstates(s) == 2
    @test states(s) == 1:2
    @test all(statedim.(s, states(s)) .== 2)
    @test stateset(s, 1) === square
    @test stateset(s, 2) === square
    @test length(transitions(s)) == 4
    @test ntransitions(s) == 4
end
