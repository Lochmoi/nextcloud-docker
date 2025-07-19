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

# Create monitoring configuration files
echo "Setting up monitoring configuration..."
mkdir -p monitoring
cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'nextcloud'
    static_configs:
      - targets: ['nextcloud-app:80']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-proxy:80']
EOF

# Create Grafana provisioning directories and files
mkdir -p grafana/provisioning/{datasources,dashboards}

cat > grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

cat > grafana/provisioning/dashboards/dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# Grafana password in .env file
if ! grep -q "GRAFANA_ADMIN_PASSWORD" .env; then
    echo "GRAFANA_ADMIN_PASSWORD=Micah123!" >> .env
    echo "Added GRAFANA_ADMIN_PASSWORD to .env file"
fi

# Start containers
echo "Starting NextCloud containers..."
docker compose up -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 30

# Check container status
docker compose ps

# Show logs
echo "Container logs:"
docker compose logs --tail=20

# Improved IP detection with multiple fallbacks
echo "Detecting server IP address..."
PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me || curl -s --connect-timeout 5 ipinfo.io/ip || curl -s --connect-timeout 5 icanhazip.com || echo "YOUR_SERVER_IP")

# Get local IP as backup
LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")


# Check if HTTPS is likely configured (basic check)
PROTOCOL="http"
if grep -q "443:" docker-compose.yml 2>/dev/null || grep -q "ssl\|tls\|https" docker-compose.yml 2>/dev/null; then
    PROTOCOL="https"
fi


# Display access info
echo "NextCloud deployment completed!"
echo "Access your NextCloud at: http://$(curl -s ifconfig.me)"
echo "Access Grafana at: http://$(curl -s ifconfig.me):3000 (admin/admin123)"
echo "Access Prometheus at: http://$(curl -s ifconfig.me):9090"
echo "Access Grafana at: http://$(curl -s ifconfig.me):3000 (admin/admin123)"
echo "Access Prometheus at: http://$(curl -s ifconfig.me):9090"
