#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE="$ROOT/.agent-state"

mkdir -p "$STATE"/{logs,failures}

echo "============================================================"
echo " FLOW SOCIAL — ERROR FIXER"
echo "============================================================"
echo

ERROR_FILE="${1:-}"

if [[ -z "$ERROR_FILE" ]]; then
    echo "Uso:"
    echo
    echo "  ./scripts/agents/error-fixer.sh caminho/do/erro.log"
    echo
    exit 1
fi

if [[ ! -f "$ERROR_FILE" ]]; then
    echo "ERROR: arquivo não encontrado:"
    echo "$ERROR_FILE"
    exit 1
fi

cp "$ERROR_FILE" "$STATE/failures/$(basename "$ERROR_FILE")"

echo "Erro registrado em:"
echo "$STATE/failures/$(basename "$ERROR_FILE")"
echo
echo "O Error Fixer Runtime está preparado."
echo "A integração com o modelo NVIDIA será adicionada no próximo estágio."
