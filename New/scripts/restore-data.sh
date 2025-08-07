#!/bin/bash
set -e

echo "Data Restoration Tool for Dev Stack on Google Cloud Run"

# Set variables
GCS_BUCKET="your-gcs-bucket-name"
CLOUD_RUN_SERVICE="dev-stack"
REGION="us-central1"

# Prompt for configuration details
read -p "Enter the GCS bucket name containing the backup data: " GCS_BUCKET
read -p "Enter your GCP project ID: " PROJECT_ID
read -p "Enter the Cloud Run service name (default: dev-stack): " SERVICE_INPUT
CLOUD_RUN_SERVICE=${SERVICE_INPUT:-dev-stack}
read -p "Enter the GCP region (default: us-central1): " REGION_INPUT
REGION=${REGION_INPUT:-us-central1}

# Create a temporary directory for data
TMP_DIR=$(mktemp -d)
echo "Created temporary directory: ${TMP_DIR}"

# Function to download and restore a volume
restore_volume() {
  VOLUME_NAME=$1
  
  echo "Restoring ${VOLUME_NAME}..."
  
  # Download the tar archive from GCS
  echo "Downloading ${VOLUME_NAME}.tar.gz from GCS bucket..."
  gcloud storage cp gs://${GCS_BUCKET}/${VOLUME_NAME}.tar.gz ${TMP_DIR}/
  
  # Extract the tar archive
  echo "Extracting ${VOLUME_NAME}.tar.gz..."
  mkdir -p ${TMP_DIR}/${VOLUME_NAME}
  tar -xzf ${TMP_DIR}/${VOLUME_NAME}.tar.gz -C ${TMP_DIR}/${VOLUME_NAME}
  
  # Get the Cloud Run service URL
  SERVICE_URL=$(gcloud run services describe ${CLOUD_RUN_SERVICE} --region=${REGION} --format="value(status.url)")
  
  # Create a temporary container to restore the data
  echo "Creating a temporary container to restore the data..."
  TEMP_CONTAINER_NAME="restore-${VOLUME_NAME}-$(date +%s)"
  
  # Use the same image as the Cloud Run service
  SERVICE_IMAGE=$(gcloud run services describe ${CLOUD_RUN_SERVICE} --region=${REGION} --format="value(spec.template.spec.containers[0].image)")
  
  # Run a temporary container with the volume mounted
  echo "Running a temporary container with the volume mounted..."
  docker run -d --name ${TEMP_CONTAINER_NAME} \
    -v ${TMP_DIR}/${VOLUME_NAME}:/tmp/restore \
    ${SERVICE_IMAGE} \
    sleep infinity
  
  # Copy the data to the appropriate location in the container
  echo "Copying the data to the appropriate location in the container..."
  docker exec ${TEMP_CONTAINER_NAME} mkdir -p /data/${VOLUME_NAME}
  docker exec ${TEMP_CONTAINER_NAME} cp -r /tmp/restore/* /data/${VOLUME_NAME}/
  
  # Stop and remove the temporary container
  echo "Stopping and removing the temporary container..."
  docker stop ${TEMP_CONTAINER_NAME}
  docker rm ${TEMP_CONTAINER_NAME}
}

# Restore each volume
echo "Starting data restoration..."

restore_volume "ollama_data"
restore_volume "openwebui_data"
restore_volume "minio_data"
restore_volume "n8n_data"
restore_volume "grafana_data"
restore_volume "prometheus_data"
restore_volume "redis_data"
restore_volume "mongodb_data"

# Clean up the temporary directory
echo "Cleaning up temporary directory..."
rm -rf ${TMP_DIR}

# Restart the Cloud Run service to apply the changes
echo "Restarting the Cloud Run service to apply the changes..."
gcloud run services update ${CLOUD_RUN_SERVICE} --region=${REGION} --clear-env-vars

echo ""
echo "Data restoration complete! The following volumes have been restored:"
echo "- ollama_data"
echo "- openwebui_data"
echo "- minio_data"
echo "- n8n_data"
echo "- grafana_data"
echo "- prometheus_data"
echo "- redis_data"
echo "- mongodb_data"
echo ""
echo "The Cloud Run service has been restarted to apply the changes."
echo "You can access your services at the configured domains once the service is fully restarted."