MISSÃO: AUDITORIA E CONFIGURAÇÃO COMPLETA DA INFRAESTRUTURA DE IA — AI_KNOWLEDGE

Você está trabalhando em uma infraestrutura permanente de conhecimento, memória e execução para uma organização de agentes de engenharia.

NÃO comece reconstruindo nada.
NÃO apague arquivos existentes.
NÃO formate discos.
NÃO reinstale o sistema operacional.
NÃO mova projetos de desenvolvimento sem primeiro auditar.
NÃO use /tmp como armazenamento permanente.
NÃO coloque bancos, caches, modelos ou runtimes pesados no disco do sistema se puderem ser direcionados para o armazenamento permanente.

============================================================
1. ARMAZENAMENTO PRINCIPAL
============================================================

O armazenamento permanente destinado à IA é:

/mnt/ai-knowledge

Nome/label esperado:

AI_KNOWLEDGE

Este HD deve ser tratado como:

AI KNOWLEDGE + AI MEMORY + AI WORKSPACE + AI RUNTIME STORAGE

Ele deve concentrar:

- memória persistente da organização;
- banco de conhecimento;
- banco de memória;
- embeddings;
- ChromaDB;
- agentes;
- especializações;
- configurações;
- runtimes locais;
- caches de desenvolvimento;
- bancos de dados locais;
- modelos locais;
- artefatos de testes;
- logs;
- projetos temporários de processamento pesado;
- ferramentas auxiliares;
- ambientes virtuais;
- dependências pesadas;
- datasets;
- backups internos;
- checkpoints;
- estado das sessões;
- estado dos projetos.

Primeiro descubra exatamente qual dispositivo está montado em:

/mnt/ai-knowledge

Execute auditoria equivalente a:

findmnt /mnt/ai-knowledge
lsblk -f
df -h /mnt/ai-knowledge
df -ih /mnt/ai-knowledge
mount | grep ai-knowledge
stat /mnt/ai-knowledge
test -w /mnt/ai-knowledge && echo WRITE_OK
du -sh /mnt/ai-knowledge/* 2>/dev/null | sort -h

NÃO presuma capacidade, UUID, dispositivo ou espaço disponível.
Leia o sistema e registre os valores reais.

============================================================
2. OBJETIVO PRINCIPAL
============================================================

Queremos separar claramente:

DISCO DO SISTEMA
    ↓
Sistema operacional + componentes essenciais

DISCO DE DESENVOLVIMENTO
    ↓
Projetos ativos e código-fonte quando necessário

AI_KNOWLEDGE
    ↓
Infraestrutura pesada e permanente da organização de IA

Sempre que tecnicamente seguro e suportado, componentes pesados devem utilizar:

/mnt/ai-knowledge

em vez de:

/tmp
/var/tmp
~/.cache
~/Downloads
ou outras localizações do disco do sistema.

IMPORTANTE:

Não altere caminhos críticos do Linux simplesmente para liberar espaço.

Faça redirecionamentos apenas quando forem tecnicamente seguros, reversíveis e documentados.

============================================================
3. AUDITORIA COMPLETA ANTES DE ALTERAR
============================================================

Audite:

- CPU
- RAM
- discos
- partições
- filesystem
- espaço disponível
- inode
- permissões
- usuário atual
- grupos
- sudo
- systemd
- Docker
- Podman
- Node.js
- npm
- pnpm
- yarn
- Bun
- Python
- pip
- venv
- PHP
- Composer
- MySQL
- MariaDB
- PostgreSQL
- Redis
- SQLite
- ChromaDB
- bancos existentes
- modelos locais
- caches
- IDEs
- OpenCode
- Antigravity
- ferramentas de agentes
- Git
- GitHub CLI
- Docker volumes
- caches de compiladores
- caches de npm
- caches de pip
- caches de Composer
- caches de modelos
- diretórios temporários

Também procure armazenamento pesado fora de /mnt/ai-knowledge.

NÃO apague nada durante essa etapa.

Gere um relatório:

/mnt/ai-knowledge/audit/

com:

system.txt
storage.txt
runtimes.txt
databases.txt
docker.txt
python.txt
node.txt
php.txt
models.txt
caches.txt
permissions.txt
agents.txt
knowledge.txt
memory.txt
recommendations.txt

============================================================
4. ESTRUTURA DEFINITIVA DO AI_KNOWLEDGE
============================================================

Após a auditoria, criar somente o que estiver faltando.

Estrutura desejada:

/mnt/ai-knowledge/

├── agents/
├── knowledge/
├── memory/
├── database/
├── databases/
├── projects/
├── runtimes/
│   ├── node/
│   ├── python/
│   ├── php/
│   ├── go/
│   ├── rust/
│   └── java/
├── packages/
│   ├── npm/
│   ├── pnpm/
│   ├── pip/
│   ├── composer/
│   └── cargo/
├── caches/
│   ├── npm/
│   ├── pnpm/
│   ├── pip/
│   ├── composer/
│   ├── playwright/
│   ├── models/
│   └── build/
├── models/
├── embeddings/
├── chromadb/
├── docker/
│   ├── volumes/
│   ├── images/
│   └── data/
├── datasets/
├── artifacts/
├── logs/
├── checkpoints/
├── sessions/
├── backups/
├── configs/
├── temp/
└── audit/

A estrutura pode ser ajustada se a auditoria demonstrar que determinado componente precisa de outro caminho.

Não duplique estruturas que já existem.
Não crie bancos ou runtimes duplicados.

============================================================
5. NODE.JS
============================================================

Queremos que instalações e artefatos pesados do ecossistema Node possam utilizar o AI_KNOWLEDGE.

Investigue:

- Node instalado;
- versão;
- npm;
- pnpm;
- yarn;
- Bun;
- nvm;
- caches;
- diretórios globais;
- diretórios de builds.

Configurar, quando seguro:

/mnt/ai-knowledge/packages/npm
/mnt/ai-knowledge/packages/pnpm
/mnt/ai-knowledge/caches/npm
/mnt/ai-knowledge/caches/pnpm
/mnt/ai-knowledge/runtimes/node

Não remova Node existente.

Não quebre projetos existentes.

Se nvm estiver instalado, avaliar configuração de diretório permanente apropriado no AI_KNOWLEDGE.

============================================================
6. PYTHON
============================================================

Auditar:

python
python3
pip
venv
virtualenv
conda
uv
poetry

Preparar:

/mnt/ai-knowledge/runtimes/python
/mnt/ai-knowledge/packages/pip
/mnt/ai-knowledge/caches/pip
/mnt/ai-knowledge/projects/python

Ambientes virtuais de projetos pesados devem poder ser criados em:

/mnt/ai-knowledge/projects/

Não substituir Python do sistema.

Não quebrar ferramentas que dependem do Python do sistema.

============================================================
7. PHP
============================================================

Auditar:

php
composer
php.ini
extensões
versões disponíveis

Preparar:

/mnt/ai-knowledge/runtimes/php
/mnt/ai-knowledge/packages/composer
/mnt/ai-knowledge/caches/composer
/mnt/ai-knowledge/projects/php

Composer deve poder utilizar cache no AI_KNOWLEDGE.

============================================================
8. BANCOS DE DADOS
============================================================

Este é um dos pontos mais importantes.

Auditar:

- PostgreSQL
- MySQL
- MariaDB
- Redis
- SQLite
- outros bancos existentes

Descobrir onde cada banco está armazenando:

- data directory;
- WAL/binlog;
- logs;
- temporary files;
- sockets;
- backups.

Para bancos locais destinados à IA/desenvolvimento pesado, preparar armazenamento em:

/mnt/ai-knowledge/databases/

ou:

/mnt/ai-knowledge/database/

Não mover banco de produção ou banco de projeto existente sem auditoria.

Não apagar banco existente.

Não executar DROP DATABASE.

Não executar reset.

Não executar migração destrutiva.

============================================================
9. AI_MEMORY
============================================================

Continuar o trabalho já realizado.

Existe uma infraestrutura de memória persistente planejada para:

ai_memory

Ela deve ficar permanentemente no:

/mnt/ai-knowledge/database/

Auditar primeiro:

- schema existente;
- banco existente;
- tabelas;
- índices;
- foreign keys;
- usuários;
- permissões;
- conexão;
- backups;
- integridade.

A memória precisa conseguir armazenar:

- projetos;
- sessões;
- agentes;
- tarefas;
- decisões;
- eventos;
- checkpoints;
- estado de projetos;
- contexto de execução;
- histórico de operações;
- conhecimento adquirido;
- relações entre entidades;
- recuperação após encerramento do terminal.

Objetivo:

SE O OPENCODE FOR FECHADO

↓ 

SE O COMPUTADOR FOR REINICIADO

↓

SE UMA SESSÃO FOR ENCERRADA

↓

A ORGANIZAÇÃO CONSEGUE RECUPERAR O ESTADO ANTERIOR.

Criar testes reais de:

CREATE
INSERT
SELECT
UPDATE
TRANSACTION
ROLLBACK
COMMIT
CHECKPOINT
RECONNECT
RESTART
RECOVERY

Não considerar a memória pronta apenas porque o banco existe.

============================================================
10. KNOWLEDGE.DB
============================================================

Existe um knowledge.db existente.

NÃO substituir.

NÃO apagar.

NÃO recriar do zero.

Auditar:

- integridade;
- tabelas;
- índices;
- registros;
- tamanho;
- consultas;
- conexões;
- backups.

Se estiver funcionando, preservar.

Documentar sua relação com ai_memory.

Evitar duas fontes de verdade conflitantes.

============================================================
11. EMBEDDINGS / CHROMADB
============================================================

Preservar a infraestrutura existente.

Modelo conhecido:

all-MiniLM-L6-v2

ChromaDB existente.

Preparar armazenamento permanente em:

/mnt/ai-knowledge/embeddings
/mnt/ai-knowledge/chromadb

Verificar:

- modelo;
- cache;
- banco vetorial;
- persistência;
- permissões;
- recuperação após reinício.

============================================================
12. AGENTES
============================================================

Preservar os agentes existentes.

Auditar:

/mnt/ai-knowledge/agents/

Descobrir:

- quantidade;
- arquivos;
- especializações;
- configuração;
- relações;
- memória;
- conhecimento utilizado;
- ferramentas disponíveis.

Os agentes devem poder utilizar o AI_KNOWLEDGE como armazenamento permanente.

Não apagar agentes existentes.

============================================================
13. DOCKER
============================================================

Auditar:

docker info
docker system df
docker volume ls
docker image ls

Descobrir quanto espaço Docker está usando no disco do sistema.

Avaliar configuração para:

/mnt/ai-knowledge/docker/

especialmente:

- volumes;
- datasets;
- caches;
- imagens pesadas;
- ambientes de teste.

NÃO mover Docker root directory sem planejamento.

Se for seguro alterar, fazer backup/configuração reversível e testar o daemon.

Não destruir containers existentes.

============================================================
14. MODELOS DE IA
============================================================

Todos os modelos locais grandes devem, quando suportado, ficar em:

/mnt/ai-knowledge/models/

Embeddings:

/mnt/ai-knowledge/embeddings/

Caches de modelos:

/mnt/ai-knowledge/caches/models/

Não baixar modelos enormes no disco do sistema.

Antes de baixar qualquer modelo novo:

1. verificar espaço;
2. verificar destino;
3. verificar se já existe;
4. evitar duplicação.

============================================================
15. PROJETOS PESADOS
============================================================

Quando um agente precisar realizar uma tarefa pesada, deve existir a possibilidade de utilizar:

/mnt/ai-knowledge/projects/

Exemplos:

/mnt/ai-knowledge/projects/builds
/mnt/ai-knowledge/projects/testing
/mnt/ai-knowledge/projects/analysis
/mnt/ai-knowledge/projects/temporary
/mnt/ai-knowledge/projects/research

Projetos oficiais não devem ser movidos automaticamente.

O AI_KNOWLEDGE funciona como área de processamento pesado, sandbox e infraestrutura auxiliar.

============================================================
16. LOGS E CHECKPOINTS
============================================================

Logs:

/mnt/ai-knowledge/logs/

Checkpoints:

/mnt/ai-knowledge/checkpoints/

Sessões:

/mnt/ai-knowledge/sessions/

Cada tarefa importante deve poder registrar:

- projeto;
- agente;
- início;
- fim;
- arquivos modificados;
- comandos importantes;
- testes;
- resultado;
- problemas;
- próximo passo.

============================================================
17. CONFIGURAÇÕES
============================================================

Centralizar configurações da infraestrutura em:

/mnt/ai-knowledge/configs/

Mas NÃO colocar segredos em texto aberto.

Segredos devem usar:

- variáveis de ambiente;
- secret manager quando disponível;
- arquivos protegidos por permissões adequadas.

Criar:

/mnt/ai-knowledge/configs/README.md

explicando o que cada configuração faz.

============================================================
18. LIMPEZA DO /TMP
============================================================

Existe/ existiu:

/tmp/ai-knowledge-structure/

NÃO apagar imediatamente.

Primeiro:

1. verificar se existe algo exclusivo;
2. comparar com /mnt/ai-knowledge;
3. verificar hashes/tamanhos quando necessário;
4. confirmar que tudo necessário foi migrado;
5. registrar resultado.

Somente depois da validação final, propor remoção.

============================================================
19. POLÍTICA DE ARMAZENAMENTO DA ORGANIZAÇÃO
============================================================

Criar:

/mnt/ai-knowledge/ARCHITECTURE.md

documentando:

SYSTEM DISK
    ↓
Sistema operacional

DEVELOPMENT DISK
    ↓
Código-fonte/projetos ativos

AI_KNOWLEDGE
    ↓
Memória
Conhecimento
Agentes
Bancos locais
Modelos
Caches
Runtimes
Datasets
Docker
Builds
Logs
Checkpoints
Backups
Processamento pesado

============================================================
20. TESTE DE ESTRESSE
============================================================

Depois da configuração, testar:

- criar projeto Node;
- instalar dependências;
- criar projeto Python;
- criar venv;
- instalar pacote;
- executar PHP;
- instalar dependência Composer;
- criar banco SQLite;
- conectar PostgreSQL/MySQL/MariaDB se disponíveis;
- criar tabela;
- inserir;
- consultar;
- atualizar;
- rollback;
- executar container;
- gravar volume;
- executar embeddings;
- gravar no ChromaDB;
- gravar memória;
- fechar conexão;
- reconectar;
- reiniciar serviço quando aplicável;
- verificar persistência.

Tudo deve sobreviver ao encerramento da sessão.

============================================================
21. VERIFICAÇÃO DE ESPAÇO
============================================================

Criar mecanismo para identificar:

- diretórios grandes;
- crescimento anormal;
- caches;
- logs;
- imagens Docker;
- node_modules;
- modelos;
- bancos;
- artefatos.

Objetivo:

EVITAR QUE O DISCO DO SISTEMA FIQUE CHEIO.

Mas não mover automaticamente arquivos críticos sem autorização.

============================================================
22. SEGURANÇA
============================================================

Não armazenar:

- senhas em logs;
- tokens;
- API keys;
- chaves privadas;
- credenciais bancárias;
- secrets em Git.

Aplicar permissões adequadas ao:

/mnt/ai-knowledge

Especialmente:

memory
database
backups
configs
secrets

Não expor bancos para a rede sem necessidade.

============================================================
23. REGRA PARA FUTUROS AGENTES
============================================================

Sempre que um agente precisar:

- instalar ferramenta;
- baixar modelo;
- criar banco;
- gerar dataset;
- criar cache;
- executar build pesado;
- executar teste pesado;
- criar ambiente virtual;
- instalar dependências grandes;
- armazenar artefatos;

ele deve primeiro verificar se o recurso pode utilizar:

/mnt/ai-knowledge

ANTES de ocupar desnecessariamente o disco do sistema.

============================================================
24. NÃO FAZER
============================================================

NÃO:

- formatar /mnt/ai-knowledge;
- apagar knowledge.db;
- apagar ai_memory;
- apagar agentes;
- apagar projetos;
- apagar bancos;
- reinstalar o sistema;
- mover /home inteiro;
- mover /usr;
- mover /var indiscriminadamente;
- alterar boot;
- alterar partições sem necessidade;
- destruir Docker;
- resetar banco;
- executar comandos destrutivos;
- começar nova arquitetura ignorando a existente.

============================================================
25. RESULTADO FINAL
============================================================

Ao terminar, gerar:

/mnt/ai-knowledge/audit/FINAL_REPORT.md

O relatório deve responder objetivamente:

1. Qual dispositivo é o AI_KNOWLEDGE?
2. Qual filesystem?
3. Quanto espaço livre?
4. Está gravável pelo usuário?
5. Onde está a memória persistente?
6. Onde está knowledge.db?
7. Onde está ChromaDB?
8. Onde estão embeddings?
9. Onde estão os agentes?
10. Onde estão os bancos?
11. Onde estão os runtimes?
12. Onde estão caches?
13. Onde estão modelos?
14. Onde estão volumes Docker?
15. O que continua no disco do sistema?
16. O que continua no disco de desenvolvimento?
17. O que foi redirecionado?
18. O que NÃO pôde ser redirecionado?
19. Quais testes passaram?
20. Quais testes falharam?
21. O que ainda precisa ser feito?

IMPORTANTE:

Não declare “CONCLUÍDO” simplesmente porque os diretórios existem.

Declare cada componente como:

[OK]
[PARCIAL]
[FALHOU]
[NÃO CONFIGURADO]
[NÃO SEGURO ALTERAR]
[REQUER DECISÃO]

A infraestrutura só será considerada operacional quando os testes reais demonstrarem persistência e funcionamento.

============================================================
OBJETIVO FINAL
============================================================

Queremos que:

OpenCode
   ↓
AGENTES
   ↓
MEMÓRIA PERSISTENTE
   ↓
AI_KNOWLEDGE
   ↓
DATABASES / RUNTIMES / MODELS / CACHE / BUILD / TEST
   ↓
PROJETOS

funcione como uma infraestrutura permanente.

O terminal pode fechar.

O computador pode reiniciar.

Uma sessão pode terminar.

O conhecimento, os agentes, os checkpoints, os projetos e a memória NÃO podem desaparecer.

Primeiro AUDITE.
Depois PLANEJE.
Depois CONFIGURE.
Depois TESTE.
Depois DOCUMENTE.
execute a auditoria da infraestrutura. As pastas de CLI e ENV já foram criadas. Agora audite cada pasta e cada ferramenta, identifique o que já está instalado e funcionando e o que falta. Instale/configure o que for necessário nos locais apropriados dentro do /mnt/ai-knowledge, incluindo Laravel. Não reinstale ferramentas funcionais, não apague nada e atualize os manifestos com o estado real. Depois configure a estrutura de ENV por projeto e registre tudo na memória persistente.

Preserve tudo o que já funciona.
