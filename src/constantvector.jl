export ConstantVector

"""
    ConstantVector{T}

Constant vector with the same element of type `T` at each entry.
"""
struct ConstantVector{T} <: AbstractVector{T}
    el::T
    length::Int
end

Base.size(x::ConstantVector) = (x.length,)
Base.getindex(x::ConstantVector, i::Integer) = x.el
Base.getindex(x::ConstantVector, I::AbstractVector) = ConstantVector(x.el, length(I))
function Base.show(io::IO, x::ConstantVector)
    print(io, summary(x))
    print(io, " with element ")
    print(io, x.el)
end
Base.show(io::IO, ::MIME"text/plain", x::ConstantVector) = show(io, x)
