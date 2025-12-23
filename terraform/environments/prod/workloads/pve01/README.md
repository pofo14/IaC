# Production Workloads - PVE01

This Terraform configuration deploys production workloads to the Proxmox node `pve01`.

## Overview

**Purpose:** Deploy and manage production virtual machines on Proxmox VE cluster node pve01.

**Primary Workload:** TrueNAS SCALE appliance for centralized storage

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ Proxmox Node: pve01                                             │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ TrueNAS Files VM (files.flopo.retropetro.net)              │ │
│ │                                                             │ │
│ │ Purpose: Primary NAS for Media, ROMs, Backups              │ │
│ │ IP: 192.168.2.50/24                                         │ │
│ │ Resources: 4 cores, 32GB RAM, 128GB boot disk              │ │
│ │                                                             │ │
│ │ Storage Strategy:                                           │ │
│ │ - HBA Controller (LSI SAS 9300-8i) PCI Passthrough         │ │
│ │ - Direct disk access for optimal ZFS performance           │ │
│ │ - SMART monitoring and native disk management              │ │
│ │                                                             │ │
│ │ Services Hosted:                                            │ │
│ │ - Media files (movies, TV shows, music)                    │ │
│ │ - ROM collections (retro gaming)                           │ │
│ │ - Backup storage (Proxmox backups, file backups)           │ │
│ │ - NFS/SMB shares for network access                        │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### TrueNAS Files VM

**Configuration:**

- **Template:** TrueNAS SCALE 25.10 (VM ID: 9001)
- **Hostname:** files.flopo.retropetro.net
- **IP Address:** 192.168.2.50/24 (static)
- **CPU:** 4 cores @ host passthrough (optimal for ZFS)
- **Memory:** 32GB (suitable for ZFS ARC cache with ~24TB storage)
- **Boot Disk:** 128GB (system + boot pool)
- **PCI Devices:** LSI SAS HBA (direct disk access)

**Why Host CPU Passthrough?**

- ZFS benefits from CPU instructions (AES-NI for encryption)
- Better checksumming performance
- Native hardware acceleration for compression

**Memory Sizing Formula:**

- Base: 8GB minimum
- Additional: 1GB per TB of raw storage
- Example: 24TB storage = 8GB + 24GB = 32GB total

## Prerequisites

### 1. Templates Created by Packer

Ensure templates exist before deployment:

```bash
# TrueNAS SCALE 25.10
cd /workspaces/IaC/packer
make truenas VERSION=25.10 ENV=prod NODE=pve01 VMID=9001
```

### 2. PCI Mappings Created

HBA controller must be mapped at datacenter level first:

```bash
# First, identify your HBA's PCI address
ssh root@pve01.flopo.retropetro.net
lspci -nn | grep -i sas  # Note the device ID and path

# Update pci-mappings.tf with your actual hardware IDs
cd /workspaces/IaC/terraform/environments/prod/infrastructure/pve1

# Apply PCI mapping
terraform apply -target=proxmox_virtual_environment_hardware_mapping_pci.hba_lsi_sas
```

This creates the `hba-lsi-sas-9300-8i` mapping referenced by the TrueNAS VM.

**Important:** Adjust the `id` and `path` values in `pci-mappings.tf` to match your actual hardware.

### 3. Network Configuration

- Static IP pool reserved: `192.168.2.50-192.168.2.99`
- Gateway: `192.168.2.1`
- DNS: Managed by PiHole (192.168.2.2)

## Usage

### Initialize Terraform

```bash
cd /workspaces/IaC/terraform/environments/prod/workloads/pve01
terraform init
```

### Plan Deployment

```bash
# Review changes before applying
terraform plan
```

### Deploy TrueNAS VM

```bash
terraform apply
```

### Verify Deployment

```bash
# Check VM status
terraform output truenas_files_fqdn
terraform output truenas_files_ipaddress

# SSH to TrueNAS (after boot completes)
ssh truenas_admin@files.flopo.retropetro.net

# Access TrueNAS Web UI
https://files.flopo.retropetro.net
```

## Configuration

### Customizing Resources

Edit `terraform.tfvars`:

```hcl
# Increase memory for larger storage pools
truenas_memory = 65536  # 64GB

# Adjust CPU cores
truenas_cores = 8

# Change IP address
truenas_ipaddress = "192.168.2.60/24"
```

### Adding Additional Disks (Without HBA Passthrough)

If not using PCI passthrough, add disks via Terraform:

```hcl
# In main.tf
add_extra_disk = true
extra_disks = [
  { size = 1000, ssd = false },  # 1TB HDD
  { size = 1000, ssd = false },  # 1TB HDD
  { size = 2000, ssd = false },  # 2TB HDD
]
```

**Note:** With HBA passthrough (default), disks are managed directly in TrueNAS.

### Changing PCI Devices

Modify the PCI mappings in `terraform.tfvars`:

```hcl
truenas_pci_mappings = [
  "hba-lsi-sas-9300-8i",
  "gpu-intel-igpu"  # Add additional devices
]
```

## Post-Deployment Configuration

### 1. Initial TrueNAS Setup

**Note:** SSH access is already configured in the Packer template with your GitHub keys.
Cloud-init is NOT used (TrueNAS pre-installed templates don't support it).

Access the web UI at `https://files.flopo.retropetro.net`:

1. **Set admin password** (initial login will prompt)
2. **Verify hostname**: Should already be set from template
3. **Create ZFS pool(s)** using passed-through disks
4. **Configure NFS/SMB shares** for media and backups
5. **Enable services**: NFS, SMB (SSH already enabled)
6. **Set up S.M.A.R.T. monitoring** for disk health

### 2. Configure Shares

Example NFS share structure:

```
/mnt/tank/media/movies    - Movies library
/mnt/tank/media/tv        - TV shows library
/mnt/tank/media/music     - Music library
/mnt/tank/roms            - ROM collections
/mnt/tank/backups/proxmox - Proxmox VM backups
/mnt/tank/backups/files   - General file backups
```

### 3. Ansible Configuration (Optional)

Apply Ansible playbook for additional TrueNAS configuration:

```bash
cd /workspaces/IaC/ansible
ansible-playbook site.yml -i inventories/production --limit files.flopo.retropetro.net --tags truenas
```

This configures:

- System hostname and domain
- NFS service settings
- S.M.A.R.T. monitoring
- ZFS datasets and permissions

## Maintenance

### Updating TrueNAS

TrueNAS SCALE updates are managed via the web UI:

1. Navigate to **System Settings → Update**
2. Check for updates
3. Apply and reboot

The VM configuration (CPU, RAM, PCI devices) persists across updates.

### Modifying VM Resources

To change CPU, memory, or other resources:

```bash
# Edit terraform.tfvars
vim terraform.tfvars

# Apply changes
terraform apply
```

**Note:** Some changes (like memory increase) can be applied hot. Others (like PCI changes) require VM shutdown.

### Backup Strategy

**Boot Pool Backup:**

- TrueNAS automatically snapshots boot pool
- Export VM configuration from Terraform state

**Data Pool Backup:**

- Use TrueNAS replication tasks to remote NAS
- PBS (Proxmox Backup Server) integration
- Cloud sync to S3/B2 for offsite backups

## Troubleshooting

### VM Won't Start After PCI Passthrough

**Issue:** VM fails to boot with PCI device errors

**Solution:**

```bash
# Check PCI mapping exists
ssh root@pve01.flopo.retropetro.net
pvesh get /cluster/mapping/pci

# Verify device is not in use
lspci -nnk | grep -A3 "LSI"

# Ensure IOMMU is enabled
dmesg | grep -i iommu
```

### TrueNAS Can't See Passed-Through Disks

**Issue:** Disks don't appear in TrueNAS disk management

**Solution:**

1. Verify HBA is passed through: Check VM → Hardware in Proxmox UI
2. Ensure HBA firmware is in IT mode (not IR/RAID mode)
3. Check TrueNAS logs: `dmesg | grep sd`

### SSH Connection Refused

**Issue:** Can't SSH to TrueNAS after deployment

**Solution:**

```bash
# Check VM console in Proxmox
# Verify cloud-init completed:
cloud-init status --wait

# Check SSH service
systemctl status ssh

# Verify SSH keys were deployed
cat /home/truenas_admin/.ssh/authorized_keys
```

### Performance Issues

**Symptom:** Slow ZFS performance

**Checks:**

1. **ARC Size:** `arc_summary` - should use ~50% of RAM
2. **CPU Usage:** Ensure host passthrough is enabled
3. **Disk Performance:** Check SMART stats and disk health
4. **Network:** Verify 1Gbps+ link speed

## Variables Reference

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `truenas_hostname` | Hostname for TrueNAS VM | `files` | No |
| `truenas_ipaddress` | Static IP in CIDR notation | `192.168.2.50/24` | No |
| `truenas_cores` | Number of CPU cores | `4` | No |
| `truenas_memory` | RAM in MB | `32768` (32GB) | No |
| `truenas_boot_disk_size` | Boot disk size in GB | `128` | No |
| `truenas_pci_mappings` | PCI devices to pass through | `["hba-lsi-sas-9300-8i"]` | No |
| `proxmox_host` | Target Proxmox node | `pve01` | Yes |
| `domain` | DNS domain | `flopo.retropetro.net` | Yes |
| `gateway` | Network gateway | `192.168.2.1` | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `truenas_files_vm_id` | Proxmox VM ID |
| `truenas_files_fqdn` | Fully qualified domain name |
| `truenas_files_ipaddress` | IP address with CIDR |
| `truenas_files_pci_devices` | Passed-through PCI devices |
| `truenas_files_resources` | Resource allocation summary |

## Related Documentation

- **Packer Templates:** `/workspaces/IaC/packer/modules/truenas/`
- **PCI Mappings:** `/workspaces/IaC/terraform/environments/prod/infrastructure/pve1/pci-mappings/`
- **Ansible Configuration:** `/workspaces/IaC/ansible/roles/truenas/`
- **VM Clone Module:** `/workspaces/IaC/terraform/modules/vm-clone-bgp/`

## Author

Infrastructure managed by Terraform
Date: December 14, 2025
