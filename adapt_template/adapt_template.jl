using Pkg
using UUIDs

function replace_PSRExample_in_file_names(new_name::String)
    @info("Renaming files.")
    project_dir = dirname(@__DIR__)
    all_paths = String[]
    push!(all_paths, readdir(project_dir; join = true)...)
    
    while !isempty(all_paths)
        current_path = pop!(all_paths)
        if current_path == @__FILE__
            continue
        end
        if occursin(".git", current_path)
            continue
        end
        if isdir(current_path)
            push!(all_paths, readdir(current_path; join = true)...)
        end
        if isfile(current_path) 
            filename = String(split(current_path, "\\")[end])
            if occursin("PSRExample", filename)
                directory = dirname(current_path)
                ext = split(current_path, ".")[end]
                mv(current_path, joinpath(directory, new_name * ".$ext"))
            end
        end
   end
   return nothing
end

function replace_PSRExample_in_file_content(new_name::String)
    @info("Editing template contents.")
    project_dir = dirname(@__DIR__)
    all_paths = String[]
    push!(all_paths, readdir(project_dir; join = true)...)
    
    while !isempty(all_paths)
        current_path = pop!(all_paths)
        if current_path == @__FILE__
            continue
        end
        if occursin(".git", current_path)
            continue
        end
        if isdir(current_path)
            push!(all_paths, readdir(current_path; join = true)...)
        end
        if isfile(current_path) 
            (tmppath, tmpio) = mktemp()
            open(current_path) do io
                for line in eachline(io, keep=true) # keep so the new line isn't chomped
                    if occursin("PSRExample", line)
                        line = replace(line, "PSRExample" => new_name)
                    end
                    write(tmpio, line)
                end
            end
            close(tmpio)
            mv(tmppath, current_path, force=true)
        end
    end
    return nothing
end

function replace_PSRExample_uuid(new_name)
    @info("Generating new valid Project.toml uuid.")
    Pkg.generate(new_name)
    project_toml = joinpath(dirname(@__DIR__), "Project.toml")
    old_uuid = "c7da9427-fc31-47ca-9482-79f6b5cd11bc"
    new_uuid = readlines(joinpath(dirname(@__DIR__), new_name, "Project.toml"))[2][9:end-1]
    (tmppath, tmpio) = mktemp()
    open(project_toml) do io
        for line in eachline(io, keep=true) # keep so the new line isn't chomped
            if occursin(old_uuid, line)
                line = replace(line, old_uuid => new_uuid)
            end
            write(tmpio, line)
        end
    end
    close(tmpio)
    mv(tmppath, project_toml, force=true)
    rm(joinpath(dirname(@__DIR__), new_name), force = true, recursive = true)
end

@assert length(ARGS) == 1
new_name = ARGS[1]
replace_PSRExample_in_file_names(new_name)
replace_PSRExample_in_file_content(new_name)
replace_PSRExample_uuid(new_name)

@info("Success.")
@info("You can now delete the directory `adapt_template`.")