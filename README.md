# SkiesDotaGitlab-CI-Templates

## Usage

In your project's `.gitlab-ci.yml`:

```yaml
include:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/common.yml'
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/jobs.yml'
  # Optionally:
  - project: 'SkiesGames/SkiesDotaGitlab-CI-Templates'
    file: '/ansible/add_ssh_key.yml'
```

## Available Jobs

- `bootstrap`: Runs the Ansible bootstrap playbook.
- `deploy`: Runs the Ansible deploy playbook.
- `add_ssh_key`: Generates and uploads an ephemeral SSH key.

## Shared Blocks

- `.common_before_script`: Sets up SSH, Ansible, and dependencies.
- `.generate_inventory`: Generates the Ansible inventory file.
