# HybridSystems

| **Documentation** | **Build Status** | **References to cite** |
|:-----------------:|:----------------:|:----------------------:|
| [![][docs-stable-img]][docs-stable-url] | [![Build Status][build-img]][build-url]       | [![DOI][zenodo-img]][zenodo-url] |
| [![][docs-latest-img]][docs-latest-url] | [![Codecov branch][codecov-img]][codecov-url] |                                  |

This packages defines an interface for defining and working with [Hybrid Systems](https://en.wikipedia.org/wiki/Hybrid_system).
It also includes an implementation of this interface.

The goal of this package is twofold

* help making algorithms on Hybrid Systems independent of the particular data structure used to represent them.
* help users to try many different tools for Hybrid Systems without needed to deal with different interfaces.

The following package implements hybrid systems representations using this interface:

* [SpaceExParser](https://github.com/JuliaReach/SpaceExParser.jl) : [SpaceEx](http://spaceex.imag.fr/) modeling language parser

The following package implements algorithms using this interface:

* [SwitchOnSafety](https://github.com/blegat/SwitchOnSafety.jl) : Computing invariant sets of hybrid systems.
* [ReachabilityAnalysis](https://github.com/JuliaReach/ReachabilityAnalysis.jl) : Computing reachable states of hybrid dynamical systems.
* [Dionysos](https://github.com/dionysos-dev/Dionysos.jl) : Solve optimal control problems on hybrid systems.

## Documentation

- [**STABLE**][docs-stable-url] &mdash; **most recently tagged version of the documentation.**
- [**LATEST**][docs-latest-url] &mdash; *in-development version of the documentation.*

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-stable-url]: https://blegat.github.io/HybridSystems.jl/stable/index.html
[docs-latest-url]: https://blegat.github.io/HybridSystems.jl/latest/index.html

[build-img]: https://github.com/blegat/HybridSystems.jl/workflows/CI/badge.svg?branch=master
[build-url]: https://github.com/blegat/HybridSystems.jl/actions?query=workflow%3ACI
[codecov-img]: http://codecov.io/github/blegat/HybridSystems.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/blegat/HybridSystems.jl?branch=master

[zenodo-url]: https://doi.org/10.5281/zenodo.1246104
[zenodo-img]: https://zenodo.org/badge/DOI/10.5281/zenodo.1246104.svg
