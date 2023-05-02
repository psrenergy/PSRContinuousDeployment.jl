using Test
using PSRExample

@test PSRExample.version() == ""

include("teste_simples.jl")
include("teste_modelo_1.jl")
