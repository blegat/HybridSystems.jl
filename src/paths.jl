export switchings

mutable struct DiscreteSwitchingSequence{S <: HybridSystem, MT <: AbstractMatrix, TT}
    s::S
    A::MT
    seq::Vector{TT}
    len::Int
end

function Base.show(io::IO, s::DiscreteSwitchingSequence)
    println(io, "Discrete switching sequence of length $(s.len):")
    println(io, s.seq)
end

HybridSystems.source(s::HybridSystem, seq::DiscreteSwitchingSequence) = source(s, seq.seq[1])
HybridSystems.target(s::HybridSystem, seq::DiscreteSwitchingSequence) = target(s, seq.seq[end])
# Short circuit for unconstrained system
HybridSystems.source(::HybridSystem{OneStateAutomaton}, ::DiscreteSwitchingSequence) = 1
HybridSystems.target(::HybridSystem{OneStateAutomaton}, ::DiscreteSwitchingSequence) = 1

function DiscreteSwitchingSequence(s::HybridSystem, A::AbstractMatrix, seq::Vector)
    DiscreteSwitchingSequence(s, A, seq, length(seq))
end
switchingsequence(s::HybridSystem, A::AbstractMatrix, seq::Vector) = DiscreteSwitchingSequence(s, A, seq)
function switchingsequence(s::HybridSystem, len::Int=0, v::Int=1)
    DiscreteSwitchingSequence(s, _eyes(s, v, true), Vector{transitiontype(s)}(undef, len), 0)
end

function Base.prepend!(s::DiscreteSwitchingSequence, other::DiscreteSwitchingSequence)
    s.A = s.A * other.A
    if s.len < length(s.seq)
        if s.len + other.len <= length(s.seq)
            s.seq[other.len .+ (1:s.len)] = s.seq[1:s.len] # Cannot use view here
            s.seq[1:other.len] = @view other.seq[1:other.len]
        else
            len = length(s.seq)
            off = max(0, len - other.len)
            append!(s.seq, @view s.seq[(off+1):s.len])
            s.seq[other.len .+ (1:off)] = s.seq[1:off] # Cannot use view here
            if len < other.len
                s.seq[:] = @view other.seq[1:len]
                append!(s.seq, @view other.seq[(len+1):other.len])
            else
                s.seq[1:other.len] = @view other.seq[1:other.len]
            end
        end
    else
        prepend!(s.seq, other.seq)
    end
    s.len += other.len
end

function Base.append!(s::DiscreteSwitchingSequence, other::DiscreteSwitchingSequence)
    s.A = other.A * s.A
    if s.len < length(s.seq)
        if s.len + other.len <= length(s.seq)
            s.seq[(s.len+1):(s.len+other.len)] = @view other.seq[1:other.len]
        else
            off = length(s.seq) - s.len
            s.seq[(s.len+1):end] = @view other.seq[1:off]
            append!(s.seq, @view other.seq[(off+1):other.len])
        end
    else
        append!(s.seq, other.seq)
    end
    s.len += other.len
end

struct SwitchingIterator{S<:HybridSystem}
    s::S
    k::Int        # length of sequence
    v0::Int       # starting mode
    forward::Bool # Is the sequence going forward or backward
end
Base.IteratorSize(::SwitchingIterator) = Base.SizeUnknown()

# Iterates over all the `forward` switching of length `k` starting at `v0`
function switchings(s::HybridSystem, k::Int, v0::Int, forward=true)
    SwitchingIterator(s, k, v0, forward)
end

struct SwitchingIteratorState{IT, ST, MT, ET}
    # modeit[i] is a list of all the possible transitions for the (i-1)th mode
    modeit::Vector{IT}
    # modest[i] is the ith state of iterator modeit[i]
    modest::Vector{ST}
    As::Vector{MT}
    seq::Vector{ET}
    function SwitchingIteratorState{IT, ST, MT, ET}(k::Int) where {IT, ST, MT, ET}
        new{IT, ST, MT, ET}(Vector{IT}(undef, k), Vector{ST}(undef, k),
                            Vector{MT}(undef, k), Vector{ET}(undef, k))
    end
end

function io_transitions(s::HybridSystem, mode, forward::Bool)
    if forward
        return out_transitions(s, mode)
    else
        return in_transitions(s, mode)
    end
end
function io_state(s::HybridSystem, t, forward::Bool)
    if forward
        return target(s, t)
    else
        return source(s, t)
    end
end

function Base.iterate(it::SwitchingIterator)
    ts = io_transitions(it.s, it.v0, it.forward)
    IT = typeof(ts)
    state_item = iterate(ts)
    if state_item === nothing
        return nothing
    end
    ST = typeof(state_item[2])
    MT = typeof(first(it.s.resetmaps).A)
    ET = transitiontype(it.s)
    st = SwitchingIteratorState{IT, ST, MT, ET}(it.k)
    return complete_switching(it, st, it.forward ? 1 : it.k)
end
function Base.iterate(it::SwitchingIterator, st::SwitchingIteratorState)
    next_switching(it, st, it.forward ? it.k : 1)
end
function cur_mode(it::SwitchingIterator, st::SwitchingIteratorState, i::Int)
    j = i + (it.forward ? -1 : 1)
    if j <= 0 || j > it.k
        return it.v0
    else
        return io_state(it.s, st.seq[j], it.forward)
    end
end
function prev_matrix(it::SwitchingIterator, st::SwitchingIteratorState, i::Int)
    j = i + (it.forward ? -1 : 1)
    if j <= 0 || j > it.k
        return I
    else
        return st.As[j]
    end
end
function process_item_state(it::SwitchingIterator, st::SwitchingIteratorState, i::Int, item_state::Nothing)
    inc = it.forward ? 1 : -1
    return next_switching(it, st, i - inc)
end
function process_item_state(it::SwitchingIterator, st::SwitchingIteratorState, i::Int, item_state)
    st.modest[i] = item_state[2]
    st.seq[i] = item_state[1]
    B = resetmap(it.s, st.seq[i]).A
    A = prev_matrix(it, st, i)
    st.As[i] = it.forward ? B * A : A * B
    return complete_switching(it, st, i + (it.forward ? 1 : -1))
end
function next_switching(it::SwitchingIterator, st::SwitchingIteratorState, i::Int)
    inc = it.forward ? 1 : -1
    if i <= 0 || i > it.k
        return nothing
    else
        item_state = iterate(st.modeit[i], st.modest[i])
        process_item_state(it, st, i, item_state)
    end
end
function complete_switching(it::SwitchingIterator, st::SwitchingIteratorState, i::Int)
    inc = it.forward ? 1 : -1
    if i <= 0 || i > it.k
        return switchingsequence(it.s, st.As[i - inc], copy(st.seq)), st
    else
        st.modeit[i] = io_transitions(it.s, cur_mode(it, st, i), it.forward)
        item_state = iterate(st.modeit[i])
        process_item_state(it, st, i, item_state)
    end
end
