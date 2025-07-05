# Test Jobs

This directory contains GitLab CI jobs for testing and validating Ansible code quality and syntax. These jobs ensure that all Ansible roles and playbooks follow best practices and can be executed safely.

## Job Structure

All testing jobs are defined in `jobs.yml` and follow a consistent approach using a base template.

### Base Template (.base_test_role_playbook)

The `.base_test_role_playbook` template provides common functionality for all testing jobs:

**Features:**
- Uses the Ansible lint testing image
- Runs in the test stage
- Provides consistent environment for all test jobs

**Image:**
- `$CI_REGISTRY_IMAGE/ansible-lint:latest` - Built from `Dockerfile.ansible-lint`

## Available Jobs

### test_ansible_syntax
Validates all Ansible roles and playbooks using ansible-lint for code quality and best practices.

**Features:**
- Checks all roles in `ansible/roles/*/` directories
- Checks all playbooks in `ansible/playbooks/*.yml`
- Uses `--nocolor` flag for consistent output
- Provides detailed feedback on code quality issues

**Execution Rules:**
- **Automatic on image changes**: When `Dockerfile.ansible-lint` changes, runs after `build_ansible_lint_image`
- **Automatic on code changes**: When playbooks or roles change
- **Manual execution**: Available for on-demand testing

**Example Output:**
```
CHECKING ROLE: ansible/roles/deploy/
CHECKING ROLE: ansible/roles/docker/
CHECKING PLAYBOOK: ansible/playbooks/setup_ci_env.yml
CHECKING PLAYBOOK: ansible/playbooks/generate_inventory.yml
```

### test_playbooks
Performs dry-run validation of all Ansible playbooks to ensure they can be executed safely.

**Features:**
- Uses `--check --diff` flags for safe simulation
- Validates playbook syntax and structure
- Shows what changes would be made without executing them
- Uses localhost inventory for testing

**Execution Rules:**
- **Dependency**: Runs after `test_ansible_syntax` completes
- **Automatic on code changes**: When playbooks or roles change
- **Manual execution**: Available for on-demand testing

**Example Output:**
```
CHECKING PLAYBOOK: ansible/playbooks/setup_ci_env.yml
PLAY [all] *********************************************************************
TASK [Gathering Facts] *********************************************************
ok: [localhost]
...
```

## Test Image

The testing jobs use a dedicated Docker image built from `Dockerfile.ansible-lint`:

**Base Image:** `python:3.13-slim`
**Installed Packages:**
- `ansible`: Core Ansible package
- `ansible-lint`: Code quality validation tool

**Build Process:**
- Built automatically when `Dockerfile.ansible-lint` changes
- Stored in GitLab registry as `$CI_REGISTRY_IMAGE/ansible-lint:latest`

## Usage in Other Projects

Include the test jobs in your project's `.gitlab-ci.yml`:

```yaml
include:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/test_jobs/jobs.yml'
```

The jobs will automatically:
- Run when Ansible code changes
- Validate syntax and best practices
- Provide feedback on code quality issues

## Configuration

### Required Variables
- `$CI_REGISTRY_IMAGE`: GitLab registry image path for the test image

### Optional Configuration
- Modify the base template to add custom testing logic
- Extend jobs to include additional validation steps
- Add custom rules for specific testing scenarios

## Best Practices

1. **Run tests before deployment**: Always validate Ansible code before running in production
2. **Fix linting issues**: Address all ansible-lint warnings and errors
3. **Test playbook changes**: Use dry-run validation for new playbooks
4. **Regular validation**: Run tests regularly to catch issues early

## Troubleshooting

### Common Issues

**Job fails with syntax errors:**
- Review ansible-lint output for specific issues
- Fix YAML syntax or Ansible best practice violations
- Ensure proper indentation and structure

**Playbook validation fails:**
- Check for missing variables or undefined references
- Verify inventory structure and host definitions
- Review task dependencies and conditions

**Image build failures:**
- Ensure Dockerfile.ansible-lint is valid
- Check GitLab registry permissions
- Verify CI/CD variable configuration

## Extending

To add new test jobs, extend the `.base_test_role_playbook` template:

```yaml
custom_test_job:
  extends: .base_test_role_playbook
  script:
    - echo "Running custom validation..."
    - # Add your custom test commands here
  rules:
    - changes:
        - ansible/**/*
      when: always
``` 