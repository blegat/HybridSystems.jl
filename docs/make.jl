using Documenter, HybridSystems

makedocs(
    doctest = true,
    modules = [HybridSystems],
    format = :html,
    sitename = "HybridSystems.jl",
    pages = [
        "Home" => "index.md",
        "Library" => Any[
        "Types" => "lib/types.md",
        "Methods" => "lib/methods.md"]
    ]
)

deploydocs(
    repo = "github.com/blegat/HybridSystems.jl.git",
    target = "build",
    osname = "linux",
    julia  = "1.0",
    deps = nothing,
    make = nothing
)
