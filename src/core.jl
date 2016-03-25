"""
Dictionary types which keys are fixed at creation time
"""
abstract AbstractFixedSizeDict{Keys}

"""
Dictionary types which keys and values are fixed at creation time
"""
immutable FixedKeyValueDict{Keys<:Tuple, Values<:Tuple} <: AbstractFixedSizeDict{Keys}
    values::Values
end
"""
Dictionary types which keys are fixed at creation time
"""
immutable FixedKeyDict{Keys<:Tuple, Values<:AbstractVector} <: AbstractFixedSizeDict{Keys}
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
    keyparams = Tuple{keys...}
    FixedKeyValueDict{keyparams, typeof(values)}(values)
end

"""
Constructor for a list of pairs of key => value.
Arbitrary data structures of length 2 can be used
"""
function FixedKeyValueDict(key_values)
    kv = tuple(key_values...) # needs to be a tuple, since both key and value needs to be a tuple
    keys = map(first, kv)
    values = map(last, kv)
    keyparams = Tuple{keys...}
    FixedKeyValueDict{keyparams, typeof(values)}(values)
end



"""
Constructor for a list of keys together with a list of values which should have the same length
"""
function FixedKeyDict{N}(keys::NTuple{N, Symbol}, values::AbstractVector)
    keyparams = Tuple{keys...}
    FixedKeyDict{keyparams, typeof(values)}(values)
end

"""
Constructor for a list of pairs of key => value.
Arbitrary data structures of length 2 can be used
"""
function FixedKeyDict(key_values)
    kv = collect(key_values) # needs collect for some datastructures like Dict
    keys = ntuple(length(kv)) do i
        first(kv[i])
    end
    values = [v for (k,v) in kv] # for comprehension to always get a Vector
    keyparams = Tuple{keys...}
    FixedKeyDict{keyparams, typeof(values)}(values)
end

# this is a generated function, since T.parameters results in the code to be slow otherwise
@generated function keys{T<:AbstractFixedSizeDict}(::Type{T})
    ks = [:(Val{$(Expr(:quote, sym))}) for sym in T.parameters[1].parameters]
    :(tuple($(ks...)))
end

keys{T<:AbstractFixedSizeDict}(::T) = keys(T)
values(x::AbstractFixedSizeDict) = x.values
length(x::AbstractFixedSizeDict) = length(x.values)
# also a generated function, since we can inline the result for every type, which
# doesn't happen otherwise
@generated function haskey{T<:AbstractFixedSizeDict, Key}(sd::T, ::Type{Val{Key}})
    :($(Val{Key} in keys(sd)))
end

function Base.start(x::AbstractFixedSizeDict)
    ks = keys(x)
    (1, ks) # we pass around the keys so that we don't have to get them multiple times
end
function Base.next(x::AbstractFixedSizeDict, state)
    index, ks = state
    (ks[index], x[index]), (index+1, ks)
end
function Base.done(x::AbstractFixedSizeDict, state)
    length(x) > state[1]
end


@generated function Base.getindex{T<:AbstractFixedSizeDict, Key}(
        sd::T, ::Type{Val{Key}}
    )
    index = findfirst(keys(T), Val{Key}) # lookup position of symbol
    index == 0 && throw(KeyError("key $Key not found in $sd"))
    :(@inbounds return sd.values[$index])
end

@generated function Base.setindex!{T<:FixedKeyDict, Key}(
        sd::T, value, ::Type{Val{Key}}
    )
    index = findfirst(keys(T), Val{Key})
    index == 0 && throw(KeyError("key $Key not found in $sd"))
    :(@inbounds return sd.values[$index] = value)
end


function get{T<:AbstractFixedSizeDict, Key}(f::Function, sd::T, k::Type{Val{Key}})
    if haskey(sd, k)
        sd[k]
    else
        f()
    end
end
function get{T<:AbstractFixedSizeDict, Key}(sd::T, k::Type{Val{Key}}, default)
    if haskey(sd, k)
        sd[k]
    else
        default
    end
end



"""
generates the expression to acces a field of a dict via a Val{Symbol}
"""
function getfield_expr(dict, key)
    :($dict[Val{$key}])
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
