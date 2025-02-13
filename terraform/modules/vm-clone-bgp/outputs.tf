output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm_clone.id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_virtual_environment_vm.vm_clone.name
}

output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.vm_clone.ipv4_addresses[1][0]
}