function setup(configuration::Configuration, id::String)
    if !Sys.iswindows()
        PSRLogger.fatal_error("SETUP: Creating setup file is only supported on Windows")
    end

    target = configuration.target
    version = configuration.version
    build_path = configuration.build_path
    setup_path = configuration.setup_path

    iss = joinpath(setup_path, "setup.iss")
    open(iss, "w") do f
        writeln(f, "[Setup]")
        writeln(f, "; NOTE: The value of AppId uniquely identifies this application.")
        writeln(f, "; Do not use the same AppId value in installers for other applications.")
        writeln(f, "; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)")
        writeln(f, "AppId={{2FE8D94F-A7F8-4CC3-B62C-AD4086F803F3}}")
        writeln(f, "AppName=$target")
        writeln(f, "AppVersion=$version")
        writeln(f, "AppVerName=$target $version")
        writeln(f, "AppPublisher=PSR")
        writeln(f, "AppPublisherURL=\"http://www.psr-inc.com\"")
        writeln(f, "AppSupportURL=\"http://www.psr-inc.com\"")
        writeln(f, "AppUpdatesURL=\"http://www.psr-inc.com\"")
        writeln(f, "DefaultDirName={sd}\\PSR\\$target")
        writeln(f, "DefaultGroupName=$target")
        writeln(f, "OutputDir=.\\")
        writeln(f, "OutputBaseFilename=$target-$version-setup")
        writeln(f, "Compression=lzma")
        writeln(f, "SolidCompression=yes")
        writeln(f, "AlwaysShowComponentsList=yes")
        writeln(f, "WizardStyle=classic")
        writeln(f, "WizardImageFile=./misc/lateral_instalador_psr.bmp")
        writeln(f, "WizardSmallImageFile=./misc/header_instalador_138.bmp")
        writeln(f, "PrivilegesRequired=admin")
        writeln(f, "")
        writeln(f, "[Languages]")
        writeln(f, "Name: english; MessagesFile: compiler:Default.isl")
        writeln(f, "Name: brazilianportuguese; MessagesFile: compiler:Languages\\BrazilianPortuguese.isl")
        writeln(f, "Name: spanish; MessagesFile: compiler:Languages\\Spanish.isl")
        writeln(f, "")
        writeln(f, "[Files]")
        writeln(f, "Source: .\\..\\build\\bin\\*; DestDir: {app}\\bin; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; Permissions: everyone-full")
        writeln(f, "Source: .\\..\\build\\lib\\*; DestDir: {app}\\lib; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; Permissions: everyone-full")
        writeln(f, "Source: .\\..\\build\\share\\*; DestDir: {app}\\share; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; Permissions: everyone-full")
        writeln(f, "")
        writeln(f, "[InstallDelete]")
        writeln(f, "Type: filesandordirs; Name: {app}\\bin")
        writeln(f, "Type: filesandordirs; Name: {app}\\lib")
        writeln(f, "Type: filesandordirs; Name: {app}\\share")
        writeln(f, "")
        writeln(f, "[Registry]")
        writeln(f, "Root: HKLM64; Subkey: SOFTWARE\\PSR\\$target\\0.0.x\\; ValueType: string; ValueName: Path; ValueData: {app}\\; Flags: uninsdeletekey")
    end

    Inno.run_inno(iss, flags = ["/Qp"])

    return nothing
end
