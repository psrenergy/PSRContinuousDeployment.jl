function make_docs()
    filename = if Sys.iswindows()
        "docs.bat"
    else
        "docs.sh"
    end

    run(`$(joinpath(package_path, "docs", filename))`)

    return nothing
end