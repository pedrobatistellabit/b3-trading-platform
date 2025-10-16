# 🚀 Production Deployment Guide

This guide covers deploying B3 Trading Platform in production environments.

## 📋 Production Checklist

### Security Configuration
- [ ] Change all default passwords in `.env.prod`
- [ ] Generate strong JWT secret key
- [ ] Configure SSL/TLS certificates
- [ ] Set up firewall rules
- [ ] Enable database encryption
- [ ] Configure secure Redis password

### Infrastructure Requirements
- [ ] Minimum 8GB RAM, 16GB recommended
- [ ] 2+ CPU cores
- [ ] 50GB+ SSD storage
- [ ] Static IP address
- [ ] Domain name (for SSL)
- [ ] Backup storage solution

### Monitoring & Logging
- [ ] Configure log retention policies
- [ ] Set up alerting (email/Slack)
- [ ] Configure Grafana dashboards
- [ ] Enable health checks
- [ ] Set up uptime monitoring

## 🏗️ Infrastructure Setup

### 1. Server Preparation

**Ubuntu 20.04+ LTS (Recommended):**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install additional tools
sudo apt install -y curl wget git nginx certbot

# Reboot to apply changes
sudo reboot
```

### 2. Domain & SSL Setup

**Configure DNS:**
```
A record: yourdomain.com -> YOUR_SERVER_IP
A record: api.yourdomain.com -> YOUR_SERVER_IP
```

**Get SSL Certificate:**
```bash
# Install Certbot
sudo snap install certbot --classic

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com -d api.yourdomain.com
```

### 3. Reverse Proxy (Nginx)

Create `/etc/nginx/sites-available/b3-trading`:
```nginx
# Frontend
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # WebSocket support
    location /ws {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# API
server {
    listen 80;
    server_name api.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/b3-trading /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🚀 Application Deployment

### 1. Clone Repository
```bash
cd /opt
sudo git clone https://github.com/pedrobatistellabit/b3-trading-platform.git
sudo chown -R $USER:$USER b3-trading-platform
cd b3-trading-platform
```

### 2. Production Configuration
```bash
# Copy production environment template
cp .env.prod .env

# Edit production configuration
nano .env
```

**Critical variables to update:**
```env
# Security - CHANGE THESE!
DB_PASSWORD=your_very_secure_database_password_here
REDIS_PASSWORD=your_very_secure_redis_password_here
JWT_SECRET_KEY=your_jwt_secret_key_minimum_32_characters_long
GRAFANA_PASSWORD=your_grafana_admin_password

# URLs - Update with your domain
NEXT_PUBLIC_API_URL=https://api.yourdomain.com

# B3 API
B3_API_KEY=your_production_b3_api_key
B3_ENVIRONMENT=production

# MetaTrader 5
MT5_LOGIN=your_production_mt5_login
MT5_PASSWORD=your_production_mt5_password
MT5_SERVER=your_production_broker_server
```

### 3. Deploy Application
```bash
# Deploy with production optimizations
./deploy.sh prod

# Or using make
make prod
```

### 4. Verify Deployment
```bash
# Check service status
docker compose ps

# Check health
make health

# View logs
make logs
```

## 📊 Monitoring Setup

### 1. Grafana Configuration

Access Grafana at `https://yourdomain.com:3001`:
- Username: `admin`
- Password: `(value from GRAFANA_PASSWORD)`

**Import dashboards:**
1. Go to "+" → Import
2. Use dashboard ID: `1860` (Node Exporter Full)
3. Use dashboard ID: `893` (Docker Containers)

### 2. Log Management

**Configure log rotation:**
```bash
# Create logrotate config
sudo tee /etc/logrotate.d/b3-trading << EOF
/opt/b3-trading-platform/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    sharedscripts
    postrotate
        docker compose -f /opt/b3-trading-platform/docker-compose.yml restart api
    endscript
}
EOF
```

---

**📋 Remember:** Always test deployment procedures in staging before applying to production!