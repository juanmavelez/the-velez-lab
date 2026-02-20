.PHONY: all network up down deploy logs clean help

# Default target
all: up

# Help target
help:
	@echo "Available commands:"
	@echo "  make network   - Create the shared 'velez-network' if it doesn't exist"
	@echo "  make up        - Start the Gateway"
	@echo "  make down      - Stop the Gateway"
	@echo "  make deploy    - Rebuild and restart the Gateway (useful after Caddyfile changes)"
	@echo "  make logs      - View logs for the Gateway"
	@echo "  make clean     - Remove the 'velez-network' (Warning: breaks running apps)"

# Create the shared network if it doesn't exist
network:
	@docker network inspect velez-network >/dev/null 2>&1 || \
		(echo "Creating velez-network..." && docker network create velez-network)

# Start the Caddy Gateway
up: network
	@echo "Starting Gateway..."
	@docker compose up -d
	@echo "Gateway started! Apps should be managed via their own repos."

# Stop the Caddy Gateway
down:
	@echo "Stopping Gateway..."
	@docker compose down

# Rebuild and deploy Gateway
deploy: network
	@echo "Deploying Gateway..."
	@docker compose down
	@docker compose up -d --build --force-recreate
	@echo "Deployment complete!"

# View logs (follow)
logs:
	@docker compose logs -f

# Clean network (use with caution)
clean:
	@echo "Removing velez-network..."
	@docker network rm velez-network || true
