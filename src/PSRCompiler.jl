module PSRCompiler

using AWS
using Git
using PSRLogger
using PackageCompiler
using TOML

import Inno
import p7zip_jll

include("string.jl")
include("configuration.jl")
include("compile.jl")
include("setup.jl")

end
