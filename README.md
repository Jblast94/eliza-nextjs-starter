# Dev-Stack for Google Cloud Run

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
