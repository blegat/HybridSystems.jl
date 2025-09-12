using Documenter, HybridSystems

DocMeta.setdocmeta!(HybridSystems, :DocTestSetup, :(using HybridSystems); recursive=true)

makedocs(
    sitename = "HybridSystems.jl",
    modules = [HybridSystems],
    format=Documenter.HTML(; prettyurls=get(ENV, "CI", nothing) == "true"),
    pages = [
        "Home" => "index.md",
        "Library" => Any[
        "Types" => "lib/types.md",
        "Methods" => "lib/methods.md"]
    ]
)

deploydocs(
    repo = "github.com/blegat/HybridSystems.jl.git",
    push_preview = true
)
