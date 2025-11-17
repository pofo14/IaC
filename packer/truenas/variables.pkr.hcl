variable "vm_id" {
  type        = number
  description = "VM ID for this template"
}

variable "memory" {
  type    = number
}

variable "cores" {
  type    = number
}

variable "disk_size_gb" {
  type        = string
  description = "Primary disk size in GB"
}

variable "environment" {
  type        = string
  description = "Environment (prod, dev, staging)"
}

variable "node_suffix" {
  type        = string
  description = "Node identifier (pve1, pve2)"
}

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
  default     = "pve1"
  description = "Proxmox node name"
}

variable "disk_storage" {
  type        = string
  default     = env("DISK_STORAGE")
  description = "Proxmox storage pool for VM disks"
}

variable "iso_filename" {
  type        = string
  description = "Proxmox ISO path (e.g., zfs01:iso/TrueNAS-SCALE-25.04.2.1.iso)"
}

variable "storage_pool_zfs" {
  type        = string
  description = "Proxmox storage pool where the ISO resides"
}

variable "storage_pool_iso" {
  type        = string
  description = "Proxmox storage pool where the ISO resides"
}

variable "truenas_version" {
  type        = string
  description = "TrueNAS version label for description/naming (e.g., 24.10.2, 25.04.1)"
}

variable "template_name_prefix" {
  type        = string
  default     = "truenas"
  description = "Prefix for template/VM name (allows distinguishing versions/flavors)"
}

variable "truenas_root_password" {
  type        = string
  default     = env("TRUENAS_ROOT_PASSWORD")
  sensitive   = true
  description = "Root password for TrueNAS"
}

variable "truenas_shutdown_option" {
  type        = string
  default     = "8"
  description = "Console menu option to shut down (usually 9)"
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Proxmox bridge for primary NIC"
}
