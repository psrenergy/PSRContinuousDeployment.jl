module PSRPackageCompiler

using Git
using PSRLogger
using PackageCompiler
using TOML

import Inno
import p7zip_jll

export CompilerConfiguration, compile

include("string.jl")
include("configuration.jl")
include("compiler.jl")
include("setup.jl")

end
