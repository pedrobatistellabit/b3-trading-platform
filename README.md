# B3 Trading Platform

Uma plataforma completa de trading para a B3 (Bolsa de Valores do Brasil) com integração MetaTrader 5.

## 🚀 Início Rápido

Para tornar a plataforma executável, utilize o script de inicialização:

```bash
./start_platform.sh
```

Ou execute diretamente:

```bash
docker compose up -d
```

## 🏗️ Arquitetura

### Serviços Disponíveis

- **Frontend (Next.js)**: Interface web moderna - `http://localhost:3000`
- **Backend (FastAPI)**: API REST e WebSocket - `http://localhost:8000`
- **PostgreSQL**: Banco de dados principal - `localhost:5432`
- **Redis**: Cache e mensageria - `localhost:6379`
- **Market Data**: Simulador de dados de mercado
- **Grafana**: Dashboard de monitoramento - `http://localhost:3001`

### Estrutura de Diretórios

```
├── backend/           # API FastAPI
├── frontend/          # Interface Next.js
├── services/          # Microserviços
│   └── market-data/   # Simulador de dados
├── database/          # Scripts SQL
├── logs/              # Logs da aplicação
└── docker-compose.yml # Configuração Docker
```

## 🔧 Problemas de Integração Corrigidos

### 1. Dependência asyncio incorreta
- **Problema**: `asyncio==3.4.3` não é um pacote válido
- **Solução**: Removido do requirements.txt (asyncio é built-in)

### 2. Dockerfile do frontend
- **Problema**: Tentativa de copiar package-lock.json inexistente
- **Solução**: Ajustado para copiar apenas package.json

### 3. Conflito de arquivos docker-compose
- **Problema**: Múltiplos arquivos (compose.yaml, docker-compose.yml)
- **Solução**: Removido compose.yaml incompleto

### 4. Problemas de SSL no backend
- **Problema**: Falha na instalação de pacotes Python
- **Solução**: Adicionado trusted-host e ca-certificates

### 5. Falta de variáveis de ambiente
- **Problema**: Backend não utilizava configuração do .env
- **Solução**: Adicionado suporte a python-dotenv

### 6. Versão obsoleta do docker-compose
- **Problema**: Warning sobre version: '3.8'
- **Solução**: Removido atributo version obsoleto

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Arquivo `.env` configurado

## 🛠️ Comandos Úteis

```bash
# Iniciar todos os serviços
docker compose up -d

# Ver logs
docker compose logs -f

# Parar todos os serviços
docker compose down

# Rebuild de um serviço específico
docker compose build api

# Verificar status dos serviços
docker compose ps
```

## 🔐 Variáveis de Ambiente

As principais variáveis estão configuradas no arquivo `.env`:

- `DB_PASSWORD`: Senha do PostgreSQL
- `REDIS_PASSWORD`: Senha do Redis
- `API_HOST/PORT`: Configuração da API
- `JWT_SECRET_KEY`: Chave para tokens JWT
- `B3_API_KEY`: Credenciais da B3 (configure suas próprias)

## 🐛 Resolução de Problemas

Se encontrar erros de integração:

1. Execute `./start_platform.sh` para verificar pré-requisitos
2. Verifique se o arquivo `.env` existe
3. Confirme se todas as portas estão disponíveis
4. Execute `docker compose config` para validar configuração

## 📊 Monitoramento

- **Grafana**: Dashboard em `http://localhost:3001`
- **API Health**: Endpoint em `http://localhost:8000/health`
- **Logs**: Diretório `./logs/` ou `docker compose logs`

## 🎯 Status do Projeto

✅ **Plataforma Executável**: Todos os problemas de integração foram resolvidos
✅ **Configuração Docker**: Validada e funcional
✅ **Variáveis de Ambiente**: Implementadas
✅ **Dependências**: Corrigidas
✅ **Scripts de Inicialização**: Disponíveis