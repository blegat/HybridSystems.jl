using Plots

function plotinvariants(H::HybridSystem, args...; kws...)
    plot(first(H.invariants), args...; kws...)
    for inv in Iterators.drop(H.invariants, 1)
        plot!(inv, args...; kws...)
    end
end
function plotinvariants!(H::HybridSystem, args...; kws...)
    for inv in H.invariants
        plot!(inv, args...; kws...)
    end
end
