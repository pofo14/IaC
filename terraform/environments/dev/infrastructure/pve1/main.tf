// filepath: /workspaces/IaC/terraform/environments/dev/infrastructure/pve1/main.tf
# PCI Device Mappings for Hardware Passthrough

# Dev has no passthrough
# module "lsi_hba_mapping" {
#   source = "../../../../modules/proxmox-hardware-mapping-pci"

#   node_name    = var.node_name
#   mapping_name = "lsi-hba"
#   pci_ids      = ["0000:01:00.0"]

#   description = "LSI HBA for TrueNAS storage"
# }

### Example for Future Use ###
# module "nvidia_gpu_mapping" {
#   source = "../../../../modules/proxmox-hardware-mapping-pci"

#   node_name    = var.node_name
#   mapping_name = "nvidia-rtx-3090"
#   pci_ids      = ["0000:02:00.0", "0000:02:00.1"]

#   description = "NVIDIA GPU for AI/ML workloads"
# }

# Future: Add storage pools, network bridges, etc.
