import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

import Git
import PackageCompiler

const git = Git.git()
const COMPILE_DIR = @__DIR__
const PSRExample_DIR = dirname(COMPILE_DIR)
const BUILD_DIR = joinpath(COMPILE_DIR, "builddir")

@info("COMPILE-PSRExample: Creating build dir")
if isdir(BUILD_DIR)
    rm(BUILD_DIR; force = true, recursive = true)
end
mkdir(BUILD_DIR)

@info "COMPILE-PSRExample: Set version hash"
cd(PSRExample_DIR) do
    try
        ver = readchomp(`$git rev-parse --short HEAD`)
        open(joinpath(PSRExample_DIR, "src", "version.jl"), "w") do io
            write(io, "const _VERSION = \"$(ver)\"")
        end
    catch
        @warn "Could not run git rev-parse --short HEAD"
    end
end

@info "COMPILE-PSRExample: Starting PackageCompiler create_app function"
PackageCompiler.create_app(
    PSRExample_DIR,
    joinpath(BUILD_DIR, "PSRExample");
    executables = ["PSRExample" => "julia_main"],
    filter_stdlibs = true,
    incremental = false,
    include_lazy_artifacts = true,
    precompile_execution_file = joinpath(COMPILE_DIR, "compilation_script.jl"),
    force = true,
    include_transitive_dependencies = false
)

@info "COMPILE-PSRExample: Cleaning version file"
open(joinpath(PSRExample_DIR, "src", "version.jl"), "w") do io
    write(io, "const _VERSION = \"\"")
end

@info("COMPILE-PSRExample: Copying calling script")
if Sys.iswindows()
    cp(
        joinpath(COMPILE_DIR, "PSRExample.bat"),
        joinpath(BUILD_DIR, "PSRExample", "bin", "PSRExample.bat");
        force = true,
    )
elseif Sys.islinux()
    cp(
        joinpath(COMPILE_DIR, "PSRExample.sh"),
        joinpath(BUILD_DIR, "PSRExample", "bin", "PSRExample.sh");
        force = true,
    )
end

@info "COMPILE-PSRExample: Touch build.ok"
touch(joinpath(COMPILE_DIR, "build.ok"))

@info "COMPILE-PSRExample: Build Success"
