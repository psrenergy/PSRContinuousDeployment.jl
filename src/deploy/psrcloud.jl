function prepare_psrcloud(
    configuration::Configuration;
    url::AbstractString,
    executables::Dict{String, String},
)
    compile_path = configuration.compile_path

    bin_path = joinpath(mktempdir(compile_path; prefix="psrcloud_bin_", cleanup=false), "bin")
    mkdir(bin_path)

    model_path = download(url)
    unzip(model_path, bin_path)

    for (executable_filename, executable_content) in executables
        executable_path = joinpath(bin_path, executable_filename)
        open(executable_path, "w") do file
            print(file, executable_content)
            return nothing
        end
    end

    chmod(bin_path, 0o755)

    zip_path = mktempdir(compile_path; prefix="psrcloud_zip_", cleanup=false)
    zip(bin_path, joinpath(zip_path, "psrcloud.zip"))
    return zip_path
end

function deploy_to_psrcloud(
    configuration::Configuration;
    model::String,
    build_id::String,
    zip_path::String,
    execution_types::Vector{String},
    groups::Vector{String},
    pycloud_version::String,        
)
    compile_path = configuration.compile_path
    version = configuration.version

    open(joinpath(compile_path, "psrcloud.py"), "w") do io
        writeln(io, "from psr.cloud import dev")
        writeln(io, "")
        writeln(io, "version = dev.Version(")
        writeln(io, "    model=\"$model\",")
        writeln(io, "    name=\"$version\",")
        writeln(io, "    execution_types=[\"$(join(execution_types, "\", \""))\"],")
        writeln(io, "    execution_types_description=[\"$(join(execution_types, "\", \""))\"],")
        writeln(io, "    build_id=\"$build_id\",")
        writeln(io, "    build_path=r\"$zip_path\",")
        writeln(io, "    groups=[\"$(join(groups, "\", \""))\"],")
        writeln(io, "    latest_version=True,")
        writeln(io, ")")
        writeln(io, "")
        writeln(io, "client = dev.DevClient(")
        writeln(io, "    cluster=\"Internal\",")
        writeln(io, "    python_client=True,")
        writeln(io, "    verbose=True,")
        writeln(io, ")")
        writeln(io, "")
        writeln(io, "client.publish_model_version(")
        writeln(io, "    version,")
        writeln(io, "    cluster_list=[\"Internal\", \"Clients-US\"],")
        writeln(io, ")")
        return nothing
    end

    open(joinpath(compile_path, "pyproject.toml"), "w") do io
        writeln(io, "[project]")
        writeln(io, "name = \"psrcloud\"")
        writeln(io, "version = \"0.1.0\"")
        writeln(io, "requires-python = \">=3.13,<3.14\"")
        writeln(io, "dependencies = [\"psr-cloud==$pycloud_version\"]")
        writeln(io, "")
        writeln(io, "[tool.uv.sources]")
        writeln(io, "psr-cloud = { git = \"https://github.com/psrenergy/pycloud.git\" }")
        return nothing
    end

    cd(compile_path) do
        cmd = `uv run psrcloud.py`
        println(cmd)
        return run(cmd)
    end
end
