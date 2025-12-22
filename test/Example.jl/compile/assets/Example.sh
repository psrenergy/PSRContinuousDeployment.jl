#!/bin/bash
set -e

BASE_PATH=$(dirname "$0")

unset JULIA_HOME
unset JULIA_BINDIR

"$BASE_PATH/Example" $@