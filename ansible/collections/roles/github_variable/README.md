# GitHub Variable Role

GitHub variable management role.

## Features

- Upload SSH keys to GitHub Secrets

## Usage

```yaml
- role: github_variable
  tasks_from: upload_ssh_key
  env:
    GITHUB_TOKEN: token
    GITHUB_REPOSITORY: user/repo
```
