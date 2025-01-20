function initialize_aws()
    aws_access_key = ENV["AWS_ACCESS_KEY_ID"]
    aws_secret_key = ENV["AWS_SECRET_ACCESS_KEY"]

    @assert !isnothing(aws_access_key)
    @assert !isnothing(aws_secret_key)

    aws_credentials = AWSCredentials(aws_access_key, aws_secret_key)
    aws_config = AWSConfig(; creds = aws_credentials, region = "us-east-1")
    global_aws_config(aws_config)

    return nothing
end