# Test VM for Proxmox Preseed Installation Testing
# Uses vm-blank-bgp module to create a VM with predictable SCSI disk IDs
# No template cloning - blank VM with two disks for ZFS mirror testing

module "dev-pve01" {
  source = "../../../../../modules/vm-blank-bgp"

  hostname     = "dev-pve01"
  proxmox_host = var.proxmox_host
  mac_address  = "BC:24:11:52:89:1A"
  cores        = 2
  memory       = 8192

  # Two SCSI disks for ZFS mirror testing
  # These will appear as:
  # - /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0
  # - /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
  disks = [
    {
      datastore_id = var.storage_pool
      interface    = "scsi0"
      size         = 20
      file_format  = "raw"
    },
    {
      datastore_id = var.storage_pool
      interface    = "scsi1"
      size         = 20
      file_format  = "raw"
    },
    {
      datastore_id = var.storage_pool
      interface    = "scsi2"
      size         = 20
      file_format  = "raw"
    }
  ]

  tags        = ["dev", "test", "preseed"]
  description = "Test VM for validating Proxmox preseed installations with predictable SCSI disk IDs"

  # Don't start VM - we'll attach Debian ISO first
  start_on_create = false

  # Disable network config - preseed will handle this
  enable_network_config = false
}

output "dev_pve01_expected_disk_paths" {
  description = "Disk paths to use in preseed configuration"
  value       = module.dev-pve01.expected_disk_ids
}

output "dev_pve01_mac_address" {
  description = "MAC address of the VM for iPXE configuration"
  value       = module.dev-pve01.mac_address
}

output "dev_pve01_ipxe_menu_filename" {
  description = "iPXE menu filename to create for this VM"
  value       = module.dev-pve01.ipxe_menu_filename
}

module "dev-pve02" {
  source = "../../../../../modules/vm-blank-bgp"

  hostname     = "dev-pve02"
  proxmox_host = var.proxmox_host
  mac_address  = "BC:24:11:52:89:1B"
  cores        = 2
  memory       = 8192

  # Two SCSI disks for ZFS mirror testing
  # These will appear as:
  # - /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0
  # - /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
  disks = [
    {
      datastore_id = var.storage_pool
      interface    = "scsi0"
      size         = 20
      file_format  = "raw"
    },
    {
      datastore_id = var.storage_pool
      interface    = "scsi1"
      size         = 20
      file_format  = "raw"
    },
    {
      datastore_id = var.storage_pool
      interface    = "scsi2"
      size         = 20
      file_format  = "raw"
    }
  ]

  tags        = ["dev", "test", "preseed"]
  description = "Test VM for validating Proxmox preseed installations with predictable SCSI disk IDs"

  # Don't start VM - we'll attach Debian ISO first
  start_on_create = false

  # Disable network config - preseed will handle this
  enable_network_config = false
}

output "dev_pve02_expected_disk_paths" {
  description = "Disk paths to use in preseed configuration"
  value       = module.dev-pve02.expected_disk_ids
}

output "dev_pve02_mac_address" {
  description = "MAC address of the VM for iPXE configuration"
  value       = module.dev-pve02.mac_address
}

output "dev_pve02_ipxe_menu_filename" {
  description = "iPXE menu filename to create for this VM"
  value       = module.dev-pve02.ipxe_menu_filename
}
