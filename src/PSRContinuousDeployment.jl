module PSRContinuousDeployment

using AWS
using PSRLogger
using PackageCompiler
using TOML

import Git
import Inno
import p7zip_jll

const git = Git.git()

@service S3

include("git.jl")
include("images.jl")
include("util.jl")
include("configuration.jl")
include("compile.jl")
include("setup.jl")

include("deploy/psrmodules.jl")
include("deploy/psrcloud.jl")
include("deploy/distribution.jl")

end
