# Management VM outputs
output "management_vm_id" {
  description = "Management VM ID"
  value       = module.vm-management.vm_id
}

# SSH keys (shared)
output "ssh_keys" {
  description = "SSH public keys from GitHub user pofo14"
  value       = data.github_ssh_keys.pofo14_ssh_keys.keys
  sensitive   = true # Prevents printing in terraform output
}

# Future: Uncomment when nextcloud module exists
# output "nextcloud_vm_id" {
#   description = "Nextcloud VM ID"
#   value       = module.vm_nextcloud.vm_id
# }
