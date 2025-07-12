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
            read -p "Press Enter after editing .env file..."
        else
            print_error ".env.example file not found"
            exit 1
        fi
    else
        print_success ".env file already exists"
    fi
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
    print_status "Setting up Tailscale..."
    
    if command_exists tailscale; then
        # Check if Tailscale is already connected
        if tailscale status >/dev/null 2>&1; then
            print_success "Tailscale is already connected"
            
            # Advertise subnet routes
            print_status "Advertising subnet routes..."
            if tailscale up --advertise-routes=100.64.0.0/24; then
                print_success "Subnet routes advertised successfully"
            else
                print_warning "Failed to advertise subnet routes"
            fi
        else
            print_warning "Tailscale is not connected. Please run 'tailscale up' first"
        fi
    else
        print_warning "Tailscale not installed, skipping network setup"
    fi
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
    echo "🤖 OpenWebUI (AI Chat):     https://chat.bbj4u.xyz"
    echo "🔄 n8n (Automation):        https://n8n.bbj4u.xyz"
    echo "📦 MinIO (Storage):         https://s3.bbj4u.xyz"
    echo "🗄️  Adminer (Database):      https://db.bbj4u.xyz"
    echo "📊 Grafana (Monitoring):    https://monitor.bbj4u.xyz"
    echo "📈 Prometheus (Metrics):    https://metrics.bbj4u.xyz"
    echo "📓 Jupyter (Notebooks):     https://notebook.bbj4u.xyz"
    echo ""
    print_warning "Note: Make sure to configure your DNS records using cloudflare-dns-records.csv"
    echo ""
    print_status "To view logs: docker-compose logs -f [service-name]"
    print_status "To stop stack: docker-compose down"
    print_status "To update stack: docker-compose pull && docker-compose up -d"
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