# Provider configuration for PCI Mappings (Infrastructure Layer)
# This requires root/elevated credentials to create datacenter-level PCI mappings

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.0"
    }
  
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7.2"
    }
  }
}

# Root provider for PCI mappings (requires elevated privileges)
provider "proxmox" {
  endpoint    = data.sops_file.secrets.data["pve1_fdqn"]
  username    = data.sops_file.secrets.data["pve1_username"]
  password    = data.sops_file.secrets.data["pve1_password"]
  insecure    = true
}

data "sops_file" "secrets" {
  source_file = "${path.module}/../../../secrets.enc.yml"
}
