# GitHub Actions Workflows

This directory contains reusable GitHub Actions workflows for CI/CD automation.

## Available Workflows

### SSH Key Setup (`ssh-key-setup.yml`)

A reusable workflow for setting up SSH keys on target servers.

**Features:**
- Generates SSH key pairs
- Distributes public keys to target servers
- Uploads private keys to GitHub Secrets
- Supports both manual trigger and reusable workflow calls

### OpenCommit (`reusable-opencommit.yml`)

A reusable workflow for improving commit messages using AI with OpenCommit.

**Features:**
- Automatically improves commit messages using AI
- Supports multiple AI providers (DeepSeek, OpenAI, etc.)
- Configurable parameters for tokens, language, emoji, etc.
- Uses conventional commit format by default
- Can be triggered on push events

**Configuration:**
- `oco-model`: AI model to use (default: 'deepseek-chat')
- `oco-ai-provider`: AI provider (default: 'deepseek')
- `oco-emoji`: Enable emoji in commit messages (default: 'true')
- `oco-api-key`: Required API key for the AI provider

## How to Use Reusable Workflows

### 1. In Other Repositories

To use the SSH key setup workflow in another repository, create a workflow file like this:

```yaml
# .github/workflows/setup-ssh.yml
name: Setup SSH Keys

on:
  workflow_dispatch:
    inputs:
      target_hosts:
        description: 'Target host IPs (comma-separated)'
        required: true
        type: string
      target_user:
        description: 'SSH username'
        required: true
        type: string
        default: 'root'
      target_password:
        description: 'SSH password'
        required: true
        type: string

jobs:
  setup-ssh-keys:
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/ssh-key-setup.yml@main
    with:
      target_hosts: ${{ github.event.inputs.target_hosts }}
      target_user: ${{ github.event.inputs.target_user }}
      target_password: ${{ github.event.inputs.target_password }}
      initial_setup: true
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
```

### 2. From Other Workflows

You can also call the workflow from within another workflow:

```yaml
jobs:
  some-other-job:
    runs-on: ubuntu-latest
    steps:
      - name: Do something
        run: echo "Hello"

  setup-ssh:
    needs: some-other-job
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/ssh-key-setup.yml@main
    with:
      target_hosts: "192.168.1.10,192.168.1.11"
      target_user: "root"
      target_password: ${{ secrets.SSH_PASSWORD }}
      initial_setup: true
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
```

### 3. OpenCommit Usage Example

To use the OpenCommit workflow for improving commit messages:

```yaml
# .github/workflows/improve-commits.yml
name: Improve Commit Messages

on:
  push:
    # Remove branches-ignore if you want OpenCommit to run on all branches
    # branches-ignore: [main master dev development release]

jobs:
  improve-commits:
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-opencommit.yml@main
    with:
      # Your specific configuration
      oco-model: 'deepseek-chat'
      oco-ai-provider: 'deepseek'
      oco-emoji: 'true'
      
      # Required: API key
      oco-api-key: ${{ secrets.OCO_API_KEY }}
      
      # Optional: override other defaults if needed
      oco-tokens-max-input: '4096'
      oco-tokens-max-output: '500'
      oco-description: 'false'
      oco-language: 'en'
      oco-prompt-module: 'conventional-commit'
      timeout-minutes: '10'
```

## Comparison with GitLab CI

### GitLab CI Approach
```yaml
# .gitlab-ci.yml
include:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs.yml'
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs/ssh_key_setup.yml'
```

### GitHub Actions Approach
```yaml
# .github/workflows/setup.yml
jobs:
  setup-ssh:
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/ssh-key-setup.yml@main
    with:
      target_hosts: ${{ github.event.inputs.target_hosts }}
      # ... other inputs
    secrets:
      github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Key Differences

| Aspect | GitLab CI | GitHub Actions |
|--------|-----------|----------------|
| **Include Method** | `include:` directive | `uses:` in jobs |
| **Reusability** | Include entire files | Call specific workflows |
| **Input Passing** | Environment variables | Explicit `with:` section |
| **Secrets** | Project variables | Explicit `secrets:` section |
| **Versioning** | Branch/tag in project path | `@main`, `@v1.0.0`, etc. |

## Including Ansible Playbooks and Roles

### Option 1: Git Submodules (Recommended)
```bash
# In your project
git submodule add https://github.com/SkiesGames/SkiesDota-CI-CD-Templates.git templates
```

Then reference in workflows:
```yaml
jobs:
  setup-ssh:
    uses: ./.github/workflows/ssh-key-setup.yml
    with:
      # ... inputs
```

### Option 2: Direct Repository Reference
```yaml
jobs:
  setup-ssh:
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/ssh-key-setup.yml@main
    with:
      # ... inputs
```

### Option 3: Composite Actions
Create reusable actions that can be called from any workflow:

```yaml
# .github/actions/setup-ssh/action.yml
name: 'Setup SSH Keys'
description: 'Setup SSH keys using Ansible'
inputs:
  target_hosts:
    description: 'Target host IPs'
    required: true
  target_user:
    description: 'SSH username'
    required: true
    default: 'root'
  target_password:
    description: 'SSH password'
    required: true
runs:
  using: 'composite'
  steps:
    - name: Checkout templates
      uses: actions/checkout@v4
      with:
        repository: SkiesGames/SkiesDota-CI-CD-Templates
        path: templates
    
    - name: Run SSH setup
      shell: bash
      run: |
        cd templates/ansible
        ansible-playbook playbooks/ssh_key_set_up.yml
      env:
        ANSIBLE_HOSTS: ${{ inputs.target_hosts }}
        ANSIBLE_USER: ${{ inputs.target_user }}
        ANSIBLE_HOSTS_PASSWORD: ${{ inputs.target_password }}
```

## Best Practices

### 1. Version Pinning
Always pin to specific versions for production:
```yaml
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/ssh-key-setup.yml@v1.0.0
```

### 2. Secret Management
Pass secrets explicitly:
```yaml
secrets:
  token: ${{ secrets.GITHUB_TOKEN }}
  ssh_password: ${{ secrets.SSH_PASSWORD }}
```

### 3. Input Validation
Validate inputs in your workflows:
```yaml
- name: Validate inputs
  run: |
    if [[ -z "${{ inputs.target_hosts }}" ]]; then
      echo "Error: target_hosts is required"
      exit 1
    fi
```

### 4. Error Handling
Add proper error handling and notifications:
```yaml
- name: Notify on failure
  if: failure()
  run: |
    echo "SSH setup failed"
    # Add notification logic
```

## Security Considerations

1. **Secrets**: Never hardcode passwords or tokens
2. **Permissions**: Use minimal required permissions
3. **Input Validation**: Validate all user inputs
4. **Audit Logs**: Monitor workflow executions
5. **Access Control**: Restrict who can trigger workflows

## Troubleshooting

### Common Issues

1. **Workflow not found**: Check repository name and path
2. **Permission denied**: Ensure proper secrets are passed
3. **Input validation failed**: Check required inputs
4. **Docker image not found**: Verify image exists in registry

### Debug Mode
Enable debug logging:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
``` 