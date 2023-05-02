# Configuration file for JuliaFormatter.jl
# For more information, see: https://domluna.github.io/JuliaFormatter.jl/stable/config/

import Pkg
Pkg.instantiate()

using JuliaFormatter

src_path = joinpath(dirname(@__DIR__), "src")
result = format(src_path)
println("Formatted: ", result)
