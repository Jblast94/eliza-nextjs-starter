# Dev Stack Clean - Supabase Integrated

A comprehensive development stack with Supabase database integration, featuring Ollama, OpenWebUI, n8n, MinIO, automated backups, and monitoring services.

## 🚀 Features

- **AI Services**: Ollama LLM server with OpenWebUI interface
- **Workflow Automation**: n8n with Supabase database backend
- **Object Storage**: MinIO S3-compatible storage
- **Database**: Supabase PostgreSQL integration with automated backups
- **Monitoring**: Grafana + Prometheus with Supabase data persistence
- **Development**: Kaggle Jupyter notebooks with GPU support
- **Networking**: Tailscale mesh networking with static IPs
- **SSL**: Automatic Let's Encrypt certificates

## 🗄️ Supabase Integration

This stack is fully integrated with Supabase for:

- **Database Backend**: PostgreSQL database for all services
- **Data Persistence**: Grafana dashboards and n8n workflows stored in Supabase
- **Automated Backups**: Daily database backups with 30-day retention
- **Centralized Storage**: Single source of truth for all application data

### Supabase Configuration

```
Database: postgres
Host: db.dwgsdbxkwjoyxywufbgf.supabase.co
Port: 5432
User: postgres
Password: rGEQ1s1Nl0t6Sdus
```

## 🏗️ Quick Start

1. **Clone and Setup**:
   ```bash
   git clone <repository-url>
   cd Dev-Stack-Clean-1
   cp .env.example .env
   ```

2. **Configure Environment**:
   Edit `.env` file with your specific values:
   ```bash
   nano .env
   ```

3. **Deploy Stack**:
   ```bash
   docker-compose up -d
   ```

4. **Configure Tailscale**:
   ```bash
   tailscale up --advertise-routes=100.64.0.0/24
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
| Jupyter | https://notebook.bbj4u.xyz | GPU Notebooks |

## 🔧 Configuration

### Environment Variables

Key environment variables in `.env`:

```bash
# Supabase
DATABASE_URL=postgresql://postgres:rGEQ1s1Nl0t6Sdus@db.dwgsdbxkwjoyxywufbgf.supabase.co:5432/postgres
SUPABASE_URL=https://dwgsdbxkwjoyxywufbgf.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Application Secrets
WEBUI_SECRET_KEY=your_secure_key
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure_password
```

### DNS Configuration

Import `cloudflare-dns-records.csv` to Cloudflare:
- Replace `[TAILSCALE_IP]` with your actual Tailscale IP
- All domains point to your Tailscale subnet

## 💾 Backup System

### Automated Backups

- **Schedule**: Daily at 2:00 AM
- **Retention**: 30 days
- **Location**: `/backups` volume in `supabase-backup` container
- **Format**: Compressed SQL dumps

### Manual Backup

```bash
# Create immediate backup
docker exec supabase-backup /scripts/backup.sh

# View backup logs
docker logs supabase-backup

# List backups
docker exec supabase-backup ls -la /backups/
```

### Restore from Backup

```bash
# Restore from specific backup
docker exec -i supabase-backup psql -h $PGHOST -U $PGUSER -d $PGDATABASE < /backups/backup_YYYYMMDD_HHMMSS.sql
```

## 🔒 Security Features

- **Network Isolation**: Tailscale mesh networking
- **SSL Certificates**: Automatic Let's Encrypt
- **Database Security**: Supabase managed PostgreSQL
- **Access Control**: Basic auth for admin interfaces
- **Resource Limits**: CPU and memory constraints

## 📊 Monitoring

### Grafana Dashboards

- **System Metrics**: CPU, memory, disk usage
- **Application Metrics**: Service health and performance
- **Database Metrics**: Supabase connection and query stats
- **Backup Status**: Automated backup monitoring

### Prometheus Targets

- Docker containers
- System metrics
- Application-specific metrics
- Custom alerting rules

## 🚀 GPU Support

Kaggle notebook service includes:
- **NVIDIA GPU access** for ML workloads
- **Pre-installed libraries**: TensorFlow, PyTorch, scikit-learn
- **Persistent storage**: `/home/jovyan/work` volume
- **Database connectivity**: Direct Supabase integration

## 🔧 Troubleshooting

### Common Issues

1. **Service not accessible**:
   ```bash
   # Check service status
   docker-compose ps
   
   # View logs
   docker-compose logs [service-name]
   ```

2. **Database connection issues**:
   ```bash
   # Test Supabase connectivity
   docker exec adminer ping db.dwgsdbxkwjoyxywufbgf.supabase.co
   ```

3. **Backup failures**:
   ```bash
   # Check backup service logs
   docker logs supabase-backup
   
   # Verify environment variables
   docker exec supabase-backup env | grep PG
   ```

### Health Checks

```bash
# Check all services
docker-compose ps

# Test network connectivity
docker exec ollama ping 100.64.0.102

# Verify Supabase connection
docker exec adminer pg_isready -h db.dwgsdbxkwjoyxywufbgf.supabase.co -p 5432
```

## 📝 Maintenance

### Regular Tasks

1. **Update containers**:
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

2. **Clean old images**:
   ```bash
   docker system prune -a
   ```

3. **Monitor disk usage**:
   ```bash
   docker system df
   ```

4. **Backup verification**:
   ```bash
   docker exec supabase-backup ls -la /backups/
   ```

## Overview
This repository contains a collection of scripts and configurations for deploying and managing a development stack with AI services on Google Cloud Run, including model servers, content generation tools, and supporting infrastructure.

## Services Included
- **Ollama:** Local LLM server
- **OpenWebUI:** Web interface for interacting with Ollama
- **n8n:** Workflow automation tool
- **MinIO:** S3-compatible object storage
- **Adminer:** Database management tool
- **Redis:** In-memory data store for caching
- **MongoDB:** NoSQL database for content storage
- **RabbitMQ:** Message queue for service communication
- **Grafana:** Monitoring and visualization
- **Prometheus:** Metrics collection

## Prerequisites

- **Google Cloud Platform Account:** With billing enabled
- **Google Cloud SDK:** Installed and configured on your local machine
- **Docker:** Installed on your local machine
- **kubectl:** Installed on your local machine
- **Domain Name:** You need to own a domain name (e.g., myn8n.com) and be able to configure DNS records

## Deployment Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd dev-stack
```

### 2. Configure Google Cloud

```bash
# Login to Google Cloud
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable run.googleapis.com containerregistry.googleapis.com storage.googleapis.com
```

### 3. Deploy to Google Cloud Run

```bash
# Make the deployment script executable
chmod +x deploy-to-cloud-run.sh

# Run the deployment script
./deploy-to-cloud-run.sh
```

The script will:
- Prompt for necessary configuration details
- Create Kubernetes secrets for sensitive data
- Build and push the Docker image to Google Container Registry
- Deploy the service to Google Cloud Run
- Display the service URL and next steps

### 4. Configure DNS Records

Update your domain's DNS records to point the following subdomains to the Cloud Run service URL using CNAME records:

- `llm.myn8n.com` - Ollama API
- `chat.myn8n.com` - OpenWebUI
- `n8n.myn8n.com` - n8n workflow automation
- `s3-console.myn8n.com` - MinIO Console
- `s3.myn8n.com` - MinIO API
- `db.myn8n.com` - Adminer
- `monitor.myn8n.com` - Grafana
- `metrics.myn8n.com` - Prometheus

## Accessing Your Services

Once the DNS records have propagated, you can access your services at the configured subdomains (e.g., `https://chat.myn8n.com`).

## Data Persistence

The deployment uses a Persistent Volume Claim (PVC) to store data. This ensures that your data persists even if the containers are restarted.

## GPU Support

If you need GPU support for AI services (PyTorch Model Server, Stable Diffusion, Ollama), you'll need to:

1. Use a GPU-enabled Cloud Run configuration
2. Update the `cloud-run-config.yaml` file to include GPU specifications
3. Use container images that support GPU acceleration

## Monitoring and Scaling

- **Monitoring:** Access Grafana at `https://monitor.myn8n.com` for monitoring dashboards
- **Metrics:** Access Prometheus at `https://metrics.myn8n.com` for raw metrics
- **Scaling:** The Cloud Run configuration includes autoscaling settings that can be adjusted in the `cloud-run-config.yaml` file

## Security Considerations

- All sensitive data is stored in Kubernetes secrets
- Services are accessible only via HTTPS
- Basic authentication is enabled for n8n, MinIO, and other services
- Change all default passwords immediately after deployment

## Troubleshooting

- **Service not accessible:** Check DNS configuration and Cloud Run service status
- **Container fails to start:** Check Cloud Run logs for error messages
- **Data persistence issues:** Verify the PVC is correctly mounted

## Customization

You can customize the deployment by modifying the following files:

- `docker-compose.yml`: Service configuration
- `cloud-run-config.yaml`: Cloud Run deployment configuration
- `Dockerfile`: Container build instructions
- `prometheus.yml`: Prometheus configuration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
