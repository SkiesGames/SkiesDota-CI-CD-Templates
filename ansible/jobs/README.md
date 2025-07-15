# Jobs (Legacy GitLab CI)

This directory contains the main GitLab CI job definitions for Ansible automation workflows. **Note: This is legacy content from the GitLab CI migration. The project now uses GitHub Actions workflows.**

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

## Migration to GitHub Actions

This project has been migrated from GitLab CI to GitHub Actions. The equivalent functionality is now available in:

### GitHub Actions Workflows
- **Main Pipeline**: `.github/workflows/ci-cd.prod.yml`
- **SSH Key Setup**: `.github/workflows/reusable-ssh-key-setup.yml`
- **Deployment**: `.github/workflows/reusable-deploy.yml`

### Key Differences

| Aspect | GitLab CI (Legacy) | GitHub Actions (Current) |
|--------|-------------------|-------------------------|
| **Job Definition** | YAML in `.gitlab-ci.yml` | YAML in `.github/workflows/` |
| **Container Registry** | GitLab Container Registry | GitHub Container Registry |
| **Variables** | GitLab CI/CD Variables | GitHub Secrets |
| **API Integration** | GitLab API | GitHub API |
| **Dependencies** | Manual stage management | Smart dependency detection |

### Migration Benefits

1. **Smart Dependencies**: Conditional execution based on file changes
2. **Reusable Workflows**: Better code organization and maintainability
3. **Fallback Support**: Graceful handling when custom images unavailable
4. **Local Development**: Local linting script for development workflow
5. **Comprehensive Security**: Dedicated security scanning workflow
6. **Auto Commit Improvements**: AI-powered commit message enhancements

### Migration Guide

To migrate from GitLab CI to GitHub Actions:

1. **Replace job includes** with workflow calls
2. **Convert variables** to GitHub Secrets
3. **Update API tokens** for GitHub integration
4. **Modify trigger conditions** to use GitHub Actions syntax
5. **Test workflows** in a fork before switching

### Example Migration

**GitLab CI (Legacy):**
```yaml
include:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs.yml'

variables:
  ANSIBLE_HOSTS: "192.168.1.1,192.168.1.2"
  ANSIBLE_USER: "ubuntu"
```

**GitHub Actions (Current):**
```yaml
jobs:
  deploy:
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-deploy.yml@main
    with:
      target_hosts: "192.168.1.1,192.168.1.2"
      target_user: "ubuntu"
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
```

## Legacy Support

While the project has migrated to GitHub Actions, the GitLab CI configuration is maintained for:

- **Backward compatibility** with existing deployments
- **Reference documentation** for migration
- **Fallback option** if needed
- **Learning purposes** for GitLab CI patterns

## Future Development

All new development should use GitHub Actions workflows:

- **New features** should be implemented in GitHub Actions
- **Bug fixes** should prioritize GitHub Actions workflows
- **Documentation** should focus on GitHub Actions usage
- **Testing** should use GitHub Actions environments

## Troubleshooting Legacy Jobs

### Common GitLab CI Issues

1. **Job not found**: Check project path and file references
2. **Permission denied**: Verify GitLab API token permissions
3. **Variable not found**: Ensure GitLab CI/CD variables are set
4. **Docker image not found**: Verify image exists in GitLab registry

### Migration Issues

1. **Workflow not found**: Check repository name and path
2. **Secret not found**: Ensure GitHub Secrets are configured
3. **API permission denied**: Verify GitHub token permissions
4. **Trigger conditions**: Update to GitHub Actions syntax

## Best Practices for Migration

1. **Test thoroughly** in a fork before switching
2. **Document changes** for team reference
3. **Maintain backward compatibility** during transition
4. **Update documentation** to reflect new workflows
5. **Train team members** on GitHub Actions usage 