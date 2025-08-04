@echo off

SET BASEPATH=%~dp0
SET JULIA=1.11.6

CALL juliaup add %JULIA%
CALL julia +%JULIA% --project=%BASEPATH% --load=%BASEPATH%\revise.jl
