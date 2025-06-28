#!/bin/bash
set -e

echo "Data Migration Tool for Dev Stack"

# Set variables
SOURCE_SERVER="your-source-server-ip"
GCS_BUCKET="your-gcs-bucket-name"

# Prompt for configuration details
read -p "Enter the source server IP or hostname: " SOURCE_SERVER
read -p "Enter the SSH username for the source server: " SSH_USER
read -p "Enter the GCS bucket name for data storage: " GCS_BUCKET
read -p "Enter your GCP project ID: " PROJECT_ID

# Create GCS bucket if it doesn't exist
echo "Creating GCS bucket if it doesn't exist..."
gcloud storage buckets create gs://${GCS_BUCKET} --project=${PROJECT_ID} --location=us-central1 || true

# Create a temporary directory for data
TMP_DIR=$(mktemp -d)
echo "Created temporary directory: ${TMP_DIR}"

# Function to backup and upload a volume
backup_volume() {
  VOLUME_NAME=$1
  CONTAINER_NAME=$2
  
  echo "Backing up ${VOLUME_NAME} from ${CONTAINER_NAME}..."
  
  # SSH to the source server and create a tar archive of the volume
  ssh ${SSH_USER}@${SOURCE_SERVER} \
    "docker run --rm -v ${VOLUME_NAME}:/source -v /tmp:/backup alpine tar -czf /backup/${VOLUME_NAME}.tar.gz -C /source ."
  
  # Download the tar archive from the source server
  echo "Downloading ${VOLUME_NAME}.tar.gz from source server..."
  scp ${SSH_USER}@${SOURCE_SERVER}:/tmp/${VOLUME_NAME}.tar.gz ${TMP_DIR}/
  
  # Upload the tar archive to GCS
  echo "Uploading ${VOLUME_NAME}.tar.gz to GCS bucket..."
  gcloud storage cp ${TMP_DIR}/${VOLUME_NAME}.tar.gz gs://${GCS_BUCKET}/
  
  # Clean up the tar archive on the source server
  ssh ${SSH_USER}@${SOURCE_SERVER} "rm /tmp/${VOLUME_NAME}.tar.gz"
}

# Backup and upload each volume
echo "Starting data migration..."

backup_volume "ollama_data" "ollama"
backup_volume "openwebui_data" "openwebui"
backup_volume "minio_data" "minio"
backup_volume "n8n_data" "n8n"
backup_volume "grafana_data" "grafana"
backup_volume "prometheus_data" "prometheus"
backup_volume "redis_data" "redis"
backup_volume "mongodb_data" "mongodb"

# Clean up the temporary directory
echo "Cleaning up temporary directory..."
rm -rf ${TMP_DIR}

echo ""
echo "Data migration complete! The following volumes have been backed up to gs://${GCS_BUCKET}/:"
echo "- ollama_data.tar.gz"
echo "- openwebui_data.tar.gz"
echo "- minio_data.tar.gz"
echo "- n8n_data.tar.gz"
echo "- grafana_data.tar.gz"
echo "- prometheus_data.tar.gz"
echo "- redis_data.tar.gz"
echo "- mongodb_data.tar.gz"
echo ""
echo "To restore this data to your Cloud Run deployment, use the restore-data.sh script."