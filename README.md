# B3 Trading Platform

A comprehensive trading platform for B3 (Brasil, Bolsa, Balcão) with MetaTrader 5 integration, featuring real-time market data, automated trading capabilities, and a modern web interface.

## 🏗️ Architecture

The platform consists of multiple services orchestrated with Docker:

- **Backend API** (FastAPI): Core trading API with REST endpoints and WebSocket support
- **Frontend** (Next.js): Modern React-based web interface
- **Market Data Service** (Python): Real-time market data simulation and processing
- **Database** (PostgreSQL): Data persistence
- **Cache** (Redis): Session management and real-time data caching
- **Monitoring** (Grafana): System monitoring and metrics

## 🐳 Docker Build Workflow

### Automated CI/CD Pipeline

The project includes automated Docker image builds using GitHub Actions:

#### Workflow Triggers
- **Push to main branch**: Builds and pushes images to GitHub Packages
- **Pull requests**: Builds images for testing (no push)

#### Built Images
The workflow builds and publishes the following images to `ghcr.io`:

1. **Main Application Image**: `ghcr.io/pedrobatistellabit/b3-trading-platform:latest`
   - Multi-stage build containing the complete application
   - Defaults to running the backend API service
   - Includes health checks and proper security configuration

2. **Individual Service Images**:
   - `ghcr.io/pedrobatistellabit/b3-trading-platform-backend:latest`
   - `ghcr.io/pedrobatistellabit/b3-trading-platform-frontend:latest`
   - `ghcr.io/pedrobatistellabit/b3-trading-platform-market-data:latest`

#### Image Tagging
Images are tagged with:
- `latest` (for main branch)
- Git SHA (e.g., `sha-abc1234`)
- Branch name (e.g., `main`)

### Local Development

#### Prerequisites
- Docker and Docker Compose installed
- Git

#### Quick Start
```bash
# Clone the repository
git clone https://github.com/pedrobatistellabit/b3-trading-platform.git
cd b3-trading-platform

# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

#### Individual Service Development
```bash
# Build specific service
docker build -t b3-backend ./backend
docker build -t b3-frontend ./frontend
docker build -t b3-market-data ./services/market-data

# Run specific service
docker run -p 8000:8000 b3-backend
docker run -p 3000:3000 b3-frontend
```

### Production Deployment

#### Using GitHub Packages Images
```bash
# Pull and run the main application
docker pull ghcr.io/pedrobatistellabit/b3-trading-platform:latest
docker run -p 8000:8000 ghcr.io/pedrobatistellabit/b3-trading-platform:latest

# Or use individual services
docker pull ghcr.io/pedrobatistellabit/b3-trading-platform-backend:latest
docker pull ghcr.io/pedrobatistellabit/b3-trading-platform-frontend:latest
docker pull ghcr.io/pedrobatistellabit/b3-trading-platform-market-data:latest
```

#### Environment Configuration
Create a `.env` file with required environment variables:
```env
# Database
POSTGRES_DB=b3trading
POSTGRES_USER=trader
DB_PASSWORD=your_secure_password

# Redis
REDIS_PASSWORD=your_redis_password

# Grafana
GRAFANA_PASSWORD=your_grafana_password
```

## 🚀 Services

### Backend API (Port 8000)
- **Health Check**: `GET /health`
- **Market Data**: `GET /api/v1/market/{symbol}`
- **Trading**: `POST /api/v1/trade`
- **Positions**: `GET /api/v1/positions`
- **Account Info**: `GET /api/v1/account`
- **WebSocket**: `ws://localhost:8000/ws`
- **MT5 Integration**: `POST /api/v1/mt5/signal`

### Frontend (Port 3000)
- Modern React dashboard
- Real-time market data display
- Trading interface
- Position management
- WebSocket integration for live updates

### Market Data Service
- Simulates real-time market data
- Publishes data to Redis
- Supports multiple instruments (WINFUT, etc.)

## 🔧 Development

### Project Structure
```
├── backend/              # FastAPI backend service
│   ├── src/             # Source code
│   ├── Dockerfile       # Backend container configuration
│   └── requirements.txt # Python dependencies
├── frontend/            # Next.js frontend application
│   ├── src/            # React components and pages
│   ├── Dockerfile      # Frontend container configuration
│   └── package.json    # Node.js dependencies
├── services/
│   └── market-data/    # Market data simulation service
├── database/           # Database initialization scripts
├── mt5-ea/            # MetaTrader 5 Expert Advisor
├── docker-compose.yml  # Local development orchestration
├── Dockerfile         # Multi-stage production build
└── .github/workflows/ # CI/CD automation
```

### GitHub Actions Workflow

The Docker build workflow (`.github/workflows/docker-image.yml`) includes:

1. **Build and Test Job**: Validates all service builds
2. **Main Image Job**: Builds and pushes the main application image
3. **Service Images Job**: Builds and pushes individual service images

**Permissions**: The workflow uses the default `GITHUB_TOKEN` with appropriate permissions to push to GitHub Packages.

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker
5. Submit a pull request

The CI pipeline will automatically build and test your changes.

## 📊 Monitoring

Access Grafana dashboard at `http://localhost:3001` (admin/password from .env file) to monitor:
- API request metrics
- Database performance
- System resource usage
- Trading activity

## 🔐 Security

- All services run with non-root users where possible
- Sensitive data stored in environment variables
- HTTPS/WSS support in production
- Regular security updates via automated builds

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This is a demonstration trading platform. Do not use with real money without proper testing and risk management procedures.