using Test
using PSRCompiler

function testall()
    configuration = PSRCompiler.Configuration("PSRClustering", raw"D:\development\psrclustering\PSRClustering.jl")

    PSRCompiler.compile(configuration)

    if Sys.iswindows()
        PSRCompiler.setup(configuration, "2FE8D94F-A7F8-4CC3-B62C-AD4086F803F3")

        aws_access_key = ENV["AWS_ACCESS_KEY_ID"]
        aws_secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
        # PSRCompiler.deploy_on_psrmodules(configuration, aws_access_key, aws_secret_key)
    end

    return nothing
end

testall()
