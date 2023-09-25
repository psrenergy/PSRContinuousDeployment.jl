function create_setup(
    configuration::Configuration,
    id::AbstractString;
    password::Union{Nothing, AbstractString} = nothing,
    setup_icon::Union{Nothing, AbstractString} = nothing,
    sign::Bool = true,
)
    if !Sys.iswindows()
        Log.fatal_error("SETUP: Creating setup file is only supported on Windows")
    end

    target = configuration.target
    version = configuration.version
    build_path = configuration.build_path
    setup_path = configuration.setup_path

    if !isdir(setup_path)
        Log.info("SETUP: Creating setup directory")
        mkdir(setup_path)
    end

    wizard_image_path = joinpath(setup_path, "lateral_instalador_psr.bmp")
    write(wizard_image_path, wizard_image)

    wizard_small_image_path = joinpath(setup_path, "header_instalador_138.bmp")
    write(wizard_small_image_path, wizard_small_image)

    Log.info("SETUP: Creating setup file for $target $version")
    iss_path = joinpath(setup_path, "setup.iss")
    open(iss_path, "w") do f
        writeln(f, "[Setup]")
        writeln(f, "AppId={{$id}}")
        writeln(f, "AppName=$target")
        writeln(f, "AppVersion=$version")
        writeln(f, "AppVerName=$target $version")
        writeln(f, "AppPublisher=PSR")
        writeln(f, "AppPublisherURL=http://www.psr-inc.com")
        writeln(f, "AppSupportURL=http://www.psr-inc.com")
        writeln(f, "AppUpdatesURL=http://www.psr-inc.com")
        writeln(f, "DefaultDirName={sd}\\PSR\\$target")
        writeln(f, "DefaultGroupName=PSR/$target")
        writeln(f, "OutputDir=.\\")
        writeln(f, "OutputBaseFilename=$target-$version-setup")
        writeln(f, "Compression=lzma")
        writeln(f, "SolidCompression=yes")
        writeln(f, "AlwaysShowComponentsList=yes")
        writeln(f, "WizardStyle=classic")
        writeln(f, "WizardImageFile=$wizard_image_path")
        writeln(f, "WizardSmallImageFile=$wizard_small_image_path")
        writeln(f, "PrivilegesRequired=admin")
        writeln(f, "VersionInfoCompany=PSR")
        writeln(f, "VersionInfoProductName=$target")
        if !isnothing(password)
            writeln(f, "Password=$password")
        end
        if !isnothing(setup_icon)
            writeln(f, "SetupIconFile=$setup_icon")
        end
        writeln(f, "")
        writeln(f, "[Languages]")
        writeln(f, "Name: english; MessagesFile: compiler:Default.isl")
        writeln(f, "Name: brazilianportuguese; MessagesFile: compiler:Languages\\BrazilianPortuguese.isl")
        writeln(f, "Name: spanish; MessagesFile: compiler:Languages\\Spanish.isl")
        writeln(f, "")
        writeln(f, "[Files]")
        writeln(f, "Source: $(joinpath(build_path, "*")); DestDir: {app}\\; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly; Permissions: everyone-full")
        writeln(f, "")
        writeln(f, "[InstallDelete]")
        writeln(f, "Type: filesandordirs; Name: {app}\\bin")
        writeln(f, "Type: filesandordirs; Name: {app}\\lib")
        writeln(f, "Type: filesandordirs; Name: {app}\\share")
        writeln(f, "")
        writeln(f, "[Registry]")
        writeln(f, "Root: HKLM64; Subkey: SOFTWARE\\PSR\\$target\\0.0.x\\; ValueType: string; ValueName: Path; ValueData: {app}; Flags: uninsdeletekey")
        return nothing
    end

    Log.info("SETUP: Donwloading Inno Setup")
    inno_url = "https://julia-artifacts.s3.amazonaws.com/inno/4b330/inno.tgz"
    inno_hash = "4b3303c32724af530789f7844f656ba8510977222bb79c5e95e88f67350864d7"
    inno_path = tempname()
    @assert download_verify_unpack(inno_url, inno_hash, inno_path)

    Log.info("SETUP: Running Inno Setup")
    inno_executable_path = joinpath(inno_path, "inno", "ISCC.exe")
    inno_flags = Cmd(["/Qp"])
    run(`$inno_executable_path $inno_flags $iss_path`)

    if sign
        Log.info("SETUP: Signing setup file")
        sync_file_with_certificate_server(configuration)
    end

    Log.info("SETUP: Removing temporary files")
    rm(iss_path, force = true)
    rm(wizard_image_path, force = true)
    rm(wizard_small_image_path, force = true)
    rm(inno_path, force = true, recursive = true)

    Log.info("SETUP: Setup file created successfully")

    return nothing
end
