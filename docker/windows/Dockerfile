# Use Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set working directory
WORKDIR C:\model_build

# Install necessary tools
SHELL ["powershell", "-Command"]
RUN Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe" -OutFile "git-installer.exe"; \
    Start-Process -Wait -FilePath ".\git-installer.exe" -ArgumentList "/VERYSILENT"; \
    Remove-Item -Force "git-installer.exe"

# Create entrypoint script
RUN Set-Content -Path "entrypoint.ps1" -Value @'
# Stop execution on errors
$ErrorActionPreference = "Stop"

# Set credentials
"[github.com]`n    user = psrcloud`n    password = $env:PERSONAL_ACCESS_TOKEN" | Out-File -Encoding ASCII -FilePath "$env:USERPROFILE\.netrc"

# Clone the repository
$repository = [System.IO.Path]::GetFileNameWithoutExtension($env:GITHUB_REPOSITORY)
git clone -n $env:GITHUB_REPOSITORY $repository
Set-Location $repository
git checkout $env:GITHUB_SHA

# Extract Julia version from Manifest.toml
$manifestContent = Get-Content "Manifest.toml"
$juliaVersion = ($manifestContent | Select-String '^julia_version\s*=' -Raw) -replace '^julia_version\s*=\s*"(.+)"', '$1'

# Setup Julia
$juliaVersionShort = ($juliaVersion -split "\.")[0,1] -join "."
$juliaVersionEnv = $juliaVersion -replace "\.", ""

$downloadUrl = "https://julialang-s3.julialang.org/bin/winnt/x64/$juliaVersionShort/julia-$juliaVersion-win64.zip"
Invoke-WebRequest -Uri $downloadUrl -OutFile "julia.zip"
Expand-Archive -Path "julia.zip" -DestinationPath "." -Force
$env:JULIA_$juliaVersionEnv = "$(Get-Location)\julia-$juliaVersion\bin\julia.exe"
$env:JULIA_PKG_USE_CLI_GIT = "true"

# Compile and publish
Start-Process -Wait -NoNewWindow -FilePath ".\compile\compile.bat" -ArgumentList "--development_stage $env:DEVELOPMENT_STAGE --version_suffix $env:VERSION_SUFFIX"
Start-Process -Wait -NoNewWindow -FilePath ".\compile\publish.bat" -ArgumentList "--development_stage $env:DEVELOPMENT_STAGE --version_suffix $env:VERSION_SUFFIX --overwrite $env:OVERWRITE"
'@

# Set script permissions
RUN powershell -Command Set-ExecutionPolicy Unrestricted -Scope Process -Force

# Entrypoint
CMD ["powershell.exe", "-File", "entrypoint.ps1"]
