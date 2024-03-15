@echo off

SET BASEPATH=%~dp0
DEL "%BASEPATH%\Manifest.toml"

%JULIA_191% --color=yes --project=%BASEPATH% %BASEPATH%\format.jl
