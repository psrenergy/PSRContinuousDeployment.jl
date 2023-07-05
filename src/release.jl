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

    target = configuration.target
    response = HTTP.post("https://api.github.com/repos/psrenergy/$(target).jl/releases", headers, JSON.json(data))
    
    if response.status == 201
        PSRLogger.info("GITHUB: Release created successfully")
    else
        PSRLogger.fatal_error("GITHUB: Failed to create release")
    end
end