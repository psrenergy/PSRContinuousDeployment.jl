function deploy(configuration::Configuration, aws_access_key::String, aws_secret_key::String)
    target = configuration.target
    version = configuration.version
    setup_path = configuration.setup_path

    setup_exe = "$target-$version-setup.exe"
    setup_exe_path = joinpath(setup_path, setup_exe)

    setup_zip = "$version.zip"
    setup_zip_path = joinpath(setup_path, setup_zip)

    run(`$(p7zip_jll.p7zip()) a -tzip $setup_zip_path $setup_exe_path`)

    @assert isfile(setup_zip_path)

    @info "Sending the $version to psrcore-update-modules S3 bucket"

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    result = S3.list_objects_v2("psr-update-modules", Dict("prefix" => module_name))

    versions = Vector{String}()
    for item in result["Contents"]
        key = remove_first_occurrence(item["Key"], "$module_name/")
        if ends_with(key, ".zip")
            push!(versions, key)
        end
    end
    push!(versions, version)

    releases_path = abspath("releases.txt")
    open(releases_path, "w") do f
        for version in versions
            write(f, "$version\n")
        end
    end

    S3.put_object(
        "psr-update-modules",
        "$module_name/releases.txt",
        Dict(
            "body" => read(releases_path),
        ),
    )

    rm(releases_path; force = true)

    S3.put_object(
        "psr-update-modules",
        "$module_name/$setup_zip",
        Dict(
            "body" => read(setup_zip_path),
        ),
    )

    return nothing
end
