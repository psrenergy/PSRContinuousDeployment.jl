# PSRExample.jl
Repositório modelo da PSR para projetos em julia

Importante notar que o PSRExample exige uma variável de ambiente JULIA_185, essa variável de ambiente é uma maneira fácil de garantir que o projeto sempre será rodado com a mesma versão de Julia. Basta setar a variável de ambiente seja em Windows ou Linux.

Aqui estão alguns exemplos de variável de ambiente que funcionam corretamente **(Importante não ter espaços no path da variável)**
```
C:\Users\xxxxx\.julia\juliaup\julia-1.8.2+0.x64\bin\julia.exe
C:\Users\xxxxx\AppData\Local\Programs\Julia-1.6.1\bin\julia.exe
```

## Criando um projeto do zero

1 - Criar um respositório no Github usando o botão verde **Use this template** localizado no site deste repositório. O padrão de julia é MODULE_NAME.jl ex: `Tariff.jl, sddp.jl, ...`

2 - Após a criação do repositório, clone o novo repositório para a sua máquina e execute o script `adapt_template.bat` passando como argumento o nome do seu novo projeto. Ex:
```
.\adapt_template\adapt_template.bat MODULE_NAME
```

3 - Certifique-se de que os testes estão funcionando no seu computador rodando o script de testes. Ex:
```
.\test\test_package.bat
```

4 - Certifique-se de que a compilação está funcionando no seu computador rodando o script de compilação. Ex:
```
.\compile\compile_package.bat
```

5 - Começe o desenvolvimento na pasta `src`

## Executáveis (.bat/.sh)
O repositório contém alguns scripts que ajudam no desenvolvimento dos modelos.

- test_package - Roda os testes unitários do projeto
- compile_package - Gera uma imagem compilada do julia com o pacote
- PSRExample - Roda a main a partir do source code do projeto
- revise - Inicia uma sessão de Julia usando o Revise.jl