#!/bin/bash
set -e

echo "Deploying Dev Stack to Google Cloud Run..."

# Set variables
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
SERVICE_NAME="dev-stack"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:latest"

# Prompt for configuration details
read -p "Enter your GCP Project ID: " PROJECT_ID
read -p "Enter the GCP Region (default: us-central1): " REGION_INPUT
REGION=${REGION_INPUT:-us-central1}

read -p "Enter a secure password for n8n basic auth: " N8N_PASSWORD
read -p "Enter a secure password for MinIO root: " MINIO_PASSWORD
read -p "Enter a secure password for MongoDB root: " MONGO_PASSWORD
read -p "Enter a secure password for RabbitMQ default user: " RABBITMQ_PASSWORD
read -p "Enter a secure password for Grafana admin: " GRAFANA_PASSWORD

# Update the image name with the provided project ID
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:latest"

# Update the cloud-run-config.yaml file with the project ID
sed -i "s|gcr.io/PROJECT_ID/dev-stack:latest|${IMAGE_NAME}|g" cloud-run-config.yaml

# Create a Kubernetes Secret for sensitive data
echo "Creating Kubernetes Secret for sensitive data..."
kubectl create secret generic dev-stack-secrets \
  --from-literal=N8N_BASIC_AUTH_USER=admin \
  --from-literal=N8N_BASIC_AUTH_PASSWORD="${N8N_PASSWORD}" \
  --from-literal=MINIO_ROOT_USER=minioadmin \
  --from-literal=MINIO_ROOT_PASSWORD="${MINIO_PASSWORD}" \
  --from-literal=MONGO_PASSWORD="${MONGO_PASSWORD}" \
  --from-literal=RABBITMQ_PASSWORD="${RABBITMQ_PASSWORD}" \
  --from-literal=GRAFANA_PASSWORD="${GRAFANA_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Build and push the Docker image
echo "Building and pushing Docker image to Google Container Registry..."
docker build -t ${IMAGE_NAME} .
docker push ${IMAGE_NAME}

# Deploy to Cloud Run
echo "Deploying to Cloud Run..."
gcloud run services replace cloud-run-config.yaml --region=${REGION}

# Get the deployed service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region=${REGION} --format="value(status.url)")

echo "\nDeployment complete! Your Dev Stack is now running at: ${SERVICE_URL}"
echo "\nImportant:"
echo "1. Configure DNS records to point your domains to the Cloud Run service URL"
echo "2. The following services are available:"
echo "   - Ollama API: https://llm.myn8n.com"
echo "   - OpenWebUI: https://chat.myn8n.com"
echo "   - n8n: https://n8n.myn8n.com"
echo "   - MinIO Console: https://s3-console.myn8n.com"
echo "   - MinIO API: https://s3.myn8n.com"
echo "   - Adminer: https://db.myn8n.com"
echo "   - Grafana: https://monitor.myn8n.com"
echo "   - Prometheus: https://metrics.myn8n.com"