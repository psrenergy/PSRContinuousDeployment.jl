#!/bin/bash

BASEPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$JULIA_185 --project=$BASEPATH --color=yes $BASEPATH/compile.jl