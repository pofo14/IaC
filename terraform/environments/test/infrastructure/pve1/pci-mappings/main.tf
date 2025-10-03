# Infrastructure Layer - PCI Mappings
# This creates datacenter-level PCI device mappings in Proxmox
# Must be applied BEFORE creating VMs that use these mappings

module "pci_mappings" {
  source = "../../../../../modules/proxmox-hardware-mapping-pci"

  comment = "Test environment PCI mappings for TrueNAS storage controllers"
  
  pci_mappings = var.pci_mappings
}
