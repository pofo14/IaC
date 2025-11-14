# Environment-specific variables
variable "vm_id" {
  type        = string
  default     = env("TRUENAS_VM_ID")
  description = "VM ID for this template"
}

variable "memory" {
  type    = number
  default = 8192
}

variable "cores" {
  type    = number
  default = 4
}

# Environment and node variables (set via auto.pkrvars.hcl)
variable "environment" {
  type        = string
  description = "Environment (prod, dev, staging)"
}

variable "node_suffix" {
  type        = string
  description = "Node identifier (pve1, pve2)"
}

# Proxmox connection variables
variable "proxmox_api_url" {
  type        = string
  default     = env("PROXMOX_API_URL")
  description = "Proxmox API URL"
}

variable "proxmox_api_token_id" {
  type        = string
  default     = env("PROXMOX_API_TOKEN_ID")
  description = "Proxmox API token ID"
}

variable "proxmox_api_token_secret" {
  type        = string
  default     = env("PROXMOX_API_TOKEN_SECRET")
  sensitive   = true
  description = "Proxmox API token secret"
}

variable "proxmox_host" {
  type        = string
  default     = env("PROXMOX_HOST")
  description = "Proxmox host identifier for secrets lookup"
}

variable "proxmox_node" {
  type        = string
  default     = "pve2"
  description = "Proxmox node name"
}

variable "disk_storage" {
  type        = string
  default     = env("DISK_STORAGE")
  description = "Proxmox storage pool for VM disks"
}

# TrueNAS specific
variable "truenas_root_password" {
  type        = string
  default     = env("TRUENAS_ROOT_PASSWORD")
  sensitive   = true
  description = "Root password for TrueNAS"
}
