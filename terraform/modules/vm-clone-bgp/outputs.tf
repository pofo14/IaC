output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm_clone.id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_virtual_environment_vm.vm_clone.name
}

output "vm_ipv4_address" {
  description = "The IPv4 address of the VM (from QEMU guest agent if available, or configured IP)"
  value       = try(proxmox_virtual_environment_vm.vm_clone.ipv4_addresses[1][0], var.ipaddress, "N/A")
}
