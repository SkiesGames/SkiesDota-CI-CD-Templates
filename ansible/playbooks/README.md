# Ansible Playbooks

This directory contains Ansible playbooks for setting up CI/CD environments, managing SSH keys, and generating dynamic configurations.

## Playbooks

### bootstrap-k3s.yml
Bootstraps a High Availability K3s Kubernetes cluster.

**Purpose**: Sets up a production-ready HA K3s cluster on target servers

**Features:**
- High Availability (HA) cluster configuration
- All nodes configured as server nodes
- Automated cluster bootstrapping
- Uses xanmanning.k3s role for reliable deployment

**Usage:**
```yaml
# In GitHub Actions workflow
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
with:
  playbook: playbooks/bootstrap-k3s.yml
  use_template_playbook: true
secrets:
  ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}
  ANSIBLE_USER: ${{ secrets.ANSIBLE_USER }}
  SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

**Requirements:**
- Target servers must be accessible via SSH
- Sufficient resources for K3s server nodes
- xanmanning.k3s role installed (via ansible/requirements.yml)

**Environment Variables:**
- `ANSIBLE_HOSTS`: Target host IPs for K3s cluster
- `ANSIBLE_USER`: SSH username

### setup_ci_env.yml
Sets up the CI/CD environment by configuring SSH agent and environment.

**Purpose**: Prepares the CI/CD environment for Ansible operations

**Features:**
- SSH agent setup and configuration
- SSH key management
- Known hosts configuration
- Environment preparation for automation

**Usage:**
```bash
ansible-playbook setup_ci_env.yml
```

**Environment Variables:**
- `SSH_PRIVATE_KEY`: Private SSH key for authentication
- `ANSIBLE_HOSTS`: Target host IPs for known hosts setup

### ssh_key_set_up.yml
Manages SSH key generation, delivery, and GitHub integration.

**Purpose**: Complete SSH key lifecycle management for infrastructure automation

**Features:**
- SSH key pair generation
- Public key distribution to target servers
- Private key upload to GitHub Secrets
- Local testing mode support
- GitHub API integration

**Usage:**
```bash
# For local testing (template development)
ansible-playbook ssh_key_set_up.yml

# For real usage with remote hosts
ansible-playbook ssh_key_set_up.yml -i inventory.ini
```

**Environment Variables:**
- `ANSIBLE_HOSTS`: Target host IPs
- `ANSIBLE_USER`: SSH username
- `ANSIBLE_HOSTS_PASSWORD`: SSH passwords (for initial setup)
- `GITHUB_TOKEN`: GitHub API token
- `GITHUB_REPOSITORY`: GitHub repository name

### generate_inventory.yml
Generates dynamic Ansible inventory from environment variables.

**Purpose**: Creates inventory files for SSH key-based authentication

**Features:**
- Dynamic host list from environment variables
- SSH key-based authentication configuration
- Python interpreter specification
- Clean, minimal configuration

**Usage:**
```bash
ansible-playbook generate_inventory.yml
```

**Environment Variables:**
- `ANSIBLE_HOSTS`: Multi-line host list
- `ANSIBLE_USER`: SSH username

**Output:**
- Creates `inventory.ini` file in the parent directory

### generate_initial_inventory.yml
Generates initial inventory for password-based SSH setup.

**Purpose**: Creates inventory files for initial password-based authentication

**Features:**
- Password authentication for first-time setup
- Host-password pairing
- Temporary configuration for key distribution
- Initial setup mode support

**Usage:**
```bash
ansible-playbook generate_initial_inventory.yml
```

**Environment Variables:**
- `ANSIBLE_HOSTS`: Multi-line host list
- `ANSIBLE_HOSTS_PASSWORD`: Multi-line password list
- `ANSIBLE_USER`: SSH username

**Output:**
- Creates `inventory.ini` file in the parent directory

## Local Testing Mode

The playbooks support a local testing mode for template development. This mode:

- Detects when running locally (localhost with local connection)
- Skips remote host operations that require SSH connections
- Skips GitHub API operations that require CI environment variables
- Allows testing of playbook structure and basic functionality

### Environment Variables

- `LOCAL_TESTING=true` - Explicitly enable local testing mode
- `CI_JOB_NAME=add_ssh_key` - Required for SSH key operations in CI environment

### Detection Logic

Local testing mode is automatically detected when:
1. `ansible_connection` is set to `local`
2. `inventory_hostname` is `localhost`
3. `LOCAL_TESTING` environment variable is set to `true`
4. No remote hosts are available in inventory

## Real Usage

For real usage in CI/CD pipelines:

1. **Set up proper inventory** with remote hosts
2. **Configure SSH connection details** in environment variables
3. **Set required environment variables** (`GITHUB_TOKEN`, `GITHUB_REPOSITORY`, etc.)
4. **Run playbooks** with proper inventory file

### Example CI/CD Usage

```yaml
# In GitHub Actions workflow
- name: Generate inventory
  run: |
    cd ansible
    ansible-playbook playbooks/generate_inventory.yml
  env:
    ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}
    ANSIBLE_USER: ${{ secrets.ANSIBLE_USER }}

- name: Setup SSH keys
  run: |
    cd ansible
    ansible-playbook -i ../inventory.ini playbooks/ssh_key_set_up.yml
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    GITHUB_REPOSITORY: ${{ github.repository }}
```

## Playbook Dependencies

### Inventory Generation
- `generate_initial_inventory.yml` → Used for initial SSH setup
- `generate_inventory.yml` → Used for regular operations

### SSH Key Management
- `setup_ci_env.yml` → Prepares environment
- `ssh_key_set_up.yml` → Manages key lifecycle

## Security Considerations

### SSH Key Management
- Private keys are never logged or exposed
- Keys are uploaded to GitHub Secrets with encryption
- Public keys are distributed securely
- Key rotation is supported

### Environment Variables
- Sensitive data is handled securely
- Passwords are masked in logs
- API tokens are encrypted
- Local testing mode prevents accidental remote operations

### File Permissions
- SSH directories have proper permissions (700)
- Private keys have restricted permissions (600)
- Public keys have standard permissions (644)

## Troubleshooting

### Connection Refused Error
If you see "Connection refused" errors, ensure you're running in local testing mode or have proper SSH access configured for remote hosts.

### GitHub API Errors
GitHub operations are skipped in local testing mode. For real usage, ensure `GITHUB_TOKEN` and `GITHUB_REPOSITORY` environment variables are set.

### Inventory Generation Issues
- Verify environment variables are set correctly
- Check template syntax in `templates/` directory
- Ensure proper file permissions for output files

### SSH Key Issues
- Verify SSH agent is running
- Check private key format and permissions
- Ensure target hosts are accessible
- Validate GitHub API token permissions

## Best Practices

### Development
1. **Use local testing mode** for development and testing
2. **Test playbooks locally** before deploying to CI/CD
3. **Validate environment variables** before running
4. **Check file permissions** for sensitive files

### Production
1. **Use proper secrets management** for sensitive data
2. **Rotate SSH keys regularly** for security
3. **Monitor playbook execution** in CI/CD logs
4. **Validate inventory files** before use

### Security
1. **Never commit sensitive data** to version control
2. **Use encrypted secrets** in CI/CD systems
3. **Limit SSH key permissions** to minimum required
4. **Audit access regularly** and rotate credentials

## Integration with CI/CD

### GitHub Actions
The playbooks are designed to work seamlessly with GitHub Actions workflows:

- **Automatic inventory generation** from secrets
- **SSH key management** with GitHub Secrets
- **Local testing support** for development
- **Error handling** and fallback mechanisms

### GitLab CI (Legacy)
The playbooks also support GitLab CI with appropriate environment variables:

- **GitLab CI/CD variables** for configuration
- **GitLab API integration** for variable management
- **Backward compatibility** with existing setups

## Performance Optimization

### Inventory Generation
- **Template-based generation** for efficiency
- **Minimal file I/O** operations
- **Caching** of generated inventories

### SSH Operations
- **Connection pooling** for multiple hosts
- **Parallel execution** where possible
- **Timeout handling** for network issues

### Local Testing
- **Fast execution** without network overhead
- **Immediate feedback** for development
- **Resource optimization** for local environments 