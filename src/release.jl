# https://docs.github.com/pt/rest/releases/releases?apiVersion=2022-11-28#create-a-release
function create_release(configuration::Configuration, github_key::AbstractString)
    headers = [
        "Accept" => "application/vnd.github+json", 
        "Authorization" => "Bearer $(github_key)",
        "X-GitHub-Api-Version" => "2022-11-28",
    ]

    data = Dict(
        "tag_name" => "v$(configuration.version)",
        "generate-release-notes" => true,
    )

    if check_release_version(configuration, configuration.version, github_key)
        PSRLogger.info("Release version already exists")
        return
    end

    target = configuration.target
    response = HTTP.post("https://api.github.com/repos/psrenergy/$(target).jl/releases", headers, JSON.json(data))
    
    if response.status == 201
        PSRLogger.info("GITHUB: Release created successfully")
    else
        PSRLogger.fatal_error("GITHUB: Failed to create release")
    end
end


function check_release_version(configuration::Configuration, tag_name::String, github_key::AbstractString)
    tag_name = tag_name[1] == 'v' ? tag_name : "v$tag_name"
    
    headers = [
        "Accept" => "application/vnd.github+json", 
        "Authorization" => "Bearer $(github_key)",
        "X-GitHub-Api-Version" => "2022-11-28"]

    target = configuration.target
    response = HTTP.get("https://api.github.com/repos/psrenergy/$(target).jl/releases", headers)

    if response.status == 200
        re = r"\"tag_name\":\"(v[0-9]+\.[0-9]+\.[0-9]+)\""
        m = match(re, String(response))
        version_tag = String(m[1])
    else
        PSRLogger.fatal_error("Error checking version")
        PSRLogger.fatal_error(response)
    end
    if version_tag == tag_name
        return true
    else
        return false
    end
end