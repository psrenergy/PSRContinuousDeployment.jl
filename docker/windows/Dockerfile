FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.39.1.windows.1/Git-2.39.1-64-bit.exe" -OutFile "Git-Installer.exe" ; \
    Start-Process -Wait -FilePath "Git-Installer.exe" -ArgumentList "/VERYSILENT", "/NORESTART" ; \
    Remove-Item -Force "Git-Installer.exe"

    # clone repo
RUN echo '$repository = ($env:GITHUB_REPOSITORY -split \"/\"| Select-Object -Last 1) -replace \".git$\", \"\"' >> entrypoint.ps1; \
    echo 'git clone -n ($env:GITHUB_REPOSITORY.Substring(0,8) + \"psrcloud:\" + \"$env:PERSONAL_ACCESS_TOKEN@\" + $env:GITHUB_REPOSITORY.Substring(8))' >> entrypoint.ps1; \
    echo 'cd $repository' >> entrypoint.ps1; \
    echo 'git checkout $env:GITHUB_SHA' >> entrypoint.ps1; \
    # get the julia version
    echo 'if ((Get-Content Manifest.toml -Raw) -match ''julia_version\s*=\s*\"([^\"]+)\"'') { $JULIA_VERSION = $Matches[1] }' >> entrypoint.ps1; \
    # setup julia
    echo '$JULIA_VERSION_SHORT = ($JULIA_VERSION -split \"\.\")[0,1] -join \".\"' >> entrypoint.ps1; \
    echo '$JULIA_VERSION_ENV = $JULIA_VERSION -replace \"\.\", \"\"' >> entrypoint.ps1; \
    echo '$ProgressPreference = \"SilentlyContinue\"' >> entrypoint.ps1; \
    echo 'Invoke-WebRequest -Uri \"https://julialang-s3.julialang.org/bin/winnt/x64/$JULIA_VERSION_SHORT/julia-$JULIA_VERSION-win64.zip\" -OutFile julia-$JULIA_VERSION-win64.zip -UseBasicParsing' >> entrypoint.ps1; \
    echo 'Expand-Archive -Path julia-$JULIA_VERSION-win64.zip -DestinationPath .' >> entrypoint.ps1; \
    echo 'Set-Item env:JULIA_$JULIA_VERSION_ENV \"$((Get-Location).Path)\julia-$($JULIA_VERSION)\bin\julia.exe\"' >> entrypoint.ps1; \
    echo '$env:JULIA_PKG_USE_CLI_GIT=$true' >> entrypoint.ps1; \
    # compile and publish
    echo '.\compile\compile.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX' >> entrypoint.ps1; \
    echo '.\compile\publish.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX --overwrite $OVERWRITE' >> entrypoint.ps1

ENTRYPOINT ["powershell", "-File", "entrypoint.ps1"] 