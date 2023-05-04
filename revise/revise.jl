import Pkg
Pkg.instantiate()

using Revise

Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using PSRContinuousDeployment
@info("""
This session is using PSRContinuousDeployment with Revise.jl.
For more information visit https://timholy.github.io/Revise.jl/stable/.
""")
