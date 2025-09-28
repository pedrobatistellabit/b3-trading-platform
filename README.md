# 🚀 B3 Trading Platform

A comprehensive algorithmic trading platform for the Brazilian stock exchange (B3) with real-time market data, automated trading execution, and portfolio management capabilities.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    B3 Trading Platform                      │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Next.js)     │  Backend API (FastAPI)           │
│  - Dashboard            │  - Trading Engine                │
│  - Portfolio View       │  - Risk Management               │
│  - Real-time Charts     │  - Order Management              │
├─────────────────────────┼─────────────────────────────────────┤
│  MetaTrader 5 EA        │  Market Data Service             │
│  - MT5 Integration      │  - Real-time Data                │
│  - Order Execution      │  - Data Simulation               │
├─────────────────────────┴─────────────────────────────────────┤
│         PostgreSQL (Data) + Redis (Cache)                  │
└─────────────────────────────────────────────────────────────┘
```

## 🛠️ Technology Stack

- **Backend**: FastAPI (Python) + SQLAlchemy + PostgreSQL
- **Frontend**: Next.js (TypeScript) + React + Tailwind CSS
- **Trading Bridge**: MetaTrader 5 Expert Advisor (MQL5)
- **Data Layer**: PostgreSQL + Redis
- **Market Data**: Python simulation service
- **Monitoring**: Grafana
- **Containerization**: Docker + Docker Compose

## 📋 Prerequisites

- Docker and Docker Compose
- MetaTrader 5 (for EA integration)
- Python 3.11+ (for local development)
- Node.js 18+ (for frontend development)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/pedrobatistellabit/b3-trading-platform.git
cd b3-trading-platform
```

### 2. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
# Set database passwords, API keys, etc.
nano .env
```

### 3. Start the Platform
```bash
# Start all services
docker-compose up -d

# Check services status
docker-compose ps
```

### 4. Access the Application
- **Frontend Dashboard**: http://localhost:3000
- **API Documentation**: http://localhost:8000/docs
- **Grafana Monitoring**: http://localhost:3001

## 🔧 Development Setup

### Backend Development
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or venv\Scripts\activate  # Windows
pip install -r requirements.txt

# Run development server
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
```

### Database Setup
```bash
# Initialize database
cd backend
alembic upgrade head

# Create test data (optional)
python scripts/seed_data.py
```

## 📊 MetaTrader 5 Integration

### Installation
1. Copy `mt5-ea/B3TradingPlatform.mq5` to your MT5 Experts folder
2. Configure MT5 to allow automated trading and WebRequests
3. Add `http://localhost:8000` to allowed URLs
4. Compile and attach the EA to a chart

For detailed instructions, see: [MT5 EA Installation Guide](mt5-ea/docs/instalacao-ea.md)

### Configuration
- **API URL**: http://localhost:8000 (or your server)
- **Risk Percent**: 2.0 (adjust based on your risk tolerance)
- **Magic Number**: Unique identifier for this EA

## 🐳 Docker Services

| Service | Port | Description |
|---------|------|-------------|
| web | 3000 | Next.js frontend dashboard |
| api | 8000 | FastAPI backend API |
| postgres | 5432 | PostgreSQL database |
| redis | 6379 | Redis cache/message broker |
| market-data | - | Market data simulation service |
| grafana | 3001 | Monitoring and observability |

## 📡 API Endpoints

### Trading Operations
- `GET /api/v1/accounts` - List trading accounts
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/positions` - Get current positions
- `GET /api/v1/market-data/{symbol}` - Get market data

### MetaTrader 5 Integration
- `POST /api/v1/mt5/trades` - Receive trades from MT5
- `GET /api/v1/mt5/signals` - Get trading signals for MT5
- `POST /api/v1/mt5/heartbeat` - EA health check

### WebSocket Streams
- `ws://localhost:8000/ws/market-data` - Real-time market data
- `ws://localhost:8000/ws/trades` - Trade execution updates

## ⚠️ Important Safety Notes

- **Always test with demo accounts first**
- **Never risk more than you can afford to lose**
- **Monitor the system constantly during live trading**
- **Keep the backend service running for MT5 integration**
- **Implement proper position sizing and risk management**

## 🔐 Security

- API keys and passwords are stored in environment variables
- Database connections use proper authentication
- All trading operations are logged for audit purposes
- Rate limiting is implemented for API endpoints

## 📊 Monitoring

Access Grafana at http://localhost:3001 to monitor:
- System performance and health
- Trading activity and P&L
- Market data feed status
- Database and Redis metrics

Default credentials: `admin/admin` (change after first login)

## 📝 Configuration

Key environment variables in `.env`:

```bash
# Database
POSTGRES_DB=b3trading
POSTGRES_USER=trader
DB_PASSWORD=your_secure_password

# Redis
REDIS_PASSWORD=your_redis_password

# Trading
RISK_MANAGEMENT_ENABLED=true
MAX_DAILY_LOSS=1000.00
DEFAULT_POSITION_SIZE=0.01

# Monitoring
GRAFANA_PASSWORD=your_grafana_password
```

## 🧪 Testing

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm test

# Integration tests
npm run test:e2e
```

## 📚 Documentation

- [API Documentation](http://localhost:8000/docs) - Interactive API docs
- [MT5 EA Installation](mt5-ea/docs/instalacao-ea.md) - MetaTrader setup guide
- [GitHub Copilot Instructions](.github/copilot-instructions.md) - Development guidelines

## 🤝 Contributing

1. Read the [Copilot Instructions](.github/copilot-instructions.md)
2. Fork the repository
3. Create a feature branch
4. Test thoroughly with demo accounts
5. Submit a pull request

## 📜 License

This project is for educational and research purposes. Please comply with all applicable trading regulations and use at your own risk.

## 🆘 Support

- Check the logs: `docker-compose logs <service-name>`
- Review API documentation at `/docs`
- Ensure all services are healthy: `docker-compose ps`
- Verify MT5 EA is connected and trading is enabled

---

**⚠️ Disclaimer**: This is a trading system that involves financial risk. Always use demo accounts for testing and never trade with money you cannot afford to lose. The developers are not responsible for any trading losses.