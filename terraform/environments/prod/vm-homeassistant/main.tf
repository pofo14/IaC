terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 3.0.1-rc1" # Or your specific version constraint from other files
    }
  }
}

# Provider block for Proxmox - ensure your main provider config is in a central place (e.g., ../../main.tf or similar)
# This is just an example if not using a shared provider configuration.
# provider "proxmox" {
#   pm_api_url = "https://your-proxmox-api-url:8006/api2/json"
#   pm_user    = "your-api-user@pve!tokenid"
#   pm_token_id = "your-api-user@pve!tokenid" # If using token ID directly in username
#   pm_token   = "your-api-token-secret"
#   pm_tls_insecure = true # Set to false in production with valid certs
# }


module "haos_vm" {
  source = "../../../modules/vm-clone" # Adjust path as necessary

  proxmox_host = var.proxmox_node
  template_name = var.haos_template_name
  vm_name       = var.haos_vm_name
  
  cores         = var.haos_cores
  sockets       = 1 # Typically 1 socket, multiple cores
  memory        = var.haos_memory
  
  # Regarding disk: The vm-clone module might try to create/resize a disk.
  # The HAOS template disk is already 32G on scsi0.
  # We need to ensure the module correctly clones this disk.
  # If the module's 'disksize' parameter implies resizing the primary disk, it should match.
  # If the module tries to add a *new* disk, that's not what we want for the OS disk.
  # The existing module defines:
  # disk { storage = var.storage_pool, type = "disk", size = var.disksize, slot = "virtio0" }
  # This will conflict with the scsi0 disk from the template.
  # For HAOS, we want to use the disk cloned from the template, not add a new virtio0.
  # This module might need adjustment or specific parameters to clone the template's disk as-is.
  # For now, passing disksize and storage_pool. This is a critical point for review.
  disksize      = var.haos_disk_size 
  storage_pool  = var.haos_storage_pool 

  network_model = "virtio" # Matches Packer
  bridge        = var.haos_network_bridge

  # Construct ipconfig0 string for Proxmox cloud-init
  # Format: "ip=IP_ADDRESS/CIDR,gw=GATEWAY_IP"
  # Module's var.ipaddress expects this full string.
  ipaddress = var.haos_ip_address_cidr != "" && var.haos_gateway != "" ? "ip=${var.haos_ip_address_cidr},gw=${var.haos_gateway}" : ""

  nameserver   = var.haos_nameserver
  searchdomain = var.haos_searchdomain
  
  ssh_keys     = var.haos_ssh_public_key
  ciuser       = var.haos_ci_user
  cipassword   = var.haos_ci_password

  tags = ["homeassistant", "terraform", var.haos_vm_name]
}
