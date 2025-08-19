# PSRContinuousDeployment.jl

[![CI](https://github.com/psrenergy/PSRContinuousDeployment.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/psrenergy/PSRContinuousDeployment.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/psrenergy/PSRContinuousDeployment.jl/graph/badge.svg?token=L4P1AI32UH)](https://codecov.io/gh/psrenergy/PSRContinuousDeployment.jl)


- `rm lib/julia/libLLVM*`
- `rm lib/julia/libjulia-codegen*`
- `strip lib/*.so*`
- `strip lib/julia/*.so*`
- `--strip-metadata`
- `--strip-ir + --compile=all`
- `cpu_target = "" (see help)`