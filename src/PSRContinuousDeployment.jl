module PSRContinuousDeployment

using AWS
using Dates
using HTTP
using JSON
using PackageCompiler
using Pkg.PlatformEngines
using SlackAPI
using TOML

import Git
import LoggingPolyglot as Log
import p7zip_jll

const git = Git.git()
const CONNECT_TIMEOUT = 120
const CONNECT_RETRIES = 8

@service S3

include("git.jl")
include("images.jl")
include("util.jl")
include("configuration.jl")
include("compile.jl")
include("github.jl")
include("sign.jl")
include("slack.jl")
include("setup.jl")
include("testrunner.jl")

include("deploy/psrmodules.jl")
include("deploy/psrcloud.jl")
include("deploy/distribution.jl")

end
