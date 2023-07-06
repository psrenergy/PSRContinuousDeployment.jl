struct Configuration
    target::String
    version::String
    package_path::String
    compile_path::String
    build_path::String
    setup_path::String
    certificate_server_url::String

    function Configuration(
        package_path::AbstractString;
        certificate_server_url::String = "http://hannover.local.psrservices.net:5000",
    )
        compile_path = joinpath(package_path, "compile")
        build_path = joinpath(compile_path, "build")
        setup_path = joinpath(compile_path, "setup")

        project_path = joinpath(package_path, "Project.toml")
        project = TOML.parse(read(project_path, String))
        target = project["name"]
        version = project["version"]

        level = Dict("Debug Level" => "debug", "Debug" => "debug", "Info" => "info", "Warn" => "warn", "Error" => "error", "Fatal Error" => "error")
        color = Dict("Debug Level" => :normal, "Debug" => :cyan, "Info" => :cyan, "Warn" => :yellow, "Error" => :red, "Fatal Error" => :red)
        background = Dict("Debug Level" => false, "Debug" => false, "Info" => false, "Warn" => false, "Error" => false, "Fatal Error" => true)

        PSRLogger.create_psr_logger(
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
            certificate_server_url,
        )
    end
end
