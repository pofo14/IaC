// filepath: /workspaces/IaC/terraform/shared/variables.tf
variable "proxmox_api_url" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "Target Proxmox node"
  type        = string
}

variable "environment" {
  description = "Environment (dev/test/stage/prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, test, stage, or prod"
  }
}

variable "ssh_authorized_keys" {
  description = "SSH public keys for VMs"
  type        = list(string)
  default     = []
}
