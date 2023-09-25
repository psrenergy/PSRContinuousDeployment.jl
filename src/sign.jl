function sync_file_with_certificate_server(configuration::Configuration)
    filename = upload_file_to_certificate_server(configuration)
    download_file_from_server(configuration, filename)
    return nothing
end

function upload_file_to_certificate_server(
    configuration::Configuration;
    connect_timeout::Integer = CONNECT_TIMEOUT,
    connect_retries::Integer = CONNECT_RETRIES
)
    target = configuration.target
    version = configuration.version
    setup_exe_path = joinpath(configuration.setup_path, "$target-$version-setup.exe")

    certificate_server_url = configuration.certificate_server_url
    url = "$certificate_server_url/upload"

    headers = []
    data = ["filename" => "", "file" => open(setup_exe_path)]
    body = HTTP.Form(data)

    t = time()
    response = HTTP.post(url, headers, body, connect_timeout = connect_timeout, retry = true, retries = connect_retries)
    Log.info("SETUP: Uploaded file to certificate server in $(time() - t) seconds")

    if response.status == 200
        regex = match(r"\{\"filename\":\"(.*)\"\}", String(response))
        return String(regex[1])
    else
        Log.fatal_error("SETUP: Could not upload file to certificate server")
    end
end

function download_file_from_server(
    configuration::Configuration,
    filename::AbstractString;
    connect_timeout::Integer = CONNECT_TIMEOUT,
    connect_retries::Integer = CONNECT_RETRIES
)
    target = configuration.target
    version = configuration.version
    setup_exe_path = joinpath(configuration.setup_path, "$target-$version-setup.exe")

    certificate_server_url = configuration.certificate_server_url
    url ="$certificate_server_url/download/$filename"

    t = time()
    response = HTTP.get(url, connect_timeout = connect_timeout, retry = true, retries = connect_retries)
    Log.info("SETUP: Downloaded file from certificate server in $(time() - t) seconds")

    if response.status == 200
        open(setup_exe_path, "w") do io
            write(io, response.body)
        end
    else
        Log.fatal_error("SETUP: Could not download file from certificate server")
    end
end
