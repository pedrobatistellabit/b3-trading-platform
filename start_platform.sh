#!/bin/bash
set -e

echo "🚀 Starting B3 Trading Platform..."
echo "📋 Checking system requirements..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available"
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    echo "💡 Please create .env file with required environment variables"
    exit 1
fi

echo "✅ Environment file found"

# Validate docker-compose configuration
echo "📝 Validating Docker Compose configuration..."
if ! docker compose config > /dev/null; then
    echo "❌ Docker Compose configuration is invalid"
    exit 1
fi

echo "✅ Docker Compose configuration is valid"

# Check if logs directory exists
if [ ! -d logs ]; then
    echo "📁 Creating logs directory..."
    mkdir -p logs
fi

echo "🌟 All integration checks passed!"
echo "🎯 Platform is ready to be executed with: docker compose up -d"
echo ""
echo "Available services:"
echo "  📊 Frontend (Next.js): http://localhost:3000"
echo "  🔧 Backend API (FastAPI): http://localhost:8000"
echo "  📈 Grafana Dashboard: http://localhost:3001"
echo "  🗄️  PostgreSQL Database: localhost:5432"
echo "  📡 Redis Cache: localhost:6379"
echo ""
echo "To start the platform, run:"
echo "  docker compose up -d"
echo ""
echo "To view logs:"
echo "  docker compose logs -f"
echo ""
echo "To stop the platform:"
echo "  docker compose down"