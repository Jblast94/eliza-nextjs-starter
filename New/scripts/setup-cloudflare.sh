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

# Check for cloudflared CLI
check_cloudflared() {
    if ! command -v cloudflared &> /dev/null; then
        print_status "Installing cloudflared..."
        curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
        sudo dpkg -i cloudflared.deb
        rm cloudflared.deb
    fi
}

# Create Cloudflare Tunnel
create_tunnel() {
    print_status "Creating Cloudflare Tunnel..."
    
    if [ -z "$CLOUDFLARE_TUNNEL_NAME" ]; then
        CLOUDFLARE_TUNNEL_NAME="dev-stack-tunnel"
    fi

    # Create the tunnel if it doesn't exist
    TUNNEL_ID=$(cloudflared tunnel list -o json | jq -r ".[] | select(.name==\"$CLOUDFLARE_TUNNEL_NAME\") | .id")
    
    if [ -z "$TUNNEL_ID" ]; then
        print_status "Creating new tunnel: $CLOUDFLARE_TUNNEL_NAME"
        TUNNEL_OUTPUT=$(cloudflared tunnel create "$CLOUDFLARE_TUNNEL_NAME")
        TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | awk '{print $3}')
        
        # Add to .env file
        echo "CLOUDFLARE_TUNNEL_ID=$TUNNEL_ID" >> .env
        print_success "Tunnel created with ID: $TUNNEL_ID"
    else
        print_success "Using existing tunnel: $CLOUDFLARE_TUNNEL_NAME (ID: $TUNNEL_ID)"
    fi
}

# Configure DNS Records
setup_dns() {
    print_status "Setting up DNS records..."
    
    # Create CNAME records for services
    cloudflared tunnel route dns "$CLOUDFLARE_TUNNEL_NAME" "remote.bbj4u.xyz"
    cloudflared tunnel route dns "$CLOUDFLARE_TUNNEL_NAME" "trae.bbj4u.xyz"
    
    print_success "DNS records configured"
}

# Configure Zero Trust Access
setup_access_policies() {
    print_status "Configuring Zero Trust policies..."
    
    # Create access policies using the Cloudflare API
    curl -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/access/apps" \
         -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
         -H "Content-Type: application/json" \
         --data "@config/cloudflare/applications.json"
    
    print_success "Access policies configured"
}

# Show next steps
show_next_steps() {
    print_success "\nCloudflare Setup Complete!"
    echo ""
    print_status "Next Steps:"
    echo "1. Visit Cloudflare Zero Trust Dashboard:"
    echo "   https://dash.cloudflare.com/access"
    echo ""
    echo "2. Configure Authentication Methods:"
    echo "   • Settings → Authentication"
    echo "   • Add your preferred providers (GitHub, Google, etc.)"
    echo ""
    echo "3. Verify DNS Records:"
    echo "   • remote.bbj4u.xyz → Cloudflare Tunnel"
    echo "   • trae.bbj4u.xyz → Cloudflare Tunnel"
    echo ""
    echo "4. Test Access:"
    echo "   • Try accessing remote.bbj4u.xyz"
    echo "   • Verify authentication works"
    echo "   • Check RustDesk connectivity"
    echo ""
    print_status "Security Recommendations:"
    echo "• Enable 2FA for all users"
    echo "• Set up device posture checks"
    echo "• Configure IP allow lists if needed"
    echo "• Enable Cloudflare logging and analytics"
}

# Main
main() {
    print_status "Starting Cloudflare Setup"
    check_cloudflared
    create_tunnel
    setup_dns
    setup_access_policies
    show_next_steps
}

main
