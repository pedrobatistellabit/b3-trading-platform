#!/bin/bash

# B3 Trading Platform Deployment Script
# Usage: ./deploy.sh [environment]
# Environments: dev, staging, prod

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

echo "🚀 Deploying B3 Trading Platform to $ENVIRONMENT environment..."

# Validate environment
case $ENVIRONMENT in
  dev|staging|prod)
    echo "✅ Valid environment: $ENVIRONMENT"
    ;;
  *)
    echo "❌ Invalid environment. Use: dev, staging, or prod"
    exit 1
    ;;
esac

# Load environment variables
ENV_FILE=".env"
if [ "$ENVIRONMENT" != "dev" ]; then
  ENV_FILE=".env.$ENVIRONMENT"
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Environment file $ENV_FILE not found!"
  exit 1
fi

echo "📋 Using environment file: $ENV_FILE"

# Copy environment file
cp "$ENV_FILE" .env

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if docker-compose is available
if ! command -v docker &> /dev/null; then
  echo "❌ Docker is not installed"
  exit 1
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down --remove-orphans

# Pull latest images (for production)
if [ "$ENVIRONMENT" = "prod" ]; then
  echo "📥 Pulling latest images..."
  docker compose pull
fi

# Build and start services
echo "🔨 Building and starting services..."
if [ "$ENVIRONMENT" = "prod" ]; then
  echo "📋 Using production configuration..."
  docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
else
  docker compose up -d --build
fi

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check API health
API_URL="http://localhost:8000"
if curl -f "$API_URL/health" >/dev/null 2>&1; then
  echo "✅ API is healthy"
else
  echo "❌ API health check failed"
  echo "📋 Showing API logs:"
  docker compose logs api --tail=20
fi

# Check frontend
FRONTEND_URL="http://localhost:3000"
if curl -f "$FRONTEND_URL" >/dev/null 2>&1; then
  echo "✅ Frontend is healthy"
else
  echo "❌ Frontend health check failed"
  echo "📋 Showing frontend logs:"
  docker compose logs web --tail=20
fi

# Check database
if docker compose exec postgres pg_isready -U trader -d b3trading >/dev/null 2>&1; then
  echo "✅ Database is healthy"
else
  echo "❌ Database health check failed"
  echo "📋 Showing database logs:"
  docker compose logs postgres --tail=20
fi

echo "🎉 Deployment completed!"
echo "📊 Service URLs:"
echo "  - Frontend: http://localhost:3000"
echo "  - API: http://localhost:8000"
echo "  - API Docs: http://localhost:8000/docs"
echo "  - Grafana: http://localhost:3001"
echo "  - Database: localhost:5432"

echo "📋 To view logs: docker compose logs -f [service_name]"
echo "🛑 To stop: docker compose down"