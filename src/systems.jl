export AbstractSystem, AbstractDiscreteSystem, AbstractContinuousSystem
export DiscreteIdentitySystem, DiscreteLinearControlSystem, DiscreteLinearAlgebraicSystem
export statedim, inputdim
abstract type AbstractSystem end

abstract type AbstractDiscreteSystem end
abstract type AbstractContinuousSystem end

"""
    DiscreteIdentitySystem <: AbstractDiscreteSystem

Trivial identity discrete-time system of the form
```math
x_{k+1} = x_k.
```
"""
struct DiscreteIdentitySystem <: AbstractDiscreteSystem
    statedim
end
statedim(s::DiscreteIdentitySystem) = s.statedim

"""
    DiscreteLinearControlSystem

Discrete-time linear control system of the form
```math
x_{k+1} = A x_k + B u_k
```
where ``u_k \\in U``.
"""
struct DiscreteLinearControlSystem{T, MT<: AbstractMatrix{T}, UT} <: AbstractSystem
    A::MT
    B::MT
    U::UT
end
DiscreteLinearControlSystem{T, MT<: AbstractMatrix{T}, UT}(A::MT, B::MT, U::UT) = DiscreteLinearControlSystem{T, MT, UT}(A, B, U)
using SemialgebraicSets
DiscreteLinearControlSystem(A, B) = DiscreteLinearControlSystem(A, B, FullSpace())
statedim(s::DiscreteLinearControlSystem) = Base.LinAlg.checksquare(s.A)
inputdim(s::DiscreteLinearControlSystem) = size(s.B, 2)

"""
    DiscreteLinearAlgebraicSystem

Discrete-time linear algebraic system of the form
```math
E x_{k+1} = A x_k.
```
"""
struct DiscreteLinearAlgebraicSystem{T, MT<: AbstractMatrix{T}} <: AbstractSystem
    A::MT
    E::MT
end
DiscreteLinearAlgebraicSystem{T, MT<: AbstractMatrix{T}}(A::MT, E::MT) = DiscreteLinearAlgebraicSystem{T, MT}(A, E)
statedim(s::DiscreteLinearAlgebraicSystem) = size(s.A, 2)
