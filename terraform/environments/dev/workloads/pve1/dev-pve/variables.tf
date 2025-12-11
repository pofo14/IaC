variable "proxmox_host" {
  description = "The Proxmox host to deploy on"
  type        = string
  default     = "pve1"
}

variable "storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}
