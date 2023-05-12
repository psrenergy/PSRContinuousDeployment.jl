function copy(source::AbstractString, destiny::AbstractString, filename::AbstractString)
    if isfile(joinpath(source, filename))
        cp(joinpath(source, filename), joinpath(destiny, filename), force = true)
    end
    return nothing
end

function compile(
    configuration::Configuration;
    windows_additional_files::Vector{String} = Vector{String}(),
    linux_additional_files::Vector{String} = Vector{String}(),
)
    target = configuration.target
    version = configuration.version
    package_path = configuration.package_path
    compile_path = configuration.compile_path
    build_path = configuration.build_path

    src_path = joinpath(package_path, "src")
    bin_path = joinpath(build_path, "bin")
    lib_path = if VERSION < v"1.9.0"
        joinpath(Sys.BINDIR, Base.LIBEXECDIR)
    else
        joinpath(Sys.BINDIR, Base.LIBEXECDIR, "julia")
    end 

    precompile_path = joinpath(compile_path, "precompile.jl")
    @assert isfile(precompile_path)

    if isdir(build_path)
        PSRLogger.info("COMPILE: Removing build directory")
        rm(build_path, force = true, recursive = true)
    end

    PSRLogger.info("COMPILE: Creating build directory")
    mkdir(build_path)

    PSRLogger.info("COMPILE: Creating version.jl")
    sha1 = read_git_sha1(package_path)
    date = read_git_date(package_path)
    write_version_jl(src_path, sha1, date, version)

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
        filter_stdlibs = false,
        force = true,
        include_lazy_artifacts = true,
        include_transitive_dependencies = true,
    )

    PSRLogger.info("COMPILE: Cleaning version.jl")
    write_version_jl(src_path, "xxxxxxx", "xxxx-xx-xx xx:xx:xx -xxxx", "x.x.x")

    if Sys.iswindows()
        copy(lib_path, bin_path, "7z.dll")
        copy(lib_path, bin_path, "7z.exe")

        for filename in windows_additional_files
            copy(compile_path, bin_path, filename)
        end
    elseif Sys.islinux()
        copy(lib_path, bin_path, "7z")

        for filename in linux_additional_files
            copy(compile_path, bin_path, filename)
        end
    else
        PSRLogger.fatal_error("COMPILE: Unsupported platform")
    end

    return touch(joinpath(compile_path, "build.ok"))
end
