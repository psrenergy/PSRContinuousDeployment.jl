@echo off

SET BASEPATH=%~dp0

%JULIA_190% --project=%BASEPATH%\.. -e "import Pkg; Pkg.test()"