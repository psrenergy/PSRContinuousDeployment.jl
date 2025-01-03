struct Configuration
    target::String
    version::VersionNumber
    package_path::String
    compile_path::String
    build_path::String
    setup_path::String
    development_stage::DevelopmentStage.T
    certificate_server_url::String

    function Configuration(;
        target::AbstractString,
        version::AbstractString,
        package_path::AbstractString,
        compile_path::AbstractString,
        build_path::AbstractString,
        setup_path::AbstractString,
        development_stage::DevelopmentStage.T,
    )
        level = Dict("Debug Level" => "debug", "Debug" => "debug", "Info" => "info", "Warn" => "warn", "Error" => "error", "Fatal Error" => "error")
        color = Dict("Debug Level" => :normal, "Debug" => :cyan, "Info" => :cyan, "Warn" => :yellow, "Error" => :red, "Fatal Error" => :red)
        background = Dict("Debug Level" => false, "Debug" => false, "Info" => false, "Warn" => false, "Error" => false, "Fatal Error" => true)

        Log.create_polyglot_logger(
            joinpath(compile_path, "$target.log"),
            level_dict = level,
            color_dict = color,
            background_reverse_dict = background,
            # append_log = true,
        )

        return new(
            target,
            VersionNumber(version),
            package_path,
            compile_path,
            build_path,
            setup_path,
            development_stage,
            "http://hannover.local.psrservices.net:5000",
        )
    end
end

function Configuration(
    package_path::AbstractString;
    development_stage::DevelopmentStage.T,
    version_suffix::AbstractString = "",
)
    compile_path = joinpath(package_path, "compile")
    build_path = joinpath(compile_path, "build")
    setup_path = joinpath(compile_path, "setup")

    project_path = joinpath(package_path, "Project.toml")
    project = TOML.parse(read(project_path, String))
    target = project["name"]

    version = if isempty(version_suffix)
        project["version"] * string(development_stage)
    else
        project["version"] * string(development_stage) * "." * version_suffix
    end

    return Configuration(
        target = target,
        version = version,
        package_path = package_path,
        compile_path = compile_path,
        build_path = build_path,
        setup_path = setup_path,
        development_stage = development_stage,
    )
end

function is_stable_release(configuration::Configuration)
    return is_stable_release(configuration.development_stage)
end

function setup_exe(configuration::Configuration)
    target = configuration.target
    version = configuration.version

    if Sys.iswindows()
        return "$target-$version-win64.exe"
    else
        lOG.fatal_error("SETUP: Creating setup file is only supported on Windows")
    end
end

function setup_exe_path(configuration::Configuration)
    return joinpath(configuration.setup_path, setup_exe(configuration))
end
