function sign_with_certificate(file_path::String)
    url = join([CERTIFICATE_SERVER_URL, "upload"])
    headers = []
    data = ["filename" => "", "file" => open(file_path)]
    body = HTTP.Form(data)
    response = HTTP.post(url, headers, body)
    if response.status == 200
        PSRLogger.info("File upload successfully.")
        re = r"\{\"filename\":\"(.*)\"\}"
        m = match(re, String(response))
        filename = String(m[1])
        download_signed_file(filename)
    else
        PSRLogger.fatal_error("File upload failed. Response:\n$(response.status) \n$(response.request)")
    end
end

function download_signed_file(filename::String)
    url = join([CERTIFICATE_SERVER_URL, "download/", filename])
    response = HTTP.get(url)
    if response.status == 200
        open(filename, "w") do io
            write(io, response.body)
        end
        PSRLogger.info("File download successfully.")
    else
        PSRLogger.fatal_error("File download failed. Response:\n$(response.status) \n$(response.request)")
    end
end
