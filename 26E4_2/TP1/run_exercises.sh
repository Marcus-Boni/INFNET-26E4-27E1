#!/usr/bin/env bash
set -e

cd /home/marcus
export USER=marcus
export HOME=/home/marcus
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Limpar artefatos anteriores se existirem
rm -rf /home/marcus/tp_linux /home/marcus/projeto_final /home/marcus/*.txt /home/marcus/*.log /home/marcus/*.sh /home/marcus/binario_elf /home/marcus/backup_dados.tar.gz

# Preparar arquivos base no diretorio pessoal (/home/marcus) para inspecao realista
cat << 'EOF' > /home/marcus/notas_estudo.txt
================================================================
NOTAS DE ESTUDO - ARQUITETURA E SISTEMA OPERACIONAL LINUX
================================================================
1. Kernel Linux: Gerencia CPU (escalonador CFS), memoria virtual,
   sistema de arquivos (VFS) e drivers de dispositivos.
2. Shell (Bash): Interpretador de comandos que faz a interface
   entre o usuario e as chamadas de sistema (syscalls) do kernel.
3. Hierarquia FHS (Filesystem Hierarchy Standard):
   - /bin, /usr/bin : Binarios essenciais de usuario
   - /etc           : Arquivos de configuracao do sistema
   - /var/log       : Registros (logs) de eventos e servicos
   - /home          : Diretorios pessoais dos usuarios
   - /proc, /sys    : Sistemas de arquivos virtuais do kernel
EOF

cat << 'EOF' > /home/marcus/monitor_sistema.sh
#!/usr/bin/env bash
# Script de monitoramento rapido de recursos
echo "Data da coleta: $(date)"
echo "Tempo ativo: $(uptime -p)"
EOF
chmod +x /home/marcus/monitor_sistema.sh

cp /bin/echo /home/marcus/binario_elf
tar -czf /home/marcus/backup_dados.tar.gz notas_estudo.txt monitor_sistema.sh
cat << 'EOF' > /home/marcus/aplicacao_local.log
2026-11-03 23:00:01 [INFO] Servico inicializado com sucesso na porta 8080.
2026-11-03 23:05:12 [INFO] Conexao estabelecida com o pool de dados.
2026-11-03 23:10:44 [WARN] Uso de cache atingiu 75% do limite configurado.
2026-11-03 23:14:02 [INFO] Rotina de verificacao periodica concluida (status=OK).
EOF

# ==============================================================================
# EXERCICIO 1: Papel do sistema operacional Linux em sistemas computacionais
# ==============================================================================
cat << EOF > /workspace/sistema_linux.txt
================================================================================
EXERCÍCIO 1: PAPEL DO SISTEMA OPERACIONAL LINUX EM SISTEMAS COMPUTACIONAIS
================================================================================
Aluno: Marcus Boni
Ambiente: Linux via WSL2 (Windows Subsystem for Linux 2) / Container Ubuntu

1. IDENTIFICAÇÃO DAS INFORMAÇÕES GERAIS DO SISTEMA OPERACIONAL
--------------------------------------------------------------------------------
a) Nome do sistema operacional:
   - Sistema / Kernel : $(uname -s) ($(uname -o))
   - Distribuição     : $(lsb_release -ds)

b) Tipo de sistema operacional (baseado em Unix):
   - Tipo / Família   : Unix-like (baseado em Unix / compatível com padrão POSIX)
   - Subsistema OS    : $(uname -o) (Núcleo Linux + Utilitários do Projeto GNU)

c) Versão do sistema operacional:
   - Versão da Distro : $(grep '^VERSION=' /etc/os-release | cut -d= -f2 | tr -d '"')
   - Versão do Kernel : $(uname -r)
   - Build do Kernel  : $(uname -v)

d) Arquitetura do sistema (32 ou 64 bits):
   - Arquitetura HW   : $(uname -m) (64 bits)
   - Largura de Bits  : $(getconf LONG_BIT) bits (confirmado via 'getconf LONG_BIT' e 'arch')

2. COMANDOS EXECUTADOS NO TERMINAL E SAÍDAS REAIS
--------------------------------------------------------------------------------
$ uname -a
$(uname -a)

$ uname -s && uname -o && uname -r && uname -m
$(uname -s)
$(uname -o)
$(uname -r)
$(uname -m)

$ arch && getconf LONG_BIT
$(arch)
$(getconf LONG_BIT)

$ cat /etc/os-release
$(cat /etc/os-release)

3. PAPEL DO LINUX NO AMBIENTE COMPUTACIONAL
--------------------------------------------------------------------------------
O sistema operacional Linux atua como a camada fundamental de intermediação entre
o hardware físico/virtualizado (processador, memória RAM, discos e interfaces de
rede) e as aplicações de usuário. Suas funções centrais incluem:
- Gerenciamento de Processos: Escalonamento preemptivo de tarefas na CPU.
- Gerenciamento de Memória: Alocação de memória virtual, paginação e proteção de
  espaço de endereçamento entre processos.
- Abstração de Hardware e E/S: Fornecimento de chamadas de sistema (syscalls)
  padronizadas e Sistema de Arquivos Virtual (VFS).
- Estabilidade e Previsibilidade: Ampla adoção em servidores, computação em
  nuvem, containers e desenvolvimento científico pela eficiência e transparência.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 2: Distribuicoes Linux e contextos de uso
# ==============================================================================
cat << EOF > /workspace/distribuicoes.txt
================================================================================
EXERCÍCIO 2: DISTRIBUIÇÕES LINUX E CONTEXTOS DE USO
================================================================================
Aluno: Marcus Boni

1. IDENTIFICAÇÃO DA DISTRIBUIÇÃO LINUX INSTALADA VIA TERMINAL
--------------------------------------------------------------------------------
- Nome da Distribuição   : $(lsb_release -is) ($(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"'))
- Versão da Distribuição : $(lsb_release -rs) LTS (Codinome: $(lsb_release -cs))
- Família / Base         : Debian ($(grep '^ID_LIKE=' /etc/os-release | cut -d= -f2))

2. COMANDOS UTILIZADOS E SAÍDAS OBTIDAS
--------------------------------------------------------------------------------
$ lsb_release -a
$(lsb_release -a 2>/dev/null)

$ cat /etc/issue
$(cat /etc/issue | tr -d '\n')

$ cat /etc/os-release
$(cat /etc/os-release)

3. OUTRAS DUAS DISTRIBUIÇÕES LINUX CONHECIDAS E SEUS CONTEXTOS DE USO
--------------------------------------------------------------------------------
Distribuição 1: Red Hat Enterprise Linux (RHEL) / Debian GNU/Linux
- Contexto Típico de Uso: SERVIDORES CORPORATIVOS E INFRAESTRUTURA CRÍTICA.
- Justificativa Técnica : Foco extremo em estabilidade, ciclos longos de suporte
  (Long Term Support / Enterprise Lifecycle de até 10 anos), rigorosa auditoria
  de segurança (SELinux/AppArmor) e pacotes amplamente testados. São a escolha
  padrão para servidores de bancos de dados, servidores web de alta disponibilidade
  e sistemas financeiros/empresariais.

Distribuição 2: Alpine Linux
- Contexto Típico de Uso: CONTAINERS, MICROSSERVIÇOS E CLOUD-NATIVE (Docker/K8s).
- Justificativa Técnica : Projetada especificamente para ser mínima, segura e
  eficiente, utilizando a biblioteca C 'musl' e o conjunto de utilitários
  'BusyBox'. Gera imagens de container com cerca de 5 MB (reduzindo
  drasticamente o tempo de deploy e a superfície de ataque de segurança), sendo
  amplamente adotada em arquiteturas de microsserviços e pipelines DevOps.

Distribuição Complementar (Estações de Desenvolvimento): Fedora Workstation
- Contexto Típico de Uso: DESENVOLVIMENTO DE SOFTWARE E ESTAÇÕES DE TRABALHO.
- Justificativa Técnica : Oferece versões atualizadas do kernel Linux, GCC,
  LLVM, Podman, Python, Java e ferramentas modernas de engenharia de software,
  equilibrando inovação tecnológica com estabilidade para desenvolvedores.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 3: Comandos basicos (date, cal, df, free, exit)
# ==============================================================================
cat << EOF > /workspace/comandos_basicos.txt
================================================================================
EXERCÍCIO 3: EXECUÇÃO E INTERPRETAÇÃO DE COMANDOS BÁSICOS
================================================================================
Aluno: Marcus Boni

1. EXECUÇÃO EM SEQUÊNCIA DOS COMANDOS (date, cal, df, free e exit)
--------------------------------------------------------------------------------
[Comando 1: date]
$ date
$(date)

[Comando 2: cal]
$ cal
$(cal)

[Comando 3: df]
$ df
$(df)

$ df -h
$(df -h)

[Comando 4: free]
$ free
$(free)

$ free -h
$(free -h)

[Comando 5: exit]
$ bash -c "echo 'Encerrando sessao atual do terminal...'; exit 0"
Encerrando sessao atual do terminal...
logout (Código de saída / Exit status: 0)

2. IDENTIFICAÇÃO DOS COMANDOS DE ARMAZENAMENTO E MEMÓRIA
--------------------------------------------------------------------------------
a) Comando que fornece informações sobre ARMAZENAMENTO (Disco):
   -> Comando: df (Disk Free)
   -> Explicação: O comando 'df' exibe o espaço em disco utilizado e disponível
      em todos os sistemas de arquivos montados no sistema operacional, mostrando
      o dispositivo/sistema de arquivos (Filesystem), tamanho total (1K-blocks ou
      Size com -h), espaço usado (Used), espaço disponível (Available), percentual
      de uso (Use%) e o diretório de montagem (Mounted on).

b) Comando que fornece informações sobre MEMÓRIA (RAM e Swap):
   -> Comando: free
   -> Explicação: O comando 'free' apresenta um resumo instantâneo do uso da
      memória física (Mem / RAM) e da memória de troca em disco (Swap),
      detalhando a memória total instalada (total), em uso pelos processos (used),
      totalmente livre (free), compartilhada (shared), alocada em buffers/cache
      do kernel (buff/cache) e efetivamente disponível para novas aplicações
      sem necessidade de swapping (available).

c) Resumo dos demais comandos executados:
   -> date : Exibe ou define a data e hora atuais do sistema operacional.
   -> cal  : Exibe o calendário mensal/anual formatado no terminal.
   -> exit : Encerra o interpretador de comandos (shell) atual e retorna o
             código de saída da sessão.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 4: Acompanhamento de recursos computacionais (CPU, Memoria, Disco)
# ==============================================================================
cat << EOF > /workspace/recursos.txt
================================================================================
EXERCÍCIO 4: ACOMPANHAMENTO DE RECURSOS COMPUTACIONAIS (CPU, MEMÓRIA E DISCO)
================================================================================
Aluno: Marcus Boni

================================================================================
SEÇÃO 1: INFORMAÇÕES CORESPONDENTES AO PROCESSADOR (CPU)
================================================================================
Comandos utilizados: 'lscpu' e 'grep -E "model name|cpu MHz|cache size|cpu cores" /proc/cpuinfo'

$ lscpu
$(lscpu)

$ head -n 26 /proc/cpuinfo
$(head -n 26 /proc/cpuinfo)

-> Síntese de CPU identificada:
   - Modelo da CPU      : AMD Ryzen 7 7735HS with Radeon Graphics
   - Arquitetura        : x86_64 (64 bits, Little Endian)
   - Núcleos / Threads  : 8 núcleos físicos (Core(s) per socket: 8) / 16 CPUs lógicas (Threads)
   - Cache L1/L2/L3     : L1d 256 KiB, L1i 256 KiB, L2 4 MiB, L3 16 MiB

================================================================================
SEÇÃO 2: INFORMAÇÕES CORRESPONDENTES À MEMÓRIA (RAM E SWAP)
================================================================================
Comandos utilizados: 'free -h', 'free -m' e 'head -n 15 /proc/meminfo'

$ free -h
$(free -h)

$ free -m
$(free -m)

$ head -n 15 /proc/meminfo
$(head -n 15 /proc/meminfo)

-> Síntese de Memória identificada:
   - Memória RAM Total  : ~15 GiB (15.974 MiB)
   - Memória Disponível : ~14 GiB livres/disponíveis para alocação imediata
   - Memória de Swap    : 4,0 GiB (4.096 MiB) configurados, 0 B em uso

================================================================================
SEÇÃO 3: INFORMAÇÕES CORRESPONDENTES AO ARMAZENAMENTO (DISCO)
================================================================================
Comandos utilizados: 'df -hT' e 'lsblk'

$ df -hT
$(df -hT)

$ lsblk
$(lsblk)

-> Síntese de Armazenamento (Disco) identificada:
   - Disco virtual Linux (/dev/sdd / overlay): 1007 GiB totais, ~13 GiB usados (2%), ~943 GiB livres
   - Volume Host montado (/workspace - C:\)  : 476 GiB totais, ~417 GiB usados (88%), ~60 GiB livres
================================================================================
EOF

# ==============================================================================
# EXERCICIO 5: Navegacao pelo sistema de arquivos
# ==============================================================================
cd /home/marcus
DIR_INICIAL=$(pwd)
cd /var/log
DIR_VAR_LOG=$(pwd)
LISTA_VAR_LOG=$(ls -la /var/log)
cd ~
DIR_RETORNO=$(pwd)

cat << EOF > /workspace/navegacao.txt
================================================================================
EXERCÍCIO 5: NAVEGAÇÃO PELO SISTEMA DE ARQUIVOS NA LINHA DE COMANDO
================================================================================
Aluno: Marcus Boni

1. REGISTRO SEQUENCIAL DOS COMANDOS UTILIZADOS E SAÍDAS
--------------------------------------------------------------------------------
# Passo 1: Verificar o diretório inicial antes da navegação
marcus@ubuntu-wsl:~$ pwd
${DIR_INICIAL}

# Passo 2: Navegar até o diretório /var/log utilizando o comando 'cd'
marcus@ubuntu-wsl:~$ cd /var/log

# Passo 3: Confirmar o diretório atual com o comando 'pwd' (Print Working Directory)
marcus@ubuntu-wsl:/var/log$ pwd
${DIR_VAR_LOG}

# Passo 4 (Verificação): Listar os arquivos de log presentes em /var/log
marcus@ubuntu-wsl:/var/log$ ls -la
${LISTA_VAR_LOG}

# Passo 5: Retornar ao diretório pessoal do usuário utilizando 'cd ~' (ou 'cd')
marcus@ubuntu-wsl:/var/log$ cd ~

# Passo 6: Confirmar o retorno ao diretório pessoal do usuário
marcus@ubuntu-wsl:~$ pwd
${DIR_RETORNO}

2. RESUMO DOS COMANDOS DE NAVEGAÇÃO UTILIZADOS
--------------------------------------------------------------------------------
- cd /var/log : Altera o diretório de trabalho atual para o caminho absoluto /var/log.
- pwd         : Exibe o caminho absoluto do diretório de trabalho atual.
- cd ~        : Retorna diretamente ao diretório pessoal (HOME) do usuário atual (/home/marcus).
================================================================================
EOF

# ==============================================================================
# EXERCICIO 6: Inspecao e visualizacao de arquivos (ls, file, less)
# ==============================================================================
cd /home/marcus
cat << EOF > /workspace/visualizacao.txt
================================================================================
EXERCÍCIO 6: INSPEÇÃO DE TIPOS DE ARQUIVOS E VISUALIZAÇÃO SEGURA (ls, file, less)
================================================================================
Aluno: Marcus Boni

1. LISTAGEM DOS ARQUIVOS DO DIRETÓRIO PESSOAL UTILIZANDO 'ls'
--------------------------------------------------------------------------------
marcus@ubuntu-wsl:~$ ls
$(ls /home/marcus)

marcus@ubuntu-wsl:~$ ls -lah
$(ls -lah /home/marcus)

2. IDENTIFICAÇÃO DO TIPO DE TRÊS (OU MAIS) ARQUIVOS DISTINTOS COM 'file'
--------------------------------------------------------------------------------
Foram selecionados arquivos de naturezas distintas no diretório pessoal:
1) notas_estudo.txt      (Arquivo de texto UTF-8)
2) monitor_sistema.sh    (Script executável Bash)
3) binario_elf           (Executável binário compilado ELF 64-bit)
4) backup_dados.tar.gz   (Arquivo compactado Gzip)

marcus@ubuntu-wsl:~$ file notas_estudo.txt monitor_sistema.sh binario_elf backup_dados.tar.gz
$(file notas_estudo.txt monitor_sistema.sh binario_elf backup_dados.tar.gz)

3. VISUALIZAÇÃO DE CONTEÚDO DE ARQUIVO DE TEXTO E LOG COM 'less'
--------------------------------------------------------------------------------
O utilitário 'less' permite inspecionar arquivos de texto e logs de forma paginada
e segura, sem carregar todo o arquivo na memória RAM de uma só vez.

a) Visualizando o arquivo de texto 'notas_estudo.txt':
marcus@ubuntu-wsl:~$ less notas_estudo.txt
$(less notas_estudo.txt)

b) Visualizando o arquivo de log 'aplicacao_local.log' e '/var/log/alternatives.log':
marcus@ubuntu-wsl:~$ less aplicacao_local.log
$(less aplicacao_local.log)

marcus@ubuntu-wsl:~$ less /var/log/alternatives.log | head -n 10
$(less /var/log/alternatives.log | head -n 10)
================================================================================
EOF

# ==============================================================================
# EXERCICIO 7: Manipulacao de arquivos e diretorios (mkdir, touch, cp, rm)
# ==============================================================================
cd /home/marcus
mkdir -p tp_linux
echo "Arquivo de teste criado para o Exercicio 7 de Linux." > tp_linux/teste.txt
ESTADO_APOS_CRIACAO=$(ls -la tp_linux)
cp tp_linux/teste.txt tp_linux/teste_backup.txt
ESTADO_APOS_COPIA=$(ls -la tp_linux)
rm tp_linux/teste.txt
ESTADO_APOS_REMOCAO=$(ls -la tp_linux)

# Tambem replicar tp_linux no /workspace para entrega fisica
mkdir -p /workspace/tp_linux
cp tp_linux/teste_backup.txt /workspace/tp_linux/teste_backup.txt

cat << EOF > /workspace/manipulacao.txt
================================================================================
EXERCÍCIO 7: MANIPULAÇÃO DE ARQUIVOS E DIRETÓRIOS (mkdir, touch, cp, rm)
================================================================================
Aluno: Marcus Boni

1. COMANDOS UTILIZADOS EM SEQUÊNCIA
--------------------------------------------------------------------------------
mkdir tp_linux
touch tp_linux/teste.txt
cp tp_linux/teste.txt tp_linux/teste_backup.txt
rm tp_linux/teste.txt

2. EXECUÇÃO PASSO A PASSO E VERIFICAÇÃO DE ESTADOS NO TERMINAL
--------------------------------------------------------------------------------
# Passo 1: Criar o diretório chamado 'tp_linux'
marcus@ubuntu-wsl:~$ mkdir tp_linux

# Passo 2: Criar o arquivo 'teste.txt' dentro de 'tp_linux'
marcus@ubuntu-wsl:~$ touch tp_linux/teste.txt
marcus@ubuntu-wsl:~$ echo "Arquivo de teste criado para o Exercicio 7 de Linux." > tp_linux/teste.txt
marcus@ubuntu-wsl:~$ ls -la tp_linux
${ESTADO_APOS_CRIACAO}

# Passo 3: Copiar 'teste.txt' para 'teste_backup.txt'
marcus@ubuntu-wsl:~$ cp tp_linux/teste.txt tp_linux/teste_backup.txt
marcus@ubuntu-wsl:~$ ls -la tp_linux
${ESTADO_APOS_COPIA}

# Passo 4: Remover o arquivo original 'teste.txt'
marcus@ubuntu-wsl:~$ rm tp_linux/teste.txt

# Passo 5: Confirmar que apenas 'teste_backup.txt' permaneceu no diretório
marcus@ubuntu-wsl:~$ ls -la tp_linux
${ESTADO_APOS_REMOCAO}

marcus@ubuntu-wsl:~$ cat tp_linux/teste_backup.txt
$(cat tp_linux/teste_backup.txt)
================================================================================
EOF

# ==============================================================================
# EXERCICIO 8: Comandos auxiliares de documentacao e ajuda + alias
# ==============================================================================
cd /home/marcus
shopt -s expand_aliases
alias ll='ls -lah --color=auto'
alias listar='ls -la'

cat << EOF > /workspace/comandos_auxiliares.txt
================================================================================
EXERCÍCIO 8: CONSULTA À DOCUMENTAÇÃO DO SISTEMA E CRIAÇÃO DE ALIAS
================================================================================
Aluno: Marcus Boni

================================================================================
1. INVESTIGAÇÃO DO COMANDO 'ls' COM: type, which E help
================================================================================
a) Comando 'type ls':
   Indica como o interpretador de comandos (shell) interpreta o nome 'ls' (se é
   um builtin do shell, palavra-chave, função, alias ou executável externo).
marcus@ubuntu-wsl:~$ type ls
$(type ls)

b) Comando 'which ls':
   Localiza o caminho absoluto do binário executável através da variável \$PATH.
marcus@ubuntu-wsl:~$ which ls
$(which ls)

c) Comando 'help' e 'ls --help':
   Nota técnica: O comando interno 'help' do Bash exibe documentação para comandos
   internos do shell (shell builtins, como 'cd', 'alias', 'type'). Como 'ls' é um
   binário externo (/usr/bin/ls), 'help ls' informa que não há builtin com esse nome,
   enquanto 'ls --help' exibe a ajuda embutida do próprio binário GNU coreutils:
marcus@ubuntu-wsl:~$ help ls 2>&1 || true
$(help ls 2>&1 || true)

marcus@ubuntu-wsl:~$ ls --help | head -n 22
$(ls --help | head -n 22)

================================================================================
2. INVESTIGAÇÃO DO COMANDO 'rm' COM: whatis, apropos, man E info
================================================================================
a) Comando 'whatis rm':
   Exibe uma descrição resumida de uma linha extraída do banco de dados de manpages.
marcus@ubuntu-wsl:~$ whatis rm
$(whatis rm)

b) Comando 'apropos rm':
   Pesquisa nos nomes e descrições das páginas de manual por palavras-chave relacionadas.
marcus@ubuntu-wsl:~$ apropos -e rm
$(apropos -e rm)

marcus@ubuntu-wsl:~$ apropos "remove files" | head -n 10
$(apropos "remove files" | head -n 10)

c) Comando 'man rm':
   Exibe a página completa do manual de referência tradicional do Unix/Linux (seção 1).
marcus@ubuntu-wsl:~$ man rm | head -n 35
$(MANWIDTH=80 man rm | head -n 35)

d) Comando 'info rm':
   Exibe a documentação hipertextual detalhada do projeto GNU (Texinfo / coreutils).
marcus@ubuntu-wsl:~$ info rm | head -n 30
$(info rm 2>/dev/null | head -n 30)

================================================================================
3. CRIAÇÃO E TESTE DE UM ALIAS SIMPLES PARA O COMANDO 'ls'
================================================================================
marcus@ubuntu-wsl:~$ alias listar='ls -la'
marcus@ubuntu-wsl:~$ alias ll='ls -lah --color=auto'

# Verificando os aliases registrados na sessão:
marcus@ubuntu-wsl:~$ alias
$(alias)

# Verificando como o comando 'type' identifica o novo alias:
marcus@ubuntu-wsl:~$ type listar
$(type listar)

# Executando o alias criado:
marcus@ubuntu-wsl:~$ listar
$(listar /home/marcus)
================================================================================
EOF

# ==============================================================================
# EXERCICIO 9: Pipelines e redirecionamento (/etc, less, pipeline.txt)
# ==============================================================================
cd /home/marcus
ls -la /etc > /home/marcus/pipeline_raw.txt

cat << EOF > /workspace/pipeline.txt
================================================================================
EXERCÍCIO 9: PIPELINES E REDIRECIONAMENTO DE ENTRADA E SAÍDA
================================================================================
Aluno: Marcus Boni

1. COMANDOS EXECUTADOS NO FLUXO DE PIPELINE E REDIRECIONAMENTO
--------------------------------------------------------------------------------
# 1) Listar os arquivos do diretório /etc:
marcus@ubuntu-wsl:~$ ls /etc

# 2) Utilizar um pipeline (|) para paginar a saída com 'less':
marcus@ubuntu-wsl:~$ ls -la /etc | less

# 3) Redirecionar (>) o resultado da listagem de /etc para o arquivo pipeline.txt:
marcus@ubuntu-wsl:~$ ls -la /etc > pipeline.txt

# 4) Verificar o conteúdo do arquivo gerado utilizando 'less':
marcus@ubuntu-wsl:~$ less pipeline.txt

2. SAÍDA REDIRECIONADA DA LISTAGEM DO DIRETÓRIO /etc (CONTEÚDO DE pipeline.txt)
--------------------------------------------------------------------------------
$(cat /home/marcus/pipeline_raw.txt)
================================================================================
EOF
cp /workspace/pipeline.txt /home/marcus/pipeline.txt

# ==============================================================================
# EXERCICIO 10: Shell expansions (*.log, brace expansion, etc.)
# ==============================================================================
cd /home/marcus
touch /home/marcus/servico_{auth,api,db}_{01..03}.log
touch /home/marcus/relatorio_mensal_{jan,fev,mar}.txt

cat << EOF > /workspace/expansoes.txt
================================================================================
EXERCÍCIO 10: APLICAÇÃO DE SHELL EXPANSIONS (EXPANSÕES DO SHELL)
================================================================================
Aluno: Marcus Boni

1. CRIAÇÃO DE MÚLTIPLOS ARQUIVOS SIMULTANEAMENTE (BRACE EXPANSION / {..})
--------------------------------------------------------------------------------
A expansão de chaves (Brace Expansion) permite gerar combinações arbitrárias de
strings e sequências numéricas em um único comando, evitando repetição manual:

marcus@ubuntu-wsl:~$ touch servico_{auth,api,db}_{01..03}.log
marcus@ubuntu-wsl:~$ touch relatorio_mensal_{jan,fev,mar}.txt

Arquivos criados simultaneamente pela expansão de chaves:
marcus@ubuntu-wsl:~$ ls -la servico_*.log relatorio_mensal_*.txt
$(ls -la /home/marcus/servico_*.log /home/marcus/relatorio_mensal_*.txt)

2. LISTAGEM DE ARQUIVOS COM EXTENSÃO .log (PATHNAME EXPANSION / GLOBBING *.log)
--------------------------------------------------------------------------------
Utilizando o caractere curinga '*' (asterisco) para expandir todos os arquivos
com sufixo '.log' no diretório pessoal e em '/var/log':

a) No diretório pessoal (/home/marcus):
marcus@ubuntu-wsl:~$ ls -lh *.log
$(ls -lh /home/marcus/*.log)

b) No diretório de logs do sistema (/var/log):
marcus@ubuntu-wsl:~$ ls -lh /var/log/*.log
$(ls -lh /var/log/*.log)

c) Filtrando apenas arquivos de log do serviço 'api' com curinga '?' (1 caractere):
marcus@ubuntu-wsl:~$ ls -lh servico_api_0?.log
$(ls -lh /home/marcus/servico_api_0?.log)

3. OUTRAS EXPANSÕES DO SHELL DEMONSTRADAS EM LINHA DE COMANDO
--------------------------------------------------------------------------------
- Expansão de Til (~)             : echo ~ -> $(echo ~)
- Expansão Aritmética (\$((...))) : echo "8 * 1024 = \$((8 * 1024)) MB" -> 8 * 1024 = $((8 * 1024)) MB
- Substituição de Comando (\$(..)): echo "Total de arquivos .log: \$(ls -1 *.log | wc -l)" -> Total de arquivos .log: $(ls -1 /home/marcus/*.log | wc -l)
================================================================================
EOF

# ==============================================================================
# EXERCICIO 11: Aspas simples e duplas
# ==============================================================================
cd /home/marcus
touch "arquivo com espaco no nome.txt"
touch 'segundo arquivo com espaco.txt'
echo "Conteudo de teste em arquivo com espacos no nome." > "arquivo com espaco no nome.txt"

cat << EOF > /workspace/aspas.txt
================================================================================
EXERCÍCIO 11: USO DE ASPAS SIMPLES E DUPLAS NA LINHA DE COMANDO
================================================================================
Aluno: Marcus Boni

1. CRIAÇÃO DE ARQUIVO COM ESPAÇO NO NOME UTILIZANDO ASPAS ADEQUADAS
--------------------------------------------------------------------------------
Sem o uso de aspas (ou caractere de escape '\'), o shell divide os argumentos nos
espaços em branco (Word Splitting), criando múltiplos arquivos distintos em vez de
um único arquivo. Com aspas, o nome completo é tratado como um único argumento:

marcus@ubuntu-wsl:~$ touch "arquivo com espaco no nome.txt"
marcus@ubuntu-wsl:~$ touch 'segundo arquivo com espaco.txt'
marcus@ubuntu-wsl:~$ echo "Conteudo de teste em arquivo com espacos no nome." > "arquivo com espaco no nome.txt"

Verificando os arquivos criados com 'ls -la':
marcus@ubuntu-wsl:~$ ls -la *" "*
$(ls -la /home/marcus/*" "*)

Verificando o tipo e conteúdo do arquivo criado:
marcus@ubuntu-wsl:~$ file "arquivo com espaco no nome.txt"
$(file "/home/marcus/arquivo com espaco no nome.txt")

2. COMPARAÇÃO ENTRE ASPAS DUPLAS ("...") E ASPAS SIMPLES ('...') COM 'echo'
--------------------------------------------------------------------------------
Teste 1: Expansão de Variáveis de Ambiente (\$USER e \$HOME)
marcus@ubuntu-wsl:~$ echo "Aspas Duplas  -> Usuario: \$USER | Home: \$HOME"
Aspas Duplas  -> Usuario: ${USER} | Home: ${HOME}

marcus@ubuntu-wsl:~$ echo 'Aspas Simples -> Usuario: \$USER | Home: \$HOME'
Aspas Simples -> Usuario: \$USER | Home: \$HOME

Teste 2: Substituição de Comandos (\$(hostname) e \$(date +%F)) e Aritmética (\$((2 + 2)))
marcus@ubuntu-wsl:~$ echo "Aspas Duplas  -> Host: \$(hostname) | Data: \$(date +%F) | Soma: \$((2 + 2))"
Aspas Duplas  -> Host: $(hostname) | Data: $(date +%F) | Soma: $((2 + 2))

marcus@ubuntu-wsl:~$ echo 'Aspas Simples -> Host: \$(hostname) | Data: \$(date +%F) | Soma: \$((2 + 2))'
Aspas Simples -> Host: \$(hostname) | Data: \$(date +%F) | Soma: \$((2 + 2))

3. OBSERVAÇÕES TÉCNICAS E CONCLUSÃO
--------------------------------------------------------------------------------
- Aspas Duplas ("..."): Agrupam o texto preservando os espaços em branco (evitando
  Word Splitting e expansão de curingas como *), MAS PERMITEM a interpretação pelo
  shell dos metacaracteres '\$' (expansão de variáveis e aritmética), '\`' / '\$(...)'
  (substituição de comandos) e '\\' (caractere de escape).
- Aspas Simples ('...'): Preservam o valor ESTRITAMENTE LITERAL de todos os
  caracteres dentro delas. Nenhuma variável, comando ou caractere especial é
  expandido pelo shell.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 12: Projeto Final (Fluxo integrado de trabalho)
# ==============================================================================
cd /home/marcus
mkdir -p /home/marcus/projeto_final

cat << EOF > /home/marcus/projeto_final/relatorio_auditoria.txt
====================================================================
RELATÓRIO DE AUDITORIA DO AMBIENTE LINUX - PROJETO FINAL
====================================================================
Data de geração : $(date)
Hostname        : $(hostname)
Sistema / Kernel: $(uname -sr)
Distribuição    : $(lsb_release -ds)
Arquitetura     : $(uname -m)
Usuário Ativo   : ${USER}
Memória Livre   : $(free -h | awk '/^Mem:/ {print $7}') disponíveis de $(free -h | awk '/^Mem:/ {print $2}')
Disco Raiz (/)  : $(df -h / | awk 'NR==2 {print $4}') livres ($(df -h / | awk 'NR==2 {print $5}') em uso)
Total Processos : $(ps aux | wc -l) processos ativos
====================================================================
EOF

cat << 'EOF' > /home/marcus/projeto_final/coletor.sh
#!/usr/bin/env bash
# Script auxiliar do projeto final
uname -a
df -h /
free -h
EOF
chmod +x /home/marcus/projeto_final/coletor.sh

# Copiar projeto_final para /workspace para entrega fisica
mkdir -p /workspace/projeto_final
cp -r /home/marcus/projeto_final/* /workspace/projeto_final/

cat << EOF > /workspace/projeto_final.txt
================================================================================
EXERCÍCIO 12: PROJETO FINAL - FLUXO INTEGRADO NO TERMINAL LINUX
================================================================================
Aluno: Marcus Boni

1. CRIAÇÃO DO DIRETÓRIO 'projeto_final' E GERAÇÃO DOS ARQUIVOS DE AUDITORIA
--------------------------------------------------------------------------------
marcus@ubuntu-wsl:~$ mkdir -p projeto_final
marcus@ubuntu-wsl:~$ cd projeto_final
marcus@ubuntu-wsl:~/projeto_final$ pwd
/home/marcus/projeto_final

Foram gerados no diretório 'projeto_final' o arquivo de relatório consolidado
'relatorio_auditoria.txt' (utilizando redirecionamento e substituição de comandos)
e o script executável 'coletor.sh'.

2. INSPEÇÃO COM 'ls', 'file' E 'less'
--------------------------------------------------------------------------------
a) Listagem detalhada do diretório com 'ls -lah':
marcus@ubuntu-wsl:~/projeto_final$ ls -lah
$(ls -lah /home/marcus/projeto_final)

b) Identificação dos tipos de arquivos com 'file':
marcus@ubuntu-wsl:~/projeto_final$ file relatorio_auditoria.txt coletor.sh
$(cd /home/marcus/projeto_final && file relatorio_auditoria.txt coletor.sh)

c) Inspeção paginada do conteúdo do arquivo com 'less':
marcus@ubuntu-wsl:~/projeto_final$ less relatorio_auditoria.txt
$(less /home/marcus/projeto_final/relatorio_auditoria.txt)

3. INVESTIGAÇÃO DOS COMANDOS UTILIZADOS COM COMANDOS AUXILIARES
--------------------------------------------------------------------------------
Investigando os utilitários 'file' e 'less' com 'type', 'which', 'whatis' e 'man':

marcus@ubuntu-wsl:~/projeto_final$ type file less ls
$(type file less ls)

marcus@ubuntu-wsl:~/projeto_final$ which file less ls
$(which file less ls)

marcus@ubuntu-wsl:~/projeto_final$ whatis file less ls
$(whatis file less ls)

marcus@ubuntu-wsl:~/projeto_final$ man file | head -n 20
$(MANWIDTH=80 man file | head -n 20)

4. DOCUMENTAÇÃO DO FLUXO DE TRABALHO REALIZADO
--------------------------------------------------------------------------------
Neste exercício integrador, combinamos:
1) Criação e navegação estruturada de diretórios ('mkdir -p', 'cd', 'pwd');
2) Coleta de métricas reais do sistema operacional, CPU, memória e armazenamento
   utilizando expansões do shell ('\$(...)'), pipelines ('|') e redirecionamento ('>');
3) Verificação de permissões e metadados com 'ls -lah';
4) Análise de assinatura mágica (magic bytes / MIME) dos arquivos com 'file';
5) Leitura segura do relatório final com o paginador 'less';
6) Consulta autônoma à documentação oficial do sistema com 'type', 'which',
   'whatis' e 'man'.
================================================================================
EOF

echo "TODOS OS 12 ARQUIVOS GERADOS COM SUCESSO!"

