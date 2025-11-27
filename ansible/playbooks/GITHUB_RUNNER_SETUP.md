# GitHub Actions Runner Setup Guide

This guide explains how to deploy a self-hosted GitHub Actions runner for your entire organization inside your k3s cluster using the `deploy-github-runner.yml` playbook.

## Important: Two Types of Permissions

**There are two separate permission systems you need to understand:**

1. **GitHub App Permissions** (for managing runners):
   - Used ONLY by Actions Runner Controller (ARC) to manage runners
   - Allows ARC to register/unregister runners and receive job assignments
   - Configured when creating the GitHub App (see Step 1)

2. **Workflow Permissions** (for your CI/CD jobs):
   - Used by your actual workflows when they run on the runners
   - Controlled by the `permissions:` block in each workflow file
   - Controls what your jobs can do (checkout repos, push to GHCR, etc.)
   - **Your existing workflows already have these configured correctly!**

**TL;DR**: The GitHub App permissions are just for runner management. Your workflows use `GITHUB_TOKEN` with permissions from the `permissions:` block (which your workflows already have set up correctly).

## Prerequisites

1. **K3s cluster** - Your cluster should already be bootstrapped using `bootstrap-k3s.yml`
2. **GitHub Organization** - You need admin access to create a GitHub App
3. **Required secrets** - GitHub App credentials (see setup steps below)

## Step 1: Create a GitHub App

To deploy organization-level runners, you need to create a GitHub App with the appropriate permissions.

### Create the GitHub App

1. Go to your organization's settings: `https://github.com/organizations/YOUR_ORG/settings/apps`
2. Click **"New GitHub App"**
3. Configure the app:

   **Basic Information:**
   - **GitHub App name**: `SkiesDota K3s Runners` (or your preferred name)
   - **Homepage URL**: Your organization homepage
   - **Webhook URL**: **Required by GitHub** (even though we don't use it)
     - **Enter**: `https://example.com/webhook` (placeholder - will be ignored)
     - **Important**: ARC uses **polling**, not webhooks, for basic runner operation. Webhooks are only needed for autoscaling (which you're not using). This placeholder URL will never be called. You can disable webhooks after creation (see below).

   **Repository Permissions:**
   - **Actions**: Read & Write (required for managing runners)
   - **Metadata**: Read-only (required)

   **Organization Permissions:**
   - **Self-hosted runners**: Read & Write (required for organization-level runners)

   **Where can this GitHub App be installed?**
   - **Choose: "Only on this account"** (restricted to `@SkiesGames`)
   - This is the secure choice - only your organization can install it
   - Do NOT choose "Any account" (that would make it publicly installable)

   **Important Note**: These GitHub App permissions are ONLY for the Actions Runner Controller (ARC) to manage the runners themselves (register/unregister runners, receive job assignments, etc.). They do NOT affect what your workflows can do.

   Your actual CI/CD workflows use the `GITHUB_TOKEN` which has separate permissions controlled by the `permissions:` block in each workflow file (see "Workflow Permissions" section below).

4. Click **"Create GitHub App"**

### Disable Webhooks (Optional but Recommended)

Since you're not using autoscaling, webhooks aren't needed. You can disable them:

1. After creating the app, go to the app's settings page
2. Scroll down to the **"Webhooks"** section
3. Click **"Disable webhooks"** or **"Delete webhook"**
4. Confirm the action

This is optional - ARC will work fine even with the placeholder URL, but disabling webhooks is cleaner since they won't be used.

### Generate Private Key

1. After creating the app, scroll down to **"Private keys"** section
2. Click **"Generate a private key"**
3. **IMPORTANT**: Download and save the `.pem` file securely. You won't be able to download it again.

### Install the App on Your Organization

1. After generating the private key, click **"Install App"**
2. Select your organization: `SkiesGames`
3. Click **"Install"**
4. On the installation page, note the **Installation ID** from the URL:
   - URL format: `https://github.com/organizations/YOUR_ORG/settings/installations/INSTALLATION_ID`
   - Copy this number

**Important**: When creating the GitHub App, choose **"Only on this account"** (restrict to `@SkiesGames`). This ensures the app can only be installed on your organization for security purposes.

### Collect Required Values

You'll need these three values:
- **App ID**: Found in the "About" section of your GitHub App settings
- **Installation ID**: From the installation page URL
- **Private Key**: The content of the `.pem` file you downloaded

## Step 2: Configure GitHub Secrets

In your `SkiesDotaInfra` repository (or wherever you'll run the workflow), add the following secrets:

### Required Secrets

1. **`GITHUB_APP_ID`**: The App ID from GitHub App settings
2. **`GITHUB_APP_INSTALLATION_ID`**: The Installation ID from the installation URL
3. **`GITHUB_APP_PRIVATE_KEY`**: The entire contents of the `.pem` file (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`). Store it exactly as downloaded, including all newlines. GitHub Secrets will preserve the formatting.
4. **`GITHUB_ORGANIZATION`**: Your organization name (e.g., `SkiesGames`)

### Runner Configuration

The playbook deploys runners with the following **fixed configuration**:
- **Min/Max Runners**: 1 (single runner pod)
- **Runner Label**: `arc-runner-set` (matches the Helm release name)
- **Namespace**: `arc-runners`
- **Docker Support**: Enabled via Docker-in-Docker (`containerMode.type=dind`)
- **Architecture**: Uses the new official ARC format (`gha-runner-scale-set`)

## Step 3: Deploy the Runner

Use the provided workflow or run the playbook manually.

### Using Workflow (Recommended)

See the example workflow file in `SkiesDotaInfra/.github/workflows/manual-deploy-github-runner.yml`

### Manual Deployment

```bash
ansible-playbook playbooks/deploy-github-runner.yml
```

## Step 4: Verify Runner Deployment

1. Check runner scale set in Kubernetes:
   ```bash
   kubectl get autoscalingrunnerset -n arc-runners
   kubectl get pods -n arc-runners
   kubectl get pods -n arc-runners -l app.kubernetes.io/name=gha-runner-scale-set-listener
   ```

2. Check controller and listener pods:
   ```bash
   kubectl get pods -n arc-runners -l app.kubernetes.io/name=gha-runner-scale-set-controller
   ```

3. Check runners in GitHub:
   - Go to: `https://github.com/organizations/YOUR_ORG/settings/actions/runner-groups`
   - You should see your runners listed under the "Default" group

## Step 5: Update Your Workflows

To use the self-hosted runners, update your workflow files to use the runner scale set name:

```yaml
jobs:
  build:
    runs-on: arc-runner-set  # Matches the Helm release name
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      # ... rest of your steps
```

**Important**: The `runs-on` value must match the Helm release name (`arc-runner-set`). This is the label that GitHub Actions uses to route jobs to your runners.

### Workflow Permissions

**This is important!** The GitHub App permissions above are only for managing runners. Your actual workflows need proper `GITHUB_TOKEN` permissions.

For workflows that need to:
- **Check out repos**: Add `contents: read` (or `write` if pushing)
- **Pull/push images from GHCR**: Add `packages: read` (or `write` if pushing)
- **All your CI/CD tasks**: Add appropriate permissions

Example workflow with proper permissions:

```yaml
name: Build and Push
on:
  push:
    branches: [main]

permissions:
  contents: read          # Read repository contents
  packages: write         # Push images to GHCR

jobs:
  build:
    runs-on: arc-runner-set
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Docker
        uses: ./.github/actions/setup-docker
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}  # Uses workflow permissions
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ghcr.io/org/repo/image:latest
```

**Your existing workflows** (like `ci-cd.prod.yml`) already have `permissions: contents: write, packages: write` - that's perfect! Just change `runs-on` to `arc-runner-set`.

## Troubleshooting

### Runner Not Appearing in GitHub

1. Check ARC controller logs:
   ```bash
   kubectl logs -n arc-runners -l app.kubernetes.io/name=gha-runner-scale-set-controller --tail=100
   ```

2. Check listener pod logs:
   ```bash
   kubectl logs -n arc-runners -l app.kubernetes.io/name=gha-runner-scale-set-listener --tail=100
   ```

3. Check AutoscalingRunnerSet status:
   ```bash
   kubectl describe autoscalingrunnerset arc-runner-set -n arc-runners
   ```

4. Verify GitHub App permissions and installation

### Runner Pod Failing

1. Check runner pod status (created on-demand when jobs are queued):
   ```bash
   kubectl get pods -n arc-runners
   kubectl describe pod -n arc-runners -l actions.github.com/scale-set-name=arc-runner-set
   ```

2. Check runner pod logs:
   ```bash
   kubectl logs -n arc-runners -l actions.github.com/scale-set-name=arc-runner-set --tail=100
   ```

3. Check resource limits - ensure your cluster has enough resources

### Authentication Issues

- Verify all three GitHub App secrets are correctly set
- Ensure the private key includes the full PEM content (headers and footers)
- Check that the App ID and Installation ID are numeric values (no extra spaces)

## Architecture

The playbook deploys using the **new official ARC format**:

1. **ARC Controller** (`gha-runner-scale-set-controller`): Kubernetes operator that manages runner scale sets
2. **AutoscalingRunnerSet**: Custom resource that defines your organization runners (managed via Helm)
3. **Listener Pod**: Watches for queued jobs and scales runner pods
4. **Runner Pods**: Individual runner instances created on-demand when jobs are queued

ARC automatically:
- Creates runner pods when jobs are queued (ephemeral runners)
- Cleans up pods when jobs complete
- Manages runner registration with GitHub
- Uses Docker-in-Docker (`dind`) for Docker support in workflows

## Scaling

The current configuration uses `minRunners=1` and `maxRunners=1` for a single persistent runner. To enable autoscaling based on job queue length, modify the Helm values in the playbook:
- `minRunners`: Minimum number of runners to keep running
- `maxRunners`: Maximum number of runners that can be created

See [ARC documentation](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller) for more details on scaling configuration.

## Security Considerations

1. **GitHub App Permissions**: Only grant minimum required permissions
2. **Runner Isolation**: Runners run in pods with limited permissions by default
3. **Secret Management**: Keep GitHub App credentials secure and rotate regularly
4. **Network Policies**: Consider implementing network policies to restrict runner network access

## Additional Resources

- [Official ARC Documentation](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller)
- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [ARC Runner Scale Set Helm Charts](https://github.com/actions/actions-runner-controller-charts)

