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

## Benefits of Reusable Workflows

1. **DRY Principle**: Eliminates code duplication across workflows
2. **Consistency**: Ensures all image builds follow the same process
3. **Maintainability**: Changes to build logic only need to be made in one place
4. **Flexibility**: Configurable parameters allow customization per use case
5. **Reusability**: Can be used across multiple repositories

## Migration from GitLab CI

This approach mirrors the GitLab CI `.base_image` template pattern:

| GitLab CI | GitHub Actions |
|-----------|----------------|
| `.base_image` template | `reusable-build-image.yml` workflow |
| `extends: .base_image` | `uses: ./.github/workflows/reusable-build-image.yml` |
| `variables:` | `with:` |
| `rules:` | `on:` triggers |

## Best Practices

1. **Use Descriptive Cache Keys**: Use unique cache keys for different image types
2. **Specify Platforms**: Explicitly define target platforms for better control
3. **Version Build Args**: Pass version information through build arguments
4. **Test Workflows**: Test reusable workflows in isolation before using in production
5. **Document Parameters**: Always document new input parameters

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

### Debug Workflows

- Enable debug logging in workflow files
- Check workflow run logs in GitHub Actions
- Use `actions/checkout@v4` with `fetch-depth: 0` for full history 