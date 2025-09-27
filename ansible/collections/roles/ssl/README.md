# SSL Role

SSL certificate management role.

## Features

- Deliver and setup certificates
- Create chained certificates
- Cleanup

## Usage

```yaml
- role: ssl
  vars:
    app_dir: /opt/app
  env:
    CERTIFICATE_CRT: cert
```
