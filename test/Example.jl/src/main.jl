function f(x::Number, y::Number)
    return x + y
end

function g(x::Number, y::Number)
    return x * y
end

function @main(ARGS)::Cint
    close_logger = open_logger(@__DIR__)

    try
        arg1 = parse(Int, ARGS[1])
        arg2 = parse(Int, ARGS[2])

        result_f = f(arg1, arg2)
        result_g = g(arg1, arg2)

        string_f = string(result_f)
        string_g = string(result_g)

        println(Core.stdout, string_f)
        println(Core.stdout, string_g)

        # @info string_f
        # @info string_g
    finally
        close_logger()
    end

    return 0
end
