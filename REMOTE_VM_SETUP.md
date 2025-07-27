# Remote VM Setup Guide

This guide provides step-by-step instructions for deploying the Dev Stack on a remote VM.

## Prerequisites

- Ubuntu/Debian-based remote VM
- SSH access to the VM
- Domain: bbj4u.xyz configured in Cloudflare
- Tailscale account

## Quick Deployment

### 1. Connect to Your Remote VM
```bash
ssh your-username@your-vm-ip
```

### 2. Clone and Deploy
```bash
# Clone the repository
git clone https://github.com/your-repo/Dev-Stack-Clean.git
cd Dev-Stack-Clean

# Make deployment script executable
chmod +x deploy.sh
chmod +x deploy-supabase-stack.sh

# Run the deployment
./deploy.sh
```

### 3. Configure Tailscale
```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Connect to your Tailscale network
sudo tailscale up

# Get your Tailscale IP
tailscale ip -4
```

### 4. Update DNS Records
1. Open `cloudflare-dns-records.csv`
2. Replace `[TAILSCALE_IP]` with your actual Tailscale IP
3. Import the CSV file into Cloudflare DNS

## Service Access

Once deployed, access your services at:

- **OpenWebUI (AI Chat)**: https://chat.bbj4u.xyz
- **n8n (Automation)**: https://n8n.bbj4u.xyz
- **MinIO (Storage)**: https://s3.bbj4u.xyz
- **Adminer (Database)**: https://db.bbj4u.xyz
- **Grafana (Monitoring)**: https://monitor.bbj4u.xyz
- **Prometheus (Metrics)**: https://metrics.bbj4u.xyz
- **Jupyter (Notebooks)**: https://notebook.bbj4u.xyz
- **Portainer (Docker Management)**: https://docker.bbj4u.xyz

## Default Credentials

All services use the same credentials for simplicity:
- **Username**: jblast
- **Password**: password123
- **Email**: johnnyblast94@gmail.com

## Management Commands

```bash
# View all running services
docker-compose ps

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f portainer

# Stop all services
docker-compose down

# Update and restart services
docker-compose pull && docker-compose up -d

# Check Tailscale status
tailscale status
```

## Troubleshooting

### Services Not Accessible
1. Check if services are running: `docker-compose ps`
2. Verify Tailscale connection: `tailscale status`
3. Check DNS propagation: `nslookup chat.bbj4u.xyz`

### Portainer Access
- First time setup: Create admin user with username `jblast` and password `password123`
- Access via: https://docker.bbj4u.xyz

### GPU Support (if available)
```bash
# Check GPU availability
nvidia-smi

# Attach GPU to services
./manage-gpu.sh attach
```

## Security Notes

- This setup uses simplified credentials for personal use
- All traffic is routed through Tailscale for security
- SSL certificates are automatically managed
- Consider changing default passwords in production environments

## Backup Information

- Automated daily backups at 2:00 AM
- 30-day retention policy
- Manual backup: `docker exec supabase-backup /scripts/backup.sh`
- View backups: `docker exec supabase-backup ls -la /backups/`