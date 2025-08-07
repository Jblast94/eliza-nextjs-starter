#!/bin/bash

# Mount Google Drive using rclone
setup_google_drive() {
    echo "Setting up Google Drive mount..."
    
    # Install rclone if not present
    if ! command -v rclone &> /dev/null; then
        curl https://rclone.org/install.sh | sudo bash
    fi

    # Create mount point
    mkdir -p /mnt/ai-storage

    # Configure rclone (if not already configured)
    if [ ! -f ~/.config/rclone/rclone.conf ]; then
        echo "Please run 'rclone config' to set up Google Drive access"
        echo "Use these settings:"
        echo "1. Name: ai-storage"
        echo "2. Storage: drive"
        echo "3. client_id: (from Google Cloud Console)"
        echo "4. client_secret: (from Google Cloud Console)"
        echo "5. root_folder_id: (your workspace folder ID)"
    fi

    # Mount Google Drive
    rclone mount ai-storage:AI /mnt/ai-storage \
        --vfs-cache-mode full \
        --vfs-cache-max-size 50G \
        --daemon
}

# Setup RunPod API
setup_runpod() {
    echo "Setting up RunPod integration..."
    
    # Install RunPod CLI
    pip install runpod

    # Configure RunPod
    cat > ~/.runpod/config.yaml << EOL
api_key: ${RUNPOD_API_KEY}
default_gpu: "NVIDIA RTX A5000"
endpoints:
  inference:
    url: https://api.runpod.ai/v2/${RUNPOD_ENDPOINT_ID}
    max_replicas: 2
EOL
}

# Setup HuggingFace
setup_huggingface() {
    echo "Setting up HuggingFace integration..."
    
    # Login to HuggingFace
    huggingface-cli login --token ${HF_TOKEN}

    # Create cache directory
    mkdir -p ${HF_HOME:-~/.cache/huggingface}
}

# Main setup
main() {
    echo "Setting up AI development environment..."
    
    # Load environment variables
    source .env

    # Run setups
    setup_google_drive
    setup_runpod
    setup_huggingface

    echo "Setup complete!"
    echo "Access points:"
    echo "- Models: /mnt/ai-storage/models"
    echo "- HuggingFace Cache: ${HF_HOME:-~/.cache/huggingface}"
    echo "- Development UI: https://dev.${BASE_DOMAIN}"
}

main
