
function copy(source::String, destiny::String, filename::String)
    cp(joinpath(source, filename), joinpath(destiny, filename), force = true)
    return nothing
end

function compile(configuration::Configuration; windows_additional_files::Vector{String} = Vector{String}(), linux_additional_files::Vector{String} = Vector{String}())
    target = configuration.target
    version = configuration.version
    package_path = configuration.package_path
    compile_path = configuration.compile_path
    build_path = configuration.build_path

    src_path = joinpath(package_path, "src")
    bin_path = joinpath(build_path, "bin")
    lib_path = joinpath(Sys.BINDIR, Base.LIBEXECDIR)

    precompile_path = joinpath(compile_path, "precompile.jl")
    @assert isfile(precompile_path)

    if isdir(build_path)
        PSRLogger.info("COMPILE: Removing build directory")
        rm(build_path, force = true, recursive = true)
    end

    PSRLogger.info("COMPILE: Creating build directory")
    mkdir(build_path)

    PSRLogger.info("COMPILE: Creating version.jl")
    try
        git = Git.git()
        git_path = joinpath(package_path, ".git")

        sha1 = readchomp(`$git --git-dir=$git_path rev-parse --short HEAD`)
        date = readchomp(`$git --git-dir=$git_path show -s --format=%ci HEAD`)

        open(joinpath(src_path, "version.jl"), "w") do io
            writeln(io, "const GIT_SHA1 = \"$sha1\"")
            writeln(io, "const GIT_DATE = \"$date\"")
            writeln(io, "const PKG_VERSION = \"$version\"")
            return nothing
        end
    catch
        PSRLogger.fatal_error("COMPILE: Failed to create version.jl")
    end

    ENV["XPRESSDIR"] = ""
    ENV["XPAUTH_PATH"] = ""
    ENV["XPRESS_JL_NO_DEPS_ERROR"] = 1
    ENV["XPRESS_JL_NO_AUTO_INIT"] = 1
    ENV["XPRESS_JL_SKIP_LIB_CHECK"] = 1

    PackageCompiler.create_app(
        package_path,
        build_path,
        executables = [target => "julia_main"],
        precompile_execution_file = precompile_path,
        incremental = false,
        filter_stdlibs = false, # true
        force = true,
        include_lazy_artifacts = true,
        include_transitive_dependencies = true,
    )

    PSRLogger.info("COMPILE: Cleaning version.jl")
    open(joinpath(src_path, "version.jl"), "w") do io
        writeln(io, "const GIT_SHA1 = \"xxxxxxx\"")
        writeln(io, "const GIT_DATE = \"xxxx-xx-xx xx:xx:xx -xxxx\"")
        writeln(io, "const PKG_VERSION = \"x.x.x\"")
        return nothing
    end

    if Sys.iswindows()
        copy(lib_path, bin_path, "7z.dll")
        copy(lib_path, bin_path, "7z.exe")
        copy(compile_path, bin_path, "$target.bat")

        for filename in windows_additional_files
            copy(compile_path, bin_path, filename)
        end
    elseif Sys.islinux()
        copy(lib_path, bin_path, "7z")
        copy(compile_path, bin_path, "psrclustering.sh")

        for filename in linux_additional_files
            copy(compile_path, bin_path, filename)
        end
    else
        PSRLogger.fatal_error("COMPILE: Unsupported platform")
    end

    return touch(joinpath(compile_path, "build.ok"))
end
