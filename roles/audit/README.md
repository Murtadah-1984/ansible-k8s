# Audit Role

This role configures system auditing and logging for Kubernetes nodes.

## Description

The audit role:
- Configures auditd for system auditing
- Sets up audit rules for Kubernetes components
- Configures log rotation
- Ensures audit logs are properly managed

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access

## Dependencies

- `common` role (should run first)

## Variables

This role uses default audit configurations and does not require custom variables.

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - common
    - audit
```

## Handlers

None

## License

MIT

