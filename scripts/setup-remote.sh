#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${YELLOW}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check prerequisites
print_status "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Create required directories
print_status "Creating directories..."
mkdir -p data/rustdesk
mkdir -p data/windows

# Configure RustDesk server
print_status "Configuring RustDesk server..."
cat > data/rustdesk/config.toml << EOL
[server]
id = "self-hosted-rustdesk"
relay-server = "remote.${BASE_DOMAIN}"
key = "${RUSTDESK_KEY}"
EOL

# Start services
print_status "Starting services..."
docker compose -f docker-compose.remote.yml up -d

# Wait for services to start
print_status "Waiting for services to initialize..."
sleep 10

# Show connection information
print_status "\nRustDesk Server Information:"
echo "ID Server: remote.${BASE_DOMAIN}:21115"
echo "Relay Server: remote.${BASE_DOMAIN}:21117"
echo ""
print_status "Windows Instance (Trae.ai IDE) Information:"
echo "RDP Address: trae.${BASE_DOMAIN}"
echo "Username: Administrator"
echo "Password: ${DEFAULT_PASSWORD}"
echo ""
print_status "Configuration Instructions:"
echo "1. In RustDesk client, set custom server to: remote.${BASE_DOMAIN}"
echo "2. Access Windows instance via RDP or RustDesk"
echo "3. Install Trae.ai IDE on Windows instance"
echo "4. Use Tailscale for secure access: 100.64.0.120"
