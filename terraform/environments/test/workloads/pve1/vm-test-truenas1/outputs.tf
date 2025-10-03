# Outputs for TrueNAS Test VM

output "vm_id" {
  description = "ID of the TrueNAS VM"
  value       = module.truenas_vm.vm_id
}

output "vm_name" {
  description = "Name of the TrueNAS VM"
  value       = module.truenas_vm.vm_name
}

output "pci_mappings_used" {
  description = "PCI mappings attached to this VM"
  value       = var.required_pci_mappings
}
