export AbstractSwitching, ControlledSwitching, AutonomousSwitching

abstract type AbstractSwitching end

struct ControlledSwitching <: AbstractSwitching end
struct AutonomousSwitching <: AbstractSwitching end
