# SkiesDota CI/CD Templates

GitHub Actions template repository for Ansible automation and infrastructure management.

## Quick Start

1. **Configure Secrets**: Set up required GitHub Secrets (see Configuration)
2. **Use Workflows**: Call reusable workflows from your repositories
3. **Deploy**: Run playbooks via GitHub Actions

## Workflows

- `ci-cd.prod.yml`: Main production pipeline with smart change detection
- `reusable-ansible.yml`: Execute Ansible playbooks
- `reusable-ssh-key-setup.yml`: SSH key generation and distribution

## Playbooks

See `ansible/playbooks/README.md` for details.

- `bootstrap-k3s.yml`: Bootstrap HA K3s cluster
- `deploy-infra-services.yml`: Deploy cert-manager, Let's Encrypt
- `deploy-github-runner.yml`: Deploy GitHub Actions self-hosted runners

## Configuration

### Required Secrets

- `ANSIBLE_HOSTS`: Multi-line list of target host IPs
- `ANSIBLE_USER`: SSH username
- `SSH_PRIVATE_KEY`: Private SSH key for authentication
- `K3S_TOKEN`: K3s cluster token

### Initial Setup

1. Configure `ANSIBLE_HOSTS`, `ANSIBLE_HOSTS_PASSWORD`, `ANSIBLE_USER`
2. Run "Reusable SSH Key Setup" workflow
3. Store generated key as `SSH_PRIVATE_KEY` secret
4. Delete `ANSIBLE_HOSTS_PASSWORD` after setup

## Usage Example

```yaml
jobs:
  bootstrap:
    uses: SkiesGames/SkiesDota-CI-CD-Templates/.github/workflows/reusable-ansible.yml@main
    with:
      playbook: playbooks/bootstrap-k3s.yml
      use_template_playbook: true
    secrets:
      ANSIBLE_HOSTS: ${{ secrets.ANSIBLE_HOSTS }}
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

## Local Development

```bash
./scripts/format-lint-local.sh
```

## Directory Structure

```
├── .github/workflows/    # CI/CD workflows
├── .github/actions/      # Custom actions
├── ansible/playbooks/    # Ansible playbooks
├── scripts/              # Local development scripts
└── Dockerfile.ansible.prod  # Ansible Docker image
```

## License

MIT License
