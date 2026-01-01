# Cleanup Role

This role performs system cleanup and optimization after Kubernetes installation.

## Description

The cleanup role:
- Removes unnecessary packages
- Cleans APT cache
- Removes temporary files
- Optimizes system settings
- Performs final system checks

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access

## Dependencies

Should run after all other roles have completed.

## Variables

This role uses default cleanup operations and does not require custom variables.

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - common
    - hardening
    - kernal
    - containerd
    - kubernetes
    - images
    - cleanup
```

## Handlers

None

## License

MIT

