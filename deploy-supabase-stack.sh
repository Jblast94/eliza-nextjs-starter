#!/bin/bash

# Supabase-Integrated Dev Stack Deployment Script
# This script helps deploy the complete development stack with Supabase integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    if ! command_exists tailscale; then
        print_warning "Tailscale is not installed. Please install Tailscale for networking."
    fi
    
    print_success "Prerequisites check completed"
}

# Function to setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_success "Created .env file from template"
            print_warning "Please edit .env file with your specific values before continuing"
            print_warning "Required: TS_AUTHKEY and CLOUDFLARE_TUNNEL_TOKEN"
            read -p "Press Enter after editing .env file..."
        else
            print_error ".env.example file not found"
            exit 1
        fi
    else
        print_success ".env file already exists"
    fi
    
    # Validate required environment variables
    source .env
    
    if [ -z "$TS_AUTHKEY" ] || [ "$TS_AUTHKEY" = "tskey-auth-YOUR_AUTH_KEY_HERE" ]; then
        print_error "TS_AUTHKEY not configured in .env file"
        print_status "Get your auth key from: https://login.tailscale.com/admin/settings/keys"
        exit 1
    fi
    
    if [ -z "$CLOUDFLARE_TUNNEL_TOKEN" ] || [ "$CLOUDFLARE_TUNNEL_TOKEN" = "YOUR_TUNNEL_TOKEN_HERE" ]; then
        print_error "CLOUDFLARE_TUNNEL_TOKEN not configured in .env file"
        print_status "Get your tunnel token from Cloudflare Zero Trust Dashboard"
        exit 1
    fi
    
    print_success "Environment validation completed"
}

# Function to create backup script directory
setup_backup_scripts() {
    print_status "Setting up backup scripts..."
    
    if [ ! -d "backup-scripts" ]; then
        mkdir -p backup-scripts
        print_success "Created backup-scripts directory"
    fi
    
    if [ -f "backup-scripts/backup.sh" ]; then
        chmod +x backup-scripts/backup.sh
        print_success "Made backup script executable"
    fi
}

# Function to validate Supabase connection
validate_supabase() {
    print_status "Validating Supabase connection..."
    
    # Source environment variables
    if [ -f ".env" ]; then
        source .env
    fi
    
    # Test connection using pg_isready (if available)
    if command_exists pg_isready; then
        if pg_isready -h "db.dwgsdbxkwjoyxywufbgf.supabase.co" -p 5432; then
            print_success "Supabase connection validated"
        else
            print_warning "Could not validate Supabase connection"
        fi
    else
        print_warning "pg_isready not available, skipping connection test"
    fi
}

# Function to setup Tailscale
setup_tailscale() {
    print_status "Setting up Tailscale Magic DNS..."
    
    if command_exists tailscale; then
        # Check if Tailscale is already connected
        if tailscale status >/dev/null 2>&1; then
            print_success "Tailscale is already connected"
            
            # Enable Magic DNS if not already enabled
            print_status "Ensuring Magic DNS is enabled..."
            tailscale up --accept-dns=true >/dev/null 2>&1 || true
            print_success "Magic DNS configuration updated"
        else
            print_warning "Tailscale is not connected"
            print_status "The Tailscale container will handle authentication automatically"
        fi
    else
        print_warning "Tailscale not installed on host, using containerized version"
    fi
    
    # Enable IP forwarding for container networking
    print_status "Enabling IP forwarding..."
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf >/dev/null
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf >/dev/null
    sudo sysctl -p >/dev/null 2>&1 || true
    print_success "IP forwarding enabled"
}

# Function to deploy stack
deploy_stack() {
    print_status "Deploying Docker stack..."
    
    # Pull latest images
    print_status "Pulling latest Docker images..."
    if docker-compose pull; then
        print_success "Images pulled successfully"
    else
        print_warning "Some images failed to pull, continuing anyway"
    fi
    
    # Start services
    print_status "Starting services..."
    if docker-compose up -d; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        exit 1
    fi
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Check service status
    print_status "Checking service status..."
    docker-compose ps
}

# Function to display service URLs
show_service_urls() {
    print_success "\nDeployment completed! Services are available at:"
    echo ""
    echo "🤖 Ollama (LLM API):        https://llm.bbj4u.xyz"
    echo "💬 OpenWebUI (AI Chat):     https://chat.bbj4u.xyz"
    echo "💻 VS Code Server:          https://code.bbj4u.xyz"
    echo "🔄 n8n (Automation):        https://n8n.bbj4u.xyz"
    echo "📦 MinIO (S3 API):          https://s3.bbj4u.xyz"
    echo "🎛️  MinIO Console:           https://s3-console.bbj4u.xyz"
    echo "🗄️  Adminer (Database):      https://db.bbj4u.xyz"
    echo "📊 Grafana (Monitoring):    https://monitor.bbj4u.xyz"
    echo "📈 Prometheus (Metrics):    https://metrics.bbj4u.xyz"
    echo "📓 Jupyter (Notebooks):     https://notebook.bbj4u.xyz"
    echo "🐰 RabbitMQ (Queue):        https://queue.bbj4u.xyz"
    echo "🐳 Portainer (Docker):      https://docker.bbj4u.xyz"
    echo ""
    echo "📋 Default Credentials:"
    echo "   Username: jblast"
    echo "   Password: password123"
    echo "   Email: johnnyblast94@gmail.com"
    echo ""
    print_success "🌐 Tailscale Magic DNS Setup:"
    echo "   • Services auto-register with Magic DNS"
    echo "   • Cloudflare Tunnel handles external access"
    echo "   • Internal communication via service hostnames"
    echo ""
    print_warning "📋 Important Setup Steps:"
    echo "   1. Configure Cloudflare Tunnel in Zero Trust Dashboard"
    echo "   2. Point your domain DNS to Cloudflare"
    echo "   3. Verify Tailscale auth key is valid"
    echo ""
    print_status "📖 Documentation: TAILSCALE_MAGIC_DNS_SETUP.md"
    print_status "🔧 Useful Commands:"
    echo "   • View logs: docker-compose logs -f [service-name]"
    echo "   • Stop stack: docker-compose down"
    echo "   • Update stack: docker-compose pull && docker-compose up -d"
    echo "   • Check Tailscale: docker exec tailscale tailscale status"
}

# Function to show backup information
show_backup_info() {
    echo ""
    print_success "Backup System Information:"
    echo "📅 Schedule: Daily at 2:00 AM"
    echo "🗂️  Retention: 30 days"
    echo "📍 Location: supabase_backups volume"
    echo ""
    print_status "Manual backup: docker exec supabase-backup /scripts/backup.sh"
    print_status "View backups: docker exec supabase-backup ls -la /backups/"
    print_status "Backup logs: docker logs supabase-backup"
}

# Main execution
main() {
    echo "======================================"
    echo "  Supabase Dev Stack Deployment"
    echo "======================================"
    echo ""
    
    check_prerequisites
    setup_environment
    setup_backup_scripts
    validate_supabase
    setup_tailscale
    deploy_stack
    show_service_urls
    show_backup_info
    
    echo ""
    print_success "Deployment script completed successfully!"
}

# Run main function
main "$@"