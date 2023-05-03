using Test
using PSRCompiler

function testall()
    configuration = PSRCompiler.Configuration(
        "PSRClustering", 
        raw"D:\development\psrclustering\PSRClustering.jl"
    )

    PSRCompiler.compile(configuration)
end

testall()
