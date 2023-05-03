function setup(configuration::Configuration, id::String)
    if !Sys.iswindows()
        PSRLogger.fatal_error("SETUP: Creating setup file is only supported on Windows")
    end

    target = configuration.target
    version = configuration.version
    build_path = configuration.build_path
    setup_path = configuration.setup_path

    if !isdir(setup_path)
        PSRLogger.info("SETUP: Creating setup directory")
        mkdir(setup_path)
    end

    wizard_image_path = joinpath(setup_path, "lateral_instalador_psr.bmp")
    write(wizard_image_path, wizard_image)

    wizard_small_image_path = joinpath(setup_path, "header_instalador_138.bmp")
    write(wizard_small_image_path, wizard_small_image)

    PSRLogger.info("SETUP: Creating setup file for $target $version")
    iss = joinpath(setup_path, "setup.iss")
    open(iss, "w") do f
        writeln(f, "[Setup]")
        writeln(f, "AppId={{$id}}")
        writeln(f, "AppName=$target")
        writeln(f, "AppVersion=$version")
        writeln(f, "AppVerName=$target $version")
        writeln(f, "AppPublisher=PSR")
        writeln(f, "AppPublisherURL=http://www.psr-inc.com")
        writeln(f, "AppSupportURL=http://www.psr-inc.com")
        writeln(f, "AppUpdatesURL=http://www.psr-inc.com")
        writeln(f, "DefaultDirName={sd}/PSR/$target")
        writeln(f, "DefaultGroupName=$target")
        writeln(f, "OutputDir=./")
        writeln(f, "OutputBaseFilename=$target-$version-setup")
        writeln(f, "Compression=lzma")
        writeln(f, "SolidCompression=yes")
        writeln(f, "AlwaysShowComponentsList=yes")
        writeln(f, "WizardStyle=classic")
        writeln(f, "WizardImageFile=$wizard_image_path")
        writeln(f, "WizardSmallImageFile=$wizard_small_image_path")
        writeln(f, "PrivilegesRequired=admin")
        writeln(f, "")
        writeln(f, "[Languages]")
        writeln(f, "Name: english; MessagesFile: compiler:Default.isl")
        writeln(f, "Name: brazilianportuguese; MessagesFile: compiler:Languages/BrazilianPortuguese.isl")
        writeln(f, "Name: spanish; MessagesFile: compiler:Languages/Spanish.isl")
        writeln(f, "")
        writeln(f, "[Files]")
        writeln(f, "Source: $(joinpath(build_path, "bin", "*")); DestDir: {app}/bin; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; Permissions: everyone-full")
        writeln(f, "Source: $(joinpath(build_path, "lib", "*")); DestDir: {app}/lib; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; Permissions: everyone-full")
        writeln(f, "Source: $(joinpath(build_path, "share", "*")); DestDir: {app}/share; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; Permissions: everyone-full")
        writeln(f, "")
        writeln(f, "[InstallDelete]")
        writeln(f, "Type: filesandordirs; Name: {app}/bin")
        writeln(f, "Type: filesandordirs; Name: {app}/lib")
        writeln(f, "Type: filesandordirs; Name: {app}/share")
        writeln(f, "")
        writeln(f, "[Registry]")
        return writeln(f, "Root: HKLM64; Subkey: SOFTWARE\\PSR\\$target\\0.0.x\\; ValueType: string; ValueName: Path; ValueData: {app}/; Flags: uninsdeletekey")
    end

    PSRLogger.info("SETUP: Creating setup file")
    Inno.run_inno(iss, flags = ["/Qp"])

    PSRLogger.info("SETUP: Removing temporary files")
    rm(iss, force = true)
    rm(wizard_image_path, force = true)
    rm(wizard_small_image_path, force = true)

    return nothing
end
