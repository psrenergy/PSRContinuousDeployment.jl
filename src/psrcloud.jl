function prepare_psrcloud(;
    url::AbstractString,
    executables::Dict{String, String},
)
    bin_path = joinpath(mktempdir(), "bin")
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

    zip_path = mktempdir()
    zip(bin_path, joinpath(zip_path, "psrcloud.zip"))
    return zip_path
end
