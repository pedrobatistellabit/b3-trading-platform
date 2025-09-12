# B3 Trading Platform

B3 Trading Platform is a comprehensive trading system that integrates Brazilian stock market (B3) data with MetaTrader 5 for automated trading. The platform consists of a FastAPI backend, Next.js frontend, Redis-based market data simulator, PostgreSQL database, and MetaTrader 5 Expert Advisor.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Critical Build and Timing Information
- **NEVER CANCEL builds or long-running commands** - builds may take 30+ minutes
- **Docker Compose full build**: Takes 20-30 minutes. NEVER CANCEL. Set timeout to 45+ minutes minimum.
- **Frontend npm install**: Takes 15-20 minutes and often fails due to dependency conflicts. NEVER CANCEL. Set timeout to 30+ minutes.
- **Backend pip install**: Often fails due to SSL certificate issues and compilation requirements for numpy/ta-lib.
- **Market data service**: Builds quickly (2-3 minutes) as it has minimal dependencies.

### Bootstrap and Build the Platform
```bash
# Prerequisites - ensure these are available
docker --version  # Required: Docker 20+
docker compose version  # Required: Docker Compose v2.x

# Full platform build (CRITICAL: 45+ minute timeout)
cd /path/to/b3-trading-platform
time docker compose build --no-cache  # NEVER CANCEL: Takes 20-30 minutes

# Alternative: Build services individually to isolate issues
docker build ./backend --no-cache      # Often fails due to SSL/pip issues
docker build ./frontend --no-cache     # Often fails due to npm dependency conflicts  
docker build ./services/market-data --no-cache  # Usually succeeds in 2-3 minutes
```

### Known Build Issues and Workarounds
- **Frontend npm install fails**: Use `npm install --legacy-peer-deps` to resolve React version conflicts
- **Backend pip install fails**: SSL certificate verification errors are common - builds may need to run in environments with proper certificate chains
- **Dependency conflicts**: Frontend has React 18.0.0 vs Next.js requiring 18.2.0+ - documented limitation
- **Network timeouts**: PyPI and npm registry timeouts are common - retry builds multiple times

### Run the Platform
```bash
# Start all services (requires successful build first)
docker compose up -d

# Check service health
docker compose ps
docker compose logs api      # Backend logs
docker compose logs web      # Frontend logs  
docker compose logs postgres # Database logs
docker compose logs redis    # Cache logs

# Access services
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# Backend API docs: http://localhost:8000/docs
# Database: localhost:5432
# Redis: localhost:6379
# Grafana: http://localhost:3001
```

### Development and Testing
```bash
# Backend local development (if dependencies install successfully)
cd backend
pip3 install --user -r requirements.txt  # Often fails due to numpy/ta-lib compilation
python3 src/main.py  # Runs on port 8000

# Frontend local development (if dependencies install successfully)
cd frontend  
npm install --legacy-peer-deps  # Required due to React version conflicts
npm run dev  # Runs on port 3000

# Test API endpoints
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/market/WINFUT
```

## Validation

### Manual Functional Testing
After building and running the platform, ALWAYS test these scenarios:

1. **API Health Check**: Verify `GET /health` returns status "healthy"
2. **Market Data Simulation**: Check `GET /api/v1/market/WINFUT` returns simulated price data
3. **WebSocket Connection**: Frontend should connect to `ws://localhost:8000/ws` and receive real-time market data
4. **Trade Execution**: Test `POST /api/v1/trade` with sample trade data
5. **Frontend Dashboard**: Verify the trading dashboard loads and displays market data
6. **MT5 Integration**: Test MetaTrader 5 EA connection (requires MT5 installation)

### MetaTrader 5 Expert Advisor Setup
```bash
# Copy EA to MT5 directory (Windows)
cp mt5-ea/B3TradingPlatform.mq5 "C:\Users\[USER]\AppData\Roaming\MetaQuotes\Terminal\[INSTANCE]\MQL5\Experts\"

# Configure MT5 settings:
# 1. Tools > Options > Expert Advisors
# 2. Enable "Allow automated trading"
# 3. Enable "Allow DLL imports" 
# 4. Enable "Allow WebRequest" and add: http://localhost:8000
# 5. Compile EA with F7 in MetaEditor
# 6. Apply EA to chart with parameters:
#    - ApiUrl: http://localhost:8000
#    - RiskPercent: 2.0
#    - MagicNumber: 123456
```

### CI/CD Validation
```bash
# The platform has basic GitHub Actions for Docker builds
# Check .github/workflows/docker-image.yml for CI configuration
# ALWAYS ensure builds pass locally before pushing changes
```

## Architecture and Key Components

### Directory Structure
```
/
├── backend/              # FastAPI backend service
│   ├── src/main.py      # Main API application
│   ├── requirements.txt # Python dependencies (problematic numpy/ta-lib)
│   └── Dockerfile       # Backend container config
├── frontend/            # Next.js frontend application  
│   ├── src/app/page.tsx # Main dashboard component
│   ├── package.json     # Node.js dependencies (React version conflicts)
│   └── Dockerfile       # Frontend container config
├── services/
│   └── market-data/     # Redis-based market data simulator
│       ├── main.py      # Market data generation service
│       └── requirements.txt # Minimal Python dependencies
├── mt5-ea/              # MetaTrader 5 Expert Advisor
│   ├── B3TradingPlatform.mq5    # MQL5 source code
│   └── docs/instalacao-ea.md    # MT5 installation guide
├── database/
│   └── init.sql         # PostgreSQL initialization
├── docker-compose.yml   # Full stack orchestration
├── compose.yaml         # Frontend-only composition
└── .env                # Environment variables
```

### Key Services and Ports
- **Backend API (FastAPI)**: Port 8000 - Main trading API with WebSocket support
- **Frontend (Next.js)**: Port 3000 - Trading dashboard and user interface
- **PostgreSQL Database**: Port 5432 - Trading data storage
- **Redis Cache**: Port 6379 - Caching and pub/sub messaging
- **Market Data Service**: No external port - Internal Redis publisher
- **Grafana Monitoring**: Port 3001 - System monitoring dashboards

### Important Configuration Files
- **docker-compose.yml**: Full production stack with all services
- **compose.yaml**: Development frontend-only stack
- **.env**: Environment variables including database passwords, API keys
- **backend/requirements.txt**: Python dependencies (problematic)
- **frontend/package.json**: Node.js dependencies (version conflicts)

## Common Development Tasks

### Making Backend Changes
1. Always test changes by running the FastAPI development server locally first
2. Backend uses simple market simulation - no real B3 API integration
3. WebSocket endpoint `/ws` broadcasts simulated market data every second
4. Key endpoints: `/health`, `/api/v1/market/{symbol}`, `/api/v1/trade`, `/ws`

### Making Frontend Changes  
1. Frontend connects to backend via axios HTTP requests and WebSocket
2. Main dashboard at `src/app/page.tsx` shows market data and trading interface
3. Uses Tailwind CSS for styling and Recharts for data visualization
4. Expects backend running on `http://localhost:8000`

### MetaTrader 5 Integration
1. EA source code in `mt5-ea/B3TradingPlatform.mq5` 
2. EA sends market data to backend `/api/v1/mt5/market-data` endpoint
3. EA receives trading signals from backend `/api/v1/mt5/signal` endpoint  
4. Requires proper MT5 configuration for WebRequest permissions

### Database Operations
1. PostgreSQL initialization script at `database/init.sql`
2. Database connection configured via `DATABASE_URL` environment variable
3. Uses SQLAlchemy ORM in backend (though current implementation uses simulation data)

## Troubleshooting

### Build Failures
- **npm dependency conflicts**: Always use `npm install --legacy-peer-deps`
- **Python SSL errors**: May require environment with proper certificate chains
- **Docker timeouts**: Increase Docker build timeout settings, never cancel builds
- **Memory issues**: Ensure sufficient disk space (5GB+) and memory (4GB+) for builds

### Runtime Issues  
- **Port conflicts**: Ensure ports 3000, 8000, 5432, 6379 are available
- **Database connection**: Verify PostgreSQL is running and credentials match .env file
- **WebSocket errors**: Check CORS configuration and firewall settings
- **MT5 EA errors**: Verify WebRequest permissions and API URL configuration

### Performance Notes
- **Market data updates**: Default 1-second intervals via WebSocket
- **Database queries**: Currently uses in-memory simulation data
- **Redis performance**: Used for caching and pub/sub, minimal load
- **Frontend rendering**: Real-time chart updates may impact browser performance

## Important Warnings
- **NEVER CANCEL** any build command that takes more than 2 minutes
- **ALWAYS test** in demo mode before live trading with MetaTrader 5
- **VERIFY** all environment variables are properly configured before deployment
- **MONITOR** system resources during builds (can consume 4GB+ memory)
- **BACKUP** any trading data before making database schema changes