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

    PSRLogger.info("DISTRIBUTION: Clonning the $url")
    run(`git clone --branch develop $url $publish_path`)

    os_path = if Sys.iswindows()
        joinpath(publish_path, "windows")
    elseif Sys.islinux()
        joinpath(publish_path, "linux")
    else
        PSRLogger.fatal_error("DISTRIBUTION: Unknown platform")
    end

    rm(os_path, force = true, recursive = true)
    mkdir(os_path)
    cp(build_path, os_path, force = true)

    PSRLogger.info("DISTRIBUTION: Updating the $url")
    cd(publish_path) do
        run(`git add --all`)
        run(`git commit -m "Update $target to $version"`)
        run(`git pull`)
        run(`git push origin --all`)
    end

    PSRLogger.info("DISTRIBUTION: Removing publish directory")
    rm(publish_path, force = true, recursive = true)

    PSRLogger.info("DISTRIBUTION: distribution deployed successfully")

    return nothing
end
