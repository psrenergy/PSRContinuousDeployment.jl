# https://docs.github.com/pt/rest/releases/releases?apiVersion=2022-11-28#create-a-release
function create_release(configuration::Configuration, github_key::AbstractString)
    headers = []
    data = [
        "Accept" => "application/vnd.github+json", 
        "Authorization" => "Bearer $(github_key))",
        "X-GitHub-Api-Version" => "2022-11-28"]
    body = HTTP.Form(data)
    response = HTTP.post(configuration.package_repo_api_url, headers, body)
end