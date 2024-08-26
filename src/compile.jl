function copy(source::AbstractString, destiny::AbstractString, filename::AbstractString)
    cp(joinpath(source, filename), joinpath(destiny, filename), force = true)
    return nothing
end

function compile(
    configuration::Configuration;
    executables::Vector{Pair{String, String}} = [configuration.target => "julia_main"],
    additional_files_path::Vector{String} = Vector{String}(),
    windows_additional_files_path::Vector{String} = Vector{String}(),
    linux_additional_files_path::Vector{String} = Vector{String}(),
    filter_stdlibs::Bool = true,
    include_lazy_artifacts::Bool = true,
    include_transitive_dependencies::Bool = true,
    skip_version_jl::Bool = false,
    kwargs...,
)
    target = configuration.target
    version = configuration.version
    package_path = configuration.package_path
    compile_path = configuration.compile_path
    build_path = configuration.build_path

    src_path = joinpath(package_path, "src")
    bin_path = joinpath(build_path, "bin")

    precompile_path = joinpath(compile_path, "precompile.jl")
    @assert isfile(precompile_path)

    Log.info("COMPILE: Compiling $target v$version")

    if isdir(build_path)
        Log.info("COMPILE: Removing build directory")
        rm(build_path, force = true, recursive = true)
    end

    Log.info("COMPILE: Creating build directory")
    mkdir(build_path)

    if !skip_version_jl
        Log.info("COMPILE: Creating version.jl")
        sha1 = read_git_sha1(package_path)
        date = read_git_date(package_path)
        build_date = Dates.format(Dates.now(Dates.UTC), dateformat"yyyy-mm-dd HH:MM:SS -0000")
        write_version_jl(src_path, sha1, date, version, build_date)

        free_memory = round(Int, Sys.free_memory() / 2^20)
        total_memory = round(Int, Sys.total_memory() / 2^20)
        Log.info("COMPILE: memory free $free_memory MB")
        Log.info("COMPILE: memory total $total_memory MB")
    end

        PackageCompiler.create_app(
            package_path,
            build_path,
            executables = executables,
            precompile_execution_file = precompile_path,
            incremental = false,
            filter_stdlibs = filter_stdlibs,
            force = true,
            include_lazy_artifacts = include_lazy_artifacts,
            include_transitive_dependencies = include_transitive_dependencies,
            sysimage_build_args = `--strip-metadata --strip-ir`,
            kwargs...,
        )
    if !skip_version_jl

        Log.info("COMPILE: Cleaning version.jl")
        clean_version_jl(src_path)
        
        Log.info("COMPILE: Creating $target.ver")
        open(joinpath(bin_path, "$target.ver"), "w") do io
            writeln(io, sha1)
            return nothing
        end
    end
        
    Log.info("COMPILE: Copying additional files")
    for file_path in additional_files_path
        copy(dirname(file_path), bin_path, basename(file_path))
    end

    if Sys.iswindows()
        for file_path in windows_additional_files_path
            copy(dirname(file_path), bin_path, basename(file_path))
        end
    elseif Sys.islinux()
        for file_path in linux_additional_files_path
            copy(dirname(file_path), bin_path, basename(file_path))
        end
    else
        Log.fatal_error("COMPILE: Unsupported platform")
    end

    Log.info("COMPILE: Copying Project.toml")

    open(joinpath(bin_path, "Project.toml"), "w") do io
        writeln(io, "name = \"$target\"")
        writeln(io, "version = \"$version\"")
    end

    Log.info("COMPILE: Removing julia.exe")
    rm(joinpath(bin_path, "julia.exe"), force = true)

    Log.info("COMPILE: Success")
    touch(joinpath(compile_path, "build.ok"))

    return nothing
end
