terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.84"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7.2"
    }
  }
}

provider "proxmox" {
  endpoint = data.sops_file.secrets.data["pve01_fdqn"]
  username = data.sops_file.secrets.data["pve01_username"]
  password = data.sops_file.secrets.data["pve01_password"]
  insecure = true
  ssh {
    agent       = false
    private_key = file(pathexpand("~/.ssh/id_ed25519"))
  }
}

provider "sops" {
  # No configuration needed
}

data "sops_file" "secrets" {
  source_file = "${path.module}/../../secrets.enc.yml"
}
