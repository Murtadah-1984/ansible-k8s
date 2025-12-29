# Kubernetes Cluster Bootstrap Guide

This guide explains how to bootstrap a complete Kubernetes cluster using the `cluster-bootstrap.yml` playbook.

## Overview

The cluster bootstrap playbook automates the complete setup of a Kubernetes cluster following CIS best practices:

1. **Node Preparation**: Prepares all nodes (control plane + workers) with required software
2. **Cluster Initialization**: Initializes the first control plane node
3. **High Availability**: Joins additional control plane nodes for HA
4. **Worker Joining**: Joins all worker nodes to the cluster
5. **CNI Installation**: Installs and configures the container network interface
6. **CIS Compliance**: Applies CIS-compliant configurations

## Prerequisites

### Infrastructure Requirements

- **Control Plane Nodes**: Minimum 1 (recommended: 3 for HA)
- **Worker Nodes**: Minimum 1
- **Network**: All nodes must be able to communicate with each other
- **Load Balancer** (optional): For HA control plane setup

### Software Requirements

- Ansible 2.9+ installed on the control machine
- SSH access to all nodes
- Python 3.6+ on all nodes
- All nodes running Ubuntu 24.04 LTS

### Pre-Bootstrap Steps

1. **Prepare Inventory**: Ensure `inventory.ini` is correctly configured
2. **SSH Access**: Verify SSH key-based authentication works
3. **Network Connectivity**: Test connectivity between nodes
4. **DNS Resolution**: Ensure hostnames resolve correctly (or use IPs)

## Quick Start

### 1. Bootstrap All Nodes

First, prepare all nodes with required software:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

This will:
- Install and configure containerd
- Install Kubernetes components (kubelet, kubeadm, kubectl)
- Apply security hardening
- Configure kernel parameters
- Pull required container images

### 2. Bootstrap the Cluster

Initialize and configure the Kubernetes cluster:

```bash
ansible-playbook -i inventory.ini cluster-bootstrap.yml
```

## Configuration

### Variables

Configure cluster settings in `group_vars/all.yml`:

```yaml
# Cluster Configuration
cluster_name: "kubernetes"
pod_network_cidr: "10.244.0.0/16"
service_cidr: "10.96.0.0/12"
control_plane_endpoint: "k8s-api.example.com:6443"  # For HA setup
cni_plugin: "calico"  # Options: calico, flannel
allow_pods_on_control_plane: false
```

### Inventory Structure

The playbook expects the following inventory groups:

```ini
[control]
k8s-cp-01 ansible_host=10.0.20.11
k8s-cp-02 ansible_host=10.0.20.12
k8s-cp-03 ansible_host=10.0.20.13

[workers]
k8s-worker-01 ansible_host=10.0.30.11
k8s-worker-02 ansible_host=10.0.30.12
# ... more workers
```

## Playbook Execution Flow

### Phase 1: Node Bootstrap
- Runs on: `control:workers`
- Prepares all nodes with Kubernetes prerequisites
- Installs containerd, kubelet, kubeadm, kubectl
- Applies security hardening

### Phase 2: Cluster Initialization
- Runs on: `control[0]` (first control plane node)
- Initializes the Kubernetes cluster using kubeadm
- Generates join commands for other nodes
- Sets up kubectl configuration

### Phase 3: Join Control Plane Nodes
- Runs on: `control[1:]` (additional control plane nodes)
- Joins nodes to the cluster as control plane nodes
- Sets up HA control plane

### Phase 4: Join Worker Nodes
- Runs on: `workers`
- Joins worker nodes to the cluster

### Phase 5: Install CNI
- Runs on: `control[0]`
- Installs and configures the container network interface
- Waits for CNI pods to be ready

### Phase 6: Cluster Configuration
- Applies CIS-compliant cluster configurations
- Sets up Pod Security Standards
- Displays cluster status

## High Availability Setup

For a highly available control plane:

1. **Set up Load Balancer**: Configure a load balancer pointing to all control plane nodes
2. **Set Control Plane Endpoint**: Update `control_plane_endpoint` in `group_vars/all.yml`
3. **Run Bootstrap**: The playbook will automatically configure HA

Example:
```yaml
control_plane_endpoint: "k8s-api.example.com:6443"
```

## CNI Plugins

### Supported CNI Plugins

- **Calico** (default): Full-featured networking and network policy
- **Flannel**: Simple overlay network

To change the CNI plugin, set in `group_vars/all.yml`:
```yaml
cni_plugin: "flannel"  # or "calico"
```

## Verification

After bootstrap completes, verify the cluster:

```bash
# From the first control plane node
ssh k8s-cp-01
kubectl get nodes
kubectl get pods -n kube-system
kubectl cluster-info
```

Or copy the kubeconfig to your local machine:

```bash
scp mhadmin@10.0.20.11:/etc/kubernetes/admin.conf ~/.kube/config
kubectl get nodes
```

## Troubleshooting

### Cluster Already Initialized

If you need to reinitialize:

```bash
# On control plane nodes
kubeadm reset --force
rm -rf /etc/kubernetes/*
rm -rf /var/lib/etcd/*

# On worker nodes
kubeadm reset --force
```

Then rerun the bootstrap playbook.

### Nodes Not Joining

1. Check network connectivity between nodes
2. Verify firewall rules allow required ports
3. Check kubelet logs: `journalctl -u kubelet -f`
4. Verify join commands are correct

### CNI Not Working

1. Check CNI pods: `kubectl get pods -n kube-system`
2. Check CNI logs: `kubectl logs -n kube-system <cni-pod-name>`
3. Verify pod network CIDR doesn't conflict with host network

### Certificate Issues

If certificates expire or are invalid:

```bash
# Regenerate certificates (on first control plane)
kubeadm certs renew all
systemctl restart kubelet
```

## CIS Compliance

The playbook implements CIS Kubernetes Benchmark v1.8.0 requirements:

- ✅ Worker node configuration file security
- ✅ Kubelet security settings
- ✅ Control plane component security
- ✅ API server security configuration
- ✅ Controller manager security
- ✅ Scheduler security
- ✅ Pod Security Standards

Run kube-bench to verify compliance:

```bash
# Install kube-bench
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

# Check results
kubectl logs -f job/kube-bench
```

## Security Considerations

1. **Kubeconfig Security**: The admin.conf file contains cluster admin credentials. Protect it accordingly.
2. **Certificate Management**: kubeadm manages certificates automatically. For production, consider external CA.
3. **Network Policies**: Install and configure network policies after CNI installation.
4. **RBAC**: Review and configure RBAC policies for your use case.
5. **Pod Security**: The playbook applies restricted Pod Security Standards. Adjust as needed.

## Next Steps

After successful bootstrap:

1. **Install Ingress Controller**: Deploy an ingress controller (e.g., NGINX, Traefik)
2. **Configure Storage**: Set up persistent storage (e.g., local-path-provisioner, NFS, Ceph)
3. **Install Monitoring**: Deploy monitoring stack (Prometheus, Grafana)
4. **Configure Backup**: Set up etcd backup procedures
5. **Review Security**: Run security scans and apply additional hardening

## Support

For issues or questions:
- Check playbook logs: `ansible-playbook -i inventory.ini cluster-bootstrap.yml -vvv`
- Review node logs: `journalctl -u kubelet -f`
- Verify inventory configuration
- Check network connectivity

