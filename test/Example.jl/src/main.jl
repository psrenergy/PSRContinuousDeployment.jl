function f(x::Number, y::Number)
    return x + y
end

function g(x::Number, y::Number)
    return x * y
end

@static if VERSION >= v"1.12.0"
    function @main(ARGS)::Cint
        arg1 = parse(Int, ARGS[1])
        arg2 = parse(Int, ARGS[2])

        result_f = f(arg1, arg2)
        result_g = g(arg1, arg2)

        string_f = string(result_f)
        string_g = string(result_g)

        println(Core.stdout, string_f)
        println(Core.stdout, string_g)

        return 0
    end
else
    function main(ARGS)::Cint
        arg1 = parse(Int, ARGS[1])
        arg2 = parse(Int, ARGS[2])

        result_f = f(arg1, arg2)
        result_g = g(arg1, arg2)

        println(result_f)
        println(result_g)

        return 0
    end
end
