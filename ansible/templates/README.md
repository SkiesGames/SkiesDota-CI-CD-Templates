# Templates

This directory contains Jinja2 templates for dynamic configuration generation in the Ansible automation pipeline.

## Available Templates

### Configuration Templates

#### ansible.cfg.j2
Ansible configuration template for CI/CD environments.

**Features:**
- Dynamic host key checking based on setup phase
- Optimized output formatting
- Retry file configuration
- Security-focused settings

**Variables:**
- `initial_setup`: Boolean for SSH key setup phase

### Inventory Templates

#### inventory.j2
Standard Ansible inventory template for SSH key authentication.

**Features:**
- Dynamic host list from environment variables
- SSH key-based authentication
- Python interpreter specification
- Clean, minimal configuration

**Variables:**
- `ANSIBLE_HOSTS`: Multi-line host list
- `ANSIBLE_USER`: SSH username

#### initial_ssh_setup_inventory.j2
Initial inventory template for password-based SSH setup.

**Features:**
- Password authentication for first-time setup
- Host-password pairing
- Temporary configuration for key distribution

**Variables:**
- `ANSIBLE_HOSTS`: Multi-line host list
- `ANSIBLE_HOSTS_PASSWORD`: Multi-line password list
- `ANSIBLE_USER`: SSH username

### Testing Templates

#### molecule.yml.j2
Molecule configuration template for role testing.

**Features:**
- Docker-based test environments
- Ansible provisioner configuration
- Customizable playbook paths
- Environment variable support

**Variables:**
- `MOLECULE_ROLE_NAME`: Role being tested
- `MOLECULE_PREPARE_PLAYBOOK`: Custom prepare playbook
- `MOLECULE_PLAYBOOK`: Custom converge playbook
- `MOLECULE_VERIFY_PLAYBOOK`: Custom verify playbook

#### converge.yml.j2
Molecule converge playbook template.

**Features:**
- Dynamic role inclusion
- Standardized testing structure
- Variable-based role selection

**Variables:**
- `MOLECULE_ROLE_NAME`: Role to test

## Template Usage

### In GitLab CI Jobs
Templates are used to generate dynamic configurations:

```yaml
- name: Generate inventory
  template:
    src: inventory.j2
    dest: ansible/inventory.ini
```

### In Ansible Tasks
Templates generate configuration files:

```yaml
- name: Configure Ansible
  template:
    src: ansible.cfg.j2
    dest: ~/.ansible/ansible.cfg
```

## Variable Sources

Templates use variables from:
- GitLab CI/CD variables
- Environment variables
- Ansible facts
- Custom role variables

## Security Considerations

- Sensitive data is masked in templates
- File permissions are set appropriately
- Credentials are handled securely
- Templates are validated before use

## Best Practices

- **Validation**: Always validate template output
- **Security**: Never expose sensitive data in templates
- **Flexibility**: Use variables for customization
- **Documentation**: Document all template variables
- **Testing**: Test templates with various inputs

## Extending Templates

To add new templates:

1. Create the template file with `.j2` extension
2. Document required variables
3. Add usage examples
4. Test with various input scenarios
5. Update this README

## Template Engine Features

- **Conditionals**: `{% if %}` statements for dynamic content
- **Loops**: `{% for %}` loops for repetitive content
- **Filters**: Jinja2 filters for data transformation
- **Variables**: Environment and custom variable support 