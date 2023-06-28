function deploy_to_psrmodules(
    configuration::Configuration,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString;
    stable_release::Bool = false,
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

    if stable_release
        PSRLogger.info("DEPLOY: Downloading the $target/releases.txt")
        releases = String(S3.get_object("psr-update-modules", "$target/releases.txt"))
        releases_versions = split(replace(releases, "\r\n" => "\n"), "\n")

        releases_path = abspath("releases.txt")
        open(releases_path, "w") do f
            for releases_version in releases_versions
                if releases_version != ""
                    write(f, "$releases_version\n")

                    if releases_version == setup_zip
                        PSRLogger.fatal_error("DEPLOY: The $setup_zip already exists in the psr-update-modules bucket")
                        return nothing
                    end
                end
            end
            return write(f, "$setup_zip\n")
        end

        PSRLogger.info("DEPLOY: Uploading the $releases_path")
        S3.put_object("psr-update-modules", "$target/releases.txt", Dict("body" => read(releases_path)))

        PSRLogger.info("DEPLOY: Removing temporary files")
        rm(releases_path; force = true)
    end

    PSRLogger.info("DEPLOY: Uploading the $setup_zip")
    S3.put_object("psr-update-modules", "$target/$setup_zip", Dict("body" => read(setup_zip_path)))

    return nothing
end
