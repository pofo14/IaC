variable "hostname" {
  description = "The hostname of the VM"
  type        = string
}

variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM on"
  type        = string
}

variable "cores" {
  description = "The number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "sockets" {
  description = "The number of CPU sockets for the VM"
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "The type of CPU for the VM"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "machine" {
  description = "The QEMU machine type for the VM"
  type        = string
  default     = "q35"
}

variable "bios" {
  description = "BIOS type to use for the VM"
  type        = string
  default     = "seabios"
}

variable "memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default     = 4096
}

variable "tags" {
  description = "The tags to apply to the VM"
  type        = list(string)
  default     = ["preseed", "test"]
}

variable "description" {
  description = "The description to apply to the VM"
  type        = string
  default     = "Blank VM for preseed testing - Managed by Terraform"
}

variable "disks" {
  description = "List of disks to create for the VM"
  type = list(object({
    datastore_id = string
    interface    = string # e.g., "scsi0", "scsi1", "sata0", etc.
    size         = number # Size in GB
    file_format  = string # "raw" or "qcow2"
    cache        = optional(string, "none")
    discard      = optional(string, "on")
    iothread     = optional(bool, false)
    ssd          = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for disk in var.disks : can(regex("^(scsi|sata|virtio|ide)\\d+$", disk.interface))
    ])
    error_message = "Disk interface must be in format: scsi0, scsi1, sata0, etc."
  }
}

variable "scsi_hardware" {
  description = "SCSI hardware controller to use for the VM"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "network_bridge" {
  description = "Network bridge to use for the VM"
  type        = string
  default     = "vmbr0"
}

variable "qemu_agent_enabled" {
  description = "Whether to enable QEMU guest agent"
  type        = bool
  default     = false # Disabled by default for preseed testing
}

variable "enable_network_config" {
  description = "Whether to configure network via Proxmox initialization"
  type        = bool
  default     = false # Disabled by default - preseed handles networking
}

variable "ipaddress" {
  description = "The IP address to assign to the VM in CIDR notation (only used if enable_network_config is true)"
  type        = string
  default     = ""
}

variable "gateway" {
  description = "The gateway IP address for the VM (only used if enable_network_config is true)"
  type        = string
  default     = ""
}

variable "start_on_create" {
  description = "Whether to start the VM after creation"
  type        = bool
  default     = false # Don't start - user will attach ISO first
}

variable "mac_address" {
  description = "MAC address for the VM's network interface (optional - Proxmox auto-generates if not specified)"
  type        = string
  default     = null
}
