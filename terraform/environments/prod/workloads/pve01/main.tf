# ============================================================================
# Workloads for pve01 - Production Environment
# ============================================================================
# All VMs deployed to pve01 Proxmox node
# VM definitions in locals.tf, shared config in variables.tf
# ============================================================================

# ----------------------------------------------------------------------------
# TrueNAS Files - Primary NAS Appliance
# ----------------------------------------------------------------------------
module "truenas-files" {
  source = "../../../../modules/vm-clone-bgp"

  # Proxmox Configuration
  proxmox_host = var.proxmox_host
  template_id  = local.truenas_files.template_id
  storage_pool = var.storage_pool

  # Network Configuration
  hostname  = local.truenas_files.hostname
  domain    = var.domain
  ipaddress = local.truenas_files.ipaddress
  gateway   = var.gateway

  # Hardware Resources
  cores            = local.truenas_files.cores
  sockets          = local.truenas_files.sockets
  cpu_type         = local.truenas_files.cpu_type
  memory           = local.truenas_files.memory
  disksize         = local.truenas_files.disksize
  machine          = local.truenas_files.machine
  skip_disk_config = local.truenas_files.skip_disk_config

  # PCI Passthrough
  pci_mappings            = local.truenas_files.pci_mappings
  pci_passthrough_options = local.truenas_files.pci_passthrough_options
  vlan_tag                = local.truenas_files.vlan_tag

  # Storage
  add_extra_disk = local.truenas_files.add_extra_disk
  extra_disks    = local.truenas_files.extra_disks

  # Metadata
  tags        = local.truenas_files.tags
  description = local.truenas_files.description

  # Cloud-Init (disabled for TrueNAS)
  cloud_init_content = ""


}

# ----------------------------------------------------------------------------
# Docker Hosts - Container Runtime VMs
# ----------------------------------------------------------------------------
# module "docker-hosts" {
#   for_each = local.docker_hosts
#   source   = "../../../../modules/vm-clone-bgp"

#   # Proxmox Configuration
#   proxmox_host = var.proxmox_host
#   template_id  = each.value.template_id
#   storage_pool = var.storage_pool

#   # Network Configuration
#   hostname  = each.value.hostname
#   domain    = var.domain
#   ipaddress = each.value.ipaddress
#   gateway   = var.gateway

#   # Hardware Resources
#   cores    = each.value.cores
#   sockets  = each.value.sockets
#   cpu_type = each.value.cpu_type
#   memory   = each.value.memory
#   disksize = each.value.disksize

#   # PCI Passthrough
#   pci_mappings = each.value.pci_mappings

#   # Storage
#   add_extra_disk = each.value.add_extra_disk
#   extra_disks    = each.value.extra_disks

#   # Metadata
#   tags        = each.value.tags
#   description = each.value.description

#   # Cloud-Init
#   cloud_init_content = each.value.cloud_init_enabled ? templatefile(
#     "${path.module}/cloud-init/${each.value.cloud_init_file}",
#     {
#       hostname = each.value.hostname
#       ssh_keys = local.github_ssh_keys
#     }
#   ) : ""
# }

# # ----------------------------------------------------------------------------
# # Management VMs - Infrastructure Services
# # ----------------------------------------------------------------------------
# module "management-vms" {
#   for_each = local.management_vms
#   source   = "../../../../modules/vm-clone-bgp"

#   # Proxmox Configuration
#   proxmox_host = var.proxmox_host
#   template_id  = each.value.template_id
#   storage_pool = var.storage_pool

#   # Network Configuration
#   hostname  = each.value.hostname
#   domain    = var.domain
#   ipaddress = each.value.ipaddress
#   gateway   = var.gateway

#   # Hardware Resources
#   cores    = each.value.cores
#   sockets  = each.value.sockets
#   cpu_type = each.value.cpu_type
#   memory   = each.value.memory
#   disksize = each.value.disksize

#   # PCI Passthrough
#   pci_mappings = each.value.pci_mappings

#   # Storage
#   add_extra_disk = each.value.add_extra_disk
#   extra_disks    = each.value.extra_disks

#   # Metadata
#   tags        = each.value.tags
#   description = each.value.description

#   # Cloud-Init
#   cloud_init_content = each.value.cloud_init_enabled ? templatefile(
#     "${path.module}/cloud-init/${each.value.cloud_init_file}",
#     {
#       hostname = each.value.hostname
#       ssh_keys = local.github_ssh_keys
#     }
#   ) : ""
# }
