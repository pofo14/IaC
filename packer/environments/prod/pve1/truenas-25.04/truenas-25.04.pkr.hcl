# Variable definitions
variable "proxmox_api_url" {
  type = string
  description = "Proxmox API URL"
}

variable "proxmox_api_token_id" {
  type = string
  description = "Proxmox API token ID"
}

variable "proxmox_api_token_secret" {
  type = string
  description = "Proxmox API token secret"
  sensitive = true
}

variable "proxmox_node" {
  type = string
  description = "Proxmox node name"
}

variable "truenas_root_password" {
  type = string
  description = "TrueNAS root password"
  sensitive = true
}

# Include shared Proxmox configuration
locals {
  environment = "prod"
  proxmox_host = "pve1"
  
  # Use environment variables set by makefile
  host_config = {
    api_url = var.proxmox_api_url
    api_token_id = var.proxmox_api_token_id
    api_token_secret = var.proxmox_api_token_secret
    node = var.proxmox_node
    storage_pools = {
      local = "local"
      zfs = "zfs01"
    }
  }
  secrets = {
    passwords = {
      truenas_root = var.truenas_root_password
    }
  }
}

# Alternative: Use SOPS when available
# Uncomment the following and comment out the variables above
# locals {
#   environment = "prod"
#   proxmox_host = "pve1"
#   
#   # Load secrets using external data source
#   secrets = yamldecode(data.external.sops.result.content)
#   host_config = local.secrets.environments[local.environment][local.proxmox_host]
# }
# 
# # External data source to decrypt SOPS file
# data "external" "sops" {
#   program = ["sh", "-c", "sops -d ${path.root}/../../../secrets.enc.yml"]
# }

source "proxmox-iso" "truenas-25" {
  # Connection settings from shared module
  proxmox_url = local.host_config.api_url
  username = local.host_config.api_token_id
  token = local.host_config.api_token_secret
  node = local.host_config.node
  insecure_skip_tls_verify = true
  task_timeout = "30m"
  
  # VM-specific settings
  vm_name = "truenas-25"
  vm_id = 9002
  template_description = "TrueNAS Scale 25.04 Template"
  template_name = "TrueNAS-25.04-template"
  memory = 8192
  cores = 2
  
  # ISO configuration
  boot_iso {
    iso_checksum = "ede23d4c70a7fde6674879346c1307517be9854dc79f6a5e016814226457f359"
    iso_storage_pool = "iso"
    iso_target_path = "TrueNAS-SCALE-25.04.0.iso"
    iso_file = "iso:iso/TrueNAS-SCALE-25.04.0.iso"
    unmount = true
  }
  
  # Network configuration
  network_adapters {
    bridge = "vmbr0"
    model = "virtio"
  }
  
  # Disk configuration
  disks {
    type = "scsi"
    disk_size = "16G"
    storage_pool = local.host_config.storage_pools.zfs
  }
  
  boot_wait           = "45s"

  # Use password from secrets
  boot_command = [
    "1<enter><wait5>",
    "<spacebar><wait3><enter><wait5>",
    "y<wait5>",
    "1<wait2><enter><wait5>",
    "${local.secrets.passwords.truenas_root}<tab><wait5>",
    "${local.secrets.passwords.truenas_root}<wait5>",
    "<enter><wait3>",
    "<enter><wait3>",
    "<wait150>",
    "<enter><wait3>",
    "<wait10>",
    "3<wait2><enter><wait5>",
    "<wait150>",
    "7<wait3><enter><wait15>",
    "service update id_or_name=ssh enable=true<wait3><enter><wait7>",
    "service start service=ssh<wait3><enter><wait7>q<wait3>",
    "service ssh update password_login_groups=truenas_admin<wait5><enter><wait5>",
    "quit<enter><wait20>",
    "10<wait3><enter><wait3>image build<enter><wait5>"
  ]
  
  communicator = "none"
}

build {
  sources = ["source.proxmox-iso.truenas-25"]
} 