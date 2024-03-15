struct Configuration
    target::String
    version::String
    package_path::String
    compile_path::String
    build_path::String
    setup_path::String
    docs_path::String
    development_stage::DevelopmentStage.T
    certificate_server_url::String

    function Configuration(
        target::AbstractString,
        version::AbstractString,
        package_path::AbstractString,
        compile_path::AbstractString,
        build_path::AbstractString,
        setup_path::AbstractString,
        docs_path::AbstractString,
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
            version,
            package_path,
            compile_path,
            build_path,
            setup_path,
            docs_path,
            development_stage,
            "http://hannover.local.psrservices.net:5000",
        )
    end

    function Configuration(
        package_path::AbstractString;
        development_stage::DevelopmentStage.T,
        version_suffix::AbstractString = "",
    )
        compile_path = joinpath(package_path, "compile")
        build_path = joinpath(compile_path, "build")
        setup_path = joinpath(compile_path, "setup")
        docs_path = joinpath(package_path, "docs", "build")

        project_path = joinpath(package_path, "Project.toml")
        project = TOML.parse(read(project_path, String))
        target = project["name"]

        version = if isempty(version_suffix)
            project["version"] * string(development_stage)
        else
            project["version"] * string(development_stage) * "." * version_suffix            
        end

        return Configuration(
            target,
            version,
            package_path,
            compile_path,
            build_path,
            setup_path,
            docs_path,
            development_stage,
        )
    end
end

function is_stable_release(configuration::Configuration)
    return is_stable_release(configuration.development_stage)
end
