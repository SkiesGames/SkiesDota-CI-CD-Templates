# GitHub Actions Scripts

This directory contains scripts used by GitHub Actions workflows for CI/CD automation.

## Available Scripts

### ansible-prod-format-lint.sh

Comprehensive formatting and linting script for Ansible code.

**Purpose**: Performs YAML formatting and Ansible validation in CI/CD pipeline

**Features:**
- YAML file formatting with Prettier
- Ansible code validation with ansible-lint
- Auto-commit of formatting changes
- Comprehensive error handling
- Consistent with local development tools

**Usage in CI/CD:**
```bash
# Used in GitHub Actions workflow
bash .github/scripts/ansible-prod-format-lint.sh
```

**What it does:**
1. **Formats YAML files** using Prettier with project configuration
2. **Validates Ansible code** using ansible-lint
3. **Commits formatting changes** if any were made
4. **Provides detailed feedback** on all operations

**Environment Requirements:**
- Git configured with CI user
- Prettier and ansible-lint available
- Proper file permissions
- GitHub token for pushing changes

**Example Output:**
```
🎨 Formatting YAML files with Prettier...
✅ YAML files formatted successfully
🔍 Validating with ansible-lint...
✅ Ansible validation passed
📝 Committing formatting changes...
✅ Changes committed successfully
🎉 All formatting and validation completed successfully!
```

### ansible-prod-test.sh

Ansible testing and validation script.

**Purpose**: Performs comprehensive Ansible testing in CI/CD pipeline

**Features:**
- Ansible syntax validation
- Playbook dry-run testing
- Role validation
- Comprehensive error reporting

**Usage in CI/CD:**
```bash
# Used in GitHub Actions workflow
bash .github/scripts/ansible-prod-test.sh
```

**What it does:**
1. **Validates Ansible syntax** for all playbooks and roles
2. **Performs dry-run testing** with `--check --diff`
3. **Reports validation results** with detailed feedback
4. **Ensures code quality** before deployment

**Environment Requirements:**
- Ansible installed and configured
- Access to target inventory (if testing connectivity)
- Proper file permissions

**Example Output:**
```
🔍 Validating Ansible syntax...
✅ Syntax validation passed
🧪 Running dry-run tests...
✅ Dry-run tests completed successfully
🎉 All Ansible tests passed!
```

## Script Integration

### GitHub Actions Workflows

These scripts are used in the main production pipeline:

```yaml
# In .github/workflows/ci-cd.prod.yml
- name: Run formatting and linting (Custom Image)
  if: steps.pull-image.outputs.custom-image-available == 'true'
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace -w /workspace \
      ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod-format-lint:latest \
      bash .github/scripts/ansible-prod-format-lint.sh

- name: Run tests (Custom Image)
  if: steps.pull-image.outputs.custom-image-available == 'true'
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace -w /workspace \
      ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod-test:latest \
      bash .github/scripts/ansible-prod-test.sh
```

### Docker Image Integration

The scripts are designed to work with the project's Docker images:

- **ansible-prod-format-lint**: Contains Prettier, ansible-lint, and Node.js
- **ansible-prod-test**: Contains Ansible and testing tools

## Script Features

### Error Handling
- **Comprehensive error checking** at each step
- **Clear error messages** for troubleshooting
- **Graceful failure handling** with proper exit codes
- **Detailed logging** for debugging

### Performance Optimization
- **Efficient file processing** with targeted patterns
- **Minimal tool overhead** for fast execution
- **Optimized Docker integration** for CI/CD
- **Caching support** where applicable

### Security Considerations
- **Safe formatting operations** that don't change logic
- **Validation-only testing** without code execution
- **Secure credential handling** in CI environment
- **Proper file permissions** for generated content

## Local Development

### Testing Scripts Locally

You can test these scripts locally to ensure they work correctly:

```bash
# Test format-lint script
bash .github/scripts/ansible-prod-format-lint.sh

# Test test script
bash .github/scripts/ansible-prod-test.sh
```

### Using Docker Images

For consistent testing with CI environment:

```bash
# Build and test with format-lint image
docker build -f Dockerfile.prod.format-lint -t local-format-lint .
docker run --rm -v "$(pwd):/workspace" -w /workspace local-format-lint \
  bash .github/scripts/ansible-prod-format-lint.sh

# Build and test with test image
docker build -f Dockerfile.prod.test -t local-test .
docker run --rm -v "$(pwd):/workspace" -w /workspace local-test \
  bash .github/scripts/ansible-prod-test.sh
```

## Configuration

### Script Configuration
The scripts use project-level configuration:

- **Prettier**: Uses `.prettierrc` for formatting rules
- **ansible-lint**: Uses default rules with project considerations
- **Ansible**: Uses `ansible/ansible.cfg` for configuration

### Environment Variables
Scripts respect these environment variables:

- `GITHUB_TOKEN`: For committing changes (format-lint script)
- `GITHUB_ACTOR`: Git user name for commits
- `GITHUB_REPOSITORY`: Repository name for configuration

## Troubleshooting

### Common Issues

1. **"Permission denied"**
   ```bash
   chmod +x .github/scripts/*.sh
   ```

2. **"Tool not found"**
   - Ensure Docker image contains required tools
   - Check script dependencies

3. **"Git configuration error"**
   - Verify Git is configured in CI environment
   - Check GitHub token permissions

4. **"Ansible validation failed"**
   - Review ansible-lint output for specific issues
   - Check playbook and role syntax

### Debug Mode

Enable debug output for troubleshooting:

```bash
# Run with debug output
bash -x .github/scripts/ansible-prod-format-lint.sh
bash -x .github/scripts/ansible-prod-test.sh
```

## Best Practices

### Script Development
1. **Keep scripts focused** on single responsibility
2. **Add comprehensive error handling**
3. **Provide clear feedback** and progress indicators
4. **Test thoroughly** in CI environment

### CI/CD Integration
1. **Use consistent environment** with Docker images
2. **Handle failures gracefully** with proper exit codes
3. **Provide detailed logging** for debugging
4. **Optimize for performance** in CI environment

### Maintenance
1. **Update documentation** when scripts change
2. **Test in multiple environments** before deployment
3. **Monitor script performance** in CI pipeline
4. **Version control scripts** with proper change tracking

## Contributing

When modifying these scripts:

1. **Test locally first** to ensure changes work
2. **Update documentation** to reflect changes
3. **Maintain backward compatibility** where possible
4. **Add appropriate error handling** for new features
5. **Follow existing patterns** for consistency 