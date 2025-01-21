function get_key(contents::Any)
    return contents["Key"]
end

function get_key(contents::Pair)
    return contents.second
end

function deploy_to_psrmodels(;
    configuration::Configuration,
    path::AbstractString,
    overwrite::Bool = false,
)
    initialize_aws()

    filename = basename(path)
    @assert isfile(path)

    key = fetch_aws_key(
        configuration = configuration,
        filename = filename,
        overwrite = overwrite,
    )

    Log.info("PSRMODELS: Uploading $filename")
    S3.put_object("psr-models", key, Dict("body" => read(path)))

    url = models_url() * key
    Log.info("PSRMODELS: Successfully deployed to $url")

    return url
end
