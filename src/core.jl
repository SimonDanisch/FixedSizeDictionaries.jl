"""
Dictionary types which keys are fixed at creation time
"""
abstract AbstractFixedSizeDict{Keys}

"""
Dictionary types which keys and values are fixed at creation time
"""
immutable FixedKeyValueDict{Keys, Values<:Tuple} <: AbstractFixedSizeDict{Keys}
    keys::Keys
    values::Values
end
"""
Dictionary types which keys are fixed at creation time
"""
immutable FixedKeyDict{Keys, Values<:AbstractVector} <: AbstractFixedSizeDict{Keys}
    keys::Keys
    values::Values
end

"""
Generic constructor that dispatches XDict(pair, pair, ...) to XDict((pair, pair))
"""
function call{T<:AbstractFixedSizeDict}(::Type{T}, args...)
    T(args)
end

# TODO set operations

"""
Constructor for a list of keys together with a list of values which should have the same length
"""
function FixedKeyValueDict{N}(keys::NTuple{N, Symbol}, values::NTuple{N, Any})
    # TODO enforce unique keys?!
    keys = map(k->Val{k}(), keys)
    FixedKeyValueDict(keys, values)
end

"""
Constructor for a list of pairs of key => value.
Arbitrary data structures of length 2 can be used
"""
function FixedKeyValueDict(key_values)
    kv = tuple(key_values...) # needs to be a tuple, since both key and value needs to be a tuple
    keys = map(k->Val{first(k)}(), kv)
    values = map(last, kv)
    FixedKeyValueDict(keys, values)
end



"""
Constructor for a list of keys together with a list of values which should have the same length
"""
function FixedKeyDict{N}(keys::NTuple{N, Symbol}, values::AbstractVector)
    keys = map(k->Val{k}(), keys)
    FixedKeyDict(keys, values)
end

"""
Constructor for a list of pairs of key => value.
Arbitrary data structures of length 2 can be used
"""
function FixedKeyDict(key_values)
    kv = collect(key_values) # needs collect for some datastructures like Dict
    keys = ntuple(length(kv)) do i # ntuple, to always get a tuple
        Val{first(kv[i])}()
    end
    values = [v for (k,v) in kv] # for-comprehension to always get a Vector
    FixedKeyDict(keys, values)
end


keys{T<:AbstractFixedSizeDict}(fsd::T) = fsd.keys
# this is a generated function, since T.parameters results in the code to be slow otherwise
@generated function keys{T<:AbstractFixedSizeDict}(::Type{T})
    ks = map(x-> x(), T.parameters[1].parameters)
    :(tuple($(ks...)))
end
# use @generated to do field lookup at compile time instead of runtime
@generated function key2index{Keys, Key}(x::AbstractFixedSizeDict{Keys}, k::Val{Key})
    index = findfirst(Keys.parameters, k)
    index == 0 && throw(KeyError("key $Key not found in $x"))
    :($index)
end
# also a generated function, since we can inline the result for every type, which
# doesn't happen otherwise
@generated function haskey{Keys, Key}(sd::AbstractFixedSizeDict{Keys}, ::Key)
    :($(Key in Keys.parameters))
end


values(x::AbstractFixedSizeDict) = x.values
length(x::AbstractFixedSizeDict) = length(x.values)


function Base.start(x::AbstractFixedSizeDict)
    (1, keys(x)) # we pass around the keys so that we don't have to get them multiple times
end
function Base.next(x::AbstractFixedSizeDict, state)
    index, ks = state
    (ks[index], x[index]), (index+1, ks)
end
function Base.done(x::AbstractFixedSizeDict, state)
    length(x) > state[1]
end

# k should be typed, but that gives weird behaviour on 0.5
function getindex{Keys, Key}(sd::AbstractFixedSizeDict{Keys}, k::Val{Key})
    @inbounds return sd.values[key2index(sd, k)]
end

function setindex!{Keys, Key}(sd::FixedKeyDict{Keys}, value, k::Val{Key})
    @inbounds return sd.values[key2index(sd, k)] = value
end

function get{Keys}(f::Function, sd::AbstractFixedSizeDict{Keys}, k)
    if haskey(sd, k)
        return sd[k]
    end
    f()
end
function get{Keys}(sd::AbstractFixedSizeDict{Keys}, k, default)
    if haskey(sd, k)
        return sd[k]
    end
    default
end


"""
generates the expression to acces a field of a dict via a Val{Symbol}
"""
function getfield_expr(dict, key)
    :($dict[Val{$key}()])
end

"""
Allows getfield like access to the keys of a FixedDict
"""
macro get(expr)
    if expr.head == :(.)
        return esc(getfield_expr(expr.args...))
    elseif expr.head == :(=)
        fieldexpr, val = expr.args
        getfieldex = getfield_expr(fieldexpr.args...)
        return esc(Expr(:(=), getfieldex, val))
    else
        throw(
            ArgumentError("Expression of the form $expr not allowed. Try a.key, or a.key=value")
        )
    end
end


# we need to redefine equality, since dicts with the same set of keys and values should
# match regardless of order
function (==)(a::AbstractFixedSizeDict, b::AbstractFixedSizeDict)
    for (key, value) in a
        if haskey(b, key)
            value != b[key] && return false
        else
            return false
        end
    end
    true
end
