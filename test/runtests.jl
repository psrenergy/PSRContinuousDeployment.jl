using Test
using PSRContinuousDeployment

function testall()
    package_path = raw"D:\development\psrclustering\PSRClustering.jl"
    assets_path = joinpath(package_path, "compile", "assets")

    configuration = PSRContinuousDeployment.Configuration(
        "PSRClustering",
        package_path,
    )

    # ENV["XPRESSDIR"] = ""
    # ENV["XPAUTH_PATH"] = ""
    # ENV["XPRESS_JL_NO_DEPS_ERROR"] = 1
    # ENV["XPRESS_JL_NO_AUTO_INIT"] = 1
    # ENV["XPRESS_JL_SKIP_LIB_CHECK"] = 1

    # PSRContinuousDeployment.compile(
    #     configuration,
    #     windows_additional_files_path = [
    #         joinpath(assets_path, "PSRClustering.bat"),
    #         joinpath(assets_path, "PSRClustering-pause.bat"),
    #     ],
    #     linux_additional_files_path = [
    #         joinpath(assets_path, "PSRClustering.sh"),
    #     ],
    # )

    if Sys.iswindows()
        PSRContinuousDeployment.create_setup(configuration, "2FE8D94F-A7F8-4CC3-B62C-AD4086F803F3")
    end

    return nothing
end

testall()
