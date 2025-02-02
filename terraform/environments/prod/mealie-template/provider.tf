# global/provider.tf
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7.2"
    }
  }
}

provider "proxmox" {
  pm_api_url = data.sops_file.secrets.data["proxmox_api_url"]
  pm_api_token_id = data.sops_file.secrets.data["proxmox_api_token_id"]
  pm_api_token_secret = data.sops_file.secrets.data["proxmox_api_token_secret"]
  pm_tls_insecure = true
}

data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.yml"
}