# PXE Boot Role

This role deploys the PXE boot menu configuration.

## Description

The pxe-boot role:
- Creates pxelinux.cfg directory
- Deploys PXE boot menu configuration
- Configures Ubuntu autoinstall via cloud-init

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access

## Dependencies

- `pxe-tftp` role (for directory structure)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `tftp_root` | `/srv/tftp` | TFTP root directory |
| `pxe_ip` | `{{ ansible_default_ipv4.address }}` | PXE server IP address |
| `ubuntu_version` | `22.04` | Ubuntu version to install |

## Example Playbook

```yaml
- hosts: pxe
  become: true
  roles:
    - pxe-tftp
    - pxe-boot
  vars:
    ubuntu_version: "22.04"
```

## License

MIT

