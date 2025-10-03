# Variables for the Proxmox Datacenter PCI Mapping Module

variable "pci_mappings" {
  description = "List of PCI mappings to create at the datacenter level"
  type = list(object({
    name         = string
    comment      = string
    id           = string
    iommu_group  = string
    node         = string
    path         = string
    subsystem_id = string
  }))
  default = []
}

variable "comment" {
  description = "Optional comment for all PCI mappings"
  type        = string
  default     = "Managed by Terraform"
}
