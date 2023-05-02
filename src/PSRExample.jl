module PSRExample

using ArgParse
using JuMP
using HiGHS
using PSRClassesInterface

# Std libs usadas
using Libdl
using LinearAlgebra
using Random
using Statistics

# constantes do módulo
const A = 1
const PSRI = PSRClassesInterface

# initializations
function initialize()
    return nothing
end

include("version.jl")

function version()
    return _VERSION
end

# includes de arquivos
include("modelo_1.jl")
include("main.jl")

end # module
