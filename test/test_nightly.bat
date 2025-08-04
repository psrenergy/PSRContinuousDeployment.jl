@echo off

SET BASEPATH=%~dp0
SET JULIA=nightly

DEL /Q "%BASEPATH%\..\Manifest.toml"

CALL juliaup add %JULIA%
CALL julia +%JULIA% --project=%BASEPATH%\.. -e "import Pkg; Pkg.test()"