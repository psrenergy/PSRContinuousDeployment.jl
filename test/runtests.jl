using Test
using PSRContinuousDeployment

function testall()
    package_path = raw"D:\development\psrnetwork\PSRNetworkReport.jl"

    configuration = PSRContinuousDeployment.Configuration(package_path)

    PSRContinuousDeployment.upload_file_to_certificate_server(configuration)

    return nothing
end

testall()
