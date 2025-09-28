# 🐳 Docker Compose Setup - B3 Trading Platform

Este repositório agora inclui configuração completa do Docker Compose para deploy na **Hostinger** e outros provedores de cloud.

## 🚀 Quick Start

```bash
# 1. Clone o repositório
git clone https://github.com/pedrobatistellabit/b3-trading-platform.git
cd b3-trading-platform

# 2. Execute o script de configuração automática
./quick-start.sh

# 3. Pronto! Sua aplicação estará rodando
```

## 📁 Arquivos de Configuração

### Docker Compose Files

- **`docker-compose.simple.yml`** - Deploy simples (recomendado para teste)
- **`docker-compose.hostinger.yml`** - Deploy completo com Nginx reverse proxy
- **`docker-compose.yml`** - Environment de desenvolvimento (original)

### Configuração

- **`.env.hostinger`** - Template de variáveis de ambiente para produção
- **`nginx/nginx.conf`** - Configuração do Nginx com reverse proxy
- **`Makefile`** - Comandos simplificados para gerenciamento
- **`quick-start.sh`** - Script de configuração automática

## 🎯 Opções de Deploy

### 1. Deploy Simples (Recomendado para começar)

```bash
# Usando Makefile
make deploy-simple

# Ou manualmente
docker compose -f docker-compose.simple.yml up -d
```

**Inclui:**
- ✅ Backend FastAPI (porta 8000)
- ✅ Frontend Next.js (porta 3000)
- ✅ PostgreSQL Database
- ✅ Redis Cache
- ✅ Market Data Simulator

### 2. Deploy Completo com Nginx

```bash
# Usando Makefile
make deploy-full

# Ou manualmente
docker compose -f docker-compose.hostinger.yml up -d
```

**Inclui tudo do deploy simples mais:**
- ✅ Nginx Reverse Proxy (porta 80/443)
- ✅ SSL/HTTPS support
- ✅ Rate limiting e segurança
- ✅ Compressão gzip
- ✅ Cache de arquivos estáticos

### 3. Deploy com Monitoramento

```bash
# Com monitoring incluso
make deploy-full
make monitoring

# Ou
docker compose -f docker-compose.hostinger.yml --profile monitoring up -d
```

**Inclui tudo mais:**
- ✅ Grafana Dashboard
- ✅ Métricas da aplicação

## 🛠️ Comandos Úteis (Makefile)

```bash
make help            # Ver todos os comandos disponíveis
make install         # Configurar ambiente
make build           # Build das imagens
make up              # Iniciar serviços
make down            # Parar serviços
make restart         # Reiniciar serviços
make logs            # Ver logs
make status          # Status dos serviços
make backup          # Backup do banco
make clean           # Limpeza completa
make update          # Atualizar aplicação
make setup-ssl       # Configurar SSL
```

## 🔧 Configuração de Variáveis de Ambiente

### Variáveis Obrigatórias

```env
# Senhas seguras (gere senhas fortes!)
DB_PASSWORD=sua_senha_segura_db
REDIS_PASSWORD=sua_senha_segura_redis
JWT_SECRET_KEY=sua_chave_jwt_de_pelo_menos_32_caracteres

# Configuração da API
NEXT_PUBLIC_API_URL=https://seudominio.com/api
DOMAIN_NAME=seudominio.com
```

### Configuração para Hostinger

1. **Copie o template de environment:**
   ```bash
   cp .env.hostinger .env
   ```

2. **Edite as configurações:**
   ```bash
   nano .env
   ```

3. **Configure seu domínio:**
   ```env
   DOMAIN_NAME=seudominio.com
   NEXT_PUBLIC_API_URL=https://seudominio.com/api
   ```

## 🌐 Acessos da Aplicação

### Deploy Simples
- **Frontend**: http://localhost:3000
- **API**: http://localhost:8000
- **Health Check**: http://localhost:8000/health

### Deploy Completo (com Nginx)
- **Frontend**: http://seudominio.com
- **API**: http://seudominio.com/api
- **Health Check**: http://seudominio.com/health
- **WebSocket**: ws://seudominio.com/ws

### Com Monitoramento
- **Grafana**: http://seudominio.com/monitoring
- **Login**: admin / (senha do GRAFANA_PASSWORD)

## 🔒 SSL/HTTPS Configuration

### Automático (Let's Encrypt)
```bash
make setup-ssl
# Siga as instruções para configurar SSL automaticamente
```

### Manual
1. Coloque seus certificados em `nginx/ssl/`
2. Configure `SSL_ENABLED=true` no .env
3. Reinicie: `make restart`

## 📊 Monitoramento e Logs

```bash
# Ver logs em tempo real
make logs

# Logs específicos
make logs-api     # API logs
make logs-web     # Frontend logs
make logs-db      # Database logs

# Status dos recursos
make status
```

## 💾 Backup e Restauração

```bash
# Criar backup
make backup

# Restaurar backup
make restore BACKUP_FILE=backup_20241201_120000.sql.gz
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Portas em uso**
   ```bash
   # Verificar portas ocupadas
   netstat -tulpn | grep :80
   netstat -tulpn | grep :3000
   ```

2. **Problemas de permissão**
   ```bash
   # Ajustar permissões
   chmod 755 logs/
   chmod +x quick-start.sh
   ```

3. **Memoria insuficiente**
   - Use `docker-compose.simple.yml` (menor uso de recursos)
   - Ajuste limites de memoria nos compose files

4. **Problemas de rede**
   ```bash
   # Reiniciar rede Docker
   docker network prune
   make restart
   ```

## 🎯 Deploy na Hostinger

### Pré-requisitos
- VPS ou Cloud Hosting na Hostinger
- Docker e Docker Compose instalados
- Domínio configurado

### Passos
1. **Conectar ao servidor:**
   ```bash
   ssh root@seu-servidor-hostinger
   ```

2. **Instalar Docker (se necessário):**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

3. **Clone e configure:**
   ```bash
   git clone https://github.com/pedrobatistellabit/b3-trading-platform.git
   cd b3-trading-platform
   ./quick-start.sh
   ```

4. **Configure seu domínio no .env**

5. **Deploy:**
   ```bash
   make deploy-full
   ```

## 📚 Documentação Adicional

- **[HOSTINGER_DEPLOY.md](HOSTINGER_DEPLOY.md)** - Guia completo de deploy na Hostinger
- **[Makefile](Makefile)** - Todos os comandos disponíveis
- **[quick-start.sh](quick-start.sh)** - Script de configuração automática

## 🆘 Suporte

- 📖 Consulte a documentação completa em `HOSTINGER_DEPLOY.md`
- 🐛 Reporte problemas no GitHub Issues
- 💬 Para dúvidas, abra uma discussão no repositório

---

**✅ Com esta configuração, sua B3 Trading Platform estará pronta para produção na Hostinger!**