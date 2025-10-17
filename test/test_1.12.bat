@echo off

SET BASEPATH=%~dp0

DEL /Q "%BASEPATH%\..\Manifest.toml"

SET JULIA=1.12
CALL juliaup add %JULIA%
CALL julia +%JULIA% --project=%BASEPATH%\.. -e "import Pkg; Pkg.test()"