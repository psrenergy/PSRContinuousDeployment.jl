struct Configuration
    target::String
    version::String
    package_path::String
    compile_path::String
    build_path::String
    setup_path::String

    function Configuration(target::AbstractString, package_path::AbstractString)
        compile_path = joinpath(package_path, "compile")
        build_path = joinpath(compile_path, "build")
        setup_path = joinpath(compile_path, "setup")

        level =
            Dict("Debug Level" => "debug", "Debug" => "debug", "Info" => "info", "Warn" => "warn", "Error" => "error", "Fatal Error" => "error")
        color = Dict("Debug Level" => :normal, "Debug" => :cyan, "Info" => :cyan, "Warn" => :yellow, "Error" => :red, "Fatal Error" => :red)
        background = Dict("Debug Level" => false, "Debug" => false, "Info" => false, "Warn" => false, "Error" => false, "Fatal Error" => true)

        PSRLogger.create_psr_logger(
            joinpath(compile_path, "$target.log"),
            level_dict = level,
            color_dict = color,
            background_reverse_dict = background,
            # append_log = true,
        )

        project = TOML.parse(read(joinpath(package_path, "Project.toml"), String))
        version = project["version"]

        return new(target, version, package_path, compile_path, build_path, setup_path)
    end
end
