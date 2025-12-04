function sync_file_with_certificate_server(configuration::Configuration, path::AbstractString = setup_exe_path(configuration))
    sync_file_with_certificate_server(
        path = path,
        certificate_server_url = configuration.certificate_server_url,
    )
    return nothing
end

function sync_file_with_certificate_server(;
    path::AbstractString,
    certificate_server_url::AbstractString,
)
    filename = upload_file_to_certificate_server(
        path = path,
        certificate_server_url = certificate_server_url,
    )
    download_file_from_server(
        path = path,
        filename = filename,
        certificate_server_url = certificate_server_url,
    )
    return nothing
end

function upload_file_to_certificate_server(;
    path::AbstractString,
    certificate_server_url::AbstractString,
    connect_timeout::Integer = CONNECT_TIMEOUT,
    connect_retries::Integer = CONNECT_RETRIES,
)
    url = "$certificate_server_url/upload"

    headers = []
    data = ["filename" => "", "file" => open(path)]
    body = HTTP.Form(data)

    t = time()
    response = HTTP.post(url, headers, body, connect_timeout = connect_timeout, retry = true, retries = connect_retries)
    @info("SETUP: Uploaded file to certificate server in $(round(time() - t, digits = 2)) seconds")

    if response.status == 200
        regex = match(r"\{\"filename\":\"(.*)\"\}", String(response))
        return String(regex[1])
    else
        throw(ErrorException("SETUP: Could not upload file to certificate server"))
    end
end

function download_file_from_server(;
    path::AbstractString,
    filename::AbstractString,
    certificate_server_url::AbstractString,
    connect_timeout::Integer = CONNECT_TIMEOUT,
    connect_retries::Integer = CONNECT_RETRIES,
)
    url = "$certificate_server_url/download/$filename"

    t = time()
    response = HTTP.get(url, connect_timeout = connect_timeout, retry = true, retries = connect_retries)
    @info("SETUP: Downloaded file from certificate server in $(round(time() - t, digits = 2)) seconds")

    if response.status == 200
        open(path, "w") do io
            write(io, response.body)
            return nothing
        end
    else
        throw(ErrorException("SETUP: Could not download file from certificate server"))
    end
end
