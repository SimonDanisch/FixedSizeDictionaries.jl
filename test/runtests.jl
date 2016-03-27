using FixedSizeDictionaries
using Base.Test


function test_fixedkeyvalue(kvdict)

    @test kvdict[Val{:a}()] == 22
    @test kvdict[Val{:b}()] == 3f0
    @test kvdict[Val{:c}()] == 3f0



    @test haskey(kvdict, Val{:a}()) == true
    @test haskey(kvdict, Val{:b}()) == true
    @test haskey(kvdict, Val{:c}()) == true
    @test haskey(kvdict, Val{:Y}()) == false

    val = get(kvdict, Val{:a}()) do
        "oh nose"
    end
    @test val == 22
    val = get(kvdict, Val{:Y}()) do
        "u do this"
    end
    @test val == "u do this"

end

@testset "FixedKeyValueDict" begin
    kvdict = FixedKeyValueDict((:a => 22, :b => 3f0, :c => 3f0))
    @test kvdict == FixedKeyValueDict(((:a, 22), (:b, 3f0), (:c, 3f0)))
    @test kvdict == FixedKeyValueDict(:a => 22, :b => 3f0, :c => 3f0)
    @test kvdict == FixedKeyValueDict((:a, :b, :c), (22, 3f0, 3f0))
    @test kvdict == FixedKeyValueDict(Dict(:a => 22, :b => 3f0, :c => 3f0))

    @test FixedSizeDictionaries.key2index(kvdict, Val{:a}()) == 1
    @test FixedSizeDictionaries.key2index(kvdict, Val{:b}()) == 2
    @test FixedSizeDictionaries.key2index(kvdict, Val{:c}()) == 3
    @test keys(kvdict) == (Val{:a}(), Val{:b}(), Val{:c}())
    @test values(kvdict) == (22, 3f0, 3f0)

    # test 2 times to make sure nothing gets compiled and different dicts
    # don't influence each other (method table is global state)
    test_fixedkeyvalue(kvdict)
    test_fixedkeyvalue(kvdict)

    #try the same with different order
    kvdict2 = FixedKeyValueDict((:b => 3f0, :c => 3f0, :a => 22))

    @test FixedSizeDictionaries.key2index(kvdict2, Val{:b}()) == 1
    @test FixedSizeDictionaries.key2index(kvdict2, Val{:c}()) == 2
    @test FixedSizeDictionaries.key2index(kvdict2, Val{:a}()) == 3
    @test keys(kvdict2) == (Val{:b}(), Val{:c}(), Val{:a}())
    @test values(kvdict2) == (3f0, 3f0, 22)

    test_fixedkeyvalue(kvdict2)
    test_fixedkeyvalue(kvdict2)

end


@testset "FixedKeyDict" begin

    kvdict = FixedKeyDict((:a => 22, :b => 3f0, :c => 3f0))
    @test kvdict == FixedKeyDict(((:a, 22), (:b, 3f0), (:c, 3f0)))
    @test kvdict == FixedKeyDict(:a => 22, :b => 3f0, :c => 3f0)
    @test kvdict == FixedKeyDict((:a, :b, :c), [22, 3f0, 3f0])
    @test kvdict == FixedKeyDict(Dict(:a => 22, :b => 3f0, :c => 3f0))


    @test FixedSizeDictionaries.key2index(kvdict, Val{:a}()) == 1
    @test FixedSizeDictionaries.key2index(kvdict, Val{:b}()) == 2
    @test FixedSizeDictionaries.key2index(kvdict, Val{:c}()) == 3
    @test keys(kvdict) == (Val{:a}(), Val{:b}(), Val{:c}())
    @test values(kvdict) == [22, 3f0, 3f0]


    test_fixedkeyvalue(kvdict)
    test_fixedkeyvalue(kvdict)



    @get kvdict.a = 10
    @get kvdict.b = 77f0
    @get kvdict.c = 88f0


    @test kvdict[Val{:a}()] == 10
    @test kvdict[Val{:b}()] == 77f0
    @test kvdict[Val{:c}()] == 88f0


    @test get(kvdict, Val{:a}(), 999) == 10
    @test get(kvdict, Val{:b}(), 999) == 77f0
    @test get(kvdict, Val{:c}(), 999) == 88f0
    @test get(kvdict, Val{:a}(), 999) == 10

    @test get(kvdict, Val{:Y}(), 999) == 999

    val = get(kvdict, Val{:a}()) do
        "oh nose"
    end
    @test val == 10
    val = get(kvdict, Val{:Y}()) do
        "u do this"
    end
    @test val == "u do this"

end
