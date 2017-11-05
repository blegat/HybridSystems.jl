export discreteswitchedsystem, DiscreteSwitchedLinearSystem, StateDepDiscreteSwitchedLinearSystem, ConstrainedDiscreteSwitchedLinearSystem

const DiscreteSwitchedLinearSystem = HybridSystem{OneStateAutomaton, <:DiscreteIdentitySystem, FullSpace, FullSpace, <:DiscreteLinearSystem, AutonomousSwitching}
const StateDepDiscreteSwitchedLinearSystem = HybridSystem{<:AbstractAutomaton, <:DiscreteIdentitySystem, <:Any, <:Any, <:DiscreteLinearSystem, AutonomousSwitching}
const ConstrainedDiscreteSwitchedLinearSystem = HybridSystem{<:AbstractAutomaton, <:DiscreteIdentitySystem, FullSpace, FullSpace, <:DiscreteLinearSystem, AutonomousSwitching}

"""
    discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix})

Creates the discrete switched linear system defined by
```math
x_{k+1} = A_{\\sigma_k} x_k, \\sigma_k = 1, \\ldots, m.
```
where `m` is the length of `A`.

    discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, S::AbstractVector)

Creates the state dependent discrete switched linear system defined by
```math
x_{k+1} = A_{\\sigma_k} x_k, \\sigma_k = 1, \\ldots, m, x_k \\in S[\\sigma_k].
```
where `m` is the length of `A` and `S`.

    discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, G::AbstractAutomaton)

Creates the constrained discrete switched linear system defined by
```math
x_{k+1} = A_{\\sigma_k} x_k,
```
where ``\\sigma_1, \\ldots, \\sigma_k`` is a valid sequence of events of the automaton `G`.

    discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, G::AbstractAutomaton, S::AbstractVector)

Creates the state-dependent constrained discrete switched linear system defined by
```math
x_{k+1} = A_{\\sigma_k} x_k, x_k \\in S[q_k]
```
where ``q_0, \\sigma_1, q_1, \\ldots, q_{k-1}, \\sigma_k, q_k`` is a valid sequence of events of the automaton `G` with intermediate states ``q_0, \\ldots, q_k``.
"""
function discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, G::AbstractAutomaton=OneStateAutomaton(length(A)), S=ConstantVector(FullSpace(), nstates(G)); kws...)
    n = nstates(G)
    modes = DiscreteIdentitySystem.(map(s -> _getstatedim(A, G, s), states(G)))
    rm = DiscreteLinearSystem.(A)
    guards = _guards(A, G, S)
    sw = ConstantVector(AutonomousSwitching(), n)
    HybridSystem(G, modes, S, guards, rm, sw, Dict{Symbol, Any}(kws))
end
function discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, S::AbstractVector; kws...)
    @assert length(A) == length(S)
    G = LightAutomaton(length(A))
    for σ in 1:length(A)
        for σnext in 1:length(A)
            add_transition!(G, σ, σnext, σ)
        end
    end
    discreteswitchedsystem(A, G, S; kws...)
end

_guards(A, G, S::ConstantVector) = ConstantVector(S[1], length(A))
function _guard(G::AbstractAutomaton, S::AbstractVector, σ)
    s = Nullable{eltype(S)}()
    for t in transitions(G)
        if symbol(G, t) == σ
            st = S[source(G, t)]
            if isnull(s)
                s = Nullable{eltype(S)}(st)
            else
                @assert get(s) === st
            end
        end
    end
    @assert !isnull(s)
    get(s)
end
_guards(A, G, S::AbstractVector) = map(σ -> _guard(G, S, σ), 1:length(A))
function _getstatedim(A, G, s)
    d = -1
    function _setcheck(T, i)
        for t in T
            n = size(A[symbol(G, t)], i)
            if d == -1
                d = n
            else
                @assert d == n
            end
        end
    end
    _setcheck(out_transitions(G, s), 2)
    _setcheck(in_transitions(G, s), 1)
    # If d == -1, that means there is no ingoing nor outgoing transition.
    # In that case, using a zero dimension won't hurt.
    d == -1 ? 0 : d
end
