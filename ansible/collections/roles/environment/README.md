# Environment Role

Environment file management role.

## Features

- Create .env file from variables
- Set secure permissions

## Usage

```yaml
- role: environment
  vars:
    app_dir: /opt/app
    env:
      ENV_FILE_CONTENTS: |
        KEY=value
```
