function bundle_psrhub(
    configuration::Configuration,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString,
    psrhub_version::AbstractString,
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

    docs_path = configuration.docs_path
    if isdir(docs_path)
        docs_content = readdir(docs_path)

        distribution_docs_path = joinpath(build_path, "docs")
        if isdir(distribution_docs_path)
            Log.info("PSRHUB: Removing docs directory")
            rm(distribution_docs_path, force = true, recursive = true)
        end

        Log.info("PSRHUB: Copying content to docs directory")
        for content in docs_content
            source = joinpath(docs_path, content)
            destiny = joinpath(distribution_docs_path, content)
            mv(source, destiny, force = true)
        end
    else
        Log.warn("PSRHUB: No docs directory found. Skipping docs copy")
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

    Log.info("PSRHUB: Creating $target.bat")
    open(joinpath(build_path, "$target.bat"), "w") do io
        writeln(io, "psrhub.exe > psrhub.log 2>&1")
        return nothing
    end

    return nothing
end
