# SkiesDota GitHub Actions CI/CD Templates

A comprehensive GitHub Actions template repository for Ansible automation and infrastructure management. Provides reusable CI/CD workflows, Docker images, Ansible playbooks, and infrastructure templates.

## Quick Start

1. **Fork or Clone**: Copy this repository to your GitHub account
2. **Configure Secrets**: Set up required GitHub Secrets (see Configuration section)
3. **Customize**: Modify workflows and playbooks for your specific needs
4. **Deploy**: Use the provided workflows for infrastructure automation

## Available Workflows

### Core Workflows
- `ci-cd.prod.yml`: Main production pipeline with smart change detection
- `reusable-ansible.yml`: Reusable Ansible playbook execution workflow
- `reusable-ssh-key-setup.yml`: SSH key generation and distribution
- `auto-opencommit.yml`: Automatic commit message improvements
- `manual-security-scan.yml`: Comprehensive security scanning

## Workflow Details

### Main Production Pipeline (`ci-cd.prod.yml`)

**Features**: Smart change detection, conditional job execution, Docker image building, security scanning, linting, testing.

**Triggers**: Push to `ansible/**/*` or `Dockerfile*` files, pull requests, manual dispatch.

### Reusable Ansible Workflow (`reusable-ansible.yml`)

Execute any Ansible playbook from calling repository or template repository.

**Usage Example**:
```yaml
jobs:
  run-playbook:
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
    with:
      playbook: playbooks/bootstrap-k3s.yml
      use_template_playbook: true
      ansible_extra_env_json: '{"NUMBER_OF_CONTROL_PLANE_NODES": "3"}'
    secrets:
      ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}
      ANSIBLE_USER: ${{ secrets.ANSIBLE_USER }}
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

## Available Playbooks

### bootstrap-k3s.yml

Bootstraps a High Availability K3s Kubernetes cluster with configurable control plane nodes.

**Features**:
- High Availability (HA) cluster configuration
- Configurable control plane node count
- Automated cluster bootstrapping
- Uses xanmanning.k3s role for reliable deployment

**Configuration**:

By default, all nodes are configured as control plane nodes (HA setup). You can specify the number of control plane nodes using the `NUMBER_OF_CONTROL_PLANE_NODES` environment variable:

- **If not set or empty**: All nodes become control plane nodes (backward compatible)
- **If set to N**: First N nodes become control plane nodes, remaining nodes become workers

**Usage Example**:
```yaml
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
with:
  playbook: playbooks/bootstrap-k3s.yml
  use_template_playbook: true
  ansible_extra_env_json: '{"NUMBER_OF_CONTROL_PLANE_NODES": "3"}'
secrets:
  ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}  # e.g., 5 hosts
  ANSIBLE_USER: ${{ secrets.ANSIBLE_USER }}
  SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
  K3S_TOKEN: ${{ secrets.K3S_TOKEN }}
```

**Result**: With 5 hosts and `NUMBER_OF_CONTROL_PLANE_NODES=3`:
- First 3 hosts (by order in ANSIBLE_HOSTS) → Control plane nodes
- Remaining 2 hosts → Worker nodes

**Requirements**:
- Target servers accessible via SSH
- Sufficient resources for K3s nodes
- xanmanning.k3s role installed (via ansible/requirements.yml)

**Environment Variables**:
- `ANSIBLE_HOSTS`: Target host IPs for K3s cluster (order matters)
- `ANSIBLE_USER`: SSH username
- `K3S_TOKEN`: Cluster token (from GitHub Secrets)
- `NUMBER_OF_CONTROL_PLANE_NODES`: (Optional) Number of control plane nodes

### Other Playbooks
- `generate_inventory.yml`: Generate dynamic Ansible inventory from environment variables
- `ssh_key_set_up.yml`: SSH key lifecycle management

See `ansible/playbooks/README.md` for detailed documentation.

## Smart Dependency Management

The main production pipeline implements intelligent dependency management:
1. **Change Detection**: Detects which files changed
2. **Conditional Execution**: Only runs jobs when relevant files change
3. **Image Availability**: Tries custom images first, falls back to standard images
4. **Parallel Processing**: Runs independent jobs in parallel

**Benefits**: Eliminates unnecessary job execution, reduces pipeline time, graceful fallback support.

## Configuration

### Required GitHub Secrets

Configure in Settings → Secrets and variables → Actions:

**Core Secrets**:
- `ANSIBLE_HOSTS`: Multi-line list of target host IPs
- `ANSIBLE_USER`: SSH username for all hosts
- `SSH_PRIVATE_KEY`: Private SSH key for authentication (after initial setup)
- `K3S_TOKEN`: K3s cluster token (for bootstrap-k3s.yml)

**Initial Setup Secrets** (temporary):
- `ANSIBLE_HOSTS_PASSWORD`: Multi-line list of host passwords (for first-time setup)
- `GITHUB_TOKEN`: GitHub Personal Access Token with repo scope

**Optional Secrets**:
- `AUTO_DEPLOY`: Set to "true" for automatic deployment on main branch
- `OCO_API_KEY`: OpenCommit API key for commit message improvements

### Example Secret Configuration

```
ANSIBLE_HOSTS:
192.168.1.1
192.168.1.2
192.168.1.3

ANSIBLE_USER: ubuntu
K3S_TOKEN: your-cluster-token-here
```

## Initial SSH Setup

1. Configure `ANSIBLE_HOSTS`, `ANSIBLE_HOSTS_PASSWORD`, and `ANSIBLE_USER` secrets
2. Run "Reusable SSH Key Setup" workflow manually
3. Store generated private key as `SSH_PRIVATE_KEY` secret
4. Delete `ANSIBLE_HOSTS_PASSWORD` after successful setup

## Local Development

### Local Linting Script

```bash
./scripts/format-lint-local.sh
```

**Features**: Same linting tools as CI pipeline, Docker-based execution, YAML formatting with Prettier, syntax validation with yamllint, Ansible best practices with ansible-lint.

**Requirements**: Docker installed and running, run from repository root.

## Directory Structure

```
├── .github/
│   ├── actions/          # Docker image building, change detection, security scan, etc.
│   └── workflows/        # CI/CD workflow definitions
├── ansible/
│   ├── playbooks/        # Ansible playbooks (bootstrap-k3s, generate_inventory, etc.)
│   ├── templates/        # Jinja2 templates
│   └── ansible.cfg       # Ansible configuration
├── scripts/
│   └── format-lint-local.sh     # Local linting script
├── Dockerfile.ansible.prod      # Main Ansible image (runtime, testing, and linting)
└── README.md             # This file
```

## Testing and Linting

### Linting (ansible-lint)
- Validates YAML syntax and Ansible best practices
- Automatic triggers on Ansible file changes
- Manual execution available

### Playbook Testing
- Uses `ansible-playbook --check --diff`
- Validates playbook execution without making changes
- Runs after linting passes

## Docker Images

### Main Ansible Image (`Dockerfile.ansible.prod`)
- **Base**: Python 3.13 slim
- **Features**: Ansible with all collections/roles from `requirements.yml`, kubectl, helm, SSH client, rsync, curl, jq, ansible-lint
- **Registry**: `ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod:latest`
- **Usage**: Used for both runtime execution, testing, and linting of Ansible playbooks

## Usage Examples

### Bootstrap K3s Cluster

```yaml
- name: Bootstrap K3s with 3 control plane nodes
  uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
  with:
    playbook: playbooks/bootstrap-k3s.yml
    use_template_playbook: true
    ansible_extra_env_json: '{"NUMBER_OF_CONTROL_PLANE_NODES": "3"}'
  secrets:
    ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}
    ANSIBLE_USER: ${{ secrets.ANSIBLE_USER }}
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
    K3S_TOKEN: ${{ secrets.K3S_TOKEN }}
```

### SSH Key Setup

1. Configure `ANSIBLE_HOSTS` and `ANSIBLE_HOSTS_PASSWORD` secrets
2. Run "Reusable SSH Key Setup" workflow manually
3. Remove `ANSIBLE_HOSTS_PASSWORD` after successful setup

## Troubleshooting

### Common Issues

**Container Registry Access**
```bash
docker login ghcr.io -u $GITHUB_USERNAME -p $GITHUB_TOKEN
```

**SSH Key Issues**
```bash
ssh -i ~/.ssh/ci_id_ed25519 $ANSIBLE_USER@$TARGET_HOST
```

**Workflow Failures**
- Check workflow run logs in GitHub Actions
- Verify all required secrets are configured
- Ensure target hosts are accessible

**Node Ordering in K3s Bootstrap**
- Nodes are ordered as they appear in `ANSIBLE_HOSTS` secret
- First N nodes (where N = `NUMBER_OF_CONTROL_PLANE_NODES`) become control plane
- Remaining nodes become workers

## Security Features

- SSH key rotation support
- Secure credential storage in GitHub Secrets
- Pre-flight validation for manual operations
- Comprehensive security scanning with TruffleHog
- Encrypted communication with GitHub API

## License

This project is licensed under the MIT License.
