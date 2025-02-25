FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.39.1.windows.1/Git-2.39.1-64-bit.exe" -OutFile "Git-Installer.exe" ; \
    Start-Process -Wait -FilePath "Git-Installer.exe" -ArgumentList "/VERYSILENT", "/NORESTART" ; \
    Remove-Item -Force "Git-Installer.exe"

RUN echo 'echo "machine github.com login psrcloud password $PERSONAL_ACCESS_TOKEN" > ~/_netrc' > entrypoint.sh; \
    # clone the repository
    echo '$repository = (sp -Leaf $env:GITHUB_REPOSITORY) -replace \"\.git$\", \"\"' >> entrypoint.sh; \
    echo 'git clone -n $GITHUB_REPOSITORY $repository' >> entrypoint.sh; \
    echo 'cd $env:repository' >> entrypoint.sh; \
    echo 'git checkout $env:GITHUB_SHA' >> entrypoint.sh; \
    # get the julia version
    echo '$JULIA_VERSION = (Select-String -Path "Manifest.toml" -Pattern \"s/^julia_version\\s*=\\s*\"([^\"]*)\".*/\\1/\" | ForEach-Object { $_.Matches.Groups[1].Value })' >> entrypoint.sh; \
    # setup julia
    echo '$JULIA_VERSION_SHORT = ($env:JULIA_VERSION -split \"\.\")[0,1] -join "."' >> entrypoint.sh; \
    echo '$JULIA_VERSION_ENV = $JULIA_VERSION -replace \"\.\", \"\"' >> entrypoint.sh; \
    echo 'Invoke-WebRequest -Uri "https://julialang-s3.julialang.org/bin/winnt/x64/$JULIA_VERSION_SHORT/julia-$JULIA_VERSION-win64.exe" -OutFile "julia-installer.exe"' >> entrypoint.sh; \
    echo 'Start-Process -FilePath "julia-installer.exe" -ArgumentList "/silent", "/norestart" -NoNewWindow -Wait' >> entrypoint.sh; \
    echo '$env:JULIA_$JULIA_VERSION_ENV = (Get-Location).Path + "\julia-$JULIA_VERSION\bin\julia"' >> entrypoint.sh; \
    echo '$env:JULIA_PKG_USE_CLI_GIT=true' >> entrypoint.sh; \
    # compile and publish
    echo '.\compile\compile.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX' >> entrypoint.sh; \
    echo '.\compile\publish.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX --overwrite $OVERWRITE' >> entrypoint.sh

CMD powershell -Command "Start-Sleep -Seconds 600"
