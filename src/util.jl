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

function writeln(io::IO, x::AbstractString)
    write(io, x)
    write(io, Sys.iswindows() ? "\r\n" : "\n")
    return nothing
end

function write_version_jl(
    path::AbstractString,
    sha1::AbstractString,
    date::AbstractString,
    pkg_version::AbstractString,
    pkg_build_date::AbstractString,
)
    open(joinpath(path, "version.jl"), "w") do io
        writeln(io, "const GIT_SHA1 = \"$sha1\"")
        writeln(io, "const GIT_DATE = \"$date\"")
        writeln(io, "const PKG_VERSION = \"$pkg_version\"")
        writeln(io, "const PKG_BUILD_DATE = \"$pkg_build_date\"")
        return nothing
    end
    return nothing
end

function clean_version_jl(path::AbstractString)
    write_version_jl(path, "xxxxxxx", "xxxx-xx-xx xx:xx:xx -xxxx", "x.x.x", "xxxx-xx-xx xx:xx:xx -xxxx")
    return nothing
end
