variable "environment" {
  type = string
  description = "Environment name (prod, stage, test)"
}

variable "proxmox_host" {
  type = string
  description = "Proxmox host name (pve1, pve2, etc.)"
} 