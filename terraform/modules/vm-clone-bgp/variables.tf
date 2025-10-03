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
  default = "proxmox"
}

variable "template_id" {
  description = "The id of the template to clone for this VM"
  type        = string
}

variable "cores" {
  description = "The number of CPU cores for the VM"
  type        = number
  default = 2
}

variable "sockets" {
  description = "The number of CPU sockets for the VM"
  type        = number
  default = 1
}

variable "cpu_type" {
  description = "The type of CPU for the VM"
  type        = string
  default = "x86-64-v2-AES"
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
  description = "SCSI hardware controller to use for the VM (provider-specific)."
  type        = string
  default     = "virtio-scsi-pci"
}

variable "efidisk_enabled" {
  description = "Whether to create an EFI vars disk for OVMF (only relevant if bios='ovmf')"
  type        = bool
  default     = false
}

variable "efidisk_datastore" {
  description = "Datastore id for the efivars disk"
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
  default = 2048
}

variable "tags" {
  description = "The tags to apply to the VM"
  type        = list(string)
  default = []
}

variable "ssh_keys" {
  description = "The ssh keys to apply to the VM"
  type        = list(string)
  default = []
}

variable "description" {
  description = "The descriptions to apply to the VM"
  type        = string
  default = "Managed by Terraform"
}

variable "disksize" {
  description = "The size of the VM's disk in GB"
  type        = string
  default = "20"
}

variable "storage_pool" {
  description = "The storage pool to use for the VM's disk"
  type        = string
  default = "zfsdata01"
}

variable "ipaddress" {
  description = "The IP address to assign to the VM"
  type        = string
  default     = "dhcp"
}

variable "gateway" {
  description = "The IP address to gateway to the VM"
  type        = string
}

variable "use_cloud_init" {
  description = "Whether to use cloud-init for the VM"
  type        = bool
  default     = true
}

variable "pci_mappings" {
  description = "PCI device mappings to attach to the VM"
  type        = list(string)
  default     = []  # Empty by default - no PCI passthrough
}




