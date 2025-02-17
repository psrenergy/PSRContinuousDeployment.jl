FROM amazonlinux:1

WORKDIR /model_build

RUN yum update -y && \
    yum install wget tar -y && \
    yum groupinstall "Development Tools" -y && \
    yum remove libstdc++-devel -y && \
    yum install libstdc++-devel -y

RUN echo "#!/bin/bash" > entrypoint.sh && \
    echo "set -e" >> entrypoint.sh && \
    # set credentials
    echo "echo \"machine github.com login psrcloud password \$PERSONAL_ACCESS_TOKEN\" > ~/.netrc" >> entrypoint.sh && \
    # clone the repository
    echo "repository=\$(basename \"\$GITHUB_REPOSITORY\" .git)" >> entrypoint.sh && \
    echo "git clone -n \"\$GITHUB_REPOSITORY\" \"\$repository\"" >> entrypoint.sh && \
    echo "cd \"\$repository\"" >> entrypoint.sh && \
    echo "git checkout \"\$GITHUB_SHA\"" >> entrypoint.sh && \
    # get the julia version
    echo "JULIA_VERSION=\$(grep '^julia_version\\s*=' Manifest.toml | sed -E 's/^julia_version\\s*=\\s*\"([^\"]*)\".*/\\1/')" >> entrypoint.sh && \
    # setup julia
    echo "JULIA_VERSION_SHORT=\$(echo \"\$JULIA_VERSION\" | cut -d '.' -f 1,2)" >> entrypoint.sh && \
    echo "JULIA_VERSION_ENV=\$(echo \"\$JULIA_VERSION\" | sed 's/\\.//g')" >> entrypoint.sh && \
    echo "wget -nv https://julialang-s3.julialang.org/bin/linux/x64/\$JULIA_VERSION_SHORT/julia-\$JULIA_VERSION-linux-x86_64.tar.gz" >> entrypoint.sh && \
    echo "tar -xzf julia-\$JULIA_VERSION-linux-x86_64.tar.gz" >> entrypoint.sh && \
    echo "export JULIA_\$JULIA_VERSION_ENV=\$(pwd)/julia-\$JULIA_VERSION/bin/julia" >> entrypoint.sh && \
    echo "export JULIA_PKG_USE_CLI_GIT=true" >> entrypoint.sh && \
    # compile and publish
    echo "./compile/compile.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX" >> entrypoint.sh && \
    echo "./compile/publish.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX --overwrite \$OVERWRITE" >> entrypoint.sh

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]