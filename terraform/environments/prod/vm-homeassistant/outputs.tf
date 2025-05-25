output "haos_vm_id" {
  description = "The ID of the Home Assistant OS VM."
  value       = module.haos_vm.id
}

output "haos_vm_name" {
  description = "The name of the Home Assistant OS VM."
  value       = module.haos_vm.name
}

output "haos_vm_ip_address" {
  description = "The primary IP address of the Home Assistant OS VM (may require time for DHCP)."
  # This assumes the vm-clone module outputs an 'ip' or 'ip_address' attribute.
  # Adjust if the output attribute from the module is named differently.
  # If DHCP is used, this might be empty on the first apply if the IP isn't available quickly.
  value       = module.haos_vm.ipconfig0_ip # Or module.haos_vm.ip, depends on module output
}

output "haos_vm_ssh_command_hint" {
  description = "SSH command hint (actual username depends on HAOS setup, usually not 'root' initially for SSH)."
  value       = "ssh <your_ssh_user_once_configured_in_haos>@${module.haos_vm.ipconfig0_ip}"
}
