@echo off

@REM Colocar variaveis de ambiente se necessário
SET BASEPATH=%~dp0

%JULIA_185% --color=yes --project=%BASEPATH% %BASEPATH%\main.jl %*