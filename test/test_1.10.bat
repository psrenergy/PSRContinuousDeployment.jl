@echo off

SET BASEPATH=%~dp0

DEL /Q "%BASEPATH%\..\Manifest.toml"

CALL julia +1.10 --project=%BASEPATH%\.. -e "import Pkg; Pkg.test()"