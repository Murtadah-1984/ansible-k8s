# CIS Ubuntu 24.04 LTS STIG Implementation

This repository has been updated to implement the CIS Ubuntu Linux 24.04 LTS STIG Benchmark v1.0.0 recommendations.

## Changes Made

### 1. Version Update
- Updated `roles/common/tasks/main.yml` to check for Ubuntu 24.04 LTS instead of 22.04

### 2. Comprehensive Hardening Role
The `roles/hardening/tasks/main.yml` has been completely rewritten to implement automated CIS STIG recommendations including:

#### Package Management
- **UBTU-24-100010**: Removes `systemd-timesyncd` package
- **UBTU-24-100020**: Removes `ntp` package  
- **UBTU-24-100030**: Removes `telnetd` package (CAT I)
- **UBTU-24-100040**: Removes `rsh-server` package (CAT I)
- Installs required security packages:
  - `aide`, `aide-common` - File integrity monitoring
  - `auditd`, `audispd-plugins` - Audit logging
  - `apparmor` - Application security framework
  - `chrony` - Time synchronization
  - `openssh-server`, `openssh-client` - Secure shell
  - `rsyslog` - System logging
  - `ufw` - Firewall
  - `libpam-pwquality` - Password quality
  - `sssd`, `libpam-sss`, `libnss-sss` - Multi-factor authentication
  - `opensc-pkcs11`, `libpam-pkcs11` - PIV credential support
  - `vlock` - Session locking

#### Service Configuration
- **UBTU-24-100200**: Enables and starts `rsyslog` service
- **UBTU-24-100410**: Enables and starts `auditd` service
- **UBTU-24-100510**: Enables and starts `apparmor` service
- **UBTU-24-100700**: Enables and starts `chronyd` service
- **UBTU-24-100810**: Enables and starts `ssh` service
- **UBTU-24-100660**: Enables and starts `sssd` service
- **UBTU-24-100310**: Enables UFW firewall with default deny policy

#### File Integrity Monitoring (AIDE)
- **UBTU-24-90890**: Configures AIDE to protect audit tools with cryptographic mechanisms
- **UBTU-24-100110**: Initializes AIDE database
- **UBTU-24-100130**: Configures AIDE to notify on baseline changes (`SILENTREPORTS=no`)

#### SSH Hardening
- **UBTU-24-100820**: Configures FIPS 140-3 approved ciphers
- **UBTU-24-100830**: Configures FIPS 140-3 approved MACs
- **UBTU-24-100840**: Configures FIPS-validated key exchange algorithms
- **UBTU-24-100850**: Configures SSH client with FIPS-approved ciphers
- **UBTU-24-100860**: Configures SSH client with FIPS-approved MACs
- Additional SSH hardening:
  - `PermitRootLogin no`
  - `PasswordAuthentication no`
  - `X11Forwarding no`
  - `PermitEmptyPasswords no`
  - `AllowTcpForwarding no`
  - `ClientAliveInterval 300`
  - `ClientAliveCountMax 2`

#### System Limits and Session Management
- **UBTU-24-200000**: Limits concurrent sessions to 10 per account
- **UBTU-24-200060**: Configures session timeout (TMOUT=600 seconds)

#### Boot Security
- **UBTU-24-102000**: Configures GRUB boot password (requires `grub_password_hash` variable)
- **UBTU-24-102010**: Enables audit at system startup (`audit=1` in GRUB)

#### File Permissions
- Sets correct permissions on:
  - `/etc/passwd` - 0644
  - `/etc/shadow` - 0640
  - `/etc/group` - 0644
  - `/etc/gshadow` - 0640
  - `/etc/ssh/sshd_config` - 0600

#### Password Policy
- **UBTU-24-100600**: Configures password quality requirements:
  - `minlen = 14`
  - `dcredit = -1`
  - `ucredit = -1`
  - `ocredit = -1`
  - `lcredit = -1`

#### Network Security (sysctl)
Configures network security parameters:
- Reverse path filtering
- Disables ICMP redirects
- Disables source routing
- Enables TCP SYN cookies
- Enables martian packet logging

#### Service Disabling
- Disables unnecessary services:
  - `snapd`
  - `bluetooth`
  - `avahi-daemon`

### 3. Enhanced Audit Role
The `roles/audit/tasks/main.yml` has been updated to check Ubuntu 24.04 STIG compliance:

- OS version verification (Ubuntu 24.04)
- Prohibited packages check
- Required packages verification
- Service status checks
- SSH configuration validation
- File permissions verification
- Sysctl network security checks
- AIDE installation and configuration
- Password policy verification
- System limits verification
- GRUB configuration checks
- AppArmor status

## Configuration

### Required Variables

To configure GRUB boot password, set the `grub_password_hash` variable in your playbook or group_vars:

```yaml
grub_password_hash: 'grub.pbkdf2.sha512.10000.YOUR_HASH_HERE'
```

Generate the hash with:
```bash
grub-mkpasswd-pbkdf2
```

### Optional Variables

```yaml
# Disable swap (default: true, required for Kubernetes)
disable_swap: true

# Kubernetes ports to allow through UFW
kubernetes_ports:
  - "10250"
  - "10256"
  - "30000:32767"
```

## Usage

Run the playbook to apply hardening:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

Run the audit role to check compliance:

```bash
ansible-playbook -i inventory.ini roles/audit/tasks/main.yml
```

Or include the audit role in your playbook:

```yaml
- name: Kubernetes Node Bootstrap (Bare Metal)
  hosts: k8s_nodes
  become: true
  gather_facts: true

  roles:
    - common
    - hardening
    - audit  # Add this to run compliance checks
    # ... other roles
```

## Manual Steps Required

Some STIG recommendations require manual configuration:

1. **UBTU-24-100110**: AIDE initialization - The role attempts to initialize AIDE, but you may need to run `aideinit` manually and copy the database
2. **UBTU-24-100120**: AIDE cron configuration - Verify the default AIDE cron job is in place
3. **UBTU-24-100450**: Audit log offloading - Configure remote audit server if needed
4. **UBTU-24-102000**: GRUB password - Set `grub_password_hash` variable or configure manually
5. **UBTU-24-200250, UBTU-24-200640, UBTU-24-200660, UBTU-24-200680**: Manual audit rule configuration
6. **UBTU-24-400370**: Manual PAM configuration for specific use cases
7. **UBTU-24-600090, UBTU-24-600130, UBTU-24-600200**: Manual log configuration
8. **UBTU-24-700300, UBTU-24-700400**: Manual system configuration
9. **UBTU-24-900920, UBTU-24-900950, UBTU-24-900960**: Manual application-specific configurations

## References

- [CIS Ubuntu Linux 24.04 LTS STIG Benchmark v1.0.0](CIS_Ubuntu_Linux_24.04_LTS_STIG_Benchmark_v1.0.0.md)
- [CIS Controls](https://www.cisecurity.org/controls/)

## Notes

- This implementation focuses on **automated** recommendations from the STIG
- Manual recommendations should be reviewed and implemented based on your specific environment
- Test thoroughly in a non-production environment before deploying
- Some configurations may need adjustment based on your specific use case (e.g., Kubernetes requirements)

