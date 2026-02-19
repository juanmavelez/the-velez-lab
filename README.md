# The Velez Lab

Welcome to **The Velez Lab**. This repository serves as the central gateway and infrastructure configuration for my personal projects and hosted services. It acts as the entry point for `thevelezlab.com`.

## Overview

The Velez Lab is built using [**Caddy**](https://caddyserver.com/) as a reverse proxy to handle domain routing and automatic SSL termination. It orchestrates various services via **Docker Compose**, allowing for easy deployment and management of containerized applications.

## Architecture

- **Gateway**: Caddy handles incoming traffic on ports 80 and 443.
- **Routing**: Traffic is routed to specific containers based on the path (e.g., `/cv-forge`).
- **Networking**: All services communicate over a shared external Docker network (`velez-network`).

## Services

Currently hosted services:

- **[CV Forge](/cv-forge)**: A powerful tool for building and managing CVs.
    - Path: `/cv-forge`
    - Service: `cv-forge-frontend`

## Usage

### Prerequisites

- [Docker](https://www.docker.com/) installed
- [Docker Compose](https://docs.docker.com/compose/) installed

### Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/juanmavelez/the-velez-lab.git
    cd the-velez-lab
    ```

2.  **Create the shared network**:
    The gateway and all services must be on the same external network to communicate.
    ```bash
    docker network create velez-network
    ```

3.  **Start the Gateway**:
    ```bash
    make up
    ```

    Other useful commands:
    -   `make deploy`: Rebuild and restart the gateway.
    -   `make down`: Stop the gateway.
    -   `make logs`: View gateway logs.

## Automatic Updates (Pull-Based)

This repository uses a **pull-based** deployment strategy to avoid opening SSH ports.

1.  **Make script executable**:
    ```bash
    chmod +x ~/the-velez-lab/scripts/auto-deploy.sh
    ```

2.  **Add Cron Job** (`crontab -e`):
    ```bash
    # Check for updates every 5 minutes
    */5 * * * * ~/the-velez-lab/scripts/auto-deploy.sh >> ~/deploy.log 2>&1
    ```

## Cloudflare Tunnel (Zero Trust Access)

This lab uses Cloudflare Tunnel to expose services securely without opening ports on the router.

### Setup
1.  Add your `CLOUDFLARE_TUNNEL_TOKEN` to `.env`.
2.  Start the tunnel: `make up`.

### SSH Access via Tunnel
To SSH into the server securely from your laptop:

1.  **Install `cloudflared`** on your laptop.
2.  **Configure SSH** (`~/.ssh/config`):
    ```ssh
    Host <your-domain>
      User <your-user>
      ProxyCommand cloudflared access ssh --hostname %h
    ```
3.  **Connect**:
    ```bash
    ssh <your-user>@<your-domain>
    ```

## Configuration

The routing configuration is managed in the `Caddyfile`.

```caddy
thevelezlab.com {
    handle_path /cv-forge* {
        reverse_proxy cv-forge-frontend:80
    }
}
```

Add new services by defining their route in the `Caddyfile` and ensuring they are attached to the `velez-network`.
