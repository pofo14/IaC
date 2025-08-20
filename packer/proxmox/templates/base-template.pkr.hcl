packer_required_plugins {
  proxmox = {
    version = ">= 1.1.3"
    source  = "github.com/hashicorp/proxmox"
  }
}

# Base template that others can extend
source "proxmox-iso" "base" {
  # Common connection settings
  proxmox_url = local.proxmox_connection.proxmox_url
  username = local.proxmox_connection.username
  token = local.proxmox_connection.token
  node = local.proxmox_connection.node
  
  # Common settings
  insecure_skip_tls_verify = local.common_vm_settings.insecure_skip_tls_verify
  task_timeout = local.common_vm_settings.task_timeout
  
  # Common network
  network_adapters {
    bridge = local.common_vm_settings.network_bridge
    model = local.common_vm_settings.network_model
  }
} 