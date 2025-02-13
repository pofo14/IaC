output "utils_vm_id" {
  value = module.utils_vm.vm_id
}

# output "nextcloud_vm_ip" {
#   description = "The IP address of the Nextcloud VM"
#   value       = module.nextcloud_vm.vm_ip
# }

output "pofo14_ssh_keys" {
  value = data.github_ssh_keys.pofo14_ssh_keys.keys
}