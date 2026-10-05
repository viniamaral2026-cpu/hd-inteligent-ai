#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AGENT="${1:-}"
TASK="${2:-}"

if [[ -z "$AGENT" ]]; then
    echo "Uso: $0 <agent> <task>"
    exit 1
fi

if [[ -z "${NVIDIA_API_KEY:-}" ]]; then
    echo "ERRO: NVIDIA_API_KEY não configurada."
    echo "Execute:"
    echo 'export NVIDIA_API_KEY="SUA_CHAVE"'
    exit 1
fi

MODEL="${NVIDIA_MODEL:-meta/llama-3.3-70b-instruct}"
NVIDIA_URL="${NVIDIA_API_URL:-https://integrate.api.nvidia.com/v1/chat/completions}"

AGENT_DIR="$ROOT/.agents/$AGENT"
LOG_DIR="$ROOT/.flow/logs/$AGENT"
STATE_DIR="$ROOT/.flow/state"

mkdir -p "$LOG_DIR" "$STATE_DIR"

if [[ ! -d "$AGENT_DIR" ]]; then
    echo "ERRO: agente não encontrado: $AGENT"
    exit 1
fi

SYSTEM_PROMPT_FILE="$AGENT_DIR/system.md"

if [[ ! -f "$SYSTEM_PROMPT_FILE" ]]; then
    echo "ERRO: $SYSTEM_PROMPT_FILE não existe."
    exit 1
fi

SYSTEM_PROMPT="$(cat "$SYSTEM_PROMPT_FILE")"

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
LOG_FILE="$LOG_DIR/$TIMESTAMP.log"

REQUEST="$(python3 - "$SYSTEM_PROMPT" "$TASK" "$ROOT" <<'PY'
import json
import sys

system = sys.argv[1]
task = sys.argv[2]
root = sys.argv[3]

prompt = f"""
Você é um agente de engenharia do projeto FLOW SOCIAL.

Workspace:
{root}

Execute a tarefa abaixo diretamente no workspace.

REGRAS:
- Não invente arquivos existentes.
- Inspecione o código antes de alterar.
- Preserve Clean Architecture.
- Preserve DDD e separação de Bounded Contexts.
- Não utilize mocks para implementar funcionalidades reais.
- Não substitua infraestrutura real por stubs.
- Escreva código executável.
- Instale dependências somente quando necessário.
- Execute testes e validações.
- Corrija os próprios erros encontrados.
- Nunca apague código funcional sem justificativa.
- Mantenha compatibilidade com Linux.
- Registre decisões importantes em arquivos apropriados.
- Ao terminar, informe exatamente:
  STATUS: SUCCESS ou STATUS: FAILED
  ALTERAÇÕES:
  TESTES:
  ERROS_RESTANTES:

TAREFA:
{task}
"""

payload = {
    "model": "meta/llama-3.3-70b-instruct",
    "messages": [
        {"role": "system", "content": system},
        {"role": "user", "content": prompt}
    ],
    "temperature": 0.1,
    "max_tokens": 12000,
    "stream": False
}

print(json.dumps(payload))
PY
)"

echo "[$(date)] AGENT=$AGENT TASK=$TASK" | tee "$LOG_FILE"

RESPONSE="$(
curl -fsS \
    "$NVIDIA_URL" \
    -H "Authorization: Bearer $NVIDIA_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$REQUEST"
)"

echo "$RESPONSE" >> "$LOG_FILE"

python3 - "$RESPONSE" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])

try:
    print(data["choices"][0]["message"]["content"])
except Exception:
    print(json.dumps(data, indent=2, ensure_ascii=False))
PY

echo "$(date -Is)" > "$STATE_DIR/$AGENT.last"
