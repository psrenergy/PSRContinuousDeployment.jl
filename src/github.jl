# https://docs.github.com/pt/rest/releases/releases?apiVersion=2022-11-28#create-a-release
function create_release(configuration::Configuration, github_key::AbstractString)
    headers = [
        "Accept" => "application/vnd.github+json",
        "Authorization" => "Bearer $(github_key)",
        "X-GitHub-Api-Version" => "2022-11-28",
    ]

    data = Dict(
        "tag_name" => "v$(configuration.version)",
        "generate_release_notes" => true,
        "make_latest" => "true",
    )

    target = configuration.target
    response = HTTP.post("https://api.github.com/repos/psrenergy/$target.jl/releases", headers, JSON.json(data))

    if response.status == 201
        Log.info("GITHUB: Release created successfully")
    else
        Log.fatal_error("GITHUB: Failed to create release")
    end
end

function is_release_tag_available(configuration::Configuration, github_key::AbstractString)
    headers = [
        "Accept" => "application/vnd.github+json",
        "Authorization" => "Bearer $github_key",
        "X-GitHub-Api-Version" => "2022-11-28",
    ]

    target = configuration.target
    version = configuration.version

    try
        HTTP.get("https://api.github.com/repos/psrenergy/$target.jl/releases/tags/v$version", headers)
    catch
        return true
    end

    return false
end