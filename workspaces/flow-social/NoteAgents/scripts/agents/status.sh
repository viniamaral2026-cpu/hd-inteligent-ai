#!/usr/bin/env bash

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "==============================================="
echo " FLOW SOCIAL - AGENT STATUS"
echo "==============================================="

echo
echo "[ROOT]"
echo "$ROOT"

echo
echo "[AGENTS]"

count=0

for dir in .agents/*; do
    [[ -d "$dir" ]] || continue

    name="$(basename "$dir")"

    if [[ -f "$dir/agent.md" ]] &&
       [[ -f "$dir/system.md" ]] &&
       [[ -f "$dir/contract.json" ]] &&
       [[ -f "$dir/state.json" ]]; then
        echo "  [OK] $name"
        count=$((count + 1))
    else
        echo "  [ERRO] $name"
    fi
done

echo
echo "Agentes válidos: $count"

echo
echo "[SCRIPTS]"

for script in scripts/agents/*.sh; do
    if [[ -x "$script" ]]; then
        echo "  [OK] $(basename "$script")"
    else
        echo "  [WARN] $(basename "$script") não executável"
    fi
done

echo
echo "[NVIDIA]"

if [[ -x scripts/agents/nvidia-client.sh ]]; then
    if scripts/agents/nvidia-client.sh health; then
        NVIDIA_STATUS="OK"
    else
        NVIDIA_STATUS="FAIL"
    fi
else
    NVIDIA_STATUS="MISSING"
fi

echo
echo "[SUMMARY]"
echo "Agents : $count"
echo "NVIDIA : $NVIDIA_STATUS"

if [[ "$NVIDIA_STATUS" != "OK" ]]; then
    exit 1
fi

echo
echo "FLOW SOCIAL AGENT SYSTEM: READY"
