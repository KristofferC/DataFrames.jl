module TestIO
    using Base.Test
    using DataFrames, Compat

    #test_group("We can read various file types.")

    data = joinpath(dirname(@__FILE__), "data")

    filenames = ["$data/blanklines/blanklines.csv",
                 "$data/compressed/movies.csv.gz",
                 "$data/headeronly/headeronly.csv",
                 "$data/newlines/embedded_os9.csv",
                 "$data/newlines/embedded_osx.csv",
                 "$data/newlines/embedded_windows.csv",
                 "$data/padding/space_after_delimiter.csv",
                 "$data/padding/space_around_delimiter.csv",
                 "$data/padding/space_before_delimiter.csv",
                 "$data/quoting/empty.csv",
                 "$data/quoting/escaping.csv",
                 "$data/quoting/quotedcommas.csv",
                 "$data/scaling/10000rows.csv",
                 "$data/utf8/corrupt_utf8.csv",
                 "$data/utf8/short_corrupt_utf8.csv",
                 "$data/utf8/utf8.csv"]

    for filename in filenames
        try
            df = readtable(filename)
        catch
            error(@sprintf "Failed to read %s\n" filename)
        end
    end

    #test_group("We get the right size, types, values for a basic csv.")

    filename = "$data/scaling/movies.csv"
    df = readtable(filename)

    @test size(df) == (58788, 25)

    @test df[1, 1] === Nullable(1)
    @test isequal(df[1, 2], Nullable("\$"))
    @test df[1, 3] === Nullable(1971)
    @test df[1, 4] === Nullable(121)
    @test df[1, 5] === Nullable(0, true) # See JuliaLang/julia#16923
    @test df[1, 6] === Nullable(6.4)
    @test df[1, 7] === Nullable(348)
    @test df[1, 8] === Nullable(4.5)
    @test df[1, 9] === Nullable(4.5)
    @test df[1, 10] === Nullable(4.5)
    @test df[1, 11] === Nullable(4.5)
    @test df[1, 12] === Nullable(14.5)
    @test df[1, 13] === Nullable(24.5)
    @test df[1, 14] === Nullable(24.5)
    @test df[1, 15] === Nullable(14.5)
    @test df[1, 16] === Nullable(4.5)
    @test df[1, 17] === Nullable(4.5)
    @test isequal(df[1, 18], Nullable(""))
    @test df[1, 19] === Nullable(0)
    @test df[1, 20] === Nullable(0)
    @test df[1, 21] === Nullable(1)
    @test df[1, 22] === Nullable(1)
    @test df[1, 23] === Nullable(0)
    @test df[1, 24] === Nullable(0)
    @test df[1, 25] === Nullable(0)

    @test df[end, 1] === Nullable(58788)
    @test isequal(df[end, 2], Nullable("xXx: State of the Union"))
    @test df[end, 3] === Nullable(2005)
    @test df[end, 4] === Nullable(101)
    @test df[end, 5] === Nullable(87000000)
    @test df[end, 6] === Nullable(3.9)
    @test df[end, 7] === Nullable(1584)
    @test df[end, 8] === Nullable(24.5)
    @test df[end, 9] === Nullable(4.5)
    @test df[end, 10] === Nullable(4.5)
    @test df[end, 11] === Nullable(4.5)
    @test df[end, 12] === Nullable(4.5)
    @test df[end, 13] === Nullable(14.5)
    @test df[end, 14] === Nullable(4.5)
    @test df[end, 15] === Nullable(4.5)
    @test df[end, 16] === Nullable(4.5)
    @test df[end, 17] === Nullable(14.5)
    @test isequal(df[end, 18], Nullable("PG-13"))
    @test df[end, 19] === Nullable(1)
    @test df[end, 20] === Nullable(0)
    @test df[end, 21] === Nullable(0)
    @test df[end, 22] === Nullable(0)
    @test df[end, 23] === Nullable(0)
    @test df[end, 24] === Nullable(0)
    @test df[end, 25] === Nullable(0)

    #test_group("readtable handles common separators and infers them from extensions.")

    df1 = readtable("$data/separators/sample_data.csv")
    df2 = readtable("$data/separators/sample_data.tsv")
    df3 = readtable("$data/separators/sample_data.wsv")
    df4 = readtable("$data/separators/sample_data_white.txt", separator = ' ')

    @test get(df1 == df2)
    @test get(df2 == df3)
    @test get(df3 == df4)

    readtable("$data/quoting/quotedwhitespace.txt", separator = ' ')

    #test_group("readtable handles common newlines.")

    df = readtable("$data/newlines/os9.csv")
    @test isequal(readtable("$data/newlines/osx.csv"), df)
    @test isequal(readtable("$data/newlines/windows.csv"), df)

    @test isequal(df, readtable("$data/newlines/os9.csv", skipblanks = false))
    @test isequal(df, readtable("$data/newlines/osx.csv", skipblanks = false))
    @test isequal(df, readtable("$data/newlines/windows.csv", skipblanks = false))

    #test_group("readtable treats rows as specified.")

    df1 = readtable("$data/comments/before_after_data.csv", allowcomments = true)
    df2 = readtable("$data/comments/middata.csv", allowcomments = true)
    df3 = readtable("$data/skiplines/skipfront.csv", skipstart = 3)
    df4 = readtable("$data/skiplines/skipfront.csv", skipstart = 4, header = false)
    names!(df4, names(df1))
    df5 = readtable("$data/comments/before_after_data_windows.csv", allowcomments = true)
    df6 = readtable("$data/comments/middata_windows.csv", allowcomments = true)
    df7 = readtable("$data/skiplines/skipfront_windows.csv", skipstart = 3)
    df8 = readtable("$data/skiplines/skipfront_windows.csv", skipstart = 4, header = false)
    names!(df8, names(df1))
    # df9 = readtable("$data/skiplines/skipfront.csv", skipstart = 3, skiprows = 5:6)
    # df10 = readtable("$data/skiplines/skipfront.csv", skipstart = 3, header = false, skiprows = [4, 6])
    # names!(df10, names(df1))

    @test get(df2 == df1)
    @test get(df3 == df1)
    @test get(df4 == df1)

    # Windows EOLS
    @test get(df5 == df1)
    @test get(df6 == df1)
    @test get(df7 == df1)
    @test get(df8 == df1)

    # @test df9 == df1[3:end]
    # @test df10 == df1[[1, 3:end]]

    function normalize_eol!(df)
        for (name, col) in eachcol(df)
            if eltype(col) <: AbstractString
                df[name] = map(s -> replace(s, "\r\n", "\n"), col)
            elseif eltype(col) <: Nullable && eltype(eltype(col)) <: AbstractString
                df[name] = map(s -> replace(get(s), "\r\n", "\n"), col)
            end
        end
        df
    end

    osxpath = "$data/skiplines/complex_osx.csv"
    winpath = "$data/skiplines/complex_windows.csv"

    opts1 = @compat Dict{Any,Any}(:allowcomments => true)
    opts2 = @compat Dict{Any,Any}(:skipstart => 4, :skiprows => [6, 7, 12, 14, 17], :skipblanks => false)

    df1 = readtable(osxpath; opts1...)
    # df2 = readtable(osxpath; opts2...)
    df1w = readtable(winpath; opts1...)
    # df2w = readtable(winpath; opts2...)

    # @test df2 == df1
    @test get(normalize_eol!(df1w) == df1)
    # @test normalize_eol!(df2w) == df1

    opts1[:nrows] = 3
    opts2[:nrows] = 3

    @test get(readtable(osxpath; opts1...) == df1[1:3, :])
    # @test readtable(osxpath; opts2...) == df1[1:3, :]
    @test get(normalize_eol!(readtable(winpath; opts1...)) == df1[1:3, :])
    # @test readtable(winpath; opts2...) == df1[1:3, :]

    # opts2[:header] = false
    # opts2[:skipstart] = 5

    # df2b = readtable(path; opts2...)
    # names!(df2b, names(df1))

    # @test df2b == df1[1:3]

    #test_group("readtable handles custom delimiters.")

    readtable("$data/skiplines/skipfront.csv", allowcomments = true, commentmark = '%')

    readtable("$data/separators/sample_data.csv", quotemark = Char[])
    @test_throws ErrorException readtable("$data/newlines/embedded_osx.csv", quotemark = Char[])
    df = readtable("$data/quoting/single.csv", quotemark = ['\''])
    @test get(df == readtable("$data/quoting/mixed.csv", quotemark = ['\'', '"']))

    # df = readtable("$data/decimal/period.csv")
    # @test df[2, :A] == 0.3
    # @test df[2, :B] == 4.0

    # @test df == readtable("$data/decimal/comma.tsv", decimal = ',')

    #test_group("readtable column names.")

    ns = [:Var1, :Var2, :Var3, :Var4, :Var5]
    df = readtable("$data/typeinference/mixedtypes.csv")
    names!(df, ns)
    @test get(df == readtable("$data/typeinference/mixedtypes.csv", names = ns))

    df = readtable("$data/separators/sample_data.csv", header = false, names = ns[1:3])
    @test get(df[1, :Var1] == Nullable(0))
    df = readtable("$data/separators/sample_data.csv", names = ns[1:3])
    @test get(df[1, :Var1] == Nullable(1))

    #test_group("Properties of data frames returned by readtable method.")

    # Readtable ignorepadding
    io = IOBuffer("A , \tB  , C\n1 , \t2, 3\n")
    @test get(readtable(io, ignorepadding = true) == DataFrame(A = 1, B = 2, C = 3))

    # Readtable c-style escape options

    df = readtable("$data/escapes/escapes.csv", allowescapes = true)
    @test get(df[1, :V] == Nullable("\t\r\n"))
    @test get(df[2, :V] == Nullable("\\\\t"))
    @test get(df[3, :V] == Nullable("\\\""))

    df = readtable("$data/escapes/escapes.csv")
    @test get(df[1, :V] == Nullable("\\t\\r\\n"))
    @test get(df[2, :V] == Nullable("\\\\t"))
    @test get(df[3, :V] == Nullable("\\\""))

    # df = readtable("$data/escapes/escapes.csv", escapechars = ['"'], nrows = 2)
    # @test df[1, :V] == "\\t\\r\\n"
    # @test df[2, :V] == "\\\\\\\\t"

    # Readtable with makefactors active should only make factors from columns
    # of strings.
    filename = "$data/factors/mixedvartypes.csv"
    df = readtable(filename, makefactors = true)

    @test isa(df[:factorvar], NullableNominalArray{Compat.UTF8String,1})
    @test isa(df[:floatvar], NullableArray{Float64,1})

    # Readtable shouldn't silently drop data when reading highly compressed gz.
    df = readtable("$data/compressed/1000x2.csv.gz")
    @test size(df) == (1000, 2)

    # Readtable type inference
    filename = "$data/typeinference/bool.csv"
    df = readtable(filename)
    @test isa(df[:Name], NullableArray{Compat.UTF8String,1})
    @test isa(df[:IsMale], NullableArray{Bool,1})
    @test get(df[:IsMale][1])
    @test !get(df[:IsMale][4])

    filename = "$data/typeinference/standardtypes.csv"
    df = readtable(filename)
    @test isa(df[:IntColumn], NullableArray{Int,1})
    @test isa(df[:IntlikeColumn], NullableArray{Float64,1})
    @test isa(df[:FloatColumn], NullableArray{Float64,1})
    @test isa(df[:BoolColumn], NullableArray{Bool,1})
    @test isa(df[:StringColumn], NullableArray{Compat.UTF8String,1})

    filename = "$data/typeinference/mixedtypes.csv"
    df = readtable(filename)
    @test isa(df[:c1], NullableArray{Compat.UTF8String,1})
    @test get(df[:c1][1]) == "1"
    @test get(df[:c1][2]) == "2.0"
    @test get(df[:c1][3]) == "true"
    @test isa(df[:c2], NullableArray{Float64,1})
    @test get(df[:c2][1]) == 1.0
    @test get(df[:c2][2]) == 3.0
    @test get(df[:c2][3]) == 4.5
    @test isa(df[:c3], NullableArray{Compat.UTF8String,1})
    @test get(df[:c3][1]) == "0"
    @test get(df[:c3][2]) == "1"
    @test get(df[:c3][3]) == "f"
    @test isa(df[:c4], NullableArray{Bool,1})
    @test get(df[:c4][1]) == true
    @test get(df[:c4][2]) == false
    @test get(df[:c4][3]) == true
    @test isa(df[:c5], NullableArray{Compat.UTF8String,1})
    @test get(df[:c5][1]) == "False"
    @test get(df[:c5][2]) == "true"
    @test get(df[:c5][3]) == "true"

    # Readtable defining column types
    filename = "$data/definedtypes/mixedvartypes.csv"

    df = readtable(filename)
    @test isa(df[:n], NullableArray{Int,1})
    @test get(df[:n][1]) == 1
    @test isa(df[:s], NullableArray{Compat.UTF8String,1})
    @test get(df[:s][1]) == "text"
    @test isa(df[:f], NullableArray{Float64,1})
    @test get(df[:f][1]) == 2.3
    @test isa(df[:b], NullableArray{Bool,1})
    @test get(df[:b][1]) == true

    df = readtable(filename, eltypes = [Int64, Compat.UTF8String, Float64, Bool])
    @test isa(df[:n], NullableArray{Int64,1})
    @test get(df[:n][1]) == 1
    @test isa(df[:s], NullableArray{Compat.UTF8String,1})
    @test get(df[:s][1]) == "text"
    @test get(df[:s][4]) == "text ole"
    @test isa(df[:f], NullableArray{Float64,1})
    @test get(df[:f][1]) == 2.3
    @test isa(df[:b], NullableArray{Bool,1})
    @test get(df[:b][1]) == true
    @test get(df[:b][2]) == false

    df = readtable(filename, eltypes = [Int64, Compat.UTF8String, Float64, Compat.UTF8String])
    @test isa(df[:n], NullableArray{Int64,1})
    @test get(df[:n][1]) == 1.0
    @test isnull(df[:s][3])
    @test isa(df[:f], NullableArray{Float64,1})
    # Float are not converted to int
    @test get(df[:f][1]) == 2.3
    @test get(df[:f][2]) == 0.2
    @test get(df[:f][3]) == 5.7
    @test isa(df[:b], NullableArray{Compat.UTF8String,1})
    @test get(df[:b][1]) == "T"
    @test get(df[:b][2]) == "FALSE"

    # Readtable name normalization
    abnormal = "\u212b"
    ns = [:Å, :_B_C_, :_end]
    @test !in(Symbol(abnormal), ns)

    io = IOBuffer(abnormal*",%_B*\tC*,end\n1,2,3\n")
    @test names(readtable(io)) == ns

    # With normalization disabled
    io = IOBuffer(abnormal*",%_B*\tC*,end\n1,2,3\n")
    @test names(readtable(io, normalizenames=false)) == [Symbol(abnormal),Symbol("%_B*\tC*"),:end]

    # Test writetable with Nullable() and compare to the results
    tf = tempname()
    isfile(tf) && rm(tf)
    df = DataFrame(A = NullableArray(Nullable{Int}[1,Nullable()]),
                   B = NullableArray(Nullable{String}["b", Nullable()]))
    writetable(tf, df)
    @test readcsv(tf) == ["A" "B"; 1 "b"; "NULL" "NULL"]    

    # Test writetable with nastring set and compare to the results
    isfile(tf) && rm(tf)
    writetable(tf, df, nastring="none")
    @test readcsv(tf) == ["A" "B"; 1 "b"; "none" "none"]

    # Test writetable with append
    df1 = DataFrame(a = NullableArray([1, 2, 3]), b = NullableArray([4, 5, 6]))
    df2 = DataFrame(a = NullableArray([1, 2, 3]), b = NullableArray([4, 5, 6]))
    df3 = DataFrame(a = NullableArray([1, 2, 3]), c = NullableArray([4, 5, 6])) # 2nd column mismatch
    df3b = DataFrame(a = NullableArray([1, 2, 3]), b = NullableArray([4, 5, 6]), c = NullableArray([4, 5, 6])) # number of columns mismatch


    # Would use joinpath(tempdir(), randstring()) to get around tempname
    # creating a file on Windows, but Julia 0.3 has no srand() to unset the
    # seed set in test/data.jl -- annoying for local testing.
    tf = tempname()
    isfile(tf) && rm(tf)

    # Written as normal if file doesn't exist
    writetable(tf, df1, append = true)
    @test isequal(readtable(tf), df1)

    # Written as normal if file is empty
    open(io -> print(io, ""), tf, "w")
    writetable(tf, df1, append = true)
    @test isequal(readtable(tf), df1)

    # Appends to existing file if append == true
    writetable(tf, df1)
    writetable(tf, df2, header = false, append = true)
    @test isequal(readtable(tf), vcat(df1, df2))

    # Overwrites file if append == false
    writetable(tf, df1)
    writetable(tf, df2)
    @test isequal(readtable(tf), df2)

    # Enforces matching column names iff append == true && header == true
    writetable(tf, df2)
    @test_throws KeyError writetable(tf, df3, append = true)
    writetable(tf, df3, header = false, append = true)

    # Enforces matching column count if append == true
    writetable(tf, df3)
    @test_throws DimensionMismatch writetable(tf, df3b, header = false, append = true)

    # Quotemarks are escaped
    tf = tempname()
    isfile(tf) && rm(tf)

    df = DataFrame(a = ["who's"]) # We have a ' in our string

    # Make sure the ' doesn't get escaped for no reason
    writetable(tf, df)
    @test isequal(readtable(tf), df)

    # Make sure the ' does get escaped when needed
    writetable(tf, df, quotemark='\'')
    @test readstring(tf) == "'a'\n'who\\'s'\n"

    ### Tests for nonstandard string literals
    # Test basic @csv_str usage
    df1 = csv"""
        name,  age, squidPerWeek
        Alice,  36,         3.14
        Bob,    24,         0
        Carol,  58,         2.71
        Eve,    49,         7.77
        """
    @test size(df1) == (4, 3)
    @test names(df1) == [:name, :age, :squidPerWeek]
    @test isequal(df1[1], NullableArray(["Alice","Bob","Carol","Eve"]))
    @test isequal(df1[2], [36,24,58,49])
    @test isequal(df1[3], [3.14,0,2.71,7.77])
    @test isa(df1[1], NullableArray{Compat.ASCIIString,1})

    # Test @wsv_str
    df2 = wsv"""
        name  age squidPerWeek
        Alice  36         3.14
        Bob    24         0
        Carol  58         2.71
        Eve    49         7.77
        """
    @test isequal(df2, df1)

    # Test @tsv_str
    df3 = tsv"""
        name	age	squidPerWeek
        Alice	36	3.14
        Bob	24	0
        Carol	58	2.71
        Eve	49	7.77
        """
    @test isequal(df3, df1)

    # csv2 can't be tested until non-'.' decimals are implemented
    #df4 = csv2"""
    #    name;  age; squidPerWeek
    #    Alice;  36;         3,14
    #    Bob;    24;         0
    #    Carol;  58;         2,71
    #    Eve;    49;         7,77
    #    """
    #@test isequal(df4, df1)

    # Test 'f' flag
    df5 = csv"""
        name,  age, squidPerWeek
        Alice,  36,         3.14
        Bob,    24,         0
        Carol,  58,         2.71
        Eve,    49,         7.77
        """f
    @test isa(df5[1], NullableNominalArray{Compat.ASCIIString,1})

    # Test 'c' flag
    df6 = csv"""
        name,  age, squidPerWeek
        Alice,  36,         3.14
        Bob,    24,         0
        #Carol,  58,         2.71
        Eve,    49,         7.77
        """c
    @test isequal(df6, df1[[1,2,4],:])

    # Test 'H' flag
    df7 = csv"""
        Alice,  36,         3.14
        Bob,    24,         0
        Carol,  58,         2.71
        Eve,    49,         7.77
        """H
    @test names(df7) == [:x1,:x2,:x3]
    names!(df7, names(df1))
    @test isequal(df7, df1)

    # Test multiple flags at once
    df8 = csv"""
        Alice,  36,         3.14
        Bob,    24,         0
        #Carol,  58,         2.71
        Eve,    49,         7.77
        """fcH
    @test isa(df8[1], NullableNominalArray{Compat.ASCIIString,1})
    @test names(df8) == [:x1,:x2,:x3]
    names!(df8, names(df1))
    @test isequal(df8, df1[[1,2,4],:])

    # Test invalid flag
    # Need to wrap macro call inside eval to prevent the error from being
    # thrown prematurely
    @test_throws ArgumentError eval(:(csv"foo,bar"a))
end
