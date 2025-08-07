#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Setting up Dev Stack...${NC}"

# Install system dependencies
echo -e "${GREEN}Installing system dependencies...${NC}"
apt update && apt install -y \
    curl \
    git \
    docker.io \
    docker-compose \
    nvidia-container-toolkit \
    restic \
    jq

# Install useful tools
echo -e "${GREEN}Installing development tools...${NC}"
curl -o /usr/local/bin/ctop -L https://github.com/bcicen/ctop/releases/latest/download/ctop-linux-amd64
chmod +x /usr/local/bin/ctop

curl -o /usr/local/bin/lazydocker -L https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_Linux_x86_64
chmod +x /usr/local/bin/lazydocker

# Install Tailscale
echo -e "${GREEN}Installing Tailscale...${NC}"
curl -fsSL https://tailscale.com/install.sh | sh

# Create directory structure
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p /opt/devstack/{data,config,backups}
mkdir -p /opt/devstack/config/{traefik,prometheus,grafana}

# Setup NVIDIA Container Toolkit
echo -e "${GREEN}Setting up NVIDIA Container Toolkit...${NC}"
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
apt update && apt install -y nvidia-docker2
systemctl restart docker

# Create networks
echo -e "${GREEN}Creating Docker networks...${NC}"
docker network create proxy || true
docker network create ai_network || true

# Start core services
echo -e "${GREEN}Starting core services...${NC}"
docker-compose up -d

# Start AI services
echo -e "${GREEN}Starting AI services...${NC}"
docker-compose -f docker-compose.ai.yml up -d

# Start development services
echo -e "${GREEN}Starting development services...${NC}"
docker-compose -f docker-compose.dev.yml up -d

# Start monitoring services
echo -e "${GREEN}Starting monitoring services...${NC}"
docker-compose -f docker-compose.monitor.yml up -d

# Setup automatic updates
echo -e "${GREEN}Setting up automatic updates...${NC}"
cat > /etc/cron.daily/docker-cleanup << EOF
#!/bin/bash
docker system prune -f
docker image prune -a -f --filter "until=168h"
EOF
chmod +x /etc/cron.daily/docker-cleanup

# Setup backup script
echo -e "${GREEN}Setting up backup script...${NC}"
cat > /opt/devstack/scripts/backup.sh << EOF
#!/bin/bash
export AWS_ACCESS_KEY_ID=\${MINIO_ROOT_USER}
export AWS_SECRET_ACCESS_KEY=\${MINIO_ROOT_PASSWORD}
export RESTIC_REPOSITORY="s3:http://localhost:9000/backups"
export RESTIC_PASSWORD=\${DEFAULT_PASSWORD}

# Initialize repository if needed
restic init || true

# Backup volumes
restic backup /opt/devstack/data

# Clean old backups
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
EOF
chmod +x /opt/devstack/scripts/backup.sh

# Add backup to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/devstack/scripts/backup.sh") | crontab -

echo -e "${BLUE}Setup complete! Access your services at:${NC}"
echo -e "${GREEN}Main Dashboard: ${NC}https://docker.${BASE_DOMAIN}"
echo -e "${GREEN}AI Chat: ${NC}https://chat.${BASE_DOMAIN}"
echo -e "${GREEN}Code Server: ${NC}https://code.${BASE_DOMAIN}"
echo -e "${GREEN}Monitoring: ${NC}https://monitor.${BASE_DOMAIN}"
echo -e "${GREEN}Storage: ${NC}https://s3.${BASE_DOMAIN}"
echo -e "${GREEN}Automation: ${NC}https://n8n.${BASE_DOMAIN}"
echo -e "${GREEN}Notebooks: ${NC}https://notebook.${BASE_DOMAIN}"

echo -e "\n${BLUE}Default credentials:${NC}"
echo -e "${GREEN}Username: ${NC}jblast"
echo -e "${GREEN}Password: ${NC}${DEFAULT_PASSWORD}"
