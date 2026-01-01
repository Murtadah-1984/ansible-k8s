# PXE TFTP Role

This role sets up the TFTP server and copies PXE boot files.

## Description

The pxe-tftp role:
- Creates TFTP directory structure
- Copies PXE BIOS boot files (pxelinux.0, menu.c32, ldlinux.c32)
- Copies UEFI GRUB boot file (grubx64.efi)
- Ensures TFTP service is running

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- syslinux-common and grub-efi-amd64-bin packages installed (via pxe-common role)

## Dependencies

- `pxe-common` role

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `tftp_root` | `/srv/tftp` | TFTP root directory |

## Example Playbook

```yaml
- hosts: pxe
  become: true
  roles:
    - pxe-common
    - pxe-tftp
```

## License

MIT

