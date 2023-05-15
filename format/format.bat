@echo off

SET BASEPATH=%~dp0
DEL "%BASEPATH%\Manifest.toml"

julia --color=yes --project=%BASEPATH% %BASEPATH%\format.jl