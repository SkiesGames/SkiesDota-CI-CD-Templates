FROM python:3.13-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        rsync \
        curl \
        jq \
        sshpass \
        gnupg \
        lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && pip install ansible \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ~/.docker \
    && echo '{"credsStore": "gitlab"}' > ~/.docker/config.json
