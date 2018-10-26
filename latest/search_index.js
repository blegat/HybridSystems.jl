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
    "category": "type",
    "text": "AbstractHybridSystem\n\nAbstract supertype for a hybrid system.\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.HybridSystem",
    "page": "Types",
    "title": "HybridSystems.HybridSystem",
    "category": "type",
    "text": "HybridSystem{A, S, R, W} <: AbstractHybridSystem\n\nA hybrid system modelled as a hybrid automaton. The automaton automaton of type A models the different discrete states and the allowed transitions with corresponding labels. The mode dynamic and domain are stored in a continuous dynamical system of type S in the vector modes. They are indexed by the discrete states of the automaton. The reset maps and guards are given as discrete dynamical system or discrete map of type R in the vector resetmaps. They are indexed by the labels of the corresponding transition. The switching of type W is given in the switchings vector, indexed by the label of the transition. Additional data can be stored in the ext field.\n\nFields\n\nautomaton  – hybrid automaton of type A.\nmodes      – vector of modes of type S indexed by the discrete states,                 both the domain and the dynamic are stored in this field.                 See stateset to access the domain.\nresetmaps  – vector of reset maps of type R indexed by the label of the                 transition, the guard is stored as constraint of the map in                 this field. See stateset to access the guard.\nswitchings – vector of switchings of type W indexed by the label of the                 transition, see AbstractSwitching.\next        – dictionary that can be used by extensions.\n\nExamples\n\nSee the Thermostat example.\n\n\n\n\n\n"
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
    "category": "type",
    "text": "AbstractAutomaton\n\nAbstract type for a hybrid automaton.\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.OneStateAutomaton",
    "page": "Types",
    "title": "HybridSystems.OneStateAutomaton",
    "category": "type",
    "text": "OneStateAutomaton\n\nAutomaton with one state and the nt events 1, ..., nt.\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.OneStateTransition",
    "page": "Types",
    "title": "HybridSystems.OneStateTransition",
    "category": "type",
    "text": "OneStateTransition\n\nTransition of OneStateAutomaton with label σ.\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.LightAutomaton",
    "page": "Types",
    "title": "HybridSystems.LightAutomaton",
    "category": "type",
    "text": "LightAutomaton{GT, ET} <: AbstractAutomaton\n\nA hybrid automaton that uses the LightGraphs backend. See the constructor LightAutomaton(::Int).\n\nFields\n\nG – graph of type GT whose vertices determine the states\nΣ – dictionary mapping the edges to their labels\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.LightAutomaton-Tuple{Int64}",
    "page": "Types",
    "title": "HybridSystems.LightAutomaton",
    "category": "method",
    "text": "LightAutomaton(n::Int)\n\nCreates a LightAutomaton with n states 1, 2, ..., n. The automaton is initialized without any transitions, use add_transition! to add transitions.\n\nExamples\n\nTo create an automaton with 2 nodes 1, 2, self-loops of labels 1, a transition from 1 to 2 with label 2 and transition from 2 to 1 with label 3, do the following:\n\njulia> a = LightAutomaton(2);\n\njulia> add_transition!(a, 1, 1, 1) # Add a self-loop of label 1 for state 1\nEdge 1 => 1\n\njulia> add_transition!(a, 2, 2, 1) # Add a self-loop of label 1 for state 2\nEdge 2 => 2\n\njulia> add_transition!(a, 1, 2, 2) # Add a transition from state 1 to state 2 with label 2\nEdge 1 => 2\n\njulia> add_transition!(a, 2, 1, 3) # Add a transition from state 2 to state 1 with label 3\nEdge 2 => 1\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#Automata-1",
    "page": "Types",
    "title": "Automata",
    "category": "section",
    "text": "AbstractAutomaton\nOneStateAutomaton\nOneStateTransition\nLightAutomaton\nLightAutomaton(::Int)"
},

{
    "location": "lib/types.html#HybridSystems.AbstractSwitching",
    "page": "Types",
    "title": "HybridSystems.AbstractSwitching",
    "category": "type",
    "text": "AbstractSwitching\n\nNature of the switching, e.g. AutonomousSwitching or ControlledSwitching, see Section 1.1.3 of [1]\n\n[1] Liberzon, D. Switching in systems and control. Springer Science & Business Media, 2012\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.AutonomousSwitching",
    "page": "Types",
    "title": "HybridSystems.AutonomousSwitching",
    "category": "type",
    "text": "AutonomousSwitching <: AbstractSwitching\n\nControlled switching, the switching signal is autonomous.\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#HybridSystems.ControlledSwitching",
    "page": "Types",
    "title": "HybridSystems.ControlledSwitching",
    "category": "type",
    "text": "ControlledSwitching <: AbstractSwitching\n\nControlled switching, the switching signal is controlled.\n\n\n\n\n\n"
},

{
    "location": "lib/types.html#Switchings-1",
    "page": "Types",
    "title": "Switchings",
    "category": "section",
    "text": "AbstractSwitching\nAutonomousSwitching\nControlledSwitching"
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
    "location": "lib/methods.html#HybridSystems.discreteswitchedsystem",
    "page": "Methods",
    "title": "HybridSystems.discreteswitchedsystem",
    "category": "function",
    "text": "discreteswitchedsystem(A::AbstractVector{<:AbstractMatrix})\n\nCreates the discrete switched linear system defined by\n\nx_k+1 = A_sigma_k x_k sigma_k = 1 ldots m\n\nwhere m is the length of A.\n\ndiscreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, S::AbstractVector)\n\nCreates the state dependent discrete switched linear system defined by\n\nx_k+1 = A_sigma_k x_k sigma_k = 1 ldots m x_k in Ssigma_k\n\nwhere m is the length of A and S.\n\ndiscreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, G::AbstractAutomaton)\n\nCreates the constrained discrete switched linear system defined by\n\nx_k+1 = A_sigma_k x_k\n\nwhere sigma_1 ldots sigma_k is a valid sequence of events of the automaton G.\n\ndiscreteswitchedsystem(A::AbstractVector{<:AbstractMatrix}, G::AbstractAutomaton, S::AbstractVector)\n\nCreates the state-dependent constrained discrete switched linear system defined by\n\nx_k+1 = A_sigma_k x_k x_k in Sq_k\n\nwhere q_0 sigma_1 q_1 ldots q_k-1 sigma_k q_k is a valid sequence of events of the automaton G with intermediate states q_0 ldots q_k.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#Switched-Systems-1",
    "page": "Methods",
    "title": "Switched Systems",
    "category": "section",
    "text": "The following method makes it easy to create specific kind of hybrid systems called switched systemsdiscreteswitchedsystem"
},

{
    "location": "lib/methods.html#MathematicalSystems.statedim",
    "page": "Methods",
    "title": "MathematicalSystems.statedim",
    "category": "function",
    "text": "statedim(hs::HybridSystem, u::Int)\n\nReturns the dimension of the state space of the system at mode u.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#MathematicalSystems.stateset",
    "page": "Methods",
    "title": "MathematicalSystems.stateset",
    "category": "function",
    "text": "stateset(s::AbstractSystem, u::Int)\n\nReturns the set of allowed states of the system at mode u.\n\n\n\n\n\nstateset(s::AbstractSystem, t)\n\nReturns the guard for the transition t.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#MathematicalSystems.inputdim",
    "page": "Methods",
    "title": "MathematicalSystems.inputdim",
    "category": "function",
    "text": "inputdim(s::AbstractSystem, u::Int)\n\nReturns the dimension of the input space of the system at mode u.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#MathematicalSystems.inputset",
    "page": "Methods",
    "title": "MathematicalSystems.inputset",
    "category": "function",
    "text": "inputset(s::AbstractSystem, u::Int)\n\nReturns the set of allowed inputs of the system at mode u.\n\n\n\n\n\ninputset(s::AbstractSystem, t)\n\nReturns the st of allowed inputs for the transition t.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#Continuous-sub-systems-1",
    "page": "Methods",
    "title": "Continuous sub-systems",
    "category": "section",
    "text": "statedim\nstateset\ninputdim\ninputset"
},

{
    "location": "lib/methods.html#Hybrid-automata-1",
    "page": "Methods",
    "title": "Hybrid automata",
    "category": "section",
    "text": ""
},

{
    "location": "lib/methods.html#HybridSystems.states",
    "page": "Methods",
    "title": "HybridSystems.states",
    "category": "function",
    "text": "states(A::AbstractAutomaton)\n\nReturns an iterator over the states of the automaton A. It has the alias modes.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.nstates",
    "page": "Methods",
    "title": "HybridSystems.nstates",
    "category": "function",
    "text": "nstates(A::AbstractAutomaton)\n\nReturns the number of states of the automaton A. It has the alias nmodes.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.rem_state!",
    "page": "Methods",
    "title": "HybridSystems.rem_state!",
    "category": "function",
    "text": "rem_state!(A::AbstractAutomaton, q)\n\nRemove the state q to the automaton A.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#Modes-1",
    "page": "Methods",
    "title": "Modes",
    "category": "section",
    "text": "states\nnstates\nrem_state!"
},

{
    "location": "lib/methods.html#HybridSystems.transitiontype",
    "page": "Methods",
    "title": "HybridSystems.transitiontype",
    "category": "function",
    "text": "transitiontype(A::AbstractAutomaton)\n\nReturns type of the transitions of the automaton A.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.transitions",
    "page": "Methods",
    "title": "HybridSystems.transitions",
    "category": "function",
    "text": "transitions(A::AbstractAutomaton)\n\nReturns an iterator over the transitions of the automaton A.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.ntransitions",
    "page": "Methods",
    "title": "HybridSystems.ntransitions",
    "category": "function",
    "text": "ntransitions(A::AbstractAutomaton)\n\nReturns the number of transitions of the automaton A.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.add_transition!",
    "page": "Methods",
    "title": "HybridSystems.add_transition!",
    "category": "function",
    "text": "add_transition!(A::AbstractAutomaton, q, r, σ)\n\nAdds a transition between states q and r with symbol σ to the automaton A.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.has_transition",
    "page": "Methods",
    "title": "HybridSystems.has_transition",
    "category": "function",
    "text": "has_transition(A::AbstractAutomaton, t)\n\nReturns true if the automaton A has the transition t.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.rem_transition!",
    "page": "Methods",
    "title": "HybridSystems.rem_transition!",
    "category": "function",
    "text": "rem_transition!(A::AbstractAutomaton, q, r, σ)\n\nRemove the transition between states q and r with symbol σ to the automaton A.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.source",
    "page": "Methods",
    "title": "HybridSystems.source",
    "category": "function",
    "text": "source(A::AbstractAutomaton, t)\n\nReturns the source of the transition t.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.event",
    "page": "Methods",
    "title": "HybridSystems.event",
    "category": "function",
    "text": "event(A::AbstractAutomaton, t)\n\nReturns the event/symbol of the transition t in the automaton A. It has the alias symbol.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.target",
    "page": "Methods",
    "title": "HybridSystems.target",
    "category": "function",
    "text": "target(A::AbstractAutomaton, t)\n\nReturns the target of the transition t.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.in_transitions",
    "page": "Methods",
    "title": "HybridSystems.in_transitions",
    "category": "function",
    "text": "in_transitions(A::AbstractAutomaton, s)\n\nReturns an iterator over the transitions with target s.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#HybridSystems.out_transitions",
    "page": "Methods",
    "title": "HybridSystems.out_transitions",
    "category": "function",
    "text": "out_transitions(A::AbstractAutomaton, s)\n\nReturns an iterator over the transitions with source s.\n\n\n\n\n\n"
},

{
    "location": "lib/methods.html#Transitions-1",
    "page": "Methods",
    "title": "Transitions",
    "category": "section",
    "text": "transitiontype\ntransitions\nntransitions\nadd_transition!\nhas_transition\nrem_transition!\nsource\nevent\ntarget\nin_transitions\nout_transitions"
},

]}
