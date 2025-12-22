using PSRContinuousDeployment

using Test

const PSRHUB_VERSION = "1.0.0-alpha.11"
const SLACK_CHANNEL = "C03SSPFNTJS"
const SLACK_TOKEN = ENV["SLACK_BOT_USER_OAUTH_ACCESS_TOKEN"]

function testall()
    package_path = joinpath(@__DIR__, "Example.jl")
    assets_path = joinpath(package_path, "compile", "assets")
    database_path = joinpath(package_path, "database")
    sign = false

    configuration = build_configuration(
        package_path = package_path,
        development_stage = "release candidate",
        version_suffix = "Julia.$VERSION",
    )

    if Sys.iswindows()
        @test PSRContinuousDeployment.build_zip_filename(
            configuration = configuration,
        ) == "$(configuration.target)-$(configuration.version)-win64.zip"
    end

    @time PSRContinuousDeployment.compile(
        configuration,
        additional_files_path = [
            database_path,
        ],
        windows_additional_files_path = [
            joinpath(assets_path, "Example.bat"),
        ],
        linux_additional_files_path = [
            joinpath(assets_path, "Example.sh"),
        ],
        skip_version_jl = true,
    )

    executable_path = if Sys.iswindows()
        joinpath(configuration.build_path, "bin", "$(configuration.target).exe")
    else
        joinpath(configuration.build_path, "bin", configuration.target)
    end

    @test read(`$executable_path 10 20`, String) == "30\n200\n"

    # if Sys.iswindows()
    #     bundle_psrhub(;
    #         configuration = configuration,
    #         psrhub_version = PSRHUB_VERSION,
    #         icon_path = joinpath(assets_path, "app_icon.ico"),
    #         sign = sign,
    #     )
    # end

    # binary_path =
    #     if Sys.iswindows()
    #         create_setup(
    #             configuration,
    #             sign = sign,
    #         )
    #     else
    #         create_zip(configuration = configuration)
    #     end

    # url = deploy_to_psrmodels(
    #     configuration = configuration,
    #     path = binary_path,
    #     overwrite = true,
    # )

    # notify_slack_channel(
    #     configuration = configuration,
    #     slack_token = SLACK_TOKEN,
    #     channel = SLACK_CHANNEL,
    #     url = url,
    # )

    return 0
end

testall()
