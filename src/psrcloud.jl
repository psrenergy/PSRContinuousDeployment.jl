function prepare_psrcloud(;
    url::AbstractString,
    executables::Dict{String, String},
)
    bin_path = joinpath(mktempdir(), "bin")
    mkdir(bin_path)

    model_path = download(url)
    unzip(model_path, bin_path)

    for (executable_filename, executable_content) in executables
        open(joinpath(bin_path, executable_filename), "w") do file
            print(file, executable_content)
        end
    end

    zip_path = joinpath(mktempdir(), randstring(8) * ".zip")
    zip(bin_path, zip_path)

    return zip_path
end