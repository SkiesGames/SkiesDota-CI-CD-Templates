# Use Python 3.13 slim image as base
FROM python:3.13-slim

# Set environment variables for better security and performance
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    ANSIBLE_FORCE_COLOR=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # SSH and file transfer tools
        openssh-client \
        rsync \
        sshpass \
        # Network and utility tools
        curl \
        jq \
        # Docker repository setup
        gnupg \
        lsb-release \
        ca-certificates \
        # OpenSSL for GitHub API encryption
        openssl \
        && rm -rf /var/lib/apt/lists/*

# Add Docker repository and install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir ansible

# Configure Docker for GitHub Container Registry
RUN mkdir -p ~/.docker && \
    echo '{"credsStore": "ghcr"}' > ~/.docker/config.json

# Set working directory
WORKDIR /workspace

# Create non-root user for better security (optional)
# RUN groupadd -r ansible && useradd -r -g ansible ansible
# USER ansible

# Health check to verify Ansible is available
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ansible --version || exit 1
