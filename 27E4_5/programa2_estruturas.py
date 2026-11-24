#!/usr/bin/env python3
"""
Programa 2: Armazenamento, recuperação e manipulação em Hashtable, Pilha e Fila.

Lê uma listagem de arquivos gerada no Linux (ex.: lista_arquivos.txt), armazena os
caminhos em três estruturas de dados (Hashtable, Pilha e Fila), recupera os arquivos
nas posições 1, 100, 1000, 5000 e última posição, e executa adição e remoção de itens,
mensurando tempo de execução (time.perf_counter) e consumo de memória (tracemalloc).
"""

import argparse
from collections import deque
import gc
from pathlib import Path
import time
import tracemalloc
from typing import Callable, Protocol


QTD_OPERACOES_LOTE = 1000


class EstruturaDados(Protocol):
    """Interface comum para padronizar os testes entre as três estruturas."""

    def adicionar(self, valor: str) -> None: ...
    def remover(self) -> str: ...
    def obter_posicao(self, posicao: int) -> str: ...


class TabelaHash:
    """Estrutura de dados Hashtable (baseada em dict) indexada por posição 1-based."""

    def __init__(self) -> None:
        self._dados: dict[int, str] = {}
        self._proximo_indice = 1

    def adicionar(self, valor: str) -> None:
        self._dados[self._proximo_indice] = valor
        self._proximo_indice += 1

    def remover(self) -> str:
        if not self._dados:
            raise IndexError("Hashtable vazia.")
        self._proximo_indice -= 1
        return self._dados.pop(self._proximo_indice)

    def obter_posicao(self, posicao: int) -> str:
        if posicao not in self._dados:
            raise IndexError(f"Posição {posicao} inexistente na Hashtable.")
        return self._dados[posicao]

    def tamanho(self) -> int:
        return len(self._dados)


class Pilha:
    """Estrutura de dados Pilha (LIFO) utilizando apenas operações de topo."""

    def __init__(self) -> None:
        self._itens: list[str] = []

    def empilhar(self, valor: str) -> None:
        self._itens.append(valor)

    def desempilhar(self) -> str:
        if not self._itens:
            raise IndexError("Pilha vazia.")
        return self._itens.pop()

    def adicionar(self, valor: str) -> None:
        self.empilhar(valor)

    def remover(self) -> str:
        return self.desempilhar()

    def topo(self) -> str:
        if not self._itens:
            raise IndexError("Pilha vazia.")
        return self._itens[-1]

    def tamanho(self) -> int:
        return len(self._itens)

    def obter_posicao(self, posicao: int) -> str:
        """
        Recupera o elemento da 1-based `posicao` (1 = fundo, N = topo)
        respeitando a disciplina LIFO com uma pilha auxiliar.
        """
        total = len(self._itens)
        if posicao < 1 or posicao > total:
            raise IndexError(f"Posição {posicao} fora dos limites (1..{total}).")
        if posicao == total:
            return self.topo()

        auxiliar: list[str] = []
        for _ in range(total - posicao):
            auxiliar.append(self.desempilhar())

        alvo = self.topo()

        while auxiliar:
            self.empilhar(auxiliar.pop())

        return alvo


class Fila:
    """Estrutura de dados Fila (FIFO) utilizando apenas operações de frente e fim."""

    def __init__(self) -> None:
        self._itens: deque[str] = deque()

    def enfileirar(self, valor: str) -> None:
        self._itens.append(valor)

    def desenfileirar(self) -> str:
        if not self._itens:
            raise IndexError("Fila vazia.")
        return self._itens.popleft()

    def adicionar(self, valor: str) -> None:
        self.enfileirar(valor)

    def remover(self) -> str:
        return self.desenfileirar()

    def frente(self) -> str:
        if not self._itens:
            raise IndexError("Fila vazia.")
        return self._itens[0]

    def tamanho(self) -> int:
        return len(self._itens)

    def obter_posicao(self, posicao: int) -> str:
        """
        Recupera o elemento da 1-based `posicao` (1 = frente, N = fim)
        respeitando a disciplina FIFO por rotação completa da fila.
        """
        total = len(self._itens)
        if posicao < 1 or posicao > total:
            raise IndexError(f"Posição {posicao} fora dos limites (1..{total}).")
        if posicao == 1:
            return self.frente()

        alvo = ""
        for idx in range(1, total + 1):
            item = self.desenfileirar()
            if idx == posicao:
                alvo = item
            self.enfileirar(item)
        return alvo


def carregar_arquivos(caminho: Path) -> list[str]:
    """Lê os caminhos de arquivos não vazios do arquivo de texto."""
    with caminho.open("r", encoding="utf-8", errors="replace") as arquivo:
        return [linha.rstrip("\r\n") for linha in arquivo if linha.strip()]


def medir_operacao(funcao: Callable[[], object]) -> tuple[object, float, int, int]:
    """
    Executa `funcao` medindo tempo (s), variação líquida de memória (bytes) e
    pico adicional de memória durante a execução (bytes).
    """
    gc.collect()
    mem_antes, _ = tracemalloc.get_traced_memory()
    tracemalloc.reset_peak()

    inicio = time.perf_counter()
    resultado = funcao()
    duracao = time.perf_counter() - inicio

    mem_depois, pico_absoluto = tracemalloc.get_traced_memory()
    delta_mem = mem_depois - mem_antes
    pico_adicional = max(0, pico_absoluto - mem_antes)
    return resultado, duracao, delta_mem, pico_adicional


def registrar_metrica(
    estrutura: str,
    operacao: str,
    duracao: float,
    delta_bytes: int,
    pico_bytes: int,
) -> dict[str, object]:
    """Formata um registro de métrica de execução e consumo de memória."""
    return {
        "estrutura": estrutura,
        "operacao": operacao,
        "tempo_s": duracao,
        "delta_kib": delta_bytes / 1024.0,
        "pico_kib": pico_bytes / 1024.0,
    }


def avaliar_estrutura(
    nome: str,
    construtor: Callable[[], EstruturaDados],
    arquivos: list[str],
    posicoes: list[int],
    novos_itens: list[str],
) -> tuple[dict[int, str], list[dict[str, object]]]:
    """Executa carregamento, consultas, adições e remoções em uma estrutura."""
    estrutura = construtor()
    metricas: list[dict[str, object]] = []

    def carregar() -> None:
        for item in arquivos:
            estrutura.adicionar(item)

    _, t_carga, d_carga, p_carga = medir_operacao(carregar)
    metricas.append(
        registrar_metrica(
            nome, f"Armazenamento ({len(arquivos):,} itens)", t_carga, d_carga, p_carga
        )
    )

    recuperados: dict[int, str] = {}
    for pos in posicoes:
        valor, t_pos, d_pos, p_pos = medir_operacao(
            lambda p=pos: estrutura.obter_posicao(p)
        )
        recuperados[pos] = str(valor)
        metricas.append(
            registrar_metrica(nome, f"Consulta pos {pos}", t_pos, d_pos, p_pos)
        )

    def adicionar_lote() -> None:
        for item in novos_itens:
            estrutura.adicionar(item)

    _, t_add, d_add, p_add = medir_operacao(adicionar_lote)
    metricas.append(
        registrar_metrica(
            nome, f"Adição ({len(novos_itens):,} itens)", t_add, d_add, p_add
        )
    )

    def remover_lote() -> None:
        for _ in range(len(novos_itens)):
            estrutura.remover()

    _, t_rem, d_rem, p_rem = medir_operacao(remover_lote)
    metricas.append(
        registrar_metrica(
            nome, f"Remoção ({len(novos_itens):,} itens)", t_rem, d_rem, p_rem
        )
    )

    del estrutura
    gc.collect()
    return recuperados, metricas


def imprimir_arquivos_recuperados(
    recuperados_por_estrutura: dict[str, dict[int, str]],
    posicoes: list[int],
) -> None:
    """Imprime os nomes de arquivos recuperados e valida consistência entre estruturas."""
    referencia = next(iter(recuperados_por_estrutura.values()))
    for nome_estrutura, mapa in recuperados_por_estrutura.items():
        if mapa != referencia:
            raise AssertionError(
                f"Divergência nos arquivos recuperados em {nome_estrutura}."
            )

    print("\n=== Arquivos Recuperados (Consistentes nas 3 Estruturas) ===")
    for pos in posicoes:
        rotulo = (
            "Primeira (1)"
            if pos == 1
            else (f"Última ({pos})" if pos == posicoes[-1] else f"Posição {pos}")
        )
        print(f"  {rotulo:<16}: {referencia[pos]}")


def imprimir_metricas(todas_metricas: list[dict[str, object]]) -> None:
    """Imprime tabela comparativa de tempo e consumo de memória por operação."""
    print("\n=== Métricas de Tempo e Memória por Estrutura ===")
    cabecalho = (
        f"{'Estrutura':<15} | {'Operação':<30} | {'Tempo (ms)':>11} | "
        f"{'Delta Mem (KiB)':>15} | {'Pico Mem (KiB)':>14}"
    )
    print(cabecalho)
    print("-" * len(cabecalho))
    for item in todas_metricas:
        tempo_ms = float(item["tempo_s"]) * 1000.0
        print(
            f"{item['estrutura']:<15} | {item['operacao']:<30} | "
            f"{tempo_ms:>11.4f} | {item['delta_kib']:>15.2f} | "
            f"{item['pico_kib']:>14.2f}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Comparação de Hashtable, Pilha e Fila com listagem Linux."
    )
    parser.add_argument(
        "--arquivo",
        type=Path,
        default=Path(__file__).with_name("lista_arquivos.txt"),
        help="Caminho para o arquivo de listagem (padrão: lista_arquivos.txt).",
    )
    parser.add_argument(
        "--lote",
        type=int,
        default=QTD_OPERACOES_LOTE,
        help="Quantidade de itens no lote de adição/remoção (padrão: 1000).",
    )
    args = parser.parse_args()

    arquivos = carregar_arquivos(args.arquivo)
    total = len(arquivos)
    if total < 5000:
        raise ValueError(
            f"A listagem precisa ter pelo menos 5.000 arquivos (encontrados: {total})."
        )

    posicoes = [1, 100, 1000, 5000, total]
    novos_itens = [f"/tmp/teste_item_{i:04d}.txt" for i in range(1, args.lote + 1)]

    print(f"Arquivo carregado: {args.arquivo.name}")
    print(f"Total de registros lidos: {total:,}")
    print(f"Tamanho do lote de adição/remoção: {args.lote:,} itens")

    estruturas: list[tuple[str, Callable[[], EstruturaDados]]] = [
        ("Hashtable", TabelaHash),
        ("Pilha (LIFO)", Pilha),
        ("Fila (FIFO)", Fila),
    ]

    recuperados_por_estrutura: dict[str, dict[int, str]] = {}
    todas_metricas: list[dict[str, object]] = []

    tracemalloc.start()
    try:
        for nome, construtor in estruturas:
            rec, met = avaliar_estrutura(
                nome, construtor, arquivos, posicoes, novos_itens
            )
            recuperados_por_estrutura[nome] = rec
            todas_metricas.extend(met)
    finally:
        tracemalloc.stop()

    imprimir_arquivos_recuperados(recuperados_por_estrutura, posicoes)
    imprimir_metricas(todas_metricas)


if __name__ == "__main__":
    main()
