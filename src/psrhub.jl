function bundle_psrhub(;
    configuration::Configuration,
    psrhub_version::AbstractString,
    sign::Bool = false,
    examples_path::Union{Nothing, AbstractString} = nothing,
    documentation_path::Union{Nothing, AbstractString} = nothing,
    icon_path::Union{Nothing, AbstractString} = nothing,
)
    initialize_aws()

    bucket = "psr-update-modules"

    target = configuration.target
    build_path = configuration.build_path

    target_build_path = joinpath(build_path, "$target.exe")

    build_folders = readdir(build_path)

    model_path = joinpath(build_path, "model")
    if isdir(model_path)
        @info("PSRHUB: Removing model directory")
        rm(model_path, force = true, recursive = true)
    end

    @info("PSRHUB: Creating model directory")
    mkdir(model_path)

    @info("PSRHUB: Copying folders to model directory")
    for folder in build_folders
        source = joinpath(build_path, folder)
        destiny = joinpath(model_path, folder)
        mv(source, destiny, force = true)
    end

    psrhub_zip = "$psrhub_version.zip"
    psrhub_zip_path = joinpath(build_path, psrhub_zip)

    @info("PSRHUB: Downloading the PSRHub/$psrhub_zip")

    open(psrhub_zip_path, "w") do f
        S3.get_object(bucket, "PSRHub/$psrhub_zip", Dict("response_stream" => f))
        return nothing
    end

    @info("PSRHUB: Extracting the $psrhub_zip")
    run(`$(p7zip_jll.p7zip()) x $psrhub_zip_path -o$build_path`)

    @info("PSRHUB: Removing the $psrhub_zip")
    rm(psrhub_zip_path, force = true)

    @info("PSRHUB: Renaming psrhub.exe to $target.exe")
    mv(joinpath(build_path, "psrhub.exe"), target_build_path, force = true)

    @info("PSRHUB: Creating $target-debug.bat")
    open(joinpath(build_path, "$target-debug.bat"), "w") do io
        writeln(io, "$target.exe > psrhub.log 2>&1")
        return nothing
    end

    if !isnothing(examples_path)
        build_examples_path = joinpath(build_path, "examples")

        if isdir(build_examples_path)
            @info("COMPILE: Removing examples directory")
            rm(build_examples_path, force = true, recursive = true)
        end

        @info("COMPILE: Creating examples directory")
        mkdir(build_examples_path)

        @info("PSRHUB: Copying examples")
        cp(examples_path, build_examples_path, force = true)
    end

    if !isnothing(documentation_path)
        build_documentation_path = joinpath(build_path, "documentation")

        if isdir(build_documentation_path)
            @info("COMPILE: Removing documentation directory")
            rm(build_documentation_path, force = true, recursive = true)
        end

        @info("COMPILE: Creating documentation directory")
        mkdir(build_documentation_path)

        @info("PSRHUB: Copying documentation")
        cp(documentation_path, build_documentation_path, force = true)
    end

    if !isnothing(icon_path)
        @info("SETUP: Downloading rcedit")
        rcedit_url = "https://github.com/electron/rcedit/releases/download/v2.0.0/rcedit-x64.exe"
        rcedit_hash = "3e7801db1a5edbec91b49a24a094aad776cb4515488ea5a4ca2289c400eade2a"
        rcedit_path = joinpath(mktempdir(; cleanup = true), "rcedit.exe")
        @assert PlatformEngines.download_verify(rcedit_url, rcedit_hash, rcedit_path)

        @info("SETUP: Running rcedit")
        run(`$rcedit_path $target_build_path --set-icon $icon_path`)
    end

    if sign
        @info("SETUP: Signing the executable")
        sync_file_with_certificate_server(configuration, target_build_path)
    end

    return nothing
end
