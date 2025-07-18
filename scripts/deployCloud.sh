#!/bin/bash
# NextCloud deployment script

set -e

# Check if we're on the EC2 instance
if [ ! -f /home/ubuntu/nextcloud-docker/docker-compose.yml ]; then
    echo "Error: Run this script on the EC2 instance"
    exit 1
fi

cd /home/ubuntu/nextcloud-docker

# Copy environment file l 
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Please edit .env file with your secure passwords"
    nano .env
fi

# Create data directories
mkdir -p data/{nextcloud,mysql,redis}

# Start containers
echo "Starting NextCloud containers..."
docker-compose up -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 30

# Check container status
docker-compose ps

# Show logs
echo "Container logs:"
docker-compose logs --tail=20

echo "NextCloud deployment completed!"
echo "Access your NextCloud at: http://$(curl -s ifconfig.me)"