# SkiesDota GitHub Actions CI/CD Templates

A comprehensive GitHub Actions template repository for Ansible automation and infrastructure management. This repository provides reusable CI/CD workflows, Docker images, Ansible playbooks, roles, and infrastructure that can be included in other projects.

## Overview

This template repository contains:

- **Docker Images**: Four pre-built Ansible runner images for different CI/CD pipeline stages
- **GitHub Actions Workflows**: Reusable workflow templates for building, testing, linting, security scanning, and deployment
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
- `ci-cd.prod.yml`: Main production pipeline with smart change detection
- `auto-opencommit.yml`: Automatic commit message improvements
- `manual-security-scan.yml`: Comprehensive security scanning
- `reusable-ssh-key-setup.yml`: SSH key generation and distribution
- `reusable-opencommit.yml`: Reusable commit improvement workflow
- `reusable-deploy.yml`: Reusable deployment workflow

### Manual Operations
- `manual-security-scan.yml`: Full security scan with git history
- `reusable-ssh-key-setup.yml`: SSH key generation and distribution (manual trigger)

## Workflow Details

### Main Production Pipeline (`.github/workflows/ci-cd.prod.yml`)

**Purpose**: Comprehensive CI/CD pipeline with smart change detection and conditional execution

**Features**:
- **Smart Change Detection**: Automatically detects which files changed and runs appropriate jobs
- **Docker Image Building**: Builds four specialized Docker images:
  - `ansible-prod`: Main Ansible runner
  - `ansible-prod-test`: Testing environment
  - `ansible-prod-lint`: Linting tools
  - `ansible-prod-security-scan`: Security scanning tools
- **Conditional Job Execution**: Only runs jobs when relevant files change
- **Security Scanning**: Fast and comprehensive security scans with TruffleHog
- **Lint**: Ansible linting and validation
- **Testing**: Ansible syntax validation and dry-run testing
- **Fallback Support**: Uses standard images when custom images unavailable

**Triggers**:
- Push to `ansible/**/*` files
- Push to `Dockerfile*` files
- Pull requests to relevant paths
- Manual workflow dispatch

### Auto OpenCommit (`.github/workflows/auto-opencommit.yml`)

**Purpose**: Automatically improves commit messages using AI

**Features**:
- Uses OpenCommit with DeepSeek AI model
- Conventional commit format
- Emoji support
- Skip if commit message is already good
- Only runs on non-merge commits from non-forks

### Manual Security Scan (`.github/workflows/manual-security-scan.yml`)

**Purpose**: Comprehensive security scanning with git history

**Features**:
- Full repository scan with TruffleHog
- Git history scanning for secrets
- Manual trigger only
- Uses custom security scan image when available

### Reusable SSH Key Setup (`.github/workflows/reusable-ssh-key-setup.yml`)

**Purpose**: SSH key generation and distribution for infrastructure automation

**Features**:
- Generates SSH key pairs
- Distributes public keys to target servers
- Uploads private keys to GitHub Secrets
- Supports both manual trigger and reusable workflow calls
- Fallback to standard Python image when custom image unavailable

## Smart Dependency Management

### How It Works

The main production pipeline implements intelligent dependency management that optimizes CI/CD pipeline performance:

1. **Change Detection**: Detects which specific files changed in the current push/PR
2. **Conditional Execution**: Only runs jobs when relevant files change
3. **Image Availability**: Tries to use custom images first, falls back to standard images
4. **Parallel Processing**: Runs independent jobs in parallel when possible

### Benefits

- **Efficiency**: Eliminates unnecessary job execution
- **Reliability**: Ensures all necessary checks are performed
- **Performance**: Reduces overall pipeline execution time
- **Flexibility**: Works with any build configuration
- **Robustness**: Graceful fallback when custom images are unavailable

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
- `OCO_API_KEY`: OpenCommit API key for commit message improvements

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
   - Go to Actions → Reusable SSH Key Setup
   - Click "Run workflow"
   - Provide target hosts, user, and password
   - Click "Run workflow"
3. **Store Generated Key**: The workflow will generate and distribute SSH keys
4. **Update Secrets**: Add the generated private key as `SSH_PRIVATE_KEY` secret
5. **Remove Password Secret**: Delete `ANSIBLE_HOSTS_PASSWORD` after successful setup

## Directory Structure

```
├── .github/
│   ├── actions/
│   │   ├── build-image/           # Docker image building action
│   │   ├── detect-changes/        # Change detection action
│   │   ├── pull-image/            # Image availability check action
│   │   ├── security-scan/         # Security scanning action
│   │   └── setup-docker/          # Docker setup action
│   ├── scripts/                   # CI/CD scripts
│   └── workflows/
│       ├── ci-cd.prod.yml         # Main production pipeline
│       ├── auto-opencommit.yml    # Auto commit improvements
│       ├── manual-security-scan.yml # Manual security scan
│       ├── reusable-opencommit.yml # Reusable commit workflow
│       ├── reusable-deploy.yml    # Reusable deploy workflow
│       ├── reusable-ssh-key-setup.yml # Reusable SSH setup
│       └── README.md              # Workflows documentation
├── ansible/
│   ├── collections/               # Ansible collections requirements
│   ├── jobs/                      # GitLab CI jobs (legacy)
│   ├── playbooks/                 # Ansible playbooks
│   ├── roles/                     # Reusable Ansible roles
│   ├── templates/                 # Jinja2 templates
│   ├── ansible.cfg                # Ansible configuration
│   └── README.md                  # Ansible documentation
├── scripts/
│   └── lint-local.sh              # Local linting script
├── Dockerfile.prod                # Main Ansible image
├── Dockerfile.prod.test           # Testing image
├── Dockerfile.prod.format-lint    # Formatting and linting image
├── Dockerfile.prod.security-scan  # Security scanning image
├── .prettierrc                    # Prettier configuration
├── LINTING.md                     # Linting documentation
└── README.md                      # This file
```

## Available Roles

- **deploy**: Application deployment and synchronization
- **docker**: Docker installation and configuration
- **docker_compose_plugin**: Docker Compose plugin management
- **environment**: Environment file management
- **firewall**: UFW firewall configuration
- **github_variable**: GitHub variable management
- **mongodb**: MongoDB replica set and index setup
- **ssh**: SSH key generation and agent setup
- **ssl**: SSL certificate management
- **synchronize**: File synchronization utilities

## Testing and Linting

The repository includes comprehensive testing and linting capabilities:

### Syntax Testing
- **ansible-lint**: Validates all roles and playbooks for best practices
- **Automatic triggers**: Runs on changes to playbooks, roles, or test image
- **Manual execution**: Available for on-demand testing
- **Smart dependencies**: Only runs when relevant files change

### Playbook Testing
- **Dry-run validation**: Uses `--check --diff` to simulate playbook execution
- **Dependency chain**: Runs after syntax validation
- **Safety checks**: Prevents accidental changes during testing

### Code Linting
- **ansible-lint**: Ansible-specific best practices and syntax validation
- **Smart dependencies**: Only runs when relevant files change

## Docker Images

### Main Ansible Image (`Dockerfile.prod`)
- **Base**: Python 3.13 slim
- **Features**: SSH client, Docker CLI, rsync, curl, jq, OpenSSL
- **Purpose**: Main Ansible runner for deployment and automation
- **Registry**: `ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod:latest`

### Test Ansible Image (`Dockerfile.prod.test`)
- **Base**: Python 3.13 slim
- **Features**: ansible, ansible-lint
- **Purpose**: Code quality validation and testing
- **Registry**: `ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod-test:latest`

### Lint Image (`Dockerfile.prod.lint`)
- **Base**: Python 3.13 slim
- **Features**: ansible-lint
- **Purpose**: Code linting and validation
- **Registry**: `ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod-lint:latest`

### Security Scan Image (`Dockerfile.prod.security-scan`)
- **Base**: Alpine 3.19
- **Features**: TruffleHog, git, bash
- **Purpose**: Security scanning and secret detection
- **Registry**: `ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod-security-scan:latest`

## Usage Examples

### Manual Deployment
1. Go to Actions tab in GitHub
2. Select "Reusable Deploy Infrastructure" workflow
3. Click "Run workflow"
4. Choose playbook type (bootstrap/deploy/ssh-key-setup)
5. Click "Run workflow"

### Automatic Deployment
Set `AUTO_DEPLOY` secret to "true" to enable automatic deployment on main branch pushes.

### SSH Key Setup
1. Configure `ANSIBLE_HOSTS` and `ANSIBLE_HOSTS_PASSWORD` secrets
2. Run "Reusable SSH Key Setup" workflow manually
3. Provide target hosts, user, and password
4. After successful run, remove `ANSIBLE_HOSTS_PASSWORD` secret

### Local Development
```bash
# Run local linting
./scripts/lint-local.sh

# Check specific role
ansible-lint ansible/collections/roles/my-role/

# Check specific playbook
ansible-lint ansible/playbooks/my-playbook.yml
```

### Security Scanning
```bash
# Manual comprehensive scan
# Go to Actions → Manual Full Security Scan → Run workflow

# Fast scan (automatic on changes)
# Triggered automatically by main pipeline
```

## Migration from GitLab CI

This repository has been migrated from GitLab CI/CD to GitHub Actions. The migration includes:

### Key Changes
- GitLab CI stages → GitHub Actions workflows
- GitLab Container Registry → GitHub Container Registry
- GitLab CI/CD variables → GitHub Secrets
- GitLab API → GitHub API
- Manual dependency management → Smart dependency with change detection

### New Features
- **Smart Dependencies**: Conditional execution based on actual changes
- **Reusable Workflows**: Better code organization and maintainability
- **Fallback Support**: Graceful handling when custom images unavailable
- **Local Development**: Local linting script for development workflow
- **Comprehensive Security**: Dedicated security scanning workflow
- **Auto Commit Improvements**: AI-powered commit message enhancements

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
- Comprehensive security scanning with TruffleHog
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
- Check if file changes are being detected correctly
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
- **Efficiency**: Jobs run only when relevant files change
- **Parallel Processing**: Multiple jobs can run simultaneously
- **Change Detection**: Only processes what actually changed
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