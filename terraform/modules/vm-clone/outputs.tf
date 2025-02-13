output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_vm_qemu.vm-clone.id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_vm_qemu.vm-clone.name
}

# output "vm_ip" {
#   description = "The IP address of the created VM"
#   value       = split("/", split("=", proxmox_vm_qemu.vm.ipconfig0)[1])[0]
# }