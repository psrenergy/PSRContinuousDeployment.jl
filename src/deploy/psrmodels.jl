function get_key(contents::Any)
    return contents["Key"]
end

function get_key(contents::Pair)
    return contents.second
end

function generate_unique_key(;
    bucket::AbstractString,
    version::VersionNumber,
    target::AbstractString,
    setup_zip::AbstractString,
    overwrite::Bool = false,
)
    objects = S3.list_objects_v2(bucket, Dict("prefix" => target))
    if haskey(objects, "Contents")
        for contents in objects["Contents"]
            key = get_key(contents)

            if startswith(key, "$target/$version/")
                if overwrite
                    Log.info("PSRMODELS: Overwriting the $setup_zip in the $bucket bucket")
                    return key
                else
                    Log.fatal_error("PSRMODELS: The $setup_zip already exists in the $bucket bucket")
                end
            end
        end
    end

    for _ in 1:10
        hash = randstring(['a':'z'; '0':'9'], 6)
        key = "$target/$version/$hash/$setup_zip"

        objects = S3.list_objects_v2(bucket, Dict("prefix" => target))
        if haskey(objects, "Contents")
            unique = true
            for contents in objects["Contents"]
                if key == get_key(contents)
                    unique = false
                    break
                end
            end

            if unique
                Log.info("PSRMODELS: Generated a unique key: $key")
                return key
            end
        else
            return key
        end
    end

    error("Failed to generate a unique hash")
end

function deploy_to_psrmodels(;
    configuration::Configuration,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString,
    overwrite::Bool = false,
)
    bucket = "psr-models"

    target = configuration.target
    version = configuration.version
    setup_path = configuration.setup_path

    setup_exe = "$target-$version-setup.exe"
    setup_exe_path = joinpath(setup_path, setup_exe)

    setup_zip = "$target-$version.zip"
    setup_zip_path = joinpath(setup_path, setup_zip)

    Log.info("PSRMODELS: Zipping $setup_exe")
    run(`$(p7zip_jll.p7zip()) a -tzip $setup_zip_path $setup_exe_path`)
    @assert isfile(setup_zip_path)

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    key = generate_unique_key(
        bucket = bucket,
        version = version,
        target = target,
        setup_zip = setup_zip,
        overwrite = overwrite,
    )

    Log.info("PSRMODELS: Uploading $setup_zip")
    S3.put_object(bucket, key, Dict("body" => read(setup_zip_path)))

    Log.info("PSRMODELS: Success")

    return "https://models.psr-inc.com/$key"
end
