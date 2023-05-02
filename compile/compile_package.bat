@echo off

SET BASEPATH=%~dp0

%JULIA_185% --project=%BASEPATH% --color=yes %BASEPATH%\compile.jl