# Cluster Bootstrap Role

This role bootstraps a complete Kubernetes cluster following CIS best practices.

## Description

The cluster-bootstrap role orchestrates the complete Kubernetes cluster initialization process:

- Initializes the first control plane node with `kubeadm init`
- Installs essential control plane tools (Helm, calicoctl, kube-bench, Argo CD CLI)
- Joins additional control plane nodes for HA setup
- Joins worker nodes to the cluster
- Installs and configures CNI plugin (Calico or Flannel)
- Configures cluster access and displays cluster information
- Applies CIS-compliant cluster configurations

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- All nodes must be prepared with node-bootstrap playbook first
- SSH access to all nodes
- Network connectivity between nodes

## Dependencies

This role requires the following roles to be executed first (via playbook):

- `common` - Base system configuration
- `hardening` - System hardening
- `kernal` - Kernel configuration
- `containerd` - Container runtime
- `kubernetes` - Kubernetes components installation
- `images` - Container image preloading
- `monitoring` - Monitoring components (optional)
- `cleanup` - System cleanup

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cluster_name` | `kubernetes` | Cluster name |
| `pod_network_cidr` | `10.244.0.0/16` | Pod network CIDR |
| `service_cidr` | `10.96.0.0/12` | Service CIDR |
| `control_plane_endpoint` | `""` | Load balancer endpoint (optional, for HA) |
| `cni_plugin` | `calico` | CNI plugin to use (`calico` or `flannel`) |
| `calico_version` | `v3.27.0` | Calico version |
| `calicoctl_version` | `v3.31.3` | calicoctl version |
| `allow_pods_on_control_plane` | `false` | Allow pods to run on control plane nodes |
| `node_bootstrap_serial` | `1` | Number of nodes to bootstrap in parallel |

## Example Playbook

```yaml
---
# Bootstrap all nodes first
- name: Bootstrap All Kubernetes Nodes
  hosts: control:workers
  become: true
  gather_facts: true
  serial: "{{ node_bootstrap_serial }}"
  
  roles:
    - common
    - hardening
    - kernal
    - containerd
    - kubernetes
    - images
    - monitoring
    - cleanup

# Then bootstrap the cluster
- name: Bootstrap Kubernetes Cluster
  hosts: control:workers
  become: true
  gather_facts: true
  
  roles:
    - cluster-bootstrap
```

## Task Files

The role is organized into separate task files:

- `tasks/main.yml` - Main entry point that orchestrates all tasks
- `tasks/init_control_plane.yml` - Initialize first control plane node
- `tasks/control_plane_tools.yml` - Install control plane tools
- `tasks/join_control_plane.yml` - Join additional control plane nodes
- `tasks/join_workers.yml` - Join worker nodes
- `tasks/install_cni.yml` - Install CNI plugin
- `tasks/configure_access.yml` - Configure cluster access
- `tasks/cis_config.yml` - Apply CIS-compliant configurations

## Templates

- `templates/kubeadm-init-config.yaml.j2` - kubeadm initialization configuration (CIS-compliant)

## Process Flow

1. **First Control Plane Node** (`control[0]`):
   - Checks if cluster is already initialized
   - Generates kubeadm configuration
   - Initializes cluster with `kubeadm init`
   - Sets up kubectl configuration
   - Waits for API server to be ready
   - Saves join commands for other nodes

2. **All Control Plane Nodes**:
   - Install control plane tools (Helm, calicoctl, kube-bench, Argo CD CLI)
   - Create kubectl alias 'k'

3. **Additional Control Plane Nodes** (`control[1:]`):
   - Retrieve join command from first control plane
   - Join cluster as control plane node
   - Wait for node to be ready

4. **Worker Nodes**:
   - Retrieve join command from first control plane
   - Join cluster as worker node
   - Wait for node to be ready

5. **First Control Plane Node**:
   - Install CNI plugin (Calico or Flannel)
   - Wait for CNI pods to be ready
   - Wait for all nodes to be Ready
   - Display cluster information
   - Apply CIS-compliant configurations

## Security Features

- CIS-compliant kubeadm configuration
- Pod Security Standards (Restricted) applied to kube-system namespace
- Secure certificate handling with `no_log: true`
- Proper file permissions on sensitive files

## Notes

- The role is idempotent - it checks if nodes are already joined before attempting to join
- For HA setups, ensure `control_plane_endpoint` is configured
- The first control plane node must be initialized before other nodes can join
- CNI plugin installation waits for pods to be ready before proceeding

## License

MIT

