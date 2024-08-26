using PSRContinuousDeployment

using Test

const ID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# function testall()
#     package_path = raw"D:\development\psrnetwork\PSRNetworkReport.jl"

#     configuration = PSRContinuousDeployment.Configuration(package_path)

#     # PSRContinuousDeployment.compile(configuration)
#     PSRContinuousDeployment.create_setup(configuration, ID, sign = false)

#     return nothing
# end

# testall()

include("compile_example.jl")
