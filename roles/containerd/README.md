# Containerd Role

This role installs and configures containerd container runtime for Kubernetes.

## Description

The containerd role:
- Installs containerd package
- Configures containerd with Kubernetes-compatible settings
- Sets SystemdCgroup for Kubernetes compatibility
- Configures sandbox image (pause container)
- Manages containerd service

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- Kernel modules configured (kernal role)

## Dependencies

- `common` role
- `kernal` role

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `containerd_version` | Latest | Containerd version to install |
| `containerd_sandbox_image` | `registry.k8s.io/pause:3.10` | Sandbox image for Kubernetes |

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - common
    - kernal
    - containerd
```

## Templates

- `templates/config.toml.j2` - Full containerd configuration template
- `templates/config-minimal.toml.j2` - Minimal Kubernetes-ready configuration template

## Handlers

- `Restart containerd` - Restarts containerd service after configuration changes

## License

MIT

