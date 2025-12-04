# https://docs.github.com/pt/rest/releases/releases?apiVersion=2022-11-28#create-a-release
function create_release(configuration::Configuration, token::AbstractString)
    headers = [
        "Accept" => "application/vnd.github+json",
        "Authorization" => "Bearer $token",
        "X-GitHub-Api-Version" => "2022-11-28",
    ]

    data = Dict(
        "tag_name" => "v$(configuration.version)",
        "generate_release_notes" => true,
        "make_latest" => "true",
    )

    owner_and_repository = configuration.owner_and_repository
    response = HTTP.post("https://api.github.com/repos/$owner_and_repository/releases", headers, JSON.json(data))

    if response.status == 201
        @info("GITHUB: Success")
    else
        throw(ErrorException("GITHUB: Failed"))
    end

    return nothing
end

function is_release_tag_available(configuration::Configuration, token::AbstractString)
    headers = [
        "Accept" => "application/vnd.github+json",
        "Authorization" => "Bearer $token",
        "X-GitHub-Api-Version" => "2022-11-28",
    ]

    owner_and_repository = configuration.owner_and_repository
    version = VersionNumber(configuration.version.major, configuration.version.minor, configuration.version.patch)

    try
        HTTP.get("https://api.github.com/repos/$owner_and_repository/releases/tags/v$version", headers)
        return false
    catch
        return true
    end
end
