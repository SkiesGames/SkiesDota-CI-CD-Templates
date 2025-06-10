FROM python:3.13-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        rsync \
        curl \
        jq \
        sshpass \
    && pip install ansible \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
