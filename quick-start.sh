#!/bin/bash

# B3 Trading Platform - Quick Start Script for Hostinger
# This script helps you quickly deploy the platform

set -e

echo "🚀 B3 Trading Platform - Hostinger Quick Start"
echo "=============================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Run: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

echo "✅ Docker and Docker Compose are available"
echo ""

# Function to generate random password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Function to generate JWT secret
generate_jwt_secret() {
    openssl rand -base64 64 | tr -d "=+/" | cut -c1-50
}

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating environment configuration..."
    
    # Generate secure passwords
    DB_PASS=$(generate_password)
    REDIS_PASS=$(generate_password)
    JWT_SECRET=$(generate_jwt_secret)
    GRAFANA_PASS=$(generate_password)
    
    # Create .env file
    cat > .env << EOF
# B3 Trading Platform - Hostinger Production Environment
# Generated automatically by quick-start.sh

# Database Configuration
DB_PASSWORD=${DB_PASS}
POSTGRES_DB=b3trading
POSTGRES_USER=trader

# Redis Configuration
REDIS_PASSWORD=${REDIS_PASS}

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=2
NEXT_PUBLIC_API_URL=http://localhost:8000/api

# JWT Security
JWT_SECRET_KEY=${JWT_SECRET}
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=30

# B3 API Configuration (Configure with your B3 credentials)
B3_API_KEY=YOUR_B3_API_KEY_HERE
B3_ENVIRONMENT=sandbox

# MetaTrader 5 Configuration (Optional)
MT5_VNC_PASSWORD=mt5_vnc_pass_2024
MT5_LOGIN=YOUR_MT5_LOGIN
MT5_PASSWORD=YOUR_MT5_PASSWORD
MT5_SERVER=YOUR_BROKER_SERVER

# Trading Configuration
MAX_POSITION_SIZE=100000
MAX_DAILY_LOSS=5000
RISK_PERCENT=2.0
KELLY_FRACTION=0.25

# Monitoring
GRAFANA_PASSWORD=${GRAFANA_PASS}

# Environment
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO

# SSL Configuration (Set to true when SSL certificates are configured)
SSL_ENABLED=false
SSL_CERT_PATH=/etc/nginx/ssl/cert.pem
SSL_KEY_PATH=/etc/nginx/ssl/key.pem

# Domain Configuration
DOMAIN_NAME=localhost
EOF

    echo "✅ Environment file created with secure random passwords"
    echo ""
    echo "🔑 Generated passwords:"
    echo "   Database: ${DB_PASS}"
    echo "   Redis: ${REDIS_PASS}"
    echo "   Grafana: ${GRAFANA_PASS}"
    echo ""
    echo "⚠️  Please save these passwords and update the .env file with your specific configuration!"
    echo ""
else
    echo "✅ Environment file already exists"
    echo ""
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p logs nginx/ssl monitoring/grafana/{dashboards,datasources} backups
chmod 755 logs

echo "✅ Directories created"
echo ""

# Ask user for deployment type
echo "📋 Choose deployment type:"
echo "1) Simple deployment (API + Frontend + Database + Redis)"
echo "2) Full deployment with Nginx reverse proxy"
echo "3) Full deployment with monitoring (Grafana included)"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "🚀 Starting simple deployment..."
        COMPOSE_FILE="docker-compose.simple.yml"
        ;;
    2)
        echo "🚀 Starting full deployment with Nginx..."
        COMPOSE_FILE="docker-compose.hostinger.yml"
        ;;
    3)
        echo "🚀 Starting full deployment with monitoring..."
        COMPOSE_FILE="docker-compose.hostinger.yml"
        MONITORING="--profile monitoring"
        ;;
    *)
        echo "❌ Invalid choice. Using simple deployment."
        COMPOSE_FILE="docker-compose.simple.yml"
        ;;
esac

echo ""
echo "🔨 Building Docker images (this may take a few minutes)..."
docker compose -f $COMPOSE_FILE build

echo ""
echo "🚀 Starting services..."
docker compose -f $COMPOSE_FILE up -d $MONITORING

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 30

echo ""
echo "📊 Service status:"
docker compose -f $COMPOSE_FILE ps

echo ""
echo "✅ B3 Trading Platform is now running!"
echo ""

if [ "$COMPOSE_FILE" = "docker-compose.simple.yml" ]; then
    echo "🌐 Access your application:"
    echo "   Frontend: http://localhost:3000"
    echo "   API: http://localhost:8000"
    echo "   API Health: http://localhost:8000/health"
else
    echo "🌐 Access your application:"
    echo "   Frontend: http://localhost"
    echo "   API: http://localhost/api"
    echo "   Health Check: http://localhost/health"
    
    if [ ! -z "$MONITORING" ]; then
        echo "   Monitoring: http://localhost/monitoring"
        echo "   Grafana Login: admin / $(grep GRAFANA_PASSWORD .env | cut -d'=' -f2)"
    fi
fi

echo ""
echo "📚 Useful commands:"
echo "   make logs          # View all service logs"
echo "   make status        # Check service status"
echo "   make restart       # Restart all services"
echo "   make down          # Stop all services"
echo "   make backup        # Backup database"
echo "   make help          # See all available commands"
echo ""
echo "📖 For more information, see HOSTINGER_DEPLOY.md"
echo ""
echo "🎉 Happy trading!"