# global/provider.tf
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.76.1"
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
  #token = var.token # or `GITHUB_TOKEN`
}

provider "proxmox" {
  endpoint  = data.sops_file.secrets.data["pve1_api_url"]
  api_token = data.sops_file.secrets.data["pve1_api_full_token"]
  insecure  = true
  ssh {
    agent    = false
    username = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}

data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.yml"
}

data "github_ssh_keys" "pofo14_ssh_keys" {}

