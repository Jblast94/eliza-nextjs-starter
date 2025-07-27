# Tailscale Magic DNS + Cloudflare Setup Guide

This guide explains how to set up the Dev Stack using Tailscale Magic DNS with Cloudflare tunnels for automatic service discovery and secure access.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your Device   │────│  Cloudflare CDN  │────│   Remote VM     │
│                 │    │   (Reverse Proxy) │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                │                        │
                         ┌──────▼──────┐        ┌───────▼────────┐
                         │  Cloudflare │        │   Tailscale    │
                         │   Tunnel    │        │  Magic DNS     │
                         └─────────────┘        └────────────────┘
```

This setup uses:
- **Tailscale Magic DNS**: Automatic service discovery and internal networking with health checks
- **Cloudflare Tunnels**: Secure external access without port forwarding
- **Docker Compose**: Container orchestration with service dependencies
- **Traefik Labels**: Ready for future load balancing (currently using Cloudflare)

Services communicate internally via Tailscale Magic DNS hostnames (e.g., `ollama`, `chat`, `n8n`) while external access goes through Cloudflare tunnels. The Tailscale container runs with proper health checks and DNS acceptance as per official documentation.

**Benefits:**
- ✅ Automatic service discovery via Tailscale Magic DNS
- ✅ Secure access through Cloudflare tunnels
- ✅ No manual IP configuration required
- ✅ Services auto-register as they start
- ✅ SSL/TLS termination at Cloudflare
- ✅ DDoS protection and CDN benefits

## 🚀 Quick Setup

### Step 1: Configure Tailscale

1. **Install Tailscale** on your VM:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   ```

2. **Get an Auth Key**:
   - Go to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
   - Create a new auth key with these settings:
     - ✅ Reusable
     - ✅ Ephemeral (optional)
     - ✅ Tags: `tag:devstack`

3. **Update your `.env` file**:
   ```bash
   TS_AUTHKEY=tskey-auth-YOUR_ACTUAL_AUTH_KEY_HERE
   ```

### Step 2: Configure Cloudflare Tunnel

1. **Create a Cloudflare Tunnel**:
   - Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
   - Navigate to **Access > Tunnels**
   - Click **Create a tunnel**
   - Name it `devstack-tunnel`
   - Copy the tunnel token

2. **Update your `.env` file**:
   ```bash
   CLOUDFLARE_TUNNEL_TOKEN=YOUR_ACTUAL_TUNNEL_TOKEN_HERE
   ```

3. **Configure Tunnel Routes** in Cloudflare Dashboard:
   ```
   Subdomain: chat      → Service: http://chat:8080
   Subdomain: code      → Service: http://code:8080
   Subdomain: n8n       → Service: http://n8n:5678
   Subdomain: s3        → Service: http://s3:9000
   Subdomain: s3-console → Service: http://s3:9001
   Subdomain: db        → Service: http://db:8080
   Subdomain: monitor   → Service: http://monitor:3000
   Subdomain: metrics   → Service: http://metrics:9090
   Subdomain: notebook  → Service: http://notebook:8888
   Subdomain: docker    → Service: https://docker:9443
   Subdomain: queue     → Service: http://rabbitmq:15672
   Subdomain: llm       → Service: http://ollama:11434
   ```

### Step 3: Deploy the Stack

```bash
# Make sure your .env file is configured
./deploy.sh
```

## 🔧 Technical Details

### Tailscale Configuration

The Tailscale container is configured with:
- `TS_AUTHKEY`: Your Tailscale auth key
- `TS_STATE_DIR`: Persistent state directory
- `TS_USERSPACE=false`: Use kernel networking for better performance
- `TS_ACCEPT_DNS=true`: Accept DNS configuration from admin console
- `TS_HOSTNAME=devstack`: Set hostname for the node
- `TS_EXTRA_ARGS`: Additional arguments for tagging
- `TS_ENABLE_HEALTH_CHECK=true`: Enable health check endpoint
- `TS_LOCAL_ADDR_PORT=:9002`: Health check and metrics port
- `network_mode: host`: Required for proper Tailscale networking
- Health check on `/healthz` endpoint for monitoring

## 🌐 Service URLs

Once deployed, services will be available at:

- **🤖 Ollama (LLM API)**: `https://llm.bbj4u.xyz`
- **💬 OpenWebUI (AI Chat)**: `https://chat.bbj4u.xyz`
- **💻 VS Code Server**: `https://code.bbj4u.xyz`
- **🔄 n8n (Automation)**: `https://n8n.bbj4u.xyz`
- **📦 MinIO (S3 API)**: `https://s3.bbj4u.xyz`
- **🎛️ MinIO Console**: `https://s3-console.bbj4u.xyz`
- **🗄️ Adminer (Database)**: `https://db.bbj4u.xyz`
- **📊 Grafana (Monitoring)**: `https://monitor.bbj4u.xyz`
- **📈 Prometheus (Metrics)**: `https://metrics.bbj4u.xyz`
- **📓 Jupyter Notebook**: `https://notebook.bbj4u.xyz`
- **🐰 RabbitMQ (Queue)**: `https://queue.bbj4u.xyz`
- **🐳 Portainer (Docker)**: `https://docker.bbj4u.xyz`

## 🔐 Default Credentials

**All services use the same credentials for simplicity:**
- **Username:** `jblast`
- **Password:** `password123`
- **Email:** `johnnyblast94@gmail.com`

## 🔧 How It Works

### Magic DNS Resolution

1. **Container Hostnames**: Each service has a hostname (e.g., `chat`, `code`, `s3`)
2. **Tailscale Magic DNS**: Automatically resolves `hostname.tailnet-name.ts.net`
3. **Cloudflare Tunnel**: Routes traffic from `subdomain.bbj4u.xyz` to `hostname:port`
4. **Automatic Discovery**: New services are automatically discoverable

### Service Registration Flow

```
1. Container starts with hostname "chat"
2. Tailscale registers "chat.your-tailnet.ts.net"
3. Cloudflare tunnel routes "chat.bbj4u.xyz" → "chat:8080"
4. Service is immediately accessible via HTTPS
```

## 🛠️ Advanced Configuration

### Custom Tailscale Tags

Add custom tags to organize your services:

```bash
# In .env file
TS_EXTRA_ARGS=--advertise-tags=tag:devstack,tag:production --hostname=devstack-$(hostname)
```

### Subnet Advertisement

To advertise routes for other devices:

```bash
# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Advertise subnet (if needed)
tailscale up --advertise-routes=10.0.0.0/24
```

### Cloudflare Access Policies

Add authentication to your services:

1. Go to **Access > Applications**
2. Create policies for sensitive services
3. Configure authentication methods (Google, GitHub, etc.)

## 🔍 Troubleshooting

### Check Tailscale Status
```bash
docker exec tailscale tailscale status
docker exec tailscale tailscale netcheck
```

### Check Cloudflare Tunnel
```bash
docker logs cloudflared
```

### Test Service Connectivity
```bash
# Test internal connectivity
docker exec chat ping ollama
docker exec code curl http://chat:8080

# Test external access
curl -I https://chat.bbj4u.xyz
```

### Common Issues

1. **Services not accessible externally**
   - Verify Cloudflare Tunnel is configured correctly
   - Check tunnel token in `.env` file
   - Ensure DNS records point to Cloudflare

2. **Internal service communication fails**
   - Check Tailscale container status: `docker logs tailscale`
   - Verify Magic DNS is working: `docker exec tailscale tailscale status`
   - Test internal connectivity: `docker exec chat ping ollama`
   - Check Tailscale health: `curl http://localhost:9002/healthz`

3. **Tailscale authentication issues**
   - Verify `TS_AUTHKEY` in `.env` file
   - Check auth key hasn't expired
   - Ensure key has proper permissions and tags
   - Verify auth key format: `tskey-auth-...` or `tskey-client-...`

4. **DNS Resolution Issues**
   - Ensure `TS_ACCEPT_DNS=true` is set
   - Check if Magic DNS is enabled in Tailscale admin console
   - Verify container can resolve Tailscale hostnames

5. **SSL/TLS errors**:
   - Verify Cloudflare SSL/TLS mode is "Full" or "Full (strict)"
   - Check tunnel configuration in Cloudflare dashboard

### Useful Commands

```bash
# Check all service status
docker-compose ps

# View Tailscale status and Magic DNS
docker exec tailscale tailscale status

# Check Tailscale health endpoint
curl http://localhost:9002/healthz

# View Tailscale logs
docker logs tailscale

# Test internal DNS resolution
docker exec chat nslookup ollama

# Check Tailscale network info
docker exec tailscale tailscale netcheck

# View Tailscale IP and hostname
docker exec tailscale tailscale ip

# Restart specific service
docker-compose restart [service-name]

# Force Tailscale reconnection
docker-compose restart tailscale
```

## 📚 Additional Resources

- [Tailscale Magic DNS Documentation](https://tailscale.com/kb/1081/magicdns/)
- [Tailscale Docker Documentation](https://tailscale.com/kb/1282/docker) <mcreference link="https://tailscale.com/kb/1282/docker" index="0">0</mcreference>
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)

## 🎯 Next Steps

1. **Customize Services**: Modify `docker-compose.yml` to add/remove services
2. **Backup Strategy**: Set up automated backups for your data
3. **Monitoring**: Configure alerts in Grafana
4. **Security**: Implement Cloudflare Access policies
5. **Scaling**: Add more nodes to your Tailscale network

---

**🎉 Congratulations!** Your Dev Stack is now running with automatic service discovery and secure access through Tailscale Magic DNS and Cloudflare tunnels.