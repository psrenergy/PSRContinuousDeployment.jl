@echo off

SET BASE_PATH=%~dp0

DEL /Q "%BASE_PATH%\..\Manifest.toml"

CALL julia +1.12 --project=%BASE_PATH%\.. -e "import Pkg; Pkg.test()"