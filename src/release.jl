# https://docs.github.com/pt/rest/releases/releases?apiVersion=2022-11-28#create-a-release
function create_release(configuration::Configuration, github_key::AbstractString)
    headers = [
        "Accept" => "application/vnd.github+json", 
        "Authorization" => "Bearer $(github_key)",
        "X-GitHub-Api-Version" => "2022-11-28"]
    data = Dict(
        "tag_name" => "v$(configuration.version)",
        "generate-release-notes" => true,
    )
    response = HTTP.post(configuration.package_repo_api_url, headers, JSON.json(data))
    if response.status == 201
        PSRLogger.info("Release created successfully")
    else
        PSRLogger.error("Error creating release")
        PSRLogger.error(response)
    end
end