output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm_iso.id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_virtual_environment_vm.vm_iso.name
}

output "vm_ipv4_address" {
  description = "The primary IPv4 address of the created VM (if available)"
  value       = try(proxmox_virtual_environment_vm.vm_iso.ipv4_addresses[0][0], "IP address not yet available")
}