function sync_file_with_certificate_server(configuration::Configuration, path::String)
    filename = upload_file_to_certificate_server(configuration, path)
    download_file_from_server(configuration, filename, path)
    return nothing
end

function upload_file_to_certificate_server(configuration::Configuration, path::String)
    certificate_server_url = configuration.certificate_server_url
    url = "$certificate_server_url/upload"

    headers = []
    data = ["filename" => "", "file" => open(path)]
    body = HTTP.Form(data)
    response = HTTP.post(url, headers, body)

    if response.status == 200
        re = r"\{\"filename\":\"(.*)\"\}"
        m = match(re, String(response))
        return String(m[1])
    else
        PSRLogger.fatal_error("SETUP: Could not upload file to certificate server")
    end
end

function download_file_from_server(configuration::Configuration, filename::String, path::String)
    certificate_server_url = configuration.certificate_server_url
    url ="$certificate_server_url/download/$filename"

    response = HTTP.get(url)

    if response.status == 200
        open(path, "w") do io
            write(io, response.body)
        end
    else
        PSRLogger.fatal_error("SETUP: Could not download file from certificate server")
    end
end
