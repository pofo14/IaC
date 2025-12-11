output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm_blank.id
}

output "vm_name" {
  description = "The name of the VM"
  value       = proxmox_virtual_environment_vm.vm_blank.name
}

output "disk_interfaces" {
  description = "List of disk interfaces created (for preseed configuration reference)"
  value       = [for disk in var.disks : disk.interface]
}

output "expected_disk_ids" {
  description = "Expected /dev/disk/by-id/ paths for SCSI disks in the guest OS"
  value = [
    for disk in var.disks :
    "scsi-0QEMU_QEMU_HARDDISK_drive-${disk.interface}" if can(regex("^scsi", disk.interface))
  ]
}

output "mac_address" {
  description = "MAC address of the VM's network interface"
  value       = proxmox_virtual_environment_vm.vm_blank.network_device[0].mac_address
}

output "ipxe_menu_filename" {
  description = "Expected iPXE menu filename based on MAC address (mac-XX-XX-XX-XX-XX-XX.ipxe format)"
  value       = "mac-${replace(lower(proxmox_virtual_environment_vm.vm_blank.network_device[0].mac_address), ":", "-")}.ipxe"
}
