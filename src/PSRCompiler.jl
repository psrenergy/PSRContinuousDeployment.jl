module PSRCompiler

using AWS
using PSRLogger
using PackageCompiler
using TOML

import Git
import Inno
import p7zip_jll

const git = Git.git()

@service S3

include("images.jl")
include("util.jl")
include("configuration.jl")
include("compile.jl")
include("setup.jl")
include("psrmodules.jl")
include("psrcloud.jl")
include("distribution.jl")

end
