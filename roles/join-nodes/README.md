# Join Nodes Role

This role joins nodes to a Kubernetes cluster using `kubeadm join`.

## Description

The join-nodes role:
- Validates prerequisites (kubeadm installed, containerd running)
- Optionally auto-fetches join tokens from control plane
- Executes `kubeadm join` with proper configuration
- Waits for kubelet to be ready
- Verifies successful join

## Requirements

- Ansible 2.9+
- kubeadm installed on target nodes
- containerd running
- Valid join token and CA cert hash
- Network connectivity to API server

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `join_token` | `""` | kubeadm join token (required) |
| `discovery_token_ca_cert_hash` | `""` | CA certificate hash (required) |
| `api_server_endpoint` | `""` | API server endpoint (required) |
| `auto_fetch_join_info` | `false` | Auto-fetch token and hash from control plane |
| `control_plane_host` | `{{ groups['control'][0] }}` | Control plane host for auto-fetch |
| `node_labels` | `[]` | Node labels to apply during join |
| `node_taints` | `[]` | Node taints to apply during join |
| `skip_if_already_joined` | `true` | Skip join if node is already part of cluster |

## Example Playbook

```yaml
- hosts: workers
  become: true
  roles:
    - join-nodes
  vars:
    join_token: "abc123.xyz789"
    discovery_token_ca_cert_hash: "sha256:..."
    api_server_endpoint: "control-plane:6443"
```

## License

MIT

