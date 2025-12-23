variable "proxmox_node" {
  type        = string
  description = "Proxmox node short name to run the build on (for example pve1)."
  default     = env("PROXMOX_NODE")
}

variable "proxmox_api_url" {
  type        = string
  default     = env("PROXMOX_API_URL")
  description = "Full Proxmox API endpoint, e.g. https://pve1.example.com:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type        = string
  default     = env("PROXMOX_API_TOKEN_ID")
  description = "Token ID used for authenticating against the Proxmox API"
}

variable "proxmox_api_token_secret" {
  type        = string
  default     = env("PROXMOX_API_TOKEN_SECRET")
  description = "Token secret used for authenticating against the Proxmox API"
  sensitive   = true
}

variable "vm_id" {
  type        = string
  default     = env("VMID")
  description = "Proxmox VM identifier. Defaults to 0 meaning auto-select next available ID."
}

# variable "vm_name" {
#   type        = string
#   description = "Name assigned to the VM during build."
# }

variable "template_description" {
  type        = string
  description = "Description applied to the resulting Proxmox template."
}

variable "environment" {
  type        = string
  description = "Logical environment label (prod, stage, test, etc.)."
  default     = env("ENV")
}

variable "memory" {
  type        = number
  default     = 8192
  description = "VM memory allocation in MiB."
}

variable "cores" {
  type        = number
  default     = 4
  description = "Number of virtual CPU cores assigned to the VM."
}

variable "sockets" {
  type        = number
  default     = 1
  description = "Number of CPU sockets configured for the VM."
}

variable "disk_storage" {
  type        = string
  default     = env("DISK_STORAGE")
  description = "Proxmox storage pool name used for VM disks."
}

variable "disk_size_gb" {
  type        = number
  default     = 128
  description = "Primary disk size in GiB. TrueNAS recommends 32GB minimum, 64-128GB for future updates."
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Proxmox network bridge to attach VM network adapter."
}

variable "github_user" {
  type        = string
  default     = "pofo14" # env("$GITHUB_USER")
  description = "GitHub username to fetch SSH keys for VM access."
}

# variable "iso_file" {
#   type = string
#   description = "Path to the TrueNAS ISO file in Proxmox storage"
# }

variable "iso_storage_pool" {
  type = string
  description = "Proxmox storage pool where the TrueNAS ISO is located"
}

# variable "boot_command" {
#   type = list(string)
#   description = "Boot command sequence for automated TrueNAS installation"
# }

variable "boot_wait" {
  type = string
  description = "Time to wait for the boot process to start"
  default = "10s"
}

variable "boot_key_interval" {
  type = string
  description = "Interval between boot command keystrokes"
  default = "10ms"
}

variable "truenas_version" {
  type = string
  description = "TrueNAS version to build"
}

variable "truenas_root_password" {
  type = string
  description = "Root password for TrueNAS installation"
  default = env("TRUENAS_ROOT_PASSWORD")
}
variable "truenas_shutdown_option" {
  default = "10"
  type = string
  description = "TrueNAS console menu option to shutdown the system"
}

variable "truenas_shell_option" {
  type = string
  default = "8"
  description = "TrueNAS console menu option to access Linux shell"
}
