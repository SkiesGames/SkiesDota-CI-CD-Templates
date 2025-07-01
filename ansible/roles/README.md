# Roles

This directory contains reusable Ansible roles for infrastructure automation and application deployment.

## Available Roles

### Core Infrastructure Roles

#### deploy
Application deployment and synchronization role.

**Features:**
- File synchronization from CI/CD pipeline
- Environment file management
- Docker Compose service management

**Dependencies:**
- `synchronize` role
- `environment` role
- `docker-compose-plugin` role

#### docker
Docker installation and configuration role.

**Features:**
- Official Docker installation script
- User group management
- Multi-distribution support

#### docker-compose-plugin
Docker Compose plugin management role.

**Features:**
- Docker Compose plugin installation
- Service restart capabilities
- Docker dependency validation

#### firewall
UFW firewall configuration role.

**Features:**
- UFW installation and enabling
- Port-based rule management
- Configurable port lists

### Application Roles

#### environment
Environment file management role.

**Features:**
- `.env` file creation from variables
- Secure file permissions (0600)
- Variable content templating

#### mongodb
MongoDB replica set and index management role.

**Features:**
- Replica set initialization
- Index creation and management
- TTL index configuration

#### ssl
SSL certificate management role.

**Features:**
- Certificate file deployment
- Chained certificate creation
- Secure key storage
- Certificate cleanup

### Utility Roles

#### synchronize
File synchronization utilities role.

**Features:**
- Rsync-based file synchronization
- Git exclusion patterns
- Configurable source/destination

#### ssh
SSH key and agent management role.

**Features:**
- SSH key pair generation
- SSH agent configuration
- Known hosts management
- Key distribution to remote hosts

#### gitlab_variable
GitLab variable management role.

**Features:**
- Secure variable upload to GitLab
- API-based variable management
- Protected and masked variables

## Role Structure

Each role follows the standard Ansible role structure:

```
role_name/
├── tasks/
│   ├── main.yml
│   └── [specific_tasks].yml
├── templates/          # If needed
├── files/             # If needed
└── README.md          # Role documentation
```

## Role Dependencies

Roles can depend on other roles through:
- Direct task inclusion
- Role dependencies in playbooks
- Shared variable definitions

## Usage in Playbooks

```yaml
- name: Example Playbook
  hosts: all
  roles:
    - role: deploy
    - role: mongodb
      vars:
        mongo_hosts:
          - "host1:27017"
          - "host2:27017"
```

## Best Practices

- **Modularity**: Each role has a single responsibility
- **Documentation**: Each role has its own README
- **Variables**: Use sensible defaults with override capability
- **Idempotency**: All tasks are idempotent

## Contributing

When adding new roles:

1. Follow the existing structure
2. Document variables and usage
3. Ensure idempotency
4. Add to this README 