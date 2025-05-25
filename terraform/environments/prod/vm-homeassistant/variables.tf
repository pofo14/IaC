variable "proxmox_node" {
  type        = string
  description = "Proxmox node where the VM will be cloned."
  default     = "pve1"
}

variable "haos_template_name" {
  type        = string
  description = "Name of the HAOS Proxmox template to clone from (created by Packer)."
  default     = "haos-template"
}

variable "haos_vm_name" {
  type        = string
  description = "Hostname for the Home Assistant OS VM."
  default     = "homeassistant"
}

variable "haos_cores" {
  type        = number
  description = "Number of CPU cores for the HAOS VM."
  default     = 2
}

variable "haos_memory" {
  type        = number
  description = "Amount of RAM in MB for the HAOS VM."
  default     = 4096
}

variable "haos_disk_size" {
  type        = string
  description = "Disk size for the HAOS VM (should match template, e.g., 32G)."
  default     = "32G"
}

variable "haos_storage_pool" {
  type        = string
  description = "Proxmox storage pool where the VM's disk will reside. Ensure template can be cloned here."
  default     = "local-lvm" # Match Packer default
}

variable "haos_network_bridge" {
  type        = string
  description = "Proxmox network bridge for the VM."
  default     = "vmbr0"
}

variable "haos_ip_address_cidr" {
  type        = string
  description = "Static IP address for HAOS VM in CIDR notation (e.g., 192.168.1.100/24). Leave empty for DHCP."
  default     = "" 
}

variable "haos_gateway" {
  type        = string
  description = "Gateway address for HAOS VM (required if static IP is set). Leave empty for DHCP."
  default     = ""
}

variable "haos_nameserver" {
  type        = string
  description = "DNS server for HAOS VM."
  default     = "1.1.1.1" # Example, change to your preferred DNS
}

variable "haos_searchdomain" {
  type        = string
  description = "DNS search domain for HAOS VM."
  default     = "" # e.g., "your.domain.local"
  nullable    = true
}

variable "haos_ssh_public_key" {
  type        = string
  description = "Public SSH key to embed in cloud-init for potential SSH access to HAOS."
  default     = "" # Paste your public SSH key here
  nullable    = false # Should be provided
}

variable "haos_ci_user" {
  type        = string
  description = "Cloud-init username (HAOS likely ignores this)."
  default     = "pkruser"
}

variable "haos_ci_password" {
  type        = string
  description = "Cloud-init password (HAOS likely ignores this, set for module completeness)."
  default     = "changeme" # Should be changed or made sensitive if ever actually used
  sensitive   = true
}
