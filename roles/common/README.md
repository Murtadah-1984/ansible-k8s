# Common Role

This role provides common system configuration and prerequisites for Kubernetes nodes.

## Description

The common role performs base system setup tasks including:
- OS version validation (Ubuntu 22.04 LTS)
- Cloud-init completion wait
- Kubernetes repository cleanup
- APT cache management
- UUID runtime installation
- Node uniqueness verification script installation

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- Network connectivity

## Dependencies

None

## Variables

This role has no default variables. It uses Ansible facts and inventory hostnames.

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - common
```

## Files

- `files/verify-node-uniqueness.sh` - Script to verify node uniqueness

## Handlers

None

## License

MIT

