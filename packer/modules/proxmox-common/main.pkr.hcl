packer_required_plugins {
  proxmox = {
    version = ">= 1.1.3"
    source  = "github.com/hashicorp/proxmox"
  }
}

# Common Proxmox configuration
locals {
  # Load environment-specific secrets
  secrets = yamldecode(sops_decrypt_file("${path.root}/../../environments/${var.environment}/secrets.enc.yml"))
  
  # Get host-specific configuration
  host_config = local.secrets.environments[var.environment][var.proxmox_host]
  
  # Common settings
  common_settings = local.secrets.global
}

# Common Proxmox connection block
locals {
  proxmox_connection = {
    proxmox_url = local.host_config.api_url
    username = local.host_config.api_token_id
    token = local.host_config.api_token_secret
    node = local.host_config.node
    insecure_skip_tls_verify = local.common_settings.insecure_skip_tls_verify
    task_timeout = local.common_settings.task_timeout
  }
}

# Common network configuration
locals {
  network_config = {
    bridge = local.common_settings.network_bridge
    model = local.common_settings.network_model
  }
} 