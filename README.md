# 🚀 B3 Trading Platform - Deployment Guide

A comprehensive trading platform for the Brazilian stock exchange (B3) with MetaTrader 5 integration.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Environment Configuration](#environment-configuration)
- [Deployment Options](#deployment-options)
- [Production Deployment](#production-deployment)
- [Monitoring & Logging](#monitoring--logging)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

- **Docker** & **Docker Compose** (v2.0+)
- **Git**
- **Minimum 4GB RAM** and **10GB disk space**
- **curl** (for health checks)

### Installing Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**macOS:**
```bash
brew install --cask docker
```

**Windows:**
Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## 🚀 Quick Start

1. **Clone the repository:**
```bash
git clone https://github.com/pedrobatistellabit/b3-trading-platform.git
cd b3-trading-platform
```

2. **Deploy with one command:**
```bash
./deploy.sh dev
```

3. **Access the platform:**
- 🌐 **Frontend:** http://localhost:3000
- 📡 **API:** http://localhost:8000
- 📚 **API Docs:** http://localhost:8000/docs
- 📊 **Grafana:** http://localhost:3001
- 🗄️ **Database:** localhost:5432

## ⚙️ Environment Configuration

### Development Environment (Default)
```bash
./deploy.sh dev
```
- Uses `.env` file
- Debug mode enabled
- Local development settings

### Staging Environment
```bash
./deploy.sh staging
```
- Uses `.env.staging` file
- Production-like settings
- Reduced resource limits

### Production Environment
```bash
./deploy.sh prod
```
- Uses `.env.prod` file
- Optimized for performance
- Security hardened

## 🔒 Environment Variables

Key variables you need to configure:

### Security (CRITICAL - Change in production!)
```env
DB_PASSWORD=your_secure_db_password
REDIS_PASSWORD=your_secure_redis_password
JWT_SECRET_KEY=your_jwt_secret_key
GRAFANA_PASSWORD=your_grafana_password
```

### API Configuration
```env
NEXT_PUBLIC_API_URL=http://localhost:8000  # Change for production
B3_API_KEY=your_b3_api_key
B3_ENVIRONMENT=sandbox  # or 'production'
```

### MetaTrader 5 Integration
```env
MT5_LOGIN=your_mt5_login
MT5_PASSWORD=your_mt5_password
MT5_SERVER=your_broker_server
```

## 🏭 Production Deployment

### 1. Server Requirements
- **CPU:** 2+ cores
- **RAM:** 8GB minimum, 16GB recommended
- **Storage:** 50GB SSD
- **Network:** Static IP, SSL certificate

### 2. Security Setup

**Update passwords:**
```bash
cp .env.prod .env
# Edit .env and change all CHANGE_ME_ values
nano .env
```

**SSL Certificate (Recommended):**
Add reverse proxy (nginx/traefik) with SSL termination.

### 3. Database Backup
```bash
# Backup
docker compose exec postgres pg_dump -U trader b3trading > backup.sql

# Restore
docker compose exec -T postgres psql -U trader b3trading < backup.sql
```

### 4. Monitoring Setup

**Grafana Access:**
- URL: http://localhost:3001
- User: admin
- Password: (from GRAFANA_PASSWORD env var)

## 📊 Services Overview

| Service | Port | Description |
|---------|------|-------------|
| **Frontend** | 3000 | Next.js web interface |
| **API** | 8000 | FastAPI backend |
| **Database** | 5432 | PostgreSQL |
| **Redis** | 6379 | Cache & sessions |
| **Grafana** | 3001 | Monitoring dashboard |
| **Market Data** | - | Real-time data simulator |

## 🔧 Management Commands

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f web
docker compose logs -f postgres
```

### Restart Services
```bash
# All services
docker compose restart

# Specific service
docker compose restart api
```

### Scale Services
```bash
# Scale API instances
docker compose up -d --scale api=3
```

### Database Management
```bash
# Connect to database
docker compose exec postgres psql -U trader -d b3trading

# Run migrations (if implemented)
docker compose exec api alembic upgrade head
```

## 🐛 Troubleshooting

### Common Issues

**1. Port already in use:**
```bash
# Check what's using the port
sudo lsof -i :3000
sudo lsof -i :8000

# Kill the process or change ports in docker-compose.yml
```

**2. Docker out of space:**
```bash
# Clean up Docker
docker system prune -a
docker volume prune
```

**3. Database connection errors:**
```bash
# Check database health
docker compose exec postgres pg_isready -U trader -d b3trading

# Reset database
docker compose down -v
docker compose up -d postgres
```

**4. Frontend can't connect to API:**
- Check `NEXT_PUBLIC_API_URL` in environment file
- Ensure API service is healthy: `curl http://localhost:8000/health`

### Health Checks
```bash
# API
curl http://localhost:8000/health

# Frontend
curl http://localhost:3000

# Database
docker compose exec postgres pg_isready -U trader -d b3trading
```

### Performance Monitoring
```bash
# Container stats
docker stats

# Service resource usage
docker compose top
```

## 🔄 CI/CD Pipeline

The platform includes GitHub Actions for:
- ✅ **Testing:** Frontend lint & build, backend tests
- 🐳 **Building:** Multi-component Docker images
- 🚀 **Deployment:** Automated staging/production deploys

### Manual Docker Build
```bash
# Build all images
docker compose build

# Build specific service
docker compose build api
```

## 🛡️ Security Best Practices

1. **Change default passwords** in production
2. **Use SSL/HTTPS** in production
3. **Limit database access** to application only
4. **Regular security updates**
5. **Monitor logs** for suspicious activity
6. **Backup regularly**

## 📞 Support

- 📧 **Issues:** [GitHub Issues](https://github.com/pedrobatistellabit/b3-trading-platform/issues)
- 📖 **Documentation:** See `/docs` folder
- 💬 **Discussions:** [GitHub Discussions](https://github.com/pedrobatistellabit/b3-trading-platform/discussions)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**⚠️ Risk Warning:** Trading involves substantial risk and may result in significant losses. This software is for educational purposes only and should not be used for actual trading without proper testing and risk management.