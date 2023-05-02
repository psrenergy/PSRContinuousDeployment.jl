#!/bin/bash

BASE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$JULIA_185 --color=yes --project=$BASE_PATH $BASE_PATH/main.jl $@