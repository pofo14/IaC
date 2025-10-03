# Workload Layer - TrueNAS Test VM
# This creates a TrueNAS VM with PCI passthrough
# PREREQUISITES: Infrastructure layer PCI mappings must exist first

module "truenas_vm" {
  source = "../../../../../modules/vm-clone-bgp"

  # VM Identity
  hostname     = var.hostname
  domain       = var.domain
  proxmox_host = var.proxmox_host
  template_id  = tostring(var.truenas_template_id)
  
  # Storage
  storage_pool = var.storage_pool
  disksize     = var.disksize

  # Compute Resources
  cores   = var.cores
  sockets = var.sockets
  memory  = var.memory

  # VM Settings
  tags        = var.tags
  description = var.description

  # TrueNAS-specific settings
  machine         = "q35"
  bios            = "ovmf"
  scsi_hardware   = "virtio-scsi-single"
  efidisk_enabled = true
  efidisk_datastore = var.storage_pool
  efidisk_type    = "4m"
  
  # Cloud-init (disabled for TrueNAS)
  use_cloud_init = false
  gateway        = var.gateway
  ssh_keys       = local.ssh_keys

  # PCI Passthrough - reference the mappings created in infrastructure layer
  pci_mappings = var.required_pci_mappings

  # Ensure PCI mappings are validated before VM creation
  depends_on = [data.proxmox_virtual_environment_hardware_mapping_pci.required_mappings]
}
