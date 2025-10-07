# B3 Trading Platform

A comprehensive trading platform for B3 (Brazilian Stock Exchange) featuring real-time market data, automated trading capabilities, and portfolio management.

## Architecture

The platform consists of multiple microservices:

- **Backend API** (`./backend`) - FastAPI-based REST API and WebSocket server
- **Frontend** (`./frontend`) - Next.js web application
- **Market Data Service** (`./services/market-data`) - Real-time market data simulator
- **PostgreSQL** - Database for storing trading data
- **Redis** - Cache and message broker
- **Grafana** - Monitoring and analytics

## Docker Images

Docker images are automatically built and pushed to GitHub Container Registry (ghcr.io) when changes are merged to the main branch.

### Available Images

- `ghcr.io/pedrobatistellabit/b3-trading-platform/backend:latest`
- `ghcr.io/pedrobatistellabit/b3-trading-platform/frontend:latest`
- `ghcr.io/pedrobatistellabit/b3-trading-platform/market-data:latest`

### GitHub Actions Workflow

The `.github/workflows/docker-image.yml` workflow automatically:

1. Builds Docker images for all services on push and pull requests
2. Pushes images to GitHub Container Registry when changes are merged to main
3. Uses Docker layer caching to speed up builds
4. Tags images with branch name, PR number, commit SHA, and `latest` for main branch

### Building Docker Images Locally

Build individual services:

```bash
# Backend
docker build -t b3-backend ./backend

# Frontend
docker build -t b3-frontend ./frontend

# Market Data Service
docker build -t b3-market-data ./services/market-data
```

### Running with Docker Compose

Start all services locally:

```bash
# Copy environment variables
cp .env.example .env  # Edit with your configuration

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Development

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local frontend development)
- Python 3.11+ (for local backend development)

### Backend Development

```bash
cd backend
pip install -r requirements.txt
uvicorn src.main:app --reload --port 8000
```

### Frontend Development

```bash
cd frontend
npm install
npm run dev
```

## API Endpoints

- `GET /` - API status
- `GET /health` - Health check
- `GET /api/v1/market/{symbol}` - Get market data for symbol
- `POST /api/v1/trade` - Execute trade
- `GET /api/v1/positions` - Get open positions
- `GET /api/v1/account` - Get account information
- `WebSocket /ws` - Real-time market data stream

## Environment Variables

Configure the following in your `.env` file:

- `POSTGRES_DB` - PostgreSQL database name
- `POSTGRES_USER` - PostgreSQL username
- `POSTGRES_PASSWORD` / `DB_PASSWORD` - PostgreSQL password
- `REDIS_PASSWORD` - Redis password
- `GRAFANA_PASSWORD` - Grafana admin password

## License

[Add your license here]
