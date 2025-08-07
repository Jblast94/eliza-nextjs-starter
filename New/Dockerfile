FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Create required directories
RUN mkdir -p /data/ollama /data/openwebui /data/minio /data/n8n /data/grafana /data/prometheus /data/redis /data/mongodb

# Copy configuration files
COPY docker-compose.yml /app/
COPY prometheus.yml /app/

# Set working directory
WORKDIR /app

# Expose ports
EXPOSE 8080 8081 8082 8083 9000 9001 3000 9090 5672 15672

# Start services
CMD ["docker-compose", "up", "-d"]