# B3 Trading Platform - Makefile for Hostinger Deployment

.PHONY: help install build up down restart logs clean backup restore test status

# Default environment file
ENV_FILE ?= .env

# Docker Compose files
COMPOSE_FILE_FULL = docker-compose.hostinger.yml
COMPOSE_FILE_SIMPLE = docker-compose.simple.yml
COMPOSE_FILE_DEV = docker-compose.yml

# Default to simple deployment
COMPOSE_FILE ?= $(COMPOSE_FILE_SIMPLE)

help: ## Show this help message
	@echo "B3 Trading Platform - Deployment Commands"
	@echo "========================================="
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Environment options:"
	@echo "  COMPOSE_FILE=docker-compose.simple.yml     # Simple deployment (default)"
	@echo "  COMPOSE_FILE=docker-compose.hostinger.yml  # Full deployment with nginx"
	@echo "  COMPOSE_FILE=docker-compose.yml            # Development"

install: ## Install dependencies and prepare environment
	@echo "🔧 Preparing environment..."
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "📝 Creating environment file from template..."; \
		cp .env.hostinger $(ENV_FILE); \
		echo "⚠️  Please edit $(ENV_FILE) with your configuration!"; \
	else \
		echo "✅ Environment file already exists"; \
	fi
	@mkdir -p logs nginx/ssl monitoring/grafana/{dashboards,datasources}
	@chmod 755 logs
	@echo "✅ Installation complete!"

build: ## Build all Docker images
	@echo "🔨 Building Docker images..."
	@docker compose -f $(COMPOSE_FILE) build
	@echo "✅ Build complete!"

up: ## Start all services
	@echo "🚀 Starting B3 Trading Platform..."
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "✅ Platform started!"
	@echo "🌐 Frontend: http://localhost:3000"
	@echo "🔗 API: http://localhost:8000"
	@make status

up-full: ## Start all services with full monitoring
	@echo "🚀 Starting B3 Trading Platform with monitoring..."
	@docker compose -f $(COMPOSE_FILE_FULL) --profile monitoring up -d
	@echo "✅ Platform started with monitoring!"
	@echo "🌐 Frontend: http://localhost"
	@echo "🔗 API: http://localhost/api"
	@echo "📊 Monitoring: http://localhost/monitoring"

down: ## Stop all services
	@echo "🛑 Stopping B3 Trading Platform..."
	@docker compose -f $(COMPOSE_FILE) down
	@echo "✅ Platform stopped!"

restart: ## Restart all services
	@echo "🔄 Restarting B3 Trading Platform..."
	@docker compose -f $(COMPOSE_FILE) restart
	@echo "✅ Platform restarted!"

logs: ## Show logs from all services
	@docker compose -f $(COMPOSE_FILE) logs -f

logs-api: ## Show API logs only
	@docker compose -f $(COMPOSE_FILE) logs -f api

logs-web: ## Show frontend logs only
	@docker compose -f $(COMPOSE_FILE) logs -f web

logs-db: ## Show database logs only
	@docker compose -f $(COMPOSE_FILE) logs -f postgres

status: ## Show status of all services
	@echo "📊 Service Status:"
	@docker compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "💾 Resource Usage:"
	@docker stats --no-stream

clean: ## Remove all containers, images, and volumes (DESTRUCTIVE)
	@echo "⚠️  This will remove all containers, images, and volumes!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		echo "🧹 Cleaning up..."; \
		docker compose -f $(COMPOSE_FILE) down -v; \
		docker system prune -f; \
		docker volume prune -f; \
		echo "✅ Cleanup complete!"; \
	else \
		echo ""; \
		echo "❌ Cleanup cancelled"; \
	fi

backup: ## Backup database
	@echo "💾 Creating database backup..."
	@mkdir -p backups
	@docker compose -f $(COMPOSE_FILE) exec -T postgres pg_dump -U trader b3trading | gzip > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql.gz
	@echo "✅ Backup created in backups/ directory"

restore: ## Restore database from backup (specify BACKUP_FILE=filename)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "❌ Please specify backup file: make restore BACKUP_FILE=backup_20241201_120000.sql.gz"; \
		exit 1; \
	fi
	@echo "📥 Restoring database from $(BACKUP_FILE)..."
	@gunzip -c backups/$(BACKUP_FILE) | docker compose -f $(COMPOSE_FILE) exec -T postgres psql -U trader b3trading
	@echo "✅ Database restored!"

test: ## Run health checks
	@echo "🧪 Running health checks..."
	@echo "API Health:"
	@curl -f http://localhost:8000/health || echo "❌ API health check failed"
	@echo ""
	@echo "Frontend Health:"
	@curl -f http://localhost:3000 || echo "❌ Frontend health check failed"
	@echo ""
	@echo "✅ Health checks complete!"

update: ## Update application (git pull + rebuild + restart)
	@echo "🔄 Updating B3 Trading Platform..."
	@git pull origin main
	@make build
	@make restart
	@echo "✅ Update complete!"

setup-ssl: ## Setup SSL certificates (requires domain configuration)
	@echo "🔒 Setting up SSL certificates..."
	@echo "⚠️  Make sure your domain is pointed to this server!"
	@read -p "Enter your domain name: " domain; \
	certbot certonly --standalone -d $$domain; \
	mkdir -p nginx/ssl; \
	cp /etc/letsencrypt/live/$$domain/fullchain.pem nginx/ssl/cert.pem; \
	cp /etc/letsencrypt/live/$$domain/privkey.pem nginx/ssl/key.pem; \
	echo "SSL_ENABLED=true" >> $(ENV_FILE); \
	echo "DOMAIN_NAME=$$domain" >> $(ENV_FILE)
	@echo "✅ SSL certificates configured!"
	@echo "🔄 Please restart the services: make restart"

monitoring: ## Start monitoring services
	@echo "📊 Starting monitoring services..."
	@docker compose -f $(COMPOSE_FILE_FULL) --profile monitoring up -d grafana
	@echo "✅ Monitoring started!"
	@echo "📊 Grafana: http://localhost:3001 (or /monitoring/ if using nginx)"

dev: ## Start development environment
	@echo "🛠️  Starting development environment..."
	@docker compose -f $(COMPOSE_FILE_DEV) up -d
	@echo "✅ Development environment started!"

# Quick deployment shortcuts
deploy-simple: install build up ## Quick simple deployment
deploy-full: install build up-full ## Quick full deployment with monitoring
deploy-dev: install dev ## Quick development deployment