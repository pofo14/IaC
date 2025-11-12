# Environment-specific variables
variable "vm_id" {
  type = number
  default = 9002
  description = "VM ID for this template"
}

variable "memory" {
  type = number
  default = 4096
  description = "Memory in MB"
}

variable "cores" {
  type = number
  default = 1
  description = "Number of CPU cores"
}

# Environment and node variables (set via auto.pkrvars.hcl)
variable "environment" {
  type = string
  default = "dev"
  description = "Environment (dev/prod)"
}

variable "node_suffix" {
  type = string
  default = "pve2"
  description = "Node suffix for naming"
}

variable "proxmox_api_url" {
  type = string
  description = "Proxmox API URL"
}

variable "proxmox_api_token_id" {
  type = string
  description = "Proxmox API token ID"
}

variable "proxmox_api_token_secret" {
  type = string
  description = "Proxmox API token secret"
  sensitive = true
}

variable "proxmox_host" {
  type = string
  description = "Proxmox host identifier for secrets lookup"
}

variable "truenas_root_password" {
  type = string
  description = "TrueNAS root password"
  sensitive = true
}
