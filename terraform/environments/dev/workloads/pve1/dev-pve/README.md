# Test Preseed VM Configuration

This directory contains Terraform configuration for a test VM specifically designed to validate Debian preseed installations for Proxmox hosts.

## Purpose

This VM is used to test the Ansible-generated preseed files before using them for production Proxmox installations.
The VM is created as a **blank VM** (no template cloning) with predictable
SCSI disk identifiers, allowing you to test automated installations with ZFS mirror configurations.

## Configuration

- **Hostname**: test-preseed
- **Memory**: 4GB
- **CPU**: 2 cores, 1 socket
- **Disks**: 2x 40GB SCSI disks (scsi0, scsi1) for ZFS mirror
- **Module**: vm-blank-bgp (blank VM, no cloning)
- **Network**: Managed by preseed installer
- **Auto-start**: Disabled (attach ISO first)

## Disk Identifiers

The VM creates two SCSI disks with predictable identifiers in the guest OS:

- `/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0`
- `/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1`

These paths can be referenced in your preseed configuration for RAID/ZFS setup.

## Usage

### 1. Generate Preseed File

First, generate the preseed file using Ansible:

```bash
cd /workspaces/IaC/ansible
make generate-preseed-dev
```

This will create preseed files in the appropriate location for your PXE server.

### 2. Deploy Test VM

Set required environment variables for Proxmox provider:

```bash
export PROXMOX_VE_ENDPOINT="https://pve1.flopo.retropetro.net:8006"
export PROXMOX_VE_API_TOKEN="user@pam!token=secret"
export PROXMOX_VE_INSECURE=true
```

Deploy the VM:

```bash
terraform init
terraform plan
terraform apply
```

The VM will be created but not started automatically.

### 3. Attach Debian Installer ISO

In the Proxmox UI:

1. Select the test-preseed VM
2. Go to Hardware → CD/DVD Drive
3. Select the Debian 12 (Bookworm) installer ISO
4. Configure boot order to boot from CD-ROM first

### 4. Test Preseed Installation

1. Start the VM from Proxmox UI or CLI
2. The Debian installer will boot
3. The preseed file should be automatically applied
4. Watch the automated installation process
5. Verify disk partitioning, ZFS configuration, and network setup

### 5. Cleanup

After testing, destroy the VM:

```bash
terraform destroy
```

## Iteration Workflow

For iterative preseed testing:

1. Modify preseed template in Ansible
2. Regenerate preseed: `make generate-preseed-dev`
3. Destroy test VM: `terraform destroy`
4. Recreate test VM: `terraform apply`
5. Attach ISO and test again

## Notes

- This VM is **not** cloned from any template - it's created from scratch
- No cloud-init configuration - preseed handles all setup
- SCSI disk IDs are predictable for reliable RAID/ZFS configuration
- VM doesn't start automatically to allow ISO attachment first
- Use this iteratively to validate preseed changes before production deployment

## Outputs

Run `terraform output` to see:

- Expected disk paths for preseed configuration reference
