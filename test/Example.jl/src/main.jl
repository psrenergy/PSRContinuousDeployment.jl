function main(args::Vector{String})
    println("Example.jl")

    return nothing
end

function julia_main()::Cint
    main(ARGS)
    return 0
end
