# Ansible Playbooks

## Playbooks

### bootstrap-k3s.yml
Bootstrap HA K3s cluster.

**Usage:**
```yaml
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
with:
  playbook: playbooks/bootstrap-k3s.yml
  use_template_playbook: true
  ansible_extra_env_json: '{"NUMBER_OF_CONTROL_PLANE_NODES": "3"}'
```

**Env vars:** `ANSIBLE_HOSTS`, `ANSIBLE_USER`, `K3S_TOKEN`, `NUMBER_OF_CONTROL_PLANE_NODES` (optional)

### deploy-infra-services.yml
Deploy cert-manager and Let's Encrypt to K3s cluster.

**Usage:**
```yaml
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
with:
  playbook: playbooks/deploy-infra-services.yml
  use_template_playbook: true
```

**Env vars:** `LETS_ENCRYPT_EMAIL` (via secrets)

### deploy-github-runner.yml
Deploy GitHub Actions self-hosted runners using ARC.

**Usage:**
```yaml
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
with:
  playbook: playbooks/deploy-github-runner.yml
  use_template_playbook: true
  ansible_extra_env_json: '{"GITHUB_ORGANIZATION": "SkiesGames"}'
secrets:
  ANSIBLE_EXTRA_SECRETS_JSON: |
    {
      "GITHUB_APP_ID": "...",
      "GITHUB_APP_INSTALLATION_ID": "...",
      "GITHUB_APP_PRIVATE_KEY": "..."
    }
```

**See:** `GITHUB_RUNNER_SETUP.md` for detailed setup

### generate_inventory.yml
Generate dynamic Ansible inventory from environment variables.

**Env vars:** `ANSIBLE_HOSTS`, `ANSIBLE_USER`

### ssh_key_set_up.yml
SSH key lifecycle management (generation, distribution, GitHub Secrets upload).

**Env vars:** `ANSIBLE_HOSTS`, `ANSIBLE_USER`, `ANSIBLE_HOSTS_PASSWORD` (initial), `GITHUB_TOKEN`, `GITHUB_REPOSITORY`

### deploy-image-cache.yml
Deploy Docker image caching DaemonSet for faster CI/CD pipelines.

**Usage:**
```yaml
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
with:
  playbook: playbooks/deploy-image-cache.yml
  use_template_playbook: true
```

**Benefits:** Reduces CI/CD startup time from ~60s to ~5s by caching Docker images on all nodes.

### deploy-image-cache.yml
Deploy DaemonSet for pre-pulling Docker images on all nodes.

**Usage:**
```yaml
uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
with:
  playbook: playbooks/deploy-image-cache.yml
  use_template_playbook: true
```

**Benefits:** Automatic image caching on all cluster nodes, reducing CI/CD startup times from ~60s to ~5s.

## Docker Image Caching Solutions

ARC runners experience slow startup times (~1 minute) due to repeated Docker image pulls.

## Docker Image Caching Solution

### Local Registry Caching (Recommended)
- Deploys local Docker registry in cluster
- Mirrors GHCR images locally with automatic updates every minute
- ARC runners pull from fast local registry instead of GHCR
- **Requires workflow changes** - update image URLs to use local registry
- Excellent performance improvement

### Performance Impact
| Method | First Pull | Cached Pulls | Setup |
|--------|------------|--------------|--------|
| No caching | ~60s | ~60s | None |
| Local registry | ~60s (once) | ~2s | Low | **Yes** ⚠️ |

## Workflow Changes Required

**You need to update your GitHub Actions workflows** to use the local registry URLs:

### Before (GHCR):
```yaml
- name: Run Ansible
  run: |
    docker run --rm \
      ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod:latest \
      ansible-playbook playbook.yml
```

### After (Local Registry):
```yaml
- name: Run Ansible
  run: |
    docker run --rm \
      localhost:5000/ansible-prod:latest \
      ansible-playbook playbook.yml
```

### For Additional Images:
```yaml
# If you add more images to the playbook:
- name: Run with multiple images
  run: |
    docker run --rm localhost:5000/my-other-image:latest
    docker run --rm localhost:5000/ubuntu-base:latest
```

**Deploy the registry first, then update your workflows!**

## Image Update Handling

The solution automatically detects and pulls image updates:

### Automatic Updates
- **Local Registry**: CronJob checks every minute for new image versions

### Manual Updates

**Force update local registry:**
```bash
# Trigger manual update job
kubectl create job -n image-cache manual-update --from=cronjob/registry-updater
```

**Check update status:**
```bash
# View registry update logs
kubectl get jobs -n image-cache
kubectl logs -n image-cache job/manual-update --tail=50
```

### Troubleshooting Updates

**Image not updating:**
```bash
# Check registry status
kubectl get pods -n image-cache
kubectl logs -n image-cache -l app=docker-registry

# Check CronJob status
kubectl get cronjob -n image-cache registry-updater
kubectl describe cronjob -n image-cache registry-updater
```

**Clear and rebuild cache:**
```bash
# Remove and redeploy
kubectl delete namespace image-cache
# Then redeploy with ansible playbook
```

## Adding Additional Images

To cache more images, edit the `deploy-image-cache.yml` playbook:

```yaml
# Add more images to the IMAGES variable (space-separated, colon-delimited):
IMAGES="ansible-prod:ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod:latest my-other-image:ghcr.io/myorg/myrepo:latest ubuntu-base:ubuntu:20.04"
```

Then redeploy:
```bash
kubectl delete namespace image-cache
ansible-playbook -i ansible/inventory.ini ansible/playbooks/deploy-image-cache.yml
```

**Available as:** `localhost:5000/image-key:latest` (e.g., `localhost:5000/my-other-image:latest`)

## Local Testing

Playbooks support local testing mode (automatically detected):
- Skips remote operations
- Skips GitHub API calls
- Allows structure validation

Set `LOCAL_TESTING=true` to explicitly enable.
