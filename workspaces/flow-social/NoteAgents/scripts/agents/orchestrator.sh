#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export FLOW_ROOT="$ROOT"

LOG="$ROOT/.flow/logs/orchestrator.log"
STATE="$ROOT/.flow/state"

mkdir -p "$(dirname "$LOG")" "$STATE"

echo "==============================================="
echo " FLOW SOCIAL - ENGINEERING AGENT ORCHESTRATOR"
echo "==============================================="
echo "ROOT: $ROOT"
echo

run_stage() {
    local stage="$1"
    local task="$2"

    echo
    echo "================================================"
    echo " STAGE: $stage"
    echo "================================================"

    if "$ROOT/scripts/agents/run-agent.sh" "$stage" "$task" \
        2>&1 | tee -a "$LOG"; then

        echo "SUCCESS: $stage"
        echo "$(date -Is)" > "$STATE/$stage.success"

    else

        echo "FAILED: $stage"

        "$ROOT/scripts/agents/run-agent.sh" \
            error-fixer \
            "O estágio $stage falhou.

Analise os logs do estágio.
Identifique a causa raiz.
Corrija os problemas diretamente no código.
Execute novamente os testes.
Não implemente workaround artificial.

Contexto:
$task" \
            2>&1 | tee -a "$LOG"

        echo "$(date -Is)" > "$STATE/$stage.repaired"
    fi
}

run_stage bootstrap \
"Preparar o monorepo FLOW SOCIAL para desenvolvimento real.
Validar Node, npm, PHP, Composer, Docker, PostgreSQL, Redis e RabbitMQ.
Criar configurações base.
Não iniciar implementação de domínio ainda."

run_stage frontend \
"Implementar completamente o frontend Next.js do FLOW SOCIAL.
Criar layouts, rotas, páginas, componentes, design system, acessibilidade,
estado, React Query, Zustand, autenticação, feed, perfil, posts, stories,
notificações, mensagens, busca, moderação e configurações.
Integrar com APIs reais.
Não utilizar mocks."

run_stage backend \
"Implementar a API PHP 8.4 com Clean Architecture, DDD, SOLID,
Result Pattern, DTOs, Commands, Queries, Controllers, repositories,
middlewares, autenticação, autorização, validação e tratamento de erros.
Implementar código executável de produção."

run_stage database \
"Implementar PostgreSQL completo.
Criar migrations, schemas, índices, constraints, foreign keys,
auditoria e dados necessários exclusivamente para funcionamento real.
Validar performance e integridade."

run_stage identity \
"Implementar Identity & Access.
Registro, login, refresh token, logout, sessões, JWT RS256,
RBAC/ABAC, 2FA, revogação de sessão e segurança."

run_stage users \
"Implementar Users bounded context.
Perfis, usernames, avatar, bio, preferências, privacidade,
status e operações necessárias pela aplicação."

run_stage social-graph \
"Implementar Social Graph.
Follow, unfollow, bloqueio, mute, seguidores, seguindo,
consultas eficientes e integração com feed."

run_stage content \
"Implementar Content.
Posts, edição, exclusão, visibilidade, hashtags, menções,
comentários e relações de conteúdo."

run_stage media \
"Implementar Media.
Upload real com presigned URLs, metadados, processamento,
validação, storage e integração com posts."

run_stage outbox \
"Implementar Transactional Outbox.
Persistência atômica de eventos, relay, retries, idempotência,
dead-letter handling e CloudEvents."

run_stage feed \
"Implementar Feed Engine híbrido Push/Pull.
Fan-out on Write, Fan-out on Read, threshold configurável,
celebrity handling, read-time merge, paginação por cursor,
Redis ZSET, hidratação e cache."

run_stage interactions \
"Implementar likes, reactions, comentários, respostas,
contadores, idempotência e optimistic concurrency."

run_stage stories \
"Implementar Stories.
Criação, upload, visualização, expiração de 24 horas,
tracking de views e ordenação."

run_stage notifications \
"Implementar Notifications.
Likes, comentários, follows, menções, agrupamento,
deduplicação, preferências e realtime."

run_stage messaging \
"Implementar Direct Messages.
Conversas, mensagens, presença, typing indicator,
WebSocket, persistência, entrega e reconexão."

run_stage search \
"Implementar Search & Explore.
Pesquisa de usuários, posts, hashtags, trending,
indexação e consultas eficientes."

run_stage moderation \
"Implementar Moderation & Safety.
Reports, fila Human-in-the-Loop, tickets, toxicidade,
sanções, suspensão, quarentena e audit log."

run_stage compliance \
"Implementar LGPD/GDPR.
Exportação, portabilidade, anonimização, exclusão,
consentimento, auditoria e DPO."

run_stage infrastructure \
"Implementar infraestrutura Docker/Kubernetes/Helm.
PostgreSQL, Redis, RabbitMQ, API, worker, frontend,
networking, secrets e ambientes."

run_stage observability \
"Implementar OpenTelemetry, métricas RED, logs estruturados,
tracing distribuído, Prometheus, Grafana, health checks,
readiness e liveness."

run_stage security \
"Executar hardening completo.
OWASP, headers, rate limiting, secrets, dependency scanning,
SAST, CSRF, XSS, SSRF, SQL injection e controle de acesso."

run_stage testing \
"Implementar testes unitários, integração, contrato e E2E.
Utilizar Pest/PHPUnit, Jest/Vitest e Playwright.
Eliminar testes artificiais e validar fluxos reais."

run_stage cicd \
"Implementar CI/CD completo.
GitHub Actions, lint, SAST, SCA, testes, Docker,
registry, GitOps, ArgoCD, Canary e rollback."

run_stage reviewer \
"Fazer revisão completa do sistema.
Inspecionar arquitetura, código, segurança, performance,
testes, dependências, inconsistências e integrações.
Corrigir problemas encontrados."

run_stage error-fixer \
"Executar auditoria final.
Encontrar erros de compilação, TypeScript, PHP, dependências,
migrations, Docker, integração, testes e runtime.
Corrigir automaticamente todos os problemas reproduzíveis."

echo
echo "================================================"
echo " FLOW SOCIAL ENGINEERING PIPELINE FINALIZADO"
echo "================================================"
echo "Logs:   $ROOT/.flow/logs"
echo "Estado: $ROOT/.flow/state"
echo
