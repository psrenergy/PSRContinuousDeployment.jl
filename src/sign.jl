using HTTP

SERVER_URL   = "http://hannover.local.psrservices.net:5000/"

function upload_file(file_path::String)
    url = join([SERVER_URL,"upload"])
    headers = []
    data = ["filename" => "", "file" => open(file_path)]
    body = HTTP.Form(data)
    response = HTTP.post(url, headers, body)
    if response.status == 200
        println("File upload successfully.")
        re = r"\{\"filename\":\"(.*)\"\}"
        m = match(re,String(response))
        filename = String(m[1])
        download_file(filename)
    else
        println("File upload failed. Response:")
        println(response.status)
        println(response.request)
    end
end

function download_file(filename::String)
    url = join([SERVER_URL,"download/",filename])
    response = HTTP.get(url)
    if response.status == 200
        open(filename, "w") do io
            write(io, response.body)
        end
        println("File download successfully.")
    else
        println("File download failed. Response:")
        println(response.status)
        println(response.request)
    end
end