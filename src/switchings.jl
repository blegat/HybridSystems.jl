export AbstractSwitching, ControlledSwitching, AutonomousSwitching

"""
    AbstractSwitching

Nature of the switching, e.g. [`AutonomousSwitching`](@ref) or [`ControlledSwitching`](@ref), see Section 1.1.3 of [1]

[1] Liberzon, D.
*Switching in systems and control*.
Springer Science & Business Media, 2012
"""
abstract type AbstractSwitching end

"""
    AutonomousSwitching <: AbstractSwitching

Controlled switching, the switching signal is autonomous.
"""

struct AutonomousSwitching <: AbstractSwitching end

"""
    ControlledSwitching <: AbstractSwitching

Controlled switching, the switching signal is controlled.
"""
struct ControlledSwitching <: AbstractSwitching end
