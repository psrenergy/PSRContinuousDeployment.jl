function deploy_on_psrmodules(
    configuration::Configuration,
    aws_access_key::String,
    aws_secret_key::String
)
    target = configuration.target
    version = configuration.version
    setup_path = configuration.setup_path

    setup_exe = "$target-$version-setup.exe"
    setup_exe_path = joinpath(setup_path, setup_exe)

    setup_zip = "$version.zip"
    setup_zip_path = joinpath(setup_path, setup_zip)

    PSRLogger.info("DEPLOY: Zipping the $setup_exe")
    run(`$(p7zip_jll.p7zip()) a -tzip $setup_zip_path $setup_exe_path`)
    @assert isfile(setup_zip_path)

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    result = S3.list_objects_v2("psr-update-modules", Dict("prefix" => target))

    versions = Vector{String}()
    for item in result["Contents"]
        key = remove_first_occurrence(item["Key"], "$target/")
        if ends_with(key, ".zip")
            push!(versions, key)
        end
    end
    push!(versions, version)

    releases_path = abspath("releases.txt")
    open(releases_path, "w") do f
        for version in versions
            writeln(f, "$version")
        end
    end

    PSRLogger.info("DEPLOY: Uploading the $releases_path")
    S3.put_object("psr-update-modules", "$target/releases.txt", Dict("body" => read(releases_path)))

    PSRLogger.info("DEPLOY: Uploading the $setup_zip")
    S3.put_object("psr-update-modules", "$target/$setup_zip", Dict("body" => read(setup_zip_path)))

    PSRLogger.info("DEPLOY: Removing temporary files")
    rm(releases_path; force = true)

    return nothing
end
