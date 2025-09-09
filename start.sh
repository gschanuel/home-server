#!/bin/bash
echo "Creating shared resources (networks, volumes, secrets)..."
docker compose -f shared/docker-compose.yaml --all-resources create

echo "Starting services in order..."

# Core infrastructure services
CORE_SERVICES=(
    "traefik"
	"postgresql"
)

# Application services
APP_SERVICES=(
    "whoami"
    "gitea"
    "vaultwarden"
    "speedtest"
    "stirling-pdf"
    "thelounge" 
    "ytdlp"
)

# Media server services
MEDIA_SERVICES=(
    "deluge"
    "flaresolverr"
    "prowlarr"
    "radarr"
    "sonarr"
    "bazarr"
    "jellyfin"
)

# Other services
OTHER_SERVICES=(
    "nextcloud"
    "homeassistant"
)

# Function to start services
start_services() {
    local services=("$@")
    for service in "${services[@]}"; do
        if [ -d "$service" ] && [ -f "$service/docker-compose.yaml" ]; then
            echo "Starting $service..."
            docker compose -f "$service/docker-compose.yaml" up -d
        else
            echo "Warning: $service directory or docker-compose.yaml not found"
        fi
    done
}

# Start services in groups
echo "Starting core services..."
start_services "${CORE_SERVICES[@]}"

echo "Starting application services..."  
start_services "${APP_SERVICES[@]}"

echo "Starting media services..."
start_services "${MEDIA_SERVICES[@]}"

echo "Starting other services..."
start_services "${OTHER_SERVICES[@]}"

echo "All services started!"
