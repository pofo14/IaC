# Required Infrastructure Variables
variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM to"
  type        = string
}

variable "ubuntu24_template_id" {
  description = "The ID of the Ubuntu 24 template to clone"
  type        = string
}

variable "domain" {
  description = "The domain name for the VM"
  type        = string
}

variable "gateway" {
  description = "The gateway IP address for the VM"
  type        = string
}

# Optional Configuration Variables with Sensible Defaults
variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1

  validation {
    condition     = var.sockets > 0
    error_message = "Sockets must be greater than 0."
  }
}

variable "cores" {
  description = "Number of CPU cores per socket"
  type        = number
  default     = 2

  validation {
    condition     = var.cores > 0
    error_message = "Cores must be greater than 0."
  }
}

variable "memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default     = 4096

  validation {
    condition     = var.memory >= 512
    error_message = "Memory must be at least 512 MB."
  }
}

variable "cpu_type" {
  description = "The CPU type for the VM"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "description" {
  description = "Description for the VM"
  type        = string
  default     = "Managed by Terraform"
}

variable "tags" {
  description = "List of tags to apply to the VM"
  type        = list(string)
  default     = []
}

variable "ipaddress" {
  description = "The IP configuration for the VM (e.g., 'ip=dhcp' or '192.168.1.10/24')"
  type        = string
  default     = "ip=dhcp"
}