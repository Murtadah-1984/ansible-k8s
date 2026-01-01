# Monitoring Role

This role installs and configures monitoring components for Kubernetes nodes.

## Description

The monitoring role sets up:
- **journald** - Systemd journal configuration for log management
- **logrotate** - Log rotation configuration
- **chrony** - Time synchronization service
- **node_exporter** - Prometheus metrics exporter
- **fluent-bit** - Log shipping to Loki

## Requirements

- Ansible 2.9+
- Ubuntu 22.04 LTS
- Root or sudo access
- Systemd (required for journald and services)

## Dependencies

- `common` role (should run first)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `node_exporter_version` | `"1.10.2"` | Node Exporter version to install |
| `node_exporter_enabled` | `true` | Enable/disable node_exporter installation |
| `fluent_bit_version` | `"4.2.0"` | Fluent Bit version to install |
| `fluent_bit_enabled` | `true` | Enable/disable Fluent Bit installation |
| `loki_host` | `"loki.default.svc"` | Loki hostname for log shipping |
| `loki_port` | `3100` | Loki port for log shipping |
| `chrony_enabled` | `true` | Enable/disable chrony installation |
| `chrony_ntp_pools` | `["time.cloudflare.com iburst", "pool.ntp.org iburst"]` | NTP pools for chrony |
| `journald_enabled` | `true` | Enable/disable journald configuration |
| `journald_system_max_use` | `"100M"` | Maximum disk space for journal files |
| `journald_runtime_max_use` | `"50M"` | Maximum runtime disk space |
| `journald_max_retention_sec` | `"1month"` | Maximum retention period |
| `logrotate_enabled` | `true` | Enable/disable logrotate configuration |

## Example Playbook

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - common
    - monitoring
      vars:
        loki_host: "loki.monitoring.svc.cluster.local"
        loki_port: 3100
```

## Handlers

- `restart systemd-journald` - Restarts journald after configuration changes
- `restart chrony` - Restarts chrony after configuration changes
- `restart node_exporter` - Restarts node_exporter after configuration changes
- `restart fluent-bit` - Restarts fluent-bit after configuration changes

## Templates

- `templates/chrony.conf.j2` - Chrony configuration template
- `templates/node_exporter.service.j2` - Node Exporter systemd service template
- `templates/fluent-bit.conf.j2` - Fluent Bit configuration template
- `templates/fluent-bit.service.j2` - Fluent Bit systemd service template

## License

MIT

