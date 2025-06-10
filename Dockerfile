FROM python:3.13-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        rsync \
        curl \
        jq \
        sshpass \
        docker-credential-helper \
    && pip install ansible \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ~/.docker \
    && echo '{"credsStore": "gitlab"}' > ~/.docker/config.json
