function deploy_on_distribution(
    configuration::Configuration,
    url::String
)
    target = configuration.target
    version = configuration.version
    package_path = configuration.package_path
    compile_path = configuration.compile_path
    build_path = configuration.build_path

    publish_path = joinpath(compile_path, "publish")

    if isdir(publish_path)
        PSRLogger.info("DISTRIBUTION: Removing publish directory")
        rm(publish_path, force = true, recursive = true)
    end

    run(`git clone --branch develop $url $publish_path`)

# cd publish
# Remove-Item -ErrorAction SilentlyContinue -Recurse -Force -Path psrclustering-distribution
# git clone --branch develop https://bitbucket.org/psr/psrclustering-distribution.git
# Copy-Item -Path .\linux\* -Destination .\psrclustering-distribution\linux -Recurse -Force
# Copy-Item -Path ..\compile\build\* -Destination .\psrclustering-distribution\windows -Recurse -Force
# cd psrclustering-distribution


# cd ..\psrio-distribution
# git add changelog.md
# git add windows\base
# git add windows\currency.units
# git add windows\definitions.units
# git add windows\locale_map.txt
# git add windows\psrio-pause.bat
# git add windows\psrio.exe
# git add windows\psrio.pmd
# git add windows\psrio.pmk
# git add windows\psrio.ver
# git commit -m "win (${{ github.sha }})"
# git pull
# git push origin --all
# cd ..\psrio

#     target = configuration.target
#     version = configuration.version
#     setup_path = configuration.setup_path

#     setup_exe = "$target-$version-setup.exe"
#     setup_exe_path = joinpath(setup_path, setup_exe)

#     setup_zip = "$version.zip"
#     setup_zip_path = joinpath(setup_path, setup_zip)

#     PSRLogger.info("DEPLOY: Zipping the $setup_exe")
#     run(`$(p7zip_jll.p7zip()) a -tzip $setup_zip_path $setup_exe_path`)
#     @assert isfile(setup_zip_path)

#     aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
#     aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
#     global_aws_config(aws_config)

#     result = S3.list_objects_v2("psr-update-modules", Dict("prefix" => target))

#     versions = Vector{String}()
#     for item in result["Contents"]
#         key = remove_first_occurrence(item["Key"], "$target/")
#         if ends_with(key, ".zip")
#             push!(versions, key)
#         end
#     end
#     push!(versions, version)

#     releases_path = abspath("releases.txt")
#     open(releases_path, "w") do f
#         for version in versions
#             write(f, "$version\n")
#         end
#     end

#     PSRLogger.info("DEPLOY: Uploading the $releases_path")
#     S3.put_object("psr-update-modules", "$target/releases.txt", Dict("body" => read(releases_path)))

#     PSRLogger.info("DEPLOY: Uploading the $setup_zip")
#     S3.put_object("psr-update-modules", "$target/$setup_zip", Dict("body" => read(setup_zip_path)))

#     PSRLogger.info("DEPLOY: Removing temporary files")
#     rm(releases_path; force = true)

    return nothing
end
