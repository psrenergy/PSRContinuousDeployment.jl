function bundle_psrhub(
    configuration::Configuration,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString,
    psrhub_version::AbstractString;
    examples_path::Union{Nothing, AbstractString} = nothing,
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
    end

    Log.info("PSRHUB: Extracting the $psrhub_zip")
    run(`$(p7zip_jll.p7zip()) x $psrhub_zip_path -o$build_path`)

    Log.info("PSRHUB: Removing the $psrhub_zip")
    rm(psrhub_zip_path, force = true)

    Log.info("PSRHUB: Renaming psrhub.exe to $target.exe")
    mv(joinpath(build_path, "psrhub.exe"), joinpath(build_path, "$target.exe"), force = true)

    Log.info("PSRHUB: Creating $target.bat")
    open(joinpath(build_path, "$target.bat"), "w") do io
        writeln(io, "$target.exe > psrhub.log 2>&1")
        return nothing
    end

    if !isnothing(examples_path)
        Log.info("PSRHUB: Copying examples to model directory")
        copy(examples_path, build_path, "examples")
    end

    return nothing
end
