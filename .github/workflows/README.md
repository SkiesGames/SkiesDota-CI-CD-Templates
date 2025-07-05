# GitHub Actions Workflows

This directory contains reusable GitHub Actions workflows for CI/CD automation.

## Available Workflows

### Reusable Build Image Workflow (`reusable-build-image.yml`)

A reusable workflow for building and publishing Docker images to GitHub Container Registry.

**Purpose**: Provides a standardized way to build Docker images with caching, multi-platform support, and automatic tagging.

**Features**:
- Docker Buildx for multi-platform builds
- GitHub Container Registry integration
- Automatic metadata extraction and tagging
- GitHub Actions caching for faster builds
- Configurable build arguments and platforms
- Support for custom build contexts

#### Usage

```yaml
jobs:
  build-my-image:
    uses: ./.github/workflows/reusable-build-image.yml
    with:
      image-name: my-app
      dockerfile-path: ./Dockerfile
      context-path: .
      cache-key: my-app-image
      platforms: linux/amd64,linux/arm64
      build-args: '{"VERSION":"1.0.0","ENV":"production"}'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `image-name` | string | ✅ | - | Name of the image to build |
| `dockerfile-path` | string | ✅ | - | Path to the Dockerfile |
| `context-path` | string | ❌ | `.` | Build context path |
| `build-args` | string | ❌ | `{}` | Build arguments as JSON string |
| `platforms` | string | ❌ | `linux/amd64` | Target platforms for multi-platform build |
| `cache-key` | string | ❌ | `build-image` | Cache key for the build |

#### Required Secrets

- `GITHUB_TOKEN`: GitHub token with packages:write permission

#### Example Use Cases

**Simple Image Build**:
```yaml
build-simple:
  uses: ./.github/workflows/reusable-build-image.yml
  with:
    image-name: simple-app
    dockerfile-path: ./Dockerfile
  secrets:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Multi-Platform Build**:
```yaml
build-multi-platform:
  uses: ./.github/workflows/reusable-build-image.yml
  with:
    image-name: multi-platform-app
    dockerfile-path: ./Dockerfile
    platforms: linux/amd64,linux/arm64,linux/arm/v7
    cache-key: multi-platform-cache
  secrets:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Build with Arguments**:
```yaml
build-with-args:
  uses: ./.github/workflows/reusable-build-image.yml
  with:
    image-name: app-with-args
    dockerfile-path: ./Dockerfile
    build-args: '{"NODE_ENV":"production","VERSION":"2.1.0"}'
    cache-key: app-with-args-cache
  secrets:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Reusable Test Ansible Workflow (`reusable-test-ansible.yml`)

A reusable workflow for testing Ansible code with conditional dependency on build workflows.

**Purpose**: Provides standardized Ansible testing with smart dependency management that waits for build workflows only when necessary.

**Features**:
- Conditional dependency on build workflows
- Ansible syntax validation using ansible-lint
- Dry-run playbook testing
- Automatic detection of running build workflows
- Configurable build workflow name
- Parallel job execution when possible

#### Usage

```yaml
jobs:
  test-ansible:
    uses: ./.github/workflows/reusable-test-ansible.yml
    with:
      wait-for-build: true
      build-workflow-name: 'Build Docker Images'
```

#### Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `wait-for-build` | boolean | ❌ | `true` | Whether to wait for build workflow to complete |
| `build-workflow-name` | string | ❌ | `'Build Docker Images'` | Name of the build workflow to wait for |

#### Jobs

**check-build-status**: Checks if the specified build workflow is currently running
**wait-for-build**: Waits for the build workflow to complete (only runs if build is running)
**test-ansible-syntax**: Runs ansible-lint on all roles and playbooks
**test-playbooks**: Performs dry-run validation of all playbooks

#### Example Use Cases

**Standard Testing with Build Dependency**:
```yaml
test-standard:
  uses: ./.github/workflows/reusable-test-ansible.yml
  with:
    wait-for-build: true
    build-workflow-name: 'Build Docker Images'
```

**Independent Testing (No Build Dependency)**:
```yaml
test-independent:
  uses: ./.github/workflows/reusable-test-ansible.yml
  with:
    wait-for-build: false
```

**Custom Build Workflow**:
```yaml
test-custom-build:
  uses: ./.github/workflows/reusable-test-ansible.yml
  with:
    wait-for-build: true
    build-workflow-name: 'Custom Build Process'
```

### Build Images Workflow (`build-images.yml`)

Main workflow that builds all project Docker images using the reusable workflow.

**Features**:
- Builds base Ansible image (`ansible:latest`)
- Builds test Ansible image (`ansible-test:latest`)
- Automatic triggering on Dockerfile changes
- Manual trigger support

**Triggers**:
- Push to Dockerfile files
- Manual workflow dispatch

### Test Ansible Workflow (`test-ansible.yml`)

Main workflow that tests Ansible code using the reusable test workflow.

**Features**:
- Uses reusable test workflow with build dependency
- Automatic triggering on Ansible code changes
- Manual trigger support
- Waits for build workflow when necessary

**Triggers**:
- Push to ansible directory
- Push to Dockerfile.test
- Pull requests to ansible directory
- Manual workflow dispatch

## Conditional Dependency Management

The reusable test workflow implements smart dependency management:

### How It Works

1. **Check Build Status**: Uses GitHub API to check if the specified build workflow is running
2. **Conditional Wait**: Only waits if the build workflow is actually running
3. **Immediate Execution**: Proceeds immediately if no build workflow is running
4. **Parallel Execution**: Allows tests to run in parallel when possible

### Benefits

- **Efficiency**: Tests don't wait unnecessarily when builds aren't running
- **Reliability**: Ensures tests use the latest images when builds are running
- **Flexibility**: Can be configured to work with any build workflow
- **Performance**: Reduces overall CI/CD pipeline time

### Implementation Details

```yaml
# Check if build workflow is running
RUNNING_WORKFLOWS=$(gh api repos/${{ github.repository }}/actions/runs \
  --jq '.workflow_runs[] | select(.name == "Build Docker Images" and .status == "in_progress") | .id')

# Wait only if build is running
if [ -n "$RUNNING_WORKFLOWS" ]; then
  # Wait for completion
  while true; do
    # Check again
    if [ -z "$RUNNING_WORKFLOWS" ]; then
      break
    fi
    sleep 30
  done
fi
```

## Benefits of Reusable Workflows

1. **DRY Principle**: Eliminates code duplication across workflows
2. **Consistency**: Ensures all image builds and tests follow the same process
3. **Maintainability**: Changes to build/test logic only need to be made in one place
4. **Flexibility**: Configurable parameters allow customization per use case
5. **Reusability**: Can be used across multiple repositories
6. **Smart Dependencies**: Conditional waiting reduces unnecessary delays

## Migration from GitLab CI

This approach mirrors the GitLab CI template pattern:

| GitLab CI | GitHub Actions |
|-----------|----------------|
| `.base_image` template | `reusable-build-image.yml` workflow |
| `.base_test_role_playbook` template | `reusable-test-ansible.yml` workflow |
| `extends: .base_image` | `uses: ./.github/workflows/reusable-build-image.yml` |
| `variables:` | `with:` |
| `rules:` | `on:` triggers |
| Manual dependency management | Conditional dependency with API checks |

## Best Practices

1. **Use Descriptive Cache Keys**: Use unique cache keys for different image types
2. **Specify Platforms**: Explicitly define target platforms for better control
3. **Version Build Args**: Pass version information through build arguments
4. **Test Workflows**: Test reusable workflows in isolation before using in production
5. **Document Parameters**: Always document new input parameters
6. **Conditional Dependencies**: Use conditional waiting to optimize pipeline performance
7. **API Rate Limits**: Be mindful of GitHub API rate limits when checking workflow status

## Troubleshooting

### Common Issues

**Build Fails with Permission Error**:
- Ensure `GITHUB_TOKEN` has `packages:write` permission
- Check repository settings for package permissions

**Cache Not Working**:
- Verify cache key is unique for the image type
- Check if cache is being invalidated by other workflows

**Multi-Platform Build Issues**:
- Ensure Dockerfile supports all target platforms
- Check for platform-specific dependencies

**Test Workflow Hangs**:
- Check if build workflow is stuck in a running state
- Verify GitHub API access and rate limits
- Review workflow logs for API errors

**Conditional Dependency Not Working**:
- Ensure `GITHUB_TOKEN` has appropriate permissions
- Check workflow name matches exactly
- Verify API query syntax

### Debug Workflows

- Enable debug logging in workflow files
- Check workflow run logs in GitHub Actions
- Use `actions/checkout@v4` with `fetch-depth: 0` for full history
- Test API queries manually using `gh api` command
- Monitor GitHub API rate limits in workflow logs 