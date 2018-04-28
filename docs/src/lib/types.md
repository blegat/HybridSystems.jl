# Types

This section describes types implemented in `HybridSystems.jl`.

```@contents
Pages = ["types.md"]
Depth = 3
```

```@meta
CurrentModule = HybridSystems
DocTestSetup = quote
    using HybridSystems
end
```

## Hybrid systems

```@docs
AbstractHybridSystem
HybridSystem
```

## Hybrid automata

```@docs
AbstractAutomaton
OneStateAutomaton
OneStateTransition
LightAutomaton
```

## Switchings

```@docs
AbstractSwitching
AutonomousSwitching
ControlledSwitching
```
