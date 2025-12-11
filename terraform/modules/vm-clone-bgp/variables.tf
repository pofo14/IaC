variable "hostname" {
  description = "The hostname of the VM"
  type        = string
}

variable "domain" {
  description = "The domain to join"
  type        = string
}

variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM on"
  type        = string
  default     = "proxmox"
}

variable "template_id" {
  description = "The ID of the template to clone for this VM"
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
  description = "BIOS type to use for the VM (set to 'ovmf' for UEFI)"
  type        = string
  default     = "seabios"
}

variable "scsi_hardware" {
  description = "SCSI hardware controller to use for the VM (provider-specific)"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "efidisk_enabled" {
  description = "Whether to create an EFI vars disk for OVMF (only relevant if bios='ovmf')"
  type        = bool
  default     = false
}

variable "efidisk_datastore" {
  description = "Datastore ID for the efivars disk"
  type        = string
  default     = "local"
}

variable "efidisk_file_format" {
  description = "File format for the efivars disk"
  type        = string
  default     = "raw"
}

variable "efidisk_type" {
  description = "EFI disk type (e.g., '4m' or '2m')"
  type        = string
  default     = "4m"
}

variable "efidisk_pre_enrolled_keys" {
  description = "Whether to use pre-enrolled keys for the efivars disk"
  type        = bool
  default     = false
}

variable "memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default     = 2048
}

variable "tags" {
  description = "The tags to apply to the VM"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "The description to apply to the VM"
  type        = string
  default     = "Managed by Terraform"
}

variable "add_extra_disk" {
  description = "Whether to add additional disks beyond the template's disk"
  type        = bool
  default     = false
}

variable "extra_disks" {
  description = "List of additional disks to attach (size in GB)"
  type = list(object({
    size = number
    ssd  = optional(bool, true)
  }))
  default = []

  validation {
    condition     = length(var.extra_disks) <= 14 # scsi0 is root, so max 14 extra (scsi1-scsi14)
    error_message = "Maximum 14 extra SCSI disks supported (scsi1-scsi14)"
  }
}

variable "disksize" {
  description = "The size of the extra disk in GB (if add_extra_disk is true)"
  type        = string
  default     = "20"
}

variable "storage_pool" {
  description = "The storage pool to use for the VM's disk"
  type        = string
  default     = "zfs01"
}

variable "storage_pool_snippets" {
  description = "The storage pool to use for cloud-init snippets"
  type        = string
  default     = "local"
}

variable "ipaddress" {
  description = "The IP address to assign to the VM in CIDR notation (e.g., 192.168.1.10/24). Use 'dhcp' for DHCP"
  type        = string
  default     = "dhcp"
}

variable "gateway" {
  description = "The gateway IP address for the VM"
  type        = string
}

variable "cloud_init_content" {
  description = "The cloud-init user-data content to pass to the VM. Set to empty string to disable cloud-init"
  type        = string
  default     = ""
}

variable "pci_mappings" {
  description = "PCI device mappings to attach to the VM"
  type        = list(string)
  default     = []
}
