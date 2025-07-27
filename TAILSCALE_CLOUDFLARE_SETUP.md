# Tailscale & Cloudflare DNS Configuration Guide

Since Tailscale is already configured and running on your system, this guide will help you get your Tailscale IP and configure Cloudflare DNS records for your Dev Stack services.

## Step 1: Get Your Tailscale IP Address

```bash
# Get your Tailscale IPv4 address
tailscale ip -4

# Alternative: Check Tailscale status for detailed info
tailscale status
```

**Example output:**
```
100.64.0.10
```

## Step 2: Update DNS Records Template

Your Dev Stack is configured with the following service IP assignments:

| Service | Container IP | Subdomain | Purpose |
|---------|-------------|-----------|----------|
| Ollama | 100.64.0.101 | - | LLM API Server |
| OpenWebUI | 100.64.0.102 | chat.bbj4u.xyz | AI Chat Interface |
| n8n | 100.64.0.103 | n8n.bbj4u.xyz | Workflow Automation |
| MinIO | 100.64.0.104 | s3.bbj4u.xyz | Object Storage |
| Jupyter | 100.64.0.105 | notebook.bbj4u.xyz | Data Science Notebooks |
| Portainer | 100.64.0.106 | docker.bbj4u.xyz | Docker Management |
| Adminer | - | db.bbj4u.xyz | Database Management |
| Grafana | - | monitor.bbj4u.xyz | Monitoring Dashboard |
| Prometheus | - | metrics.bbj4u.xyz | Metrics Collection |

## Step 3: Configure Cloudflare DNS Records

### Option A: Manual Configuration

1. **Login to Cloudflare Dashboard**
   - Go to https://dash.cloudflare.com
   - Select your `bbj4u.xyz` domain

2. **Add DNS Records**
   Navigate to DNS > Records and add the following A records:

   ```
   Type: A | Name: chat     | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   Type: A | Name: n8n      | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   Type: A | Name: s3       | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   Type: A | Name: notebook | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   Type: A | Name: docker   | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   Type: A | Name: db       | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   Type: A | Name: monitor  | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   Type: A | Name: metrics  | Content: [YOUR_TAILSCALE_IP] | Proxy: Off
   ```

### Option B: CSV Import Method

1. **Update the CSV file:**
   ```bash
   # Get your Tailscale IP
   TAILSCALE_IP=$(tailscale ip -4)
   
   # Update the CSV file with your actual IP
   sed -i "s/\[TAILSCALE_IP\]/$TAILSCALE_IP/g" cloudflare-dns-records.csv
   ```

2. **Import to Cloudflare:**
   - Go to Cloudflare Dashboard > DNS > Records
   - Click "Import and export"
   - Choose "Import DNS records"
   - Upload the updated `cloudflare-dns-records.csv` file

## Step 4: Verify Configuration

### Check Tailscale Network
```bash
# Verify Tailscale is advertising the subnet
tailscale status

# Check if subnet routes are advertised
tailscale netcheck
```

### Test DNS Resolution
```bash
# Test DNS resolution for your services
nslookup chat.bbj4u.xyz
nslookup docker.bbj4u.xyz
nslookup n8n.bbj4u.xyz
```

### Test Service Connectivity
```bash
# Test if services are accessible via Tailscale
curl -k https://chat.bbj4u.xyz
curl -k https://docker.bbj4u.xyz
```

## Step 5: Deploy Your Stack

Once DNS is configured, deploy your services:

```bash
# Deploy the entire stack
./deploy.sh

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

## Service URLs

After deployment, access your services at:

- **🤖 OpenWebUI (AI Chat)**: https://chat.bbj4u.xyz
- **🔄 n8n (Automation)**: https://n8n.bbj4u.xyz
- **📦 MinIO (Storage)**: https://s3.bbj4u.xyz
- **🗄️ Adminer (Database)**: https://db.bbj4u.xyz
- **📊 Grafana (Monitoring)**: https://monitor.bbj4u.xyz
- **📈 Prometheus (Metrics)**: https://metrics.bbj4u.xyz
- **📓 Jupyter (Notebooks)**: https://notebook.bbj4u.xyz
- **🐳 Portainer (Docker)**: https://docker.bbj4u.xyz

## Default Credentials

All services use these simplified credentials:
- **Username**: jblast
- **Password**: password123
- **Email**: johnnyblast94@gmail.com

## Troubleshooting

### DNS Not Resolving
```bash
# Check DNS propagation
dig chat.bbj4u.xyz

# Flush local DNS cache
sudo systemctl flush-dns  # Ubuntu/Debian
```

### Services Not Accessible
```bash
# Check Tailscale connectivity
tailscale ping [TAILSCALE_IP]

# Check Docker network
docker network ls
docker network inspect dev-stack-clean_tailscale
```

### SSL Certificate Issues
```bash
# Check Let's Encrypt logs
docker-compose logs nginx-proxy
docker-compose logs letsencrypt-companion
```

## Advanced Configuration

### Custom Tailscale ACLs
If you need to restrict access, configure Tailscale ACLs in your admin console:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["your-user@domain.com"],
      "dst": ["100.64.0.0/24:*"]
    }
  ]
}
```

### Subnet Route Advertisement
Ensure your Tailscale node advertises the Docker subnet:

```bash
# Advertise subnet routes
sudo tailscale up --advertise-routes=100.64.0.0/24

# Accept routes in Tailscale admin console
# Go to https://login.tailscale.com/admin/machines
# Enable subnet routes for your machine
```

## Security Notes

- All traffic is encrypted via Tailscale
- Services are only accessible through your Tailscale network
- SSL certificates are automatically managed by Let's Encrypt
- Consider enabling Tailscale MagicDNS for easier access

Your Dev Stack is now ready for secure remote access via Tailscale!