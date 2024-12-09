@echo off

SET BASEPATH=%~dp0

CALL "%JULIA_1106%" --project=%BASEPATH% --load=%BASEPATH%\revise.jl
