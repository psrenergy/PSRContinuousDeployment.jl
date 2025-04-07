Set-StrictMode -Version Latest

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

try {
    # set the credentials
    $username = "psrcloud"
    $token = $env:PERSONAL_ACCESS_TOKEN
    git config --global user.name $username
    git config --global user.password $token
    git config --global url."https://${username}:${token}@github.com".insteadOf "https://github.com"

    # clone the repository
    git clone -n $env:GITHUB_REPOSITORY "model"
    Set-Location "model"
    git checkout $env:GITHUB_SHA

    # get the julia version
    if ((Get-Content Manifest.toml -Raw) -match 'julia_version\s*=\s*"([^"]+)"') {
        $JULIA_VERSION = $Matches[1]
    } else {
        throw "julia_version not found in Manifest.toml"
    }

    # setup julia
    $JULIA_VERSION_SHORT = ($JULIA_VERSION -split "\.")[0,1] -join "."
    $JULIA_VERSION_ENV = $JULIA_VERSION -replace "\.", ""
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri "https://julialang-s3.julialang.org/bin/winnt/x64/$JULIA_VERSION_SHORT/julia-$JULIA_VERSION-win64.zip" -OutFile julia-$JULIA_VERSION-win64.zip -UseBasicParsing
    Expand-Archive -Path julia-$JULIA_VERSION-win64.zip -DestinationPath .
    Set-Item env:JULIA_$JULIA_VERSION_ENV "$((Get-Location).Path)\julia-$($JULIA_VERSION)\bin\julia.exe"

    # compile and publish
    Set-Item env:JULIA_PKG_USE_CLI_GIT "true"
    .\compile\compile.bat --development_stage $env:DEVELOPMENT_STAGE --version_suffix $env:VERSION_SUFFIX
    .\compile\publish.bat --development_stage $env:DEVELOPMENT_STAGE --version_suffix $env:VERSION_SUFFIX --overwrite $env:OVERWRITE
} catch {
    Write-Error "An error occurred: $_"
    exit 1
}    