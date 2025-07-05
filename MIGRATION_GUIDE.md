# Migration Guide: GitLab CI/CD to GitHub Actions

This guide provides step-by-step instructions for migrating your Ansible infrastructure automation project from GitLab CI/CD to GitHub Actions.

## Overview

The migration involves converting GitLab CI stages and jobs to GitHub Actions workflows while maintaining equivalent functionality for:
- Docker image building
- Ansible code testing
- Infrastructure deployment
- SSH key management

## Prerequisites

1. **GitHub Repository**: Create a new repository on GitHub
2. **GitHub Personal Access Token**: For API access (if using SSH key upload)
3. **GitHub Container Registry**: Enable for Docker image storage

## Migration Steps

### 1. Repository Setup

```bash
# Clone your existing GitLab repository
git clone <gitlab-repo-url>
cd <repository-name>

# Add GitHub as a new remote
git remote add github <github-repo-url>

# Push to GitHub
git push -u github main
```

### 2. GitHub Secrets Configuration

Configure the following secrets in your GitHub repository (Settings → Secrets and variables → Actions):

#### Required Secrets
- `ANSIBLE_HOSTS`: Multi-line list of target host IPs
- `ANSIBLE_USER`: SSH username for all hosts
- `SSH_PRIVATE_KEY`: Private SSH key for authentication (after initial setup)

#### Initial Setup Secrets (temporary)
- `ANSIBLE_HOSTS_PASSWORD`: Multi-line list of host passwords (for first-time setup)
- `GITHUB_TOKEN`: GitHub Personal Access Token with repo scope

#### Optional Secrets
- `AUTO_DEPLOY`: Set to "true" to enable automatic deployment on main branch

### 3. File Structure Changes

The migration creates the following new structure:

```
├── .github/
│   └── workflows/
│       ├── build-images.yml      # Docker image building
│       ├── test-ansible.yml      # Ansible code testing
│       └── deploy.yml           # Infrastructure deployment
├── ansible/
│   ├── roles/
│   │   ├── github_variable/     # New: GitHub API integration
│   │   └── gitlab_variable/     # Old: Can be removed
│   └── playbooks/
│       └── ssh_key_set_up.yml   # Updated to use GitHub role
├── Dockerfile                   # Updated for GitHub Container Registry
├── Dockerfile.test             # New: Testing image
└── MIGRATION_GUIDE.md          # This guide
```

### 4. Workflow Migration Details

#### Build Images Workflow (`.github/workflows/build-images.yml`)
**GitLab Equivalent**: `ansible/images_jobs/jobs.yml`

**Key Changes**:
- Uses GitHub Container Registry (`ghcr.io`)
- Leverages GitHub Actions caching
- Automatic metadata extraction
- Multi-platform support with Buildx

**Features**:
- Builds base Ansible image (`ansible:latest`)
- Builds test Ansible image (`ansible-test:latest`)
- Automatic triggering on Dockerfile changes
- Manual trigger support

#### Test Ansible Workflow (`.github/workflows/test-ansible.yml`)
**GitLab Equivalent**: `ansible/test_jobs/jobs.yml`

**Key Changes**:
- Uses Python setup action instead of Docker image
- Direct ansible-lint installation
- Parallel job execution

**Features**:
- Syntax validation for all roles and playbooks
- Dry-run testing for all playbooks
- Automatic triggering on Ansible code changes
- Manual trigger support

#### Deploy Workflow (`.github/workflows/deploy.yml`)
**GitLab Equivalent**: `ansible/jobs/jobs.yml` + `ansible/jobs/ssh_key_setup.yml`

**Key Changes**:
- Uses workflow_dispatch with input parameters
- Conditional job execution based on inputs
- GitHub Container Registry image usage

**Features**:
- Bootstrap deployment (manual)
- Auto-deploy on main branch (configurable)
- SSH key setup (manual)
- Pre-flight checks for manual runs

### 5. Role Updates

#### New GitHub Variable Role
**File**: `ansible/roles/github_variable/`

**Purpose**: Replaces GitLab variable management with GitHub API integration

**Features**:
- Encrypts SSH keys using GitHub's public key
- Uploads secrets to GitHub repository
- Secure API communication

#### Updated SSH Key Setup
**File**: `ansible/playbooks/ssh_key_set_up.yml`

**Changes**:
- Uses `github_variable` role instead of `gitlab_variable`
- Maintains same functionality with GitHub API

### 6. Docker Image Updates

#### Base Image (Dockerfile)
**Changes**:
- Added OpenSSL for GitHub API encryption
- Updated Docker credential store to `ghcr`
- Maintains all existing functionality

#### Test Image (Dockerfile.test)
**New**: Lightweight image for testing
**Features**:
- Python 3.13 slim base
- Ansible and ansible-lint only
- Optimized for testing workflows

### 7. Environment Variables Mapping

| GitLab CI Variable | GitHub Actions Secret | Purpose |
|-------------------|---------------------|---------|
| `$CI_REGISTRY_IMAGE` | `${{ github.repository }}` | Container registry path |
| `$CI_REGISTRY_USER` | `${{ github.actor }}` | Registry username |
| `$CI_REGISTRY_PASSWORD` | `${{ secrets.GITHUB_TOKEN }}` | Registry password |
| `$CI_PROJECT_ID` | `${{ github.repository }}` | Project identifier |
| `$CI_COMMIT_BRANCH` | `${{ github.ref_name }}` | Current branch |
| `$CI_JOB_MANUAL` | `${{ github.event_name == 'workflow_dispatch' }}` | Manual trigger flag |

### 8. Usage Examples

#### Manual Deployment
1. Go to Actions tab in GitHub
2. Select "Deploy Infrastructure" workflow
3. Click "Run workflow"
4. Choose playbook type (bootstrap/deploy/ssh-key-setup)
5. Click "Run workflow"

#### Automatic Deployment
Set `AUTO_DEPLOY` secret to "true" to enable automatic deployment on main branch pushes.

#### SSH Key Setup
1. Configure `ANSIBLE_HOSTS` and `ANSIBLE_HOSTS_PASSWORD` secrets
2. Run "Deploy Infrastructure" workflow manually
3. Select "ssh-key-setup" option
4. After successful run, remove `ANSIBLE_HOSTS_PASSWORD` secret

### 9. Testing the Migration

#### Pre-Migration Checklist
- [ ] All secrets configured in GitHub
- [ ] GitHub Container Registry enabled
- [ ] Repository permissions set correctly
- [ ] SSH keys available (if using existing setup)

#### Post-Migration Verification
1. **Build Images**: Trigger build-images workflow manually
2. **Test Code**: Push changes to trigger test workflow
3. **Deploy**: Run deployment workflow manually
4. **Verify**: Check that all functionality works as expected

### 10. Rollback Plan

If issues arise during migration:

1. **Keep GitLab Repository**: Maintain as backup
2. **Gradual Migration**: Test workflows before full switch
3. **Dual Setup**: Run both systems in parallel initially
4. **Documentation**: Keep GitLab CI files for reference

### 11. Troubleshooting

#### Common Issues

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

**GitHub API Limits**
- Use Personal Access Token with appropriate scopes
- Monitor API rate limits
- Implement retry logic if needed

#### Debug Workflows
- Enable debug logging in workflow files
- Check workflow run logs in GitHub Actions
- Use `actions/checkout@v4` with `fetch-depth: 0` for full history

### 12. Performance Optimizations

#### Caching
- GitHub Actions provides built-in caching
- Docker layer caching in Container Registry
- Ansible fact caching in workflows

#### Parallelization
- Jobs can run in parallel when possible
- Matrix builds for multiple environments
- Conditional job execution

### 13. Security Considerations

#### Secrets Management
- All sensitive data stored in GitHub Secrets
- Secrets are encrypted and masked in logs
- No hardcoded credentials in workflows

#### Access Control
- Repository permissions control workflow access
- Branch protection rules for main branch
- Required reviews for critical deployments

#### Container Security
- Base images from official sources
- Regular security updates
- Minimal attack surface in containers

## Conclusion

This migration maintains all existing functionality while leveraging GitHub Actions' advanced features. The new setup provides:

- **Better Integration**: Native GitHub ecosystem integration
- **Enhanced Security**: Improved secrets management
- **Better Performance**: Advanced caching and parallelization
- **Easier Maintenance**: Simplified workflow management

For questions or issues during migration, refer to the GitHub Actions documentation or create issues in the repository. 