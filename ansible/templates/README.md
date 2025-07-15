# Templates

This directory contains Jinja2 templates for dynamic configuration generation in the Ansible automation pipeline.

## Available Templates

### Inventory Templates

#### inventory.j2
Standard Ansible inventory template for SSH key authentication.

**Purpose**: Creates inventory files for SSH key-based authentication

**Features:**
- Dynamic host list from environment variables
- SSH key-based authentication
- Python interpreter specification
- Clean, minimal configuration

**Variables:**
- `ANSIBLE_HOSTS`: Multi-line host list from environment
- `ANSIBLE_USER`: SSH username from environment

**Usage:**
```yaml
- name: Generate inventory
  template:
    src: inventory.j2
    dest: ansible/inventory.ini
```

**Output Example:**
```ini
[all]
192.168.1.10 ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3
192.168.1.11 ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3
```

#### initial_ssh_setup_inventory.j2
Initial inventory template for password-based SSH setup.

**Purpose**: Creates inventory files for initial password-based authentication

**Features:**
- Password authentication for first-time setup
- Host-password pairing
- Temporary configuration for key distribution
- Initial setup mode support

**Variables:**
- `ANSIBLE_HOSTS`: Multi-line host list from environment
- `ANSIBLE_HOSTS_PASSWORD`: Multi-line password list from environment
- `ANSIBLE_USER`: SSH username from environment

**Usage:**
```yaml
- name: Generate initial inventory
  template:
    src: initial_ssh_setup_inventory.j2
    dest: ansible/inventory.ini
```

**Output Example:**
```ini
[all]
192.168.1.10 ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3 ansible_ssh_pass=password1 ansible_become_pass=password1
192.168.1.11 ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3 ansible_ssh_pass=password2 ansible_become_pass=password2
```

## Template Engine Features

### Jinja2 Capabilities
- **Conditionals**: `{% if %}` statements for dynamic content
- **Loops**: `{% for %}` loops for repetitive content
- **Filters**: Jinja2 filters for data transformation
- **Variables**: Environment and custom variable support
- **Lookups**: Ansible lookup plugins for external data

### Environment Variable Integration
Templates seamlessly integrate with environment variables:

```jinja2
{% for host in lookup('env', 'ANSIBLE_HOSTS').split('\n') | select('string') | list %}
{{ host }} ansible_user={{ lookup('env', 'ANSIBLE_USER') }}
{% endfor %}
```

### Data Processing
Advanced data processing capabilities:

- **String filtering**: `select('string')` removes empty lines
- **List operations**: `split('\n')` converts multi-line strings to lists
- **Zipping**: `zip()` pairs hosts with passwords
- **Conditional rendering**: Dynamic content based on variables

## Template Usage

### In Ansible Playbooks
Templates are used to generate dynamic configurations:

```yaml
- name: Generate inventory file
  ansible.builtin.copy:
    content: "{{ lookup('template', playbook_dir + '/../templates/inventory.j2') }}"
    dest: "{{ playbook_dir }}/../inventory.ini"
    mode: "0644"
```

### In GitLab CI Jobs (Legacy)
Templates were used in GitLab CI for dynamic configuration:

```yaml
- name: Generate inventory
  template:
    src: inventory.j2
    dest: ansible/inventory.ini
```

### In GitHub Actions Workflows (Current)
Templates are used in GitHub Actions for inventory generation:

```yaml
- name: Generate inventory
  run: |
    cd ansible
    ansible-playbook playbooks/generate_inventory.yml
  env:
    ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}
    ANSIBLE_USER: ${{ secrets.ANSIBLE_USER }}
```

## Variable Sources

Templates use variables from multiple sources:

### Environment Variables
- `ANSIBLE_HOSTS`: Target host IPs
- `ANSIBLE_USER`: SSH username
- `ANSIBLE_HOSTS_PASSWORD`: SSH passwords (for initial setup)

### Ansible Facts
- `playbook_dir`: Current playbook directory
- `inventory_hostname`: Current host being processed

### Custom Variables
- Role-specific variables
- Playbook variables
- Host variables

## Security Considerations

### Sensitive Data Handling
- **Passwords are masked** in logs and output
- **Private keys** are never included in templates
- **API tokens** are handled securely
- **File permissions** are set appropriately

### Template Validation
- **Syntax validation** before use
- **Variable validation** for required fields
- **Output validation** for security
- **Permission validation** for sensitive files

### Best Practices
- **Never expose secrets** in template output
- **Use proper permissions** for generated files
- **Validate input data** before processing
- **Sanitize user input** to prevent injection

## Template Development

### Local Testing
Templates can be tested locally:

```bash
# Set environment variables
export ANSIBLE_HOSTS="192.168.1.10\n192.168.1.11"
export ANSIBLE_USER="ubuntu"

# Test template rendering
ansible localhost -m template -a "src=ansible/templates/inventory.j2 dest=/tmp/test.ini"
```

### Template Validation
Validate template syntax:

```bash
# Check Jinja2 syntax
python -c "from jinja2 import Template; Template(open('ansible/templates/inventory.j2').read())"
```

### Debug Mode
Enable debug output for template development:

```bash
# Run with verbose output
ansible-playbook -vvv playbooks/generate_inventory.yml
```

## Performance Optimization

### Template Caching
- **Jinja2 caching** for repeated templates
- **Variable caching** for environment lookups
- **Output caching** for static content

### Efficient Processing
- **Minimal lookups** to reduce overhead
- **Optimized loops** for large datasets
- **Conditional rendering** to skip unnecessary processing

### Memory Management
- **Streaming processing** for large files
- **Garbage collection** for temporary variables
- **Resource cleanup** after template rendering

## Troubleshooting

### Common Issues

1. **Template not found**: Check file path and permissions
2. **Variable not defined**: Verify environment variables are set
3. **Syntax error**: Validate Jinja2 syntax
4. **Permission denied**: Check file permissions for output

### Debug Techniques

1. **Enable verbose logging**: Use `-vvv` flag
2. **Check environment variables**: Verify variable values
3. **Test template locally**: Render template manually
4. **Validate output**: Check generated file content

### Error Messages

- **"template not found"**: Check file path and existence
- **"variable not defined"**: Verify environment variable is set
- **"permission denied"**: Check file permissions
- **"syntax error"**: Validate Jinja2 syntax

## Best Practices

### Template Design
1. **Keep templates simple** and focused
2. **Use descriptive variable names**
3. **Include comments** for complex logic
4. **Validate input data** before processing

### Security
1. **Never include secrets** in templates
2. **Use proper file permissions**
3. **Validate user input**
4. **Sanitize data** before rendering

### Performance
1. **Minimize lookups** and operations
2. **Use efficient loops** and conditionals
3. **Cache static content** when possible
4. **Optimize for readability** and maintainability

### Maintenance
1. **Document template variables**
2. **Version control templates**
3. **Test templates thoroughly**
4. **Update documentation** when templates change

## Integration Examples

### Complete Workflow Integration
```yaml
# 1. Generate inventory
- name: Generate inventory
  template:
    src: inventory.j2
    dest: inventory.ini

# 2. Use inventory for playbook
- name: Run playbook
  command: ansible-playbook -i inventory.ini playbook.yml
```

### CI/CD Integration
```yaml
# GitHub Actions workflow
- name: Generate inventory
  run: |
    cd ansible
    ansible-playbook playbooks/generate_inventory.yml
  env:
    ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}
    ANSIBLE_USER: ${{ secrets.ANSIBLE_USER }}
```

### Local Development
```bash
# Local testing
export ANSIBLE_HOSTS="localhost"
export ANSIBLE_USER="$(whoami)"
ansible-playbook playbooks/generate_inventory.yml
``` 