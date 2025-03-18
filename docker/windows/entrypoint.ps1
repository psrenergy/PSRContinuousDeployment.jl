# set credentials and clone repository
# Write-Output $env:GITHUB_REPOSITORY
# git clone -n ("https://psrcloud:" + "$env:PERSONAL_ACCESS_TOKEN" + "@github.com/" + $env:GITHUB_REPOSITORY + ".git") $repository
# git clone -n $env:GITHUB_REPOSITORY "repository"
git clone -n ("https://psrcloud:" + "$env:PERSONAL_ACCESS_TOKEN" + "@github.com/psrenergy/SCE.jl.git") "repository"
Set-Location "repository"
git checkout $env:GITHUB_SHA

# get the julia version
if ((Get-Content Manifest.toml -Raw) -match 'julia_version\s*=\s*"([^"]+)"') { $JULIA_VERSION = $Matches[1] }

# setup julia
$JULIA_VERSION_SHORT = ($JULIA_VERSION -split "\.")[0,1] -join "."
$JULIA_VERSION_ENV = $JULIA_VERSION -replace "\.", ""

$ProgressPreference = "SilentlyContinue"
Invoke-WebRequest -Uri "https://julialang-s3.julialang.org/bin/winnt/x64/$JULIA_VERSION_SHORT/julia-$JULIA_VERSION-win64.zip" -OutFile julia-$JULIA_VERSION-win64.zip -UseBasicParsing
Expand-Archive -Path julia-$JULIA_VERSION-win64.zip -DestinationPath .
Set-Item env:JULIA_$JULIA_VERSION_ENV "$((Get-Location).Path)\julia-$($JULIA_VERSION)\bin\julia.exe"

# compile and publish
Set-Item env:JULIA_PKG_USE_CLI_GIT "true"
.\compile\compile.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX
.\compile\publish.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX --overwrite $OVERWRITE