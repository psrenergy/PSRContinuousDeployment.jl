function create_zip(;
    configuration::Configuration,
)
    target = configuration.target
    version = configuration.version
    build_path = joinpath(configuration.build_path, "*")
    setup_path = configuration.setup_path

    zip_filename = build_zip_filename(configuration = configuration)
    zip_path = joinpath(setup_path, zip_filename)

    Log.info("ZIP: Zipping the $zip_filename")
    run(`$(p7zip_jll.p7zip()) a -tzip $zip_path $build_path`)
    @assert isfile(zip_path)

    return zip_path
end

function zip(path::AbstractString, destination::AbstractString)
    Log.info("ZIP: Zipping $path to $destination")
    run(`$(p7zip_jll.p7zip()) a -tzip $destination $path`)
end

function unzip(path::AbstractString, destination::AbstractString)
    Log.info("ZIP: Unzipping $path to $destination")
    run(`$(p7zip_jll.p7zip()) x -o$destination $path`)
end
