# Scripts

This directory contains local development scripts for the SkiesDota CI/CD Templates project.

## Available Scripts

### lint-local.sh

A local development script for linting Ansible code.

**Purpose**: Provides the same linting capabilities as the CI pipeline for local development

**Features:**
- Ansible code validation with ansible-lint
- Consistent with CI pipeline tools
- Fast local execution

**Usage:**
```bash
# Make script executable (first time only)
chmod +x scripts/lint-local.sh

# Run linting
./scripts/lint-local.sh
```

**What it does:**
1. **Validates Ansible code** using ansible-lint
2. **Provides feedback** on validation results

**Requirements:**
- ansible-lint installed: `pip install ansible-lint`
- Run from repository root directory

**Example Output:**
```
🔍 Validating with ansible-lint...
🎉 All linting completed successfully!
```

## Alternative Local Development Methods

### Using Docker (Recommended)

For consistent environment with CI pipeline:

```bash
# Build the lint image
docker build -f Dockerfile.prod.lint -t local-ansible-lint .

# Run linting
docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint \
  bash .github/scripts/ansible-prod-lint.sh
```

### Using CI Script Directly

Run the same script used in CI:

```bash
# Run the CI script directly
bash .github/scripts/ansible-prod-lint.sh
```

## Prerequisites

### For Native Script Execution
```bash
# Install ansible-lint
pip install ansible-lint

# Install Ansible (if not already installed)
pip install ansible
```

### For Docker Execution
```bash
# Install Docker
# No additional tools required - everything is in the Docker image
```

## Configuration

### ansible-lint Configuration
Uses default ansible-lint rules with project-specific considerations:
- FQCN (Fully Qualified Collection Names) preferred
- Deprecated modules avoided
- Best practices enforced
- Schema validation for meta files

## Troubleshooting

### Common Issues

1. **"ansible-lint: command not found"**
   ```bash
   pip install ansible-lint
   ```

2. **"Permission denied"**
   ```bash
   chmod +x scripts/lint-local.sh
   ```

4. **"No such file or directory"**
   - Ensure you're running from the repository root
   - Check that the script file exists

### Docker Issues

1. **"Docker image not found"**
   ```bash
   docker build -f Dockerfile.prod.lint -t local-ansible-lint .
   ```

2. **"Permission denied" in Docker**
   ```bash
   # On Linux, you might need to adjust file permissions
   sudo chown -R $USER:$USER .
   ```

## Best Practices

### Development Workflow
1. **Run before commits**: Use the script to ensure code quality
2. **Fix issues locally**: Address linting warnings before pushing
3. **Use consistent tools**: Stick to the same tools as CI pipeline
4. **Test changes**: Verify formatting doesn't break functionality

### Script Maintenance
1. **Keep scripts simple**: Focus on single responsibility
2. **Add error handling**: Provide clear error messages
3. **Document requirements**: List all prerequisites
4. **Test regularly**: Ensure scripts work with current tools

## Integration with IDE

### VS Code
Configure VS Code to use the same tools:

```json
{
  "ansible.ansibleLint.enabled": true,
  "ansible.ansibleLint.path": "ansible-lint"
}
```

### Pre-commit Hooks
Consider adding pre-commit hooks to automatically run linting:

```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v2.8.8
    hooks:
      - id: prettier
        files: \.(yml|yaml)$
```

## Performance Tips

### Native Execution
- **Fast startup**: No Docker overhead
- **Direct access**: Uses system-installed tools
- **Immediate feedback**: Quick execution for development

### Docker Execution
- **Consistent environment**: Same as CI pipeline
- **No tool installation**: Everything included in image
- **Isolated execution**: No system dependencies

## Contributing

When adding new scripts:

1. **Follow naming convention**: Use descriptive names with `.sh` extension
2. **Add error handling**: Include proper error checking and messages
3. **Document usage**: Update this README with new script information
4. **Test thoroughly**: Ensure scripts work in different environments
5. **Keep it simple**: Focus on single responsibility and clear purpose 