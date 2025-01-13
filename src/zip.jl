function create_zip(;
    configuration::Configuration,
)
    target = configuration.target
    version = configuration.version
    build_path = joinpath(configuration.build_path, "*")
    setup_path = configuration.setup_path

    zip_filename = if Sys.iswindows()
        "$target-$version-win64.zip"
    else
        "$target-$version-linux.zip"
    end

    zip_path = joinpath(setup_path, zip_filename)

    Log.info("ZIP: Zipping the $zip_filename")
    run(`$(p7zip_jll.p7zip()) a -tzip $zip_path $build_path`)
    @assert isfile(zip_path)

    return zip_path
end