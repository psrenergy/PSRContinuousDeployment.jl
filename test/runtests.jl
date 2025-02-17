using PSRContinuousDeployment

using Test

const SLACK_CHANNEL = "C03SSPFNTJS"
const SLACK_TOKEN = ENV["SLACK_BOT_USER_OAUTH_ACCESS_TOKEN"]

function testall()
    package_path = joinpath(@__DIR__, "Example.jl")
    database_path = joinpath(package_path, "database")

    configuration = build_configuration(
        package_path = package_path,
        development_stage = "stable release",
    )

    if Sys.iswindows()
        @test PSRContinuousDeployment.build_zip_filename(
            configuration = configuration,
        ) == "$(configuration.target)-$(configuration.version)-win64.zip"
    end

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

    binary_path =
        if Sys.iswindows()
            create_setup(
                configuration,
                sign = false,
            )
        else
            create_zip(
                configuration,
            )
        end

    url = deploy_to_psrmodels(
        configuration = configuration,
        path = binary_path,
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
