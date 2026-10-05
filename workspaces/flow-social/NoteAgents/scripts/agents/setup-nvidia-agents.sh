#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo " FLOW SOCIAL — NVIDIA AGENT ENVIRONMENT"
echo "=============================================="
echo

# ------------------------------------------------
# NVIDIA NIM / API
# ------------------------------------------------

read -rsp "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" NVIDIA_API_KEY_INPUT
echo

if [[ -z "$NVIDIA_API_KEY_INPUT" ]]; then
    echo "ERRO: NVIDIA_API_KEY não informada."
    exit 1
fi

export NVIDIA_API_KEY="$NVIDIA_API_KEY_INPUT"
export NVIDIA_API_BASE_URL="https://integrate.api.nvidia.com/v1"
export NVIDIA_API_URL="https://integrate.api.nvidia.com/v1/chat/completions"
export NVIDIA_MODEL="nvidia/nemotron-3-ultra-550b-a55b"

# ------------------------------------------------
# Agent configuration
# ------------------------------------------------

export FLOW_ROOT="$ROOT"

export FLOW_AGENT_MODE="engineering"

export FLOW_AGENT_MAX_TOKENS="16384"
export FLOW_AGENT_TEMPERATURE="1"
export FLOW_AGENT_TOP_P="0.95"

export FLOW_AGENT_ENABLE_THINKING="true"
export FLOW_AGENT_STREAM="true"

# ------------------------------------------------
# Workspace safety
# ------------------------------------------------

export FLOW_AGENT_WORKSPACE="$ROOT"

export FLOW_AGENT_ALLOW_FILE_READ="true"
export FLOW_AGENT_ALLOW_FILE_WRITE="true"
export FLOW_AGENT_ALLOW_FILE_DELETE="false"

export FLOW_AGENT_ALLOW_COMMANDS="true"

# ------------------------------------------------
# Runtime directories
# ------------------------------------------------

export FLOW_STATE_DIR="$ROOT/.flow/state"
export FLOW_LOG_DIR="$ROOT/.flow/logs"
export FLOW_REPORT_DIR="$ROOT/.flow/reports"

mkdir -p \
    "$FLOW_STATE_DIR" \
    "$FLOW_LOG_DIR" \
    "$FLOW_REPORT_DIR"

# ------------------------------------------------
# Persist configuration without storing API key
# ------------------------------------------------

ENV_FILE="$ROOT/.env.agents"

cat > "$ENV_FILE" <<EOF
export NVIDIA_API_BASE_URL="https://integrate.api.nvidia.com/v1"
export NVIDIA_API_URL="https://integrate.api.nvidia.com/v1/chat/completions"
export NVIDIA_MODEL="nvidia/nemotron-3-ultra-550b-a55b"

export FLOW_ROOT="$ROOT"
export FLOW_AGENT_MODE="engineering"

export FLOW_AGENT_MAX_TOKENS="16384"
export FLOW_AGENT_TEMPERATURE="1"
export FLOW_AGENT_TOP_P="0.95"

export FLOW_AGENT_ENABLE_THINKING="true"
export FLOW_AGENT_STREAM="true"

export FLOW_AGENT_WORKSPACE="$ROOT"

export FLOW_AGENT_ALLOW_FILE_READ="true"
export FLOW_AGENT_ALLOW_FILE_WRITE="true"
export FLOW_AGENT_ALLOW_FILE_DELETE="false"
export FLOW_AGENT_ALLOW_COMMANDS="true"

export FLOW_STATE_DIR="$ROOT/.flow/state"
export FLOW_LOG_DIR="$ROOT/.flow/logs"
export FLOW_REPORT_DIR="$ROOT/.flow/reports"
EOF

chmod 600 "$ENV_FILE"

# ------------------------------------------------
# Python environment
# ------------------------------------------------

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERRO: python3 não encontrado."
    exit 1
fi

echo
echo "[1/6] Python:"
python3 --version

# ------------------------------------------------
# Virtual environment
# ------------------------------------------------

if [[ ! -d "$ROOT/.venv-agents" ]]; then
    echo
    echo "[2/6] Criando ambiente Python..."
    python3 -m venv "$ROOT/.venv-agents"
fi

source "$ROOT/.venv-agents/bin/activate"

echo
echo "[3/6] Atualizando pip..."
python -m pip install --upgrade pip

# ------------------------------------------------
# Dependencies
# ------------------------------------------------

echo
echo "[4/6] Instalando dependências..."

python -m pip install \
    --upgrade \
    openai \
    httpx \
    pydantic \
    python-dotenv

# ------------------------------------------------
# Ignore secrets
# ------------------------------------------------

touch "$ROOT/.gitignore"

grep -qxF ".env.agents" "$ROOT/.gitignore" 2>/dev/null || \
    echo ".env.agents" >> "$ROOT/.gitignore"

grep -qxF ".venv-agents/" "$ROOT/.gitignore" 2>/dev/null || \
    echo ".venv-agents/" >> "$ROOT/.gitignore"

grep -qxF ".flow/logs/" "$ROOT/.gitignore" 2>/dev/null || \
    echo ".flow/logs/" >> "$ROOT/.gitignore"

# ------------------------------------------------
# Create activation helper
# ------------------------------------------------

cat > "$ROOT/scripts/agents/env.sh" <<'EOF'
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
EOF

chmod +x "$ROOT/scripts/agents/env.sh"

# ------------------------------------------------
# API connectivity test
# ------------------------------------------------

echo
echo "[5/6] Testando NVIDIA API..."

HTTP_STATUS="$(
curl -sS \
    -o "$ROOT/.flow/reports/nvidia-health.json" \
    -w "%{http_code}" \
    "$NVIDIA_API_BASE_URL/models" \
    -H "Authorization: Bearer $NVIDIA_API_KEY" \
    -H "Accept: application/json" \
    || true
)"

if [[ "$HTTP_STATUS" == "200" ]]; then
    echo "NVIDIA API: OK"
else
    echo "NVIDIA API respondeu HTTP $HTTP_STATUS"
    echo "Consulte:"
    echo "$ROOT/.flow/reports/nvidia-health.json"
fi

# ------------------------------------------------
# Final status
# ------------------------------------------------

echo
echo "[6/6] Ambiente configurado."
echo
echo "=============================================="
echo " CONFIGURAÇÃO CONCLUÍDA"
echo "=============================================="
echo
echo "Modelo:"
echo "  $NVIDIA_MODEL"
echo
echo "API:"
echo "  $NVIDIA_API_BASE_URL"
echo
echo "Workspace:"
echo "  $ROOT"
echo
echo "Para ativar em um novo terminal:"
echo
echo "  source ./scripts/agents/env.sh"
echo
echo "Depois:"
echo
echo "  ./scripts/agents/run-agent.sh bootstrap \\"
echo "    \"Analise o workspace e faça o diagnóstico inicial.\""
echo
echo "=============================================="
