FROM docker:dind

# Copy the daemon configuration with insecure registry settings
COPY daemon.json /etc/docker/daemon.json

# Ensure proper permissions
RUN chmod 644 /etc/docker/daemon.json
