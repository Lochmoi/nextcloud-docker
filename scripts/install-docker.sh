#!/bin/bash
# Docker installation script for Ubuntu

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose v2 (plugin method)
apt-get install -y docker-compose-plugin

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Docker Compose
#curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose

# Enable Docker service
systemctl enable docker
systemctl start docker

# Create project directory
mkdir -p /home/ubuntu/nextcloud-docker
chown ubuntu:ubuntu /home/ubuntu/nextcloud-docker

echo "Docker installation completed!"
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"
