function initialize_aws()
    aws_access_key = ENV["AWS_ACCESS_KEY_ID"]
    aws_secret_key = ENV["AWS_SECRET_ACCESS_KEY"]

    @assert !isnothing(aws_access_key)
    @assert !isnothing(aws_secret_key)

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    return nothing
end

function models_url()
    return "https://models.psr-inc.com/"
end

function fetch_aws_key(;
    configuration::Configuration,
    filename::AbstractString,
    overwrite::Bool,
)
    target = configuration.target
    version = configuration.version

    objects = S3.list_objects_v2("psr-models", Dict("prefix" => target))
    if haskey(objects, "Contents")
        for contents in objects["Contents"]
            key = get_key(contents)

            if startswith(key, "$target/$version/")
                if endswith(key, filename)
                    if overwrite
                        Log.info("PSRMODELS: Overwriting $filename")
                        return key
                    else
                        Log.fatal_error("PSRMODELS: $filename already exists")
                    end
                else
                    Log.info("PSRMODELS: Found version $target $version")
                    _, _, hash, _ = split(key, "/")
                    return "$target/$version/$hash/$filename"
                end
            end
        end
    end

    for _ in 1:10
        hash = randstring(['a':'z'; '0':'9'], 6)
        key = "$target/$version/$hash/$filename"

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

    return nothing
end

function fetch_aws_linux_zip(configuration::Configuration)
    filename = build_zip_filename(configuration = configuration, os = :Linux)

    key = fetch_aws_key(;
        configuration = configuration,
        filename = filename,
        overwrite = false,
    )

    return models_url() * key
end