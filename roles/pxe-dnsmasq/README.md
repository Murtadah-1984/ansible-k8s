# PXE DNSMasq Role

This role configures dnsmasq as a DHCP and TFTP server for PXE boot.

## Description

The pxe-dnsmasq role:
- Configures dnsmasq with DHCP and TFTP support
- Sets up DHCP range and lease time
- Enables PXE boot for both BIOS and UEFI clients
- Configures TFTP root directory

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- dnsmasq package installed (via pxe-common role)

## Dependencies

- `pxe-common` role

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `pxe_interface` | `{{ ansible_default_ipv4.interface }}` | Network interface for PXE |
| `pxe_ip` | `{{ ansible_default_ipv4.address }}` | PXE server IP address |
| `dhcp_range_start` | `192.168.100.50` | DHCP range start IP |
| `dhcp_range_end` | `192.168.100.100` | DHCP range end IP |
| `dhcp_lease_time` | `12h` | DHCP lease time |
| `tftp_root` | `/srv/tftp` | TFTP root directory |

## Example Playbook

```yaml
- hosts: pxe
  become: true
  roles:
    - pxe-common
    - pxe-dnsmasq
  vars:
    pxe_interface: eno1
    dhcp_range_start: 192.168.100.50
    dhcp_range_end: 192.168.100.100
```

## License

MIT

