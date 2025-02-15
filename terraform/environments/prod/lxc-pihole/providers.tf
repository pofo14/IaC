terraform {
  required_providers {
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }    
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.1"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "../secrets.enc.yml"
}

provider "proxmox" {
  
  endpoint = "https://proxmox.flopo.retropetro.net:8006/"

  username = data.sops_file.secrets.data["proxmox_username"]
  password = data.sops_file.secrets.data["proxmox_password"]

  insecure = true

  ssh {
    agent = true
  }
}