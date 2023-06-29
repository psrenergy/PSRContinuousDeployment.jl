function sign_with_certificate(server_url::String, file_path::String)
    upload_url = "$server_url/upload"

    headers = []
    data = ["filename" => "", "file" => open(file_path)]
    body = HTTP.Form(data)
    response = HTTP.post(upload_url, headers, body)
    
    if response.status == 200
        PSRLogger.info("CERTIFICATE: File upload successfully.")
        re = r"\{\"filename\":\"(.*)\"\}"
        m = match(re, String(response))
        filename = String(m[1])
        download_signed_file(server_url, filename)
    else
        PSRLogger.fatal_error("CERTIFICATE: File upload failed, response: $(response.status) - $(response.request)")
    end
end

function download_signed_file(server_url::String, filename::String)
    download_url ="$server_url/download/$filename"

    response = HTTP.get(download_url)

    if response.status == 200
        open(filename, "w") do io
            write(io, response.body)
        end
        PSRLogger.info("CERTIFICATE: File download successfully.")
    else
        PSRLogger.fatal_error("CERTIFICATE: File download failed, response: $(response.status) - $(response.request)")
    end
end
