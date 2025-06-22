# Playbooks

This directory contains Ansible playbooks for infrastructure automation and deployment workflows.

## Available Playbooks

### ssh_key_set_up.yml
SSH key management and distribution playbook.

**Purpose:**
- Generates SSH key pairs for CI/CD automation
- Distributes public keys to target servers
- Uploads private keys to GitLab variables for secure storage

**Roles Used:**
- `ssh`: Key generation and distribution
- `gitlab_variable`: Secure variable storage

**Usage:**
- Triggered by `add_ssh_key` job
- Used for initial server setup
- Requires password authentication for first run

**Target Hosts:**
- All hosts defined in `ANSIBLE_HOSTS` variable

**Execution:**
```bash
ansible-playbook -i inventory.ini ssh_key_set_up.yml
```

## Playbook Structure

Each playbook follows the standard Ansible structure:

```yaml
- name: Playbook Description
  hosts: target_hosts
  gather_facts: false  # When not needed
  roles:
    - role: role_name
      tasks_from: specific_task_file  # Optional
```

## Integration with Jobs

Playbooks are executed by GitLab CI jobs:

- **bootstrap**: Runs bootstrap playbook (to be created)
- **deploy**: Runs deploy playbook (to be created)
- **add_ssh_key**: Runs ssh_key_set_up.yml

## Variables

Playbooks use variables from:
- GitLab CI/CD variables
- Inventory files
- Role defaults
- Environment-specific configurations

## Security Considerations

- SSH keys are generated ephemerally
- Private keys are stored securely in GitLab variables
- Public keys are distributed to authorized hosts only
- Password authentication is only used for initial setup

## Extending Playbooks

To add new playbooks:

1. Create the playbook file in this directory
2. Define the required roles and tasks
3. Update corresponding job definitions
4. Add documentation for usage and variables

## Best Practices

- Use roles for reusable functionality
- Keep playbooks focused on specific workflows
- Document required variables and dependencies
- Test playbooks with Molecule before deployment 