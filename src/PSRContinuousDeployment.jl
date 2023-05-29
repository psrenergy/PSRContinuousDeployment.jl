module PSRContinuousDeployment

using AWS
using Dates
using PSRLogger
using PackageCompiler
using TOML

import Git
import p7zip_jll

if Sys.iswindows()
    import Inno
end

const git = Git.git()

@service S3

include("git.jl")
include("images.jl")
include("util.jl")
include("configuration.jl")
include("compile.jl")
include("setup.jl")
include("testrunner.jl")

include("deploy/psrmodules.jl")
include("deploy/psrcloud.jl")
include("deploy/distribution.jl")

end
