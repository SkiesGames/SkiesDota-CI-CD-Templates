# Templates

Jinja2 templates for dynamic configuration generation.

## Inventory Templates

### inventory.j2
Standard inventory template for SSH key authentication.

**Variables:** `ANSIBLE_HOSTS`, `ANSIBLE_USER`

**Usage:**
```yaml
- name: Generate inventory
  template:
    src: inventory.j2
    dest: ansible/inventory.ini
```

### initial_ssh_setup_inventory.j2
Initial inventory template for password-based SSH setup.

**Variables:** `ANSIBLE_HOSTS`, `ANSIBLE_HOSTS_PASSWORD`, `ANSIBLE_USER`

## Usage

Templates are used in playbooks via the `template` module:

```yaml
- name: Generate inventory
  ansible.builtin.copy:
    content: "{{ lookup('template', playbook_dir + '/../templates/inventory.j2') }}"
    dest: "{{ playbook_dir }}/../inventory.ini"
```

Variables are sourced from environment variables via Ansible `lookup('env', ...)`.
