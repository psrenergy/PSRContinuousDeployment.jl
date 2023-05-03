

function copy(source::String, destiny::String, filename::String)
    cp(joinpath(source, filename), joinpath(destiny, filename), force = true)
    return nothing
end

function compile(configuration::CompilerConfiguration)
    target = configuration.target
    version = configuration.version
    package_path = configuration.package_path
    compile_path = configuration.compile_path
    build_path = configuration.build_path

    bin_path = joinpath(build_path, "bin")
    src_path = joinpath(package_path, "src")
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
            writeln(io, "GIT_SHA1 = \"$sha1\"")
            writeln(io, "GIT_DATE = \"$date\"")
            writeln(io, "PKG_VERSION = \"$version\"")
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
        build_path;
        executables = [target => "julia_main"],
        filter_stdlibs = false,
        incremental = false,
        include_lazy_artifacts = true,
        precompile_execution_file = precompile_path,
        force = true,
        include_transitive_dependencies = true
    )

    PSRLogger.info("COMPILE: Cleaning version.jl")
    open(joinpath(src_path, "version.jl"), "w") do io
        writeln(io, "GIT_SHA1 = \"xxxxxxx\"")
        writeln(io, "GIT_DATE = \"xxxx-xx-xx xx:xx:xx -xxxx\"")
        writeln(io, "PKG_VERSION = \"x.x.x\"")
        return nothing
    end

    if Sys.iswindows()
        copy(compile_path, bin_path, "$target.bat")
        copy(compile_path, bin_path, "$target-pause.bat")
        copy(lib_path, bin_path, "7z.dll")
        copy(lib_path, bin_path, "7z.exe")
    elseif Sys.islinux()
        copy(compile_path, bin_path, "psrclustering.sh")
        copy(lib_path, bin_path, "7z")
    else
        PSRLogger.fatal_error("COMPILE: Unsupported platform")
    end
end