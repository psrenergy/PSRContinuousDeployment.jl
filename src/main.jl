function finish_path(path::String)
    if isempty(path)
        return path
    end
    if isfile(path)
        return normpath(path)
    end
    if Sys.islinux() && path[end] != '/'
        return normpath(path * "/")
    elseif Sys.iswindows() && path[end] != '\\'
        return normpath(path * "\\")
    else
        return normpath(path)
    end
end
function parse_commandline(args)
    s = ArgParse.ArgParseSettings()

    ArgParse.@add_arg_table! s begin
        "--opt1"
        help = "an option with an argument"
        action = :store_true
        "path"
        help = "path to the case inputs"
        arg_type = String
        default = pwd()
    end
    # dump args into dict
    parsed_args = ArgParse.parse_args(args, s)

    # Possibly fix paths and apply the normpath method
    parsed_args["path"] = finish_path(parsed_args["path"])
    if !isdir(parsed_args["path"])
        error("The directory " * parsed_args["path"] * " does not exist.")
    end

    return parsed_args
end

function main(args)
    @info("PSRExample - version: $_VERSION")

    # Funções para validar os argumentos
    parsed_args = parse_commandline(args)

    # Funções de inicialização
    # Servem para deixar dlls disponíveis (PSRClasses, etc.)
    initialize()

    # Todo o trabalho deve ser feito aqui
    # Esse daqui é apenas um exemplo, em geral é necessário 
    # passar uma pasta com um caso e alguns parâmetros.
    input = readline(open(joinpath(parsed_args["path"], "input.dat")))
    rhs = parse(Float64, input)
    obj = solve_model(rhs)

    # Write some results
    PSRI.array_to_file(
        PSRI.OpenBinary.Writer,
        joinpath(parsed_args["path"], "output"),
        [obj][:, :, :, :];
        agents = ["Objective"],
        unit = "MW",
        initial_stage = 3,
        initial_year = 2006,
    )

    touch(joinpath(parsed_args["path"], "PSRExample.ok"))
    return
end

function julia_main()::Cint
    main(ARGS)
    return 0
end
