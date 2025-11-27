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

## Local Testing

Playbooks support local testing mode (automatically detected):
- Skips remote operations
- Skips GitHub API calls
- Allows structure validation

Set `LOCAL_TESTING=true` to explicitly enable.
