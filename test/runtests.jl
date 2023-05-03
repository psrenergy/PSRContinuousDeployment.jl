using Test
using PSRCompiler

function testall()
    configuration = CompilerConfiguration("PSRClustering", raw"D:\development\psrclustering\PSRClustering.jl", raw"D:\development\psrclustering\PSRClustering.jl\compile")

    compile(configuration)
end

testall()
