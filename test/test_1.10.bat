@echo off

SET BASEPATH=%~dp0

DEL /Q "%BASEPATH%\..\Manifest.toml"

CALL "%JULIA_1107%" --project=%BASEPATH%\.. -e "import Pkg; Pkg.test()"