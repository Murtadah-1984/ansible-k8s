# Hardening Role

This role implements CIS Ubuntu 24.04 LTS STIG compliance and security hardening.

## Description

The hardening role implements automated security recommendations from the CIS Ubuntu Linux 24.04 LTS STIG Benchmark v1.0.0, including:
- Package removal (prohibited services)
- System configuration hardening
- SSH daemon security settings
- Firewall (UFW) configuration
- Fail2ban configuration
- AIDE (Advanced Intrusion Detection Environment) setup
- Postfix local-only configuration
- System auditing configuration

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS or 24.04 LTS
- Root or sudo access

## Dependencies

- `common` role (should run first)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `grub_password_hash` | `'CHANGE_ME'` | GRUB bootloader password hash (generate with `grub-mkpasswd-pbkdf2`) |
| `disable_swap` | `true` | Disable swap (required for Kubernetes) |
| `kubernetes_ports` | `["10250", "10256", "30000:32767"]` | Kubernetes ports to allow through UFW |

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - role: hardening
      vars:
        grub_password_hash: 'grub.pbkdf2.sha512.10000.ABC123...'
```

## Handlers

- `Restart SSH` - Restarts SSH service after configuration changes

## License

MIT

