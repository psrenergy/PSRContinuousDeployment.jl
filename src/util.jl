function remove_first_occurrence(string::AbstractString, substr::AbstractString)
    range = findfirst(substr, string)
    if isnothing(range)
        return string
    end
    return string[(range[end]+1):end]
end

function ends_with(string::AbstractString, substr::AbstractString)
    range = findlast(substr, string)
    if isnothing(range)
        return false
    end
    return range[end] == length(string)
end

function writeln(io::IO, x::String)
    write(io, x)
    write(io, Sys.iswindows() ? "\r\n" : "\n")
    return nothing
end

function write_version_jl(path::String, sha1::String, date::String, version::String)
    open(joinpath(path, "version.jl"), "w") do io
        writeln(io, "const GIT_SHA1 = \"$sha1\"")
        writeln(io, "const GIT_DATE = \"$date\"")
        writeln(io, "const PKG_VERSION = \"$version\"")
        return nothing
    end
    return nothing
end