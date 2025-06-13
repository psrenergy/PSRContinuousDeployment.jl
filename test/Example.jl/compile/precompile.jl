import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Example

Example.main(["2", "3"])
