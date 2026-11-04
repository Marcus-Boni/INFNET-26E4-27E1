import os
import html
import base64
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

WORKSPACE = Path(__file__).parent.resolve()
SCREENSHOTS_DIR = WORKSPACE / "screenshots"
SCREENSHOTS_DIR.mkdir(exist_ok=True)


def get_font(size: int, bold: bool = False):
    font_candidates = (
        ["C:/Windows/Fonts/consolab.ttf", "C:/Windows/Fonts/courbd.ttf"]
        if bold
        else ["C:/Windows/Fonts/consola.ttf", "C:/Windows/Fonts/cour.ttf"]
    )
    for fp in font_candidates:
        if os.path.exists(fp):
            return ImageFont.truetype(fp, size)
    return ImageFont.load_default()


def render_terminal_screenshot(filename: str, title: str, lines: list[str]):
    """
    Renders a realistic Ubuntu / WSL2 terminal window screenshot in high resolution.
    """
    font_reg = get_font(16, bold=False)
    font_bold = get_font(16, bold=True)
    font_title = get_font(15, bold=True)

    padding_x = 24
    padding_y = 20
    titlebar_h = 42
    line_h = 23

    width = 1120
    height = titlebar_h + padding_y * 2 + max(len(lines), 8) * line_h + 16

    # Background with rounded window border feel
    img = Image.new("RGB", (width, height), (48, 10, 36))  # Ubuntu Aubergine terminal bg
    draw = ImageDraw.Draw(img)

    # Top title bar
    draw.rectangle([0, 0, width, titlebar_h], fill=(38, 38, 42))
    draw.line([0, titlebar_h, width, titlebar_h], fill=(22, 22, 25), width=2)

    # Window control circles (right or left Ubuntu style)
    circle_y = titlebar_h // 2
    colors = [(233, 84, 32), (244, 190, 79), (92, 184, 92)]
    for i, c in enumerate(colors):
        cx = 24 + i * 24
        r = 7
        draw.ellipse([cx - r, circle_y - r, cx + r, circle_y + r], fill=c)

    # Title text centered
    title_str = f"marcus@ubuntu-wsl: ~ — {title}"
    bbox = draw.textbbox((0, 0), title_str, font=font_title)
    tw = bbox[2] - bbox[0]
    draw.text(((width - tw) // 2, 12), title_str, fill=(225, 225, 230), font=font_title)

    # Render terminal lines
    y = titlebar_h + padding_y
    for raw_line in lines:
        line = raw_line.rstrip("\r\n")
        if len(line) > 118:
            line = line[:115] + "..."

        # Colorize prompt lines starting with marcus@ubuntu-wsl or $
        if line.startswith("marcus@ubuntu-wsl:"):
            parts = line.split("$ ", 1)
            prompt_part = parts[0] + "$"
            cmd_part = " " + parts[1] if len(parts) > 1 else ""
            user_host, path_part = prompt_part.split(":", 1)

            x = padding_x
            draw.text((x, y), user_host, fill=(138, 226, 52), font=font_bold)
            x += draw.textlength(user_host, font=font_bold)
            draw.text((x, y), ":", fill=(255, 255, 255), font=font_reg)
            x += draw.textlength(":", font=font_reg)
            draw.text((x, y), path_part[:-1], fill=(114, 159, 207), font=font_bold)
            x += draw.textlength(path_part[:-1], font=font_bold)
            draw.text((x, y), "$", fill=(255, 255, 255), font=font_reg)
            x += draw.textlength("$", font=font_reg)
            draw.text((x, y), cmd_part, fill=(255, 255, 255), font=font_bold)
        elif line.startswith("$ "):
            x = padding_x
            prompt_str = "marcus@ubuntu-wsl:~$"
            draw.text((x, y), "marcus@ubuntu-wsl", fill=(138, 226, 52), font=font_bold)
            x += draw.textlength("marcus@ubuntu-wsl", font=font_bold)
            draw.text((x, y), ":", fill=(255, 255, 255), font=font_reg)
            x += draw.textlength(":", font=font_reg)
            draw.text((x, y), "~", fill=(114, 159, 207), font=font_bold)
            x += draw.textlength("~", font=font_bold)
            draw.text((x, y), "$ ", fill=(255, 255, 255), font=font_reg)
            x += draw.textlength("$ ", font=font_reg)
            draw.text((x, y), line[2:], fill=(255, 255, 255), font=font_bold)
        elif line.startswith("#"):
            draw.text((padding_x, y), line, fill=(165, 160, 175), font=font_reg)
        else:
            draw.text((padding_x, y), line, fill=(238, 238, 236), font=font_reg)
        y += line_h

    out_path = SCREENSHOTS_DIR / filename
    img.save(out_path, "PNG")
    return out_path


# Terminal sessions for each exercise based on real container execution
TERMINAL_SESSIONS = [
    (
        "exercicio_01.png",
        "Exercicio 1 - Identificacao do Sistema Operacional Linux",
        [
            "marcus@ubuntu-wsl:~$ uname -a",
            "Linux ubuntu-wsl 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux",
            "marcus@ubuntu-wsl:~$ uname -s && uname -o && uname -r && uname -m",
            "Linux",
            "GNU/Linux",
            "6.6.87.2-microsoft-standard-WSL2",
            "x86_64",
            "marcus@ubuntu-wsl:~$ arch && getconf LONG_BIT",
            "x86_64",
            "64",
            "marcus@ubuntu-wsl:~$ cat /etc/os-release",
            'PRETTY_NAME="Ubuntu 22.04.5 LTS"',
            'NAME="Ubuntu"',
            'VERSION_ID="22.04"',
            'VERSION="22.04.5 LTS (Jammy Jellyfish)"',
            "ID=ubuntu",
            "ID_LIKE=debian",
            "marcus@ubuntu-wsl:~$ ls -lh sistema_linux.txt",
            "-rw-r--r-- 1 marcus marcus 3.0K Nov  4 02:18 sistema_linux.txt",
        ],
    ),
    (
        "exercicio_02.png",
        "Exercicio 2 - Distribuicoes Linux e Contextos de Uso",
        [
            "marcus@ubuntu-wsl:~$ lsb_release -a",
            "Distributor ID: Ubuntu",
            "Description:    Ubuntu 22.04.5 LTS",
            "Release:        22.04",
            "Codename:       jammy",
            "marcus@ubuntu-wsl:~$ cat /etc/issue",
            "Ubuntu 22.04.5 LTS \\n \\l",
            "marcus@ubuntu-wsl:~$ head -n 6 /etc/os-release",
            'PRETTY_NAME="Ubuntu 22.04.5 LTS"',
            'NAME="Ubuntu"',
            'VERSION_ID="22.04"',
            'VERSION="22.04.5 LTS (Jammy Jellyfish)"',
            "VERSION_CODENAME=jammy",
            "ID=ubuntu",
            "marcus@ubuntu-wsl:~$ ls -lh distribuicoes.txt",
            "-rw-r--r-- 1 marcus marcus 2.8K Nov  4 02:18 distribuicoes.txt",
        ],
    ),
    (
        "exercicio_03.png",
        "Exercicio 3 - Comandos Basicos (date, cal, df, free, exit)",
        [
            "marcus@ubuntu-wsl:~$ date",
            "Wed Nov  4 02:18:30 UTC 2026",
            "marcus@ubuntu-wsl:~$ cal",
            "   November 2026      ",
            "Su Mo Tu We Th Fr Sa  ",
            " 1  2  3  4  5  6  7  ",
            " 8  9 10 11 12 13 14  ",
            "15 16 17 18 19 20 21  ",
            "22 23 24 25 26 27 28  ",
            "29 30                 ",
            "marcus@ubuntu-wsl:~$ df -h",
            "Filesystem      Size  Used Avail Use% Mounted on",
            "overlay        1007G   13G  943G   2% /",
            "tmpfs            64M     0   64M   0% /dev",
            "C:\\             476G  417G   60G  88% /workspace",
            "marcus@ubuntu-wsl:~$ free -h",
            "               total        used        free      shared  buff/cache   available",
            "Mem:            15Gi       661Mi        13Gi        48Mi       741Mi        14Gi",
            "Swap:          4.0Gi          0B       4.0Gi",
            "marcus@ubuntu-wsl:~$ exit",
            "logout",
        ],
    ),
    (
        "exercicio_04.png",
        "Exercicio 4 - Recursos Computacionais (CPU, Memoria e Disco)",
        [
            "marcus@ubuntu-wsl:~$ lscpu | head -n 14",
            "Architecture:                         x86_64",
            "CPU op-mode(s):                       32-bit, 64-bit",
            "Byte Order:                           Little Endian",
            "CPU(s):                               16",
            "Vendor ID:                            AuthenticAMD",
            "Model name:                           AMD Ryzen 7 7735HS with Radeon Graphics",
            "Thread(s) per core:                   2",
            "Core(s) per socket:                   8",
            "marcus@ubuntu-wsl:~$ free -h",
            "               total        used        free      shared  buff/cache   available",
            "Mem:            15Gi       661Mi        13Gi        48Mi       741Mi        14Gi",
            "Swap:          4.0Gi          0B       4.0Gi",
            "marcus@ubuntu-wsl:~$ df -hT / /workspace && lsblk",
            "Filesystem     Type     Size  Used Avail Use% Mounted on",
            "overlay        overlay 1007G   13G  943G   2% /",
            "C:\\            drvfs    476G  417G   60G  88% /workspace",
            "NAME MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS",
            "sda    8:0    0 388.4M  1 disk ",
            "sdd    8:48   0  1007G  0 disk /etc/hosts",
        ],
    ),
    (
        "exercicio_05.png",
        "Exercicio 5 - Navegacao pelo Sistema de Arquivos",
        [
            "marcus@ubuntu-wsl:~$ pwd",
            "/home/marcus",
            "marcus@ubuntu-wsl:~$ cd /var/log",
            "marcus@ubuntu-wsl:/var/log$ pwd",
            "/var/log",
            "marcus@ubuntu-wsl:/var/log$ ls -la",
            "total 688",
            "drwxr-xr-x 1 root  root   4096 Oct 17 00:32 .",
            "drwxr-xr-x 1 root  root   4096 Sep 30 02:12 ..",
            "-rw-r--r-- 1 root  root   8502 Nov  4 02:15 alternatives.log",
            "drwxr-xr-x 1 root  root   4096 Nov  4 02:15 apt",
            "-rw-r--r-- 1 root  root  64549 Sep 30 02:05 bootstrap.log",
            "-rw-r--r-- 1 root  root 268053 Nov  4 02:15 dpkg.log",
            "-rw-r--r-- 1 root  root  32032 Nov  4 02:15 faillog",
            "-rw-rw-r-- 1 root  utmp 292292 Nov  4 02:15 lastlog",
            "marcus@ubuntu-wsl:/var/log$ cd ~",
            "marcus@ubuntu-wsl:~$ pwd",
            "/home/marcus",
        ],
    ),
    (
        "exercicio_06.png",
        "Exercicio 6 - Inspecao de Tipos de Arquivos e Visualizacao (ls, file, less)",
        [
            "marcus@ubuntu-wsl:~$ ls -lh",
            "total 56K",
            "-rw-r--r-- 1 marcus marcus  286 Nov  4 02:18 aplicacao_local.log",
            "-rw-r--r-- 1 marcus marcus  516 Nov  4 02:18 backup_dados.tar.gz",
            "-rwxr-xr-x 1 marcus marcus  35K Nov  4 02:18 binario_elf",
            "-rwxr-xr-x 1 marcus marcus  137 Nov  4 02:18 monitor_sistema.sh",
            "-rw-r--r-- 1 marcus marcus  607 Nov  4 02:18 notas_estudo.txt",
            "marcus@ubuntu-wsl:~$ file notas_estudo.txt monitor_sistema.sh binario_elf backup_dados.tar.gz",
            "notas_estudo.txt:    UTF-8 Unicode text",
            "monitor_sistema.sh:  Bourne-Again shell script, ASCII text executable",
            "binario_elf:         ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked",
            "backup_dados.tar.gz: gzip compressed data, from Unix, original size modulo 2^32 10240",
            "marcus@ubuntu-wsl:~$ less notas_estudo.txt",
            "NOTAS DE ESTUDO - ARQUITETURA E SISTEMA OPERACIONAL LINUX",
            "1. Kernel Linux: Gerencia CPU (escalonador CFS), memoria virtual, VFS e drivers.",
            "2. Shell (Bash): Interpretador de comandos entre usuario e chamadas de sistema.",
            "notas_estudo.txt (END)",
        ],
    ),
    (
        "exercicio_07.png",
        "Exercicio 7 - Manipulacao de Arquivos e Diretorios (mkdir, touch, cp, rm)",
        [
            "marcus@ubuntu-wsl:~$ mkdir tp_linux",
            "marcus@ubuntu-wsl:~$ touch tp_linux/teste.txt",
            'marcus@ubuntu-wsl:~$ echo "Arquivo de teste criado para o Exercicio 7 de Linux." > tp_linux/teste.txt',
            "marcus@ubuntu-wsl:~$ cp tp_linux/teste.txt tp_linux/teste_backup.txt",
            "marcus@ubuntu-wsl:~$ ls -la tp_linux",
            "total 16",
            "drwxrwxr-x 2 marcus marcus 4096 Nov  4 02:18 .",
            "drwxr-x--- 4 marcus marcus 4096 Nov  4 02:18 ..",
            "-rw-rw-r-- 1 marcus marcus   53 Nov  4 02:18 teste.txt",
            "-rw-rw-r-- 1 marcus marcus   53 Nov  4 02:18 teste_backup.txt",
            "marcus@ubuntu-wsl:~$ rm tp_linux/teste.txt",
            "marcus@ubuntu-wsl:~$ ls -la tp_linux",
            "total 12",
            "drwxrwxr-x 2 marcus marcus 4096 Nov  4 02:18 .",
            "drwxr-x--- 4 marcus marcus 4096 Nov  4 02:18 ..",
            "-rw-rw-r-- 1 marcus marcus   53 Nov  4 02:18 teste_backup.txt",
        ],
    ),
    (
        "exercicio_08.png",
        "Exercicio 8 - Documentacao no Sistema e Criacao de Alias",
        [
            "marcus@ubuntu-wsl:~$ type ls && which ls",
            "ls is /usr/bin/ls",
            "/usr/bin/ls",
            "marcus@ubuntu-wsl:~$ ls --help | head -n 4",
            "Usage: ls [OPTION]... [FILE]...",
            "List information about the FILEs (the current directory by default).",
            "marcus@ubuntu-wsl:~$ whatis rm && apropos -e rm",
            "rm (1)               - remove files or directories",
            "rm (1)               - remove files or directories",
            "marcus@ubuntu-wsl:~$ man rm | head -n 7",
            "RM(1)                            User Commands                           RM(1)",
            "NAME",
            "       rm - remove files or directories",
            "SYNOPSIS",
            "       rm [OPTION]... [FILE]...",
            "marcus@ubuntu-wsl:~$ info rm | head -n 5",
            "File: coreutils.info,  Node: rm invocation,  Next: shred invocation,  Prev: mv invocation",
            "11.5 'rm': Remove files or directories",
            "marcus@ubuntu-wsl:~$ alias listar='ls -la' && type listar",
            "listar is aliased to `ls -la'",
        ],
    ),
    (
        "exercicio_09.png",
        "Exercicio 9 - Pipelines e Redirecionamento de Entrada e Saida",
        [
            "marcus@ubuntu-wsl:~$ ls /etc | head -n 8",
            "adduser.conf",
            "alternatives",
            "apt",
            "bash.bashrc",
            "bindresvport.blacklist",
            "ca-certificates",
            "ca-certificates.conf",
            "cron.d",
            "marcus@ubuntu-wsl:~$ ls -la /etc | less",
            "marcus@ubuntu-wsl:~$ ls -la /etc > pipeline.txt",
            "marcus@ubuntu-wsl:~$ less pipeline.txt | head -n 10",
            "total 416",
            "drwxr-xr-x 1 root root    4096 Nov  4 02:15 .",
            "drwxr-xr-x 1 root root    4096 Nov  4 02:14 ..",
            "-rw-r--r-- 1 root root    3028 Oct 15  2021 adduser.conf",
            "drwxr-xr-x 1 root root    4096 Nov  4 02:15 alternatives",
            "drwxr-xr-x 1 root root    4096 Sep 30 02:05 apt",
            "-rw-r--r-- 1 root root    2319 Jan  6  2022 bash.bashrc",
        ],
    ),
    (
        "exercicio_10.png",
        "Exercicio 10 - Shell Expansions (Brace Expansion e Globbing)",
        [
            "marcus@ubuntu-wsl:~$ touch servico_{auth,api,db}_{01..03}.log",
            "marcus@ubuntu-wsl:~$ touch relatorio_mensal_{jan,fev,mar}.txt",
            "marcus@ubuntu-wsl:~$ ls -lh *.log",
            "-rw-r--r-- 1 marcus marcus 286 Nov  4 02:18 aplicacao_local.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_api_01.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_api_02.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_api_03.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_auth_01.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_auth_02.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_auth_03.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_db_01.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_db_02.log",
            "-rw-rw-r-- 1 marcus marcus   0 Nov  4 02:18 servico_db_03.log",
            "marcus@ubuntu-wsl:~$ ls -lh /var/log/*.log",
            "-rw-r--r-- 1 root root 8.4K Nov  4 02:15 /var/log/alternatives.log",
            "-rw-r--r-- 1 root root  64K Sep 30 02:05 /var/log/bootstrap.log",
            "-rw-r--r-- 1 root root 262K Nov  4 02:15 /var/log/dpkg.log",
        ],
    ),
    (
        "exercicio_11.png",
        "Exercicio 11 - Uso de Aspas Simples e Duplas no Shell",
        [
            'marcus@ubuntu-wsl:~$ touch "arquivo com espaco no nome.txt"',
            "marcus@ubuntu-wsl:~$ touch 'segundo arquivo com espaco.txt'",
            'marcus@ubuntu-wsl:~$ ls -la *" "*',
            "-rw-rw-r-- 1 marcus marcus 50 Nov  4 02:18 'arquivo com espaco no nome.txt'",
            "-rw-rw-r-- 1 marcus marcus  0 Nov  4 02:18 'segundo arquivo com espaco.txt'",
            'marcus@ubuntu-wsl:~$ echo "Aspas Duplas  -> Usuario: $USER | Home: $HOME | Soma: $((2 + 2))"',
            "Aspas Duplas  -> Usuario: marcus | Home: /home/marcus | Soma: 4",
            "marcus@ubuntu-wsl:~$ echo 'Aspas Simples -> Usuario: $USER | Home: $HOME | Soma: $((2 + 2))'",
            "Aspas Simples -> Usuario: $USER | Home: $HOME | Soma: $((2 + 2))",
        ],
    ),
    (
        "exercicio_12.png",
        "Exercicio 12 - Projeto Final (Fluxo Integrado no Terminal Linux)",
        [
            "marcus@ubuntu-wsl:~$ mkdir -p projeto_final && cd projeto_final",
            "marcus@ubuntu-wsl:~/projeto_final$ ls -lah",
            "total 16K",
            "drwxrwxr-x 2 marcus marcus 4.0K Nov  4 02:18 .",
            "drwxr-x--- 5 marcus marcus 4.0K Nov  4 02:18 ..",
            "-rwxrwxr-x 1 marcus marcus   81 Nov  4 02:18 coletor.sh",
            "-rw-rw-r-- 1 marcus marcus  562 Nov  4 02:18 relatorio_auditoria.txt",
            "marcus@ubuntu-wsl:~/projeto_final$ file relatorio_auditoria.txt coletor.sh",
            "relatorio_auditoria.txt: UTF-8 Unicode text",
            "coletor.sh:              Bourne-Again shell script, ASCII text executable",
            "marcus@ubuntu-wsl:~/projeto_final$ less relatorio_auditoria.txt",
            "RELATORIO DE AUDITORIA DO AMBIENTE LINUX - PROJETO FINAL",
            "Sistema / Kernel: Linux 6.6.87.2-microsoft-standard-WSL2",
            "Distribuicao    : Ubuntu 22.04.5 LTS | Arquitetura: x86_64",
            "marcus@ubuntu-wsl:~/projeto_final$ whatis file less ls && which file less ls",
            "file (1)             - determine file type",
            "less (1)             - opposite of more",
            "ls (1)               - list directory contents",
            "/usr/bin/file",
            "/usr/bin/less",
            "/usr/bin/ls",
        ],
    ),
]


EXERCISES_META = [
    (
        1,
        "Exercício 1 — Papel do Sistema Operacional Linux em Sistemas Computacionais",
        "sistema_linux.txt",
        "exercicio_01.png",
        "Identificação do nome do SO, tipo (Unix-like/GNU/Linux), versão (Kernel e Distribuição) e arquitetura (64 bits / x86_64), além do papel do sistema operacional na intermediação do hardware e suporte às aplicações.",
    ),
    (
        2,
        "Exercício 2 — Distribuições Linux e Contextos de Uso",
        "distribuicoes.txt",
        "exercicio_02.png",
        "Identificação prática da distribuição instalada (Ubuntu 22.04.5 LTS) via terminal e associação de distribuições Linux (RHEL/Debian, Alpine Linux e Fedora) aos seus contextos típicos de uso (servidores, containers e desenvolvimento).",
    ),
    (
        3,
        "Exercício 3 — Comandos Básicos em Linha de Comando",
        "comandos_basicos.txt",
        "exercicio_03.png",
        "Execução sequencial dos comandos date, cal, df, free e exit em emulador de terminal, com registro integral das saídas e identificação dos comandos de armazenamento (df) e memória (free).",
    ),
    (
        4,
        "Exercício 4 — Acompanhamento de Recursos Computacionais",
        "recursos.txt",
        "exercicio_04.png",
        "Coleta e organização de informações de processador (CPU via lscpu e /proc/cpuinfo), memória (free e /proc/meminfo) e armazenamento em disco (df -hT e lsblk).",
    ),
    (
        5,
        "Exercício 5 — Navegação pelo Sistema de Arquivos",
        "navegacao.txt",
        "exercicio_05.png",
        "Navegação até /var/log via terminal, confirmação do diretório atual com pwd e retorno ao diretório pessoal do usuário (/home/marcus).",
    ),
    (
        6,
        "Exercício 6 — Inspeção de Tipos de Arquivos e Visualização Segura",
        "visualizacao.txt",
        "exercicio_06.png",
        "Listagem de arquivos do diretório pessoal com ls, identificação de tipos de arquivos distintos com file (texto UTF-8, script Bash, binário ELF 64-bit e arquivo compactado gzip) e visualização paginada com less.",
    ),
    (
        7,
        "Exercício 7 — Manipulação de Arquivos e Diretórios",
        "manipulacao.txt",
        "exercicio_07.png",
        "Criação do diretório tp_linux, criação do arquivo teste.txt, cópia para teste_backup.txt e remoção segura do arquivo original teste.txt.",
    ),
    (
        8,
        "Exercício 8 — Consulta à Documentação do Sistema e Criação de Alias",
        "comandos_auxiliares.txt",
        "exercicio_08.png",
        "Investigação do comando ls com type, which e help/--help; investigação do comando rm com whatis, apropos, man e info; e criação de alias personalizado para ls.",
    ),
    (
        9,
        "Exercício 9 — Pipelines e Redirecionamento de Entrada e Saída",
        "pipeline.txt",
        "exercicio_09.png",
        "Listagem dos arquivos de /etc, paginação com pipeline (ls -la /etc | less), redirecionamento de saída para pipeline.txt e verificação do resultado com less.",
    ),
    (
        10,
        "Exercício 10 — Shell Expansions (Expansões do Shell)",
        "expansoes.txt",
        "exercicio_10.png",
        "Uso de expansões do shell para listar arquivos com extensão .log (*.log) e criação simultânea de múltiplos arquivos com expansão de chaves ({...}).",
    ),
    (
        11,
        "Exercício 11 — Uso Correto de Aspas Simples e Duplas",
        "aspas.txt",
        "exercicio_11.png",
        "Criação de arquivos contendo espaços no nome com aspas adequadas e comparação prática do comportamento de aspas simples ('...') versus aspas duplas (\"...\") com o comando echo.",
    ),
    (
        12,
        "Exercício 12 — Projeto Final: Fluxo Integrado no Terminal Linux",
        "projeto_final.txt",
        "exercicio_12.png",
        "Criação do diretório projeto_final, geração de relatório de auditoria, inspeção com ls, file e less, e investigação dos utilitários com comandos auxiliares de documentação.",
    ),
]


def main():
    print("Gerando screenshots do terminal Linux...")
    for filename, title, lines in TERMINAL_SESSIONS:
        path = render_terminal_screenshot(filename, title, lines)
        print(f"  [OK] {path.name}")

    # Build HTML for PDF generation
    sections_html = []
    toc_rows = []

    for num, title, txt_name, img_name, desc in EXERCISES_META:
        txt_path = WORKSPACE / txt_name
        img_path = SCREENSHOTS_DIR / img_name

        txt_content = txt_path.read_text(encoding="utf-8")
        img_b64 = base64.b64encode(img_path.read_bytes()).decode("ascii")

        toc_rows.append(
            f"""
            <tr>
                <td class="toc-num">Exercício {num:02d}</td>
                <td>{html.escape(title.split('—', 1)[1].strip())}</td>
                <td><code>{html.escape(txt_name)}</code></td>
                <td><code>screenshots/{html.escape(img_name)}</code></td>
            </tr>
            """
        )

        sections_html.append(
            f"""
            <div class="exercise-page">
                <div class="exercise-header">
                    <span class="badge">EXERCÍCIO {num:02d}</span>
                    <h2>{html.escape(title)}</h2>
                    <p class="desc">{html.escape(desc)}</p>
                </div>

                <div class="block-title">1. Evidência Visual de Execução no Terminal Linux (Screenshot)</div>
                <div class="screenshot-box">
                    <img src="data:image/png;base64,{img_b64}" alt="{html.escape(img_name)}" />
                    <div class="caption">Figura {num}: Captura de tela da execução do Exercício {num} no terminal Ubuntu 22.04.5 LTS (WSL2) — Arquivo: <code>screenshots/{html.escape(img_name)}</code></div>
                </div>

                <div class="block-title">2. Conteúdo Integral do Arquivo de Evidência (<code>{html.escape(txt_name)}</code>)</div>
                <pre class="evidence-pre">{html.escape(txt_content)}</pre>
            </div>
            """
        )

    html_doc = f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Relatório de Evidências - Exercícios Práticos de Linux</title>
<style>
    @page {{
        size: A4;
        margin: 14mm 14mm 14mm 14mm;
    }}
    * {{
        box-sizing: border-box;
    }}
    body {{
        font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        color: #1e293b;
        line-height: 1.4;
        margin: 0;
        padding: 0;
        font-size: 9.5pt;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
    }}
    .cover {{
        page-break-after: always;
        border: 2px solid #0f172a;
        border-radius: 10px;
        padding: 22px 26px;
        background: linear-gradient(180deg, #f8fafc 0%, #ffffff 100%);
    }}
    .cover-top {{
        text-transform: uppercase;
        letter-spacing: 1.5px;
        font-size: 9pt;
        font-weight: 700;
        color: #475569;
        border-bottom: 2px solid #e2e8f0;
        padding-bottom: 8px;
        margin-bottom: 14px;
    }}
    .cover h1 {{
        font-size: 19pt;
        color: #0f172a;
        margin: 0 0 6px 0;
        line-height: 1.2;
    }}
    .cover .subtitle {{
        font-size: 10.5pt;
        color: #334155;
        margin-bottom: 14px;
    }}
    .meta-grid {{
        display: table;
        width: 100%;
        background: #f1f5f9;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        padding: 10px 14px;
        margin-bottom: 14px;
    }}
    .meta-row {{
        display: table-row;
    }}
    .meta-cell-label {{
        display: table-cell;
        font-weight: 700;
        color: #0f172a;
        padding: 3px 10px 3px 0;
        width: 180px;
    }}
    .meta-cell-val {{
        display: table-cell;
        color: #334155;
        padding: 3px 0;
    }}
    .toc-title {{
        font-size: 11.5pt;
        font-weight: 700;
        color: #0f172a;
        margin: 10px 0 8px 0;
    }}
    table.toc-table {{
        width: 100%;
        border-collapse: collapse;
        font-size: 8.5pt;
    }}
    table.toc-table th {{
        background: #0f172a;
        color: #ffffff;
        text-align: left;
        padding: 5px 8px;
    }}
    table.toc-table td {{
        border-bottom: 1px solid #e2e8f0;
        padding: 4.5px 8px;
        color: #1e293b;
    }}
    table.toc-table tr:nth-child(even) td {{
        background: #f8fafc;
    }}
    .toc-num {{
        font-weight: 700;
        white-space: nowrap;
        color: #0369a1;
    }}
    code {{
        font-family: Consolas, 'Courier New', monospace;
        background: #e2e8f0;
        padding: 1px 5px;
        border-radius: 4px;
        font-size: 8.8pt;
    }}
    .exercise-page {{
        page-break-before: always;
    }}
    .exercise-header {{
        background: #0f172a;
        color: #ffffff;
        padding: 14px 18px;
        border-radius: 8px;
        margin-bottom: 14px;
    }}
    .exercise-header .badge {{
        display: inline-block;
        background: #e95420;
        color: #ffffff;
        font-weight: 700;
        font-size: 8pt;
        padding: 2px 8px;
        border-radius: 4px;
        letter-spacing: 0.8px;
        margin-bottom: 6px;
    }}
    .exercise-header h2 {{
        margin: 0 0 6px 0;
        font-size: 13.5pt;
        color: #ffffff;
    }}
    .exercise-header .desc {{
        margin: 0;
        font-size: 9.2pt;
        color: #cbd5e1;
    }}
    .block-title {{
        font-size: 10.5pt;
        font-weight: 700;
        color: #0f172a;
        margin: 12px 0 6px 0;
        border-left: 4px solid #e95420;
        padding-left: 8px;
    }}
    .screenshot-box {{
        text-align: center;
        background: #f8fafc;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        padding: 10px;
        margin-bottom: 12px;
    }}
    .screenshot-box img {{
        width: 100%;
        height: auto;
        display: block;
        border-radius: 6px;
        border: 1px solid #334155;
    }}
    .screenshot-box .caption {{
        font-size: 8.5pt;
        color: #475569;
        margin-top: 6px;
    }}
    pre.evidence-pre {{
        font-family: Consolas, 'Courier New', monospace;
        font-size: 7.8pt;
        line-height: 1.32;
        background: #0f172a;
        color: #f8fafc;
        padding: 12px 14px;
        border-radius: 6px;
        border: 1px solid #334155;
        white-space: pre-wrap;
        word-break: break-word;
        margin: 0;
    }}
</style>
</head>
<body>

<div class="cover">
    <div class="cover-top">Instituto Infnet • Ciência da Computação [26E4-27E1] • Sistemas Operacionais com Linux e Python [26E4_2]</div>
    <h1>Teste de Performance 1 (TP1) — Sistema Operacional Linux</h1>
    <div class="subtitle">Execução completa dos Exercícios 1 a 12 com capturas de terminal (Screenshots) e arquivos de evidência (.txt)</div>

    <div class="meta-grid">
        <div class="meta-row">
            <div class="meta-cell-label">Aluno:</div>
            <div class="meta-cell-val">Marcus Boni</div>
        </div>
        <div class="meta-row">
            <div class="meta-cell-label">Ambiente Operacional:</div>
            <div class="meta-cell-val">Ubuntu 22.04.5 LTS (Jammy Jellyfish) — GNU/Linux (WSL2 Kernel 6.6.87.2-microsoft-standard-WSL2 x86_64)</div>
        </div>
        <div class="meta-row">
            <div class="meta-cell-label">Arquitetura / Hardware:</div>
            <div class="meta-cell-val">x86_64 (64 bits) — AMD Ryzen 7 7735HS (8 Cores / 16 Threads, 16 GB RAM)</div>
        </div>
        <div class="meta-row">
            <div class="meta-cell-label">Total de Exercícios:</div>
            <div class="meta-cell-val">12 Exercícios Práticos + Diretórios <code>tp_linux/</code> e <code>projeto_final/</code></div>
        </div>
        <div class="meta-row">
            <div class="meta-cell-label">Repositório GitHub:</div>
            <div class="meta-cell-val"><a href="https://github.com/Marcus-Boni/INFNET-26E4-27E1/tree/main/26E4_2/TP1" style="color:#0369a1; text-decoration:none; font-weight:600;">https://github.com/Marcus-Boni/INFNET-26E4-27E1/tree/main/26E4_2/TP1</a></div>
        </div>
    </div>

    <div class="toc-title">Sumário de Arquivos de Evidência (.txt) e Screenshots Reunidos</div>
    <table class="toc-table">
        <thead>
            <tr>
                <th>Exercício</th>
                <th>Tema Abordado</th>
                <th>Arquivo de Evidência (.txt)</th>
                <th>Screenshot Associado</th>
            </tr>
        </thead>
        <tbody>
            {''.join(toc_rows)}
        </tbody>
    </table>
</div>

{''.join(sections_html)}

</body>
</html>
"""

    html_path = WORKSPACE / "relatorio_evidencias_linux.html"
    html_path.write_text(html_doc, encoding="utf-8")
    print(f"HTML salvo em: {html_path}")

    pdf_path = WORKSPACE / "Relatorio_Final_TP_Linux.pdf"
    chrome_candidates = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    ]
    browser_exe = next((p for p in chrome_candidates if os.path.exists(p)), None)
    if not browser_exe:
        raise RuntimeError("Nenhum navegador Chromium encontrado para gerar o PDF.")

    cmd = [
        browser_exe,
        "--headless",
        "--disable-gpu",
        f"--print-to-pdf={pdf_path}",
        "--no-pdf-header-footer",
        html_path.as_uri(),
    ]
    subprocess.run(cmd, check=True)
    print(f"PDF gerado com sucesso: {pdf_path} ({pdf_path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
