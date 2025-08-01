#!/bin/bash
set -e

# GPU instance management script
GPU_COMPOSE_FILE="docker-compose.gpu.yml"

case "$1" in
  "attach")
    echo "Creating GPU compose file..."
    cat > $GPU_COMPOSE_FILE << EOF
version: '3.8'

services:
  ollama:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all # Or specify a number if you have multiple GPUs and want to assign a specific one
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all # Or specify GPU indices (e.g., "0,1")

  pytorch-server:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all

  stable-diffusion:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1 # Stable Diffusion might only need one GPU
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all

# NOTE: The 'deploy' section with 'runtime: nvidia' and 'devices' is specific to NVIDIA GPUs and Docker's configuration for them.
# You may need to adjust this section based on your cloud provider's GPU setup and the container runtime you are using.
EOF
    
    echo "Merging GPU configuration..."
    # Bring up all services that can utilize the GPU
    docker compose -f docker-compose.yml -f $GPU_COMPOSE_FILE up -d ollama pytorch-server stable-diffusion
    echo "GPU attached to Ollama, PyTorch Server, and Stable Diffusion services"
    ;;

  "detach")
    if [ -f "$GPU_COMPOSE_FILE" ]; then
      echo "Removing GPU configuration..."
      # Bring up services without the GPU configuration
      docker compose -f docker-compose.yml up -d ollama pytorch-server stable-diffusion
      rm $GPU_COMPOSE_FILE
      echo "GPU detached from services"
    else
      echo "No GPU configuration found"
    fi
    ;;

  *)
    echo "Usage: $0 {attach|detach}"
    exit 1
    ;;
esac
