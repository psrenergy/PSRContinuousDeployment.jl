using Test
using PSRContinuousDeployment

const ID = "2FE8D94F-A7F8-4CC3-B62C-AD4086F803F3"

function testall()
    package_path = raw"D:\development\psrnetwork\PSRNetworkReport.jl"

    configuration = PSRContinuousDeployment.Configuration(package_path)

    PSRContinuousDeployment.create_setup(configuration, ID)

    return nothing
end

testall()
