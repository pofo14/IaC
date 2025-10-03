# Variables for TrueNAS Test VM

variable "proxmox_host" {
  description = "Proxmox node to deploy on"
  type        = string
  default     = "pve1"
}

variable "truenas_template_id" {
  description = "Template ID to clone for TrueNAS VM"
  type        = string
  default     = "9002"
}

variable "storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "zfs01"
}

variable "hostname" {
  description = "Hostname for the TrueNAS VM"
  type        = string
  default     = "test-truenas1"
}

variable "domain" {
  description = "DNS domain name"
  type        = string
  default     = "flopo.retropetro.net"
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "cores" {
  description = "Number of CPU cores per socket"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory allocation in MB"
  type        = number
  default     = 8192
}

variable "disksize" {
  description = "OS disk size"
  type        = number
  default     = 64
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = ["truenas", "test", "storage"]
}

variable "description" {
  description = "VM description"
  type        = string
  default     = "TrueNAS Test VM - Managed by Terraform"
}

variable "gateway" {
  description = "Default gateway IP address"
  type        = string
}

variable "required_pci_mappings" {
  description = "List of PCI mapping names that must exist (created in infrastructure layer)"
  type        = list(string)
  default     = ["hba-lsi-sas-9300-8i"]
}
