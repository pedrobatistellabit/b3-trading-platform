# B3 Trading Platform Development Instructions

B3 Trading Platform is a comprehensive trading system with React/Next.js frontend, FastAPI Python backend, PostgreSQL database, Redis cache, market data simulation, and MetaTrader 5 Expert Advisor integration. All services are orchestrated using Docker Compose.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Bootstrap and Build the Platform
**CRITICAL: NEVER CANCEL builds or long-running commands. Set timeouts to 60+ minutes for builds.**

#### Frontend (Next.js/React)
- Prerequisites: Node.js v20+ and npm v10+
- **Navigate to frontend directory**: `cd frontend/`
- **Install dependencies**: `npm install --legacy-peer-deps` -- takes ~15 seconds
- **Build the application**: `npm run build` -- takes ~20 seconds. NEVER CANCEL.
- **Start development server**: `npm run dev` -- starts on http://localhost:3000
- **Lint the code**: `npm run lint`

**Important**: The frontend requires `--legacy-peer-deps` flag due to React version conflicts between Next.js 14 and React 18.2.

#### Backend (FastAPI/Python)
- Prerequisites: Python 3.12+ and pip3
- **Navigate to backend directory**: `cd backend/`
- **Install dependencies**: `pip3 install -r requirements.txt` -- **WARNING: May fail due to network connectivity issues with PyPI**
- **Alternative for testing**: Use the test server script from `/tmp/test_api_server.py` which provides basic API functionality
- **Start development server**: `python3 src/main.py` or `uvicorn src.main:app --host 0.0.0.0 --port 8000`

#### Docker Compose (Recommended Production Setup)
**CRITICAL: Docker builds may take 20+ minutes. NEVER CANCEL. Set timeout to 60+ minutes.**

**Important**: There are two compose files:
- `docker-compose.yml` -- Complete multi-service setup (recommended)
- `compose.yaml` -- Simple frontend-only setup

**For full platform (recommended)**:
- **Build all services**: `docker compose -f docker-compose.yml build` -- takes 20+ minutes due to npm package resolution. NEVER CANCEL.
- **Start all services**: `docker compose -f docker-compose.yml up` -- starts all containers including PostgreSQL, Redis, Grafana
- **Build and start**: `docker compose -f docker-compose.yml up --build` -- combines build and start
- **Stop all services**: `docker compose -f docker-compose.yml down`

**For frontend only**:
- **Build frontend**: `docker compose build` -- uses compose.yaml, builds only frontend
- **Start frontend**: `docker compose up` -- starts only frontend container

**Full Platform Services and Ports (docker-compose.yml)**:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- PostgreSQL: localhost:5432
- Redis: localhost:6379
- Grafana: http://localhost:3001

## Testing and Validation

### Manual Testing Scenarios
**ALWAYS run through complete end-to-end scenarios after making changes:**

1. **Frontend-Backend Integration Test**:
   - Start backend API (port 8000) and frontend dev server (port 3000)
   - Navigate to http://localhost:3000
   - Verify dashboard loads with account information (Balance: R$ 50,000, etc.)
   - Check WebSocket connection status (red dot = disconnected, green dot = connected)
   - Test market data display for WINFUT and WDOFUT symbols

2. **API Endpoint Validation**:
   - `curl http://localhost:8000/health` -- should return healthy status
   - `curl http://localhost:8000/api/v1/market/WINFUT` -- should return market data
   - `curl http://localhost:8000/api/v1/account` -- should return account info
   - `curl -X POST http://localhost:8000/api/v1/trade -H "Content-Type: application/json" -d '{"symbol":"WINFUT","side":"BUY","quantity":1}'` -- should execute trade

3. **Database Integration** (with Docker):
   - Connect to PostgreSQL: `psql -h localhost -p 5432 -U trader -d b3trading`
   - Password: `b3_secure_pass_2024` (from .env file)
   - Verify tables exist: `\dt trading.*`

### Build Validation Steps
- **Frontend**: Always run `npm run lint` and `npm run build` before committing
- **Backend**: Always validate Python syntax with: `python3 -m py_compile src/main.py`
- **Docker Full Platform**: Test build: `docker compose -f docker-compose.yml build api`
- **Docker Frontend Only**: Test build: `docker compose build b3tradingfrontend`

## Known Issues and Workarounds

### Network Connectivity Issues
- **PyPI timeouts**: Python package installation may fail due to network issues
- **Workaround for backend testing**: Use the provided test API server:
  ```bash
  # Copy test server to project root (if not already there)
  python3 -c "
  import json, random, time
  from datetime import datetime
  from http.server import HTTPServer, BaseHTTPRequestHandler
  # ... (test server code available in project)
  "
  # Or run: python3 /tmp/test_api_server.py
  ```
- **Docker npm install**: May take 20+ minutes due to missing package-lock.json

### Package Version Conflicts
- **Frontend React versions**: Use `npm install --legacy-peer-deps` to resolve
- **Next.js config warnings**: Invalid `appDir` option warnings are non-critical
- **TypeScript version**: Frontend package.json has been updated to use TypeScript ^5.2.0

### Environment Configuration
- **Environment variables**: All configured in `.env` file with secure defaults
- **Database credentials**: `trader` / `b3_secure_pass_2024`
- **Redis password**: `redis_b3_pass_2024`
- **JWT secret**: Pre-configured for development

## Architecture Overview

### Project Structure
```
├── backend/                 # FastAPI Python backend
│   ├── src/main.py         # Main API server with WebSocket support
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Backend container
├── frontend/               # Next.js React frontend
│   ├── src/app/           # React components and pages
│   ├── package.json       # Node.js dependencies (corrected versions)
│   └── Dockerfile         # Frontend container
├── database/              # PostgreSQL schema and initialization
│   └── init.sql           # Complete trading database schema
├── services/              # Additional microservices
│   └── market-data/       # Market data simulator service
├── mt5-ea/               # MetaTrader 5 Expert Advisor
│   ├── B3TradingPlatform.mq5  # MQL5 Expert Advisor code
│   └── docs/             # MT5 integration documentation
├── docker-compose.yml    # Complete multi-service orchestration
└── .env                  # Environment variables with secure defaults
```

### Key Technologies
- **Frontend**: Next.js 14, React 18.2, TypeScript, Tailwind CSS, WebSocket integration
- **Backend**: FastAPI, Python 3.12, WebSocket, asyncio
- **Database**: PostgreSQL 15 with complete trading schema (users, accounts, orders, positions, market_data)
- **Cache**: Redis 7 for session management and real-time data
- **Monitoring**: Grafana for system metrics
- **Trading**: MetaTrader 5 Expert Advisor integration via API

### Database Schema Highlights
- Complete trading system tables: `trading.users`, `trading.accounts`, `trading.orders`, `trading.positions`
- Market data storage: `trading.market_data`, `trading.symbols`
- API logging: `trading.api_logs`
- Default admin user: `admin` / `admin123`
- Demo trading account pre-configured

## MetaTrader 5 Integration

### Expert Advisor Setup
- **Location**: `mt5-ea/B3TradingPlatform.mq5`
- **Documentation**: `mt5-ea/docs/instalacao-ea.md`
- **API Integration**: Sends signals to `http://localhost:8000/api/v1/mt5/signal`
- **Configuration**: Set API URL, risk percentage, magic number in EA parameters

### Requirements for MT5
- MetaTrader 5 platform installed
- WebRequest permissions enabled for localhost:8000
- DLL imports allowed
- Demo or live trading account

## Performance and Timing

### Expected Build Times
- **Frontend npm install**: ~15 seconds (with --legacy-peer-deps)
- **Frontend build**: ~20 seconds
- **Docker compose build**: 20+ minutes (NEVER CANCEL - set timeout to 60+ minutes)
- **Container startup**: 2-3 minutes for all services

### Startup Sequence
1. **Database**: PostgreSQL starts first with health checks
2. **Redis**: Cache service with authentication
3. **Backend API**: Waits for database and Redis health checks
4. **Frontend**: Starts after backend is ready
5. **Market Data Service**: Begins real-time simulation
6. **Grafana**: Monitoring dashboard

## Security Configuration

### Default Credentials (Development)
- **Database**: `trader` / `b3_secure_pass_2024`
- **Redis**: Password `redis_b3_pass_2024`
- **Grafana**: `admin` / `grafana_admin_2024`
- **Default Trading Account**: Balance R$ 50,000, Demo mode

### API Security
- JWT token authentication configured
- CORS enabled for localhost development
- Rate limiting recommended for production

## Troubleshooting Common Issues

### Frontend Issues
- **React version conflicts**: Use `npm install --legacy-peer-deps`
- **Build failures**: Check Node.js version (requires v20+)
- **WebSocket connection**: Ensure backend is running on port 8000

### Backend Issues
- **Package installation failures**: Use test server for development
- **Database connection**: Verify PostgreSQL container is healthy
- **API endpoints**: Check Docker network connectivity

### Docker Issues
- **Long build times**: Normal, wait for completion (20+ minutes)
- **Port conflicts**: Ensure ports 3000, 8000, 5432, 6379, 3001 are available
- **Memory usage**: Docker containers may require 4GB+ RAM

## Development Workflow

### Making Changes
1. **Always validate** with existing tests and build commands
2. **Frontend changes**: Test with `npm run dev` and `npm run build`
3. **Backend changes**: Validate syntax and test API endpoints
4. **Database changes**: Update `database/init.sql` if schema changes
5. **Docker changes**: Test builds individually before full compose build

### Before Committing
- Run `npm run lint` in frontend directory
- Validate Python syntax: `python3 -m py_compile backend/src/main.py`
- Test manual scenarios described in Testing section
- Ensure Docker compose can start successfully

**Remember: This platform provides a complete trading simulation environment with real-time market data, order execution, and position management. Always test trading functionality thoroughly before deploying to production.**