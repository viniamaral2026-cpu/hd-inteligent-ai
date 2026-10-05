#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -f "$ROOT/.env.agents" ]]; then
    set -a
    source "$ROOT/.env.agents"
    set +a
fi

NVIDIA_BASE_URL="${NVIDIA_BASE_URL:-https://integrate.api.nvidia.com/v1}"
NVIDIA_MODEL="${NVIDIA_MODEL:-nvidia/nemotron-3.5-lightning-30b-a3b}"
NVIDIA_API_KEY="${NVIDIA_API_KEY:-}"

if [[ -z "$NVIDIA_API_KEY" ]]; then
    echo "ERRO: NVIDIA_API_KEY não configurada."
    exit 10
fi

NVIDIA_ENDPOINT="${NVIDIA_BASE_URL%/}/chat/completions"

request() {
    local prompt="${1:-}"
    local system="${2:-You are the Flow Social engineering agent. Work directly on the repository. Be precise, production-oriented and never invent successful operations.}"

    if [[ -z "$prompt" ]]; then
        echo "ERRO: prompt vazio."
        exit 11
    fi

    curl --silent --show-error \
        --fail-with-body \
        --connect-timeout 15 \
        --max-time 600 \
        -X POST "$NVIDIA_ENDPOINT" \
        -H "Authorization: Bearer $NVIDIA_API_KEY" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$(python3 - "$system" "$prompt" "$NVIDIA_MODEL" <<'PY'
import json
import sys

system = sys.argv[1]
prompt = sys.argv[2]
model = sys.argv[3]

payload = {
    "model": model,
    "messages": [
        {
            "role": "system",
            "content": system
        },
        {
            "role": "user",
            "content": prompt
        }
    ],
    "temperature": 0.2,
    "top_p": 0.95,
    "max_tokens": 16384,
    "stream": False
}

print(json.dumps(payload))
PY
)"
}

health() {
    echo "==============================================="
    echo " FLOW SOCIAL - NVIDIA API HEALTH"
    echo "==============================================="
    echo "Endpoint: $NVIDIA_ENDPOINT"
    echo "Model:    $NVIDIA_MODEL"
    echo

    local response

    response="$(
        curl --silent --show-error \
            --fail-with-body \
            --connect-timeout 15 \
            --max-time 120 \
            -X POST "$NVIDIA_ENDPOINT" \
            -H "Authorization: Bearer $NVIDIA_API_KEY" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            --data "$(python3 - "$NVIDIA_MODEL" <<'PY'
import json
import sys

print(json.dumps({
    "model": sys.argv[1],
    "messages": [
        {
            "role": "user",
            "content": "Respond only with FLOW_SOCIAL_NVIDIA_OK"
        }
    ],
    "temperature": 0,
    "max_tokens": 32,
    "stream": False
}))
PY
)"
    )"

    if python3 - "$response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])

content = (
    data.get("choices", [{}])[0]
    .get("message", {})
    .get("content", "")
)

print(content)

if "FLOW_SOCIAL_NVIDIA_OK" not in content:
    raise SystemExit(1)
PY
    then
        echo
        echo "NVIDIA API: OK"
        return 0
    fi

    echo
    echo "NVIDIA API: resposta inesperada."
    return 1
}

case "${1:-}" in
    health)
        health
        ;;

    request)
        shift
        request "$*"
        ;;

    *)
        echo "Uso:"
        echo
        echo "  $0 health"
        echo "  $0 request \"Seu prompt\""
        exit 2
        ;;
esac
