FROM amazonlinux:1

WORKDIR /model_build

RUN yum update -y && yum install -y git wget tar gcc gcc-c++ make

RUN echo "#!/bin/bash" > entrypoint.sh && \
    echo "echo \"machine github.com login psrcloud password \$GITHUB_TOKEN\" > ~/.netrc" >> entrypoint.sh && \
    echo "export JULIA_PKG_USE_CLI_GIT=true" >> entrypoint.sh && \
    echo "VERSION_LONG=\$JULIA_VERSION" >> entrypoint.sh && \
    echo "VERSION_SHORT=\$(echo \"\$VERSION_LONG\" | cut -d '.' -f 1,2)" >> entrypoint.sh && \
    echo "VERSION_ENV=\$(echo \"\$VERSION_LONG\" | sed 's/\\.//g')" >> entrypoint.sh && \
    echo "wget https://julialang-s3.julialang.org/bin/linux/x64/\$VERSION_SHORT/julia-\$VERSION_LONG-linux-x86_64.tar.gz" >> entrypoint.sh && \
    echo "tar -xvzf julia-\$VERSION_LONG-linux-x86_64.tar.gz" >> entrypoint.sh && \
    echo "export JULIA_\$VERSION_ENV=\$(pwd)/julia-\$VERSION_LONG/bin/julia" >> entrypoint.sh && \
    echo "git clone --branch \$GIT_BRANCH https://github.com/psrenergy/\$REPOSITORY.git" >> entrypoint.sh && \
    echo "cd \$REPOSITORY" >> entrypoint.sh && \
    echo "./compile/compile.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX" >> entrypoint.sh && \
    echo "./compile/publish.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX --overwrite \$OVERWRITE" >> entrypoint.sh && \
    echo "sleep 10000000000" >> entrypoint.sh

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]