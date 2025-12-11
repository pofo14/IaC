# Preseed Integration Guide

## Overview

The `vm-blank-bgp` module creates VMs with **predictable SCSI disk identifiers**,
making it perfect for automated preseed installations that require consistent disk naming.

## Disk Naming in VM

When you create this test VM, it will have two SCSI disks that appear in the Debian installer as:

```
/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0
/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
```

You can verify this after running `terraform apply` by checking the output:

```bash
terraform output expected_disk_paths
```

## Updating Your Preseed Template

### Current Preseed Configuration

Your current preseed template uses hardware-specific disk IDs:

```yaml
# ansible/inventories/dev/host_vars/dev-pve1.flopo.retropetro.net.yml
storage_disks:
  - ata-Samsung_SSD_860_EVO_500GB_S598NE0M803304V
  - ata-Samsung_SSD_870_EVO_500GB_S6PXNZ0TC05818H
```

### For Test VM (QEMU Disks)

Create a new test host_vars file for the test-preseed VM:

```bash
# Create host_vars for test-preseed VM
cat > /workspaces/IaC/ansible/inventories/dev/host_vars/test-preseed.flopo.retropetro.net.yml << 'YAML'
---
pve_hostname: test-preseed
pve_ip: 192.168.2.99
network_interface: ens18
storage_disks:
  - scsi-0QEMU_QEMU_HARDDISK_drive-scsi0
  - scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
YAML
```

### Add to Ansible Inventory

Update your dev inventory to include the test VM:

```bash
# Add to ansible/inventories/dev/hosts
[proxmox_hosts]
dev-pve1.flopo.retropetro.net
test-preseed.flopo.retropetro.net
```

## Testing Workflow

### 1. Generate Preseed for Test VM

```bash
cd /workspaces/IaC/ansible
ansible-playbook playbooks/generate_preseed.yml -i inventories/dev/hosts -l test-preseed.flopo.retropetro.net
```

### 2. Review Generated Preseed

Check the generated preseed file to ensure it references the correct QEMU disk IDs:

```bash
cat /tmp/preseed/test-preseed.cfg | grep -A5 "storage_disks"
```

You should see references to:

- `scsi-0QEMU_QEMU_HARDDISK_drive-scsi0`
- `scsi-0QEMU_QEMU_HARDDISK_drive-scsi1`

### 3. Deploy Test VM

```bash
cd /workspaces/IaC/terraform/environments/dev/workloads/pve1/test-preseed
terraform apply
```

### 4. Attach Debian ISO

In Proxmox UI or via CLI:

```bash
# Download Debian 12 installer if not already available
# Then attach to VM (assuming VM ID is 999)
qm set 999 --ide2 iso:iso/debian-12.x.x-amd64-netinst.iso,media=cdrom
```

### 5. Configure PXE/Preseed Boot

You have two options:

**Option A: PXE Boot** (if you have PXE server configured)

- VM will boot from network
- PXE server serves preseed file

**Option B: ISO Boot with Preseed URL**

- Boot from Debian ISO
- At boot prompt, enter:

  ```
  auto url=http://192.168.2.7/preseed/test-preseed.cfg
  ```

### 6. Start VM and Monitor

```bash
# Start VM
qm start 999

# Watch installation via console
# The preseed should automatically partition the two SCSI disks
# and create a ZFS mirror
```

## Key Differences: Hardware vs VM Disks

| Environment | Disk Identifier Format | Example |
|-------------|------------------------|---------|
| **Physical Hardware** | `ata-<MODEL>_<SERIAL>` | `ata-Samsung_SSD_860_EVO_500GB_S598NE0M803304V` |
| **QEMU/KVM VM (SCSI)** | `scsi-0QEMU_QEMU_HARDDISK_drive-<interface>` | `scsi-0QEMU_QEMU_HARDDISK_drive-scsi0` |
| **QEMU/KVM VM (SATA)** | `ata-QEMU_HARDDISK_QM<num>` | `ata-QEMU_HARDDISK_QM00001` |

## Benefits of This Approach

1. **Predictable Testing**: SCSI interface names (scsi0, scsi1) are stable and known before VM creation
2. **Repeatable**: Destroy and recreate test VM - disk IDs remain the same
3. **No Template Dependency**: Blank VM approach means no cloud-init or existing partitions to interfere
4. **Real-World Simulation**: Tests the actual preseed partitioning logic that will run on bare metal

## Next Steps

After successful test VM validation:

1. Use the same preseed template structure for production hosts
2. Update host_vars for each physical Proxmox node with their hardware-specific disk IDs
3. Generate production preseed files
4. Deploy to bare metal with confidence
