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

## Automata

```@docs
AbstractAutomaton
HybridSystems.AbstractTransition
OneStateAutomaton
OneStateTransition
GraphAutomaton
GraphAutomaton(::Int)
HybridSystems.GraphTransitionIterator
```

## Switchings

```@docs
AbstractSwitching
AutonomousSwitching
ControlledSwitching
```
