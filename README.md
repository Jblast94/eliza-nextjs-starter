# Dev-Stack

## Overview
This repository contains a collection of scripts and configurations for deploying and managing a development stack with AI services, including model servers, content generation tools, and supporting infrastructure. The stack is designed to be easily deployable on various cloud instances using Docker and Docker Compose.

The stack includes:
- **Traefik:** Reverse proxy and load balancer with automatic HTTPS via Let's Encrypt.
- **Ollama:** Local LLM server.
- **OpenWebUI:** Web interface for interacting with Ollama.
- **n8n:** Workflow automation tool.
- **MinIO:** S3-compatible object storage.
- **Adminer:** Database management tool.
- **Portainer:** Docker container management UI.
- **VS Code Server:** Web-based VS Code environment.
- **Prometheus & Grafana:** Monitoring and visualization.
- **Node Exporter:** System metrics collector.
- **PyTorch Model Server & Stable Diffusion:** AI model serving and content generation (GPU-dependent).
- **Redis & MongoDB & RabbitMQ:** Supporting data and messaging services for AI components.

## Prerequisites

- **Docker:** Installed and running on your cloud instance.
- **Docker Compose:** Installed on your cloud instance.
- **GPU Setup (for AI services):** If you plan to use the GPU-dependent AI services (PyTorch Model Server, Stable Diffusion, Ollama), you need a cloud instance with a compatible GPU and the necessary drivers and container runtime (e.g., NVIDIA drivers and `nvidia-container-runtime`). Refer to your cloud provider's documentation for setting up GPU instances and Docker with GPU support.
- **DNS Configuration:** You need to own a domain name and be able to configure DNS records to point subdomains to your cloud instance's IP address.

## Configuration

The stack is configured using a `.env` file. The `deploy.sh` script will prompt you for the necessary information and create this file.

Key environment variables in the `.env` file:

- `EMAIL`: Email address for Let's Encrypt certificates.
- `BASE_DOMAIN`: The base domain for accessing your services (e.g., `mydevstack.com`). Subdomains will be automatically generated based on this.
- `VSCODE_PASSWORD`: Secure password for the VS Code Server.
- `GRAFANA_PASSWORD`: Secure password for the Grafana admin user.
- `MONGO_PASSWORD`: Secure password for the MongoDB root user.
- `RABBITMQ_PASSWORD`: Secure password for the RabbitMQ default user.
- `N8N_BASIC_AUTH_USER`: Username for n8n basic authentication.
- `N8N_BASIC_AUTH_PASSWORD`: Password for n8n basic authentication.
- `MINIO_ROOT_USER`: Root username for MinIO.
- `MINIO_ROOT_PASSWORD`: Root password for MinIO.
- `TRAEFIK_PASSWORD`: Hashed password for Traefik basic authentication (the `deploy.sh` script currently uses a default, you should generate a strong password hash).
- `PROMETHEUS_PASSWORD`: Hashed password for Prometheus basic authentication (the `deploy.sh` script currently uses a default, you should generate a strong password hash).

**Important:** Change all default passwords in the `.env` file immediately after deployment. For `TRAEFIK_PASSWORD` and `PROMETHEUS_PASSWORD`, you should generate a secure password hash using a tool like `htpasswd` or a similar utility and update the `.env` file.

## Deployment Instructions

1. Clone the repository on your cloud instance:
   ```bash
   git clone <repository-url>
   cd dev-stack
   ```

2. Run the deployment script:
   ```bash
   ./deploy.sh
   ```
   This script will install dependencies (Docker, Docker Compose if not present), create necessary directories, prompt you for configuration details to create the `.env` file, and start the core services using `docker compose up -d`.

3. Configure DNS records:
   Update your domain's DNS records to point the following subdomains to the IP address of your cloud instance:
   - `traefik.<BASE_DOMAIN>`
   - `llm.<BASE_DOMAIN>`
   - `chat.<BASE_DOMAIN>`
   - `n8n.<BASE_DOMAIN>`
   - `s3-console.<BASE_DOMAIN>`
   - `s3.<BASE_DOMAIN>` (for MinIO API)
   - `db.<BASE_DOMAIN>`
   - `docker.<BASE_DOMAIN>`
   - `code.<BASE_DOMAIN>`
   - `monitor.<BASE_DOMAIN>`
   - `metrics.<BASE_DOMAIN>`

4. Access your services:
   Once the DNS records have propagated and Traefik has obtained SSL certificates (this may take a few minutes), you can access your services at the configured subdomains (e.g., `https://chat.mydevstack.com`).

## Scripts for Management

### `manage-gpu.sh`
This script helps manage GPU resources for the AI services.
- `attach`: Creates a `docker-compose.gpu.yml` overlay file and restarts GPU-dependent services (`ollama`, `pytorch-server`, `stable-diffusion`) with GPU access enabled.
- `detach`: Removes the `docker-compose.gpu.yml` file and restarts GPU-dependent services without GPU access.

Usage:
```bash
./manage-gpu.sh attach
./manage-gpu.sh detach
```

**Note:** The GPU configuration in `docker-compose.gpu.yml` might need adjustments based on your specific GPU setup and Docker configuration on the cloud instance.

### `manage-gpu-spot.sh`
This script is an **example** for managing spot instances with GPU resources, currently tailored towards AWS. You **MUST** adapt this script with the appropriate CLI commands for your specific cloud provider (e.g., Azure, GCP) for requesting and terminating instances, and potentially for checking GPU utilization if `nvidia-smi` is not available or you are using a different GPU vendor.

Usage:
```bash
./manage-gpu-spot.sh start   # Request spot instance, attach GPU, setup monitoring
./manage-gpu-spot.sh stop    # Stop GPU services, terminate instance
./manage-gpu-spot.sh monitor # Check GPU utilization
```

Environment variables can be used to configure `INSTANCE_TYPE`, `PRICE_THRESHOLD`, `REGION`, and `GPU_UTIL_THRESHOLD` for this script.

## Volumes

The Docker Compose files use named volumes to persist data. By default, these volumes are managed by Docker. If you need to use specific paths on your host machine (e.g., for external storage), you can modify the `volumes` section in `docker-compose.yml` and `docker-compose.ai.yml` to use bind mounts instead (e.g., `- /path/on/host:/path/in/container`).

## Troubleshooting
- Check the logs of a specific service:
  ```bash
  docker logs <container-name>
  ```
- Restart a specific service:
  ```bash
  docker compose restart <service-name>
  ```
- If you encounter issues with Traefik and SSL certificates, ensure your DNS records are correctly pointing to your instance and that ports 80 and 443 are open in your firewall.

## License
This project is licensed under the MIT License.
