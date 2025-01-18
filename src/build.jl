function build_docs()
    filename = if Sys.iswindows()
        "docs.bat"
    else
        "docs.sh"
    end

    run(`$(joinpath(package_path, "docs", filename))`)

    return nothing
end

function build_examples()
    filename = if Sys.iswindows()
        "examples.bat"
    else
        "examples.sh"
    end

    run(`$(joinpath(package_path, "examples", filename))`)

    return nothing
end