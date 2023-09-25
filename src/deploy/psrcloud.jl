# function deploy_to_psrcloud(
#     configuration::Configuration,
#     psrcloud_user::AbstractString,
#     psrcloud_password::AbstractString;
#     url::AbstractString = raw"https://psrcloud-deploy.psr-inc.com/CamadaGerenciadoraServicoWeb/DespachanteWS.asmx",
#     cluster::AbstractString = raw"PSR-US_OHIO",
# )

#     target = configuration.target
#     version = configuration.version
#     package_path = configuration.package_path
#     compile_path = configuration.compile_path
#     build_path = configuration.build_path

#     publish_path = joinpath(compile_path, "publish")

#     cd(publish_path) do
#         run(`git add --all`)
#         run(`git commit -m "$version ($sha1)"`)
#         run(`git pull`)
#         run(`git push origin --all`)
#         return nothing
#     end

# cd deploy
# Remove-Item -Recurse -Force -ErrorAction Ignore -Path publish.xml
# Remove-Item -Recurse -Force -ErrorAction Ignore -Path upload 
# Remove-Item -Recurse -Force -ErrorAction Ignore -Path psrio-distribution
# git clone --branch develop https://bitbucket.org/psr/psrio-distribution.git
# Rename-Item psrio-distribution\linux bin
# Copy-Item psrio_core.sh -Destination psrio-distribution\bin
# Invoke-Expression "& `".\7zip\7z.exe`" a -tzip .\upload\psrio.zip .\psrio-distribution\bin"
# echo '<?xml version="1.0" encoding="utf-8"?>' > publish.xml
# echo '<ColecaoParametro>' >> publish.xml
# echo '<Parametro nome="urlServico" tipo="System.String">https://psrcloud-deploy.psr-inc.com/CamadaGerenciadoraServicoWeb/DespachanteWS.asmx</Parametro>' >> publish.xml
# echo '<Parametro nome="usuario" tipo="System.String">rsampaio</Parametro>' >> publish.xml
# echo '<Parametro nome="senha" tipo="System.String">${{ secrets.CLOUD_RSAMPAIO }}</Parametro>' >> publish.xml
# echo '<Parametro nome="idioma" tipo="System.String">3</Parametro>' >> publish.xml
# echo '<Parametro nome="programa" tipo="System.String">PSRIO</Parametro>' >> publish.xml
# echo '<Parametro nome="comando" tipo="System.String">cadastrarVersao</Parametro>' >> publish.xml
# echo '<Parametro nome="cluster" tipo="System.String">PSR-US_OHIO</Parametro>' >> publish.xml
# echo '<Parametro nome="versao" tipo="System.String">${{ github.event.inputs.version }}</Parametro>' >> publish.xml
# echo '<Parametro nome="ultimaVersao" tipo="System.Boolean">true</Parametro>' >> publish.xml
# echo '<Parametro nome="ativo" tipo="System.Boolean">true</Parametro>' >> publish.xml
# echo '<Parametro nome="tipoVersao" tipo="System.String">0</Parametro>' >> publish.xml
# echo '<Parametro nome="idArquitetura" tipo="System.String">503</Parametro>' >> publish.xml
# echo ('<Parametro nome="diretorioPrograma" tipo="System.String">'+$((Get-Item .).FullName)+'\upload</Parametro>') >> publish.xml
# echo '<Parametro nome="colecaoTipoExecucao" tipo="System.String">SDDP,PSRCore,CompilePSRModel,OPTGEN,NETPLAN,SDDP-NETPLAN,NONE</Parametro>' >> publish.xml
# echo '<Parametro nome="colecaoEnvironment" tipo="System.String"></Parametro>' >> publish.xml
# echo '<Parametro nome="colecaoDescricao" tipo="System.String">Default</Parametro>' >> publish.xml
# echo '<Parametro nome="colecaoSubdiretorio" tipo="System.String"></Parametro>' >> publish.xml
# echo '<Parametro nome="colecaoArgs" tipo="System.String">,,,</Parametro>' >> publish.xml
# echo '<Parametro nome="colecaoJob" tipo="System.String">,,,</Parametro>' >> publish.xml
# echo '<Parametro nome="colecaoGrupo" tipo="System.String">PSRIO</Parametro>' >> publish.xml
# echo '<Parametro nome="scriptModelo" tipo="System.String"></Parametro>' >> publish.xml
# echo '</ColecaoParametro>' >> publish.xml
# C:\PSR\FakeConsole\v5.0-rc.3\FakeConsole.exe publish.xml | Tee-Object -file psrcloud_publish.log
# Remove-Item -Recurse -Force -ErrorAction Ignore -Path publish.xml
# Remove-Item -Recurse -Force -ErrorAction Ignore -Path upload 
# Remove-Item -Recurse -Force -ErrorAction Ignore -Path psrio-distribution
# cd ..

# end