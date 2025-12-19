@echo off

SET BASE_PATH=%~dp0

CALL julia +1.12.3 --project=%BASE_PATH% --load=%BASE_PATH%\revise.jl
