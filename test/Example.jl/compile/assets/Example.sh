#!/bin/bash
set -e

BASEPATH=$(dirname "$0")

unset JULIA_HOME
unset JULIA_BINDIR

"$BASEPATH/Example" $@