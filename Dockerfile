FROM amazonlinux:1

WORKDIR /model_build

RUN yum update -y
RUN yum install wget tar -y
RUN yum groupinstall "Development Tools" -y
RUN yum remove libstdc++-devel -y
RUN yum install libstdc++-devel -y

RUN echo "#!/bin/bash" > entrypoint.sh && \
    echo "echo \"machine github.com login psrcloud password \$GITHUB_TOKEN\" > ~/.netrc" >> entrypoint.sh && \
    echo "export JULIA_PKG_USE_CLI_GIT=true" >> entrypoint.sh && \
    echo "JULIA_VERSION_SHORT=\$(echo \"\$JULIA_VERSION\" | cut -d '.' -f 1,2)" >> entrypoint.sh && \
    echo "JULIA_VERSION_ENV=\$(echo \"\$JULIA_VERSION\" | sed 's/\\.//g')" >> entrypoint.sh && \
    echo "wget https://julialang-s3.julialang.org/bin/linux/x64/\$JULIA_VERSION_SHORT/julia-\$JULIA_VERSION-linux-x86_64.tar.gz" >> entrypoint.sh && \
    echo "tar -xvzf julia-\$JULIA_VERSION-linux-x86_64.tar.gz" >> entrypoint.sh && \
    echo "export JULIA_\$JULIA_VERSION_ENV=\$(pwd)/julia-\$JULIA_VERSION/bin/julia" >> entrypoint.sh && \
    echo "git clone --branch \$GIT_BRANCH https://github.com/psrenergy/\$REPOSITORY.git" >> entrypoint.sh && \
    echo "cd \$REPOSITORY" >> entrypoint.sh && \
    echo "./compile/compile.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX" >> entrypoint.sh && \
    echo "./compile/publish.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX --overwrite \$OVERWRITE" >> entrypoint.sh

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]