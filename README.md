# HybridSystems

This packages defines an interface for defining and working with [Hybrid Systems](https://en.wikipedia.org/wiki/Hybrid_system).
It also includes an implementation of this interface.

The goal of this package is twofold

* help making algorithms on Hybrid Systems independent of the particular data structure used to represent them.
* help users to try many different tools for Hybrid Systems without needed to deal with different interfaces.

The following package implements algorithms using this interface:

* [SwitchOnSafety](https://github.com/blegat/SwitchOnSafety.jl) : Computing invariant sets of hybrid systems.
