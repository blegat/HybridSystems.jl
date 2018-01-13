var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#HybridSystems.jl-1",
    "page": "Home",
    "title": "HybridSystems.jl",
    "category": "section",
    "text": "DocTestFilters = [r\"[0-9\\.]+ seconds \\(.*\\)\"]Hybrid Systems definitions in Julia."
},

{
    "location": "index.html#Library-Outline-1",
    "page": "Home",
    "title": "Library Outline",
    "category": "section",
    "text": "Pages = [\n    \"lib/types.md\",\n    \"lib/methods.md\"\n]\nDepth = 2"
},

{
    "location": "lib/types.html#",
    "page": "Types",
    "title": "Types",
    "category": "page",
    "text": ""
},

{
    "location": "lib/types.html#Types-1",
    "page": "Types",
    "title": "Types",
    "category": "section",
    "text": "This section describes types implemented in HybridSystems.jl.Pages = [\"types.md\"]\nDepth = 3CurrentModule = HybridSystems\nDocTestSetup = quote\n    using HybridSystems\nend"
},

{
    "location": "lib/types.html#HybridSystems.AbstractHybridSystem",
    "page": "Types",
    "title": "HybridSystems.AbstractHybridSystem",
    "category": "Type",
    "text": "AbstractHybridSystem\n\nAbstract supertype for a hybrid system.\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.HybridSystem",
    "page": "Types",
    "title": "HybridSystems.HybridSystem",
    "category": "Type",
    "text": "HybridSystem{A, S, I, G, R, W} <: AbstractHybridSystem\n\nA hybrid system modelled as a hybrid automaton.\n\nFields\n\nautomaton  – hybrid automaton\nmodes      – vector of modes\nresetmaps  – vector of reset maps\nswitchings – vector of switchings\next        – dictionary that can be used by extensions\n\n\n\n"
},

{
    "location": "lib/types.html#Hybrid-systems-1",
    "page": "Types",
    "title": "Hybrid systems",
    "category": "section",
    "text": "AbstractHybridSystem\nHybridSystem"
},

{
    "location": "lib/types.html#HybridSystems.AbstractAutomaton",
    "page": "Types",
    "title": "HybridSystems.AbstractAutomaton",
    "category": "Type",
    "text": "AbstractAutomaton\n\nAbstract type for a hybrid automaton.\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.OneStateAutomaton",
    "page": "Types",
    "title": "HybridSystems.OneStateAutomaton",
    "category": "Type",
    "text": "OneStateAutomaton\n\nAutomaton with one state and the nt events 1, ..., nt.\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.LightAutomaton",
    "page": "Types",
    "title": "HybridSystems.LightAutomaton",
    "category": "Type",
    "text": "LightAutomaton{GT, ET} <: AbstractAutomaton\n\nA hybrid automaton that uses the LightGraphs backend.\n\nFields\n\nG – graph whose vertices determine the states\nΣ – dictionary that defines the state transition graph\n\n\n\n"
},

{
    "location": "lib/types.html#Hybrid-automata-1",
    "page": "Types",
    "title": "Hybrid automata",
    "category": "section",
    "text": "AbstractAutomaton\nOneStateAutomaton\nLightAutomaton"
},

{
    "location": "lib/types.html#HybridSystems.ConstantVector",
    "page": "Types",
    "title": "HybridSystems.ConstantVector",
    "category": "Type",
    "text": "ConstantVector{T}\n\nConstant vector with the same element of type T at each entry.\n\n\n\n"
},

{
    "location": "lib/types.html#Constant-vector-1",
    "page": "Types",
    "title": "Constant vector",
    "category": "section",
    "text": "ConstantVector"
},

{
    "location": "lib/methods.html#",
    "page": "Methods",
    "title": "Methods",
    "category": "page",
    "text": ""
},

{
    "location": "lib/methods.html#Methods-1",
    "page": "Methods",
    "title": "Methods",
    "category": "section",
    "text": "This section describes systems methods implemented in HybridSystems.jl.Pages = [\"methods.md\"]\nDepth = 3CurrentModule = HybridSystems\nDocTestSetup = quote\n    using HybridSystems\nend"
},

{
    "location": "lib/methods.html#HybridSystems.states",
    "page": "Methods",
    "title": "HybridSystems.states",
    "category": "Function",
    "text": "states(A::AbstractAutomaton)\n\nReturns an iterator over the states of the automaton A. It has the alias modes.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.nstates",
    "page": "Methods",
    "title": "HybridSystems.nstates",
    "category": "Function",
    "text": "nstates(A::AbstractAutomaton)\n\nReturns the number of states of the automaton A. It has the alias nmodes.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.transitiontype",
    "page": "Methods",
    "title": "HybridSystems.transitiontype",
    "category": "Function",
    "text": "transitiontype(A::AbstractAutomaton)\n\nReturns type of the transitions of the automaton A.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.transitions",
    "page": "Methods",
    "title": "HybridSystems.transitions",
    "category": "Function",
    "text": "transitions(A::AbstractAutomaton)\n\nReturns an iterator over the transitions of the automaton A.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.ntransitions",
    "page": "Methods",
    "title": "HybridSystems.ntransitions",
    "category": "Function",
    "text": "ntransitions(A::AbstractAutomaton)\n\nReturns the number of transitions of the automaton A.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.add_transition!",
    "page": "Methods",
    "title": "HybridSystems.add_transition!",
    "category": "Function",
    "text": "add_transition!(A::AbstractAutomaton, q, r, σ)\n\nAdds a transition between states q and r with symbol σ to the automaton A.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.has_transition",
    "page": "Methods",
    "title": "HybridSystems.has_transition",
    "category": "Function",
    "text": "has_transition(A::AbstractAutomaton, t)\n\nReturns true if the automaton A has the transition t.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.rem_transition!",
    "page": "Methods",
    "title": "HybridSystems.rem_transition!",
    "category": "Function",
    "text": "rem_transition!(A::AbstractAutomaton, q, r, σ)\n\nRemove the transition between states q and r with symbol σ to the automaton A.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.rem_state!",
    "page": "Methods",
    "title": "HybridSystems.rem_state!",
    "category": "Function",
    "text": "rem_state!(A::AbstractAutomaton, q)\n\nRemove the state q to the automaton A.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.source",
    "page": "Methods",
    "title": "HybridSystems.source",
    "category": "Function",
    "text": "source(A::AbstractAutomaton, t)\n\nReturns the source of the transition t.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.event",
    "page": "Methods",
    "title": "HybridSystems.event",
    "category": "Function",
    "text": "event(A::AbstractAutomaton, t)\n\nReturns the event/symbol of the transition t in the automaton A. It has the alias symbol.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.target",
    "page": "Methods",
    "title": "HybridSystems.target",
    "category": "Function",
    "text": "target(A::AbstractAutomaton, t)\n\nReturns the target of the transition t.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.in_transitions",
    "page": "Methods",
    "title": "HybridSystems.in_transitions",
    "category": "Function",
    "text": "in_transitions(A::AbstractAutomaton, s)\n\nReturns an iterator over the transitions with target s.\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.out_transitions",
    "page": "Methods",
    "title": "HybridSystems.out_transitions",
    "category": "Function",
    "text": "out_transitions(A::AbstractAutomaton, s)\n\nReturns an iterator over the transitions with source s.\n\n\n\n"
},

{
    "location": "lib/methods.html#Hybrid-automata-1",
    "page": "Methods",
    "title": "Hybrid automata",
    "category": "section",
    "text": "states\nnstates\ntransitiontype\ntransitions\nntransitions\nadd_transition!\nhas_transition\nrem_transition!\nrem_state!\nsource\nevent\ntarget\nin_transitions\nout_transitions"
},

]}
