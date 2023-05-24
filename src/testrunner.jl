function testrunner(
    configuration::Configuration,
    testrunner_version::AbstractString,
)
    target = configuration.target
    package_path = configuration.package_path

    user = "testrunner-psrclustering"
    password = ""
    repository = ""
    branch = ""
    run_number = ""
    run_attempt = ""

    open("spec.cfg", "w") do f
        writeln(f, "url = \"https://github.com/$repository\"")
        writeln(f, "branch = \"$branch\"")
        writeln(f, "clone = true")
        writeln(f, "compile = true")
        writeln(f, "test = true")
        writeln(f, "print_timings = true")
        writeln(f, "run_model_from_case_path = true")
    end

    open("executar.xml", "w") do f
        writeln(f, "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
        writeln(f, "<ColecaoParametro>")
        writeln(f, "<Parametro nome=\"urlServico\" tipo=\"System.String\">https://psrcloud-prod.psr-inc.com/CamadaGerenciadoraServicoWeb/DespachanteWS.asmx</Parametro>")
        writeln(f, "<Parametro nome=\"usuario\" tipo=\"System.String\">$user</Parametro>")
        writeln(f, "<Parametro nome=\"senha\" tipo=\"System.String\">$password</Parametro>")
        writeln(f, "<Parametro nome=\"idioma\" tipo=\"System.Int32\">1</Parametro>")
        writeln(f, "<Parametro nome=\"modelo\" tipo=\"System.String\">TestRunner</Parametro>")
        writeln(f, "<Parametro nome=\"comando\" tipo=\"System.String\">executar</Parametro>")
        writeln(f, "<Parametro nome=\"cluster\" tipo=\"System.String\">PSR-US2</Parametro>")
        writeln(f, "<Parametro nome=\"diretorioDados\" tipo=\"System.String\">$package_path</Parametro>")
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
        writeln(f, "<Parametro nome=\"nomeCaso\" tipo=\"System.String\">GH CI $repository $branch $run_number-$run_attempt</Parametro>")
        writeln(f, "</ColecaoParametro>")
    end

    open("testrunner.sh", "w") do f
        writeln(f, "git --version")
        writeln(f, "sudo yum update git -y")
        writeln(f, "git --version")
        writeln(f, "")
        writeln(f, "echo =======================================================================================")
        writeln(f, "echo '### Clonning TestRunner'")
        writeln(f, "echo =======================================================================================")
        writeln(f, "rm -rf testrunner")
        writeln(f, "git clone --depth 1 --branch 1.6.0 --recurse-submodules http://github.com/psrenergy/testrunner.git testrunner")
        writeln(f, "")
        writeln(f, "echo")
        writeln(f, "echo '# Current Testrunner commit:'")
        writeln(f, "cd testrunner")
        writeln(f, "git log -1 --format=medium")
        writeln(f, "cd ..")
        writeln(f, "")
        writeln(f, "echo =======================================================================================")
        writeln(f, "echo '### Installing julia'")
        writeln(f, "echo =======================================================================================")
        writeln(f, "")
        writeln(f, "export JULIA_DOWNLOAD=\"/tmp/julia/download\"")
        writeln(f, "export JULIA_INSTALL=\"/tmp/julia/install\"")
        writeln(f, "export JULIA_DEPOT_PATH=\"/tmp/julia/.julia\"")
        writeln(f, "")
        writeln(f, "wget https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh")
        writeln(f, "bash jill.sh --no-confirm -v 1.9.0")
        writeln(f, "")
        writeln(f, "export PATH=\$PATH:\"/tmp/julia/install\"")
        writeln(f, "export JULIA_190=\"/tmp/julia/install/julia\"")
        writeln(f, "")
        writeln(f, "which \$JULIA_190")
        writeln(f, "\$JULIA_190 --version")
        writeln(f, "")
        writeln(f, "echo =======================================================================================")
        writeln(f, "echo '### Running Testrunner'")
        writeln(f, "echo =======================================================================================")
        writeln(f, "")
        writeln(f, "dos2unix ./testrunner/run_testrunner.sh")
        writeln(f, "./testrunner/run_testrunner.sh")
    end

    return nothing
end
