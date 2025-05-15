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
  #token = var.token # or `GITHUB_TOKEN`
}

provider "proxmox" {
  endpoint = "https://proxmox.flopo.retropetro.net:8006/"

  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_USERNAME environment variable
  username = "root@pam"
  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_PASSWORD environment variable
  password = "Ch@rl!e29"

  # because self-signed TLS certificate is in use
  insecure = true
  # uncomment (unless on Windows...)
  # tmp_dir  = "/var/tmp"

  ssh {
    agent = true
    # TODO: uncomment and configure if using api_token instead of password
    # username = "root"
  }
}

data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.yml"
}

data "github_ssh_keys" "pofo14_ssh_keys" {}

