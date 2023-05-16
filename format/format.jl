import Pkg
Pkg.instantiate()

using JuliaFormatter

for _ in 1:3
    format(dirname(@__DIR__))
end

println("Done formatting")
