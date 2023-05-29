function copy(source::AbstractString, destiny::AbstractString, filename::AbstractString)
    cp(joinpath(source, filename), joinpath(destiny, filename), force = true)
    return nothing
end

function compile(
    configuration::Configuration;
    windows_additional_files_path::Vector{String} = Vector{String}(),
    linux_additional_files_path::Vector{String} = Vector{String}(),
)
    target = configuration.target
    version = configuration.version
    package_path = configuration.package_path
    compile_path = configuration.compile_path
    build_path = configuration.build_path

    src_path = joinpath(package_path, "src")
    bin_path = joinpath(build_path, "bin")
    libexec_path = if VERSION < v"1.9.0"
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
    build_date = Dates.format(Dates.now(Dates.UTC), dateformat"yyyy-mm-dd HH:MM:SS -0000")
    write_version_jl(src_path, sha1, date, version, build_date)

    free_memory = round(Int, Sys.free_memory() / 2^20)
    total_memory = round(Int, Sys.total_memory() / 2^20)
    PSRLogger.info("COMPILE: memory $free_memory/$total_memory MB")

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
    clean_version_jl(src_path)

    PSRLogger.info("COMPILE: Creating $target.ver")
    open(joinpath(bin_path, "$target.ver"), "w") do io
        writeln(io, sha1)
        return nothing
    end

    if Sys.iswindows()
        copy(libexec_path, bin_path, "7z.dll")
        copy(libexec_path, bin_path, "7z.exe")

        for file_path in windows_additional_files_path
            copy(dirname(file_path), bin_path, basename(file_path))
        end
    elseif Sys.islinux()
        copy(libexec_path, bin_path, "7z")

        for file_path in linux_additional_files_path
            copy(dirname(file_path), bin_path, basename(file_path))
        end
    else
        PSRLogger.fatal_error("COMPILE: Unsupported platform")
    end

    return touch(joinpath(compile_path, "build.ok"))
end
