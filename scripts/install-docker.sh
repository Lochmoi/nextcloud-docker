#!/bin/bash
# Docker installation script for Ubuntu

# Update system
sudo apt-get update
 sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose v2 (plugin method)
sudo apt-get install -y docker-compose-plugin

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Create project directory
mkdir -p /home/ubuntu/nextcloud-docker
chown ubuntu:ubuntu /home/ubuntu/nextcloud-docker

echo "Docker installation completed!"
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"
