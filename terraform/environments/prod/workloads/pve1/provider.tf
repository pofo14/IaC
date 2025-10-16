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
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  # GitHub token from environment variable GITHUB_TOKEN
}

provider "proxmox" {
  endpoint    = data.sops_file.secrets.data["pve1_fdqn"]
  username    = data.sops_file.secrets.data["pve1_username"]
  password    = data.sops_file.secrets.data["pve1_password"]
  insecure    = true
  ssh { agent = true }
}

provider "sops" {
  # No configuration needed
}

data "sops_file" "secrets" {
  source_file = "${path.module}/../../secrets.enc.yml"  # Environment-level file
}

data "github_ssh_keys" "pofo14_ssh_keys" {}

