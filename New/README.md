# Dev Stack

A streamlined development stack with MinIO storage, n8n automation, and Jupyter notebooks.

## Features

- **Storage**: MinIO S3-compatible object storage
- **Automation**: n8n workflow automation platform
- **Data Science**: Jupyter notebooks for data analysis
- **Security**: Basic authentication and SSL/TLS support
- **Networking**: Traefik for reverse proxy

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Git

### Deployment

1. **Clone the repository**:

   ```bash
   git clone https://github.com/Jblast94/Dev-Stack-Clean.git
   cd Dev-Stack-Clean
   ```

2. **Configure environment**:

   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. **Run the deployment**:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

## 🌐 Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| OpenWebUI | https://chat.bbj4u.xyz | AI Chat Interface |
| n8n | https://n8n.bbj4u.xyz | Workflow Automation |
| MinIO | https://s3.bbj4u.xyz | Object Storage |
| Adminer | https://db.bbj4u.xyz | Database Management |
| Grafana | https://monitor.bbj4u.xyz | Monitoring Dashboard |
| Prometheus | https://metrics.bbj4u.xyz | Metrics Collection |
| Jupyter | https://notebook.bbj4u.xyz | Data Science Notebooks |
| Portainer | https://docker.bbj4u.xyz | Docker Management |

## ⚙️ Configuration

### Environment Variables
A pre-configured `.env` file is included with simplified credentials:

- **Username**: jblast
- **Password**: password123
- **Email**: johnnyblast94@gmail.com

All services use these same credentials for simplicity in this personal stack.

### DNS Configuration
1. Update `cloudflare-dns-records.csv` with your Tailscale IP
2. Import the CSV file into Cloudflare DNS
3. Ensure all domains point to your Tailscale node

## 🔄 Backup System

### Automated Backups
- **Frequency**: Daily at 2:00 AM
- **Retention**: 30 days automatic cleanup
- **Format**: Compressed PostgreSQL dumps
- **Monitoring**: Logs available via Docker

### Manual Backup
```bash
# Create immediate backup
docker exec supabase-backup /scripts/backup.sh

# View backup files
docker exec supabase-backup ls -la /backups/

# Check backup logs
docker logs supabase-backup
```

### Backup Recovery
```bash
# Extract backup
docker exec supabase-backup gunzip /backups/backup_YYYYMMDD_HHMMSS.sql.gz

# Restore to Supabase (use with caution)
psql -h ${SUPABASE_HOST} -p ${SUPABASE_PORT} -U ${SUPABASE_DB_USER} -d ${SUPABASE_DB_NAME} < backup_file.sql
```

## 🔒 Security Features

- **SSL/TLS**: Automatic Let's Encrypt certificates
- **Network Isolation**: Tailscale mesh networking
- **Authentication**: Basic auth for n8n, token-based for Jupyter
- **Database Security**: Supabase built-in security features
- **Resource Limits**: CPU and memory constraints for all services

## 📊 Monitoring

### Grafana Dashboards
- System metrics and performance
- Application-specific monitoring
- Database connection and query metrics
- Backup system status

### Prometheus Metrics
- Container resource usage
- Network performance
- Service health checks
- Custom application metrics

## 🖥️ GPU Support

Kaggle Jupyter notebooks include:
- NVIDIA GPU access
- CUDA toolkit
- Popular ML/AI libraries
- Direct database connectivity

## 🛠️ Troubleshooting

### Common Issues

1. **Services not accessible**:
   ```bash
   # Check Tailscale status
   tailscale status
   
   # Verify DNS records
   nslookup chat.bbj4u.xyz
   ```

2. **Database connection issues**:
   ```bash
   # Test Supabase connectivity
   docker exec supabase-backup pg_isready -h ${SUPABASE_HOST} -p ${SUPABASE_PORT}
   ```

3. **Backup failures**:
   ```bash
   # Check backup logs
   docker logs supabase-backup
   
   # Manual backup test
   docker exec supabase-backup /scripts/backup.sh
   ```

### Service Logs
```bash
# View all services
docker-compose logs -f

# Specific service
docker-compose logs -f [service-name]

# Real-time monitoring
docker-compose ps
```

## 🔧 Maintenance

### Updates
```bash
# Pull latest images
docker-compose pull

# Restart with updates
docker-compose up -d
```

### Cleanup
```bash
# Remove old containers
docker system prune

# Clean unused volumes (careful!)
docker volume prune
```

### Scaling
```bash
# Scale specific services
docker-compose up -d --scale prometheus=2
```

## 📝 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Check the troubleshooting section
- Review Docker and Tailscale documentation