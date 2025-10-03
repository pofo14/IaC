# Outputs for Test Environment PCI Mappings

output "pci_mapping_names" {
  description = "Names of created PCI mappings (for reference in workload layer)"
  value       = module.pci_mappings.pci_mapping_names
}

output "created_mappings" {
  description = "List of PCI mapping names that were created"
  value       = [for mapping in var.pci_mappings : mapping.name]
}
