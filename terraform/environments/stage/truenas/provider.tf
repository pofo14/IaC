# global/provider.tf
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7.2"
    }
        github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}


# Configure the GitHub Provider
# TODO: add documentation to local dev environment setup to do this: sudo apt install gh
provider "github" {
  token = data.sops_file.secrets.data["github_token"]
}

data "github_ssh_keys" "pofo14_ssh_keys" {}

provider "proxmox" {
  
  endpoint = "https://pve1.flopo.retropetro.net:8006/"

  username = data.sops_file.secrets.data["proxmox_username"]
  password = data.sops_file.secrets.data["proxmox_password"]

  insecure = true

  ssh {
    agent = true
  }
}

data "sops_file" "secrets" {
  source_file = "${path.module}/../secrets.enc.yml"
}


