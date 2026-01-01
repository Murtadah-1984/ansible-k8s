# PXE Autoinstall Role

This role deploys Ubuntu autoinstall configuration files for unattended installation.

## Description

The pxe-autoinstall role:
- Creates autoinstall directory in HTTP root
- Deploys user-data (cloud-init configuration)
- Deploys meta-data (instance metadata)
- Configures hostname, user, and SSH settings

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- nginx configured (via pxe-nginx role)

## Dependencies

- `pxe-nginx` role

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `http_root` | `/var/www/html` | HTTP root directory |
| `pxe_hostname` | `ubuntu-node` | Hostname for installed systems |
| `pxe_user` | `admin` | Username for installed systems |
| `pxe_password_hash` | `$6$REPLACE_ME` | Password hash (use `mkpasswd -m sha-512`) |
| `pxe_ssh_allow_pw` | `false` | Allow password authentication for SSH |

## Example Playbook

```yaml
- hosts: pxe
  become: true
  roles:
    - pxe-nginx
    - pxe-autoinstall
  vars:
    pxe_hostname: "k8s-node-01"
    pxe_user: "admin"
    pxe_password_hash: "$6$rounds=5000$salt$hashedpassword"
```

## Security Notes

- **IMPORTANT**: Replace `pxe_password_hash` with a proper password hash
- Generate hash using: `mkpasswd -m sha-512`
- Set `pxe_ssh_allow_pw: false` for production (use SSH keys instead)

## License

MIT

