# Jobs

This directory contains the main GitLab CI job definitions for Ansible automation workflows.

## Available Jobs

### Core Jobs (jobs.yml)

#### bootstrap
Initial server setup and configuration job.

**Features:**
- Extends `.base_ansible` template
- Runs bootstrap playbook
- Manual trigger only
- Includes pre-flight checks for manual runs

**Variables:**
- `playbook_path`: ansible/playbooks/bootstrap.yml
- `manual_job`: true

#### deploy
Application deployment and updates job.

**Features:**
- Extends `.base_ansible` template
- Runs deploy playbook
- Automatic deployment on main branch when `AUTO_DEPLOY=true`
- Manual trigger available
- Pre-flight checks for manual runs

**Variables:**
- `playbook_path`: ansible/playbooks/deploy.yml
- `manual_job`: false (auto) / true (manual)

**Rules:**
- Auto-deploy: `$CI_COMMIT_BRANCH == "main" && $AUTO_DEPLOY == "true"`
- Manual: Always available

### SSH Key Setup (ssh_key_setup.yml)

#### add_ssh_key
SSH key generation and distribution job.

**Features:**
- Generates ephemeral SSH keys
- Uploads keys to target servers
- Stores private key in GitLab variables
- Initial setup for password-based authentication

**Variables:**
- `playbook_path`: ansible/playbooks/ssh_key_set_up.yml
- `initial_setup`: true

**Required Variables:**
- `ANSIBLE_HOSTS`: Target host IPs
- `ANSIBLE_HOSTS_PASSWORD`: Host passwords
- `ANSIBLE_USER`: SSH username
- `GITLAB_API_TOKEN`: GitLab API access

## Base Template (.base_ansible)

Shared configuration for all Ansible jobs:

- **Image**: `$CI_REGISTRY_IMAGE/ansible:latest`
- **Before Script**: SSH setup and inventory generation
- **Common Tasks**: Standardized Ansible execution

## Job Dependencies

All jobs require:
- Built Docker images (from `images_jobs/`)
- Proper SSH configuration
- Target host access
- GitLab CI/CD variables

## Usage

Include in your project's `.gitlab-ci.yml`:

```yaml
include:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs.yml'
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs/ssh_key_setup.yml'
```

## Job Execution Flow

1. **SSH Setup**: Configure SSH agent and keys
2. **Inventory Generation**: Create dynamic inventory files
3. **Pre-flight Check**: Dry-run for manual jobs
4. **Playbook Execution**: Run Ansible playbooks
5. **Result Display**: Show execution results

## Security Features

- SSH key rotation
- Secure credential storage
- Pre-flight validation
- Manual approval for critical operations 