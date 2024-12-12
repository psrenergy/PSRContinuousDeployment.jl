module PSRContinuousDeployment

using AWS
using Base: parse, string
using Dates
using EnumX
using HTTP
using JSON
using PackageCompiler
using Pkg.PlatformEngines
using Random
using SlackAPI
using TOML
using UUIDs

import Git
import LoggingPolyglot as Log
import p7zip_jll

const git = Git.git()
const CONNECT_TIMEOUT = 120
const CONNECT_RETRIES = 8

export Configuration,
    DevelopmentStage,
    is_stable_release,
    is_release_tag_available,
    bundle_psrhub,
    create_setup,
    deploy_to_psrmodels,
    deploy_to_psrmodules,
    notify_slack_channel,
    create_release

@service S3

include("development_stage.jl")
include("git.jl")
include("images.jl")
include("util.jl")
include("configuration.jl")
include("compile.jl")
include("github.jl")
include("psrhub.jl")
include("sign.jl")
include("slack.jl")
include("setup.jl")

include("deploy/psrmodels.jl")
include("deploy/psrmodules.jl")
include("deploy/distribution.jl")

end
