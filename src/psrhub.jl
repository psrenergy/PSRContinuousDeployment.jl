function bundle_psrhub(
    configuration::Configuration,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString,
    version::AbstractString,
)
    bucket = "psr-update-modules"

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

    psrhub_zip = "$version.zip"
    psrhub_zip_path = joinpath(build_path, psrhub_zip)

    Log.info("PSRHUB: Downloading the PSRHub/$psrhub_zip")

    open(psrhub_zip_path, "w") do f
        S3.get_object(bucket, "PSRHub/$psrhub_zip", Dict("response_stream" => f))
    end

    Log.info("PSRHUB: Extracting the $psrhub_zip")
    run(`$(p7zip_jll.p7zip()) x $psrhub_zip_path -o$build_path`)

    Log.info("PSRHUB: Removing the $psrhub_zip")
    rm(psrhub_zip_path, force = true)

    return nothing
end
