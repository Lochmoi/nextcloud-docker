#!/bin/bash
# NextCloud deployment script

set -e

# Define the path to the compose directory
COMPOSE_DIR="/home/ubuntu/nextcloud-docker/docker"

# Check if we're on the EC2 instance with the docker-compose.yml file
if [ ! -f "$COMPOSE_DIR/docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found. Run this script on the correct EC2 instance."
    exit 1
fi

# Move to the compose directory
cd "$COMPOSE_DIR"

# Check for .env file
if [ ! -f .env ]; then
    echo "Error: .env file is missing. Please create it before running this script."
    exit 1
fi

# Create data directories
mkdir -p data/{nextcloud,mysql,redis}

# Start containers
echo "Starting NextCloud containers..."
docker compose up -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 30

# Check container status
docker-compose ps

# Show logs
echo "Container logs:"
docker compose logs --tail=20

# Display access info
echo "NextCloud deployment completed!"
echo "Access your NextCloud at: http://$(curl -s ifconfig.me)"
