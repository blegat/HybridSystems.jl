export discreteswitchedsystem, DiscreteSwitchedLinearSystem, ConstrainedDiscreteSwitchedLinearSystem

const DiscreteSwitchedLinearSystem = HybridSystem{OneStateAutomaton, <:DiscreteIdentitySystem, FullSpace, FullSpace, <:DiscreteLinearSystem, AutonomousSwitching}
const ConstrainedDiscreteSwitchedLinearSystem = HybridSystem{<:AbstractAutomaton, <:DiscreteIdentitySystem, FullSpace, FullSpace, <:DiscreteLinearSystem, AutonomousSwitching}

"""
    discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix})

Creates the switched system defined by
```math
x_{k+1} = A_{\\sigma_k} x_k, \\sigma_k = 1, \\ldots, m.
```
where `m` is the length of `A`.

    discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, G::AbstractAutomaton)

Creates the constrainted switched system defined by
```math
x_{k+1} = A_{\\sigma_k} x_k,
```
where ``\\sigma_1, \\ldots, \\sigma_k`` is a valid sequence of events of the automaton `G`.
"""
function discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, G=OneStateAutomaton(length(A)))
    n = nstates(G)
    modes = DiscreteIdentitySystem.(map(s -> _getstatedim(A, G, s), states(G)))
    rm = DiscreteLinearSystem.(A)
    ig = ConstantVector(FullSpace(), n)
    sw = ConstantVector(AutonomousSwitching(), n)
    HybridSystem(G, modes, ig, ig, rm, sw, Dict{Symbol, Any}())
end
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
