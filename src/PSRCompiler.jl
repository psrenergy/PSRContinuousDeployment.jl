module PSRCompiler

using AWS
using Git
using PSRLogger
using PackageCompiler
using TOML

import Inno
import p7zip_jll

@service S3

include("images.jl")
include("util.jl")
include("configuration.jl")
include("compile.jl")
include("setup.jl")
include("deploy.jl")

end
