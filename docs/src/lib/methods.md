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

## Switched Systems

The following method makes it easy to create specific kind of hybrid systems called switched systems
```@docs
discreteswitchedsystem
```

## Continuous sub-systems

```@docs
statedim
stateset
inputdim
inputset
```

## Hybrid automata

### Modes

```@docs
states
nstates
rem_state!
mode
target_mode
```

### Transitions

```@docs
transitiontype
transitions
ntransitions
add_transition!
has_transition
rem_transition!
source
event
target
in_transitions
out_transitions
```

### Guards and Assignments

```@docs
resetmap
guard
assignment
```

### Utilities

```@docs
switchings
```
