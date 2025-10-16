#!/bin/bash

# Test deployment configuration
echo "🧪 Testing B3 Trading Platform deployment configuration..."

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

echo "✅ Project structure validation:"

# Check required files
required_files=(
    "docker-compose.yml"
    "docker-compose.prod.yml"
    ".env"
    ".env.staging"
    ".env.prod"
    "deploy.sh"
    "Makefile"
    "README.md"
    "frontend/Dockerfile"
    "backend/Dockerfile"
    "backend/requirements.txt"
    "frontend/package.json"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
    fi
done

echo ""
echo "✅ Environment configuration validation:"

# Check environment files have required variables
required_vars=(
    "DB_PASSWORD"
    "REDIS_PASSWORD"
    "JWT_SECRET_KEY"
    "NEXT_PUBLIC_API_URL"
    "GRAFANA_PASSWORD"
)

for env_file in ".env" ".env.staging" ".env.prod"; do
    echo "  📋 $env_file:"
    for var in "${required_vars[@]}"; do
        if grep -q "^$var=" "$env_file" 2>/dev/null; then
            echo "    ✅ $var"
        else
            echo "    ❌ $var (missing)"
        fi
    done
done

echo ""
echo "✅ Docker configuration validation:"

# Validate docker-compose files
if docker compose config >/dev/null 2>&1; then
    echo "  ✅ docker-compose.yml syntax is valid"
else
    echo "  ❌ docker-compose.yml syntax error"
fi

if docker compose -f docker-compose.yml -f docker-compose.prod.yml config >/dev/null 2>&1; then
    echo "  ✅ production configuration is valid"
else
    echo "  ❌ production configuration error"
fi

echo ""
echo "✅ Security check:"

# Check for default passwords in .env
if grep -q "CHANGE_ME" .env 2>/dev/null; then
    echo "  ⚠️  Default passwords found in .env - update for production!"
else
    echo "  ✅ No default passwords in .env"
fi

echo ""
echo "✅ Frontend build test:"

# Test frontend build
cd frontend
if npm list >/dev/null 2>&1; then
    echo "  ✅ Frontend dependencies are installed"
    if npm run build >/dev/null 2>&1; then
        echo "  ✅ Frontend builds successfully"
    else
        echo "  ❌ Frontend build failed"
    fi
else
    echo "  ⚠️  Frontend dependencies not installed (run: cd frontend && npm install)"
fi

cd ..

echo ""
echo "🎉 Deployment configuration test completed!"
echo ""
echo "📋 Quick commands:"
echo "  ./deploy.sh dev     - Deploy development"
echo "  ./deploy.sh staging - Deploy staging"
echo "  ./deploy.sh prod    - Deploy production"
echo "  make help           - Show all available commands"