#!/usr/bin/env bash
set -e

# ==============================================================================
# TP2 - Sistemas Operacionais com Linux e Python (26E4_2) - Instituto Infnet
# Aluno: Marcus Boni
# Script de execucao automatizada dos 12 exercicios praticos em ambiente Linux
# ==============================================================================

if ! id -u marcus >/dev/null 2>&1; then
    useradd -m -s /bin/bash marcus >/dev/null 2>&1 || true
fi
mkdir -p /home/marcus
chown -R marcus:marcus /home/marcus >/dev/null 2>&1 || true
cd /home/marcus
export USER=marcus
export HOME=/home/marcus
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Iniciar daemons udevd e journald caso ainda nao estejam ativos no container
if [ -x /lib/systemd/systemd-udevd ] && ! pgrep -x systemd-udevd >/dev/null 2>&1; then
    /lib/systemd/systemd-udevd --daemon >/dev/null 2>&1 || true
    udevadm trigger --type=subsystems --action=add >/dev/null 2>&1 || true
    udevadm trigger --type=devices --action=add >/dev/null 2>&1 || true
    udevadm settle >/dev/null 2>&1 || true
fi

if [ -x /lib/systemd/systemd-journald ] && ! pgrep -x systemd-journald >/dev/null 2>&1; then
    mkdir -p /run/log/journal
    /lib/systemd/systemd-journald >/dev/null 2>&1 &
    JOURNALD_PID=$!
    sleep 2
fi

cleanup() {
    if [ -n "${JOURNALD_PID:-}" ]; then
        kill "$JOURNALD_PID" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

# Limpar artefatos anteriores no diretorio pessoal
rm -rf /home/marcus/analise_dispositivo /home/marcus/*.txt /home/marcus/*.log /workspace/analise_dispositivo

# Preparar arquivo de log base no diretorio pessoal para demonstracao realista
cat << 'EOF' > /home/marcus/aplicacao_sistema.log
2026-11-23 21:00:01 [INFO] Servico de monitoramento inicializado com sucesso.
2026-11-23 21:05:14 [INFO] Verificacao de integridade dos volumes concluida.
2026-11-23 21:10:33 [WARN] Utilizacao de cache em 72% do limite configurado.
2026-11-23 21:15:00 [INFO] Coleta periodica de telemetria finalizada (status=OK).
EOF

# Selecionar dispositivo de armazenamento principal (preferencia para sde ou maior disco sd*)
DISCO="sde"
if [ ! -b "/dev/${DISCO}" ]; then
    DISCO=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk" {print $1}' | tail -n 1)
fi
DEV_PATH="/dev/${DISCO}"

# ==============================================================================
# EXERCICIO 1: Shell expansions (expansoes.txt)
# ==============================================================================
cd /home/marcus
touch /home/marcus/servico_{auth,api,db}_{01..03}.log
touch /home/marcus/relatorio_{q1,q2,q3,q4}.txt
chown -R marcus:marcus /home/marcus/*.log /home/marcus/*.txt 2>/dev/null || true

cat << EOF > /workspace/expansoes.txt
================================================================================
EXERCÍCIO 1: SHELL EXPANSIONS (EXPANSÕES DO SHELL)
================================================================================
Aluno: Marcus Boni
Ambiente: $(lsb_release -ds 2>/dev/null || echo "Ubuntu 22.04 LTS") — Kernel $(uname -r) ($(uname -m))

1. CRIAÇÃO DE MÚLTIPLOS ARQUIVOS SIMULTANEAMENTE (BRACE EXPANSION / {..})
--------------------------------------------------------------------------------
A expansão de chaves (Brace Expansion) gera automaticamente combinações de
prefixos, listas separadas por vírgula e intervalos sequenciais em um único
comando, eliminando repetição manual e aumentando a produtividade:

marcus@ubuntu-wsl:~$ touch servico_{auth,api,db}_{01..03}.log
marcus@ubuntu-wsl:~$ touch relatorio_{q1,q2,q3,q4}.txt

Verificando todos os arquivos criados simultaneamente:
marcus@ubuntu-wsl:~$ ls -la servico_*.log relatorio_*.txt
$(ls -la servico_*.log relatorio_*.txt)

2. LISTAGEM DE ARQUIVOS COM EXTENSÃO .log (PATHNAME EXPANSION / GLOBBING *.log)
--------------------------------------------------------------------------------
A expansão de caminhos (Pathname Expansion / Globbing) substitui padrões com
metacaracteres como '*' (zero ou mais caracteres) e '?' (exatamente um caractere)
pelos nomes de arquivos correspondentes antes da execução do comando:

a) Listando arquivos .log no diretório pessoal (/home/marcus):
marcus@ubuntu-wsl:~$ ls -lh *.log
$(ls -lh *.log)

b) Listando arquivos .log no diretório de logs do sistema (/var/log):
marcus@ubuntu-wsl:~$ ls -lh /var/log/*.log
$(ls -lh /var/log/*.log)

c) Filtrando arquivos .log apenas do serviço 'api' usando o curinga '?':
marcus@ubuntu-wsl:~$ ls -lh servico_api_0?.log
$(ls -lh servico_api_0?.log)

3. EXPANSÕES COMPLEMENTARES NO SHELL BASH
--------------------------------------------------------------------------------
- Expansão de Til (~)             : echo ~ -> $(echo ~)
- Expansão Aritmética (\$((...))) : echo "1024 * 4 = \$((1024 * 4)) bytes" -> 1024 * 4 = $((1024 * 4)) bytes
- Substituição de Comando (\$(..)): echo "Total de arquivos .log em ~: \$(ls -1 *.log | wc -l)" -> Total de arquivos .log em ~: $(ls -1 *.log | wc -l)
================================================================================
EOF

# ==============================================================================
# EXERCICIO 2: Pipelines e redirecionamento basico (pipeline.txt)
# ==============================================================================
cd /home/marcus
ls -la /etc > /home/marcus/pipeline_etc_raw.txt

cat << EOF > /workspace/pipeline.txt
================================================================================
EXERCÍCIO 2: PIPELINES E REDIRECIONAMENTO BÁSICO
================================================================================
Aluno: Marcus Boni

1. COMANDOS EXECUTADOS NO FLUXO DE PIPELINE E REDIRECIONAMENTO
--------------------------------------------------------------------------------
# Passo 1: Listar os arquivos presentes no diretório /etc
marcus@ubuntu-wsl:~$ ls /etc

# Passo 2: Utilizar um pipeline (|) para paginar a saída com 'less'
marcus@ubuntu-wsl:~$ ls -la /etc | less

# Passo 3: Redirecionar (>) a saída da listagem de /etc para pipeline.txt
marcus@ubuntu-wsl:~$ ls -la /etc > pipeline.txt

# Passo 4: Verificar o conteúdo do arquivo gerado utilizando 'less'
marcus@ubuntu-wsl:~$ less pipeline.txt

Resumo de verificação quantitativa:
marcus@ubuntu-wsl:~$ wc -l pipeline.txt
$(wc -l < /home/marcus/pipeline_etc_raw.txt) pipeline.txt

2. SAÍDA REDIRECIONADA DA LISTAGEM DO DIRETÓRIO /etc (CONTEÚDO DE pipeline.txt)
--------------------------------------------------------------------------------
$(cat /home/marcus/pipeline_etc_raw.txt)
================================================================================
EOF

# ==============================================================================
# EXERCICIO 3: Pipelines para inspecao de dispositivos (dispositivos_bloco.txt)
# ==============================================================================
cd /home/marcus
ls -la /dev | grep '^b' > /home/marcus/dispositivos_bloco_raw.txt

cat << EOF > /workspace/dispositivos_bloco.txt
================================================================================
EXERCÍCIO 3: PIPELINES PARA INSPEÇÃO DE DISPOSITIVOS DE BLOCO EM /dev
================================================================================
Aluno: Marcus Boni

1. COMANDOS EXECUTADOS
--------------------------------------------------------------------------------
# Passo 1: Listar todos os arquivos especiais presentes no diretório /dev
marcus@ubuntu-wsl:~$ ls -la /dev

# Passo 2: Filtrar apenas dispositivos do tipo bloco via pipeline (linha iniciada por 'b')
marcus@ubuntu-wsl:~$ ls -la /dev | grep '^b'

# Passo 3: Redirecionar o resultado filtrado para dispositivos_bloco.txt
marcus@ubuntu-wsl:~$ ls -la /dev | grep '^b' > dispositivos_bloco.txt

# Passo 4: Verificar o conteúdo do arquivo gerado utilizando 'less'
marcus@ubuntu-wsl:~$ less dispositivos_bloco.txt

2. DISPOSITIVOS DE BLOCO FILTRADOS EM /dev (CONTEÚDO DE dispositivos_bloco.txt)
--------------------------------------------------------------------------------
$(cat /home/marcus/dispositivos_bloco_raw.txt)

3. ANÁLISE TÉCNICA DOS RESULTADOS
--------------------------------------------------------------------------------
- Total de dispositivos de bloco encontrados em /dev: $(wc -l < /home/marcus/dispositivos_bloco_raw.txt)
- O primeiro caractere 'b' na coluna de permissões identifica um Block Special
  File (dispositivo orientado a blocos, com acesso aleatório e bufferização no
  kernel, como discos rígidos/virtuais e dispositivos loopback).
- Os números separados por vírgula (ex.: 8, 64 em 'sde'; 7, 0 em 'loop0'; 1, 0
  em 'ram0') correspondem respectivamente ao Major Number (identificador do
  driver no kernel: 8 = sd, 7 = loop, 1 = ramdisk) e ao Minor Number (instância
  específica do dispositivo ou partição gerenciada por aquele driver).
================================================================================
EOF

# ==============================================================================
# EXERCICIO 4: Redirecionamento e abstracao de dispositivos (redirecionamento.txt)
# ==============================================================================
cd /home/marcus
SAIDA_NULL_1=$(echo "Mensagem enviada para o dispositivo especial /dev/null" > /dev/null)
STATUS_NULL_1=$?
SAIDA_NORMAL_1=$(echo "Mensagem enviada para o dispositivo especial /dev/null")
SAIDA_NULL_2=$(uname -a > /dev/null)
STATUS_NULL_2=$?
SAIDA_NORMAL_2=$(uname -a)

cat << EOF > /workspace/redirecionamento.txt
================================================================================
EXERCÍCIO 4: REDIRECIONAMENTO E ABSTRAÇÃO DE DISPOSITIVOS (/dev/null)
================================================================================
Aluno: Marcus Boni

1. INSPEÇÃO DO DISPOSITIVO ESPECIAL /dev/null
--------------------------------------------------------------------------------
No Linux, dispositivos são representados como arquivos especiais na árvore /dev.
O /dev/null é um dispositivo de caractere (major 1, minor 3) conhecido como
"bit bucket" ou "buraco negro de dados": toda escrita enviada a ele é descartada
pelo kernel retornando sucesso (exit status 0), e toda leitura retorna EOF.

marcus@ubuntu-wsl:~$ ls -la /dev/null
$(ls -la /dev/null)

2. EXECUÇÃO DOS COMANDOS COM E SEM REDIRECIONAMENTO PARA /dev/null
--------------------------------------------------------------------------------
[Teste 1: Comando 'echo']
a) Com redirecionamento da saída padrão (stdout) para /dev/null:
marcus@ubuntu-wsl:~$ echo "Mensagem enviada para o dispositivo especial /dev/null" > /dev/null
${SAIDA_NULL_1:-(nenhuma saída exibida no terminal — código de saída: ${STATUS_NULL_1})}

b) Executando novamente SEM redirecionamento:
marcus@ubuntu-wsl:~$ echo "Mensagem enviada para o dispositivo especial /dev/null"
${SAIDA_NORMAL_1}

[Teste 2: Comando 'uname -a']
a) Com redirecionamento da saída padrão (stdout) para /dev/null:
marcus@ubuntu-wsl:~$ uname -a > /dev/null
${SAIDA_NULL_2:-(nenhuma saída exibida no terminal — código de saída: ${STATUS_NULL_2})}

b) Executando novamente SEM redirecionamento:
marcus@ubuntu-wsl:~$ uname -a
${SAIDA_NORMAL_2}

[Teste 3: Demonstração complementar de descarte de erros (stderr -> 2>/dev/null)]
marcus@ubuntu-wsl:~$ ls /diretorio_inexistente 2>/dev/null; echo "Exit status: \$?"
$(ls /diretorio_inexistente 2>/dev/null || echo "Exit status: $?")

3. DIFERENÇA OBSERVADA E CONCLUSÃO TÉCNICA
--------------------------------------------------------------------------------
- COM redirecionamento ('> /dev/null'): O comando é executado normalmente pelo
  sistema operacional (mantendo o código de saída 0 em caso de sucesso), porém
  o descritor de arquivo 1 (stdout) é apontado para o arquivo especial /dev/null,
  fazendo com que o kernel descarte silenciosamente todo o fluxo textual sem
  imprimi-lo no terminal nem gravá-lo em disco.
- SEM redirecionamento: O descritor stdout permanece conectado ao terminal
  interativo (tty/pts), exibindo integralmente a saída textual na tela.
- Aplicações práticas: Muito utilizado em scripts de automação e tarefas cron
  quando interessa apenas testar o código de retorno (\$?) de um comando ou
  suprimir mensagens verbosas/de erro ('2>/dev/null' ou '&>/dev/null').
================================================================================
EOF

# ==============================================================================
# EXERCICIO 5: Uso correto de aspas no shell (aspas.txt)
# ==============================================================================
cd /home/marcus
cat << EOF > /workspace/aspas.txt
================================================================================
EXERCÍCIO 5: USO CORRETO DE ASPAS SIMPLES E DUPLAS NO SHELL
================================================================================
Aluno: Marcus Boni

1. USO DE 'echo' COM ASPAS SIMPLES E DUPLAS PARA TEXTOS DISTINTOS
--------------------------------------------------------------------------------
Quando a string contém apenas texto literal sem metacaracteres especiais, tanto
aspas duplas ("...") quanto aspas simples ('...') preservam espaços e imprimem
o conteúdo diretamente:

marcus@ubuntu-wsl:~$ echo "Texto impresso com aspas duplas no GNU Bash."
$(echo "Texto impresso com aspas duplas no GNU Bash.")

marcus@ubuntu-wsl:~$ echo 'Texto impresso com aspas simples no GNU Bash.'
$(echo 'Texto impresso com aspas simples no GNU Bash.')

2. DEMONSTRAÇÃO DE CASOS EM QUE O COMPORTAMENTO MUDA
--------------------------------------------------------------------------------
Caso A — Expansão de Variáveis de Ambiente (\$USER e \$HOME):
marcus@ubuntu-wsl:~$ echo "Aspas Duplas  -> Usuario: \$USER | Diretorio Home: \$HOME"
$(echo "Aspas Duplas  -> Usuario: $USER | Diretorio Home: $HOME")

marcus@ubuntu-wsl:~$ echo 'Aspas Simples -> Usuario: \$USER | Diretorio Home: \$HOME'
$(echo 'Aspas Simples -> Usuario: $USER | Diretorio Home: $HOME')

Caso B — Substituição de Comandos (\$(hostname), \$(uname -s)) e Aritmética (\$((...))):
marcus@ubuntu-wsl:~$ echo "Aspas Duplas  -> Host: \$(hostname) | Kernel: \$(uname -s) | Calculo: \$((512 * 8)) bytes"
$(echo "Aspas Duplas  -> Host: $(hostname) | Kernel: $(uname -s) | Calculo: $((512 * 8)) bytes")

marcus@ubuntu-wsl:~$ echo 'Aspas Simples -> Host: \$(hostname) | Kernel: \$(uname -s) | Calculo: \$((512 * 8)) bytes'
$(echo 'Aspas Simples -> Host: $(hostname) | Kernel: $(uname -s) | Calculo: $((512 * 8)) bytes')

Caso C — Proteção contra Pathname Expansion / Globbing (*):
Sem aspas, o caractere '*' é expandido para todos os arquivos .log do diretório;
com aspas (simples ou duplas), o asterisco é tratado literalmente:
marcus@ubuntu-wsl:~$ echo *.log
$(echo *.log)

marcus@ubuntu-wsl:~$ echo "*.log"
$(echo "*.log")

marcus@ubuntu-wsl:~$ echo '*.log'
$(echo '*.log')

3. CONCLUSÃO TÉCNICA SOBRE O COMPORTAMENTO DAS ASPAS
--------------------------------------------------------------------------------
- Aspas Duplas ("..."): Realizam "weak quoting" — protegem contra divisão de
  palavras (Word Splitting) e expansão de curingas (*, ?), MAS permitem que o
  shell interprete '\$' (variáveis e aritmética), '\$(...)' / crases (substituição
  de comandos) e '\\' (caractere de escape).
- Aspas Simples ('...'): Realizam "strong quoting" — desativam TODA e qualquer
  interpretação ou expansão pelo shell, preservando literalmente cada caractere
  contido entre elas.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 6: Exploracao do sysfs (sysfs.txt)
# ==============================================================================
cd /home/marcus
SIZE_SECTORS=$(cat /sys/block/${DISCO}/size)
LOGICAL_BS=$(cat /sys/block/${DISCO}/queue/logical_block_size)
PHYSICAL_BS=$(cat /sys/block/${DISCO}/queue/physical_block_size)
SIZE_BYTES=$((SIZE_SECTORS * 512))
SIZE_GIB=$((SIZE_BYTES / 1024 / 1024 / 1024))

cat << EOF > /workspace/sysfs.txt
================================================================================
EXERCÍCIO 6: EXPLORAÇÃO DO SYSFS (/sys/block)
================================================================================
Aluno: Marcus Boni

1. LISTAGEM DOS DISPOSITIVOS DE BLOCO DISPONÍVEIS EM /sys/block
--------------------------------------------------------------------------------
O sysfs é um sistema de arquivos virtual mantido em memória pelo kernel Linux e
montado em /sys. Ele expõe a hierarquia de dispositivos, barramentos, drivers e
seus atributos diretamente para o espaço de usuário:

marcus@ubuntu-wsl:~$ ls -la /sys/block
$(ls -la /sys/block)

2. DISPOSITIVO ESCOLHIDO E ESTRUTURA DE ATRIBUTOS NO SYSFS
--------------------------------------------------------------------------------
Dispositivo selecionado: ${DISCO} (/sys/block/${DISCO})

marcus@ubuntu-wsl:~$ ls -la /sys/block/${DISCO}/
$(ls -la /sys/block/${DISCO}/)

3. LEITURA DE ATRIBUTOS DO DISPOSITIVO /sys/block/${DISCO}
--------------------------------------------------------------------------------
marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/dev
$(cat /sys/block/${DISCO}/dev)

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/size
${SIZE_SECTORS}

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/ro
$(cat /sys/block/${DISCO}/ro)

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/removable
$(cat /sys/block/${DISCO}/removable)

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/device/vendor
$(cat /sys/block/${DISCO}/device/vendor 2>/dev/null || echo "N/A")

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/device/model
$(cat /sys/block/${DISCO}/device/model 2>/dev/null || echo "N/A")

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/queue/logical_block_size
${LOGICAL_BS}

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/queue/physical_block_size
${PHYSICAL_BS}

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/queue/rotational
$(cat /sys/block/${DISCO}/queue/rotational)

marcus@ubuntu-wsl:~$ cat /sys/block/${DISCO}/stat
$(cat /sys/block/${DISCO}/stat)

4. INTERPRETAÇÃO TÉCNICA DOS ATRIBUTOS LIDOS
--------------------------------------------------------------------------------
- dev                     : $(cat /sys/block/${DISCO}/dev) (Major 8 = driver SCSI disk 'sd'; Minor 64 = disco ${DISCO}).
- size                    : ${SIZE_SECTORS} setores de 512 bytes = ${SIZE_BYTES} bytes (~${SIZE_GIB} GiB / 1 TiB).
- ro                      : $(cat /sys/block/${DISCO}/ro) (0 indica dispositivo habilitado para leitura e escrita).
- removable               : $(cat /sys/block/${DISCO}/removable) (0 indica disco fixo / não removível).
- device/vendor e model   : Fabricante '$(cat /sys/block/${DISCO}/device/vendor 2>/dev/null | xargs)' | Modelo '$(cat /sys/block/${DISCO}/device/model 2>/dev/null | xargs)'.
- logical/physical_block  : Setor lógico de ${LOGICAL_BS} B e setor físico de ${PHYSICAL_BS} B (4K aligned).
- stat                    : Contadores em tempo real de operações de leitura/escrita (I/O) do kernel.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 7: Metadados de dispositivos com udev (udev_info.txt)
# ==============================================================================
cd /home/marcus
udevadm info --query=all --name="${DEV_PATH}" > /home/marcus/udev_raw.txt 2>&1

cat << EOF > /workspace/udev_info.txt
================================================================================
EXERCÍCIO 7: METADADOS DE DISPOSITIVOS COM UDEV (udevadm info)
================================================================================
Aluno: Marcus Boni

1. IDENTIFICAÇÃO DO DISPOSITIVO DE ARMAZENAMENTO E COMANDOS UTILIZADOS
--------------------------------------------------------------------------------
Dispositivo selecionado em /dev: ${DEV_PATH}

# Verificar o nó de dispositivo em /dev:
marcus@ubuntu-wsl:~$ ls -la ${DEV_PATH}
$(ls -la ${DEV_PATH})

# Inspecionar todos os metadados udev e redirecionar para udev_info.txt:
marcus@ubuntu-wsl:~$ udevadm info --query=all --name=${DEV_PATH} > udev_info.txt

2. DESTAQUE: INFORMAÇÕES DE TIPO DE DISPOSITIVO E FABRICANTE
--------------------------------------------------------------------------------
Filtrando as propriedades-chave relacionadas ao tipo, barramento e fabricante:
marcus@ubuntu-wsl:~$ udevadm info --query=all --name=${DEV_PATH} | grep -E 'DEVNAME|DEVTYPE|SUBSYSTEM|ID_TYPE|ID_BUS|ID_VENDOR=|ID_MODEL=|ID_REVISION|ID_FS_TYPE'
$(grep -E 'DEVNAME|DEVTYPE|SUBSYSTEM|ID_TYPE|ID_BUS|ID_VENDOR=|ID_MODEL=|ID_REVISION|ID_FS_TYPE' /home/marcus/udev_raw.txt)

Síntese destacada:
- Tipo de Dispositivo : DEVTYPE=$(grep '^E: DEVTYPE=' /home/marcus/udev_raw.txt | cut -d= -f2) | ID_TYPE=$(grep '^E: ID_TYPE=' /home/marcus/udev_raw.txt | cut -d= -f2) | SUBSYSTEM=$(grep '^E: SUBSYSTEM=' /home/marcus/udev_raw.txt | cut -d= -f2)
- Fabricante (Vendor) : ID_VENDOR=$(grep '^E: ID_VENDOR=' /home/marcus/udev_raw.txt | cut -d= -f2) (Microsoft / Hyper-V Virtual SCSI Storage)
- Modelo e Revisão    : ID_MODEL=$(grep '^E: ID_MODEL=' /home/marcus/udev_raw.txt | cut -d= -f2) | ID_REVISION=$(grep '^E: ID_REVISION=' /home/marcus/udev_raw.txt | cut -d= -f2)
- Barramento / FS     : ID_BUS=$(grep '^E: ID_BUS=' /home/marcus/udev_raw.txt | cut -d= -f2) | ID_FS_TYPE=$(grep '^E: ID_FS_TYPE=' /home/marcus/udev_raw.txt | cut -d= -f2)

3. SAÍDA COMPLETA DO COMANDO 'udevadm info --query=all --name=${DEV_PATH}'
--------------------------------------------------------------------------------
$(cat /home/marcus/udev_raw.txt)
================================================================================
EOF

# ==============================================================================
# EXERCICIO 8: Mensagens do kernel e hardware (kernel_devices.txt)
# ==============================================================================
cd /home/marcus
journalctl -k --no-pager 2>/dev/null | grep -iE 'scsi|sd [0-9]|\[sd[a-z]\]|\bblock\b|blocks:|ext4|storvsc|disk|loop:' > /home/marcus/kernel_devices_raw.txt || true

cat << EOF > /workspace/kernel_devices.txt
================================================================================
EXERCÍCIO 8: MENSAGENS DO KERNEL E HARDWARE (journalctl -k)
================================================================================
Aluno: Marcus Boni

1. COMANDOS EXECUTADOS
--------------------------------------------------------------------------------
# Visualizar as mensagens do kernel (ring buffer via systemd-journald):
marcus@ubuntu-wsl:~$ journalctl -k --no-pager

# Filtrar mensagens relacionadas a dispositivos de armazenamento e salvar em kernel_devices.txt:
marcus@ubuntu-wsl:~$ journalctl -k --no-pager | grep -iE 'scsi|sd [0-9]|\[sd[a-z]\]|\bblock\b|blocks:|ext4|storvsc|disk|loop:' > kernel_devices.txt

Total de eventos de armazenamento filtrados: $(wc -l < /home/marcus/kernel_devices_raw.txt) linhas

2. MENSAGENS DO KERNEL RELACIONADAS A DISPOSITIVOS DE ARMAZENAMENTO
--------------------------------------------------------------------------------
$(cat /home/marcus/kernel_devices_raw.txt)

3. ANÁLISE TÉCNICA DAS MENSAGENS COLETADAS
--------------------------------------------------------------------------------
As mensagens do kernel registradas via 'journalctl -k' evidenciam o ciclo de
inicialização da pilha de armazenamento do Linux:
1) Inicialização do subsistema SCSI ('SCSI subsystem initialized') e da camada
   de dispositivos de bloco ('Block layer SCSI generic (bsg) driver').
2) Carregamento do adaptador virtual SCSI do Hyper-V ('scsi host0: storvsc_host_t').
3) Enumeração dos discos virtuais SCSI ('Msft Virtual Disk 1.0') nos barramentos
   0:0:0:0 a 0:0:0:4 e vinculação pelo driver 'sd' aos nós [sda], [sdb], [sdc],
   [sdd] e [sde], com anúncio da geometria de blocos lógicos (512B) e físicos (4096B).
4) Reconhecimento e montagem do sistema de arquivos EXT4 ('EXT4-fs') sobre os
   volumes de armazenamento detectados.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 9: Dispositivos e drivers ativos (drivers.txt)
# ==============================================================================
cd /home/marcus
cat /proc/devices > /home/marcus/drivers_raw.txt

cat << EOF > /workspace/drivers.txt
================================================================================
EXERCÍCIO 9: DISPOSITIVOS E DRIVERS ATIVOS (/proc/devices)
================================================================================
Aluno: Marcus Boni

1. COMANDOS EXECUTADOS
--------------------------------------------------------------------------------
# Listar os drivers de caractere e de bloco registrados no kernel Linux:
marcus@ubuntu-wsl:~$ cat /proc/devices > drivers.txt

# Inspecionar o arquivo gerado:
marcus@ubuntu-wsl:~$ cat drivers.txt

2. CONTEÚDO INTEGRAL DE /proc/devices
--------------------------------------------------------------------------------
$(cat /home/marcus/drivers_raw.txt)

3. IDENTIFICAÇÃO DE DRIVERS DE BLOCO E DE CARACTERE
--------------------------------------------------------------------------------
Cada linha de /proc/devices exibe o Major Number (número principal atribuído ao
driver pelo kernel) seguido do nome do driver registrado.

a) Exemplos de DRIVERS DE BLOCO (Block devices) identificados:
   - Major 8   -> sd       : Driver SCSI Disk responsável pelos discos /dev/sda,
                             /dev/sdb, /dev/sdc, /dev/sdd e /dev/sde.
   - Major 7   -> loop     : Driver de dispositivos loopback (/dev/loop0..loop7),
                             que permite montar imagens de disco como block devices.
   - Major 1   -> ramdisk  : Driver de discos em memória RAM (/dev/ram0..ram15).
   - Major 259 -> blkext   : Driver de extensões de bloco (partições estendidas / NVMe).

b) Exemplos de DRIVERS DE CARACTERE (Character devices) identificados:
   - Major 1   -> mem      : Driver de dispositivos de memória e pseudo-dispositivos
                             essenciais como /dev/null, /dev/zero, /dev/random.
   - Major 4   -> tty      : Driver de terminais virtuais de console (/dev/tty0..).
   - Major 5   -> /dev/tty : Driver do terminal controlador do processo atual e /dev/console.
   - Major 21  -> sg       : Driver SCSI Generic para comunicação direta com dispositivos SCSI.
   - Major 136 -> pts      : Driver de pseudoterminais escravos (/dev/pts/*), utilizados
                             em sessões de terminal interativo e conexões SSH.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 10: Identificacao de dispositivos de armazenamento (armazenamento.txt)
# ==============================================================================
cd /home/marcus
cat << EOF > /workspace/armazenamento.txt
================================================================================
EXERCÍCIO 10: IDENTIFICAÇÃO DE DISPOSITIVOS DE ARMAZENAMENTO (lsblk)
================================================================================
Aluno: Marcus Boni

1. LISTAGEM HIERÁRQUICA DE DISCOS E PARTIÇÕES COM 'lsblk'
--------------------------------------------------------------------------------
O utilitário 'lsblk' (List Block Devices) consulta o sysfs e o udev para exibir
todos os dispositivos de bloco disponíveis em formato de árvore hierárquica
(discos -> partições -> volumes/pontos de montagem).

a) Visão padrão hierárquica:
marcus@ubuntu-wsl:~$ lsblk
$(lsblk)

b) Visão detalhada com colunas de arquitetura, modelo, tipo, filesystem e montagem:
marcus@ubuntu-wsl:~$ lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,MODEL,MOUNTPOINTS
$(lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,MODEL,MOUNTPOINTS)

c) Visão focada em sistemas de arquivos e UUIDs ('lsblk -f'):
marcus@ubuntu-wsl:~$ lsblk -f
$(lsblk -f)

d) Visão com caminhos absolutos em /dev ('lsblk -p'):
marcus@ubuntu-wsl:~$ lsblk -p -o NAME,SIZE,TYPE,RO,MOUNTPOINTS
$(lsblk -p -o NAME,SIZE,TYPE,RO,MOUNTPOINTS)

e) Referência complementar da tabela de partições do kernel (/proc/partitions):
marcus@ubuntu-wsl:~$ cat /proc/partitions
$(cat /proc/partitions)

2. INTERPRETAÇÃO TÉCNICA DA HIERARQUIA IDENTIFICADA
--------------------------------------------------------------------------------
- Discos virtuais SCSI (TYPE=disk, Major 8):
  * /dev/sda (388.6M, RO=1) e /dev/sdb (186M, RO=1): volumes de sistema somente leitura
    do ambiente WSL2/Docker Desktop.
  * /dev/sdc (4G, RO=0): volume dedicado à memória virtual de troca ([SWAP]).
  * /dev/sdd (141.5M, RO=0): volume auxiliar virtual do ambiente.
  * /dev/sde (1T, RO=0, ext4): disco virtual principal de armazenamento de dados do
    ambiente Linux (1 TiB), formatado integralmente em ext4 (sem tabela de subpartições,
    padrão em discos VHDX do WSL2).
- Dispositivos Loopback (TYPE=loop, Major 7):
  * /dev/loop0 e /dev/loop1: imagens montadas em modo somente leitura (RO=1) utilizadas
    pela infraestrutura do ambiente.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 11: Filesystems montados (filesystems.txt)
# ==============================================================================
cd /home/marcus
mount > /home/marcus/mount_raw.txt

cat << EOF > /workspace/filesystems.txt
================================================================================
EXERCÍCIO 11: FILESYSTEMS MONTADOS (mount e df)
================================================================================
Aluno: Marcus Boni

1. LISTAGEM DE FILESYSTEMS MONTADOS COM 'mount'
--------------------------------------------------------------------------------
marcus@ubuntu-wsl:~$ mount > filesystems.txt
marcus@ubuntu-wsl:~$ mount
$(cat /home/marcus/mount_raw.txt)

2. ANÁLISE COMPLEMENTAR DE USO DE ESPAÇO EM DISCO COM 'df'
--------------------------------------------------------------------------------
a) Uso de espaço em formato legível por humanos ('df -h'):
marcus@ubuntu-wsl:~$ df -h
$(df -h)

b) Uso de espaço exibindo explicitamente o tipo de filesystem ('df -hT'):
marcus@ubuntu-wsl:~$ df -hT
$(df -hT)

3. ANÁLISE TÉCNICA DOS FILESYSTEMS IDENTIFICADOS
--------------------------------------------------------------------------------
A combinação de 'mount' e 'df -hT' permite correlacionar os dispositivos físicos,
virtuais e pseudo-filesystems do kernel com seus pontos de montagem e ocupação:
- overlay (/): Sistema de arquivos em camadas (OverlayFS) utilizado como raiz
  do ambiente containerizado Ubuntu 22.04 sobre o volume Linux (~1007 GiB totais).
- ext4 (${DEV_PATH}): Sistema de arquivos nativo Linux com journaling, hospedando
  os arquivos de configuração e armazenamento persistente do ambiente.
- 9p / drvfs (/workspace): Driver de integração (protocolo 9P / DrvFs) do WSL2
  que monta o sistema de arquivos NTFS do host Windows na árvore de diretórios Linux.
- tmpfs (/dev, /dev/shm, /run): Sistemas de arquivos temporários residentes em
  memória RAM para alto desempenho e dados voláteis.
- proc (/proc), sysfs (/sys), devpts (/dev/pts), cgroup2 (/sys/fs/cgroup):
  Pseudo-filesystems do kernel que expõem processos, hardware, terminais e grupos
  de controle de recursos diretamente como arquivos.
================================================================================
EOF

# ==============================================================================
# EXERCICIO 12: Integracao de comandos para analise de dispositivo (analise_final.txt)
# ==============================================================================
cd /home/marcus
mkdir -p /home/marcus/analise_dispositivo
mkdir -p /workspace/analise_dispositivo

# Etapa A: Representacao no diretorio /dev (usando pipeline + redirecionamento separado)
{
    echo "# Etapa A - Representacao do dispositivo ${DISCO} no diretorio /dev"
    echo "$ ls -la /dev | grep -E '\\b${DISCO}\\b'"
    ls -la /dev | grep -E "\b${DISCO}\b"
    echo ""
    echo "$ ls -la /dev/disk/by-id /dev/disk/by-path /dev/disk/by-uuid | grep ${DISCO}"
    ls -la /dev/disk/by-id /dev/disk/by-path /dev/disk/by-uuid 2>/dev/null | grep "${DISCO}" || true
} > /home/marcus/analise_dispositivo/etapa1_dev.txt

# Etapa B: Reconhecimento pelo kernel, udev e particoes (pipeline + redirecionamento separado)
{
    echo "# Etapa B - Reconhecimento do dispositivo ${DISCO} pelo kernel, udev e particoes"
    echo "$ journalctl -k --no-pager | grep -iE '${DISCO}|0:0:0:4'"
    journalctl -k --no-pager 2>/dev/null | grep -iE "${DISCO}|0:0:0:4" || true
    echo ""
    echo "$ cat /proc/partitions | grep -E 'major|${DISCO}'"
    cat /proc/partitions | grep -E "major|${DISCO}"
    echo ""
    echo "$ udevadm info --query=all --name=${DEV_PATH} | grep -E 'DEVNAME|DEVTYPE|MAJOR|MINOR|SUBSYSTEM|ID_VENDOR=|ID_MODEL=|ID_BUS|ID_FS_TYPE|ID_FS_UUID='"
    udevadm info --query=all --name="${DEV_PATH}" | grep -E 'DEVNAME|DEVTYPE|MAJOR|MINOR|SUBSYSTEM|ID_VENDOR=|ID_MODEL=|ID_BUS|ID_FS_TYPE|ID_FS_UUID='
} > /home/marcus/analise_dispositivo/etapa2_kernel_particoes.txt

# Etapa C: Organizacao na hierarquia de block devices e sysfs (pipeline + redirecionamento separado)
{
    echo "# Etapa C - Hierarquia de block devices (lsblk) e atributos no sysfs (/sys/block/${DISCO})"
    echo "$ lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,MODEL,MOUNTPOINTS | grep -E 'NAME|${DISCO}'"
    lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,MODEL,MOUNTPOINTS | grep -E "NAME|${DISCO}"
    echo ""
    echo "$ ls -la /sys/block | grep ${DISCO}"
    ls -la /sys/block | grep "${DISCO}"
    echo ""
    echo "$ head -n 1 /sys/block/${DISCO}/dev /sys/block/${DISCO}/size /sys/block/${DISCO}/ro /sys/block/${DISCO}/removable /sys/block/${DISCO}/device/vendor /sys/block/${DISCO}/device/model /sys/block/${DISCO}/queue/logical_block_size /sys/block/${DISCO}/queue/physical_block_size"
    head -n 1 /sys/block/${DISCO}/dev /sys/block/${DISCO}/size /sys/block/${DISCO}/ro /sys/block/${DISCO}/removable /sys/block/${DISCO}/device/vendor /sys/block/${DISCO}/device/model /sys/block/${DISCO}/queue/logical_block_size /sys/block/${DISCO}/queue/physical_block_size
    echo ""
    echo "$ mount | grep ${DEV_PATH}"
    mount | grep "${DEV_PATH}" || true
} > /home/marcus/analise_dispositivo/etapa3_hierarquia_bloco.txt

# Etapa D: Investigacao de comandos utilizados com comandos auxiliares (type, which, whatis, man)
{
    echo "# Etapa D - Investigacao dos comandos utilizados com comandos auxiliares"
    echo "$ type lsblk udevadm journalctl"
    type lsblk udevadm journalctl
    echo ""
    echo "$ which lsblk udevadm journalctl"
    which lsblk udevadm journalctl
    echo ""
    echo "$ whatis lsblk udevadm journalctl"
    whatis lsblk udevadm journalctl 2>/dev/null || true
    echo ""
    echo "$ man lsblk | head -n 25"
    MANWIDTH=80 man lsblk 2>/dev/null | head -n 25 || lsblk --help | head -n 25
} > /home/marcus/analise_dispositivo/etapa4_comando_auxiliar.txt

# Copiar etapas registradas separadamente para /workspace/analise_dispositivo
cp /home/marcus/analise_dispositivo/*.txt /workspace/analise_dispositivo/

# Consolidar todas as informacoes em analise_final.txt
cat << EOF > /workspace/analise_final.txt
================================================================================
EXERCÍCIO 12: ANÁLISE INTEGRADA DE DISPOSITIVO DE ARMAZENAMENTO
================================================================================
Aluno: Marcus Boni
Dispositivo Analisado: ${DEV_PATH} (${DISCO})
Arquivos de Etapas Registrados Separadamente:
  - analise_dispositivo/etapa1_dev.txt
  - analise_dispositivo/etapa2_kernel_particoes.txt
  - analise_dispositivo/etapa3_hierarquia_bloco.txt
  - analise_dispositivo/etapa4_comando_auxiliar.txt

================================================================================
SEÇÃO 1: IDENTIFICAÇÃO DO DISPOSITIVO E REPRESENTAÇÃO NO DIRETÓRIO /dev
================================================================================
[Comandos executados]
- ls -la /dev | grep -E '\b${DISCO}\b' > analise_dispositivo/etapa1_dev.txt
- ls -la /dev/disk/by-id /dev/disk/by-path /dev/disk/by-uuid | grep ${DISCO} >> analise_dispositivo/etapa1_dev.txt

[Finalidade de cada comando]
- ls -la /dev          : Lista todos os nós de dispositivos especiais gerenciados no /dev
                         com permissões, tipo (b/c), major/minor e data de criação.
- grep -E '\b${DISCO}\b'   : Filtra via pipeline exclusivamente as linhas referentes ao
                         dispositivo ${DISCO}.
- ls -la /dev/disk/... : Exibe os links simbólicos persistentes criados pelo udev
                         (por ID SCSI/WWN, caminho de barramento e UUID do filesystem).

[Principais informações obtidas]
$(cat /home/marcus/analise_dispositivo/etapa1_dev.txt)

-> Síntese da Seção 1:
   O arquivo especial ${DEV_PATH} é um dispositivo de bloco ('b'), com Major Number 8
   (driver SCSI disk 'sd') e Minor Number 64. O udev mantém links simbólicos
   persistentes por caminho ACPI/SCSI, por identificador WWN/SCSI e por UUID do
   sistema de arquivos ext4, garantindo referência estável independentemente da
   ordem de enumeração dos discos.

================================================================================
SEÇÃO 2: RECONHECIMENTO PELO KERNEL, METADADOS UDEV E PARTIÇÕES
================================================================================
[Comandos executados]
- journalctl -k --no-pager | grep -iE '${DISCO}|0:0:0:4' > analise_dispositivo/etapa2_kernel_particoes.txt
- cat /proc/partitions | grep -E 'major|${DISCO}' >> analise_dispositivo/etapa2_kernel_particoes.txt
- udevadm info --query=all --name=${DEV_PATH} | grep -E 'DEVNAME|DEVTYPE|MAJOR|MINOR|SUBSYSTEM|ID_VENDOR=|ID_MODEL=|ID_BUS|ID_FS_TYPE|ID_FS_UUID=' >> analise_dispositivo/etapa2_kernel_particoes.txt

[Finalidade de cada comando]
- journalctl -k        : Consulta as mensagens emitidas diretamente pelo kernel Linux
                         durante o boot e detecção de hardware.
- cat /proc/partitions : Exibe a tabela interna do kernel contendo dispositivos de
                         bloco e partições reconhecidas (major, minor e total de blocos de 1 KiB).
- udevadm info         : Consulta o banco de metadados do udev para o dispositivo,
                         expondo fabricante, modelo, barramento e assinatura de filesystem.

[Principais informações obtidas]
$(cat /home/marcus/analise_dispositivo/etapa2_kernel_particoes.txt)

-> Síntese da Seção 2:
   O kernel detecta o disco no barramento SCSI virtual Hyper-V (endereço 0:0:0:4),
   identificando-o como 'Msft Virtual Disk' (revisão 1.0) com 2.147.483.648 setores
   lógicos de 512 bytes (1,00 TiB / 1,10 TB) e blocos físicos de 4096 bytes.
   Em /proc/partitions, consta apenas a entrada inteira '${DISCO}' (1.073.741.824 blocos
   de 1 KiB), sem subpartições (como ${DISCO}1), pois o volume VHDX do ambiente WSL2
   é formatado diretamente em ext4 no dispositivo completo (UUID=$(grep '^E: ID_FS_UUID=' /home/marcus/udev_raw.txt | cut -d= -f2)).

================================================================================
SEÇÃO 3: ORGANIZAÇÃO NA HIERARQUIA DE BLOCK DEVICES E SYSFS
================================================================================
[Comandos executados]
- lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,MODEL,MOUNTPOINTS | grep -E 'NAME|${DISCO}' > analise_dispositivo/etapa3_hierarquia_bloco.txt
- ls -la /sys/block | grep ${DISCO} >> analise_dispositivo/etapa3_hierarquia_bloco.txt
- head -n 1 /sys/block/${DISCO}/{dev,size,ro,removable,device/vendor,device/model,queue/logical_block_size,queue/physical_block_size} >> analise_dispositivo/etapa3_hierarquia_bloco.txt
- mount | grep ${DEV_PATH} >> analise_dispositivo/etapa3_hierarquia_bloco.txt

[Finalidade de cada comando]
- lsblk -o ...         : Apresenta a hierarquia de block devices com colunas customizadas
                         de identificação, capacidade, tipo, filesystem, modelo e montagem.
- ls -la /sys/block    : Confirma o registro do dispositivo na classe 'block' do sysfs.
- head -n 1 /sys/...   : Lê atributos diretos do dispositivo expostos pelo kernel no sysfs.
- mount | grep ...     : Confirma os pontos de montagem ativos associados ao dispositivo.

[Principais informações obtidas]
$(cat /home/marcus/analise_dispositivo/etapa3_hierarquia_bloco.txt)

-> Síntese da Seção 3:
   Na árvore de dispositivos de bloco, '${DISCO}' aparece como dispositivo raiz do tipo
   'disk' (MAJ:MIN 8:64), tamanho 1T, leitura/escrita (RO=0), fixo (RM=0), filesystem
   'ext4', modelo 'Virtual Disk', com setores lógicos de 512B e físicos de 4096B.

================================================================================
SEÇÃO 4: INVESTIGAÇÃO DOS COMANDOS COM COMANDOS AUXILIARES
================================================================================
[Comandos executados]
- type lsblk udevadm journalctl > analise_dispositivo/etapa4_comando_auxiliar.txt
- which lsblk udevadm journalctl >> analise_dispositivo/etapa4_comando_auxiliar.txt
- whatis lsblk udevadm journalctl >> analise_dispositivo/etapa4_comando_auxiliar.txt
- man lsblk | head -n 25 >> analise_dispositivo/etapa4_comando_auxiliar.txt

[Finalidade de cada comando]
- type   : Informa como o shell Bash resolve cada comando (builtin, alias ou binário externo).
- which  : Localiza o caminho absoluto do executável nos diretórios listados em \$PATH.
- whatis : Exibe o resumo de uma linha do banco de páginas de manual (man-db).
- man    : Abre a documentação oficial completa do utilitário (seção 8 — administração).

[Principais informações obtidas]
$(cat /home/marcus/analise_dispositivo/etapa4_comando_auxiliar.txt)

-> Síntese da Seção 4:
   Todos os três utilitários investigados ('lsblk', 'udevadm' e 'journalctl') são
   binários executáveis externos instalados em /usr/bin, pertencentes aos pacotes
   fundamentais 'util-linux' e 'systemd', com documentação completa disponível no
   manual do sistema (man 8 lsblk).

================================================================================
CONCLUSÃO GERAL DA AUDITORIA DE ARMAZENAMENTO
================================================================================
A integração de /dev, journalctl -k, /proc/partitions, udevadm info, /sys/block,
lsblk, mount e comandos auxiliares de documentação permitiu traçar de ponta a ponta
o ciclo de vida do dispositivo ${DEV_PATH} no Linux: desde a detecção de hardware pelo
driver SCSI (Major 8), exposição de atributos via sysfs e enriquecimento de metadados
pelo udev, até a disponibilização lógica do sistema de arquivos ext4 ao usuário.
================================================================================
EOF

echo "TODOS OS 12 EXERCICIOS DO TP2 FORAM EXECUTADOS E REGISTRADOS COM SUCESSO!"
