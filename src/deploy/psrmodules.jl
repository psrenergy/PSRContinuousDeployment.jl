function deploy_to_psrmodules(
    configuration::Configuration,
    aws_access_key::AbstractString,
    aws_secret_key::AbstractString,
    stable_release::Bool;
    overwrite::Bool = false,
)
    bucket = "psr-update-modules"

    target = configuration.target
    version = configuration.version
    setup_path = configuration.setup_path

    setup_exe = "$target-$version-setup.exe"
    setup_exe_path = joinpath(setup_path, setup_exe)

    setup_zip = "$version.zip"
    setup_zip_path = joinpath(setup_path, setup_zip)

    Log.info("PSRMODULES: Zipping the $setup_exe")
    run(`$(p7zip_jll.p7zip()) a -tzip $setup_zip_path $setup_exe_path`)
    @assert isfile(setup_zip_path)

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    if stable_release
        Log.info("PSRMODULES: Downloading the $target/releases.txt")

        releases_versions = Vector{String}()

        objects = S3.list_objects_v2(bucket, Dict("prefix" => target))
        if haskey(objects, "Contents")
            for contents in objects["Contents"]
                key = contents["Key"]
                if key == "$target/releases.txt"
                    releases = String(S3.get_object(bucket, "$target/releases.txt"))
                    releases_versions = split(replace(releases, "\r\n" => "\n"), "\n")
                    break
                end
            end
        end

        releases_path = abspath("releases.txt")
        open(releases_path, "w") do f
            append = true
            for releases_version in releases_versions
                if releases_version != ""
                    write(f, "$releases_version\n")

                    if releases_version == setup_zip
                        if overwrite
                            append = false
                            Log.info("PSRMODULES: Overwriting the $setup_zip in the psr-update-modules bucket")
                        else
                            Log.fatal_error("PSRMODULES: The $setup_zip already exists in the psr-update-modules bucket")
                            return nothing
                        end
                    end
                end
            end
            if append
                write(f, "$setup_zip\n")
            end
            return nothing
        end

        Log.info("PSRMODULES: Uploading the $releases_path")
        S3.put_object(bucket, "$target/releases.txt", Dict("body" => read(releases_path)))

        Log.info("PSRMODULES: Removing temporary files")
        rm(releases_path; force = true)
    end

    Log.info("PSRMODULES: Uploading the $setup_zip")
    S3.put_object(bucket, "$target/$setup_zip", Dict("body" => read(setup_zip_path)))

    Log.info("PSRMODULES: Success")

    return nothing
end
