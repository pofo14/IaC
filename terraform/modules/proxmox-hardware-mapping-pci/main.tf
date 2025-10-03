# Proxmox Datacenter PCI Mapping Module
#
# This module creates datacenter-level PCI mappings using root privileges
# It should be run before VM creation that requires PCI passthrough

# Create datacenter-level PCI mappings for each device
resource "proxmox_virtual_environment_hardware_mapping_pci" "pci_mappings" {
  for_each = { for m in var.pci_mappings : m.name => m }
  
  # Using default provider with elevated credentials
  comment = var.comment
  name    = each.value.name

  map = [
    {
      comment      = coalesce(each.value.comment, "PCI device passthrough")
      id           = each.value.id
      iommu_group  = each.value.iommu_group
      node         = each.value.node
      path         = each.value.path
      subsystem_id = each.value.subsystem_id
    }
  ]
}

