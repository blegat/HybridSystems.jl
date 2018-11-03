using Documenter, HybridSystems

makedocs(
    strict = true,
    # See https://github.com/JuliaDocs/Documenter.jl/issues/868
    html_prettyurls = get(ENV, "CI", nothing) == "true",
    modules = [HybridSystems],
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
)
