# Provider configuration for VM workloads

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
    
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the GitHub Provider for SSH keys
provider "github" {
  token = data.sops_file.secrets.data["github_token"]
}

# Standard provider for VM operations
provider "proxmox" {
  endpoint  = data.sops_file.secrets.data["pve1_fdqn"]
  api_token = "${data.sops_file.secrets.data["pve1_api_token_id"]}=${data.sops_file.secrets.data["pve1_api_token_secret"]}"
  insecure  = true

  ssh {
    agent    = true
    username = data.sops_file.secrets.data["pve1_username"]
  }
}

data "sops_file" "secrets" {
  source_file = "${path.module}/../../../secrets.enc.yml"
}
