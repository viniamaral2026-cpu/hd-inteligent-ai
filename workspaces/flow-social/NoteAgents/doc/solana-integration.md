# Solana Pay Integration for NoteAgents

## Visão Geral

Integração do NoteAgents com o ecossistema Solana, permitindo pagamentos descentralizados via Solana Pay. Este documento descreve como desenvolvedores podem implementar e usar funcionalidades de pagamento Solana dentro de projetos NoteAgents.

## Referências Oficiais

- Documentação Solana Pay: https://solana.com/pt/docs/payments/accept-payments/solana-pay
- Circle Console: https://console.circle.com/signin?useSSO=true&marketingConsent=false

## Como Funciona

O NoteAgents agora pode:

1. **Emitir faturas** em SOL e USDC para serviços de agentes
2. **Receber pagamentos** automaticamente quando tarefas são concluídas
3. **Gerar wallets** temporárias para agentes individuais
4. **Fazer swap** entre SOL e USDC automaticamente
5. **Registrar transações** no Evidence Engine (D1)

## Setup de Integração

### 1. Requisitos

- Conta Solana.dev ou Phantom Wallet
- Token da API da Solana
- Conta Circle (para USDC)
- Conta NoteAgents com D1 Evidence Engine

### 2. Configuração de Variáveis de Ambiente

```bash
# Solana
REACT_APP_SOLANA_NETWORK="devnet"  # ou "mainnet-beta", "testnet"
REACT_APP_SOLANA_RPC_URL="https://api.devnet.solana.com"
REACT_APP_SOLANA_WALLET_PRIVATE_KEY="sua-privada-aqui"

# Circle (USDC)
CIRCLE_API_KEY="sua-chave-circle"
CIRCLE_USDC_ADDRESS="endereco-usdc"

# NoteAgents
SLACK_BOT_TOKEN="seu-token"
SLACK_CHANNEL_#Geral="#general"
```

### 3. Configuração no NoteAgents

```json
// .env ou configuração do NoteAgents
{
  "solana": {
    "network": "devnet",
    "rpcUrl": "https://api.devnet.solana.com",
    "walletPrivateKey": "sua-privada-aqui"
  },
  "circle": {
    "apiKey": "sua-chave-circle",
    "usdcAddress": "endereco-usdc"
  },
  "payment": {
    "enabled": true,
    "defaultCurrency": "SOL",
    "settlementCurrency": "USDC",
    "automaticSettlement": true
  }
}
```

## Casos de Uso

### 1. Pagamento de Agentes Autônomos

Quando um agente NoteAgents completa uma tarefa, ele pode solicitar pagamento automático:

```typescript
// Exemplo: Pagamento após task completion
await noteagents.payment.requestPayment({
  amount: 0.001, // em SOL
  currency: "SOL",
  recipient: "agent-wallet-address",
  description: "Task: implement login page",
  metadata: {
    taskId: "task-123",
    agent: "frontend-agent",
    completedAt: new Date().toISOString()
  }
})
```

### 2. Receiving Payments de Clientes

O NoteAgents pode gerar QR codes e endereços para recebimento:

```typescript
// Gerar endereço de recebimento
const address = await noteagents.payment.generateAddress({
  amount: 10, // em USDC
  currency: "USDC",
  purpose: "Projeto NoteAgents - Q1 2025"
})

// Gerar QR code para pagamento
const qrCode = await noteagents.payment.generateQRCode({
  address,
  amount: 10
})
```

### 3. Swap Automatizado SOL ↔ USDC

Quando o agente precisa de liquidez:

```typescript
// Swap SOL para USDC
await noteagents.payment.swap({
  from: "SOL",
  to: "USDC",
  amount: 0.5,
  minReceived: 50, // mínimo em USDC
  slippage: 0.5 // 0.5%
})
```

## Integração com Evidence Engine

Todas as transações são registradas no D1 Evidence Engine:

```typescript
// Registrar pagamento no Evidence Engine
await noteagents.evidence.recordEvidence({
  type: "payment",
  status: "completed",
  description: "Agent payment for task completion",
  details: {
    transactionHash: txSignature,
    amount: 0.001,
    currency: "SOL",
    recipient: "agent-wallet",
    taskId: "task-123"
  },
  project: "meu-projeto",
  timestamp: new Date().toISOString()
})
```

## Development Workflow

### 1. Testnet First

Sempre teste em devnet antes de mainnet:

```bash
# Configurar rede testnet
export SOLANA_NETWORK="devnet"

# Testar transferência
noteagents payment transfer \
  --amount 0.001 \
  --from developer-wallet \
  --to agent-wallet \
  --memo "Task completion reward"
```

### 2. Usando a CLI

```bash
# Solicitar pagamento
noteagents payment request \
  --amount 0.001 \
  --currency SOL \
  --task "implementar feature X"

# Verificar status
noteagents payment status \
  --transaction "assinatura-da-transaction"
```

### 3. Dashboard

O painel web mostra:
- Saldo atual (SOL + USDC)
- Histórico de transações
- Status de pagamentos pendentes/confirmados
- Gráficos de receita por agente

## Segurança

### Boas Práticas

1. **Nunca exponha chaves privadas** no frontend
2. Use wallets conectadas via Phantom/Extension
3. Valide todas as quantias antes de transferir
4. Implemente slippage protection
5. Monitore transações pendentes

### Alertas de Segurança

- Limite diário de transações
- Validação de destinatário
- Rate limiting de pagamentos
- Alertas para valores anômalos

## Hackathon Superteam Preparation

### Inscrição

1. Visite: https://hackathon.superteam.com.br/
2. Registre-se com conta GitHub
3. Selecione o track "Solana & AI" ou "Payments"

### Project Structure para Hackathon

```
hackathon-submission/
├── src/
│   ├── agents/        # NoteAgents agents
│   ├── payments/      # Solana Pay integration
│   ├── ui/            # Dashboard UI
│   └── utils/         # Helper functions
├── package.json
├── tsconfig.json
├── README.md
└── .env.example
```

### Oportunidades no Hackathon

- **Best Use of Solana Pay**: Implementar pagamentos agente-to-agente
- **Best Use of Circle**: Pagamentos fiat-ancorados
- **Best Integration with NoteAgents**: Como o NoteAgents pode melhorar a experiência
- **Most Innovative**: Casos de uso criativos

### Prêmios Potenciais

- Prêmio em SOL para melhores integrações
- Créditos da Circle para projetos de pagamentos
- Mentoria da Superteam community
- Exposure para projetos open source

## API Reference

### SolanaPay Class

```typescript
class SolanaPay {
  constructor(config: SolanaPayConfig)
  
  // Methods
  requestPayment(amount: number, currency: "SOL" | "USDC", recipient: string, metadata?: Record<string, any>): Promise<TransactionResult>
  generateAddress(amount: number, currency: "SOL" | "USDC", purpose?: string): Promise<{address: string, qrCode: string}>
  swap(from: "SOL" | "USDC", to: "SOL" | "USDC", amount: number, minReceived: number, slippage?: number): Promise<SwapResult>
  getBalance(): Promise<{solt: number, usdc: number}>
  getTransactionHistory(): Promise<TransactionHistoryEntry[]>
}
```

### Eventos

```typescript
// Escutar eventos de pagamento
noteagents.payment.on("payment-completed", (event) => {
  console.log(`Payment of ${event.amount} ${event.currency} completed`)
})

noteagents.payment.on("payment-failed", (event) => {
  console.log(`Payment failed: ${event.error}`)
})

noteagents.payment.on("balance-changed", (event) => {
  console.log(`Balance updated: SOL ${event.sol}, USDC ${event.usdc}`)
})
```

## Exemplos Práticos

### Exemplo 1: Agente Autônomo com Pagamento

```typescript
import { noteagents } from "noteagents";

// Inicializar
await noteagents.initialize();

// Criar tarefa
const task = await noteagents.tasks.create({
  description: "Create user profile component",
  type: "frontend",
  requirements: [...]
});

// Executar
await noteagents.agents.frontend.execute(task);

// Receber pagamento automaticamente
await noteagents.payment.requestPayment({
  amount: 0.05, // 0.05 SOL
  currency: "SOL",
  recipient: noteagents.config.walletAddress,
  description: "Frontend agent task completion",
  metadata: {
    taskId: task.id,
    completedAt: new Date().toISOString()
  }
})
```

### Exemplo 2: Dashboard de Pagamentos

```typescript
import { useQuery } from "@tanstack/react-query"
import { noteagents } from "noteagents"

function PaymentDashboard() {
  const { data: balance, isLoading } = useQuery({
    queryKey: ["payment-balance"],
    queryFn: () => noteagents.payment.getBalance()
  })
  
  const { data: transactions } = useQuery({
    queryKey: ["payment-transactions"],
    queryFn: () => noteagents.payment.getTransactionHistory()
  })
  
  return (
    <div>
      <h2>Payment Dashboard</h2>
      <p>SOL Balance: {balance?.sol} SOL</p>
      <p>USDC Balance: {balance?.usdc} USDC</p>
      <TransactionsList transactions={transactions} />
    </div>
  )
}
```

## Roadmap da Integração

| Fase | Funcionalidades |
|------|-----------------|
| **Fase 1** (atual) | Pagamentos SOL básico, receive payments, Evidence Engine integration |
| **Fase 2** | Circle USDC integration, automatic settlement, slippage protection |
| **Fase 3** | Multi-chain support (Ethereum, Base, etc.), Agent economies, Marketplace |
| **Fase 4** | Regulatory compliance, KYC/AML integration, Institutional features |

## Suporte

- Documentação: https://docs.noteagents.dev
- Discord: https://discord.noteagents.dev
- Email: dev@noteagents.com
- Twitter: @noteagents_io

---

*Documentação gerada em 04/10/2025. Versão 0.1.0*