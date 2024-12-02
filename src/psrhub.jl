function bundle_psrhub(
    configuration::Configuration,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString,
    psrhub_version::AbstractString;
    examples_path::Union{Nothing, AbstractString} = nothing,
    documentation_path::Union{Nothing, AbstractString} = nothing,
)
    bucket = "psr-update-modules"

    target = configuration.target
    build_path = configuration.build_path

    build_folders = readdir(build_path)

    model_path = joinpath(build_path, "model")
    if isdir(model_path)
        Log.info("PSRHUB: Removing model directory")
        rm(model_path, force = true, recursive = true)
    end

    Log.info("PSRHUB: Creating model directory")
    mkdir(model_path)

    Log.info("PSRHUB: Copying folders to model directory")
    for folder in build_folders
        source = joinpath(build_path, folder)
        destiny = joinpath(model_path, folder)
        mv(source, destiny, force = true)
    end

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    psrhub_zip = "$psrhub_version.zip"
    psrhub_zip_path = joinpath(build_path, psrhub_zip)

    Log.info("PSRHUB: Downloading the PSRHub/$psrhub_zip")

    open(psrhub_zip_path, "w") do f
        S3.get_object(bucket, "PSRHub/$psrhub_zip", Dict("response_stream" => f))
        return nothing
    end

    Log.info("PSRHUB: Extracting the $psrhub_zip")
    run(`$(p7zip_jll.p7zip()) x $psrhub_zip_path -o$build_path`)

    Log.info("PSRHUB: Removing the $psrhub_zip")
    rm(psrhub_zip_path, force = true)

    Log.info("PSRHUB: Renaming psrhub.exe to $target.exe")
    mv(joinpath(build_path, "psrhub.exe"), joinpath(build_path, "$target.exe"), force = true)

    Log.info("PSRHUB: Creating $target-debug.bat")
    open(joinpath(build_path, "$target-debug.bat"), "w") do io
        writeln(io, "$target.exe > psrhub.log 2>&1")
        return nothing
    end

    if !isnothing(examples_path)
        build_examples_path = joinpath(build_path, "examples")

        if isdir(build_examples_path)
            Log.info("COMPILE: Removing examples directory")
            rm(build_examples_path, force = true, recursive = true)
        end

        Log.info("COMPILE: Creating examples directory")
        mkdir(build_examples_path)

        Log.info("PSRHUB: Copying examples")
        cp(examples_path, build_examples_path, force = true)
    end

    if !isnothing(documentation_path)
        build_documentation_path = joinpath(build_path, "documentation")

        if isdir(build_documentation_path)
            Log.info("COMPILE: Removing documentation directory")
            rm(build_documentation_path, force = true, recursive = true)
        end

        Log.info("COMPILE: Creating documentation directory")
        mkdir(build_documentation_path)

        Log.info("PSRHUB: Copying documentation")
        cp(documentation_path, build_documentation_path, force = true)
    end

    return nothing
end
