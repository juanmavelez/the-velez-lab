.PHONY: all network gateway cv-forge up down deploy status logs clean help

# Default target
all: up

# Help target
help:
	@echo "Available commands:"
	@echo "  make network   - Create the shared 'velez-network' if it doesn't exist"
	@echo "  make gateway   - Start the Caddy Gateway"
	@echo "  make cv-forge  - Start the CV Forge application"
	@echo "  make up        - Start all services (Gateway + CV Forge)"
	@echo "  make down      - Stop all services"
	@echo "  make deploy    - Rebuild and restart all services"
	@echo "  make status    - Show status of all running containers"
	@echo "  make logs      - View logs for the Gateway"

# Create the shared network if it doesn't exist
network:
	@docker network inspect velez-network >/dev/null 2>&1 || \
		(echo "Creating velez-network..." && docker network create velez-network)

# Start the Caddy Gateway
gateway: network
	@echo "Starting Gateway..."
	@docker-compose up -d

# Start CV Forge (assumes sibling directory)
cv-forge: network
	@echo "Starting CV Forge..."
	@docker-compose -f ../cv-forge/docker-compose.yml up -d

# Start everything
up: gateway cv-forge
	@echo "All services started!"

# Stop everything
down:
	@echo "Stopping CV Forge..."
	@docker-compose -f ../cv-forge/docker-compose.yml down
	@echo "Stopping Gateway..."
	@docker-compose down

# Rebuild and deploy everything
deploy: network
	@echo "Deploying Gateway..."
	@docker-compose up -d --build
	@echo "Deploying CV Forge..."
	@docker-compose -f ../cv-forge/docker-compose.yml up -d --build
	@echo "Deployment complete!"

# Check status of containers
status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View logs (follow)
logs:
	@docker-compose logs -f

# Clean network (use with caution)
clean:
	@echo "Removing velez-network..."
	@docker network rm velez-network || true
