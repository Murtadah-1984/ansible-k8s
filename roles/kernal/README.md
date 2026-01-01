# Kernal Role

This role configures required kernel modules for Kubernetes.

## Description

The kernal role ensures required kernel modules are loaded and configured for Kubernetes, including:
- Overlay filesystem module
- Bridge netfilter module
- IP forwarding configuration
- Kernel parameter tuning

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access

## Dependencies

- `common` role (should run first)

## Variables

This role uses default kernel module names and does not require custom variables.

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - common
    - kernal
```

## Handlers

None

## License

MIT

