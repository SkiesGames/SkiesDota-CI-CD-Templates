# Ansible Playbooks

This directory contains Ansible playbooks for setting up CI/CD environments and managing SSH keys.

## Playbooks

### setup_ci_env.yml
Sets up the CI/CD environment by configuring SSH agent and environment.

**Usage:**
```bash
ansible-playbook setup_ci_env.yml
```

### ssh_key_set_up.yml
Manages SSH key generation, delivery, and GitHub integration.

**Usage:**
```bash
# For local testing (template development)
ansible-playbook ssh_key_set_up.yml

# For real usage with remote hosts
ansible-playbook ssh_key_set_up.yml -i inventory.yml
```

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

## Real Usage

For real usage in CI/CD pipelines:

1. Set up proper inventory with remote hosts
2. Configure SSH connection details
3. Set required environment variables (`GITHUB_TOKEN`, `GITHUB_REPOSITORY`, etc.)
4. Run playbooks with proper inventory file

## Troubleshooting

### Connection Refused Error
If you see "Connection refused" errors, ensure you're running in local testing mode or have proper SSH access configured for remote hosts.

### GitHub API Errors
GitHub operations are skipped in local testing mode. For real usage, ensure `GITHUB_TOKEN` and `GITHUB_REPOSITORY` environment variables are set. 