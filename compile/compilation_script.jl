import Pkg
Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using PSRExample
# Colocar todas funções que devem ser compiladas
PSRExample.main([joinpath(dirname(@__DIR__), "test", "caso_exemplo")])
