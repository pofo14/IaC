# vm-blank-bgp Module

Creates a blank Proxmox VM with multiple empty disks - designed for preseed/autoinstall testing.

## Purpose

This module creates a VM **without cloning** from any template. It's specifically designed for:

- Testing Debian preseed installations
- PXE boot scenarios
- ISO-based automated installations
- Scenarios requiring predictable disk identifiers

## Key Features

- **No template cloning** - creates blank VM from scratch
- **Predictable disk IDs** - explicit interface names (scsi0, scsi1) for stable `/dev/disk/by-id/` paths
- **Multiple disk support** - perfect for RAID/ZFS mirror testing
- **No cloud-init by default** - VM boots from ISO/PXE
- **Flexible configuration** - optional network config, QEMU agent, auto-start

## Disk Naming Convention

When you create disks with specific interfaces, they appear predictably in the guest OS:

| Interface | Guest OS /dev/disk/by-id/ Path |
|-----------|--------------------------------|
| `scsi0`   | `scsi-0QEMU_QEMU_HARDDISK_drive-scsi0` |
| `scsi1`   | `scsi-0QEMU_QEMU_HARDDISK_drive-scsi1` |
| `sata0`   | `ata-QEMU_HARDDISK_QM00001` |
| `sata1`   | `ata-QEMU_HARDDISK_QM00002` |

This predictability allows you to reference specific disks in your preseed configuration.

## Usage Example

### Basic: Two SCSI disks for ZFS mirror testing

```hcl
module "preseed-test-vm" {
  source = "../../../../modules/vm-blank-bgp"

  hostname     = "test-preseed"
  proxmox_host = "pve1"

  cores  = 2
  memory = 4096

  disks = [
    {
      datastore_id = "local-lvm"
      interface    = "scsi0"
      size         = 40
      file_format  = "raw"
    },
    {
      datastore_id = "local-lvm"
      interface    = "scsi1"
      size         = 40
      file_format  = "raw"
    }
  ]

  tags = ["preseed", "test", "debian"]
}
```

### Advanced: With network configuration

```hcl
module "preseed-test-vm" {
  source = "../../../../modules/vm-blank-bgp"

  hostname     = "test-preseed"
  proxmox_host = "pve1"

  cores  = 2
  memory = 4096

  # Network configuration (optional)
  enable_network_config = true
  ipaddress            = "192.168.2.99/24"
  gateway              = "192.168.2.1"

  disks = [
    {
      datastore_id = "local-lvm"
      interface    = "scsi0"
      size         = 40
      file_format  = "raw"
    },
    {
      datastore_id = "local-lvm"
      interface    = "scsi1"
      size         = 40
      file_format  = "raw"
    }
  ]

  start_on_create = false  # Don't start - attach ISO first
}
```

## Workflow

1. **Create VM** - `terraform apply` creates blank VM with disks
2. **Attach ISO** - Manually attach Debian installer ISO in Proxmox UI
3. **Configure boot** - Set boot order to CD-ROM first
4. **Start VM** - Boot from ISO and test your preseed file
5. **Iterate** - `terraform destroy` and repeat as needed

## Variables

See `variables.tf` for full variable documentation.

Key variables:

- `disks` - List of disk configurations with explicit interface names
- `enable_network_config` - Set to false for preseed-managed networking
- `start_on_create` - Usually false to attach ISO before first boot
- `qemu_agent_enabled` - Usually false until OS is installed

## Outputs

- `vm_id` - Proxmox VM ID
- `vm_name` - VM name
- `disk_interfaces` - List of created disk interfaces
- `expected_disk_ids` - Expected paths in guest OS for preseed reference
- `mac_address` - MAC address of the VM's network interface
- `ipxe_menu_filename` - Suggested iPXE menu filename based on MAC address (format: `mac-XX-XX-XX-XX-XX-XX.ipxe`)

### Example Output Usage

```bash
terraform apply
terraform output mac_address        # BC:24:11:21:57:B7
terraform output ipxe_menu_filename # mac-bc-24-11-21-57-b7.ipxe

# Use for creating MAC-based iPXE boot files
MAC_FILE=$(terraform output -raw ipxe_menu_filename)
echo "Create iPXE file: /var/www/html/ipxe/${MAC_FILE}"
```
