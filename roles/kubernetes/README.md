# Kubernetes Role

This role installs and configures Kubernetes components (kubelet, kubeadm, kubectl).

## Description

The kubernetes role:
- Verifies prerequisites (swap disabled, kernel modules)
- Configures Kubernetes APT repository
- Installs kubelet, kubeadm, and kubectl
- Configures kubelet with CIS-compliant settings
- Sets proper file permissions and ownership (CIS requirements)
- Prepares nodes for cluster initialization or joining

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- Swap disabled
- Kernel modules loaded (kernal role)
- Containerd installed (containerd role)

## Dependencies

- `common` role
- `kernal` role
- `containerd` role

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `kubernetes_version` | From group_vars | Kubernetes version to install (e.g., "1.28") |
| `pod_network_cidr` | `10.244.0.0/16` | Pod network CIDR |
| `service_cidr` | `10.96.0.0/12` | Service CIDR |

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
```

## Templates

- `templates/kubeadm-init-config.yaml.j2` - kubeadm initialization configuration
- `templates/kubelet-config.yaml.j2` - kubelet configuration

## Handlers

- `Restart kubelet` - Restarts kubelet service after configuration changes

## License

MIT

