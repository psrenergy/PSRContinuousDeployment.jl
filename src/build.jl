function build_docs(configuration::Configuration)
    package_path = configuration.package_path

    filename = if Sys.iswindows()
        "docs.bat"
    else
        "docs.sh"
    end

    @info("Building documentation")
    run(`$(joinpath(package_path, "docs", filename))`)

    return nothing
end

function build_examples(configuration::Configuration)
    package_path = configuration.package_path

    filename = if Sys.iswindows()
        "examples.bat"
    else
        "examples.sh"
    end

    @info("Building examples")
    run(`$(joinpath(package_path, "examples", filename))`)

    return nothing
end
