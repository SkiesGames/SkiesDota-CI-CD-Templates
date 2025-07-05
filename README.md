# SkiesDota GitHub Actions CI/CD Templates

A comprehensive GitHub Actions template repository for Ansible automation and infrastructure management. This repository provides reusable CI/CD workflows, Docker images, Ansible playbooks, roles, and infrastructure that can be included in other projects.

## Overview

This template repository contains:

- **Docker Images**: Three pre-built Ansible runner images for different CI/CD pipeline stages
- **GitHub Actions Workflows**: Reusable workflow templates for building, testing, linting, and deployment
- **Smart Dependency Management**: Conditional dependency system that optimizes pipeline performance
- **Local Development Tools**: Scripts for local linting and testing
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
- `build-images`: Builds three Docker images for different CI/CD stages
- `test-ansible`: Validates Ansible code quality and syntax with smart build dependencies
- `lint-ansible`: Performs code formatting and linting with smart build dependencies
- `deploy`: Infrastructure deployment and automation

### Manual Operations
- `bootstrap`: Initial server setup and configuration (manual trigger)
- `deploy`: Application deployment and updates (auto on main branch or manual)
- `ssh-key-setup`: SSH key generation and distribution (manual trigger)

## Workflow Details

### Build Images Workflow (`.github/workflows/build-images.yml`)

**Purpose**: Builds and publishes three Docker images to GitHub Container Registry

**Features**:
- Builds base Ansible image (`ansible-base:latest`)
- Builds test Ansible image (`ansible-test:latest`)
- Builds lint Ansible image (`ansible-lint:latest`)
- Automatic triggering on Dockerfile changes
- Manual trigger support
- Uses reusable workflow for consistency
- Multi-platform support with Docker Buildx
- Layer caching for faster builds

**Triggers**:
- Push to Dockerfile files
- Manual workflow dispatch

### Test Ansible Workflow (`.github/workflows/test-ansible.yml`)

**Purpose**: Validates Ansible code quality and syntax with smart dependency management

**Features**:
- **Smart Build Dependency**: Automatically waits for build workflow only when necessary
- Syntax validation for all roles and playbooks using ansible-lint
- Dry-run testing for all playbooks with `--check --diff`
- Fallback to standard Python image if custom image unavailable
- Parallel job execution when possible
- Automatic triggering on Ansible code changes

**Smart Dependency Management**:
- Checks if Dockerfile.test changed in the current push/PR
- Waits for build completion only when test image needs rebuilding
- Proceeds immediately if test image doesn't need updates
- Reduces unnecessary delays and improves pipeline efficiency

**Triggers**:
- Push to ansible directory
- Push to Dockerfile.test
- Pull requests to ansible directory
- Manual workflow dispatch

### Lint Ansible Workflow (`.github/workflows/lint-ansible.yml`)

**Purpose**: Performs code formatting and comprehensive linting with smart dependency management

**Features**:
- **Smart Build Dependency**: Automatically waits for build workflow only when necessary
- YAML formatting with Prettier
- YAML syntax validation with yamllint
- Ansible best practices validation with ansible-lint
- Fallback to standard Python image if custom image unavailable
- Automatic triggering on Ansible code changes

**Smart Dependency Management**:
- Checks if Dockerfile.lint changed in the current push/PR
- Waits for build completion only when lint image needs rebuilding
- Proceeds immediately if lint image doesn't need updates
- Optimizes pipeline performance with conditional waiting

**Triggers**:
- Push to ansible directory
- Push to Dockerfile.lint
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

## Smart Dependency Management

### How It Works

The test and lint workflows implement intelligent dependency management that optimizes CI/CD pipeline performance:

1. **Change Detection**: Checks if the relevant Dockerfile changed in the current push/PR
2. **Conditional Wait**: Only waits if the Docker image needs rebuilding
3. **Immediate Execution**: Proceeds immediately if no rebuild is needed
4. **Fallback Support**: Uses standard images if custom images are unavailable

### Benefits

- **Efficiency**: Eliminates unnecessary waiting when images don't need rebuilding
- **Reliability**: Ensures tests use the latest images when rebuilds are necessary
- **Performance**: Reduces overall pipeline execution time
- **Flexibility**: Works with any build workflow configuration
- **Robustness**: Graceful fallback when custom images are unavailable

### Example Scenarios

**Scenario 1: Image Needs Rebuilding**
```
1. User pushes changes to Dockerfile.test
2. Build workflow starts
3. User pushes changes to ansible/ directory
4. Test workflow detects Dockerfile.test changed
5. Test workflow waits for build completion
6. Test workflow proceeds with latest image
```

**Scenario 2: No Image Rebuild Needed**
```
1. User pushes changes to ansible/ directory only
2. Test workflow detects no Dockerfile changes
3. Test workflow proceeds immediately
4. Uses existing image from registry
```

**Scenario 3: Custom Image Unavailable**
```
1. Test workflow tries to pull custom image
2. Pull fails (e.g., first run, network issues)
3. Test workflow falls back to standard Python image
4. Installs required packages and proceeds
```

## Local Development

### Local Linting Script

The repository includes a local linting script for development:

```bash
# Run local linting (requires Docker)
./scripts/lint-local.sh
```

**Features**:
- Same linting tools as CI pipeline
- Docker-based execution for consistency
- YAML formatting with Prettier
- YAML syntax validation with yamllint
- Ansible best practices validation with ansible-lint

**Requirements**:
- Docker installed and running
- Script run from repository root

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
│       ├── test-ansible.yml          # Ansible code testing
│       ├── lint-ansible.yml          # Ansible code linting
│       ├── reusable-test-ansible.yml # Reusable test workflow
│       ├── reusable-build-images.yml # Reusable build workflow
│       ├── reusable-ansible-base.yml # Reusable ansible base workflow
│       └── deploy.yml                # Infrastructure deployment
├── ansible/
│   ├── images_jobs/     # GitLab CI jobs (legacy)
│   ├── test_jobs/       # GitLab CI jobs (legacy)
│   ├── jobs/           # GitLab CI jobs (legacy)
│   ├── playbooks/      # Ansible playbooks
│   ├── roles/          # Reusable Ansible roles
│   └── templates/      # Jinja2 templates
├── scripts/
│   └── lint-local.sh   # Local linting script
├── Dockerfile          # Base Ansible image
├── Dockerfile.test     # Ansible testing image
├── Dockerfile.lint     # Ansible linting image
├── .prettierrc         # Prettier configuration
├── .yamllint           # yamllint configuration
├── CONDITIONAL_DEPENDENCY_SOLUTION.md # Dependency solution documentation
├── LINTING.md          # Linting documentation
└── README.md           # This file
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

## Testing and Linting

The repository includes comprehensive testing and linting capabilities with smart dependency management:

### Syntax Testing
- **ansible-lint**: Validates all roles and playbooks for best practices
- **Automatic triggers**: Runs on changes to playbooks, roles, or test image
- **Manual execution**: Available for on-demand testing
- **Smart dependencies**: Waits for build workflow only when necessary

### Playbook Testing
- **Dry-run validation**: Uses `--check --diff` to simulate playbook execution
- **Dependency chain**: Runs after syntax validation
- **Safety checks**: Prevents accidental changes during testing

### Code Linting
- **Prettier**: YAML file formatting for consistency
- **yamllint**: YAML syntax validation and style checking
- **ansible-lint**: Ansible-specific best practices and syntax validation
- **Smart dependencies**: Waits for build workflow only when necessary

### Smart Dependency Features
- **Change-based detection**: Checks if relevant Dockerfiles changed
- **Conditional waiting**: Only waits when images need rebuilding
- **Parallel execution**: Runs tests/linting immediately when no build dependency exists
- **Fallback support**: Uses standard images when custom images unavailable

## Docker Images

### Base Ansible Image (`Dockerfile`)
- **Base**: Python 3.13 slim
- **Features**: SSH client, Docker CLI, rsync, curl, jq, OpenSSL
- **Purpose**: Main Ansible runner for deployment and automation
- **Registry**: `ghcr.io/${{ github.repository }}/ansible-base:latest`

### Test Ansible Image (`Dockerfile.test`)
- **Base**: Python 3.13 slim
- **Features**: ansible, ansible-lint
- **Purpose**: Code quality validation and testing
- **Registry**: `ghcr.io/${{ github.repository }}/ansible-test:latest`

### Lint Ansible Image (`Dockerfile.lint`)
- **Base**: Python 3.13 slim
- **Features**: ansible-lint, yamllint, prettier, nodejs, npm
- **Purpose**: Code formatting and comprehensive linting
- **Registry**: `ghcr.io/${{ github.repository }}/ansible-lint:latest`

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

### Local Development
```bash
# Run local linting
./scripts/lint-local.sh

# Check specific role
ansible-lint ansible/roles/my-role/

# Check specific playbook
ansible-lint ansible/playbooks/my-playbook.yml
```

### Testing with Smart Dependencies
The test and lint workflows automatically handle build dependencies:
- **When image needs rebuilding**: Waits for completion, then runs tests/linting
- **When image doesn't need rebuilding**: Proceeds immediately with existing images
- **When custom image unavailable**: Falls back to standard images with package installation

## Migration from GitLab CI

This repository has been migrated from GitLab CI/CD to GitHub Actions. See `CONDITIONAL_DEPENDENCY_SOLUTION.md` for detailed implementation documentation.

### Key Changes
- GitLab CI stages → GitHub Actions workflows
- GitLab Container Registry → GitHub Container Registry
- GitLab CI/CD variables → GitHub Secrets
- GitLab API → GitHub API
- Manual dependency management → Smart dependency with change detection

### New Features
- **Smart Dependencies**: Conditional waiting based on actual changes
- **Reusable Workflows**: Better code organization and maintainability
- **Fallback Support**: Graceful handling when custom images unavailable
- **Local Development**: Local linting script for development workflow
- **Comprehensive Linting**: Separate linting workflow with formatting and validation

## Contributing

1. Follow the existing role structure
2. Update documentation for new features
3. Test changes in a fork before submitting
4. Ensure all Ansible code passes linting and validation
5. Use the local linting script during development

## Security Features

- SSH key rotation
- Secure credential storage in GitHub Secrets
- Pre-flight validation for manual operations
- Manual approval for critical operations
- Encrypted communication with GitHub API
- Smart dependency management reduces attack surface

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

**Smart Dependency Issues**
- Check if Dockerfile changes are being detected correctly
- Verify workflow name matches exactly
- Review API permissions for GITHUB_TOKEN
- Check fallback behavior when custom images unavailable

### Debug Workflows
- Enable debug logging in workflow files
- Check workflow run logs in GitHub Actions
- Use `actions/checkout@v4` with `fetch-depth: 0` for full history
- Test local linting script for development issues
- Monitor GitHub API rate limits in workflow logs

## Performance Optimizations

### Smart Dependencies
- **Efficiency**: Tests/linting run immediately when no rebuild needed
- **Parallel Processing**: Multiple workflows can run simultaneously
- **Change Detection**: Only waits when actual changes require rebuilding
- **Fallback Support**: Reduces dependency on custom image availability

### Build Optimizations
- **Layer Caching**: Docker layer caching reduces build times
- **Multi-platform**: Parallel builds for different architectures
- **Registry Caching**: GitHub Container Registry optimizations

### Local Development
- **Local Scripts**: Fast local linting without CI overhead
- **Docker Consistency**: Same environment as CI pipeline
- **Immediate Feedback**: Quick validation during development

## License

This project is licensed under the MIT License. 