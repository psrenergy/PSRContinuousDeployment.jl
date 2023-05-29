using Test
using PSRContinuousDeployment

function testall()
    configuration = PSRContinuousDeployment.Configuration("PSRClustering", raw"D:\development\psrclustering\PSRClustering.jl")

    ENV["XPRESSDIR"] = ""
    ENV["XPAUTH_PATH"] = ""
    ENV["XPRESS_JL_NO_DEPS_ERROR"] = 1
    ENV["XPRESS_JL_NO_AUTO_INIT"] = 1
    ENV["XPRESS_JL_SKIP_LIB_CHECK"] = 1

    PSRContinuousDeployment.compile(configuration)

    # if Sys.iswindows()
    #     PSRContinuousDeployment.create_setup(configuration, "2FE8D94F-A7F8-4CC3-B62C-AD4086F803F3")

    #     aws_access_key = ENV["AWS_ACCESS_KEY_ID"]
    #     aws_secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
    #     PSRContinuousDeployment.deploy_to_psrmodules(configuration, aws_access_key, aws_secret_key)

    #     PSRContinuousDeployment.deploy_to_distribution(configuration, raw"https://bitbucket.org/psr/psrclustering-distribution.git")
    # end

    return nothing
end

testall()
