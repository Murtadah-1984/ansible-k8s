# PXE Nginx Role

This role configures nginx HTTP server for serving autoinstall files.

## Description

The pxe-nginx role:
- Ensures HTTP root directory exists
- Starts and enables nginx service

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- nginx package installed (via pxe-common role)

## Dependencies

- `pxe-common` role

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `http_root` | `/var/www/html` | HTTP root directory for autoinstall files |

## Example Playbook

```yaml
- hosts: pxe
  become: true
  roles:
    - pxe-common
    - pxe-nginx
```

## License

MIT

