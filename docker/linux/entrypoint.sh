#!/bin/bash
set -e

# set the credentials
echo "machine github.com login psrcloud password $PERSONAL_ACCESS_TOKEN" > ~/.netrc

# clone the repository
git clone --recurse-submodules -n "$GITHUB_REPOSITORY" "model"
cd "model"
git checkout "$GITHUB_SHA"

# ensure submodules are initialized and updated
git submodule update --init --recursive

# get the julia version
JULIA_VERSION=$(grep '^julia_version\s*=' Manifest.toml | sed -E 's/^julia_version\s*=\s*"([^"]*)".*/\1/')

# setup julia
JULIA_VERSION_SHORT=$(echo "$JULIA_VERSION" | cut -d '.' -f 1,2)
JULIA_VERSION_ENV=$(echo "$JULIA_VERSION" | sed 's/\.//g')
wget -nv https://julialang-s3.julialang.org/bin/linux/x64/$JULIA_VERSION_SHORT/julia-$JULIA_VERSION-linux-x86_64.tar.gz
tar -xzf julia-$JULIA_VERSION-linux-x86_64.tar.gz
export JULIA_$JULIA_VERSION_ENV=$(pwd)/julia-$JULIA_VERSION/bin/julia

# compile and publish
export JULIA_PKG_USE_CLI_GIT=true
./compile/compile.sh --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX
./compile/publish.sh --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX --overwrite $OVERWRITE