# TrueNAS Files VM - Deployment Summary

## Overview

Successfully configured Terraform module for deploying a TrueNAS SCALE appliance to serve as the primary NAS for media files, ROM collections, and backups.

## What Was Created

### 1. **main.tf** - VM Resource Definition

- Fully documented module instantiation using `vm-clone-bgp`
- Configures TrueNAS with HBA PCI passthrough for direct disk access
- Host CPU passthrough for optimal ZFS performance
- 32GB RAM allocation (suitable for ~24TB storage pool)
- Static IP configuration for reliable NFS/SMB services
- Cloud-init integration for automated initial setup

### 2. **variables.tf** - Configuration Variables

- Infrastructure-level variables (Proxmox host, storage, networking)
- TrueNAS-specific variables with sensible defaults
- Comprehensive validation rules ensuring minimum requirements
- Detailed descriptions with formulas and recommendations
- Memory sizing guide: `1GB per TB storage + 8GB base`

### 3. **outputs.tf** - Resource Outputs

- VM identification (ID, name, FQDN, IP address)
- PCI device mappings for verification
- Resource allocation summary
- SSH key deployment confirmation
- Environment summary for operational reference

### 4. **cloud-init-truenas.yml** - Initial Configuration Template

- Sets hostname and FQDN
- Configures SSH keys from GitHub
- Enables QEMU guest agent for Proxmox integration
- Disables password authentication (keys only)
- Sets timezone to America/New_York
- Updates TrueNAS middleware with hostname

### 5. **provider.tf** - Terraform Providers

- BPG Proxmox provider configuration (v0.89+)
- SOPS integration for secrets management
- GitHub SSH key fetching
- Comprehensive inline documentation

### 6. **README.md** - Complete Documentation

- Architecture diagram
- Prerequisites and dependencies
- Usage instructions
- Configuration examples
- Post-deployment setup guide
- Troubleshooting section
- Variable reference table

### 7. **terraform.tfvars.example** - Configuration Template

- Example values for all variables
- Advanced customization examples
- Copy-paste ready for quick setup

## Key Design Decisions

### HBA PCI Passthrough

**Why:** Direct disk access provides:

- Native SMART monitoring in TrueNAS
- Better ZFS performance (no virtualization overhead)
- Simplified disk management
- Hardware-level error reporting

**Requirement:** HBA must be in IT (Initiator Target) mode, not IR/RAID mode

### Host CPU Passthrough

**Why:** ZFS benefits from:

- AES-NI instructions for encryption
- Native CPU checksumming
- Better compression performance
- No CPU feature emulation overhead

### Static IP Address

**Why:** NAS requires predictable address for:

- NFS/SMB mount point stability
- DNS A record reliability
- Consistent backup target configuration
- Service discovery (Avahi/mDNS)

### Memory Allocation (32GB)

**Formula:** `(1GB per TB of storage) + 8GB base`

- Example: 24TB storage = 24GB + 8GB = 32GB
- ZFS ARC cache uses ~50% of available RAM
- Larger ARC = better read performance

## Deployment Workflow

```bash
# 1. Create TrueNAS template via Packer
cd /workspaces/IaC/packer
make truenas VERSION=25.10 ENV=prod NODE=pve01 VMID=9001

# 2. Create PCI mappings at datacenter level
cd ../terraform/environments/prod/infrastructure/pve1/pci-mappings
terraform apply

# 3. Deploy TrueNAS VM
cd ../../workloads/pve01
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars as needed
terraform init
terraform plan
terraform apply

# 4. Post-deployment: Configure TrueNAS
# - Access web UI: https://files.flopo.retropetro.net
# - Create ZFS pool(s) using passed-through disks
# - Configure shares (NFS/SMB)
# - Enable services
# - Set up SMART monitoring

# 5. (Optional) Apply Ansible configuration
cd /workspaces/IaC/ansible
ansible-playbook site.yml -i inventories/production --limit files.flopo.retropetro.net --tags truenas
```

## Configuration Defaults

| Setting | Value | Rationale |
|---------|-------|-----------|
| Hostname | `files` | Descriptive of primary function |
| IP Address | `192.168.2.50/24` | Static IP in reserved NAS range |
| CPU Cores | `4` | Sufficient for ZFS + services |
| Memory | `32GB` | Supports ~24TB storage with good ARC |
| Boot Disk | `128GB` | Room for system + boot pool snapshots |
| CPU Type | `host` | Optimal ZFS performance |
| PCI Devices | LSI SAS HBA | Direct disk access for ZFS |

## Network Topology

```
┌─────────────────────────────────────────┐
│ Network: 192.168.2.0/24                 │
│                                         │
│ Gateway:    192.168.2.1                 │
│ DNS/DHCP:   192.168.2.2 (PiHole)        │
│ TrueNAS:    192.168.2.50 (files)        │
│                                         │
│ NFS/SMB Services:                       │
│ - Port 2049 (NFS)                       │
│ - Port 445 (SMB)                        │
│ - Port 139 (NetBIOS)                    │
│ - Port 22 (SSH - management)            │
│ - Port 443 (HTTPS - web UI)             │
└─────────────────────────────────────────┘
```

## Storage Architecture

### Boot Pool (VM System Disk)

- **Size:** 128GB
- **Purpose:** TrueNAS SCALE OS and system configuration
- **Managed by:** Proxmox (as VM disk on zfs01)
- **Backup:** Proxmox VM backups

### Data Pool (HBA-Attached Disks)

- **Management:** Direct in TrueNAS UI
- **Purpose:** Media, ROMs, backups
- **Configuration:** Determined post-deployment based on available disks
- **Backup:** TrueNAS replication + PBS + cloud sync

### Recommended Data Pool Layout

```
tank (ZFS pool)
├── media/
│   ├── movies     (recordsize=1M, compression=lz4)
│   ├── tv         (recordsize=1M, compression=lz4)
│   └── music      (recordsize=128K, compression=lz4)
├── roms/          (recordsize=128K, compression=zstd)
└── backups/
    ├── proxmox    (recordsize=128K, compression=lz4)
    └── files      (recordsize=128K, compression=zstd)
```

## Integration Points

### Proxmox

- VM managed via Terraform (this module)
- PCI mappings created in infrastructure layer
- Backups via PBS (Proxmox Backup Server)

### Ansible

- System configuration (hostname, domain, services)
- Dataset creation and permission management
- S.M.A.R.T. monitoring configuration
- Role: `/workspaces/IaC/ansible/roles/truenas/`

### Packer

- Template creation for reproducible deployments
- TrueNAS SCALE 25.10 ISO-based build
- Template ID: 9001
- Location: `/workspaces/IaC/packer/modules/truenas/25.10/`

### Network Services

- NFS exports for Linux clients
- SMB shares for Windows/Mac clients
- SSH access for management and automation
- Web UI for administration

## Security Considerations

### SSH Access

- ✅ Key-based authentication only (password auth disabled)
- ✅ Keys fetched from GitHub (version controlled)
- ✅ SSH limited to management network
- ✅ Root login prohibited (truenas_admin user)

### Network Isolation

- TrueNAS on management VLAN (192.168.2.0/24)
- Shares accessible from trusted networks only
- Firewall rules at Proxmox level
- No direct internet exposure

### Data Protection

- ZFS snapshots for point-in-time recovery
- Replication to secondary NAS (optional)
- PBS backups of VM configuration
- Cloud sync for critical data (optional)

## Performance Optimization

### ZFS ARC Tuning

```bash
# Check ARC stats
arc_summary

# ARC should use ~50% of RAM (16GB with 32GB RAM)
# Adjust if needed via TrueNAS UI: System Settings → Advanced
```

### Network Performance

```bash
# Verify network speed
ethtool eth0

# Should show: Speed: 1000Mb/s or 10000Mb/s
# Enable jumbo frames if supported: MTU 9000
```

### Disk Performance

```bash
# Test ZFS read performance
dd if=/mnt/tank/testfile of=/dev/null bs=1M count=1000

# Test write performance
dd if=/dev/zero of=/mnt/tank/testfile bs=1M count=1000

# Check for disk errors
smartctl -a /dev/sda
```

## Maintenance Tasks

### Regular Checks (Weekly)

- [ ] Verify scrub schedule (monthly recommended)
- [ ] Review SMART status
- [ ] Check available space
- [ ] Verify backup jobs completed

### Monthly Tasks

- [ ] Review ZFS scrub results
- [ ] Update TrueNAS SCALE (if available)
- [ ] Verify replication tasks
- [ ] Test restore from backup

### Quarterly Tasks

- [ ] Review share permissions
- [ ] Audit user access
- [ ] Verify disaster recovery plan
- [ ] Test VM clone/restore procedure

## Future Enhancements

### Potential Additions

1. **S3 Integration:** Add cloud sync for offsite backups
2. **Monitoring:** Integrate with Prometheus/Grafana
3. **Alerting:** Configure email/Slack notifications
4. **Additional Services:** Add MinIO, Nextcloud, or other apps
5. **HA Setup:** Add second TrueNAS for replication/failover

### Scaling Considerations

- Memory: Add more RAM as storage grows (1GB per TB rule)
- CPU: Upgrade to 8 cores for heavy compression workloads
- Network: Upgrade to 10Gbps NIC for better throughput
- Storage: Add disk shelves for capacity expansion

## References

- **TrueNAS Documentation:** <https://www.truenas.com/docs/scale/>
- **ZFS Best Practices:** <https://openzfs.github.io/openzfs-docs/>
- **Proxmox PCI Passthrough:** <https://pve.proxmox.com/wiki/PCI_Passthrough>
- **Terraform BPG Provider:** <https://registry.terraform.io/providers/bpg/proxmox/>

## Change Log

- **2025-12-14:** Initial module creation with TrueNAS SCALE 25.10 support
- **2025-12-14:** Added comprehensive documentation and examples
- **2025-12-14:** Configured HBA PCI passthrough for direct disk access

---

**Status:** Ready for deployment
**Tested:** Pending initial deployment
**Maintained by:** Infrastructure Team
