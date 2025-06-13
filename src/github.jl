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

    target = configuration.target
    repo_address = configuration.repository_address
    response = HTTP.post("https://api.github.com/repos/$repo_address/releases", headers, JSON.json(data))

    if response.status == 201
        Log.info("GITHUB: Success")
    else
        Log.fatal_error("GITHUB: Failed")
    end

    return nothing
end

function is_release_tag_available(configuration::Configuration, token::AbstractString)
    headers = [
        "Accept" => "application/vnd.github+json",
        "Authorization" => "Bearer $token",
        "X-GitHub-Api-Version" => "2022-11-28",
    ]

    target = configuration.target
    repo_address = configuration.repository_address
    version = VersionNumber(configuration.version.major, configuration.version.minor, configuration.version.patch)

    try
        HTTP.get("https://api.github.com/repos/$repo_address/releases/tags/v$version", headers)
        return false
    catch
        return true
    end
end
