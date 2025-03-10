get-content .env | foreach {
    $name, $value = $_.split('=')
    set-content env:\$name $value
}

$repository = ($env:GITHUB_REPOSITORY -split '/' | Select-Object -Last 1) -replace '\.git$', ''
echo "$repository"
echo "$env:GITHUB_REPOSITORY"
git clone -n $env:GITHUB_REPOSITORY
cd $repository
git checkout $env:GITHUB_SHA

if ((Get-Content Manifest.toml -Raw) -match 'julia_version\s*=\s*"([^"]+)"') { $JULIA_VERSION = $Matches[1] }
$JULIA_VERSION_SHORT = ($JULIA_VERSION -split "\.")[0,1] -join "."
$JULIA_VERSION_ENV = $JULIA_VERSION -replace "\.", ""

echo "$JULIA_VERSION"
echo "$JULIA_VERSION_SHORT"
echo "$JULIA_VERSION_ENV"

Invoke-WebRequest -Uri https://julialang-s3.julialang.org/bin/winnt/x64/$JULIA_VERSION_SHORT/julia-$JULIA_VERSION-win64.zip -OutFile julia-$JULIA_VERSION-win64.zip
Expand-Archive -Path julia-$JULIA_VERSION-win64.zip -DestinationPath .
Set-Content env:JULIA_\$JULIA_VERSION_ENV "$((Get-Location).Path)\julia-$($JULIA_VERSION)\bin\julia.exe"

# $env:JULIA_PKG_USE_CLI_GIT=true
.\compile\compile.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX
.\compile\publish.bat --development_stage $DEVELOPMENT_STAGE --version_suffix $VERSION_SUFFIX --overwrite $OVERWRITE