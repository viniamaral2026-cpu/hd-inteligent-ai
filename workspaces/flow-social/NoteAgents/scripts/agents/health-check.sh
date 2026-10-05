#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "FLOW SOCIAL — HEALTH CHECK"
echo

check() {
    local name="$1"
    local command="$2"

    if eval "$command" >/dev/null 2>&1; then
        printf '[PASS] %s\n' "$name"
    else
        printf '[FAIL] %s\n' "$name"
    fi
}

check "Git" "git --version"
check "Node.js" "node --version"
check "NPM" "npm --version"
check "PHP" "php --version"
check "Composer" "composer --version"
check "Docker" "docker --version"
check "Docker Compose" "docker compose version"

echo
echo "Project: $ROOT"
echo "Health check concluído."
