#!/usr/bin/env python3
"""
Programa 1: Ordenação da listagem de arquivos do Linux e análise de desempenho.

Lê uma listagem de caminhos de arquivos gerada no Linux (ex.: lista_arquivos.txt),
executa os algoritmos Bubble Sort, Selection Sort e Insertion Sort sobre os dados,
verifica a corretude das ordenações e registra tempo de execução, comparações e
movimentações/trocas (incluindo escala progressiva para análise Big O).
"""

import argparse
from pathlib import Path
import time
from typing import Callable


def carregar_arquivos(caminho: Path) -> list[str]:
    """Lê os caminhos de arquivos não vazios do arquivo de texto."""
    with caminho.open("r", encoding="utf-8", errors="replace") as arquivo:
        return [linha.rstrip("\r\n") for linha in arquivo if linha.strip()]


def bubble_sort(itens: list[str]) -> tuple[list[str], int, int]:
    """
    Ordena uma cópia da lista usando Bubble Sort com parada antecipada.

    Retorna (lista_ordenada, total_comparacoes, total_trocas).
    """
    dados = itens.copy()
    n = len(dados)
    comparacoes = 0
    trocas = 0

    for i in range(n - 1):
        trocou = False
        for j in range(0, n - 1 - i):
            comparacoes += 1
            if dados[j] > dados[j + 1]:
                dados[j], dados[j + 1] = dados[j + 1], dados[j]
                trocas += 1
                trocou = True
        if not trocou:
            break

    return dados, comparacoes, trocas


def selection_sort(itens: list[str]) -> tuple[list[str], int, int]:
    """
    Ordena uma cópia da lista usando Selection Sort.

    Retorna (lista_ordenada, total_comparacoes, total_trocas).
    """
    dados = itens.copy()
    n = len(dados)
    comparacoes = 0
    trocas = 0

    for i in range(n - 1):
        indice_menor = i
        for j in range(i + 1, n):
            comparacoes += 1
            if dados[j] < dados[indice_menor]:
                indice_menor = j
        if indice_menor != i:
            dados[i], dados[indice_menor] = dados[indice_menor], dados[i]
            trocas += 1

    return dados, comparacoes, trocas


def insertion_sort(itens: list[str]) -> tuple[list[str], int, int]:
    """
    Ordena uma cópia da lista usando Insertion Sort.

    Retorna (lista_ordenada, total_comparacoes, total_deslocamentos).
    """
    dados = itens.copy()
    n = len(dados)
    comparacoes = 0
    deslocamentos = 0

    for i in range(1, n):
        chave = dados[i]
        j = i - 1
        while j >= 0:
            comparacoes += 1
            if dados[j] > chave:
                dados[j + 1] = dados[j]
                deslocamentos += 1
                j -= 1
            else:
                break
        dados[j + 1] = chave

    return dados, comparacoes, deslocamentos


def executar_algoritmo(
    nome: str,
    funcao: Callable[[list[str]], tuple[list[str], int, int]],
    dados: list[str],
    referencia_ordenada: list[str],
) -> dict[str, object]:
    """Executa um algoritmo de ordenação, mede o tempo e valida o resultado."""
    inicio = time.perf_counter()
    resultado, comparacoes, operacoes = funcao(dados)
    duracao = time.perf_counter() - inicio

    if resultado != referencia_ordenada:
        raise AssertionError(f"Falha na ordenação do algoritmo {nome}.")

    return {
        "algoritmo": nome,
        "tamanho": len(dados),
        "tempo_s": duracao,
        "comparacoes": comparacoes,
        "operacoes": operacoes,
    }


def imprimir_tabela_resultados(titulo: str, resultados: list[dict[str, object]]) -> None:
    """Exibe os resultados de execução formatados em tabela no terminal."""
    print(f"\n=== {titulo} ===")
    cabecalho = (
        f"{'Algoritmo':<16} | {'N':>7} | {'Tempo (s)':>11} | "
        f"{'Comparações':>14} | {'Trocas/Desloc.':>14}"
    )
    print(cabecalho)
    print("-" * len(cabecalho))
    for item in resultados:
        print(
            f"{item['algoritmo']:<16} | {item['tamanho']:>7} | "
            f"{item['tempo_s']:>11.6f} | {item['comparacoes']:>14,} | "
            f"{item['operacoes']:>14,}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Ordenação de listagem de arquivos Linux (Bubble, Selection, Insertion)."
    )
    parser.add_argument(
        "--arquivo",
        type=Path,
        default=Path(__file__).with_name("lista_arquivos.txt"),
        help="Caminho para o arquivo de listagem (padrão: lista_arquivos.txt).",
    )
    parser.add_argument(
        "--escala",
        action="store_true",
        help="Também executa testes de escala com N = 1000, 5000 e 10000.",
    )
    args = parser.parse_args()

    arquivos = carregar_arquivos(args.arquivo)
    total = len(arquivos)
    print(f"Arquivo carregado: {args.arquivo.name}")
    print(f"Total de registros lidos: {total:,}")

    algoritmos: list[tuple[str, Callable[[list[str]], tuple[list[str], int, int]]]] = [
        ("Bubble Sort", bubble_sort),
        ("Selection Sort", selection_sort),
        ("Insertion Sort", insertion_sort),
    ]

    if args.escala:
        tamanhos = [t for t in (1000, 5000, 10000) if t < total]
        resultados_escala: list[dict[str, object]] = []
        for tamanho in tamanhos:
            amostra = arquivos[:tamanho]
            referencia = sorted(amostra)
            for nome, funcao in algoritmos:
                resultados_escala.append(
                    executar_algoritmo(nome, funcao, amostra, referencia)
                )
        imprimir_tabela_resultados("Benchmark de Escala (Amostras)", resultados_escala)

    referencia_completa = sorted(arquivos)
    resultados_completos: list[dict[str, object]] = []
    for nome, funcao in algoritmos:
        resultados_completos.append(
            executar_algoritmo(nome, funcao, arquivos, referencia_completa)
        )

    imprimir_tabela_resultados(
        f"Ordenação Completa ({total:,} arquivos)", resultados_completos
    )
    print("\nAmostra dos 5 primeiros após ordenação:")
    for indice, caminho in enumerate(referencia_completa[:5], start=1):
        print(f"  {indice}: {caminho}")
    print("Amostra dos 5 últimos após ordenação:")
    for indice, caminho in enumerate(referencia_completa[-5:], start=total - 4):
        print(f"  {indice}: {caminho}")


if __name__ == "__main__":
    main()

