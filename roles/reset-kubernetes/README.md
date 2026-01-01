# Reset Kubernetes Role

This role performs a complete reset of Kubernetes nodes, gracefully stopping services and cleaning up all Kubernetes-related files.

## Description

The reset-kubernetes role:
- Gracefully stops static pods (kube-apiserver, etcd, etc.)
- Stops kubelet and containerd services
- Runs kubeadm reset
- Cleans CNI configurations and artifacts
- Removes Kubernetes state directories
- Cleans containerd runtime data
- Optionally removes kubeconfig directories

**WARNING:** This role will destroy all Kubernetes cluster state!

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- Kubernetes cluster nodes

## Dependencies

None (standalone role for reset operations)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `perform_reset` | `false` | Safety flag - MUST be set to true to proceed |
| `remove_kubeconfig` | `false` | Remove ~/.kube directories |

## Example Playbook

```yaml
- hosts: all
  become: true
  vars:
    perform_reset: true
  roles:
    - reset-kubernetes
```

## Safety Features

- Requires explicit `perform_reset=true` variable
- Gracefully stops static pods before reset
- Does NOT flush iptables globally (per Kubernetes docs)
- Does NOT remove ~/.kube unless explicitly requested

## Handlers

This role does not use handlers as it performs direct service management for reset operations.

## License

MIT

