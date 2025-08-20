# Common Proxmox configuration
locals {
  # Load secrets from SOPS
  secrets = yamldecode(sops_decrypt_file("${path.root}/secrets.enc.yml"))
  
  # Common VM settings
  common_vm_settings = {
    insecure_skip_tls_verify = true
    task_timeout = "30m"
    network_bridge = "vmbr0"
    network_model = "virtio"
  }
}

# Common Proxmox connection block
locals {
  proxmox_connection = {
    proxmox_url = local.secrets.proxmox.api_url
    username = local.secrets.proxmox.api_token_id
    token = local.secrets.proxmox.api_token_secret
    node = local.secrets.proxmox.node
  }
} 