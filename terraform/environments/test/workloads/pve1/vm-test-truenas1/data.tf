# Data sources and locals

data "github_ssh_keys" "pofo14_ssh_keys" {}

locals {
  ssh_keys = data.github_ssh_keys.pofo14_ssh_keys.keys
}

# Verify that required PCI mappings exist before creating VM
# This provides early validation and clear error messages
data "proxmox_virtual_environment_hardware_mapping_pci" "required_mappings" {
  for_each = toset(var.required_pci_mappings)
  name     = each.value
}
