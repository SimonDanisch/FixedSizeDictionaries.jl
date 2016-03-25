using FixedSizeDictionaries
using BaseTestNext

@testset "FixedKeyValueDict" begin
    kvdict = FixedKeyValueDict((:a => 22, :b => 3f0, :c => 3f0))
    @test kvdict == FixedKeyValueDict(((:a, 22), (:b, 3f0), (:c, 3f0)))
    @test kvdict == FixedKeyValueDict(:a => 22, :b => 3f0, :c => 3f0)
    @test kvdict == FixedKeyValueDict((:a, :b, :c), (22, 3f0, 3f0))
    @test kvdict == FixedKeyValueDict(Dict(:a => 22, :b => 3f0, :c => 3f0))
    @test @get(kvdict.a) == 22
    @test @get(kvdict.b) == 3f0
    @test @get(kvdict.c) == 3f0
    @test keys(kvdict) == (Val{:a}, Val{:b}, Val{:c})
    @test values(kvdict) == (22, 3f0, 3f0)

    val = get(kvdict, Val{:a}) do
        "oh nose"
    end
    @test val == 22
    val = get(kvdict, Val{:Y}) do
        "u do this"
    end
    @test val == "u do this"

end


@testset "FixedKeyDict" begin

    kvdict = FixedKeyDict((:a => 22, :b => 3f0, :c => 3f0))
    @test kvdict == FixedKeyDict(((:a, 22), (:b, 3f0), (:c, 3f0)))
    @test kvdict == FixedKeyDict(:a => 22, :b => 3f0, :c => 3f0)
    @test kvdict == FixedKeyDict((:a, :b, :c), [22, 3f0, 3f0])
    @test kvdict == FixedKeyDict(Dict(:a => 22, :b => 3f0, :c => 3f0))

    @test @get(kvdict.a) == 22
    @test @get(kvdict.b) == 3f0
    @test @get(kvdict.c) == 3f0

    @test keys(kvdict) == (Val{:a}, Val{:b}, Val{:c})
    @test values(kvdict) == [22, 3f0, 3f0]

    @get kvdict.a = 10
    @get kvdict.b = 77f0
    @get kvdict.c = 88f0

    @test @get(kvdict.a) == 10
    @test @get(kvdict.b) == 77f0
    @test @get(kvdict.c) == 88f0

    @test get(kvdict, Val{:a}, 999) == 10
    @test get(kvdict, Val{:Y}, 999) == 999

    val = get(kvdict, Val{:a}) do
        "oh nose"
    end
    @test val == 10
    val = get(kvdict, Val{:Y}) do
        "u do this"
    end
    @test val == "u do this"

end
