# Scripts

Local development scripts.

## format-lint-local.sh

Local linting script matching CI pipeline.

**Usage:**
```bash
./scripts/format-lint-local.sh
```

**Features:**
- YAML formatting with Prettier
- Syntax validation with yamllint
- Ansible best practices with ansible-lint

**Requirements:** Docker installed and running

## Docker Alternative

```bash
docker run --rm -v "$(pwd):/workspace" \
  ghcr.io/skiesgames/skiesdota-ci-cd-templates/ansible-prod:latest \
  bash .github/scripts/ansible-prod-lint.sh
```
