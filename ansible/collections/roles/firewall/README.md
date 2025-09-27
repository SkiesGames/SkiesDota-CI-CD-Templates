# Firewall Role

UFW firewall configuration role.

## Features

- Install and enable UFW
- Open specified ports

## Usage

```yaml
- role: firewall
  vars:
    ports:
      - port: 22
        proto: tcp
```
