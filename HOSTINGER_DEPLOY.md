# 🚀 B3 Trading Platform - Hostinger Deployment Guide

Este guia explica como fazer deploy da B3 Trading Platform na Hostinger usando Docker Compose.

## 📋 Pré-requisitos

1. **Conta na Hostinger** com VPS ou Cloud Hosting
2. **Docker e Docker Compose** instalados no servidor
3. **Acesso SSH** ao servidor
4. **Domínio configurado** apontando para o servidor

## 🛠️ Configuração Inicial

### 1. Conectar ao Servidor

```bash
ssh root@seu-servidor-hostinger
```

### 2. Instalar Docker (se não estiver instalado)

```bash
# Atualizar sistema
apt update && apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Adicionar usuário ao grupo docker (opcional)
usermod -aG docker $USER

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 3. Clonar o Repositório

```bash
git clone https://github.com/pedrobatistellabit/b3-trading-platform.git
cd b3-trading-platform
```

## ⚙️ Configuração da Aplicação

### 1. Configurar Variáveis de Ambiente

```bash
# Copiar arquivo de exemplo
cp .env.hostinger .env

# Editar configurações
nano .env
```

**Configure os seguintes valores obrigatórios:**

```env
# Senhas seguras (use geradores de senha)
DB_PASSWORD=SuaSenhaSeguraDB123!
REDIS_PASSWORD=SuaSenhaSeguraRedis456!
JWT_SECRET_KEY=SuaChaveJWTMuitoSeguraComPeloMenos32Caracteres

# Seu domínio
NEXT_PUBLIC_API_URL=https://seudominio.com/api
DOMAIN_NAME=seudominio.com

# Credenciais B3 (se disponível)
B3_API_KEY=sua_api_key_b3
B3_ENVIRONMENT=production
```

### 2. Criar Diretórios Necessários

```bash
mkdir -p logs monitoring/grafana/{dashboards,datasources}
chmod 755 logs
```

## 🚀 Deploy da Aplicação

### 1. Build e Start dos Serviços

```bash
# Build das imagens
docker compose -f docker-compose.hostinger.yml build

# Iniciar todos os serviços
docker compose -f docker-compose.hostinger.yml up -d

# Verificar status
docker compose -f docker-compose.hostinger.yml ps
```

### 2. Verificar Logs

```bash
# Ver logs de todos os serviços
docker compose -f docker-compose.hostinger.yml logs -f

# Ver logs específicos
docker compose -f docker-compose.hostinger.yml logs -f api
docker compose -f docker-compose.hostinger.yml logs -f web
```

### 3. Testar a Aplicação

```bash
# Teste de health check
curl http://localhost/health

# Teste da API
curl http://localhost/api/v1/health
```

## 🔒 Configuração SSL (Recomendado)

### 1. Obter Certificado SSL

```bash
# Instalar Certbot
apt install certbot

# Obter certificado
certbot certonly --standalone -d seudominio.com

# Certificados ficam em: /etc/letsencrypt/live/seudominio.com/
```

### 2. Configurar Nginx para HTTPS

```bash
# Copiar certificados para o projeto
mkdir -p nginx/ssl
cp /etc/letsencrypt/live/seudominio.com/fullchain.pem nginx/ssl/cert.pem
cp /etc/letsencrypt/live/seudominio.com/privkey.pem nginx/ssl/key.pem

# Editar nginx.conf para habilitar HTTPS
nano nginx/nginx.conf
# Descomente as seções HTTPS no arquivo
```

### 3. Reiniciar com SSL

```bash
# Atualizar configuração de SSL no .env
echo "SSL_ENABLED=true" >> .env

# Reiniciar serviços
docker compose -f docker-compose.hostinger.yml restart nginx
```

## 📊 Monitoramento (Opcional)

### Habilitar Grafana

```bash
# Iniciar com perfil de monitoramento
docker compose -f docker-compose.hostinger.yml --profile monitoring up -d

# Acessar Grafana em: http://seudominio.com/monitoring/
# Usuário: admin
# Senha: definida em GRAFANA_PASSWORD no .env
```

## 🔧 Comandos Úteis

### Gerenciamento de Serviços

```bash
# Parar todos os serviços
docker compose -f docker-compose.hostinger.yml down

# Parar e remover volumes (CUIDADO: apaga dados)
docker compose -f docker-compose.hostinger.yml down -v

# Reiniciar serviço específico
docker compose -f docker-compose.hostinger.yml restart api

# Rebuild de um serviço
docker compose -f docker-compose.hostinger.yml build api
```

### Backup e Restauração

```bash
# Backup do banco de dados
docker compose -f docker-compose.hostinger.yml exec postgres pg_dump -U trader b3trading > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker compose -f docker-compose.hostinger.yml exec -T postgres psql -U trader b3trading < backup_20241201.sql
```

### Limpeza do Sistema

```bash
# Remover imagens não utilizadas
docker system prune -f

# Remover volumes órfãos
docker volume prune -f
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Erro de conexão com banco de dados**
   ```bash
   # Verificar se o postgres está rodando
   docker compose -f docker-compose.hostinger.yml logs postgres
   
   # Verificar conectividade
   docker compose -f docker-compose.hostinger.yml exec api ping postgres
   ```

2. **Problemas de memória**
   ```bash
   # Verificar uso de recursos
   docker stats
   
   # Ajustar limites no docker-compose.hostinger.yml
   ```

3. **Nginx não consegue se conectar aos serviços**
   ```bash
   # Verificar se os serviços estão no ar
   docker compose -f docker-compose.hostinger.yml ps
   
   # Testar conectividade interna
   docker compose -f docker-compose.hostinger.yml exec nginx wget -qO- http://api:8000/health
   ```

### Logs Importantes

```bash
# Ver logs de erro do Nginx
docker compose -f docker-compose.hostinger.yml exec nginx tail -f /var/log/nginx/error.log

# Ver logs da aplicação
docker compose -f docker-compose.hostinger.yml logs -f api web
```

## 📈 Otimização para Produção

### 1. Configurar Firewall

```bash
# Permitir apenas portas necessárias
ufw enable
ufw allow ssh
ufw allow 80
ufw allow 443
```

### 2. Configurar Backup Automático

```bash
# Criar script de backup
cat > /root/backup.sh << 'EOF'
#!/bin/bash
cd /root/b3-trading-platform
docker compose -f docker-compose.hostinger.yml exec -T postgres pg_dump -U trader b3trading | gzip > /root/backups/backup_$(date +%Y%m%d_%H%M%S).sql.gz
find /root/backups -name "*.sql.gz" -mtime +7 -delete
EOF

chmod +x /root/backup.sh

# Configurar cron
crontab -e
# Adicionar: 0 2 * * * /root/backup.sh
```

### 3. Monitoramento de Recursos

```bash
# Instalar htop para monitoramento
apt install htop

# Configurar alertas de disco
echo "*/5 * * * * df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print \$5 \" \" \$1 }' | while read output; do usage=\$(echo \$output | awk '{ print \$1}' | cut -d'%' -f1); if [ \$usage -ge 80 ]; then echo \"Disk usage alert: \$output\" | mail -s \"Disk Space Alert\" admin@seudominio.com; fi; done" | crontab -
```

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar logs dos serviços
2. Consultar documentação da Hostinger
3. Abrir issue no repositório do GitHub

## 🔄 Atualizações

Para atualizar a aplicação:

```bash
# Pull das mudanças
git pull origin main

# Rebuild e restart
docker compose -f docker-compose.hostinger.yml build
docker compose -f docker-compose.hostinger.yml up -d
```

---

**✅ Após seguir este guia, sua B3 Trading Platform estará rodando na Hostinger com Docker Compose!**