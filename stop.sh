#!/bin/bash

echo "Stopping all services..."

# All services (reverse order for proper shutdown)
ALL_SERVICES=(
    "homeassistant"
    "nextcloud"
    "jellyfin"
    "bazarr"
    "sonarr"
    "radarr"
    "prowlarr" 
    "flaresolverr"
    "deluge"
    "ytdlp"
    "thelounge"
    "stirling-pdf"
    "speedtest"
    "vaultwarden"
    "gitea"
    "whoami"
    "traefik"
    "postgresql"
)

# Function to stop services
stop_services() {
    local services=("$@")
    for service in "${services[@]}"; do
        if [ -d "$service" ] && [ -f "$service/docker-compose.yaml" ]; then
            echo "Stopping $service..."
            docker compose -f "$service/docker-compose.yaml" down
        else
            echo "Warning: $service directory or docker-compose.yaml not found"
        fi
    done
}

# Stop all services
stop_services "${ALL_SERVICES[@]}"

echo "All services stopped!"

echo "Cleaning all resources"
docker compose -f shared/docker-compose.yaml --all-resources down -v
