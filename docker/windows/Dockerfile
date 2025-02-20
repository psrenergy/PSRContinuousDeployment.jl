FROM mcr.microsoft.com/windows/servercore:ltsc2019

WORKDIR C:/model_build

# Install necessary tools (like wget, git) using Chocolatey
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); \
    choco install git wget -y

# Setup entrypoint script
RUN echo "echo 'Setting up GitHub credentials...'" > entrypoint.ps1 && \
    echo "echo 'machine github.com login psrcloud password \$env:PERSONAL_ACCESS_TOKEN' > \$env:USERPROFILE\.netrc" >> entrypoint.ps1 && \
    echo "echo 'Cloning repository...'" >> entrypoint.ps1 && \
    echo "$repository = [System.IO.Path]::GetFileNameWithoutExtension(\$env:GITHUB_REPOSITORY)" >> entrypoint.ps1 && \
    echo "git clone -n \$env:GITHUB_REPOSITORY \$repository" >> entrypoint.ps1 && \
    echo "cd \$repository" >> entrypoint.ps1 && \
    echo "git checkout \$env:GITHUB_SHA" >> entrypoint.ps1 && \
    echo "echo 'Getting Julia version...'" >> entrypoint.ps1 && \
    echo "JULIA_VERSION = (Select-String '^julia_version\s*=' Manifest.toml).Line -replace '^julia_version\s*=\s*\"([^\"]*)\"', '$1'" >> entrypoint.ps1 && \
    echo "JULIA_VERSION_SHORT = \$JULIA_VERSION.Split('.')[0] + '.' + \$JULIA_VERSION.Split('.')[1]" >> entrypoint.ps1 && \
    echo "JULIA_VERSION_ENV = \$JULIA_VERSION -replace '\.', ''" >> entrypoint.ps1 && \
    echo "Invoke-WebRequest -Uri https://julialang-s3.julialang.org/bin/windows/x64/\$JULIA_VERSION_SHORT/julia-\$JULIA_VERSION-win64.zip -OutFile julia-\$JULIA_VERSION-win64.zip" >> entrypoint.ps1 && \
    echo "Expand-Archive -Path julia-\$JULIA_VERSION-win64.zip -DestinationPath julia-\$JULIA_VERSION" >> entrypoint.ps1 && \
    echo "setx JULIA_\$JULIA_VERSION_ENV C:\model_build\julia-\$JULIA_VERSION\bin\julia.exe" >> entrypoint.ps1 && \
    echo "setx JULIA_PKG_USE_CLI_GIT true" >> entrypoint.ps1 && \
    echo "echo 'Running compile and publish scripts...'" >> entrypoint.ps1 && \
    echo "C:\model_build\compile\compile.bat --development_stage \$env:DEVELOPMENT_STAGE --version_suffix \$env:VERSION_SUFFIX" >> entrypoint.ps1 && \
    echo "C:\model_build\compile\publish.bat --development_stage \$env:DEVELOPMENT_STAGE --version_suffix \$env:VERSION_SUFFIX --overwrite \$env:OVERWRITE" >> entrypoint.ps1

# Ensure the entrypoint script is executable
RUN powershell -Command \
    Set-ExecutionPolicy RemoteSigned -Scope Process; \
    ./entrypoint.ps1

CMD ["powershell", "-File", "./entrypoint.ps1"]
