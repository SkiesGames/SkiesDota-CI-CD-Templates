# Ansible Linting Setup

This repository includes a comprehensive linting setup for Ansible code using multiple tools to ensure code quality and consistency.

## Tools Used

### 1. **Prettier**
- **Purpose**: Auto-formats YAML files
- **What it fixes**: Indentation, spacing, line endings, trailing spaces
- **Configuration**: `.prettierrc`

### 2. **ansible-lint**
- **Purpose**: Ansible-specific linting and best practices validation
- **What it checks**: Best practices, deprecated modules, FQCN issues, schema validation
- **Configuration**: Uses default rules with custom overrides

## CI/CD Integration

### GitHub Actions Workflow
- **File**: `.github/workflows/ci-cd.prod.yml` (format-lint job)
- **Triggers**: 
  - Push to `ansible/**/*` files
  - Changes to `Dockerfile.prod.format-lint`
  - Manual workflow dispatch

### Docker Image
- **File**: `Dockerfile.prod.format-lint`
- **Purpose**: Pre-configured environment with all linting tools
- **Registry**: `ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod-format-lint:latest`

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
   # Build the format-lint image
   docker build -f Dockerfile.prod.format-lint -t local-ansible-format-lint .
   
   # Run Prettier formatting
   docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-format-lint \
     prettier --write 'ansible/**/*.yml' 'ansible/**/*.yaml'
   
   # Run ansible-lint
   docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-format-lint \
     ansible-lint ansible/roles/ ansible/playbooks/
   ```

3. **Using the CI script directly**:
   ```bash
   # Run the same script used in CI
   bash .github/scripts/ansible-prod-format-lint.sh
   ```

## Workflow Process

1. **Prettier** runs first to auto-format YAML files
2. **ansible-lint** validates the formatted Ansible code
3. **Auto-commit** changes if formatting was applied

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

### `.prettierrc`
```json
{
  "overrides": [
    {
      "files": "*.yml",
      "options": {
        "parser": "yaml",
        "singleQuote": false,
        "tabWidth": 2,
        "useTabs": false,
        "printWidth": 80,
        "trailingComma": "none",
        "bracketSpacing": true,
        "arrowParens": "avoid"
      }
    },
    {
      "files": "*.yaml",
      "options": {
        "parser": "yaml",
        "singleQuote": false,
        "tabWidth": 2,
        "useTabs": false,
        "printWidth": 80,
        "trailingComma": "none",
        "bracketSpacing": true,
        "arrowParens": "avoid"
      }
    }
  ]
}
```

### ansible-lint Configuration
Uses default ansible-lint rules with the following considerations:
- **FQCN**: Fully Qualified Collection Names are preferred
- **Deprecated modules**: Avoid using deprecated Ansible modules
- **Best practices**: Follow Ansible best practices and conventions
- **Schema validation**: Ensure meta files have correct platform names

## Smart Dependency Management

The linting workflow includes smart dependency management:

### How It Works
1. **Change Detection**: Detects if `Dockerfile.prod.format-lint` changed
2. **Image Availability**: Tries to use custom format-lint image first
3. **Fallback Support**: Uses standard Python image if custom image unavailable
4. **Conditional Execution**: Only runs when relevant files change

### Benefits
- **Efficiency**: Only runs when necessary
- **Reliability**: Ensures consistent linting environment
- **Performance**: Reduces unnecessary job execution
- **Robustness**: Graceful fallback when custom images unavailable

## Troubleshooting

### CI Failures
1. Check the workflow logs for specific error messages
2. Run the local linting script to reproduce issues
3. Fix issues locally before pushing

### Local Issues
1. Ensure Docker is running
2. Check file permissions on the script
3. Verify you're in the repository root

### Common Error Messages
- **"Docker image not found"**: Build the format-lint image locally
- **"Permission denied"**: Check script permissions (`chmod +x scripts/lint-local.sh`)
- **"ansible-lint not found"**: Ensure the Docker image includes ansible-lint

## Best Practices

1. **Run linting before commits**: Use the local script
2. **Fix formatting issues**: Let Prettier handle them automatically
3. **Address all warnings**: Don't ignore linting warnings
4. **Keep configurations updated**: Update tool versions regularly
5. **Use consistent formatting**: Follow the established style guide

## Integration with IDE

Consider setting up your IDE to:
- Format YAML files on save using Prettier
- Show ansible-lint warnings inline
- Run ansible-lint on Ansible files

This will catch issues before they reach CI and improve your development experience.

### VS Code Configuration
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "ansible.ansibleLint.enabled": true,
  "ansible.ansibleLint.path": "ansible-lint"
}
```

## Performance Optimization

### Docker Layer Caching
- **Base image caching**: Reuse Python base image layers
- **Package caching**: Cache pip and npm installations
- **Build optimization**: Minimize image size and build time

### Local Development
- **Fast feedback**: Local linting without CI overhead
- **Consistent environment**: Same tools as CI pipeline
- **Immediate validation**: Quick checks during development

## Security Considerations

### Tool Security
- **Prettier**: Safe formatting tool, no security risks
- **ansible-lint**: Static analysis tool, no code execution
- **Docker images**: Built from official base images

### Best Practices
- **No secrets in code**: Linting tools don't expose secrets
- **Safe formatting**: Prettier only changes formatting, not logic
- **Validation only**: ansible-lint only validates, doesn't execute

## Future Enhancements

### Planned Improvements
1. **Additional linters**: Consider adding yamllint for YAML validation
2. **Custom rules**: Develop project-specific linting rules
3. **Performance**: Optimize Docker image size and build time
4. **Integration**: Better IDE integration and pre-commit hooks

### Contributing
When contributing to the linting setup:
1. Test changes locally first
2. Update documentation for new tools
3. Ensure backward compatibility
4. Add appropriate error handling 