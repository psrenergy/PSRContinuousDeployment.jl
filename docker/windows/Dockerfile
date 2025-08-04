FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.39.1.windows.1/Git-2.39.1-64-bit.exe" -OutFile "Git-Installer.exe" ; \
    Start-Process -Wait -FilePath "Git-Installer.exe" -ArgumentList "/VERYSILENT", "/NORESTART" ; \
    Remove-Item -Force "Git-Installer.exe"

ENV POWERSHELL_VERSION=7.4.1
RUN Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$env:POWERSHELL_VERSION/PowerShell-$env:POWERSHELL_VERSION-win-x64.msi" -OutFile "pwsh.msi" ; \
    Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/i", "pwsh.msi", "/qn" ; \
    Remove-Item -Force "pwsh.msi"

RUN Invoke-WebRequest -Uri "https://install.julialang.org/Julia-x64.msi" -OutFile "julia.msi" ; \
    Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/i", "julia.msi", "ALLUSERS=1", "/qn" ; \
    Remove-Item -Force "julia.msi"    

WORKDIR C:/psr

COPY entrypoint.ps1 .

ENTRYPOINT ["pwsh", "-NoExit", "-Command", "C:/psr/entrypoint.ps1"]