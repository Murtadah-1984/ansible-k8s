# PXE Common Role

This role installs base packages required for PXE server functionality.

## Description

The pxe-common role installs essential packages needed for PXE boot server:
- dnsmasq (DHCP/TFTP server)
- syslinux-common (PXE boot files)
- pxelinux (PXE bootloader)
- tftp-hpa (TFTP server)
- nginx (HTTP server for autoinstall files)
- grub-efi-amd64-bin (UEFI boot support)
- unzip, wget (utilities)

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `pxe_base_packages` | See defaults | List of packages to install |

## Example Playbook

```yaml
- hosts: pxe
  become: true
  roles:
    - pxe-common
```

## License

MIT

