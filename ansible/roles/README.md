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
- Orchestrates multiple sub-roles for complete deployment

**Dependencies:**
- `synchronize` role
- `environment` role
- `docker_compose_plugin` role

**Usage:**
```yaml
- name: Deploy application
  hosts: all
  roles:
    - role: deploy
```

#### docker
Docker installation and configuration role.

**Features:**
- Official Docker installation script
- User group management
- Multi-distribution support
- Automatic Docker CLI installation

**Usage:**
```yaml
- name: Install Docker
  hosts: all
  roles:
    - role: docker
```

#### docker_compose_plugin
Docker Compose plugin management role.

**Features:**
- Docker Compose plugin installation
- Service restart capabilities
- Docker dependency validation
- Plugin management for Docker Compose v2

**Dependencies:**
- `docker` role

**Usage:**
```yaml
- name: Setup Docker Compose
  hosts: all
  roles:
    - role: docker_compose_plugin
  vars:
    app_dir: /opt/myapp
```

### Application Roles

#### environment
Environment file management role.

**Features:**
- `.env` file creation from variables
- Secure file permissions (0600)
- Variable content templating
- Environment-specific configuration

**Usage:**
```yaml
- name: Setup environment
  hosts: all
  roles:
    - role: environment
  vars:
    app_dir: /opt/myapp
  env:
    ENV_FILE_CONTENTS: |
      DATABASE_URL=postgresql://user:pass@localhost/db
      API_KEY=your-api-key
```

#### mongodb
MongoDB replica set and index management role.

**Features:**
- Replica set initialization
- Index creation and management
- TTL index configuration
- Optimized indexes for performance

**Usage:**
```yaml
- name: Setup MongoDB
  hosts: all
  roles:
    - role: mongodb
  env:
    MONGO_HOST_1: "192.168.1.10:27017"
    MONGO_HOST_2: "192.168.1.11:27017"
    MONGO_HOST_3: "192.168.1.12:27017"
```

#### ssl
SSL certificate management role.

**Features:**
- Certificate file deployment
- Chained certificate creation
- Secure key storage
- Certificate cleanup
- SSL directory management

**Usage:**
```yaml
- name: Setup SSL certificates
  hosts: all
  roles:
    - role: ssl
  vars:
    app_dir: /opt/myapp
  env:
    CERTIFICATE_CRT: "-----BEGIN CERTIFICATE-----..."
    CERTIFICATE_CA_CRT: "-----BEGIN CERTIFICATE-----..."
    CERTIFICATE_KEY: "-----BEGIN PRIVATE KEY-----..."
```

### Utility Roles

#### synchronize
File synchronization utilities role.

**Features:**
- Rsync-based file synchronization
- Git exclusion patterns
- Configurable source/destination
- Efficient file transfer

**Usage:**
```yaml
- name: Sync files
  hosts: all
  roles:
    - role: synchronize
  vars:
    app_dir: /opt/myapp
  env:
    CI_PROJECT_DIR: /workspace
```

#### ssh
SSH key and agent management role.

**Features:**
- SSH key pair generation
- SSH agent configuration
- Known hosts management
- Key distribution to remote hosts
- Local testing mode support

**Usage:**
```yaml
- name: Setup SSH keys
  hosts: all
  roles:
    - role: ssh
      tasks_from: generate_and_deliver
```

#### github_variable
GitHub variable management role.

**Features:**
- Secure variable upload to GitHub
- API-based variable management
- Protected and masked variables
- SSH key upload to GitHub Secrets

**Usage:**
```yaml
- name: Upload SSH key to GitHub
  hosts: localhost
  connection: local
  roles:
    - role: github_variable
      tasks_from: upload_ssh_key
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    GITHUB_REPOSITORY: "user/repo"
```

#### firewall
UFW firewall configuration role.

**Features:**
- UFW installation and enabling
- Port-based rule management
- Configurable port lists
- Security-focused configuration

**Usage:**
```yaml
- name: Configure firewall
  hosts: all
  roles:
    - role: firewall
  vars:
    ports:
      - port: 22
        proto: tcp
      - port: 80
        proto: tcp
      - port: 443
        proto: tcp
```

## Role Structure

Each role follows the standard Ansible role structure:

```
role_name/
├── tasks/
│   ├── main.yml
│   └── [specific_tasks].yml
├── templates/          # If needed
├── files/             # If needed
├── meta/
│   └── main.yml       # Role metadata and dependencies
└── README.md          # Role documentation
```

## Role Dependencies

Roles can depend on other roles through:
- Direct task inclusion
- Role dependencies in playbooks
- Shared variable definitions
- Meta dependencies

## Usage in Playbooks

```yaml
- name: Complete Application Deployment
  hosts: all
  roles:
    - role: deploy
    - role: mongodb
      vars:
        mongo_hosts:
          - "host1:27017"
          - "host2:27017"
    - role: ssl
      vars:
        app_dir: /opt/myapp
```

## Best Practices

- **Modularity**: Each role has a single responsibility
- **Documentation**: Each role has its own README
- **Variables**: Use sensible defaults with override capability
- **Idempotency**: All tasks are idempotent
- **Security**: Proper file permissions and secure handling of sensitive data
- **Testing**: Support for local testing mode

## Contributing

When adding new roles:

1. Follow the existing structure
2. Document variables and usage
3. Ensure idempotency
4. Add to this README
5. Include meta information
6. Support local testing mode when applicable

## Security Features

- SSH key rotation and management
- Secure credential storage
- Proper file permissions
- Encrypted communication
- Input validation
- Local testing mode for development

## Troubleshooting

### Common Issues

1. **Permission Denied**: Check file permissions and SSH key setup
2. **Connection Refused**: Verify SSH connectivity and firewall rules
3. **Variable Not Found**: Ensure all required environment variables are set
4. **Docker Issues**: Verify Docker installation and user group membership

### Local Testing

Most roles support local testing mode:
```bash
# Set local testing environment
export LOCAL_TESTING=true

# Run playbook locally
ansible-playbook playbooks/your-playbook.yml
```

### Debug Mode

Enable verbose output for debugging:
```bash
ansible-playbook -vvv playbooks/your-playbook.yml
``` 