output "truenas1_vm_id" {
  value = module.truenas1_vm.vm_id
}

# output "truenas1_vm_ip" {
#   description = "The IP address of the Truenas1 VM"
#   value       = module.truenas1_vm.vm_ip
# }

output "pofo14_ssh_keys" {
  value = data.github_ssh_keys.pofo14_ssh_keys.keys
}