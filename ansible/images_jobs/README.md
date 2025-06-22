# Images Jobs

This directory contains GitLab CI jobs for building and managing Docker images used in the Ansible automation pipeline.

## Available Jobs

### build_base_ansible_image
Builds the base Ansible runner image used for all Ansible operations.

**Features:**
- Python 3.13 slim base image
- Ansible installation
- SSH client and related tools
- Docker CLI for container operations
- GitLab credential store configuration

**Usage:**
- Manual trigger only
- Builds and pushes to `$CI_REGISTRY_IMAGE/ansible:latest`

### build_test_image
Builds the testing image with Molecule for role testing.

**Features:**
- Python 3.13 slim base image
- Ansible and Molecule installation
- Docker CLI for test environments
- Non-root user (molecule) for security
- Optimized for testing workflows

**Usage:**
- Manual trigger only
- Builds and pushes to `$CI_REGISTRY_IMAGE/ansible-test:latest`

## Image Dependencies

Both images require:
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
    file: '/ansible/jobs.yml'
```

The jobs will automatically use the appropriate image based on the task type. 