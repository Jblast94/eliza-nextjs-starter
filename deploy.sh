#!/bin/bash
set -e

echo "Setting up dev stack environment..."

# Install required packages
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
fi

# Install Docker Compose if not installed
if ! command -v docker compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create required directories
echo "Creating directories..."
mkdir -p data/{ollama,openwebui,minio,portainer,traefik}

# Prompt for email address
# Prompt for configuration details
read -p "Enter your email address for Let's Encrypt certificates: " EMAIL
read -p "Enter the base domain for your services (e.g., mydevstack.com): " BASE_DOMAIN
read -p "Enter a secure password for VS Code Server: " VSCODE_PASSWORD
read -p "Enter a secure password for Grafana admin: " GRAFANA_PASSWORD
read -p "Enter a secure password for MongoDB root: " MONGO_PASSWORD
read -p "Enter a secure password for RabbitMQ default user: " RABBITMQ_PASSWORD

# Create .env file for environment variables
cat > .env << EOF
# --- General Configuration ---
EMAIL=$EMAIL
BASE_DOMAIN=$BASE_DOMAIN

# --- Service Passwords (CHANGE THESE IMMEDIATELY AFTER DEPLOYMENT) ---
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=change_me_immediately # Change this in .env
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=change_me_immediately # Change this in .env
VSCODE_PASSWORD=$VSCODE_PASSWORD
GRAFANA_PASSWORD=$GRAFANA_PASSWORD
MONGO_PASSWORD=$MONGO_PASSWORD
RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD

# --- Domain Configuration ---
TRAEFIK_DOMAIN=traefik.\$BASE_DOMAIN
LLM_DOMAIN=llm.\$BASE_DOMAIN
CHAT_DOMAIN=chat.\$BASE_DOMAIN
N8N_DOMAIN=n8n.\$BASE_DOMAIN
S3_CONSOLE_DOMAIN=s3-console.\$BASE_DOMAIN
DB_DOMAIN=db.\$BASE_DOMAIN
DOCKER_DOMAIN=docker.\$BASE_DOMAIN
CODE_DOMAIN=code.\$BASE_DOMAIN
MONITOR_DOMAIN=monitor.\$BASE_DOMAIN
METRICS_DOMAIN=metrics.\$BASE_DOMAIN
S3_API_DOMAIN=s3.\$BASE_DOMAIN

EOF

# Set correct permissions
sudo chown -R 1000:1000 data/

echo "Starting services..."
docker compose up -d

echo "Setup complete! Please wait a few minutes for all services to initialize."
echo "
Access your services at:
- Traefik Dashboard: https://traefik.myn8n.art
- Ollama API: https://llm.myn8n.art
- OpenWebUI: https://chat.myn8n.art
- n8n: https://n8n.myn8n.art
- MinIO Console: https://s3-console.myn8n.art
- Adminer: https://db.myn8n.art
- Portainer: https://docker.myn8n.art

Important:
1. Update your DNS records to point these domains to your server's IP
2. Change default passwords in Portainer and MinIO console
3. Configure n8n credentials in the .env file
"
