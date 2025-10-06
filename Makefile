# B3 Trading Platform - Makefile
# Common deployment and management tasks

.PHONY: help dev staging prod build stop logs clean backup restore test

# Default environment
ENV ?= dev

help: ## Show this help message
	@echo "B3 Trading Platform - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Environment Options:"
	@echo "  ENV=dev      - Development (default)"
	@echo "  ENV=staging  - Staging environment" 
	@echo "  ENV=prod     - Production environment"
	@echo ""
	@echo "Examples:"
	@echo "  make dev           # Deploy development"
	@echo "  make prod          # Deploy production"
	@echo "  make logs ENV=prod # View production logs"

dev: ## Deploy development environment
	./deploy.sh dev

staging: ## Deploy staging environment
	./deploy.sh staging

prod: ## Deploy production environment
	./deploy.sh prod

build: ## Build all Docker images
	docker compose build

up: ## Start services
	@if [ "$(ENV)" = "prod" ]; then \
		docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d; \
	else \
		docker compose up -d; \
	fi

stop: ## Stop all services
	docker compose down

restart: ## Restart all services
	docker compose restart

logs: ## View logs (use ENV= to specify environment)
	docker compose logs -f

status: ## Show service status
	docker compose ps

shell-api: ## Access API container shell
	docker compose exec api bash

shell-db: ## Access database shell
	docker compose exec postgres psql -U trader -d b3trading

clean: ## Clean up Docker resources
	docker compose down -v --remove-orphans
	docker system prune -f

backup: ## Backup database
	@mkdir -p backups
	docker compose exec postgres pg_dump -U trader b3trading > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup created in backups/ directory"

restore: ## Restore database (specify BACKUP_FILE=path/to/backup.sql)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Error: Please specify BACKUP_FILE=path/to/backup.sql"; \
		exit 1; \
	fi
	docker compose exec -T postgres psql -U trader b3trading < $(BACKUP_FILE)

test: ## Run tests
	@echo "Running frontend tests..."
	cd frontend && npm run lint
	@echo "Running backend tests..."
	# Add backend tests here when available

health: ## Check service health
	@echo "Checking API health..."
	@curl -f http://localhost:8000/health || echo "API not responding"
	@echo ""
	@echo "Checking frontend..."
	@curl -f http://localhost:3000 > /dev/null || echo "Frontend not responding"
	@echo ""
	@echo "Checking database..."
	@docker compose exec postgres pg_isready -U trader -d b3trading || echo "Database not ready"

monitor: ## Open monitoring dashboard
	@echo "Opening Grafana dashboard..."
	@echo "URL: http://localhost:3001"
	@echo "Username: admin"
	@echo "Password: Check GRAFANA_PASSWORD in .env file"

install: ## Install dependencies and setup
	@echo "Installing dependencies..."
	cd frontend && npm install
	@echo "Setting up environment..."
	@if [ ! -f .env ]; then \
		cp .env.example .env 2>/dev/null || echo "No .env.example found"; \
	fi
	@echo "Setup complete! Run 'make dev' to start."