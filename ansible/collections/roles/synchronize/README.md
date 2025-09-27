# Synchronize Role

File synchronization utilities role.

## Features

- Rsync files excluding .git

## Usage

```yaml
- role: synchronize
  vars:
    app_dir: /opt/app
  env:
    CI_PROJECT_DIR: /workspace
```
