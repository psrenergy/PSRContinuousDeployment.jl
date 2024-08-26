using PSRContinuousDeployment

using Test

const ID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

function testall()
    package_path = joinpath(@__DIR__, "Example.jl")
    database_path = joinpath(package_path, "database")

    configuration = PSRContinuousDeployment.Configuration(
        package_path,
        development_stage = PSRContinuousDeployment.DevelopmentStage.Alpha,
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

    return 0
end

testall()