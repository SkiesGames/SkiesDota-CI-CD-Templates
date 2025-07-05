# SkiesDotaGitlab-CI-Templates

A comprehensive GitLab CI template repository for Ansible automation and infrastructure management. This repository provides reusable CI/CD jobs, Docker images, Ansible playbooks, roles, and infrastructure that can be included in other projects.

## Overview

This template repository contains:

- **Docker Images**: Pre-built Ansible runner images for CI/CD pipelines
- **CI/CD Jobs**: Reusable GitLab CI job templates for deployment and automation
- **Test Jobs**: Ansible code quality validation and syntax checking
- **Ansible Playbooks**: Infrastructure automation playbooks
- **Ansible Roles**: Modular, reusable Ansible roles for common tasks
- **Templates**: Jinja2 templates for dynamic configuration generation

## Quick Start

Include this template in your project's `.gitlab-ci.yml`:

```yaml
include:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/common.gitlab-ci.yml'
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs.yml'
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs/ssh_key_setup.yml'
```

## Available Jobs

### Core Jobs
- `bootstrap`: Initial server setup and configuration (manual trigger)
- `deploy`: Application deployment and updates (auto on main branch or manual)
- `add_ssh_key`: SSH key generation and distribution (manual trigger)

### Image Building Jobs
- `build_base_ansible_image`: Builds the base Ansible runner image
- `build_ansible_lint_image`: Builds the Ansible lint testing image

### Test Jobs
- `test_ansible_syntax`: Validates Ansible roles and playbooks using ansible-lint
- `test_playbooks`: Performs dry-run checks on all playbooks with --check --diff

## Shared Templates

### Base Templates
- `.base_ansible`: Base template for all Ansible jobs with SSH and inventory setup
- `.base_image`: Base template for Docker image building jobs with caching and registry integration
- `.base_test_role_playbook`: Base template for Ansible testing jobs

### Shared Blocks
- `.common_before_script`: Sets up SSH, Ansible, and dependencies
- `.generate_inventory`: Generates Ansible inventory files
- `.execute_playbook`: Executes Ansible playbooks with safety checks

## Initial SSH Setup

For first-time SSH key setup, configure these GitLab CI/CD variables:

1. `ANSIBLE_HOSTS`: Multi-line list of host IPs
2. `ANSIBLE_HOSTS_PASSWORD`: Multi-line list of corresponding passwords
3. `ANSIBLE_USER`: SSH user for all hosts
4. `GITLAB_API_TOKEN`: For uploading generated keys to GitLab variables

Example:
```
ANSIBLE_HOSTS:
192.168.1.1
192.168.1.2

ANSIBLE_HOSTS_PASSWORD:
password1
password2
```

After successful setup, `ANSIBLE_HOSTS_PASSWORD` can be removed as subsequent runs use SSH key authentication.

## Directory Structure

```
├── ansible/
│   ├── images_jobs/     # Docker image building jobs
│   │   └── jobs.yml     # Image building jobs with base template
│   ├── test_jobs/       # Ansible testing and validation jobs
│   │   └── jobs.yml     # Test jobs for syntax and playbook validation
│   ├── jobs/           # Main CI/CD job definitions
│   │   ├── jobs.yml    # Core deployment jobs
│   │   └── ssh_key_setup.yml  # SSH key management
│   ├── playbooks/      # Ansible playbooks
│   ├── roles/          # Reusable Ansible roles
│   └── templates/      # Jinja2 templates
├── Dockerfile          # Base Ansible image
├── Dockerfile.ansible-lint  # Ansible lint testing image
├── common.gitlab-ci.yml # Shared CI/CD templates and anchors
└── .gitlab-ci.yml      # Main CI/CD pipeline
```

## Available Roles

- **deploy**: Application deployment and synchronization
- **docker**: Docker installation and configuration
- **docker-compose-plugin**: Docker Compose plugin management
- **environment**: Environment file management
- **firewall**: UFW firewall configuration
- **gitlab_variable**: GitLab variable management
- **mongodb**: MongoDB replica set and index setup
- **ssh**: SSH key generation and agent setup
- **ssl**: SSL certificate management
- **synchronize**: File synchronization utilities

## Testing

The repository includes comprehensive testing capabilities:

### Syntax Testing
- **ansible-lint**: Validates all roles and playbooks for best practices
- **Automatic triggers**: Runs on changes to playbooks, roles, or test image
- **Manual execution**: Available for on-demand testing

### Playbook Testing
- **Dry-run validation**: Uses `--check --diff` to simulate playbook execution
- **Dependency chain**: Runs after syntax validation
- **Safety checks**: Prevents accidental changes during testing

## Contributing

1. Follow the existing role structure
2. Update documentation for new features
3. Test changes in a fork before submitting
4. Ensure all Ansible code passes linting and validation

## License

This project is licensed under the MIT License.
