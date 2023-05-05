function read_git_sha1(path::AbstractString)
    git_path = joinpath(path, ".git")
    return readchomp(`$git --git-dir=$git_path rev-parse --short HEAD`)
end

function read_git_date(path::AbstractString)
    git_path = joinpath(path, ".git")
    return readchomp(`$git --git-dir=$git_path show -s --format=%ci HEAD`)
end
