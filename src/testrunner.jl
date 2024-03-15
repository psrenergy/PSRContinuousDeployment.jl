function run_testrunner(
    configuration::Configuration,
    user::AbstractString,
    password::AbstractString,
    testrunner_version::AbstractString,
)
    target = configuration.target
    package_path = configuration.package_path
    testrunner_path = joinpath(configuration.package_path, "testrunner")

    branch = cd(package_path) do
        readchomp(`$git branch --show-current`)
        return nothing
    end

    if branch == ""
        PSRLogger.fatal_error("TESTRUNNER: Could not get current branch")
    end

    if isdir(testrunner_path)
        PSRLogger.info("TESTRUNNER: Removing testrunner directory")
        rm(testrunner_path, force = true, recursive = true)
    end

    PSRLogger.info("TESTRUNNER: Creating testrunner directory")
    mkdir(testrunner_path)

    cfg_path = joinpath(testrunner_path, "spec.cfg")
    open(cfg_path, "w") do f
        write(f, "url = \"https://github.com/psrenergy/$target\"\n")
        write(f, "branch = \"$branch\"\n")
        write(f, "clone = true\n")
        write(f, "compile = true\n")
        write(f, "test = true\n")
        write(f, "print_timings = true\n")
        write(f, "run_model_from_case_path = true\n")
        return nothing
    end

    xml_path = joinpath(testrunner_path, "executar.xml")
    open(xml_path, "w") do f
        writeln(f, "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
        writeln(f, "<ColecaoParametro>")
        writeln(f, "<Parametro nome=\"urlServico\" tipo=\"System.String\">https://psrcloud-prod.psr-inc.com/CamadaGerenciadoraServicoWeb/DespachanteWS.asmx</Parametro>")
        writeln(f, "<Parametro nome=\"usuario\" tipo=\"System.String\">$user</Parametro>")
        writeln(f, "<Parametro nome=\"senha\" tipo=\"System.String\">$password</Parametro>")
        writeln(f, "<Parametro nome=\"idioma\" tipo=\"System.Int32\">1</Parametro>")
        writeln(f, "<Parametro nome=\"modelo\" tipo=\"System.String\">TestRunner</Parametro>")
        writeln(f, "<Parametro nome=\"comando\" tipo=\"System.String\">executar</Parametro>")
        writeln(f, "<Parametro nome=\"cluster\" tipo=\"System.String\">PSR-US2</Parametro>")
        writeln(f, "<Parametro nome=\"diretorioDados\" tipo=\"System.String\">$testrunner_path</Parametro>")
        writeln(f, "<Parametro nome=\"versao\" tipo=\"System.String\">0.0.1</Parametro>")
        writeln(f, "<Parametro nome=\"nproc\" tipo=\"System.Int32\">16</Parametro>")
        writeln(f, "<Parametro nome=\"minCores\" tipo=\"System.Int32\">16</Parametro>")
        writeln(f, "<Parametro nome=\"maxCores\" tipo=\"System.Int32\">32</Parametro>")
        writeln(f, "<Parametro nome=\"minMemoryGB\" tipo=\"System.Int32\">2</Parametro>")
        writeln(f, "<Parametro nome=\"maxMemoryGB\" tipo=\"System.Int32\">32</Parametro>")
        writeln(f, "<Parametro nome=\"repositorioPai\" tipo=\"System.Int32\">0</Parametro>")
        writeln(f, "<Parametro nome=\"idTipoExecucao\" tipo=\"System.String\">97</Parametro>")
        writeln(f, "<Parametro nome=\"filtroDownload\" tipo=\"System.String\">Download</Parametro>")
        writeln(f, "<Parametro nome=\"tipoExecucao\" tipo=\"System.Int32\">0</Parametro>")
        writeln(f, "<Parametro nome=\"nomeCaso\" tipo=\"System.String\">GH CI $target $branch</Parametro>")
        writeln(f, "</ColecaoParametro>")
        return nothing
    end

    testrunner_sh_path = joinpath(testrunner_path, "testrunner.sh")
    open(testrunner_sh_path, "w") do f
        julia = "JULIA_$(VERSION.major)$(VERSION.minor)$(VERSION.patch)"

        write(f, "git --version\n")
        write(f, "sudo yum update git -y\n")
        write(f, "git --version\n\n")

        write(f, "echo =======================================================================================\n")
        write(f, "echo '### Clonning TestRunner'\n")
        write(f, "echo =======================================================================================\n")
        write(f, "rm -rf testrunner\n")
        write(f, "git clone --depth 1 --branch $testrunner_version --recurse-submodules http://github.com/psrenergy/testrunner.git testrunner\n\n")

        write(f, "echo\n")
        write(f, "echo '# Current Testrunner commit:'\n")
        write(f, "cd testrunner\n")
        write(f, "git log -1 --format=medium\n")
        write(f, "cd ..\n\n")

        write(f, "echo =======================================================================================\n")
        write(f, "echo '### Installing julia'\n")
        write(f, "echo =======================================================================================\n\n")

        write(f, "export JULIA_DOWNLOAD=\"/tmp/julia/download\"\n")
        write(f, "export JULIA_INSTALL=\"/tmp/julia/install\"\n")
        write(f, "export JULIA_DEPOT_PATH=\"/tmp/julia/.julia\"\n\n")

        write(f, "wget https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh\n")
        write(f, "bash jill.sh --no-confirm -v $VERSION\n\n")

        write(f, "export PATH=\$PATH:\"/tmp/julia/install\"\n")
        write(f, "export $julia=\"/tmp/julia/install/julia\"\n\n")

        write(f, "which \$$julia\n")
        write(f, "\$$julia --version\n\n")

        write(f, "echo =======================================================================================\n")
        write(f, "echo '### Running Testrunner'\n")
        write(f, "echo =======================================================================================\n\n")

        write(f, "dos2unix ./testrunner/run_testrunner.sh\n")
        write(f, "./testrunner/run_testrunner.sh\n")

        return nothing
    end

    # fake_console = raw"C:\FakeConsolev4_15\FakeConsole.exe"
    fake_console = raw"D:\PSR\FakeConsole\FakeConsole.exe"

    if !isfile(fake_console)
        PSRLogger.fatal_error("TESTRUNNER: FakeConsole not found at $fake_console")
    end

    cd(testrunner_path) do
        if Sys.iswindows()
            # run(`$fake_console executar.xml \| Tee-Object -file testrunner.log`)
            run(`$fake_console executar.xml`)
        else
            PSRLogger.fatal_error("TESTRUNNER: Unsupported OS")
        end
    end

    testrunner_ok_path = joinpath(testrunner_path, "testrunner.ok")
    if !isfile(testrunner_ok_path)
        PSRLogger.fatal_error("TESTRUNNER: Cloud failed to return testrunner.ok")
    end

    rm(cfg_path, force = true)
    rm(xml_path, force = true)
    rm(testrunner_sh_path, force = true)
    rm(testrunner_ok_path, force = true)

    return nothing
end
