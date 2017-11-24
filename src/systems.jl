export AbstractSystem, AbstractDiscreteSystem, AbstractContinuousSystem
export DiscreteIdentitySystem, DiscreteLinearSystem, DiscreteLinearControlSystem, DiscreteLinearAlgebraicSystem

export statedim, inputdim
abstract type AbstractSystem end
"""
    statedim(s::AbstractSystem)

Returns the dimension of the state space of system `s`.
"""
function statedim end
"""
    inputdim(s::AbstractSystem)

Returns the dimension of the input space of system `s`.
"""
function inputdim end

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
    DiscreteLinearSystem

Discrete-time linear system of the form
```math
x_{k+1} = A x_k.
```
"""
struct DiscreteLinearSystem{T, MT<: AbstractMatrix{T}} <: AbstractDiscreteSystem
    A::MT
end
DiscreteLinearSystem{T, MT<: AbstractMatrix{T}}(A::MT) = DiscreteLinearSystem{T, MT}(A)
statedim(s::DiscreteLinearSystem) = Base.LinAlg.checksquare(s.A)
inputdim(s::DiscreteLinearSystem) = 0

"""
    DiscreteLinearControlSystem

Discrete-time linear control system of the form
```math
x_{k+1} = A x_k + B u_k
```
where ``u_k \\in U``.
"""
struct DiscreteLinearControlSystem{T, MT<: AbstractMatrix{T}, UT} <: AbstractDiscreteSystem
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
