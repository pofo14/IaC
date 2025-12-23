# ============================================================================
# Shared Infrastructure Variables
# ============================================================================
# Configuration shared across all VMs deployed to this Proxmox node
# VM-specific configuration is in locals.tf

variable "proxmox_host" {
  description = "The Proxmox node name to deploy VMs to"
  type        = string
  default     = "pve01"
}

variable "storage_pool" {
  description = "Default storage pool for VM disks (typically ZFS)"
  type        = string
  default     = "zfs01"
}

variable "domain" {
  description = "DNS domain name for all VMs in this environment"
  type        = string
  default     = "flopo.retropetro.net"
}

variable "gateway" {
  description = "Default gateway IP address for VM network configuration"
  type        = string
  default     = "192.168.2.1"
}

# ============================================================================
# Template IDs
# ============================================================================
# VM template IDs created by Packer builds

variable "ubuntu24_template_id" {
  description = "Template ID for Ubuntu 24.04 LTS (created by Packer)"
  type        = string
  default     = "9002"
}

variable "truenas_template_id" {
  description = "Template ID for TrueNAS SCALE 25.10 (created by Packer)"
  type        = string
  default     = "9001"
}
