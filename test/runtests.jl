using PSRContinuousDeployment

using Test

const SLACK_CHANNEL = "C03SSPFNTJS"

const AWS_ACCESS = ENV["AWS_ACCESS_KEY_ID"]
const AWS_SECRET = ENV["AWS_SECRET_ACCESS_KEY"]
const SLACK_TOKEN = ENV["SLACK_BOT_USER_OAUTH_ACCESS_TOKEN"]

function testall()
    package_path = joinpath(@__DIR__, "Example.jl")
    database_path = joinpath(package_path, "database")

    configuration = PSRContinuousDeployment.Configuration(
        package_path,
        development_stage = PSRContinuousDeployment.DevelopmentStage.StableRelease,
    )

    PSRContinuousDeployment.compile(
        configuration,
        additional_files_path = [
            database_path,
        ],
        windows_additional_files_path = [
            joinpath(package_path, "Example.bat"),
        ],
        skip_version_jl = true,
    )

    binary_path = create_setup(
        configuration,
        sign = false,
    )

    url = deploy_to_psrmodels(
        configuration = configuration,
        path = binary_path,
        aws_access_key = AWS_ACCESS,
        aws_secret_key = AWS_SECRET,
        overwrite = true,
    )

    notify_slack_channel(
        configuration = configuration,
        slack_token = SLACK_TOKEN,
        channel = SLACK_CHANNEL,
        url = url,
    )

    return 0
end

testall()
