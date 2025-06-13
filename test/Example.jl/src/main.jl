function f(x::Number, y::Number)
    return x + y
end

function g(x::Number, y::Number)
    return x * y
end

function main(args::Vector{String})
    println("Example.jl")

    println("Arguments: ", args)

    println("f = ", f(parse(Float64, args[1]), parse(Float64, args[2])))
    println("g = ", g(parse(Float64, args[1]), parse(Float64, args[2])))

    return nothing
end

function julia_main()::Cint
    main(ARGS)
    return 0
end
