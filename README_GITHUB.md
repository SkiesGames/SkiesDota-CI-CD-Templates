# SkiesDota GitHub Actions CI/CD Templates

A comprehensive GitHub Actions template repository for Ansible automation and infrastructure management. This repository provides reusable CI/CD workflows, Docker images, Ansible playbooks, roles, and infrastructure that can be included in other projects.

## Overview

This template repository contains:

- **Docker Images**: Pre-built Ansible runner images for CI/CD pipelines
- **GitHub Actions Workflows**: Reusable workflow templates for deployment and automation
- **Test Workflows**: Ansible code quality validation and syntax checking with smart dependency management
- **Ansible Playbooks**: Infrastructure automation playbooks
- **Ansible Roles**: Modular, reusable Ansible roles for common tasks
- **Templates**: Jinja2 templates for dynamic configuration generation

## Quick Start

### Using This Template

1. **Fork or Clone**: Copy this repository to your GitHub account
2. **Configure Secrets**: Set up required GitHub Secrets (see Configuration section)
3. **Customize**: Modify workflows and playbooks for your specific needs
4. **Deploy**: Use the provided workflows for infrastructure automation

### Including in Other Projects

You can reference these workflows in other repositories by copying the workflow files and adjusting the paths.

## Available Workflows

### Core Workflows
- `build-images`: Builds Docker images for Ansible runners and testing
- `test-ansible`: Validates Ansible code quality and syntax with conditional build dependencies
- `deploy`: Infrastructure deployment and automation

### Manual Operations
- `bootstrap`: Initial server setup and configuration (manual trigger)
- `deploy`: Application deployment and updates (auto on main branch or manual)
- `ssh-key-setup`: SSH key generation and distribution (manual trigger)

## Workflow Details

### Build Images Workflow (`.github/workflows/build-images.yml`)

**Purpose**: Builds and publishes Docker images to GitHub Container Registry

**Features**:
- Builds base Ansible image (`ansible:latest`)
- Builds test Ansible image (`ansible-test:latest`)
- Automatic triggering on Dockerfile changes
- Manual trigger support
- Uses YAML anchor template for consistency
- Multi-platform support with Docker Buildx
- Layer caching for faster builds

**Triggers**:
- Push to Dockerfile files
- Manual workflow dispatch

### Test Ansible Workflow (`.github/workflows/test-ansible.yml`)

**Purpose**: Validates Ansible code quality and syntax with smart dependency management

**Features**:
- **Conditional Build Dependency**: Automatically waits for build workflow only when necessary
- Syntax validation for all roles and playbooks using ansible-lint
- Dry-run testing for all playbooks with `--check --diff`
- Parallel job execution when possible
- Automatic triggering on Ansible code changes
- Uses reusable workflow for consistency and maintainability

**Smart Dependency Management**:
- Checks if build workflow is running using GitHub API
- Waits for build completion only when build is actually running
- Proceeds immediately if no build workflow is active
- Reduces unnecessary delays and improves pipeline efficiency

**Triggers**:
- Push to ansible directory
- Push to Dockerfile.test
- Pull requests to ansible directory
- Manual workflow dispatch

### Deploy Workflow (`.github/workflows/deploy.yml`)

**Purpose**: Infrastructure deployment and automation

**Features**:
- Bootstrap deployment (manual)
- Auto-deploy on main branch (only if AUTO_DEPLOY=true)
- SSH key setup (manual)
- Pre-flight checks for manual runs
- Conditional job execution based on inputs
- Uses reusable workflow for consistency

**Triggers**:
- Push to main branch (ansible changes) - only if AUTO_DEPLOY=true
- Manual workflow dispatch with playbook selection

## Conditional Dependency Management

### How It Works

The test workflow implements intelligent dependency management that optimizes CI/CD pipeline performance:

1. **API Check**: Uses GitHub API to check if build workflow is currently running
2. **Conditional Wait**: Only waits if build workflow is actually in progress
3. **Immediate Execution**: Proceeds immediately if no build workflow is running
4. **Parallel Processing**: Allows tests to run in parallel when possible

### Benefits

- **Efficiency**: Eliminates unnecessary waiting when builds aren't running
- **Reliability**: Ensures tests use the latest images when builds are active
- **Performance**: Reduces overall pipeline execution time
- **Flexibility**: Works with any build workflow configuration

### Example Scenarios

**Scenario 1: Build Running**
```
1. Test workflow triggers
2. API check finds build workflow running
3. Test workflow waits for build completion
4. Test workflow proceeds with latest image
```

**Scenario 2: No Build Running**
```
1. Test workflow triggers
2. API check finds no build workflow running
3. Test workflow proceeds immediately
4. Uses existing image from registry
```

## Configuration

### Required GitHub Secrets

Configure these secrets in your GitHub repository (Settings → Secrets and variables → Actions):

#### Core Secrets
- `ANSIBLE_HOSTS`: Multi-line list of target host IPs
- `ANSIBLE_USER`: SSH username for all hosts
- `SSH_PRIVATE_KEY`: Private SSH key for authentication (after initial setup)

#### Initial Setup Secrets (temporary)
- `ANSIBLE_HOSTS_PASSWORD`: Multi-line list of host passwords (for first-time setup)
- `GITHUB_TOKEN`: GitHub Personal Access Token with repo scope

#### Optional Secrets
- `AUTO_DEPLOY`: Set to "true" to enable automatic deployment on main branch

### Example Secret Configuration

```
ANSIBLE_HOSTS:
192.168.1.1
192.168.1.2

ANSIBLE_HOSTS_PASSWORD:
password1
password2

ANSIBLE_USER: ubuntu
```

## Initial SSH Setup

For first-time SSH key setup:

1. **Configure Secrets**: Set `ANSIBLE_HOSTS`, `ANSIBLE_HOSTS_PASSWORD`, and `ANSIBLE_USER`
2. **Run SSH Key Setup**: 
   - Go to Actions → Deploy Infrastructure
   - Click "Run workflow"
   - Select "ssh-key-setup" option
   - Click "Run workflow"
3. **Store Generated Key**: The workflow will generate and distribute SSH keys
4. **Update Secrets**: Add the generated private key as `SSH_PRIVATE_KEY` secret
5. **Remove Password Secret**: Delete `ANSIBLE_HOSTS_PASSWORD` after successful setup

## Directory Structure

```
├── .github/
│   └── workflows/
│       ├── build-images.yml           # Docker image building
│       ├── test-ansible.yml          # Ansible code testing (main)
│       ├── reusable-test-ansible.yml # Reusable test workflow
│       └── deploy.yml                # Infrastructure deployment
├── ansible/
│   ├── images_jobs/     # GitLab CI jobs (legacy)
│   ├── test_jobs/       # GitLab CI jobs (legacy)
│   ├── jobs/           # GitLab CI jobs (legacy)
│   ├── playbooks/      # Ansible playbooks
│   ├── roles/          # Reusable Ansible roles
│   └── templates/      # Jinja2 templates
├── Dockerfile          # Base Ansible image
├── Dockerfile.test     # Ansible testing image
├── common.gitlab-ci.yml # GitLab CI templates (legacy)
├── .gitlab-ci.yml      # GitLab CI pipeline (legacy)
├── MIGRATION_GUIDE.md  # Migration documentation
└── README_GITHUB.md    # This file
```

## Available Roles

- **deploy**: Application deployment and synchronization
- **docker**: Docker installation and configuration
- **docker-compose-plugin**: Docker Compose plugin management
- **environment**: Environment file management
- **firewall**: UFW firewall configuration
- **github_variable**: GitHub variable management (new)
- **gitlab_variable**: GitLab variable management (legacy)
- **mongodb**: MongoDB replica set and index setup
- **ssh**: SSH key generation and agent setup
- **ssl**: SSL certificate management
- **synchronize**: File synchronization utilities

## Testing

The repository includes comprehensive testing capabilities with smart dependency management:

### Syntax Testing
- **ansible-lint**: Validates all roles and playbooks for best practices
- **Automatic triggers**: Runs on changes to playbooks, roles, or test image
- **Manual execution**: Available for on-demand testing
- **Conditional dependencies**: Waits for build workflow only when necessary

### Playbook Testing
- **Dry-run validation**: Uses `--check --diff` to simulate playbook execution
- **Dependency chain**: Runs after syntax validation
- **Safety checks**: Prevents accidental changes during testing

### Smart Dependency Features
- **API-based detection**: Uses GitHub API to check build workflow status
- **Conditional waiting**: Only waits when builds are actually running
- **Parallel execution**: Runs tests immediately when no build dependency exists
- **Configurable**: Can be adapted for different build workflow names

## Docker Images

### Base Ansible Image (`Dockerfile`)
- **Base**: Python 3.13 slim
- **Features**: SSH client, Docker CLI, rsync, curl, jq, OpenSSL
- **Purpose**: Main Ansible runner for deployment and automation
- **Registry**: `ghcr.io/${{ github.repository }}/ansible:latest`

### Test Ansible Image (`Dockerfile.test`)
- **Base**: Python 3.13 slim
- **Features**: ansible, ansible-lint
- **Purpose**: Code quality validation and testing
- **Registry**: `ghcr.io/${{ github.repository }}/ansible-test:latest`

## Usage Examples

### Manual Deployment
1. Go to Actions tab in GitHub
2. Select "Deploy Infrastructure" workflow
3. Click "Run workflow"
4. Choose playbook type (bootstrap/deploy/ssh-key-setup)
5. Click "Run workflow"

### Automatic Deployment
Set `AUTO_DEPLOY` secret to "true" to enable automatic deployment on main branch pushes.

### SSH Key Setup
1. Configure `ANSIBLE_HOSTS` and `ANSIBLE_HOSTS_PASSWORD` secrets
2. Run "Deploy Infrastructure" workflow manually
3. Select "ssh-key-setup" option
4. After successful run, remove `ANSIBLE_HOSTS_PASSWORD` secret

### Testing with Conditional Dependencies
The test workflow automatically handles build dependencies:
- **When build is running**: Waits for completion, then runs tests
- **When build is not running**: Proceeds immediately with existing images
- **Manual override**: Can be configured to skip build dependency entirely

## Migration from GitLab CI

This repository has been migrated from GitLab CI/CD to GitHub Actions. See `MIGRATION_GUIDE.md` for detailed migration instructions.

### Key Changes
- GitLab CI stages → GitHub Actions workflows
- GitLab Container Registry → GitHub Container Registry
- GitLab CI/CD variables → GitHub Secrets
- GitLab API → GitHub API
- Manual dependency management → Conditional dependency with API checks

### New Features
- **Smart Dependencies**: Conditional waiting reduces pipeline delays
- **Reusable Workflows**: Better code organization and maintainability
- **API Integration**: Real-time workflow status checking
- **Parallel Execution**: Optimized job scheduling

## Contributing

1. Follow the existing role structure
2. Update documentation for new features
3. Test changes in a fork before submitting
4. Ensure all Ansible code passes linting and validation

## Security Features

- SSH key rotation
- Secure credential storage in GitHub Secrets
- Pre-flight validation for manual operations
- Manual approval for critical operations
- Encrypted communication with GitHub API
- Conditional dependency management reduces attack surface

## Troubleshooting

### Common Issues

**Container Registry Access**
```bash
# Verify registry access
docker login ghcr.io -u $GITHUB_USERNAME -p $GITHUB_TOKEN
```

**SSH Key Issues**
```bash
# Test SSH connectivity
ssh -i ~/.ssh/ci_id_ed25519 $ANSIBLE_USER@$TARGET_HOST
```

**Workflow Failures**
- Check workflow run logs in GitHub Actions
- Verify all required secrets are configured
- Ensure target hosts are accessible

**Conditional Dependency Issues**
- Check GitHub API rate limits
- Verify workflow name matches exactly
- Review API permissions for GITHUB_TOKEN
- Test API queries manually using `gh api` command

### Debug Workflows
- Enable debug logging in workflow files
- Check workflow run logs in GitHub Actions
- Use `actions/checkout@v4` with `fetch-depth: 0` for full history
- Monitor GitHub API rate limits in workflow logs
- Test conditional dependency logic manually

## Performance Optimizations

### Conditional Dependencies
- **Efficiency**: Tests run immediately when no build dependency exists
- **Parallel Processing**: Multiple workflows can run simultaneously
- **API Optimization**: Minimal API calls for status checking
- **Caching**: Leverages GitHub Actions caching for faster builds

### Build Optimizations
- **Layer Caching**: Docker layer caching reduces build times
- **Multi-platform**: Parallel builds for different architectures
- **Registry Caching**: GitHub Container Registry optimizations

## License

This project is licensed under the MIT License. 