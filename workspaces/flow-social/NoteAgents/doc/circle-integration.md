# Circle Integration for NoteAgents

## Visão Geral

Integração do NoteAgents com o ecossistema Circle, permitindo pagamentos estáveis em USDC. Este documento descreve como desenvolvedores podem implementar e usar funcionalidades de pagamento Circle dentro de projetos NoteAgents.

## Referências Oficiais

- Circle Console: https://console.circle.com/signin?useSSO=true&marketingConsent=false

## Visão Geral

O NoteAgents agora suporta pagamentos através da Circle, proporcionando:

- Pagamentos estáveis em USDC (USD Coin)
- Regulamentação completa e compliance
- Assentamento rápido (menos de 24 horas)
- Integração com sistemas bancários tradicionais
- Emissão e resgate de USDC

## Como Funciona

O Circle proporciona uma ponte entre o sistema financeiro tradicional e criptomoedas, permitindo que o NoteAgents:

1. **Emita USDC** para pagamentos de serviços
2. **Receba USDC** de clientes e parceiros
3. **Converta** entre SOL (Solana) e USDC (Circle)
4. **Faça pagamentos** de folha de pagamento para agentes
5. **Faça reembolsos** quando necessário

## Setup de Integração

### 1. Requisitos

- Conta Circle Business
- API Key da Circle
- Conta bancária para vinculação
- Conta NoteAgents

### 2. Configuração de Variáveis de Ambiente

```bash
# Circle
CIRCLE_API_KEY="sua-chave-circle-api"
CIRCLE_WEBHOOK_SECRET="seu-webhook-secret"
CIRCLE_MERCHANT_ACCOUNT_ID="sua-conta-circle"

# NoteAgents
SLACK_BOT_TOKEN="seu-token"
SLACK_CHANNEL_#Geral="#general"

# Solana (opcional, para conversão SOL↔USDC)
REACT_APP_SOLANA_NETWORK="devnet"
REACT_APP_SOLANA_RPC_URL="https://api.devnet.solana.com"
```

### 3. Configuração no NoteAgents

```json
// .env ou configuração do NoteAgents
{
  "circle": {
    "apiKey": "sua-chave-circle",
    "webhookSecret": "seu-webhook-secret",
    "merchantAccountId": "sua-conta-circle"
  },
  "payment": {
    "enabled": true,
    "defaultCurrency": "USDC",
    "autoSettlement": true,
    "convertSOLToUSDC": true
  }
}
```

## Casos de Uso

### 1. Pagamento de Folha de Agentes

Pagamento automatizado de agentes NoteAgents:

```typescript
// Pagamento de salário mensal em USDC
await noteagents.payment.requestPayment({
  amount: 500, // $500 em USDC
  currency: "USDC",
  recipient: "agent-wallet-address",
  description: "Monthly agent salary - Q1 2025",
  metadata: {
    period: "monthly",
    agentId: "frontend-agent-001",
    paidAt: new Date().toISOString()
  }
})
```

### 2. Recebimento de Clientes

Recebimento de pagamentos de clientes em USDC:

```typescript
// Solicitar pagamento do cliente
await noteagents.payment.requestPaymentFromClient({
  amount: 1000, // $1000 em USDC
  currency: "USDC",
  customerEmail: "cliente@empresa.com",
  description: "Projeto NoteAgents - Desenvolvimento Q1",
  metadata: {
    projectId: "proj-456",
    expectedDelivery: "2025-02-01"
  }
})
```

### 3. Conversão SOL ↔ USDC

Quando o agente precisa de liquidez em dólar:

```typescript
// Converter SOL para USDC via Circle
await noteagents.payment.convert({
  from: "SOL",
  to: "USDC",
  amount: 2.5, // 2.5 SOL
  destination: "USDC-wallet-address",
  purpose: "Conversão para pagamento de agentes"
})
```

### 4. Reembolsos

```typescript
// Processar reembolso
await noteagents.payment.refund({
  transactionId: "tx-abc123",
  amount: 50, // $50 em USDC
  reason: "Cliente solicita cancelamento",
  metadata: {
    originalTransaction: "tx-abc123",
    refundReason: "service-not-delivered",
    requestedAt: new Date().toISOString()
  }
})
```

## API Reference

### CirclePay Class

```typescript
class CirclePay {
  constructor(config: CirclePayConfig)
  
  // Methods
  requestPayment(amount: number, currency: "USDC", recipient: string, metadata?: Record<string, any>): Promise<PaymentResult>
  requestPaymentFromClient(amount: number, currency: "USDC", customerEmail: string, description: string, metadata?: Record<string, any>): Promise<PaymentResult>
  convert(from: "SOL" | "USDC", to: "SOL" | "USDC", amount: number): Promise<ConvertResult>
  refund(transactionId: string, amount: number, reason: string): Promise<RefundResult>
  getBalance(): Promise<{usdc: number, usdcAvailable: number}>
  getTransactionHistory(): Promise<TransactionHistoryEntry[]>
  setupWebhook(): Promise<WebhookConfig>
}
```

### Webhooks

O Circle envia webhooks para notificações de eventos:

```typescript
// Configurar webhook no NoteAgents
await noteagents.payment.setupWebhook({
  url: "https://seu-dominio.com/api/circle/webhook",
  events: [
    "PAYMENT_COMPLETED",
    "PAYMENT_FAILED",
    "PAYMENT_REVERSED",
    "USDC_MINTED",
    "USDC_REDEEMED"
  ]
})
```

### Eventos de Webhook

```typescript
// Listener de webhook
app.post("/api/circle/webhook", async (req, res) => {
  const event = req.body;
  
  switch (event.type) {
    case "PAYMENT_COMPLETED":
      // Atualizar status do pagamento
      await noteagents.evidence.recordEvidence({
        type: "payment",
        status: "completed",
        details: { ... }
      });
      break;
    
    case "PAYMENT_FAILED":
      // Logar erro e notificar
      console.error("Payment failed:", event.failureReason);
      break;
    
    case "USDC_MINTED":
      // Atualizar balance
      await noteagents.payment.getBalance();
      break;
  }
  
  res.json({ status: "ok" });
});
```

## Development Workflow

### 1. Testando o Setup

```bash
# Verificar balance
noteagents payment get-balance

# Solicitar pagamento de teste
noteagents payment request \
  --amount 10 \
  --currency USDC \
  --description "Test payment" \
  --recipient "test-wallet-address"
```

### 2. Modo Sandbox

Use o ambiente sandbox da Circle para testes:

```bash
# Configurar modo sandbox
export CIRCLE_ENV="sandbox"

# Todas as transações são simuladas
# Sem dinheiro real movimentado
```

### 3. Debugging

```bash
# Ativar logs detalhados
export NOTEAGENTS_DEBUG="circle"

# Ver logs de webhook
noteagents logs tail --filter circle
```

## Segurança

### Boas Práticas

1. **Nunca exponha a Circle API Key** no frontend
2. Valide o webhook secret antes de processar eventos
3. Use HTTPS para todos os endpoints
4. Implemente idempotency keys para operações seguras
5. Monitore webhooks falhados e faça retry

### Validação de Webhook

```typescript
// Validar webhook Circle
function validateCircleWebhook(secret: string, payload: string, signature: string): boolean {
  const hmac = crypto.createHmac("sha256", secret);
  const digest = hmac.update(payload).digest("hex");
  return crypto.timingSafeEqual(Buffer.from(digest, "hex"), Buffer.from(signature, "hex"));
}
```

## Integração com Solana

Conversão entre SOL e USDC:

```typescript
// Converter SOL para USDC usando Circle
await noteagents.payment.convert({
  from: "SOL",
  to: "USDC",
  amount: 10, // 10 SOL
})

// Converter USDC para SOL
await noteagents.payment.convert({
  from: "USDC",
  to: "SOL",
  amount: 50, // $50 em USDC
})
```

## Hackathon Superteam Preparation

### Inscrição

1. Visite: https://hackathon.superteam.com.br/
2. Selecione o track "Payments & Finance" ou "AI x Finance"
3. Submeta seu projeto NoteAgents com integração Circle

### Categorias de Prêmio

- **Best Use of Circle**: Melhor uso da API Circle para pagamentos
- **Best AI x Finance**: Melhor uso de IA para decisões financeiras
- **Best Integration**: Melhor integração com NoteAgents
- **Most Innovative**: Mais inovador projeto financeiro

### Prêmios

- Prêmios em USDC para vencedores
- Mentoria da Circle developer community
- Exposure para projetos open source
- Créditos da Circle para projetos selecionados

## Exemplos Práticos

### Exemplo 1: Folha de Pagamento de Agentes

```typescript
import { noteagents } from "noteagents";

async function payAgentsSalary() {
  const agents = await noteagents.agents.list();
  
  for (const agent of agents) {
    await noteagents.payment.requestPayment({
      amount: 100, // $100 em USDC por agente
      currency: "USDC",
      recipient: agent.walletAddress,
      description: "Monthly salary - Q1 2025",
      metadata: {
        agentId: agent.id,
        period: "monthly",
        paidAt: new Date().toISOString()
      }
    });
  }
}

// Executar
payAgentsSalary();
```

### Exemplo 2: Dashboard de Pagamentos

```typescript
import { useQuery } from "@tanstack/react-query"
import { noteagents } from "noteagents"

function PaymentsDashboard() {
  const { data: balance } = useQuery({
    queryKey: ["circle-balance"],
    queryFn: () => noteagents.payment.getBalance()
  })
  
  const { data: transactions } = useQuery({
    queryKey: ["circle-transactions"],
    queryFn: () => noteagents.payment.getTransactionHistory()
  })
  
  return (
    <div>
      <h2>Payments Dashboard</h2>
      <p>USDC Balance: ${balance?.usdc.toFixed(2)}</p>
      <TransactionsList transactions={transactions} />
    </div>
  )
}
```

## Roadmap da Integração Circle

| Fase | Funcionalidades |
|------|-----------------|
| **Fase 1** (atual) | Pagamentos USDC básicos, send/receive, balance tracking |
| **Fase 2** | Webhooks, reembolsos, conversão SOL↔USDC |
| **Fase 3** | KYC/AML compliance, institutional features, multi-currency |
| **Fase 4** | Enterprise features, custom settlement, regulatory reporting |

## Suporte

- Documentação: https://docs.noteagents.dev/integrations/circle
- Discord: https://discord.noteagents.dev
- Email: dev@noteagents.com
- Circle Docs: https://docs.circle.com

---

*Documentação gerada em 04/10/2025. Versão 0.1.0*