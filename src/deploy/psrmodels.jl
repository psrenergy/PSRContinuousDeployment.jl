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

function deploy_to_psrmodels(;
    configuration::Configuration,
    path::AbstractString,
    overwrite::Bool = false,
)
    initialize_aws()

    bucket = "psr-models"

    target = configuration.target
    version = configuration.version

    filename = basename(path)
    @assert isfile(path)

    key = generate_unique_key(
        bucket = bucket,
        version = version,
        target = target,
        filename = filename,
        overwrite = overwrite,
    )

    Log.info("PSRMODELS: Uploading $filename")
    S3.put_object(bucket, key, Dict("body" => read(path)))

    Log.info("PSRMODELS: Success")

    return "https://models.psr-inc.com/$key"
end
