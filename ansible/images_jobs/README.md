# Images Jobs

This directory contains GitLab CI jobs for building and managing Docker images used in the Ansible automation pipeline.

## Job Structure

All image building jobs are defined in `jobs.yml` and follow a DRY (Don't Repeat Yourself) approach using a base template.

### Base Template (.base_image)

The `.base_image` template provides common functionality for all image building jobs:

**Features:**
- Docker-in-Docker service setup
- GitLab registry authentication
- Layer caching for faster builds
- Automatic build and push logic
- Change-based and manual trigger rules

**Variables:**
- `IMAGE_NAME`: Target image name (e.g., `ansible`)
- `DOCKERFILE_PATH`: Path to Dockerfile for change detection
- `DOCKERFILE_FLAG`: Docker build flags (empty for base)
- `CACHE_KEY`: Unique cache key for the image type

## Available Jobs

### build_base_ansible_image
Builds the base Ansible runner image used for all Ansible operations.

**Features:**
- Python 3.13 slim base image
- Ansible installation
- SSH client and related tools
- Docker CLI for container operations
- GitLab credential store configuration

**Configuration:**
- Extends: `.base_image`
- Image: `$CI_REGISTRY_IMAGE/ansible:latest`
- Dockerfile: `/Dockerfile`
- Cache: `base-image`

### build_test_ansible_image
Builds the Ansible testing image used for code quality validation.

**Features:**
- Python 3.13 slim base image
- Ansible and ansible-lint installation
- Lightweight testing environment

**Configuration:**
- Extends: `.base_image`
- Image: `$CI_REGISTRY_IMAGE/ansible-test:latest`
- Dockerfile: `/Dockerfile.test`
- Cache: `test-image`

## Image Dependencies

The images require:
- `$CI_REGISTRY_USER`: GitLab registry username
- `$CI_REGISTRY_PASSWORD`: GitLab registry password
- `$CI_REGISTRY`: GitLab registry URL
- `$CI_REGISTRY_IMAGE`: Target image path

## Dockerfile Locations

- Base image: `/Dockerfile`
- Test image: `/Dockerfile.test`

## Usage in Other Projects

These images are automatically used when including the template jobs:

```yaml
include:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/images_jobs/jobs.yml'
```

The jobs will automatically use the appropriate image based on the task type.

## Extending

To add a new image type, extend the `.base_image` template:

```yaml
build_custom_image:
  extends: .base_image
  variables:
    IMAGE_NAME: custom-app
    DOCKERFILE_PATH: Dockerfile.custom
    DOCKERFILE_FLAG: "-f Dockerfile.custom"
    CACHE_KEY: custom-image
``` 