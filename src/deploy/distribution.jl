function deploy_to_distribution(
    configuration::Configuration,
    url::AbstractString;
    create_tag::Bool = false,
)
    target = configuration.target
    version = configuration.version
    package_path = configuration.package_path
    compile_path = configuration.compile_path
    build_path = configuration.build_path

    publish_path = joinpath(compile_path, "publish")

    sha1 = read_git_sha1(package_path)

    if isdir(publish_path)
        Log.info("DISTRIBUTION: Removing publish directory")
        rm(publish_path, force = true, recursive = true)
    end

    Log.info("DISTRIBUTION: Clonning the $url")
    run(`git clone --branch develop $url $publish_path`)

    os_path = if Sys.iswindows()
        joinpath(publish_path, "windows")
    elseif Sys.islinux()
        joinpath(publish_path, "linux")
    else
        Log.fatal_error("DISTRIBUTION: Unknown platform")
    end

    rm(os_path, force = true, recursive = true)
    mkdir(os_path)
    cp(build_path, os_path, force = true)

    Log.info("DISTRIBUTION: Updating the $url")
    cd(publish_path) do
        run(`git add --all`)

        if Sys.iswindows()
            run(`git commit -m "Windows $version ($sha1)"`)
        elseif Sys.islinux()
            run(`git commit -m "Linux $version ($sha1)"`)
        else
            Log.fatal_error("DISTRIBUTION: Unknown platform")
        end

        run(`git pull`)
        run(`git push origin --all`)
        return nothing
    end

    if create_tag
        Log.info("DISTRIBUTION: Creating tag $version")
        cd(publish_path) do
            run(`git fetch --progress --prune --force --recurse-submodules=no origin refs/heads/develop:refs/remotes/origin/develop`)
            run(`git branch --no-track release/$version refs/heads/develop`)
            run(`git checkout release/$version`)
            run(`git fetch --progress --prune --force --recurse-submodules=no origin refs/heads/master:refs/remotes/origin/master`)
            run(`git fetch --progress --prune --force --recurse-submodules=no origin refs/heads/develop:refs/remotes/origin/develop`)
            run(`git checkout --ignore-other-worktrees master`)
            run(`git merge --no-ff -m "Finish $version" release/$version`)
            run(`git tag -f $version refs/heads/master`)
            run(`git checkout --ignore-other-worktrees develop`)
            run(`git merge --no-ff -m "Finish $version" $version`)
            run(`git push --porcelain --progress --recurse-submodules=check origin refs/heads/develop:refs/heads/develop`)
            run(`git push --porcelain --progress --recurse-submodules=check origin refs/heads/master:refs/heads/master`)
            run(`git push --porcelain --progress --recurse-submodules=check origin refs/tags/$version:refs/tags/$version`)
            run(`git branch -D release/$version`)
            return nothing
        end
    end

    Log.info("DISTRIBUTION: Removing publish directory")
    rm(publish_path, force = true, recursive = true)

    Log.info("DISTRIBUTION: Success")

    return nothing
end
