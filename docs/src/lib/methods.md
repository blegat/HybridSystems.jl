# Methods

This section describes systems methods implemented in `HybridSystems.jl`.

```@contents
Pages = ["methods.md"]
Depth = 3
```

```@meta
CurrentModule = HybridSystems
DocTestSetup = quote
    using HybridSystems
end
```

## Hybrid automata

```@docs
states
nstates
transitiontype
transitions
ntransitions
add_transition!
has_transition
rem_transition!
rem_state!
source
event
target
in_transitions
out_transitions
```
