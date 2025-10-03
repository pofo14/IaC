# Variables for Test Environment PCI Mappings

variable "pci_mappings" {
  description = "List of PCI devices to map at the datacenter level"
  type = list(object({
    name         = string
    comment      = string
    id           = string
    iommu_group  = string
    node         = string
    path         = string
    subsystem_id = string
  }))
  
  # Default can be overridden in terraform.tfvars
  default = []
}
