@echo off

SET BASEPATH=%~dp0

%JULIA_191% --project=%BASEPATH%\.. -e "import Pkg; Pkg.test()"