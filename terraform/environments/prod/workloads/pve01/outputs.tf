# ============================================================================
# Outputs for prod/workloads/pve01
# ============================================================================
# Expose VM details for operational reference and downstream usage

# ============================================================================
# TrueNAS Files VM Outputs
# ============================================================================

output "truenas_files_vm_id" {
  description = "Proxmox VM ID of the TrueNAS Files VM"
  value       = module.truenas-files.vm_id
}

output "truenas_files_vm_name" {
  description = "VM name of the TrueNAS Files appliance"
  value       = module.truenas-files.vm_name
}

output "truenas_files_ipaddress" {
  description = "IP address of the TrueNAS Files VM"
  value       = local.truenas_files.ipaddress
}

output "truenas_files_fqdn" {
  description = "Fully qualified domain name of the TrueNAS Files VM"
  value       = "${local.truenas_files.hostname}.${var.domain}"
}

output "truenas_files_pci_devices" {
  description = "PCI devices passed through to TrueNAS for direct disk access"
  value       = local.truenas_files.pci_mappings
}

output "truenas_files_resources" {
  description = "Resource allocation summary for TrueNAS Files VM"
  value = {
    cores   = local.truenas_files.cores
    memory  = "${local.truenas_files.memory / 1024}GB"
    storage = "${local.truenas_files.disksize}GB"
  }
}

# ============================================================================
# Docker Hosts Outputs
# ============================================================================

# output "docker_hosts" {
#   description = "Summary of all Docker host VMs"
#   value = {
#     for key, vm in module.docker-hosts : key => {
#       vm_id     = vm.vm_id
#       vm_name   = vm.vm_name
#       ipaddress = local.docker_hosts[key].ipaddress
#       fqdn      = "${local.docker_hosts[key].hostname}.${var.domain}"
#       cores     = local.docker_hosts[key].cores
#       memory_gb = local.docker_hosts[key].memory / 1024
#     }
#   }
# }

# ============================================================================
# Management VMs Outputs
# ============================================================================

# output "management_vms" {
#   description = "Summary of all Management VMs"
#   value = {
#     for key, vm in module.management-vms : key => {
#       vm_id     = vm.vm_id
#       vm_name   = vm.vm_name
#       ipaddress = local.management_vms[key].ipaddress
#       fqdn      = "${local.management_vms[key].hostname}.${var.domain}"
#     }
#   }
# }

# ============================================================================
# SSH Keys (for verification)
# ============================================================================

output "deployed_ssh_keys" {
  description = "SSH keys deployed to all VMs from GitHub user pofo14"
  value       = data.github_ssh_keys.pofo14_ssh_keys.keys
  sensitive   = true
}

output "deployed_ssh_key_count" {
  description = "Number of SSH keys deployed to VMs"
  value       = length(data.github_ssh_keys.pofo14_ssh_keys.keys)
}

# ============================================================================
# Environment Information
# ============================================================================

output "environment_summary" {
  description = "Summary of deployed workloads in prod/pve01"
  value = {
    proxmox_node   = var.proxmox_host
    domain         = var.domain
    truenas_vm     = "${local.truenas_files.hostname}.${var.domain}"
    docker_hosts   = [for k, v in local.docker_hosts : "${v.hostname}.${var.domain}"]
    management_vms = [for k, v in local.management_vms : "${v.hostname}.${var.domain}"]
    total_vms      = 1 + length(local.docker_hosts) + length(local.management_vms)
  }
}
