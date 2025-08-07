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

# Check for required environment variables
check_env() {
    print_status "Checking environment variables..."
    if [ -z "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
        echo "Error: CLOUDFLARE_TUNNEL_TOKEN is not set"
        echo "Get your tunnel token from: https://dash.cloudflare.com/ → Zero Trust → Networks → Tunnels"
        exit 1
    fi
    
    if [ -z "$RUSTDESK_KEY" ]; then
        # Generate a random key if not set
        export RUSTDESK_KEY=$(openssl rand -base64 32)
        echo "Generated new RUSTDESK_KEY: $RUSTDESK_KEY"
        echo "RUSTDESK_KEY=$RUSTDESK_KEY" >> .env
    fi
}

# Create Cloudflare DNS entries
setup_cloudflare_dns() {
    print_status "Setting up Cloudflare DNS entries..."
    cat > config/cloudflare-config.json << EOL
{
    "tunnel": "${CLOUDFLARE_TUNNEL_TOKEN}",
    "ingress": [
        {
            "hostname": "remote.bbj4u.xyz",
            "service": "http://rustdesk-hbbs:21115"
        },
        {
            "hostname": "trae.bbj4u.xyz",
            "service": "http://windows-dev:3389"
        },
        {
            "service": "http_status:404"
        }
    ]
}
EOL
    print_success "DNS configuration created"
}

# Start services
start_services() {
    print_status "Starting services..."
    docker compose -f docker-compose.remote.yml up -d
    print_success "Services started"
}

# Show connection information
show_info() {
    print_success "\nDeployment Complete!"
    echo ""
    print_status "RustDesk Server Information:"
    echo "ID Server: remote.bbj4u.xyz:21115"
    echo "Relay Server: remote.bbj4u.xyz:21117"
    echo ""
    print_status "Windows (Trae.ai IDE) Access:"
    echo "RDP Address: trae.bbj4u.xyz:3389"
    echo "Username: Administrator"
    echo "Password: ${DEFAULT_PASSWORD}"
    echo ""
    print_status "Next Steps:"
    echo "1. In RustDesk client, set custom server to: remote.bbj4u.xyz"
    echo "2. RDP to trae.bbj4u.xyz to install Trae.ai IDE"
    echo "3. Use RustDesk for subsequent connections"
    echo ""
    print_status "Security Notes:"
    echo "• All traffic is encrypted through Cloudflare Tunnel"
    echo "• RustDesk provides additional encryption layer"
    echo "• Windows RDP is only accessible through Cloudflare"
}

# Main
main() {
    print_status "Starting Remote Development Setup"
    check_env
    setup_cloudflare_dns
    start_services
    show_info
}

main
