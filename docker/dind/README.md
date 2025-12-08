# Custom ARC Dind Image

This directory contains the configuration for a custom Docker-in-Docker (dind) image used with the Actions Runner Controller (ARC).

## Purpose

The standard `docker:dind` image doesn't include insecure registry configuration. This custom image pre-configures Docker daemon to trust the local image cache registry at `registry.image-cache.svc.cluster.local:5000`.

## Files

- `Dockerfile`: Builds the custom dind image based on `docker:dind`
- `daemon.json`: Docker daemon configuration with insecure registry settings
- `README.md`: This documentation

## Building

The image is automatically built and pushed via GitHub Actions when changes are made to this directory. The workflow is located at `.github/workflows/build-dind.yml`.

## Usage

This image is used in the `deploy-github-runner.yml` Ansible playbook as the dind sidecar container for GitHub Actions runners.
