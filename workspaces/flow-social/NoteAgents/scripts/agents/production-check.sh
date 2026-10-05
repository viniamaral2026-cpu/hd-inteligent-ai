#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "============================================================"
echo " FLOW SOCIAL — PRODUCTION READINESS CHECK"
echo "============================================================"
echo

FAIL=0

check_file() {
    local file="$1"

    if [[ -f "$ROOT/$file" ]]; then
        echo "[PASS] $file"
    else
        echo "[PENDING] $file"
    fi
}

check_file "package.json"
check_file "docker-compose.yml"
check_file ".env.example"
check_file "apps/web/package.json"
check_file "apps/api/composer.json"

echo
echo "Production check inicial concluído."
echo "Nenhum deploy será executado automaticamente neste estágio."
