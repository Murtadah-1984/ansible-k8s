# Images Role

This role pre-pulls required container images for Kubernetes.

## Description

The images role pre-pulls container images to reduce initialization time:
- Kubernetes control plane images
- Core DNS images
- CNI plugin images (if configured)
- Pause container image

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- Containerd installed and running
- crictl available

## Dependencies

- `containerd` role (must run first)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `kubernetes_version` | From group_vars | Kubernetes version for image tags |
| `cni_plugin` | `calico` | CNI plugin to pre-pull images for |

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - containerd
    - kubernetes
    - images
```

## Handlers

None

## License

MIT

