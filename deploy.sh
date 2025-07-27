#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Setting up Dev Stack with Tailscale Magic DNS..."

# Install required packages
print_status "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_success "Docker installed successfully"
else
    print_success "Docker is already installed"
fi

# Install Docker Compose if not installed
if ! command -v docker compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed successfully"
else
    print_success "Docker Compose is already installed"
fi

# Validate configuration
print_status "Validating configuration..."

if [ ! -f ".env" ]; then
    print_error ".env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

# Source environment variables
source .env

# Check required environment variables
if [ -z "$TS_AUTHKEY" ] || [ "$TS_AUTHKEY" = "tskey-auth-YOUR_AUTH_KEY_HERE" ]; then
    print_error "Tailscale auth key not configured. Please set TS_AUTHKEY in .env file."
    print_warning "Get your auth key from: https://login.tailscale.com/admin/settings/keys"
    exit 1
fi

if [ -z "$CLOUDFLARE_TUNNEL_TOKEN" ] || [ "$CLOUDFLARE_TUNNEL_TOKEN" = "YOUR_TUNNEL_TOKEN_HERE" ]; then
    print_error "Cloudflare tunnel token not configured. Please set CLOUDFLARE_TUNNEL_TOKEN in .env file."
    print_warning "Get your tunnel token from: https://one.dash.cloudflare.com/"
    exit 1
fi

print_success "Configuration validated successfully"

# Create required directories
print_status "Creating directories..."
mkdir -p data/{ollama,openwebui,minio,portainer,code}

# Enable IP forwarding for Tailscale
print_status "Configuring system for Tailscale..."
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf > /dev/null
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p > /dev/null
print_success "IP forwarding enabled"

# Set correct permissions
print_status "Setting permissions..."
sudo chown -R 1000:1000 data/
print_success "Permissions set successfully"

# Pull latest images
print_status "Pulling latest Docker images..."
docker compose pull
print_success "Images pulled successfully"

# Start services
print_status "Starting services..."
docker compose up -d

# Wait for services to initialize
print_status "Waiting for services to initialize..."
sleep 30

# Check service status
print_status "Checking service status..."
docker compose ps

print_success "\n🎉 Dev Stack deployed successfully with Tailscale Magic DNS!"
echo ""
print_status "📋 Service URLs (accessible via Cloudflare tunnels):"
echo ""
echo "🤖 OpenWebUI (AI Chat):     https://chat.bbj4u.xyz"
echo "💻 VS Code Server:          https://code.bbj4u.xyz"
echo "🔄 n8n (Automation):        https://n8n.bbj4u.xyz"
echo "📦 MinIO API:               https://s3.bbj4u.xyz"
echo "🎛️  MinIO Console:           https://s3-console.bbj4u.xyz"
echo "🗄️  Adminer (Database):      https://db.bbj4u.xyz"
echo "📊 Grafana (Monitoring):    https://monitor.bbj4u.xyz"
echo "📈 Prometheus (Metrics):    https://metrics.bbj4u.xyz"
echo "📓 Jupyter (Notebooks):     https://notebook.bbj4u.xyz"
echo "🐳 Portainer (Docker):      https://docker.bbj4u.xyz"
echo "🐰 RabbitMQ (Queue):        https://queue.bbj4u.xyz"
echo "🧠 Ollama (LLM API):        https://llm.bbj4u.xyz"
echo ""
print_status "🔐 Default Credentials (all services):"
echo "   Username: jblast"
echo "   Password: password123"
echo "   Email: johnnyblast94@gmail.com"
echo ""
print_warning "⚠️  Important Setup Steps:"
echo "1. Configure Cloudflare tunnel routes in your dashboard"
echo "2. Ensure DNS records point to your Cloudflare tunnel"
echo "3. Services auto-register via Tailscale Magic DNS"
echo ""
print_status "📚 For detailed setup instructions, see:"
echo "   - TAILSCALE_MAGIC_DNS_SETUP.md"
echo "   - REMOTE_VM_SETUP.md"
echo ""
print_status "🔧 Useful commands:"
echo "   - View logs: docker compose logs -f [service-name]"
echo "   - Stop stack: docker compose down"
echo "   - Update stack: docker compose pull && docker compose up -d"
echo "   - Check Tailscale: docker exec tailscale tailscale status"
echo "   - Check tunnel: docker logs cloudflared"
echo ""
