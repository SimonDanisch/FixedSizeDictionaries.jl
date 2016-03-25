
"""
Library which implements a FixedSize variant of Dictionaries.
These can be stack allocated and have `O(1)` indexing performance without boundcheck
It implements most parts of the `Base.Dict` interface.
This package is usefull, when you basically want anonymous composite types.
You should be a bit carefull with generating a lot of FixedSizeDict's, since
it will compile a unique set of functions for every field of a Dict.
"""
module FixedSizeDictionaries

    import Base: start
    import Base: next
    import Base: done
    import Base: getindex
    import Base: setindex!
    import Base: get
    import Base: haskey
    import Base: values
    import Base: keys
    import Base: ==
    import Base: length

    include("core.jl")

    export AbstractFixedSizeDict
    export FixedKeyDict
    export FixedKeyValueDict
    export @get

end # module
