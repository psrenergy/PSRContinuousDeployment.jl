FROM amazonlinux:1

WORKDIR /model_build

RUN yum update -y && yum install -y git wget tar

RUN echo "#!/bin/bash" > entrypoint.sh \
    && echo "echo \"machine github.com login psrcloud password \$GITHUB_TOKEN\" > ~/.netrc" >> entrypoint.sh \
    && echo "wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.6-linux-x86_64.tar.gz" >> entrypoint.sh \
    && echo "tar -xvzf julia-1.10.6-linux-x86_64.tar.gz" >> entrypoint.sh \
    && echo "export JULIA_1106=$(pwd)/julia-1.10.6/bin/julia" >> entrypoint.sh \ 
    && echo "git clone --branch \$GIT_BRANCH https://\$GITHUB_TOKEN@github.com/psrenergy/\$REPOSITORY.git" >> entrypoint.sh \
    && echo "cd \$REPOSITORY" >> entrypoint.sh \
    && echo "./compile/compile.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX" >> entrypoint.sh \
    && echo "./compile/publish.sh --development_stage \$DEVELOPMENT_STAGE --version_suffix \$VERSION_SUFFIX --overwrite \$OVERWRITE" >> entrypoint.sh

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]