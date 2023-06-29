@echo off

SET BASEPATH=%~dp0

%JULIA_191% --color=yes --project=%BASEPATH% --load=%BASEPATH%\revise.jl
