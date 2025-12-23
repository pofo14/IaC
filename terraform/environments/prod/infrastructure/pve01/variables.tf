variable "target_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve01"
}

variable "ubuntu_template_id" {
  description = "Template ID for Ubuntu VMs"
  type        = string
  default     = "9002"
}

variable "ssh_authorized_keys" {
  description = "SSH public keys for VM access"
  type        = list(string)
  default     = []
}

# Network defaults for Management VLAN
variable "management_vlan" {
  description = "Management VLAN configuration"
  type = object({
    network_bridge = string
    gateway        = string
    dns_servers    = list(string)
    subnet_prefix  = string
  })
  default = {
    network_bridge = "vmbr0"
    gateway        = "10.10.10.1"
    dns_servers    = ["10.10.10.41", "10.10.10.42"]
    subnet_prefix  = "24"
  }
}

# Infrastructure VM defaults
variable "default_storage" {
  description = "Default storage pool for VM disks"
  type        = string
  default     = "zfs01"
}

variable "default_disk_type" {
  description = "Default disk controller type"
  type        = string
  default     = "scsi"
}

variable "default_tags" {
  description = "Default tags for all infrastructure VMs"
  type        = map(string)
  default = {
    environment = "prod"
    role        = "infrastructure"
    vlan        = "management"
    managed_by  = "terraform"
  }
}
