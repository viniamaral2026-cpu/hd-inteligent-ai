#!/usr/bin/env bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -f "$ROOT/.venv-agents/bin/activate" ]]; then
    source "$ROOT/.venv-agents/bin/activate"
fi

if [[ -f "$ROOT/.env.agents" ]]; then
    source "$ROOT/.env.agents"
fi

if [[ -z "${NVIDIA_API_KEY:-}" ]]; then
    echo "ERRO: NVIDIA_API_KEY não está configurada."
    echo
    echo 'Execute:'
    echo 'export NVIDIA_API_KEY="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"'
    return 1 2>/dev/null || exit 1
fi

export FLOW_ROOT="$ROOT"
export FLOW_AGENT_WORKSPACE="$ROOT"

echo "FLOW SOCIAL Agent Environment"
echo "-----------------------------"
echo "ROOT:   $FLOW_ROOT"
echo "MODEL:  $NVIDIA_MODEL"
echo "API:    $NVIDIA_API_BASE_URL"
echo "MODE:   $FLOW_AGENT_MODE"
echo
