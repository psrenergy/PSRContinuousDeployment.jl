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
    filename::AbstractString,
    overwrite::Bool = false,
)
    objects = S3.list_objects_v2(bucket, Dict("prefix" => target))
    if haskey(objects, "Contents")
        for contents in objects["Contents"]
            key = get_key(contents)

            if startswith(key, "$target/$version/")
                if overwrite
                    Log.info("PSRMODELS: Overwriting the $filename in the $bucket bucket")
                    return key
                else
                    Log.fatal_error("PSRMODELS: The $filename already exists in the $bucket bucket")
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

function deploy_to_psrmodels(;
    configuration::Configuration,
    path::AbstractString,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString,
    overwrite::Bool = false,
)
    bucket = "psr-models"

    target = configuration.target
    version = configuration.version

    file_name = basename(path)
    @assert isfile(path)

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    key = generate_unique_key(
        bucket = bucket,
        version = version,
        target = target,
        filename = file_name,
        overwrite = overwrite,
    )

    Log.info("PSRMODELS: Uploading $file_name")
    S3.put_object(bucket, key, Dict("body" => read(path)))

    Log.info("PSRMODELS: Success")

    return "https://models.psr-inc.com/$key"
end
