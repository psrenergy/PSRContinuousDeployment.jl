FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.39.1.windows.1/Git-2.39.1-64-bit.exe" -OutFile "Git-Installer.exe" ; \
    Start-Process -Wait -FilePath "Git-Installer.exe" -ArgumentList "/VERYSILENT", "/NORESTART" ; \
    Remove-Item -Force "Git-Installer.exe"

COPY entrypoint.ps1 entrypoint.ps1

ENTRYPOINT ["powershell", "entrypoint.ps1"]