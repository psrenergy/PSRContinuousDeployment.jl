struct CompilerConfiguration
    target::String
    version::String
    package_path::String
    compile_path::String
    build_path::String
    setup_path::String

    function CompilerConfiguration(target::String, package_path::String, compile_path::String)
        level = Dict("Debug Level" => "debug", "Debug" => "debug", "Info" => "info", "Warn" => "warn", "Error" => "error", "Fatal Error" => "error")
        color = Dict("Debug Level" => :cyan, "Debug" => :cyan, "Info" => :cyan, "Warn" => :yellow, "Error" => :red, "Fatal Error" => :red)
        background = Dict("Debug Level" => false, "Debug" => false, "Info" => false, "Warn" => false, "Error" => false, "Fatal Error" => true)
    
        PSRLogger.create_psr_logger(
            joinpath(compile_path, "compile.log"),
            level_dict = level,
            color_dict = color,
            background_reverse_dict = background
        )
        
        project_path = joinpath(package_path, "Project.toml")
        project = TOML.parse(read(project_path, String))
        version = project["version"]

        build_path = joinpath(compile_path, "build")
        setup_path = joinpath(compile_path, "setup")

        return new(target, version, package_path, compile_path, build_path, setup_path)
    end
end
