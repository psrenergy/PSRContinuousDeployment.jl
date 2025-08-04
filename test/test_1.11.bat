@echo off

SET BASEPATH=%~dp0
SET JULIA=1.11

DEL /Q "%BASEPATH%\..\Manifest.toml"

CALL juliaup add %JULIA%
CALL julia +%JULIA% --project=%BASEPATH%\.. -e "import Pkg; Pkg.test()"