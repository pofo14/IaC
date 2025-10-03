# Outputs for the Proxmox Datacenter PCI Mapping Module

output "pci_mapping_names" {
  description = "Map of PCI mapping names created"
  value = {
    for key, mapping in proxmox_virtual_environment_hardware_mapping_pci.pci_mappings : 
    key => mapping.name
  }
}

output "pci_mappings" {
  description = "Full PCI mapping objects"
  value       = proxmox_virtual_environment_hardware_mapping_pci.pci_mappings
}
