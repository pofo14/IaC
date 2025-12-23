# ============================================================================
# Terraform Provider Configuration - prod/workloads/pve01
# ============================================================================
# Configures providers for Proxmox VM management, secrets management, and
# SSH key retrieval from GitHub
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # BPG Proxmox provider - manages Proxmox VE resources
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.89" # Updated to support Proxmox 9.x features
    }

    # SOPS provider - decrypts secrets stored in git
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7.2"
    }

    # GitHub provider - fetches SSH keys for cloud-init
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# ----------------------------------------------------------------------------
# GitHub Provider Configuration
# ----------------------------------------------------------------------------
# Authenticates using GITHUB_TOKEN environment variable
# Used to fetch SSH public keys for deploying to VMs

provider "github" {
  # Token loaded from environment: export GITHUB_TOKEN="ghp_xxx"
}

# ----------------------------------------------------------------------------
# Proxmox Provider Configuration
# ----------------------------------------------------------------------------
# Connects to Proxmox VE API using credentials from SOPS-encrypted secrets
# SSH authentication used for certain operations (file uploads)

provider "proxmox" {
  endpoint = data.sops_file.secrets.data["pve01_fdqn"]     # e.g., https://pve01.flopo.retropetro.net:8006
  username = data.sops_file.secrets.data["pve01_username"] # API user with appropriate permissions
  password = data.sops_file.secrets.data["pve01_password"] # API token secret
  insecure = true                                          # Allow self-signed certificates (internal lab environment)

  # SSH configuration for file operations (cloud-init snippets)
  ssh {
    agent       = false
    private_key = file(pathexpand("~/.ssh/id_ed25519"))
  }
}

# ----------------------------------------------------------------------------
# SOPS Provider Configuration
# ----------------------------------------------------------------------------
# No explicit configuration needed - uses age keys from environment

provider "sops" {}

# ============================================================================
# Data Sources
# ============================================================================

# SOPS-encrypted secrets file
# Contains Proxmox API credentials and other sensitive configuration
data "sops_file" "secrets" {
  source_file = "${path.module}/../../secrets.enc.yml"
}

# GitHub SSH keys for user pofo14
# Automatically fetches all public SSH keys from GitHub profile
# These keys are injected into VMs via cloud-init for secure access
data "github_ssh_keys" "pofo14_ssh_keys" {}
