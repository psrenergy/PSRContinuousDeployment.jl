@echo off

@REM Colocar variaveis de ambiente se necessário
SET FORMATTERPATH=%~dp0

%JULIA_185% --color=yes --project=%FORMATTERPATH% %FORMATTERPATH%\format.jl
