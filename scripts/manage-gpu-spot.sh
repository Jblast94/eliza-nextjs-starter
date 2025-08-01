#!/bin/bash
set -e

# Configuration
INSTANCE_TYPE="${INSTANCE_TYPE:-g5.xlarge}"  # Default AWS instance type for ML/AI development
PRICE_THRESHOLD="${PRICE_THRESHOLD:-1.00}"     # Maximum price willing to pay per hour
REGION="${REGION:-us-east-1}"        # Default region

# Function to check GPU utilization
# NOTE: This function uses nvidia-smi, which is specific to NVIDIA GPUs.
# You may need to adapt this for other GPU types or cloud monitoring tools.
check_gpu_utilization() {
    local threshold="${GPU_UTIL_THRESHOLD:-30}"  # 30% utilization threshold, configurable via env var
    if command -v nvidia-smi &> /dev/null; then
        local util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
        echo "Current GPU utilization: $util%"
        if [ "$util" -lt "$threshold" ]; then
            return 0  # Low utilization
        fi
        return 1  # High utilization
    else
        echo "nvidia-smi not found. Cannot check GPU utilization."
        return 1 # Assume high utilization or inability to check
    fi
}

# Function to request spot instance
# NOTE: This function contains placeholders for cloud provider specific commands.
# You MUST replace these with the appropriate commands for your cloud provider (e.g., AWS, Azure, GCP).
request_spot_instance() {
    echo "Requesting spot instance of type $INSTANCE_TYPE in region $REGION with price threshold $PRICE_THRESHOLD..."
    # Add your cloud provider's CLI commands here
    # Example for AWS:
    # aws ec2 request-spot-instances --instance-count 1 --launch-specification file://launch-spec.json --spot-price $PRICE_THRESHOLD --instance-type $INSTANCE_TYPE --region $REGION
    echo "Cloud provider specific spot instance request command goes here."
    # You will likely need to wait for the instance to be ready and get its IP address
}

# Function to attach GPU to services
# This assumes docker-compose.gpu.yml is correctly configured for your environment.
attach_gpu() {
    echo "Attaching GPU to services defined in docker-compose.gpu.yml..."
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d \
        ollama \
        stable-diffusion \
        pytorch-server
}

# Function to setup monitoring
# This sets up Prometheus and Grafana with a basic node exporter.
# You may need to configure dcgm-exporter separately depending on your GPU setup.
setup_monitoring() {
    echo "Configuring monitoring services (Prometheus, Grafana, Node Exporter)..."
    # Ensure dcgm-exporter is running if needed for GPU metrics
    # docker compose up -d dcgm-exporter
    docker compose up -d prometheus grafana node-exporter
    
    # Wait for Grafana to be ready
    echo "Waiting for Grafana to be ready..."
    sleep 30 # Increased sleep time for Grafana initialization
    
    # Import GPU dashboard to Grafana
    # NOTE: This assumes a gpu-dashboard.json file exists and is compatible.
    # The URL uses the MONITOR_DOMAIN environment variable.
    echo "Attempting to import GPU monitoring dashboard to Grafana at https://${MONITOR_DOMAIN}..."
    curl -X POST \
        -H "Content-Type: application/json" \
        -d @gpu-dashboard.json \
        http://admin:${GRAFANA_PASSWORD}@localhost:3000/api/dashboards/db # Note: Using localhost:3000 for curl from the host, assuming port 3000 is accessible. Adjust if Grafana is not directly accessible on localhost.
    echo "Dashboard import command executed. Check Grafana UI to confirm."
}

case "$1" in
    "start")
        request_spot_instance
        attach_gpu
        setup_monitoring
        ;;
    "stop")
        echo "Stopping GPU-dependent services..."
        docker compose -f docker-compose.yml -f docker-compose.gpu.yml stop \
            ollama \
            stable-diffusion \
            pytorch-server
        echo "Adding cloud provider specific instance termination logic here."
        # Add instance termination logic here
        # Example for AWS:
        # aws ec2 terminate-instances --instance-ids i-xxxxxxxxxxxxxxxxx --region $REGION
        ;;
    "monitor")
        check_gpu_utilization
        # Add cloud provider specific monitoring checks here if needed
        ;;
    *)
        echo "Usage: $0 {start|stop|monitor}"
        echo "Environment variables can be used to configure INSTANCE_TYPE, PRICE_THRESHOLD, REGION, and GPU_UTIL_THRESHOLD."
        exit 1
        ;;
esac
