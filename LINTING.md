# Ansible Linting Setup

This repository includes a comprehensive linting setup for Ansible code using multiple tools to ensure code quality and consistency.

## Tools Used

### 1. **Prettier**
- **Purpose**: Auto-formats YAML files
- **What it fixes**: Indentation, spacing, line endings, trailing spaces
- **Configuration**: `.prettierrc`

### 2. **yamllint**
- **Purpose**: Validates YAML syntax and style
- **What it checks**: Syntax errors, formatting issues, style violations
- **Configuration**: `.yamllint`

### 3. **ansible-lint**
- **Purpose**: Ansible-specific linting
- **What it checks**: Best practices, deprecated modules, FQCN issues, schema validation
- **Configuration**: Uses default rules with custom overrides

## CI/CD Integration

### GitHub Actions Workflow
- **File**: `.github/workflows/lint-ansible.yml`
- **Triggers**: 
  - Push to `ansible/**/*` files
  - Changes to `Dockerfile.lint`
  - Manual workflow dispatch

### Docker Image
- **File**: `Dockerfile.lint`
- **Purpose**: Pre-configured environment with all linting tools
- **Registry**: `ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-lint:latest`

## Local Development

### Prerequisites
- Docker installed and running
- Repository cloned locally

### Running Linting Locally

1. **Using the provided script** (recommended):
   ```bash
   ./scripts/lint-local.sh
   ```

2. **Manual Docker commands**:
   ```bash
   # Build the lint image
   docker build -f Dockerfile.lint -t local-ansible-lint .
   
   # Run Prettier formatting
   docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint \
     prettier --write 'ansible/**/*.yml' 'ansible/**/*.yaml'
   
   # Run yamllint
   docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint \
     yamllint ansible/
   
   # Run ansible-lint
   docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint \
     ansible-lint ansible/roles/ ansible/playbooks/
   ```

## Workflow Process

1. **Prettier** runs first to auto-format YAML files
2. **yamllint** validates the formatted YAML
3. **ansible-lint** checks Ansible-specific rules

## Common Issues and Fixes

### YAML Formatting Issues
- **Missing newlines**: Prettier will add them automatically
- **Trailing spaces**: Prettier will remove them
- **Indentation**: Prettier will standardize to 2 spaces

### Ansible-Specific Issues
- **Deprecated modules**: Update to newer versions (e.g., `docker_compose` → `docker_compose_v2`)
- **FQCN issues**: Use canonical module names (e.g., `ansible.posix.synchronize`)
- **Schema errors**: Fix platform names in meta files (use `EL` instead of `CentOS`)

### Tag Format Issues
- **Invalid characters**: Use only lowercase letters and digits
- **Examples**: 
  - ✅ `ci`, `docker`, `mongodb`
  - ❌ `ci-cd`, `replica-set`

## Configuration Files

### `.yamllint`
```yaml
extends: default
rules:
  line-length: disable
  document-start: disable
  trailing-spaces: enable
  empty-lines-at-end-of-file: enable
  indentation:
    spaces: 2
```

### `.prettierrc`
```json
{
  "overrides": [
    {
      "files": "*.yml",
      "options": {
        "parser": "yaml",
        "tabWidth": 2,
        "printWidth": 80
      }
    }
  ]
}
```

## Troubleshooting

### CI Failures
1. Check the workflow logs for specific error messages
2. Run the local linting script to reproduce issues
3. Fix issues locally before pushing

### Local Issues
1. Ensure Docker is running
2. Check file permissions on the script
3. Verify you're in the repository root

## Best Practices

1. **Run linting before commits**: Use the local script
2. **Fix formatting issues**: Let Prettier handle them automatically
3. **Address all warnings**: Don't ignore linting warnings
4. **Keep configurations updated**: Update tool versions regularly

## Integration with IDE

Consider setting up your IDE to:
- Format YAML files on save using Prettier
- Show yamllint warnings inline
- Run ansible-lint on Ansible files

This will catch issues before they reach CI and improve your development experience. 