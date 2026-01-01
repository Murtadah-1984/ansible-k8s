# PXE Ubuntu Netboot Role

This role downloads Ubuntu ISO and extracts kernel and initrd for PXE boot.

## Description

The pxe-ubuntu-netboot role:
- Downloads Ubuntu ISO image
- Mounts ISO and extracts vmlinuz and initrd
- Copies files to TFTP directory
- Cleans up ISO file after extraction

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- Sufficient disk space for ISO download

## Dependencies

- `pxe-tftp` role (for directory structure)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `tftp_root` | `/srv/tftp` | TFTP root directory |
| `ubuntu_version` | `22.04` | Ubuntu version |
| `ubuntu_iso_url` | See defaults | Ubuntu ISO download URL |
| `ubuntu_iso_dest` | `/tmp/ubuntu.iso` | Local path for ISO download |
| `iso_mount_point` | `/mnt` | ISO mount point |

## Example Playbook

```yaml
- hosts: pxe
  become: true
  roles:
    - pxe-tftp
    - pxe-ubuntu-netboot
  vars:
    ubuntu_version: "22.04"
    ubuntu_iso_url: "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
```

## Notes

- The role is idempotent - it checks if files already exist before downloading
- ISO file is removed after extraction to save disk space
- Ensure sufficient disk space for ISO download (typically 2-4 GB)

## License

MIT

