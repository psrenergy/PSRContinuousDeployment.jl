import Pkg
Pkg.instantiate()

using JuliaFormatter

for folder in ["format", "revise", "src", "test"]
    format(joinpath(dirname(@__DIR__), folder))
end
