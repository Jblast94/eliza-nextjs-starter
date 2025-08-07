#!/bin/bash

# Update DNS Records Script
# This script gets your Tailscale IP and updates the Cloudflare DNS records CSV file

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

# Check if Tailscale is installed and running
check_tailscale() {
    if ! command -v tailscale &> /dev/null; then
        print_error "Tailscale is not installed. Please install it first."
        echo "Run: curl -fsSL https://tailscale.com/install.sh | sh"
        exit 1
    fi

    if ! tailscale status &> /dev/null; then
        print_error "Tailscale is not connected. Please run 'tailscale up' first."
        exit 1
    fi
}

# Get Tailscale IP
get_tailscale_ip() {
    local ip=$(tailscale ip -4 2>/dev/null)
    if [ -z "$ip" ]; then
        print_error "Could not get Tailscale IP address."
        exit 1
    fi
    echo "$ip"
}

# Update CSV file
update_csv_file() {
    local tailscale_ip="$1"
    local csv_file="cloudflare-dns-records.csv"
    
    if [ ! -f "$csv_file" ]; then
        print_error "CSV file $csv_file not found."
        exit 1
    fi
    
    # Create backup
    cp "$csv_file" "${csv_file}.backup"
    print_status "Created backup: ${csv_file}.backup"
    
    # Update the CSV file
    sed -i "s/\[TAILSCALE_IP\]/$tailscale_ip/g" "$csv_file"
    
    print_success "Updated $csv_file with Tailscale IP: $tailscale_ip"
}

# Display updated records
show_dns_records() {
    local csv_file="cloudflare-dns-records.csv"
    
    print_status "Updated DNS records:"
    echo ""
    echo "| Subdomain | Type | Content | Proxy |"
    echo "|-----------|------|---------|-------|"
    
    # Skip header and display records
    tail -n +2 "$csv_file" | while IFS=',' read -r type name content proxy ttl comment; do
        # Remove quotes if present
        name=$(echo "$name" | tr -d '"')
        content=$(echo "$content" | tr -d '"')
        proxy=$(echo "$proxy" | tr -d '"')
        
        echo "| $name | $type | $content | $proxy |"
    done
    echo ""
}

# Show Cloudflare import instructions
show_import_instructions() {
    print_success "Next steps:"
    echo ""
    echo "1. Go to Cloudflare Dashboard: https://dash.cloudflare.com"
    echo "2. Select your 'bbj4u.xyz' domain"
    echo "3. Navigate to DNS > Records"
    echo "4. Click 'Import and export'"
    echo "5. Choose 'Import DNS records'"
    echo "6. Upload the updated 'cloudflare-dns-records.csv' file"
    echo ""
    print_warning "Make sure to set Proxy status to 'DNS only' (not proxied) for all records"
}

# Test DNS resolution
test_dns_resolution() {
    local domains=("chat.bbj4u.xyz" "docker.bbj4u.xyz" "n8n.bbj4u.xyz" "s3.bbj4u.xyz")
    
    print_status "Testing DNS resolution (this may take a few minutes after import):"
    echo ""
    
    for domain in "${domains[@]}"; do
        if nslookup "$domain" &> /dev/null; then
            local resolved_ip=$(nslookup "$domain" | grep -A1 "Name:" | tail -1 | awk '{print $2}')
            print_success "$domain → $resolved_ip"
        else
            print_warning "$domain → Not resolved yet (DNS propagation may take time)"
        fi
    done
    echo ""
}

# Main execution
main() {
    echo "=== Tailscale DNS Records Updater ==="
    echo ""
    
    # Check prerequisites
    check_tailscale
    
    # Get Tailscale IP
    print_status "Getting Tailscale IP address..."
    TAILSCALE_IP=$(get_tailscale_ip)
    print_success "Found Tailscale IP: $TAILSCALE_IP"
    echo ""
    
    # Update CSV file
    print_status "Updating DNS records CSV file..."
    update_csv_file "$TAILSCALE_IP"
    echo ""
    
    # Show updated records
    show_dns_records
    
    # Show import instructions
    show_import_instructions
    
    # Ask if user wants to test DNS
    echo ""
    read -p "Do you want to test DNS resolution now? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_dns_resolution
    fi
    
    print_success "DNS records update completed!"
    echo ""
    print_status "Your services will be available at:"
    echo "  🤖 AI Chat:      https://chat.bbj4u.xyz"
    echo "  🐳 Docker Mgmt:  https://docker.bbj4u.xyz"
    echo "  🔄 Automation:   https://n8n.bbj4u.xyz"
    echo "  📦 Storage:      https://s3.bbj4u.xyz"
    echo "  🗄️  Database:     https://db.bbj4u.xyz"
    echo "  📊 Monitoring:   https://monitor.bbj4u.xyz"
    echo "  📈 Metrics:      https://metrics.bbj4u.xyz"
    echo "  📓 Notebooks:    https://notebook.bbj4u.xyz"
    echo ""
    print_status "Default credentials: jblast / password123"
}

# Run main function
main "$@"